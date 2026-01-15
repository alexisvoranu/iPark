package eu.ase.ro.parking.controller;

import com.stripe.Stripe;
import com.stripe.exception.EventDataObjectDeserializationException;
import com.stripe.exception.StripeException;
import com.stripe.model.Event;
import com.stripe.model.PaymentIntent;
import com.stripe.model.checkout.Session;
import com.stripe.net.Webhook;
import com.stripe.param.checkout.SessionCreateParams;
import eu.ase.ro.parking.entity.*;
import eu.ase.ro.parking.repository.*;
import jakarta.annotation.PostConstruct;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import com.stripe.model.EventDataObjectDeserializer;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Controller
public class PaymentController {

    @Value("${stripe.api.key}")
    private String stripeApiKey;

    @Value("${stripe.webhook.secret}")
    private String endpointSecret;

    @Autowired
    private ParkingZoneRepository zoneRepository;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private ReservationRepository reservationRepository;
    @Autowired
    private PaymentLogRepository paymentLogRepository;

    @PostConstruct
    public void init() {
        Stripe.apiKey = stripeApiKey;
    }

    @PostMapping("/payment/checkout")
    public String createCheckoutSession(
            @RequestParam Long zoneId,
            @RequestParam String licensePlate,
            @RequestParam String durationType,
            @RequestParam(defaultValue = "1") int hours,
            HttpSession httpSession,
            HttpServletRequest request) throws StripeException {

        User user = (User) httpSession.getAttribute("currentUser");
        if (user == null) return "redirect:/login";

        ParkingZone zone = zoneRepository.findById(zoneId).orElseThrow();
        String finalPlate = licensePlate.toUpperCase().trim();

        double amount;
        String productName;

        if ("daily".equals(durationType)) {
            amount = zone.getPricePerDay();
            productName = "Parcare " + zone.getName() + " - 1 Zi (24h)";
        } else {
            amount = zone.getPricePerHour() * hours;
            productName = "Parcare " + zone.getName() + " - " + hours + " Ore";
        }

        long amountInBani = (long) (amount * 100);

        Map<String, String> metadata = new HashMap<>();
        metadata.put("userId", user.getId().toString());
        metadata.put("zoneId", zone.getId().toString());
        metadata.put("plate", finalPlate);
        metadata.put("duration", durationType);
        metadata.put("hours", String.valueOf(hours));
        metadata.put("username", user.getUsername());

        String baseUrl = ServletUriComponentsBuilder.fromRequestUri(request)
                .replacePath(null)
                .build()
                .toUriString();

        String appUrl = baseUrl + "/iPark";

        SessionCreateParams params = SessionCreateParams.builder()
                .setMode(SessionCreateParams.Mode.PAYMENT)
                .setSuccessUrl(appUrl + "/payment/success")
                .setCancelUrl(appUrl + "/payment/cancel")
                .addLineItem(SessionCreateParams.LineItem.builder()
                        .setQuantity(1L)
                        .setPriceData(SessionCreateParams.LineItem.PriceData.builder()
                                .setCurrency("ron")
                                .setUnitAmount(amountInBani)
                                .setProductData(SessionCreateParams.LineItem.PriceData.ProductData.builder()
                                        .setName(productName)
                                        .build())
                                .build())
                        .build())
                .putAllMetadata(metadata)
                .build();

        Session session = Session.create(params);

        return "redirect:" + session.getUrl();
    }

    @PostMapping("/webhook")
    @ResponseBody
    public String handleStripeWebhook(@RequestBody String payload, HttpServletRequest request)
            throws EventDataObjectDeserializationException {
        String sigHeader = request.getHeader("Stripe-Signature");
        Event event;

        try {
            event = Webhook.constructEvent(payload, sigHeader, endpointSecret);
        } catch (Exception e) {
            return "Webhook error";
        }

        if ("checkout.session.completed".equals(event.getType())) {
            EventDataObjectDeserializer dataDeserializer = event.getDataObjectDeserializer();
            Session session = null;

            if (dataDeserializer.getObject().isPresent()) {
                session = (Session) dataDeserializer.getObject().get();
            } else {
                try {
                    session = (Session) dataDeserializer.deserializeUnsafe();
                } catch (Exception e) {
                    System.out.println("Eroare gravă deserializare Stripe: " + e.getMessage());
                }
            }

            if (session != null) {
                handleSuccess(session);
            } else {
                System.out.println("Nu s-a putut deserializa sesiunea pentru evenimentul: " + event.getId());
            }

        } else if ("payment_intent.payment_failed".equals(event.getType())) {
            EventDataObjectDeserializer dataDeserializer = event.getDataObjectDeserializer();
            PaymentIntent intent = null;
            if (dataDeserializer.getObject().isPresent()) {
                intent = (PaymentIntent) dataDeserializer.getObject().get();
            } else {
                intent = (PaymentIntent) dataDeserializer.deserializeUnsafe();
            }

            if (intent != null) {
                handleFailure(intent);
            }
        }

        return "ok";
    }

    private void handleSuccess(Session session) {
        Map<String, String> meta = session.getMetadata();
        Long userId = Long.valueOf(meta.get("userId"));
        Long zoneId = Long.valueOf(meta.get("zoneId"));
        String plate = meta.get("plate");
        String duration = meta.get("duration");
        int hours = meta.containsKey("hours") ? Integer.parseInt(meta.get("hours")) : 1;

        Double amount = session.getAmountTotal() / 100.0;

        paymentLogRepository.save(new PaymentLog(meta.get("username"), amount, "SUCCESS",
                "Plată confirmată.", session.getId()));

        User user = userRepository.findById(userId).orElseThrow();
        ParkingZone zone = zoneRepository.findById(zoneId).orElseThrow();

        Reservation res = new Reservation();
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime end;

        if ("daily".equals(duration)) {
            end = now.plusHours(24);
        } else {
            end = now.plusHours(hours);
        }

        res.setup(user, zone, plate, now, end, amount);

        zone.setOccupiedSpaces(zone.getOccupiedSpaces() + 1);
        zoneRepository.save(zone);
        reservationRepository.save(res);
    }

    private void handleFailure(PaymentIntent intent) {
        String errorMsg = intent.getLastPaymentError() != null ? intent.getLastPaymentError().getMessage() : "Eroare necunoscută";
        Double amount = intent.getAmount() / 100.0;

        paymentLogRepository.save(new PaymentLog("Sistem/User", amount, "FAILED", errorMsg, intent.getId()));
    }

    @GetMapping("/payment/success")
    public String paymentSuccess() {
        return "redirect:/account?msg=success";
    }

    @GetMapping("/payment/cancel")
    public String paymentCancel(HttpSession session) {
        User user = (User) session.getAttribute("currentUser");
        if (user != null) {
            paymentLogRepository.save(new PaymentLog(user.getUsername(), 0.0, "CANCELED",
                    "Utilizatorul a anulat plata.", "N/A"));
        }
        return "redirect:/account?msg=canceled";
    }
}