package com.dancehall.controller;

import com.dancehall.dto.StepFilter;
import com.dancehall.model.Step;
import com.dancehall.service.StepService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.web.PagedModel;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class StepController {
    private final StepService stepService;

    @GetMapping("/steps")
    public PagedModel<Step> getSteps(StepFilter filter) {
        return new PagedModel<>(stepService.listSteps(filter));
    }

//    @GetMapping("/steps2")
//    public Page<Step> getSteps2(StepFilter filter) {
//        return stepService.listSteps(filter);
//    }

    @GetMapping("/steps/{slug}")
    public Step getStepBySlug(@PathVariable String slug) {
        return stepService.getStepBySlug(slug);
    }
}
