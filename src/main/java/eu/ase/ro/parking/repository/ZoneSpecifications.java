package eu.ase.ro.parking.repository;

import eu.ase.ro.parking.entity.ParkingZone;
import org.springframework.data.jpa.domain.Specification;

public class ZoneSpecifications {

    public static Specification<ParkingZone> hasAvailableSpaces() {
        return (root, query, criteriaBuilder) ->
                criteriaBuilder.greaterThan(root.get("totalCapacity"), root.get("occupiedSpaces"));
    }
}