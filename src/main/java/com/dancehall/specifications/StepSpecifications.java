package com.dancehall.specifications;

import com.dancehall.dto.StepFilter;
import com.dancehall.model.Author;
import com.dancehall.model.Step;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;

import java.util.ArrayList;
import java.util.List;

public final class StepSpecifications {
    public static Specification<Step> byFilter(StepFilter stepFilter) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if(stepFilter.getQ() != null && !stepFilter.getQ().isBlank()) {
                predicates.add(
                        cb.like(
                                cb.lower(root.get("name")),
                                "%" + stepFilter.getQ().toLowerCase() + "%"
                        )
                );
            }
            if(stepFilter.getStyle() != null && !stepFilter.getStyle().isEmpty()) {
                predicates.add(
                        root.get("style").in(stepFilter.getStyle())
                );
            }
            if(stepFilter.getEra() != null && !stepFilter.getEra().isEmpty()) {
                predicates.add(
                        root.get("era").in(stepFilter.getEra())
                );
            }
            if(stepFilter.getAuthor() != null && !stepFilter.getAuthor().isEmpty()) {
                query.distinct(true);
                Join<Step, Author> authorJoin = root.join("author");

                predicates.add(
                        authorJoin.get("slug").in(stepFilter.getAuthor())
                );
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}
