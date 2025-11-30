#pragma once

#include <cmath>
#include <memory>
#include <string>
#include <vector>

#include "helpers.hpp"
#include "lexer.hpp"

using emplex::Token;

enum class ASTType {
  NONE = 0,
  BLOCK,
  IF,
  WHILE,
  BREAK,
  CONTINUE,
  RETURN, // Controllers
  CALL,
  OP1,
  OP2,
  INDEX, // Functions
  LIT_DOUBLE,
  LIT_INT,
  LIT_STRING,
  VAR, // Leaves
  UNKNOWN
};

std::string TypeToName(ASTType type) {
  switch (type) {
  case ASTType::NONE:
    return "None";
  case ASTType::BLOCK:
    return "BLOCK";
  case ASTType::IF:
    return "IF";
  case ASTType::WHILE:
    return "WHILE";
  case ASTType::BREAK:
    return "BREAK";
  case ASTType::CONTINUE:
    return "CONTINUE";
  case ASTType::RETURN:
    return "RETURN";
  case ASTType::CALL:
    return "CALL";
  case ASTType::OP1:
    return "OP1";
  case ASTType::OP2:
    return "OP2";
  case ASTType::INDEX:
    return "INDEX";
  case ASTType::LIT_DOUBLE:
    return "LIT_DOUBLE";
  case ASTType::LIT_INT:
    return "LIT_INT";
  case ASTType::LIT_STRING:
    return "LIT_STRING";
  case ASTType::VAR:
    return "VAR";
  default:
    return "UNKNOWN";
  }
}

class ASTNode {
protected:
  ASTType node_type = ASTType::UNKNOWN; // Type of this AST node.
  Token token;                   // Original token responsible for this node
  Type out_type = Type::UNKNOWN; // Type does this node resolves to
  size_t symbol_id =
      static_cast<size_t>(-1); // ID for relevant symbols in table.
  std::string
      extra_info; // Extra information about node for informative debugging.
  std::vector<ASTNode> children{}; // Any sub-trees under this node.

public:
  ASTNode() {}

  // Children can be provided at construction
  template <typename... NODE_Ts>
  ASTNode(ASTType node_type, Token token, NODE_Ts &&...nodes)
      : node_type(node_type), token(token) {
    (AddChild(std::forward<NODE_Ts>(nodes)), ...);
  }

  ASTType GetNodeType() const { return node_type; };

  size_t GetLineID() const { return token.line_id; }
  std::string GetLexeme() const { return token.lexeme; }

  Type GetType() const { return out_type; }
  void SetType(Type in) { out_type = in; }

  size_t GetSymbolID() const { return symbol_id; }
  void SetSymbolID(size_t id) { symbol_id = id; }

  std::string GetExtra() const { return extra_info; }
  void SetExtra(std::string in) { extra_info = in; }

  // Tools to work with child nodes...
  size_t NumChildren() const { return children.size(); }
  ASTNode &Child(size_t id) {
    assert(children.size() > id);
    return children[id];
  }
  const ASTNode &Child(size_t id) const {
    assert(children.size() > id);
    return children[id];
  }
  void AddChild(ASTNode &&child) { children.push_back(std::move(child)); }

  // === HELPER FUNCTIONS ===

  template <typename... Ts> void Error(Ts &&...message) const {
    ::Error(token.line_id, std::forward<Ts>(message)...);
  }

  void Print(std::string prefix = "") const {
    std::cout << prefix << TypeToName(node_type) << ": " << extra_info
              << std::endl;
    for (auto &child : children)
      child.Print(prefix + "  ");
  }

  bool CanAssign() const {
    return node_type == ASTType::VAR || node_type == ASTType::INDEX;
  }
};

ASTNode ASTNode_Block(Token token) { return ASTNode{ASTType::BLOCK, token}; }
ASTNode ASTNode_If(Token token, ASTNode &&test, ASTNode &&action) {
  return ASTNode{ASTType::IF, token, std::move(test), std::move(action)};
}
ASTNode ASTNode_If(Token token, ASTNode &&test, ASTNode &&action,
                   ASTNode &&alt_action) {
  return ASTNode{ASTType::IF, token, std::move(test), std::move(action),
                 std::move(alt_action)};
}
ASTNode ASTNode_While(Token token, ASTNode &&test, ASTNode &&action) {
  return ASTNode{ASTType::WHILE, token, std::move(test), std::move(action)};
}
ASTNode ASTNode_Break(Token token) { return ASTNode{ASTType::BREAK, token}; }
ASTNode ASTNode_Continue(Token token) {
  return ASTNode{ASTType::CONTINUE, token};
}
ASTNode ASTNode_Return(Token token, ASTNode &&value) {
  return ASTNode{ASTType::RETURN, token, std::move(value)};
}

ASTNode ASTNode_Call(Token token, size_t fun_id) {
  ASTNode out{ASTType::CALL, token};
  out.SetSymbolID(fun_id);
  out.SetExtra("Function:" + std::to_string(fun_id));
  return out;
}

ASTNode ASTNode_Operator(Token token, ASTNode child) {
  ASTNode out{ASTType::OP1, token, std::move(child)};
  out.SetExtra("Operator:" + token.lexeme);
  return out;
}

ASTNode ASTNode_Operator(Token token, ASTNode child1, ASTNode child2) {
  ASTNode out{ASTType::OP2, token, std::move(child1), std::move(child2)};
  out.SetExtra("Operator:" + token.lexeme);
  return out;
}

ASTNode ASTNode_Index(Token token, ASTNode child1, ASTNode child2) {
  return ASTNode{ASTType::INDEX, token, std::move(child1), std::move(child2)};
}

ASTNode ASTNode_LitDouble(Token token) {
  return ASTNode{ASTType::LIT_DOUBLE, token};
}
ASTNode ASTNode_LitInt(Token token) { return ASTNode{ASTType::LIT_INT, token}; }
ASTNode ASTNode_LitString(Token token, std::string value, int mem_pos) {
  ASTNode out{ASTType::LIT_STRING, token};
  out.SetExtra(value);
  out.SetSymbolID(mem_pos);
  return out;
}

ASTNode ASTNode_Var(Token token, size_t var_id, Type type) {
  ASTNode out{ASTType::VAR, token};
  out.SetExtra(token.lexeme);
  out.SetSymbolID(var_id);
  out.SetType(type);
  return out;
}
