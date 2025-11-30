#pragma once

#include <string>
#include <unordered_map>

#include "AST.hpp"
#include "SymbolTable.hpp"
#include "lexer.hpp"

class Parser {
private:
  Lexer &lexer;
  SymbolTable &symbols;

  struct OpInfo {
    size_t prec;
    bool recurse_left;
    bool recurse_right;
  };

  std::unordered_map<std::string, OpInfo> op_map;
  size_t max_prec_level = 0;

  bool IsBuiltinFunction(const std::string &name) const {
    return name == "AddButton" || name == "AddKeypress" ||
           name == "AddClickFun" || name == "AddMoveFun" ||
           name == "AddAnimFun" || name == "SetTitle" || name == "LineColor" ||
           name == "FillColor" || name == "LineWidth" || name == "Line" ||
           name == "Rect" || name == "Circle" || name == "Text";
  }

  size_t GetBuiltinParamCount(const std::string &name) const {
    if (name == "AddButton")
      return 2;
    if (name == "AddKeypress")
      return 2;
    if (name == "AddClickFun")
      return 1;
    if (name == "AddMoveFun")
      return 1;
    if (name == "AddAnimFun")
      return 1;
    if (name == "SetTitle")
      return 1;
    if (name == "LineColor")
      return 1;
    if (name == "FillColor")
      return 1;
    if (name == "LineWidth")
      return 1;
    if (name == "Line")
      return 4;
    if (name == "Rect")
      return 4;
    if (name == "Circle")
      return 3;
    if (name == "Text")
      return 4;
    return 0;
  }

  [[nodiscard]] ASTNode MakeVarNode(Token var_token) const {
    size_t var_id = symbols.GetSymbolID(var_token);
    Type type = symbols.GetVarType(var_id);
    return ASTNode_Var(var_token, var_id, type);
  }

  [[nodiscard]] ASTNode Parse_Statement() {
    if (lexer.None())
      Error(lexer.Peek(), "Unexpected End-of-File");

    ASTNode out_node;

    // Look at the next token to determine the type of statement.
    int token_id = lexer.Peek();
    switch (token_id) {
    case Lexer::ID_BREAK:
      out_node = Parse_BREAK();
      break;
    case Lexer::ID_CONTINUE:
      out_node = Parse_CONTINUE();
      break;
    case Lexer::ID_TYPE:
      out_node = Parse_Declare();
      break;
    case Lexer::ID_RETURN:
      out_node = Parse_RETURN();
      break;

    // Statements that DON'T need a semi-colon at the end:
    case Lexer::ID_IF:
      return Parse_IF();
    case Lexer::ID_WHILE:
      return Parse_WHILE();
    case '{':
      return Parse_Block();

    case ';':
      break; // Empty line -- nothing to process.
    default:
      out_node = Parse_Expression();
    }

    lexer.Use(';');

    return out_node;
  }

  [[nodiscard]] ASTNode Parse_Block() {
    Token open_token = lexer.Use('{');
    symbols.IncScope();
    ASTNode block = ASTNode_Block(open_token);
    while (lexer.Peek() != '}') {
      ASTNode line = Parse_Statement();
      if (line.GetNodeType() != ASTType::UNKNOWN)
        block.AddChild(std::move(line));
    }
    lexer.Use('}', "Missing close brace (open on line ", open_token.line_id,
              ")");
    symbols.DecScope();

    return block;
  }

  [[nodiscard]] ASTNode Parse_Term() {
    Token token = lexer.Use();

    // Check for unary operators
    if (token == '!' || token == '-' || token == '#') {
      return ASTNode_Operator(token, Parse_Term());
    }

    ASTNode out_node;

    // Check for parentheses
    if (token == '(') {
      out_node = Parse_Expression();
      lexer.Use(')', "Missing parenthesis");
    }

    // Check if this is an ID.
    else if (token == Lexer::ID_ID) {
      // Test if the ID is a variable.
      if (symbols.HasVarSymbol(token.lexeme)) {
        out_node = MakeVarNode(token);
      }

      // Otherwise check if the ID is a function call.
      else if (symbols.HasFunSymbol(token.lexeme)) {
        size_t fun_id = symbols.GetFunID(token.lexeme);
        out_node = ASTNode_Call(token, fun_id);

        // Collect arguments...
        lexer.Use('(', "Call to function '", token.lexeme, "' must have '('.");
        size_t arg_count = symbols.GetFunParams(fun_id).size();
        for (size_t arg_id = 0; arg_id < arg_count; ++arg_id) {
          if (arg_id)
            lexer.Use(',');
          out_node.AddChild(Parse_Expression());
        }
        lexer.Use(')', "Missing closing ')' in call to function '",
                  token.lexeme, "'.");
      }

      // Otherwise check if this is a built-in function call.
      else if (IsBuiltinFunction(token.lexeme)) {
        out_node = ASTNode_Call(token, SymbolTable::NO_ID);

        lexer.Use('(', "Call to function '", token.lexeme, "' must have '('.");
        size_t arg_count = GetBuiltinParamCount(token.lexeme);
        for (size_t arg_id = 0; arg_id < arg_count; ++arg_id) {
          if (arg_id)
            lexer.Use(',');
          out_node.AddChild(Parse_Expression());
        }
        lexer.Use(')', "Missing closing ')' in call to function '",
                  token.lexeme, "'.");
      }
    }

    // == Check if this is a literal ==

    else if (token == Lexer::ID_LIT_DOUBLE) {
      out_node = ASTNode_LitDouble(token);
    } else if (token == Lexer::ID_LIT_INT) {
      out_node = ASTNode_LitInt(token);
    } else if (token == Lexer::ID_LIT_STRING) {
      std::string lit = token.lexeme.substr(1, token.lexeme.size() - 2);
      size_t pos_id = symbols.AddLiteral(lit);
      out_node = ASTNode_LitString(token, lit, pos_id);
    } else
      Error(token, "Unexpected token '", token.lexeme, "'");
    ;

    // See if we are indexing into this term.
    if (lexer.Peek() == '[') {
      Token index_token = lexer.Use('[');
      ASTNode index_expr = Parse_Expression();
      out_node = ASTNode_Index(index_token, std::move(out_node),
                               std::move(index_expr));
      lexer.Use(']');
    }

    return out_node;
  }

  ASTNode Parse_Expression(size_t prec_level = 1000, ASTNode lhs = ASTNode{}) {
    prec_level = std::min(prec_level, max_prec_level);

    if (prec_level == 0) {
      // If we aren't extending an existing LHS expression, get a term.
      if (lhs.GetNodeType() == ASTType::UNKNOWN)
        lhs = Parse_Term();
      return lhs;
    }

    // Fill out higher precedence for left-hand side (LHS)
    lhs = Parse_Expression(prec_level - 1, std::move(lhs));

    // If next token is an operator on THIS precedence level, act on it.
    auto it = op_map.find(lexer.Peek().lexeme);
    if (it != op_map.end() && it->second.prec == prec_level) {
      Token op_token = lexer.Use(); // Get the current operator.

      // Determine the right-hand-side of this operator.
      size_t right_prec =
          it->second.recurse_right ? prec_level : prec_level - 1;
      ASTNode rhs = Parse_Expression(right_prec);

      // Build the node
      lhs = ASTNode_Operator(op_token, std::move(lhs), std::move(rhs));

      // If left associative, look for additional ops to put higher in the tree.
      if (it->second.recurse_left)
        lhs = Parse_Expression(prec_level, std::move(lhs));
    }
    return lhs;
  }

  ASTNode Parse_BREAK() {
    Token break_token = lexer.Use(Lexer::ID_BREAK);
    return ASTNode_Break(break_token);
  }

  ASTNode Parse_CONTINUE() {
    Token cont_token = lexer.Use(Lexer::ID_CONTINUE);
    return ASTNode_Continue(cont_token);
  }

  ASTNode Parse_RETURN() {
    Token return_token = lexer.Use(Lexer::ID_RETURN);
    ASTNode return_node = Parse_Expression();
    return ASTNode_Return(return_token, std::move(return_node));
  }

  ASTNode Parse_IF() {
    Token if_token = lexer.Use(Lexer::ID_IF);
    lexer.Use('(');
    ASTNode condition = Parse_Expression();
    lexer.Use(')', "If condition must end with ')', but found \"",
              lexer.Peek().lexeme, "\".");
    ASTNode body = Parse_Statement();
    ASTNode out = ASTNode_If(if_token, std::move(condition), std::move(body));
    if (lexer.UseIf(Lexer::ID_ELSE)) {
      out.AddChild(Parse_Statement());
    }

    return out;
  }

  ASTNode Parse_WHILE() {
    Token while_token = lexer.Use(Lexer::ID_WHILE);
    lexer.Use('(');
    ASTNode condition = Parse_Expression();
    lexer.Use(')', "While condition must end with ')'");
    ASTNode body = Parse_Statement();
    return ASTNode_While(while_token, std::move(condition), std::move(body));
  }

  ASTNode Parse_Declare() {
    Token type_token = lexer.Use(Lexer::ID_TYPE);
    Token id_token = lexer.Use(Lexer::ID_ID);
    symbols.AddVarSymbol(id_token, type_token);
    Token assign_token = lexer.Use('=');

    ASTNode lhs = MakeVarNode(id_token);
    ASTNode rhs = Parse_Expression();

    return ASTNode_Operator(assign_token, std::move(lhs), std::move(rhs));
  }

  void Parse_Function() {
    lexer.Use(Lexer::ID_FUNCTION);
    Token name_token = lexer.Use(Lexer::ID_ID);
    size_t fun_id = symbols.AddFunction(name_token);

    // Figure out parameters:
    symbols.IncScope();
    std::vector<Token> param_names;
    lexer.Use('(');
    while (lexer.Peek() != ')') {
      Token type_id = lexer.Use(Lexer::ID_TYPE);
      Token param = lexer.Use(Lexer::ID_ID);
      param_names.push_back(param);
      if (lexer.Peek() != ')') {
        // Next token must end parameters or be a comma.
        lexer.Use(',',
                  "Function parameters must be separated by commans (',')");
      }
      symbols.AddVarSymbol(param, type_id, true);
    }

    lexer.Use(')');
    lexer.Use(':');
    Token return_type_token = lexer.Use(Lexer::ID_TYPE);
    symbols.AddFunctionReturn(return_type_token);
    symbols.AddFunctionBody(Parse_Block());
    symbols.DecScope();
    symbols.EndFunction(fun_id);
  }

public:
  Parser(Lexer &lexer, SymbolTable &symbols) : lexer(lexer), symbols(symbols) {
    // Set up all information about operators...
    OpInfo cur_info{++max_prec_level, false, true}; // RIGHT associative
    op_map["**"] = cur_info;
    cur_info = {++max_prec_level, true, false}; // LEFT associative
    op_map[":<"] = op_map[":>"] = cur_info;
    cur_info = {++max_prec_level, true, false}; // LEFT associative
    op_map["*"] = op_map["/"] = op_map["%"] = cur_info;
    cur_info = {++max_prec_level, true, false}; // LEFT associative
    op_map["+"] = op_map["-"] = cur_info;
    cur_info = {++max_prec_level, false, false}; // NON associative
    op_map["<"] = op_map[">"] = op_map["<="] = op_map[">="] = op_map["=="] =
        op_map["!="] = cur_info;
    cur_info = {++max_prec_level, false, true}; // RIGHT associative
    op_map["="] = cur_info;
  }

  void Parse() {
    // Parsing the token stream, one function at a time.
    while (lexer.Any())
      Parse_Function();
  }
};
