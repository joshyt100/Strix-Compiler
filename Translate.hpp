#pragma once

// Visitor pattern for moving though an AST and translating all nodes to WAT

#include <string>

#include "AST.hpp"
#include "SymbolTable.hpp"
#include "lexer.hpp"

class Translate {
private:
  SymbolTable &symbols; // Reference to symbol table
  int indent = 0;       // How much should WAT output be indented?
  size_t fun_id =
      SymbolTable::NO_ID;        // Which function are we currently translating?
  size_t next_while_id = 1;      // Unique ID for next while loop.
  std::vector<size_t> while_ids; // Which while loops are we currently in?

  // == HELPER FUNCTIONS ==

  template <typename... Ts> void AddCode(Ts &&...message) const {
    std::cout << std::string(indent, ' ');
    (std::cout << ... << std::forward<Ts>(message)) << std::endl;
  }

  // Select code to add based on the type specified.
  void SelectCode(Type type, std::string double_code, std::string int_code,
                  std::string str_code) {
    switch (type) {
    case Type::DOUBLE:
      AddCode(double_code);
      break;
    case Type::INT:
      AddCode(int_code);
      break;
    case Type::STRING:
      AddCode(str_code);
      break;
    default:
      std::cerr << "Internal ERROR: No type provided for code selection."
                << std::endl;
      exit(1);
    }
  }

  // Add code to convert between the specified types.
  void AddConvert(Type from_type, Type to_type) const {
    assert(from_type != Type::NONE && to_type != Type::NONE);
    assert(from_type != Type::UNKNOWN && to_type != Type::UNKNOWN);
    if (from_type == to_type)
      return; // No change needed!

    if (from_type == Type::DOUBLE && to_type == Type::INT) {
      AddCode("(i32.trunc_f64_s)  ;; Convert from f64 to i32.");
    } else if (from_type == Type::INT && to_type == Type::DOUBLE) {
      AddCode("(f64.convert_i32_s)  ;; Convert from f32 to i64.");
    }

    else {
      std::cerr << "Unexpected conversion from '" << TypeToName(from_type)
                << "' to '" << TypeToName(to_type) << "'." << std::endl;
      exit(2);
    }
  }

  // == Info about WHILE loops being generated ==

  // Are we currently generating any while loops?
  bool InWhile() const { return while_ids.size() > 0; }

  // What is the ID of the inner-most while loop we are generating?
  size_t GetWhileID() const {
    assert(InWhile());
    return while_ids.back();
  }

  // Start generating a new while loop (return unique ID for this loop)
  size_t AddWhile() {
    while_ids.push_back(next_while_id++);
    return GetWhileID();
  }

  // Finish the inner-most while loop being generated.
  size_t ExitWhile() {
    assert(InWhile());
    size_t out_id = while_ids.back();
    while_ids.pop_back();
    return out_id;
  }

  // WAT HELPER FUNCTIONS
  void PrintWATHelpers() {
    std::cout
        << "  ;; Function to swap the top two i32s on the stack.\n"
        << "  (func $_swap32 (param $val1 i32) (param $val2 i32) (result i32) "
           "(result i32)\n"
        << "    (local.get $val2)\n"
        << "    (local.get $val1)\n"
        << "  )\n"
        << "\n"
        << "  ;; Function to allocate a string; add one to size and place null "
           "there.\n"
        << "  ;; Returns the memory position of the new string.\n"
        << "  (func $_alloc_str (param $size i32) (result i32)\n"
        << "    (local $null_pos i32) ;; Local variable to place null "
           "terminator.\n"
        << "    (global.get $free_mem)                            ;; Old free "
           "mem is alloc start.\n"
        << "    (global.get $free_mem)                            ;; Adjust "
           "new free mem.\n"
        << "    (local.get $size)\n"
        << "    (i32.add)\n"
        << "    (local.set $null_pos)\n"
        << "    (i32.store8 (local.get $null_pos) (i32.const 0))  ;; Place "
           "null terminator.\n"
        << "    (i32.add (i32.const 1) (local.get $null_pos))\n"
        << "    (global.set $free_mem)                            ;; Update "
           "free memory start.\n"
        << "  )\n"
        << "\n"
        << "  ;; Convert a char to a string.\n"
        << "  ;; Return a pointer to the new string.\n"
        << "  (func $_char2str (param $char i32) (result i32)\n"
        << "    (local $ptr i32)                                  ;; Allocated "
           "pointer\n"
        << "    (call $_alloc_str (i32.const 1))                  ;; Allocate "
           "a string with one char.\n"
        << "    (local.set $ptr)                                  ;; save the "
           "allocated position.\n"
        << "    (i32.store8 (local.get $ptr) (local.get $char))   ;; Store the "
           "char.\n"
        << "    (local.get $ptr)                                  ;; return "
           "the allocated position.\n"
        << "  )\n"
        << "\n"
        << "  ;; Function to copy memory.  Args: [source] [destination] "
           "[size]\n"
        << "  ;; No return value.\n"
        << "  (func $_mem_copy (param $src i32) (param $dest i32) (param $size "
           "i32)\n"
        << "    (loop $_mem_copy_loop\n"
        << "      (if (i32.eqz (local.get $size)) (then (return)))\n"
        << "\n"
        << "      (local.get $dest)               ;; Specify location to place "
           "byte\n"
        << "      (i32.load8_u (local.get $src))  ;; Load byte from source\n"
        << "      (i32.store8)                    ;; Store byte\n"
        << "\n"
        << "      (local.set $src  (i32.add (local.get $src)  (i32.const 1))) "
           ";; source++\n"
        << "      (local.set $dest (i32.add (local.get $dest) (i32.const 1))) "
           ";; destination++\n"
        << "      (local.set $size (i32.sub (local.get $size) (i32.const 1))) "
           ";; size--;\n"
        << "\n"
        << "      (br $_mem_copy_loop) ;; Go back to the start of the loop!\n"
        << "    )\n"
        << "  )\n"
        << "\n"
        << "  ;; Function to calculate the length of a string and return it "
           "(as i32).\n"
        << "  (func $_strlen (param $ptr i32) (result i32)\n"
        << "    (local $len i32) ;; Local variable to keep track of the "
           "length\n"
        << "    (local.set $len (i32.const 0)) ;; Initialize the length to 0\n"
        << "\n"
        << "    ;; Loop through memory until the null terminator is found\n"
        << "    (loop $strlen_loop\n"
        << "      (i32.load8_u (local.get $ptr)) ;; Load byte at current "
           "pointer\n"
        << "      (if (i32.eqz)                       ;; Test if null.\n"
        << "        (then (local.get $len) (return))  ;; ...if so, return\n"
        << "      )\n"
        << "\n"
        << "      ;; Increment pointer and length\n"
        << "      (local.set $ptr (i32.add (local.get $ptr) (i32.const 1))) ;; "
           "ptr++\n"
        << "      (local.set $len (i32.add (local.get $len) (i32.const 1))) ;; "
           "len++\n"
        << "\n"
        << "      (br $strlen_loop) ;; Keep going...\n"
        << "    )\n"
        << "    (local.get $len) ;; Return length\n"
        << "  )\n"
        << "\n"
        << "  ;; Function to create make a series of copies of a string.\n"
        << "  ;; $ptr is a pointer to the string to be duplicated.\n"
        << "  ;; $dups is the number of copies to make.\n"
        << "  ;; Returns the memory position of the duplate chain.\n"
        << "  (func $_str_duplicate (param $ptr i32) (param $dups i32) (result "
           "i32)\n"
        << "    (local $str_len i32)      ;; Length of the input string\n"
        << "    (local $new_ptr i32)      ;; Pointer to the newly allocated "
           "memory\n"
        << "    (local $dest i32)         ;; Pointer for writing to the new "
           "string\n"
        << "    (local $i i32)            ;; Loop counter\n"
        << "\n"
        << "    ;; Step 1: Get the length of the input string\n"
        << "    (local.get $ptr)\n"
        << "    (call $_strlen)\n"
        << "    (local.set $str_len)\n"
        << "\n"
        << "    ;; Step 2: Compute the total length of the new string and "
           "allocate it.\n"
        << "    (i32.mul (local.get $str_len) (local.get $dups))\n"
        << "    (call $_alloc_str)\n"
        << "    (local.set $new_ptr)  ;; Store the pointer to the allocated "
           "memory\n"
        << "\n"
        << "    ;; Step 3: Initialize destination pointer\n"
        << "    (local.set $dest (local.get $new_ptr))\n"
        << "\n"
        << "    ;; Step 4: Copy the input string `dups` times into the new "
           "memory\n"
        << "    (local.set $i (i32.const 0)) ;; Initialize loop counter\n"
        << "    (block $copy_block\n"
        << "      (loop $copy_loop\n"
        << "        ;; Check if $i >= $dups\n"
        << "        (i32.ge_u (local.get $i) (local.get $dups))\n"
        << "        (br_if $copy_block) ;; Exit loop if done\n"
        << "\n"
        << "        ;; Copy the input string to the current destination\n"
        << "        (call $_mem_copy (local.get $ptr) (local.get $dest) "
           "(local.get $str_len))\n"
        << "\n"
        << "        ;; Update the destination pointer\n"
        << "        (i32.add (local.get $dest) (local.get $str_len))\n"
        << "        (local.set $dest)\n"
        << "\n"
        << "        ;; Increment loop counter\n"
        << "        (i32.add (local.get $i) (i32.const 1))\n"
        << "        (local.set $i)\n"
        << "\n"
        << "        ;; Repeat the loop\n"
        << "        (br $copy_loop)\n"
        << "      ) ;; end of $copy_loop\n"
        << "    ) ;; end of $copy_block\n"
        << "\n"
        << "    (local.get $new_ptr) ;; Return pointer to new string.\n"
        << "  )\n"
        << "\n"
        << "  ;; Function to concatenate two strings\n"
        << "  ;; $ptr1 and $ptr2 are the pointers to the two strings to "
           "concatenate.\n"
        << "  ;; Returns a pointer to the new, combined string.\n"
        << "  (func $_str_concat (param $ptr1 i32) (param $ptr2 i32) (result "
           "i32)\n"
        << "    (local $len1 i32)      ;; Length of the first string\n"
        << "    (local $len2 i32)      ;; Length of the second string\n"
        << "    (local $new_ptr i32)   ;; Pointer to the newly allocated "
           "string\n"
        << "\n"
        << "    ;; Step 1: Get the lengths of the two strings\n"
        << "    (local.get $ptr1)\n"
        << "    (call $_strlen)\n"
        << "    (local.set $len1)\n"
        << "\n"
        << "    (local.get $ptr2)\n"
        << "    (call $_strlen)\n"
        << "    (local.set $len2)\n"
        << "\n"
        << "    ;; Step 2: Compute the total length of the new string and "
           "allocate memory\n"
        << "    (i32.add (local.get $len1) (local.get $len2))\n"
        << "    (call $_alloc_str)\n"
        << "    (local.set $new_ptr)       ;; Store the pointer to the "
           "allocated memory\n"
        << "\n"
        << "    ;; Step 3: Copy the first string to the new memory\n"
        << "    (local.get $ptr1)\n"
        << "    (local.get $new_ptr)\n"
        << "    (local.get $len1)\n"
        << "    (call $_mem_copy)\n"
        << "\n"
        << "    ;; Step 4: Copy the second string to the new memory (after the "
           "first string)\n"
        << "    (local.get $ptr2)\n"
        << "    (i32.add (local.get $new_ptr) (local.get $len1))\n"
        << "    (local.get $len2)\n"
        << "    (call $_mem_copy)\n"
        << "\n"
        << "    ;; Step 5: Return the pointer to the new string\n"
        << "    (local.get $new_ptr)\n"
        << "  )\n"
        << "\n"
        << "  ;; Function to make a copy of a string and return its pointer.\n"
        << "  (func $_str_copy (param $str i32) (result i32)\n"
        << "    (local $size i32)                    ;; Var: Length of string "
           "to copy.\n"
        << "    (local $new_ptr i32)                 ;; Var: Location of new "
           "string.\n"
        << "    (call $_strlen (local.get $str))     ;; Calculate length of "
           "the string to copy.\n"
        << "    (local.set $size)                    ;; Save the string "
           "length.\n"
        << "    (call $_alloc_str (local.get $size)) ;; Allocate space for the "
           "new string.\n"
        << "    (local.set $new_ptr)                 ;; Save pointer to new "
           "string.\n"
        << "    ;; copy memory into the new string...\n"
        << "    (call $_mem_copy (local.get $str) (local.get $new_ptr) "
           "(local.get $size))\n"
        << "    (local.get $new_ptr)                 ;; Return the pointer to "
           "the new string.\n"
        << "  )\n"
        << "\n";
  }

public:
  Translate(SymbolTable &symbols) : symbols(symbols) {}

  // Translate all functions into WebAssembly Text (WAT) output
  void ToWAT() {

    std::cout << "(module\n"
              << "  (import \"Math\" \"pow\" (func $pow (param f64 f64) "
                 "(result f64)))\n"
              // New project 5 imports
              << "  (import \"host\" \"addButton\"     (func $addButton  "
                 "(param i32 i32)))\n"
              << "  (import \"host\" \"addKeyTrigger\" (func $addKeyTrigger "
                 "(param i32 i32)))\n"
              << "  (import \"host\" \"addClickFun\"   (func $addClickFun "
                 "(param i32)))\n"
              << "  (import \"host\" \"addMoveFun\"    (func $addMoveFun  "
                 "(param i32)))\n"
              << "  (import \"host\" \"addAnimFun\"    (func $addAnimFun "
                 "(param i32)))\n"
              << "  (import \"host\" \"setTitle\"       (func $setTitle       "
                 "(param i32)))\n"
              << "  (import \"host\" \"setStrokeColor\" (func $setStrokeColor "
                 "(param i32)))\n"
              << "  (import \"host\" \"setFillColor\"   (func $setFillColor   "
                 "(param i32)))\n"
              << "  (import \"host\" \"setLineWidth\"   (func $setLineWidth   "
                 "(param i32)))\n"
              << "  (import \"host\" \"drawLine\"       (func $drawLine   "
                 "(param i32 i32 i32 i32)))\n"
              << "  (import \"host\" \"drawRect\"       (func $drawRect   "
                 "(param i32 i32 i32 i32)))\n"
              << "  (import \"host\" \"drawCircle\"     (func $drawCircle "
                 "(param i32 i32 i32)))\n"
              << "  (import \"host\" \"drawText\"       (func $drawText   "
                 "(param i32 i32 i32 i32)))\n";

    symbols.PrintWATMemory();

    const auto &globals = symbols.GetGlobalVars();
    for (auto var_id : globals) {
      Type type = symbols.GetVarType(var_id);
      std::string wat_type = symbols.GetWATType(var_id);
      std::cout << "  (global $var" << var_id << " (mut " << wat_type << ") ";
      if (type == Type::DOUBLE) {
        double value =
            symbols.HasInit(var_id) ? symbols.GetGlobalInitDouble(var_id) : 0.0;
        std::cout << "(f64.const " << value << ")";
      } else {
        int value =
            symbols.HasInit(var_id) ? symbols.GetGlobalInitInt(var_id) : 0;
        std::cout << "(i32.const " << value << ")";
      }
      std::cout << ")\n";
    }

    PrintWATHelpers(); // Print all of the helper functions for dealing with
                       // strings.

    std::cout << "  (func $Init\n";
    indent = 4;
    for (auto &init_node : symbols.GetGlobalInits()) {
      ToWAT(init_node, false);
    }
    indent = 0;
    std::cout << "  )\n";
    std::cout << "  (start $Init)\n";

    for (fun_id = 0; fun_id < symbols.GetNumFuns(); ++fun_id) {
      std::cout << "  (func $Fun" << fun_id;

      // Declare PARAMETERS
      auto params = symbols.GetFunParams(fun_id);
      for (auto var_id : params) {
        std::cout << " (param $var" << var_id << " "
                  << ToWATType(symbols.GetVarType(var_id)) << ")";
      }
      std::cout << " (result " << ToWATType(symbols.GetReturnType(fun_id))
                << ")\n";

      indent = 4;

      // Declare LOCAL variables
      auto locals = symbols.GetFunLocals(fun_id);
      for (auto var_id : locals) {
        std::string wat_type_local = symbols.GetWATType(var_id);
        AddCode("(local $var", var_id, " ", wat_type_local,
                ") ;; Declare var '", symbols.GetVarName(var_id), "'");
      }

      // Generate BODY
      ToWAT(symbols.GetFunBody(fun_id), false);
      indent = 0;

      // CLOSE function
      std::cout << "  )\n";
    }

    // EXPORT Functions
    std::cout << "\n";
    for (size_t fun_id = 0; fun_id < symbols.GetNumFuns(); ++fun_id) {
      std::cout << "  (export \"" << symbols.GetFunName(fun_id)
                << "\" (func $Fun" << fun_id << "))\n";
    }
    std::cout << "  (export \"free_mem\" (global $free_mem))\n";

    std::cout << ") ;; End module\n";
  }

  void ToWAT(ASTNode &node, bool need_result, int indent_shift = 0) {
    indent += indent_shift;

    switch (node.GetNodeType()) {
    case ASTType::BLOCK:
      ToWAT_Block(node, need_result);
      break;
    case ASTType::BREAK:
      ToWAT_Break(node, need_result);
      break;
    case ASTType::CALL:
      ToWAT_Call(node, need_result);
      break;
    case ASTType::CONTINUE:
      ToWAT_Continue(node, need_result);
      break;
    case ASTType::IF:
      ToWAT_If(node, need_result);
      break;
    case ASTType::INDEX:
      ToWAT_Index(node, need_result);
      break;
    case ASTType::LIT_DOUBLE:
      ToWAT_LitDouble(node, need_result);
      break;
    case ASTType::LIT_INT:
      ToWAT_LitInt(node, need_result);
      break;
    case ASTType::LIT_STRING:
      ToWAT_LitString(node, need_result);
      break;
    case ASTType::OP1:
      ToWAT_Operator1(node, need_result);
      break;
    case ASTType::OP2:
      ToWAT_Operator2(node, need_result);
      break;
    case ASTType::RETURN:
      ToWAT_Return(node, need_result);
      break;
    case ASTType::VAR:
      ToWAT_Var(node, need_result);
      break;
    case ASTType::WHILE:
      ToWAT_While(node, need_result);
      break;
    default:
      std::cerr << "Internal Compiler Error: Unknown AST Node '"
                << TypeToName(node.GetNodeType()) << "'." << std::endl;
      exit(2);
    }

    indent -= indent_shift;
  }

  void ChildrenToWAT(ASTNode &node, bool need_result) {
    // Translate all children.
    for (size_t i = 0; i < node.NumChildren(); ++i) {
      ToWAT(node.Child(i), need_result);
    }
  }

  void ToWAT_Block(ASTNode &node, [[maybe_unused]] bool need_result) {
    assert(need_result == false);
    ChildrenToWAT(node, false);
  }

  void ToWAT_Break([[maybe_unused]] ASTNode &node,
                   [[maybe_unused]] bool need_result) {
    assert(need_result == false);
    size_t while_id = GetWhileID();
    std::string block_name = "$exit" + std::to_string(while_id);

    AddCode("(br ", block_name, ") ;; / BREAK out of while ", while_id);
  }

  void ToWAT_Call(ASTNode &node, bool need_result) {
    ChildrenToWAT(node, true);

    std::string fun_name = node.GetLexeme();

    std::string wat_label;
    bool is_builtin = false;

    if (fun_name == "AddButton") {
      wat_label = "$addButton";
      is_builtin = true;
    } else if (fun_name == "AddKeypress") {
      wat_label = "$addKeyTrigger";
      is_builtin = true;
    } else if (fun_name == "AddClickFun") {
      wat_label = "$addClickFun";
      is_builtin = true;
    } else if (fun_name == "AddMoveFun") {
      wat_label = "$addMoveFun";
      is_builtin = true;
    } else if (fun_name == "AddAnimFun") {
      wat_label = "$addAnimFun";
      is_builtin = true;
    } else if (fun_name == "SetTitle") {
      wat_label = "$setTitle";
      is_builtin = true;
    } else if (fun_name == "LineColor") {
      wat_label = "$setStrokeColor";
      is_builtin = true;
    } else if (fun_name == "FillColor") {
      wat_label = "$setFillColor";
      is_builtin = true;
    } else if (fun_name == "LineWidth") {
      wat_label = "$setLineWidth";
      is_builtin = true;
    } else if (fun_name == "Line") {
      wat_label = "$drawLine";
      is_builtin = true;
    } else if (fun_name == "Rect") {
      wat_label = "$drawRect";
      is_builtin = true;
    } else if (fun_name == "Circle") {
      wat_label = "$drawCircle";
      is_builtin = true;
    } else if (fun_name == "Text") {
      wat_label = "$drawText";
      is_builtin = true;
    }

    if (!is_builtin) {
      const FunInfo &fun_info = symbols.GetFunInfo(node.GetSymbolID());
      wat_label = "$Fun" + std::to_string(fun_info.fun_id);
      AddCode("(call ", wat_label, ")  ;; Call function ", fun_name);
      if (!need_result && fun_info.return_type != Type::NONE)
        AddCode("(drop) ;; Result not used.");
    } else {
      AddCode("(call ", wat_label, ")  ;; Call function ", fun_name);
    }
  }

  void ToWAT_Continue([[maybe_unused]] ASTNode &node,
                      [[maybe_unused]] bool need_result) {
    assert(need_result == false);
    const size_t while_id = GetWhileID();
    std::string loop_name = "$loop" + std::to_string(while_id);

    AddCode("(br ", loop_name, ") ;; CONTINUE while ", while_id);
  }

  void ToWAT_If(ASTNode &node, [[maybe_unused]] bool need_result) {
    assert(need_result == false);
    AddCode(";; == If Condition ==");
    ToWAT(node.Child(0), true); // Generate condition code

    // If the condition is a double, convert it to an int.
    AddConvert(node.Child(0).GetType(), Type::INT); // Make sure we have an int.
    AddCode("(if ;; Execute code based on result of condition.");
    AddCode("  (then ;; 'then' block");
    ToWAT(node.Child(1), false, 4);
    AddCode("  ) ;; End 'then'");

    if (node.NumChildren() == 3) {
      AddCode("  (else ;; 'else' block");
      ToWAT(node.Child(2), false, 4);
      AddCode("  ) ;; End 'else'");
    }

    AddCode(") ;; End 'if'");
  }

  void ToWAT_Index(ASTNode &node, bool need_result) {

    ToWAT(node.Child(0), true); // Generate code for string to index into.
    ToWAT(node.Child(1), true); // Generate code for index value.

    AddCode("(i32.add)      ;; Sum pointer and index to get index memory "
            "position.");
    AddCode("(i32.load8_u)  ;; Extract value at index.");

    if (!need_result)
      AddCode("(drop) ;; Result not used.");
  }

  void ToWAT_LitDouble(ASTNode &node, bool need_result) {
    if (need_result) {
      const double value = std::stod(node.GetLexeme());
      AddCode("(f64.const ", value, ")  ;; Literal value");
    }
  }

  void ToWAT_LitInt(ASTNode &node, bool need_result) {
    if (!need_result)
      return;

    std::string lex = node.GetLexeme();

    if (lex.size() == 3 && lex.front() == '\'' && lex.back() == '\'') {
      unsigned char ch = static_cast<unsigned char>(lex[1]);
      AddCode("(i32.const ", static_cast<int>(ch), ")  ;; Char literal ", lex,
              " → ASCII ", static_cast<int>(ch));
    } else {
      AddCode("(i32.const ", lex, ")  ;; Literal value");
    }
  }

  void ToWAT_LitString(ASTNode &node, bool need_result) {
    if (need_result) {
      AddCode("(i32.const ", node.GetSymbolID(), ")  ;; Literal string ",
              node.GetLexeme());
    }
  }

  void ToWAT_Operator1(ASTNode &node, bool need_result) {

    ToWAT(node.Child(0), true); // Generate code for value to modify.

    std::string op = node.GetLexeme();

    if (op == "!") {
      AddCode("(i32.eqz)  ;; Do operator '!'");
    } else if (op == "-") {
      if (node.Child(0).GetType() == Type::DOUBLE)
        AddCode("(f64.neg)  ;; Operator negate ('-')");
      else {
        AddCode("(i32.const -1)  ;; Setup negation.");
        AddCode("(i32.mul)       ;; Perform unary minus ('-')");
      }
    } else if (op == "#") {
      AddCode("(call $_strlen)  ;; Get size of string.");
    }

    if (!need_result)
      AddCode("(drop) ;; Result not used.");
  }
  void ToWAT_Operator2(ASTNode &node, bool need_result) {

    std::string op = node.GetLexeme();

    Type type0 = node.Child(0).GetType();
    Type type1 = node.Child(1).GetType();

    // If we are doing an assignment, we need to handle it specially.
    if (op == "=") {
      AddCode(";; Calculate RHS for assignment.");
      ToWAT(node.Child(1), true); // Generate code for rhs value.
      AssignWAT(node.Child(0));
      if (need_result)
        ToWAT(node.Child(0), true); // Put assigned value on stack.
      return;
    }

    // Short-circuiting logical AND
    if (op == "&&") {
      ToWAT(node.Child(0), true);
      AddConvert(type0, Type::INT);

      AddCode("(if (result i32)");
      AddCode("  (then");
      ToWAT(node.Child(1), true);
      AddConvert(type1, Type::INT);
      AddCode("    (i32.eqz)");
      AddCode("    (i32.eqz)");
      AddCode("  )");
      AddCode("  (else");
      AddCode("    (i32.const 0)");
      AddCode("  )");
      AddCode(")");

      if (!need_result)
        AddCode("(drop) ;; Result not used.");
      return;
    }

    // Short-circuiting logical OR
    if (op == "||") {
      ToWAT(node.Child(0), true);
      AddConvert(type0, Type::INT);

      AddCode("(if (result i32)");
      AddCode("  (then");
      AddCode("    (i32.const 1)");
      AddCode("  )");
      AddCode("  (else");
      ToWAT(node.Child(1), true);
      AddConvert(type1, Type::INT);
      AddCode("    (i32.eqz)");
      AddCode("    (i32.eqz)");
      AddCode("  )");
      AddCode(")");

      if (!need_result)
        AddCode("(drop) ;; Result not used.");
      return;
    }

    // We are working with an operator that needs two arguments; generate both.
    ToWAT(node.Child(0), true);
    // Promote arg0 from INT to DOUBLE if needed.
    if (type1 == Type::DOUBLE || op == "**" || op == ":<" || op == ":>") {
      AddConvert(type0, Type::DOUBLE);
      type0 = Type::DOUBLE;
    }

    ToWAT(node.Child(1), true);
    // Promote arg from INT to DOUBLE if needed.
    if (type0 == Type::DOUBLE || op == "**" || op == ":<" || op == ":>") {
      AddConvert(type1, Type::DOUBLE);
      type1 = Type::DOUBLE;
    }

    // Only one type allowed...
    if (op == "**")
      AddCode("(call $pow)");
    else if (op == ":<")
      AddCode("(f64.min)");
    else if (op == ":>")
      AddCode("(f64.max)");
    else if (op == "%")
      AddCode("(i32.rem_s)");

    else if (op == "*")
      SelectCode(type0, "(f64.mul)", "(i32.mul)", "(call $_str_duplicate)");
    else if (op == "/")
      SelectCode(type0, "(f64.div)", "(i32.div_s)", "");
    else if (op == "-")
      SelectCode(type0, "(f64.sub)", "(i32.sub)", "");
    else if (op == "==")
      SelectCode(type0, "(f64.eq)", "(i32.eq)", "");
    else if (op == "!=")
      SelectCode(type0, "(f64.ne)", "(i32.ne)", "");
    else if (op == "<")
      SelectCode(type0, "(f64.lt)", "(i32.lt_s)", "");
    else if (op == "<=")
      SelectCode(type0, "(f64.le)", "(i32.le_s)", "");
    else if (op == ">")
      SelectCode(type0, "(f64.gt)", "(i32.gt_s)", "");
    else if (op == ">=")
      SelectCode(type0, "(f64.ge)", "(i32.ge_s)", "");

    else if (op == "+") {
      if (type0 == Type::STRING && type1 == Type::INT) {
        AddCode("(call $_char2str)"); // Convert the +int to a one char string.
      }
      SelectCode(type0, "(f64.add)", "(i32.add)", "(call $_str_concat)");
    }

    else {
      node.Error("Internal compiler error; unknown op '", op, "'");
    }

    if (!need_result)
      AddCode("(drop) ;; Result not used.");
  }

  void ToWAT_Return(ASTNode &node, [[maybe_unused]] bool need_result) {
    assert(need_result == false);
    AddCode(";; == Generate return code ==");
    ToWAT(node.Child(0), true); // Generate code for return value

    // If we need to convert to the correct return type, do so.
    AddConvert(node.Child(0).GetType(), symbols.GetReturnType(fun_id));

    AddCode("(return)");
  }

  void ToWAT_Var(ASTNode &node, bool need_result) {
    if (need_result) {
      size_t var_id = node.GetSymbolID();
      if (symbols.IsGlobal(var_id)) {
        AddCode("(global.get $var", var_id, ")");
      } else {
        AddCode("(local.get $var", var_id, ")  ;; Variable '",
                symbols.GetVarName(var_id), "'");
      }
    }
  }

  void ToWAT_While(ASTNode &node, [[maybe_unused]] bool need_result) {
    assert(need_result == false);
    std::string while_id = std::to_string(AddWhile());
    std::string block_name = "$exit" + while_id;
    std::string loop_name = "$loop" + while_id;

    AddCode("(block ", block_name, " ;; Outer block for breaking while loop.");
    AddCode("  (loop ", loop_name, " ;; Inner loop for continuing while.");

    indent += 4;
    AddCode(";; == WHILE ", while_id, " CONDITION ==");
    ToWAT(node.Child(0), true);                     // Generate condition code
    AddConvert(node.Child(0).GetType(), Type::INT); // Convert result to int.
    AddCode(";; == END WHILE ", while_id, " CONDITION ==");
    AddCode("(i32.eqz)       ;; Invert the result of the test condition.");
    AddCode("(br_if ", block_name,
            ") ;; If condition was false (0), exit the loop");

    AddCode(";; == WHILE ", while_id, " BODY ==");
    ToWAT(node.Child(1), false); // Generate while body
    AddCode(";; == END WHILE ", while_id, " BODY ==");

    AddCode("(br ", loop_name, ") ;; Branch back to the start of the loop");

    indent -= 4;
    AddCode("  ) ;; End loop");
    AddCode(") ;; End block\n");

    ExitWhile();
  }

  //  === Generate code to perform an ASSIGNMENT (assuming value to assign is on
  //  stack) ===

  void AssignWAT(ASTNode &node) {
    ASTType type = node.GetNodeType();
    if (type == ASTType::INDEX)
      AssignWAT_Index(node);
    else if (type == ASTType::VAR)
      AssignWAT_Var(node);
    else {
      std::cerr << "Internal Compiler Error: Cannot assign to AST Node '"
                << TypeToName(type) << "'." << std::endl;
      exit(2);
    }
  }

  void AssignWAT_Index(ASTNode &node) {
    ToWAT(node.Child(0), true); // Generate code for string to index into.
    ToWAT(node.Child(1), true); // Generate code for index value.
    AddCode("(i32.add)        ;; Sum pointer and index to get index memory "
            "position.");
    AddCode("(call $_swap32)  ;; Put the store args in the correct order.");
    AddCode("(i32.store8)     ;; Store the value at index.");
  }

  void AssignWAT_Var(ASTNode &node) {
    size_t var_id = node.GetSymbolID();
    if (node.GetType() ==
        Type::STRING) { // If we have a string, duplicate it before setting.
      AddCode("(call $_str_copy)");
    }
    if (symbols.IsGlobal(var_id)) {
      AddCode("(global.set $var", var_id, ")");
    } else {
      AddCode("(local.set $var", var_id, ")  ;; Set variable '",
              symbols.GetVarName(var_id), "'");
    }
  }
};
