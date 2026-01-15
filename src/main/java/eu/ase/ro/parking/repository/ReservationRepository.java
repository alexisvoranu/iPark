package eu.ase.ro.parking.repository;

import eu.ase.ro.parking.entity.ParkingZone;
import eu.ase.ro.parking.entity.Reservation;
import eu.ase.ro.parking.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface ReservationRepository extends JpaRepository<Reservation, Long> {
    List<Reservation> findByUserOrderByStartTimeDesc(User user);

    Optional<Reservation> findFirstByZoneAndEndTimeAfterOrderByEndTimeAsc(ParkingZone zone, LocalDateTime now);
}