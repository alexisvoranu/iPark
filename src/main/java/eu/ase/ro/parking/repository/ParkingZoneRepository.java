package eu.ase.ro.parking.repository;

import eu.ase.ro.parking.entity.ParkingZone;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface ParkingZoneRepository extends JpaRepository<ParkingZone, Long>, JpaSpecificationExecutor<ParkingZone> {
}