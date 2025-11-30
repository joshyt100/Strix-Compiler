#pragma once

#include <iostream>

#include "lexer.hpp"

// === Types and Type helper functions ===

enum class Type { NONE, DOUBLE, INT, STRING, UNKNOWN };

Type NameToType(std::string name) {
  if (name == "none")
    return Type::NONE;
  if (name == "double")
    return Type::DOUBLE;
  if (name == "int")
    return Type::INT;
  if (name == "string")
    return Type::STRING;
  return Type::UNKNOWN;
}

std::string TypeToName(Type type) {
  switch (type) {
  case Type::NONE:
    return "none";
  case Type::DOUBLE:
    return "double";
  case Type::INT:
    return "int";
  case Type::STRING:
    return "string";
  default:
    return "UNKNOWN";
  }
}

std::string ToWATType(Type type) {
  switch (type) {
  case Type::DOUBLE:
    return "f64";
  case Type::INT:
    return "i32";
  case Type::STRING:
    return "i32";
  default:
    return "UNKNOWN";
  }
}

// === Error Handling helpers ===

template <typename... Ts> void Error(size_t line_id, Ts... message) {
  std::cerr << "ERROR (line " << line_id << "): ";
  (std::cerr << ... << std::forward<Ts>(message)) << std::endl;
  exit(1);
}

template <typename... Ts> void Error(emplex::Token token, Ts... message) {
  Error(token.line_id, std::forward<Ts>(message)...);
}
