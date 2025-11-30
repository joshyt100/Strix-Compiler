#pragma once

#include <assert.h>
#include <map>
#include <string>
#include <vector>

#include "AST.hpp"
#include "helpers.hpp"
#include "lexer.hpp"

using emplex::Lexer;
using emplex::Token;
class ASTNode;

// Information about each variable declared in the source file.
struct VarInfo {
  std::string name;
  size_t def_line;
  Type type;
};

// Information about each function declared in the source file.
struct FunInfo {
  std::string name;
  size_t def_line;
  size_t fun_id;
  std::vector<size_t> param_ids = {}; // IDs of variables used as parameters.
  std::vector<size_t> local_ids =
      {};         // IDs of variables local to this function.
  ASTNode body{}; // ASTNode for function body.
  Type return_type =
      Type::UNKNOWN; // Must set a return type before calling function.
};

class SymbolTable {
public:
  static constexpr size_t NO_ID = static_cast<size_t>(-1);

private:
  std::vector<VarInfo> vars; // Set of ALL variables organized by ID.
  std::vector<FunInfo> funs; // Set of all functions, organized by ID.

  std::string start_memory; // Starting values stored in memory.
  std::map<std::string, size_t> lit_strings; // Position of literal strings.

  using scope_t =
      std::map<std::string, size_t>; // Map of vars in a scope to their IDs.
  std::vector<scope_t> scopes;

  std::map<std::string, size_t> fun_map; // Map of functions to their IDs.
  size_t parse_fun =
      NO_ID; // Current function being parsed (NO_ID means none parsing)

  // Checks to ensure we don't try to use invalid var ids.
  VarInfo &Var(size_t id) {
    assert(id < vars.size());
    return vars[id];
  }
  const VarInfo &Var(size_t id) const {
    assert(id < vars.size());
    return vars[id];
  }

  // Look up the unique ID of a variable.
  size_t FindVarID(std::string name) const {
    size_t scope_id = FindScopeID(name);
    if (scope_id == NO_ID)
      return NO_ID;
    return scopes[scope_id].find(name)->second;
  }

  // Determine which scope a symbol is in; use one past the end if variable is
  // not included.
  size_t FindScopeID(std::string name) const {
    for (size_t scope_id = scopes.size() - 1; scope_id < scopes.size();
         --scope_id) {
      if (scopes[scope_id].contains(name))
        return scope_id;
    }
    return NO_ID;
  }

public:
  SymbolTable() {
    IncScope(); // Create global scope.
  }

  // === SCOPES ===

  void IncScope() { scopes.emplace_back(); }
  void DecScope() { scopes.pop_back(); }

  // === VARIABLES ===

  bool HasVarID(size_t id) const { return id < vars.size(); }
  bool HasVarSymbol(std::string name) const {
    return FindScopeID(name) < scopes.size();
  }
  std::string GetVarName(size_t id) const { return Var(id).name; }
  Type GetVarType(size_t id) const { return Var(id).type; }
  std::string GetWATType(size_t id) const { return ToWATType(Var(id).type); }

  size_t AddVarSymbol(Token id_token, Token type_token, bool is_param = false) {
    return AddVarSymbol(id_token, NameToType(type_token.lexeme), is_param);
  }

  size_t AddVarSymbol(Token id_token, Type type, bool is_param = false) {
    assert(scopes.size() > 0);
    std::string name = id_token.lexeme;

    // Symbols focus on only CURRENT scope.
    scope_t &symbols = scopes.back();
    if (symbols.contains(name)) {
      Error(id_token.line_id, "Redeclaration of variable '", name,
            "' (originally defined on line ", vars[symbols[name]].def_line,
            ")");
    }
    size_t var_id = vars.size();
    vars.push_back(VarInfo{name, id_token.line_id, type});
    symbols[name] = var_id;

    // List this variable as part of the function it is in.
    assert(funs.size() > 0);
    if (is_param)
      funs.back().param_ids.push_back(var_id);
    else
      funs.back().local_ids.push_back(var_id);

    return var_id;
  }

  // Get the ID of a symbol that is expected to be in the symbol table; throw
  // error if not there.
  [[nodiscard]] size_t GetSymbolID(Token token) const {
    std::string name = token.lexeme;
    size_t var_id = FindVarID(name);
    if (var_id == NO_ID) {
      Error(token, "Unknown variable '", name, "'");
    }
    return var_id;
  }

  // === LITERAL STRINGS ===
  size_t AddLiteral(std::string str) {
    // Check if we already have this literal
    if (lit_strings.contains(str))
      return lit_strings[str];

    // Otherwise add it.
    size_t pos = start_memory.size();
    start_memory += str;
    start_memory +=
        '\0'; // Place a null terminator at the end of the literal string.
    lit_strings[str] = pos;
    return pos;
  }

  // === FUNCTIONS ===
  bool HasFunSymbol(std::string name) const { return fun_map.contains(name); }

  size_t GetFunID(std::string name) const {
    auto it = fun_map.find(name);
    if (it == fun_map.end())
      return NO_ID;
    return it->second;
  }

  size_t AddFunction(Token id_token) {
    const std::string name = id_token.lexeme;
    if (HasFunSymbol(name)) {
      Error(id_token.line_id, "Redeclaration of function '", name,
            "' (originally defined on line ", funs[GetFunID(name)].def_line,
            ")");
    }
    parse_fun = funs.size();
    funs.push_back(FunInfo{name, id_token.line_id, parse_fun});
    fun_map[name] = parse_fun;
    return parse_fun;
  }

  void AddFunctionBody(ASTNode &&body) { funs.back().body = std::move(body); }
  void AddFunctionReturn(Type return_type) {
    funs.back().return_type = return_type;
  }
  void AddFunctionReturn(Token token) {
    AddFunctionReturn(NameToType(token.lexeme));
  }

  void EndFunction([[maybe_unused]] size_t fun_id) {
    assert(parse_fun ==
           fun_id); // Check that we are parsing the function we think we are.
    parse_fun = NO_ID;
  }

  size_t GetNumFuns() const { return funs.size(); }

  FunInfo &GetFunInfo(size_t id) { return funs[id]; }

  std::string GetFunName(size_t id) { return funs[id].name; }
  ASTNode &GetFunBody(size_t id) { return funs[id].body; }
  std::vector<size_t> GetFunParams(size_t id) { return funs[id].param_ids; }
  std::vector<size_t> GetFunLocals(size_t id) { return funs[id].local_ids; }

  Type GetReturnType(size_t fun_id) const {
    assert(fun_id < funs.size());
    return funs[fun_id].return_type;
  }

  // === WAT OUTPUT ===
  void PrintWATMemory() const {
    std::cout << "  ;; Define a memory block with ten pages (640KB)\n"
              << "  (memory (export \"memory\") 10)\n";

    if (start_memory.size()) {
      std::cout << "  (data (i32.const 0) \"";
      for (char x : start_memory) {
        if (x == '\0')
          std::cout << "\\00";
        else
          std::cout << x;
      }
      std::cout << "\")\n";
    }
    std::cout << "  (global $free_mem (mut i32) (i32.const "
              << start_memory.size() << "))\n\n";
  }
};
