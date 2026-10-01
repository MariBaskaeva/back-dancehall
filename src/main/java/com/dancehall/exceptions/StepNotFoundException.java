package com.dancehall.exceptions;

public class StepNotFoundException extends RuntimeException {
    public StepNotFoundException(String slug) {
        super("Step with slug '%s' not found".formatted(slug));
    }
}
