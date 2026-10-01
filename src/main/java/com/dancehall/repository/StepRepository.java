package com.dancehall.repository;

import com.dancehall.model.Step;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface StepRepository extends JpaRepository<Step, Long>, JpaSpecificationExecutor<Step> {
    @EntityGraph(attributePaths = "author")
    Page<Step> findAll(Specification<Step> spec, Pageable pageable);

    @EntityGraph(attributePaths = "author")
    Optional<Step> findBySlug(String slug);
}
