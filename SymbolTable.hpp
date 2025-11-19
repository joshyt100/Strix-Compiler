#pragma once

#include <assert.h>
#include <map>
#include <string>
#include <vector>

#include "helpers.hpp"
#include "lexer.hpp"

using emplex::Lexer;
using emplex::Token;
class ASTNode;

class SymbolTable {
private:
  struct VarInfo {
    std::string name;
    double value;
    size_t def_line;
  };

  struct FunInfo {
    std::string name;
    std::vector<size_t> param_ids = {}; // IDs of variables used as parameters.
    std::vector<size_t> local_ids = {}; // IDs of variables local to this function.
    std::unique_ptr<ASTNode> body_ptr = nullptr;  // ASTNode for function body.
    // Return type? -> in future projects!
  };

  std::vector<VarInfo> vars; // Set of ALL variables organized by ID.
  std::vector<FunInfo> funs; // Set of all functions, organized by ID.

  static constexpr size_t NO_ID = static_cast<size_t>(-1);

  using scope_t = std::map<std::string, size_t>; // Map of vars in a scope to their IDs.
  std::vector<scope_t> scopes;

  size_t next_while_id = 1;
  std::vector<size_t> while_ids; // Which while loops are we currently in?

  // Look up the unique ID of a variable.
  size_t FindVarID(std::string name) const {
    size_t scope_id = FindScopeID(name);
    if (scope_id == NO_ID) return NO_ID;
    return scopes[scope_id].find(name)->second;
  }

  // Determine which scope a symbol is in; use one past the end if variable is not included.
  size_t FindScopeID(std::string name) const {
    for (size_t scope_id = scopes.size()-1; scope_id < scopes.size(); --scope_id) {
      if (scopes[scope_id].contains(name)) return scope_id;
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
  // Each variable has a unique ID that you can save and look it up by later, without worrying about names.

  bool HasID(size_t id) const { return id < vars.size(); }
  bool HasSymbol(std::string name) const {
    return FindScopeID(name) < scopes.size();
  }
  std::string GetName(size_t id) const {
    return vars[id].name;
  }

  size_t AddSymbol(Token token, double init_val=0.0, bool is_param=false) {
    assert(scopes.size() > 0);
    std::string name = token.lexeme;

    // Symbols focus on only CURRENT scope.
    scope_t & symbols = scopes.back();
    if (symbols.contains(name)) {
      Error(token.line_id, "Redeclaration of variable '", name,
            "' (originally defined on line ", vars[symbols[name]].def_line, ")");
    }
    size_t var_id = vars.size();
    vars.push_back(VarInfo{name, init_val, token.line_id});
    symbols[name] = var_id;

    // List this variable as part of the function it is in.
    assert(funs.size() > 0);
    if (is_param) funs.back().param_ids.push_back(var_id);
    else funs.back().local_ids.push_back(var_id);

    return var_id;
  }

  double GetIDValue(size_t var_id) const {
    assert(var_id < vars.size());
    return vars[var_id].value;
  }

  // Get the ID of a symbol that is expected to be in the symbol table; throw error if not there.
  [[nodiscard]] size_t GetSymbolID(Token token) const {
    std::string name = token.lexeme;
    size_t var_id = FindVarID(name);
    if (var_id == NO_ID) { Error(token, "Unknown variable '", name, "'"); }
    return var_id;
  }

  [[nodiscard]] double GetSymbolValue(Token token) const {
    size_t var_id = GetSymbolID(token);
    return vars[var_id].value;
  }

  double SetID(size_t var_id, double value) {
    assert(var_id < vars.size());
    return vars[var_id].value = value;
  }

  double SetSymbol(Token token, double value) {
    size_t var_id = GetSymbolID(token);
    return vars[var_id].value = value;
  }

  // === FUNCTIONS ===
  void AddFunction(std::string name) {
    funs.push_back(FunInfo{name});
  }

  void AddFunctionBody(std::unique_ptr<ASTNode> body_ptr) {
    funs.back().body_ptr = std::move(body_ptr);
  }

  size_t GetNumFuns() const { return funs.size(); }

  std::string GetFunName(size_t id) {
    return funs[id].name;
  }
  ASTNode & GetFunBody(size_t id) {
    return *funs[id].body_ptr;
  }
  std::vector<size_t> GetFunParams(size_t id) {
    return funs[id].param_ids;
  }
  std::vector<size_t> GetFunLocals(size_t id) {
    return funs[id].local_ids;
  }

  // === WHILE MANAGEMENT ===

  // Test if we are currently in a while loop.
  bool InWhile() const { return while_ids.size() > 0; }

  // Get the unique ID for the while loop we are in.
  size_t GetWhileID() const {
    assert(InWhile());
    return while_ids.back();
  }

  // Start a new while loop (returns its unique ID)
  size_t AddWhile() {
    while_ids.push_back(next_while_id++);
    return GetWhileID();
  }

  // Finish a while loop (indicate ID and it will make sure it's the inner-most one ending next!)
  size_t ExitWhile([[maybe_unused]] size_t while_id) {
    assert(InWhile() && GetWhileID() == while_id);
    size_t out_id = while_ids.back();
    while_ids.pop_back();
    return out_id;
  }

 };