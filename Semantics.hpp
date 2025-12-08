#pragma once

// Visitor pattern for moving though an AST and ensuring all semantics are
// valid.

#include <string>

#include "AST.hpp"
#include "SymbolTable.hpp"
#include "lexer.hpp"

class Semantics {
private:
  size_t while_depth = 0;
  SymbolTable &symbols;               // Full symbol table
  size_t fun_id = SymbolTable::NO_ID; // Current function being analyzed.

  // === HELPER FUNCTIONS ===

  bool IsNumeric(Type type) const {
    return (type == Type::INT || type == Type::DOUBLE);
  }

  void RequireInt(ASTNode &node, Type found_type, std::string error) {
    if (found_type != Type::INT) {
      node.Error(error, "; type ", TypeToName(found_type), " found.");
    }
  }

  void RequireString(ASTNode &node, Type found_type, std::string error) {
    if (found_type != Type::STRING) {
      node.Error(error, "; type ", TypeToName(found_type), " found.");
    }
  }

  void RequireNumeric(ASTNode &node, Type found_type, std::string error) {
    if (found_type == Type::STRING) {
      node.Error(error, "; type ", TypeToName(found_type), " found.");
    }
  }

  bool IsBuiltin(const std::string &name) const {
    return name == "AddButton" || name == "AddKeypress" ||
           name == "AddClickFun" || name == "AddMoveFun" ||
           name == "AddAnimFun" || name == "SetTitle" || name == "LineColor" ||
           name == "FillColor" || name == "LineWidth" || name == "Line" ||
           name == "Rect" || name == "Circle" || name == "Text";
  }

  void CheckBuiltinCall(ASTNode &node) {
    const std::string &name = node.GetExtra(); // we didn't store name here,
                                               // so use token lexeme instead
  }

public:
  Semantics(SymbolTable &symbols) : symbols(symbols) {}

  // Analyze all functions in the symbol table.
  void Analyze() {
    for (auto &init_node : symbols.GetGlobalInits()) {
      Analyze(init_node);
    }

    for (fun_id = 0; fun_id < symbols.GetNumFuns(); ++fun_id) {
      Analyze(symbols.GetFunBody(fun_id));
    }
  }

  Type Analyze(ASTNode &node) {
    Type type = Type::UNKNOWN;
    switch (node.GetNodeType()) {
    case ASTType::BLOCK:
      type = Analyze_BLOCK(node);
      break;
    case ASTType::BREAK:
      type = Analyze_BREAK(node);
      break;
    case ASTType::CALL:
      type = Analyze_CALL(node);
      break;
    case ASTType::CONTINUE:
      type = Analyze_CONTINUE(node);
      break;
    case ASTType::IF:
      type = Analyze_IF(node);
      break;
    case ASTType::INDEX:
      type = Analyze_INDEX(node);
      break;
    case ASTType::LIT_DOUBLE:
      type = Analyze_LIT_DOUBLE(node);
      break;
    case ASTType::LIT_INT:
      type = Analyze_LIT_INT(node);
      break;
    case ASTType::LIT_STRING:
      type = Analyze_LIT_STRING(node);
      break;
    case ASTType::OP1:
      type = Analyze_OP1(node);
      break;
    case ASTType::OP2:
      type = Analyze_OP2(node);
      break;
    case ASTType::RETURN:
      type = Analyze_RETURN(node);
      break;
    case ASTType::VAR:
      type = Analyze_VAR(node);
      break;
    case ASTType::WHILE:
      type = Analyze_WHILE(node);
      break;
    default:
      std::cerr << "Internal Compiler Error: Unknown AST Node '"
                << TypeToName(node.GetNodeType()) << "'." << std::endl;
      exit(2);
    }

    node.SetType(type);
    return type;
  }

  Type Analyze_BLOCK(ASTNode &node) {
    // Perform a semantic analysis on all children.
    for (size_t i = 0; i < node.NumChildren(); ++i) {
      Analyze(node.Child(i));
    }
    return Type::NONE;
  }

  Type Analyze_BREAK(ASTNode &node) {
    assert(node.NumChildren() == 0);
    if (while_depth == 0) {
      node.Error(
          "All 'break' statements must be used inside of 'while' loops.");
    }
    return Type::NONE;
  }

  Type Analyze_CALL(ASTNode &node) {
    size_t id = node.GetSymbolID();

    if (id == SymbolTable::NO_ID) {
      const std::string name = node.GetLexeme();

      if (!IsBuiltin(name)) {
        node.Error("Unknown function '", name, "'.");
      }

      if (name == "AddButton") {
        if (node.NumChildren() != 2) {
          node.Error(
              "Function call to 'AddButton' expected 2 arguments, but found ",
              node.NumChildren(), ".");
        }
        Type t0 = Analyze(node.Child(0));
        Type t1 = Analyze(node.Child(1));
        if (t0 != Type::STRING) {
          node.Error("First argument to 'AddButton' must be of type string, "
                     "but found type ",
                     TypeToName(t0), ".");
        }
        if (t1 != Type::STRING) {
          node.Error("Second argument to 'AddButton' must be of type string, "
                     "but found type ",
                     TypeToName(t1), ".");
        }
        return Type::NONE;
      }

      if (name == "AddKeypress") {
        if (node.NumChildren() != 2) {
          node.Error(
              "Function call to 'AddKeypress' expected 2 arguments, but found ",
              node.NumChildren(), ".");
        }
        Type t0 = Analyze(node.Child(0));
        Type t1 = Analyze(node.Child(1));
        if (t0 != Type::STRING) {
          node.Error("First argument to 'AddKeypress' must be of type string, "
                     "but found type ",
                     TypeToName(t0), ".");
        }
        if (t1 != Type::STRING) {
          node.Error("Second argument to 'AddKeypress' must be of type string, "
                     "but found type ",
                     TypeToName(t1), ".");
        }
        return Type::NONE;
      }

      if (name == "AddClickFun" || name == "AddMoveFun" ||
          name == "AddAnimFun") {
        if (node.NumChildren() != 1) {
          node.Error("Function call to '", name,
                     "' expected 1 argument, but found ", node.NumChildren(),
                     ".");
        }
        Type t0 = Analyze(node.Child(0));
        if (t0 != Type::STRING) {
          node.Error("First argument to '", name,
                     "' must be of type string, but found type ",
                     TypeToName(t0), ".");
        }
        return Type::NONE;
      }

      if (name == "SetTitle" || name == "LineColor" || name == "FillColor") {
        if (node.NumChildren() != 1) {
          node.Error("Function call to '", name,
                     "' expected 1 argument, but found ", node.NumChildren(),
                     ".");
        }
        Type t0 = Analyze(node.Child(0));
        if (t0 != Type::STRING) {
          node.Error("First argument to '", name,
                     "' must be of type string, but found type ",
                     TypeToName(t0), ".");
        }
        return Type::NONE;
      }

      if (name == "LineWidth") {
        if (node.NumChildren() != 1) {
          node.Error(
              "Function call to 'LineWidth' expected 1 argument, but found ",
              node.NumChildren(), ".");
        }
        Type t0 = Analyze(node.Child(0));
        RequireInt(node.Child(0), t0,
                   "Argument to 'LineWidth' must have type int");
        return Type::NONE;
      }

      if (name == "Line") {
        if (node.NumChildren() != 4) {
          node.Error("Function call to 'Line' expected 4 arguments, but found ",
                     node.NumChildren(), ".");
        }
        for (size_t i = 0; i < 4; ++i) {
          Type t = Analyze(node.Child(i));
          RequireInt(node.Child(i), t,
                     "Arguments to 'Line' must all have type int");
        }
        return Type::NONE;
      }

      if (name == "Rect") {
        if (node.NumChildren() != 4) {
          node.Error("Function call to 'Rect' expected 4 arguments, but found ",
                     node.NumChildren(), ".");
        }
        for (size_t i = 0; i < 4; ++i) {
          Type t = Analyze(node.Child(i));
          RequireInt(node.Child(i), t,
                     "Arguments to 'Rect' must all have type int");
        }
        return Type::NONE;
      }

      if (name == "Circle") {
        if (node.NumChildren() != 3) {
          node.Error(
              "Function call to 'Circle' expected 3 arguments, but found ",
              node.NumChildren(), ".");
        }
        for (size_t i = 0; i < 3; ++i) {
          Type t = Analyze(node.Child(i));
          RequireInt(node.Child(i), t,
                     "Arguments to 'Circle' must all have type int");
        }
        return Type::NONE;
      }

      if (name == "Text") {
        if (node.NumChildren() != 4) {
          node.Error("Function call to 'Text' expected 4 arguments, but found ",
                     node.NumChildren(), ".");
        }
        for (size_t i = 0; i < 3; ++i) {
          Type t = Analyze(node.Child(i));
          RequireInt(node.Child(i), t,
                     "The first three arguments to 'Text' must have type int");
        }
        Type t3 = Analyze(node.Child(3));
        if (t3 != Type::STRING) {
          node.Error("Fourth argument to 'Text' must be of type string, but "
                     "found type ",
                     TypeToName(t3), ".");
        }
        return Type::NONE;
      }

      node.Error("Unknown built-in function '", name, "'.");
    }

    const FunInfo &fun_info = symbols.GetFunInfo(node.GetSymbolID());

    // Make sure we have the correct number of arguments.
    if (fun_info.param_ids.size() != node.NumChildren()) {
      node.Error("Function call to '", fun_info.name, "' expected ",
                 fun_info.param_ids.size(), " arguments, but found ",
                 node.NumChildren(), ".");
    }

    // Check that sub-tree for each arg is semantically correct and returns
    // correct type.
    for (size_t i = 0; i < node.NumChildren(); ++i) {
      Type arg_type = Analyze(node.Child(i));
      Type param_type = symbols.GetVarType(fun_info.param_ids[i]);
      if (arg_type == Type::INT && param_type == Type::DOUBLE)
        arg_type = Type::DOUBLE;
      if (arg_type != param_type) {
        node.Error("Expected argument ", i, " of call to '", fun_info.name,
                   "' to be of type ", TypeToName(param_type),
                   ", but found type ", TypeToName(arg_type), ".");
      }
    }

    return fun_info.return_type;
  }

  Type Analyze_CONTINUE(ASTNode &node) {
    assert(node.NumChildren() == 0);
    if (while_depth == 0) {
      node.Error(
          "All 'continue' statements must be used inside of 'while' loops.");
    }
    return Type::NONE;
  }

  Type Analyze_IF(ASTNode &node) {
    assert(node.NumChildren() >= 2 && node.NumChildren() <= 3);

    Type cond_type = Analyze(node.Child(0));
    RequireNumeric(node, cond_type,
                   "Type mismatch: If 'condition' must be numeric");

    // Analyze THEN and ELSE sub-trees.
    Analyze(node.Child(1));
    if (node.NumChildren() > 2)
      Analyze(node.Child(2));

    return Type::NONE;
  }

  Type Analyze_INDEX(ASTNode &node) {
    assert(node.NumChildren() == 2);

    Type base_type = Analyze(node.Child(0));
    Type index_type = Analyze(node.Child(1));

    RequireString(node, base_type, "Indexing can be done only on string type");
    RequireInt(node, index_type, "Indexing must be to int positions");

    return Type::INT;
  }

  Type Analyze_LIT_DOUBLE([[maybe_unused]] ASTNode &node) {
    assert(node.NumChildren() == 0);
    return Type::DOUBLE;
  }

  Type Analyze_LIT_INT([[maybe_unused]] ASTNode &node) {
    assert(node.NumChildren() == 0);
    return Type::INT;
  }

  Type Analyze_LIT_STRING([[maybe_unused]] ASTNode &node) {
    assert(node.NumChildren() == 0);
    return Type::STRING;
  }

  Type Analyze_OP1(ASTNode &node) {
    assert(node.NumChildren() == 1);

    Type type = Analyze(node.Child(0));
    std::string op = node.GetLexeme();

    switch (op[0]) {
    case '-':
      RequireNumeric(node, type, "Unary '-' operator requires numeric type");
      return type;
    case '!':
      RequireInt(node, type, "The '!' operator requires type int");
      return Type::INT;
    case '#':
      RequireString(node, type, "The '#' operator requires type string");
      return Type::INT;
    }

    return Type::UNKNOWN;
  }

  Type Analyze_OP2(ASTNode &node) {
    assert(node.NumChildren() == 2);

    std::string op = node.GetLexeme();
    Type type0 = Analyze(node.Child(0));
    Type type1 = Analyze(node.Child(1));

    if (op == "**") {
      RequireNumeric(node, type0, "The '**' operator requires numeric types");
      RequireNumeric(node, type1, "The '**' operator requires numeric types");
      return Type::DOUBLE;
    }

    if (op == "*") {
      if (IsNumeric(type0)) {
        RequireNumeric(node, type1, "RHS of multuple must be numeric");
        return std::min(type0, type1);
      } else {
        RequireInt(node, type1, "String can only be multiplied by ints");
        return Type::STRING;
      }
    }

    if (op == "/" || op == "-" || op == ":<" || op == ":>") {
      RequireNumeric(node, type0,
                     "Operator '" + op + "' must have numeric args");
      RequireNumeric(node, type1,
                     "Operator '" + op + "' must have numeric args");
      return std::min(type0, type1);
    } else if (op == "%") {
      RequireInt(node, type0, "Operator '" + op + "' must have in args");
      RequireInt(node, type1, "Operator '" + op + "' must have in args");
      return Type::INT;
    } else if (op == "+") {
      if (IsNumeric(type0)) {
        RequireNumeric(node, type1,
                       "Numbers can only be added to other numbers");
        return std::min(type0, type1);
      }
      if (type1 == Type::DOUBLE) {
        node.Error(
            "Cannot use plus operator ('+') to add a double onto a string.");
      }
      return Type::STRING;
    }

    else if (op == "&&" || op == "||") {
      RequireNumeric(node, type0,
                     "Operator '" + op + "' must have numeric args");
      RequireNumeric(node, type1,
                     "Operator '" + op + "' must have numeric args");
      return Type::INT;
    }

    else if (op == "==" || op == "!=" || op == "<" || op == "<=" || op == ">" ||
             op == ">=") {
      RequireNumeric(node, type0, "Comparisons must have numeric args");
      RequireNumeric(node, type1, "Comparisons must have numeric args");
      return Type::INT;
    } else if (op == "&&" || op == "||") {
      RequireNumeric(node, type0,
                     "Operator '" + op + "' must have numeric args");
      RequireNumeric(node, type1,
                     "Operator '" + op + "' must have numeric args");
      return Type::INT;
    }

    else if (op == "=") {
      if (!node.Child(0).CanAssign()) {
        node.Error("Left-hand-side of assignment must be a variable.");
      }

      if (type0 != type1 && (type0 == Type::STRING || type1 == Type::STRING)) {
        node.Error("Assignments operators must have matching types.");
      }

      return type0;
    }

    return Type::UNKNOWN;
  }

  Type Analyze_RETURN(ASTNode &node) {
    assert(node.NumChildren() == 1);

    if (fun_id == SymbolTable::NO_ID) {
      node.Error("Return command found outside of function.");
    }

    Type type = Analyze(node.Child(0));
    Type return_type = symbols.GetReturnType(fun_id);

    if (return_type == Type::DOUBLE && type == Type::INT)
      type = Type::DOUBLE; // Promote type if needed.

    if (type != return_type) {
      node.Error("Expected return type ", TypeToName(return_type),
                 " for function '", symbols.GetFunName(fun_id),
                 "', but received type ", TypeToName(type), ".");
    }

    return Type::NONE; // A return statement doesn't actually have a type.
  }

  Type Analyze_VAR(ASTNode &node) {
    assert(node.NumChildren() == 0);
    return node.GetType();
  }

  Type Analyze_WHILE(ASTNode &node) {
    assert(node.NumChildren() == 2);
    Type cond_type = Analyze(node.Child(0));
    RequireNumeric(node, cond_type,
                   "Type mismatch: While 'condition' must be numeric");
    ++while_depth;
    Analyze(node.Child(1));
    --while_depth;

    return Type::NONE;
  }
};
