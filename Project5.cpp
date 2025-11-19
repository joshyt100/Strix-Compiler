// -- Some header files that are likely to be useful --
#include <assert.h>
#include <fstream>
#include <iostream>
#include <string>
#include <unordered_map>
#include <vector>

#include "AST.hpp"
#include "lexer.hpp"
#include "SymbolTable.hpp"

using emplex::Lexer;
using emplex::Token;

// A possible structure for the project...

class Strix {
private:
  const std::string filename;
  Lexer lexer;

  SymbolTable symbols;

  using ast_node_t = std::unique_ptr<ASTNode>;
  struct OpInfo {
    size_t prec;
    bool recurse_left;
    bool recurse_right;
  };

  std::unordered_map<std::string, OpInfo> op_map;
  size_t max_prec_level = 0;

  // === Helper Functions ===

  // Easy way to throw an Unexpected Token error
  void UnexpectedToken(Token token) {
    Error(token, "Unexpected token '", token.lexeme, "'");
  }

  ast_node_t MakeVarNode(Token var_token) {
    size_t var_id = symbols.GetSymbolID(var_token);
    return nullptr; // std::make_unique<ASTNode_Var>(var_id);
  }

  // For unary ops
  ast_node_t MakeOpNode(Token op_token, ast_node_t child) {
    return nullptr; // std::make_unique<ASTNode_Operator1>(op_token, std::move(child));
  }

  // For binary ops
  ast_node_t MakeOpNode(Token op_token, ast_node_t child1, ast_node_t child2) {
    return nullptr; // std::make_unique<ASTNode_Operator2>(op_token, std::move(child1), std::move(child2));
  }

  OpInfo GetOpInfo(Token token) {
    auto it = op_map.find(token.lexeme);
    if (it == op_map.end()) return {max_prec_level+1, false, false};
    return it->second;
  }


  // == PARSING FUNCTIONS ==

  ast_node_t Parse_Statement() {
    if (lexer.None()) Error(lexer.Peek(), "Unexpected End-of-File");

    ast_node_t out_node = nullptr;

    // TO DO: PARSE THE FILE!

    return out_node;
  }

  ast_node_t Parse_Block() {
    Token open_token = lexer.Use('{');
    symbols.IncScope();
    ast_node_t block = std::make_unique<ASTNode>();
    while (lexer.Peek() != '}') {
      ast_node_t line = Parse_Statement();
      if (line) block->AddChild( std::move(line) );
    }
    lexer.Use('}', "Missing close brace (open on line ", open_token.line_id, ")");
    symbols.DecScope();

    return block;
  }


  void Parse_Function() {
    lexer.Use(Lexer::ID_FUNCTION);
    Token fun_name = lexer.Use(Lexer::ID_ID);
    symbols.AddFunction(fun_name.lexeme);

    // TODO: Finish this function!!
  }

public:
  Strix(std::string filename) : filename(filename) {
    // Set up info about operators...
    OpInfo cur_info{ ++max_prec_level, false,  true };  // RIGHT associative
    op_map["**"] = cur_info;
    cur_info = { ++max_prec_level, true,  false };  // LEFT associative
    op_map["+"] = op_map["-"] = cur_info;
    
    // TODO: Add in other operators are the correct levels and with correct prec / assoc!!
  }

  void Parse() {
    // Generate the token stream to work with.
    std::ifstream fs(filename);
    lexer.Tokenize(fs);

    // Start parsing the token stream.
    while (lexer.Any()) {
      Parse_Function();
    }
  }

  // Convert the file to WAT format.
  void ToWAT() {
    std::cout
      << "(module\n"
      << "  (import \"Math\" \"pow\" (func $pow (param f64 f64) (result f64)))\n";

    // TODO: Generate CODE and EXPORT the functions!

    std::cout << ") ;; End module\n";
  }
};

int main(int argc, char * argv[])
{
  if (argc != 2) {
    std::cout << "Format: " << argv[0] << " [filename]" << std::endl;
    exit(1);
  }

  Strix prog(argv[1]);
  prog.Parse();
  prog.ToWAT();
}
