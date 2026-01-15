package eu.ase.ro.parking.controller;

import eu.ase.ro.parking.entity.*;
import eu.ase.ro.parking.repository.*;
import jakarta.annotation.PostConstruct;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class ParkingController {

    @Autowired
    private ParkingZoneRepository zoneRepository;
    @Autowired
    private ReservationRepository reservationRepository;
    @Autowired
    private UserRepository userRepository;

    @PostConstruct
    public void init() {
        if (userRepository.count() == 0) {
            User admin = new User("admin", "admin");
            admin.getLicensePlates().add("B 314 TIK");
            admin.getLicensePlates().add("B 01 ERU");
            admin.getLicensePlates().add("IF 22 VIP");
            userRepository.save(admin);
        }

        if (zoneRepository.count() == 0) {
            ParkingZone zoneA = new ParkingZone("Zona A ", 50, 10.0, 100.0);
            zoneA.setOccupiedSpaces(50);
            zoneRepository.save(zoneA);

            zoneRepository.save(new ParkingZone("Zona B ", 120, 5.0, 60.0));
            zoneRepository.save(new ParkingZone("Zona C", 60, 3.0, 40.0));
            zoneRepository.save(new ParkingZone("Zona D1", 100, 1.0, 15.0));

            ParkingZone fullZone = new ParkingZone("Zona D2", 80, 2.0, 35.0);
            fullZone.setOccupiedSpaces(80);

            zoneRepository.save(fullZone);
        }
    }

    @GetMapping("/")
    public String root() {
        return "redirect:/zones";
    }

    @GetMapping("/zones")
    public String listZones(@RequestParam(required = false) Boolean onlyAvailable,
                            HttpSession session, Model model) {

        User user = (User) session.getAttribute("currentUser");

        List<ParkingZone> zones;
        if (Boolean.TRUE.equals(onlyAvailable)) {
            zones = zoneRepository.findAll(ZoneSpecifications.hasAvailableSpaces());
        } else {
            zones = zoneRepository.findAll();
        }

        LocalDateTime now = LocalDateTime.now();


        model.addAttribute("zones", zones);
        model.addAttribute("user", user);
        return "zones/index";
    }

    @GetMapping("/reserve/{zoneId}")
    public String showReserveForm(@PathVariable Long zoneId, HttpSession session, Model model) {
        User user = (User) session.getAttribute("currentUser");
        if (user == null) return "redirect:/login";

        user = userRepository.findById(user.getId()).orElse(user);

        ParkingZone zone = zoneRepository.findById(zoneId).orElseThrow();
        if (zone.getAvailableSpaces() <= 0) {
            return "redirect:/zones?error=NoSpace";
        }

        model.addAttribute("zone", zone);
        model.addAttribute("savedPlates", user.getLicensePlates());
        return "zones/reserve";
    }

    @PostMapping("/reserve")
    public String processReservation(
            @RequestParam Long zoneId,
            @RequestParam(required = false) String selectedPlate,
            @RequestParam(required = false) String manualPlate,
            @RequestParam String durationType,
            HttpSession session) {

        User sessionUser = (User) session.getAttribute("currentUser");
        if (sessionUser == null) return "redirect:/login";
        User user = userRepository.findById(sessionUser.getId()).orElseThrow();

        ParkingZone zone = zoneRepository.findById(zoneId).orElseThrow();

        String finalPlate;
        if ("manual".equals(selectedPlate) || (manualPlate != null && !manualPlate.isBlank())) {
            finalPlate = manualPlate;
        } else {
            finalPlate = selectedPlate;
        }

        if (zone.getAvailableSpaces() > 0) {
            Reservation res = new Reservation();
            LocalDateTime now = LocalDateTime.now();

            if ("24h".equals(durationType)) {
                res.setup(user, zone, finalPlate, now, now.plusHours(24), zone.getPricePerDay());
            } else {
                res.setup(user, zone, finalPlate, now, now.plusHours(1), zone.getPricePerHour());
            }

            zone.setOccupiedSpaces(zone.getOccupiedSpaces() + 1);
            zoneRepository.save(zone);
            reservationRepository.save(res);
        }

        return "redirect:/account";
    }

    @PostMapping("/account/add-plate")
    public String addLicensePlate(@RequestParam String newPlate, HttpSession session) {
        User sessionUser = (User) session.getAttribute("currentUser");
        if (sessionUser == null) return "redirect:/login";

        User user = userRepository.findById(sessionUser.getId()).orElseThrow();
        if (newPlate != null && !newPlate.trim().isEmpty()) {
            user.getLicensePlates().add(newPlate.trim().toUpperCase());
            userRepository.save(user);
        }
        return "redirect:/account";
    }

    @Autowired
    private PaymentLogRepository paymentLogRepository;

    @GetMapping("/account")
    public String myAccount(HttpSession session, Model model) {
        User user = (User) session.getAttribute("currentUser");
        if (user == null) return "redirect:/login";
        user = userRepository.findById(user.getId()).orElse(user);

        model.addAttribute("user", user);
        model.addAttribute("reservations", reservationRepository.findByUserOrderByStartTimeDesc(user));

        model.addAttribute("paymentLogs", paymentLogRepository.findByUserEmailOrderByTimestampDesc(user.getUsername()));

        model.addAttribute("now", LocalDateTime.now());
        return "account";
    }
}