package eu.ase.ro.parking.entity;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
public class Reservation {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String licensePlate;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private Double cost;

    @ManyToOne
    private ParkingZone zone;

    @ManyToOne
    private User user;

    public Reservation() {
    }

    public void setup(User user, ParkingZone zone, String licensePlate, LocalDateTime start, LocalDateTime end, Double cost) {
        this.user = user;
        this.zone = zone;
        this.licensePlate = licensePlate;
        this.startTime = start;
        this.endTime = end;
        this.cost = cost;
    }

    public Long getId() {
        return id;
    }

    public String getLicensePlate() {
        return licensePlate;
    }

    public LocalDateTime getStartTime() {
        return startTime;
    }

    public LocalDateTime getEndTime() {
        return endTime;
    }

    public Double getCost() {
        return cost;
    }

    public ParkingZone getZone() {
        return zone;
    }

    public User getUser() {
        return user;
    }
}