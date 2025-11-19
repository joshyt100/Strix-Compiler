#pragma once

#include <iostream>

#include "lexer.hpp"

// Various helper functions.

constexpr size_t NPOS = 1 << 30;

template <typename... Ts>
void Error(size_t line_id, Ts... message) {
  std::cerr << "ERROR (line " << line_id << "): ";
  (std::cerr << ... << std::forward<Ts>(message)) << std::endl;
  exit(1);
}

template <typename... Ts>
void Error(emplex::Token token, Ts... message) {
  Error(token.line_id, std::forward<Ts>(message)...);
}

// Add code to the output.
// Prefix indicates spacing to put before each line.
template <typename T, typename... Ts>
static void AddCode(std::string prefix, T && line, Ts... message) {
  std::cout << prefix << std::forward<T>(line);
  (std::cout << ... << std::forward<Ts>(message)) << std::endl;
}
