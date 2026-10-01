package com.dancehall.service;

import com.dancehall.model.Author;
import com.dancehall.repository.AuthorRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AuthorService {

    private final AuthorRepository authorRepository;

    public List<Author> listAuthors() {
        return authorRepository.findAllByOrderByNameAsc();
    }
}