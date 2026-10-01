package com.dancehall.exceptions;

public record ErrorResponse(
        String code,
        String message
) {
}