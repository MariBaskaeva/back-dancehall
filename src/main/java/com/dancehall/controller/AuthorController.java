package com.dancehall.controller;

import com.dancehall.dto.AuthorCollection;
import com.dancehall.service.AuthorService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AuthorController {
    private final AuthorService authorService;

    @GetMapping("/authors")
    public AuthorCollection getAuthors() {
        return new AuthorCollection(authorService.listAuthors());
    }
}
