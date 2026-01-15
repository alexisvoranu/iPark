package eu.ase.ro.parking.entity;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
public class PaymentLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String userEmail;
    private Double amount;
    private String status;
    private String message;
    private LocalDateTime timestamp;
    private String stripeSessionId;

    public PaymentLog() {
    }

    public PaymentLog(String userEmail, Double amount, String status, String message, String stripeSessionId) {
        this.userEmail = userEmail;
        this.amount = amount;
        this.status = status;
        this.message = message;
        this.stripeSessionId = stripeSessionId;
        this.timestamp = LocalDateTime.now();
    }

    public String getStatus() {
        return status;
    }

    public String getMessage() {
        return message;
    }

    public Double getAmount() {
        return amount;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public String getUserEmail() {
        return userEmail;
    }
}