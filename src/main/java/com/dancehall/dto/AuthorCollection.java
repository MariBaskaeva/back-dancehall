package com.dancehall.dto;

import com.dancehall.model.Author;

import java.util.List;

public record AuthorCollection(
        List<Author> items
) {
}