#pragma once

#include <cmath>
#include <memory>
#include <string>
#include <vector>

#include "lexer.hpp"
#include "SymbolTable.hpp"

// As possible base class for ASTNodes 
// NOTE: You may absolutely use your own!
class ASTNode {
protected:
  using ptr_t = std::unique_ptr<ASTNode>;
  std::vector< ptr_t > children{};  // Any sub-trees under this node.

  template <typename T, typename... Ts>
  static void AddCode(std::string prefix, T && line, Ts... message) {
    std::cout << prefix << std::forward<T>(line);
    (std::cout << ... << std::forward<Ts>(message)) << std::endl;
  }
public:
  // Children can be provided at construction
  template <typename... NODE_Ts>
  ASTNode(NODE_Ts &&... nodes) { (AddChild(std::move(nodes)), ...); }

  // Virtual destructor to ensure correct version always gets called.
  virtual ~ASTNode() { } // Children are unique pointers and will delete on their own.

  virtual std::string GetTypeName() const { return "BASE"; }
  virtual std::string ExtraInfo() const { return ""; }

  // Tools to work with child nodes...
  size_t NumChildren() const { return children.size(); }
  ASTNode & Child(size_t id) { assert(children.size() > id); return *(children[id]); }
  const ASTNode & Child(size_t id) const { assert(children.size() > id); return *(children[id]); }

  // Provide an ASTNode type and any constructor arguments to build it in place.
  template <typename NODE_T, typename... ARG_Ts>
  void MakeChild(ARG_Ts &&... args) {
    children.push_back( std::make_unique<NODE_T>(std::forward<ARG_Ts>(args)...) );
  }

  void AddChild(ptr_t && child) {
    children.push_back(std::move(child));
  }

  virtual double Run(SymbolTable & symbols) {
    for (auto & child : children) child->Run(symbols);
    return 0.0;
  }

  // Generate WAT code.  ID how many values were left on the stack.
  virtual void ToWAT(SymbolTable & symbols, std::string prefix, [[maybe_unused]] bool need_result) {
    assert(need_result == false);
    for (auto & child : children) child->ToWAT(symbols, prefix, false);
  }

  virtual void Print(std::string prefix="") const {
    std::cout << prefix << GetTypeName() << ": " << ExtraInfo() << std::endl;
    prefix += "  ";
    for (auto & child : children) child->Print(prefix);
  }

  virtual bool CanAssign() const { return false; }
  virtual double Assign(double value, SymbolTable & /* symbols */) const {
    assert(false);  // Do not call Assign() on a node that can't run it.
    return value;
  }
  virtual void AssignWAT(SymbolTable & /*symbols*/, std::string /*prefix*/) const {
    assert(false);  // Do not call AssignWAT() on a node that can't run it.
  }
};

// Some derived version that may be useful...

// Child0: Condition
// Child1: Body
// Child2: Else
class ASTNode_If : public ASTNode { };

// Child0: Condition
// Child1: Body
class ASTNode_While : public ASTNode { };

// Simple leaf to indicate a break command.
class ASTNode_Break : public ASTNode { };

// Simple leaf to indicate a continue command.
class ASTNode_Continue : public ASTNode { };

// Child0: Value to return
class ASTNode_Return : public ASTNode { };

// Class to handle UNARY operators
class ASTNode_Operator1 : public ASTNode {
protected:
  Token token; // Token to represent this operator (and indicate line number for errors)
};

// Class to handle BINARY operators
class ASTNode_Operator2 : public ASTNode {
protected:
  Token token; // Token to represent this operator (and indicate line number for errors)
};

// A literal number (AST leaf)
class ASTNode_NumLit : public ASTNode {
protected:
  double value{};
};

// A variable (AST leaf)
class ASTNode_Var : public ASTNode {
protected:
  size_t var_id;
};
