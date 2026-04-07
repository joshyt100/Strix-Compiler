# Strix Compiler

Strix is a C++ compiler for a custom language that translates source code into **WebAssembly Text (WAT)**.

## Features
- Lexer → tokenizes input
- Parser → builds an AST
- Semantic analysis → checks types & scope
- Code generation → outputs WAT
- Supports variables, functions, control flow (`if`, `while`), and built-in graphics/event functions


## How it Works
1. **Lexing**  
   The input file is read and converted into a stream of tokens.

2. **Parsing**  
   Tokens are structured into an **Abstract Syntax Tree (AST)** representing the program.

3. **Semantic Analysis**  
   The AST is validated for:
   - Type correctness  
   - Variable/function declarations  
   - Scope rules  

4. **Code Generation**  
   The validated AST is traversed and translated into **WebAssembly Text (WAT)**, including:
   - Function definitions  
   - Control flow (`if`, `while`)  
   - Memory and string utilities  
   - Calls to host-provided functions (graphics/events)

## Build & Run
```bash
make
./strix input.txt
