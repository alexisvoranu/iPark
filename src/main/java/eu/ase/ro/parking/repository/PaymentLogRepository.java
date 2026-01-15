package eu.ase.ro.parking.repository;

import eu.ase.ro.parking.entity.PaymentLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PaymentLogRepository extends JpaRepository<PaymentLog, Long> {
    List<PaymentLog> findByUserEmailOrderByTimestampDesc(String userEmail);
}