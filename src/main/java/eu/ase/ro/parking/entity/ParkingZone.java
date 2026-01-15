package eu.ase.ro.parking.entity;

import jakarta.persistence.*;

@Entity
public class ParkingZone {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private Integer totalCapacity;
    private Integer occupiedSpaces = 0;
    private Double pricePerHour;
    private Double pricePerDay;

    public ParkingZone() {
    }

    public ParkingZone(String name, Integer totalCapacity, Double pricePerHour, Double pricePerDay) {
        this.name = name;
        this.totalCapacity = totalCapacity;
        this.pricePerHour = pricePerHour;
        this.pricePerDay = pricePerDay;
    }

    public int getAvailableSpaces() {
        return totalCapacity - occupiedSpaces;
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public Integer getTotalCapacity() {
        return totalCapacity;
    }

    public Integer getOccupiedSpaces() {
        return occupiedSpaces;
    }

    public void setOccupiedSpaces(Integer occupiedSpaces) {
        this.occupiedSpaces = occupiedSpaces;
    }

    public Double getPricePerHour() {
        return pricePerHour;
    }

    public Double getPricePerDay() {
        return pricePerDay;
    }

    public void setPricePerDay(Double pricePerDay) {
        this.pricePerDay = pricePerDay;
    }
}