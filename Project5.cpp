// -- Some header files that are likely to be useful --
#include <assert.h>
#include <fstream>
#include <iostream>
#include <string>
#include <unordered_map>
#include <vector>

#include "AST.hpp"
#include "Parser.hpp"
#include "Semantics.hpp"
#include "SymbolTable.hpp"
#include "Translate.hpp"
#include "lexer.hpp"

using emplex::Lexer;
using emplex::Token;

class Strix {
private:
  Lexer lexer;
  SymbolTable symbols;

public:
  Strix(std::string filename) {
    // Generate the token stream to work with.
    std::ifstream fs(filename);
    if (!fs) {
      std::cerr << "Failed to open file '" << filename << "'.  Exiting."
                << std::endl;
      exit(1);
    }
    lexer.Tokenize(fs);
  }

  // Create a Parse object and used to the convert the input token (in lexer)
  // into one or more functions (stored in the symbol table.)
  void Parse() {
    Parser parser{lexer, symbols};
    parser.Parse();
  }

  // Do a full semantic analysis of the inputs, as found in the symbol table.
  void AnalyzeSemantics() {
    Semantics analyzer{symbols};
    analyzer.Analyze();
  }

  // Convert the functions in the symbol table into WAT format.
  void ToWAT() {
    Translate translator{symbols};
    translator.ToWAT();
  }
};

int main(int argc, char *argv[]) {
  if (argc != 2) {
    std::cout << "Format: " << argv[0] << " [filename]" << std::endl;
    exit(1);
  }

  Strix prog(argv[1]);
  prog.Parse();
  prog.AnalyzeSemantics();
  prog.ToWAT();
}
