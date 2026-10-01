package com.dancehall.dto;

import com.dancehall.model.StepEra;
import com.dancehall.model.StepStyle;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class StepFilter {
    private String q;
    private List<StepStyle> style;
    private List<StepEra> era;
    private List<String> author;
    private Integer page = 0;
    private Integer size = 20;

}
