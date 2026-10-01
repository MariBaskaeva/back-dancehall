package com.dancehall.service;

import com.dancehall.dto.StepFilter;
import com.dancehall.exceptions.StepNotFoundException;
import com.dancehall.model.Step;
import com.dancehall.repository.StepRepository;
import com.dancehall.specifications.StepSpecifications;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class StepService {
    private final StepRepository repository;

    public Page<Step> listSteps(StepFilter stepFilter) {
        Specification<Step> specification = StepSpecifications.byFilter(stepFilter);
        Pageable pageable = PageRequest.of(stepFilter.getPage(), stepFilter.getSize());

        return repository.findAll(specification, pageable);
    }

    public Step getStepBySlug(String slug) {
        return repository.findBySlug(slug)
                .orElseThrow(() -> new StepNotFoundException(slug));
    }
}
