(module
  (import "Math" "pow" (func $pow (param f64 f64) (result f64)))
  (import "host" "addButton"     (func $addButton  (param i32 i32)))
  (import "host" "addKeyTrigger" (func $addKeyTrigger (param i32 i32)))
  (import "host" "addClickFun"   (func $addClickFun (param i32)))
  (import "host" "addMoveFun"    (func $addMoveFun  (param i32)))
  (import "host" "addAnimFun"    (func $addAnimFun (param i32)))
  (import "host" "setTitle"       (func $setTitle       (param i32)))
  (import "host" "setStrokeColor" (func $setStrokeColor (param i32)))
  (import "host" "setFillColor"   (func $setFillColor   (param i32)))
  (import "host" "setLineWidth"   (func $setLineWidth   (param i32)))
  (import "host" "drawLine"       (func $drawLine   (param i32 i32 i32 i32)))
  (import "host" "drawRect"       (func $drawRect   (param i32 i32 i32 i32)))
  (import "host" "drawCircle"     (func $drawCircle (param i32 i32 i32)))
  (import "host" "drawText"       (func $drawText   (param i32 i32 i32 i32)))
  ;; Define a memory block with ten pages (640KB)
  (memory (export "memory") 10)
  (data (i32.const 0) "##########\00+ #      #\00# # ## # #\00# # #  # #\00# # # ####\00#   #    #\00# ###### #\00# #   #  #\00#   # # ##\00#######-##\00black\00white\00#202020\00green\00red\00blue\00Test: Keyboard input\00w\00KeyUp\00a\00KeyLeft\00s\00KeyDown\00d\00KeyRight\00ArrowUp\00ArrowLeft\00ArrowDown\00ArrowRight\00")
  (global $free_mem (mut i32) (i32.const 244))

  (global $var0 (mut i32) (i32.const 0))
  (global $var1 (mut i32) (i32.const 0))
  (global $var2 (mut i32) (i32.const 0))
  (global $var3 (mut i32) (i32.const 0))
  (global $var4 (mut i32) (i32.const 0))
  (global $var5 (mut i32) (i32.const 0))
  (global $var6 (mut i32) (i32.const 0))
  ;; Function to swap the top two i32s on the stack.
  (func $_swap32 (param $val1 i32) (param $val2 i32) (result i32) (result i32)
    (local.get $val2)
    (local.get $val1)
  )

  ;; Function to allocate a string; add one to size and place null there.
  ;; Returns the memory position of the new string.
  (func $_alloc_str (param $size i32) (result i32)
    (local $null_pos i32) ;; Local variable to place null terminator.
    (global.get $free_mem)                            ;; Old free mem is alloc start.
    (global.get $free_mem)                            ;; Adjust new free mem.
    (local.get $size)
    (i32.add)
    (local.set $null_pos)
    (i32.store8 (local.get $null_pos) (i32.const 0))  ;; Place null terminator.
    (i32.add (i32.const 1) (local.get $null_pos))
    (global.set $free_mem)                            ;; Update free memory start.
  )

  ;; Convert a char to a string.
  ;; Return a pointer to the new string.
  (func $_char2str (param $char i32) (result i32)
    (local $ptr i32)                                  ;; Allocated pointer
    (call $_alloc_str (i32.const 1))                  ;; Allocate a string with one char.
    (local.set $ptr)                                  ;; save the allocated position.
    (i32.store8 (local.get $ptr) (local.get $char))   ;; Store the char.
    (local.get $ptr)                                  ;; return the allocated position.
  )

  ;; Function to copy memory.  Args: [source] [destination] [size]
  ;; No return value.
  (func $_mem_copy (param $src i32) (param $dest i32) (param $size i32)
    (loop $_mem_copy_loop
      (if (i32.eqz (local.get $size)) (then (return)))

      (local.get $dest)               ;; Specify location to place byte
      (i32.load8_u (local.get $src))  ;; Load byte from source
      (i32.store8)                    ;; Store byte

      (local.set $src  (i32.add (local.get $src)  (i32.const 1))) ;; source++
      (local.set $dest (i32.add (local.get $dest) (i32.const 1))) ;; destination++
      (local.set $size (i32.sub (local.get $size) (i32.const 1))) ;; size--;

      (br $_mem_copy_loop) ;; Go back to the start of the loop!
    )
  )

  ;; Function to calculate the length of a string and return it (as i32).
  (func $_strlen (param $ptr i32) (result i32)
    (local $len i32) ;; Local variable to keep track of the length
    (local.set $len (i32.const 0)) ;; Initialize the length to 0

    ;; Loop through memory until the null terminator is found
    (loop $strlen_loop
      (i32.load8_u (local.get $ptr)) ;; Load byte at current pointer
      (if (i32.eqz)                       ;; Test if null.
        (then (local.get $len) (return))  ;; ...if so, return
      )

      ;; Increment pointer and length
      (local.set $ptr (i32.add (local.get $ptr) (i32.const 1))) ;; ptr++
      (local.set $len (i32.add (local.get $len) (i32.const 1))) ;; len++

      (br $strlen_loop) ;; Keep going...
    )
    (local.get $len) ;; Return length
  )

  ;; Function to create make a series of copies of a string.
  ;; $ptr is a pointer to the string to be duplicated.
  ;; $dups is the number of copies to make.
  ;; Returns the memory position of the duplate chain.
  (func $_str_duplicate (param $ptr i32) (param $dups i32) (result i32)
    (local $str_len i32)      ;; Length of the input string
    (local $new_ptr i32)      ;; Pointer to the newly allocated memory
    (local $dest i32)         ;; Pointer for writing to the new string
    (local $i i32)            ;; Loop counter

    ;; Step 1: Get the length of the input string
    (local.get $ptr)
    (call $_strlen)
    (local.set $str_len)

    ;; Step 2: Compute the total length of the new string and allocate it.
    (i32.mul (local.get $str_len) (local.get $dups))
    (call $_alloc_str)
    (local.set $new_ptr)  ;; Store the pointer to the allocated memory

    ;; Step 3: Initialize destination pointer
    (local.set $dest (local.get $new_ptr))

    ;; Step 4: Copy the input string `dups` times into the new memory
    (local.set $i (i32.const 0)) ;; Initialize loop counter
    (block $copy_block
      (loop $copy_loop
        ;; Check if $i >= $dups
        (i32.ge_u (local.get $i) (local.get $dups))
        (br_if $copy_block) ;; Exit loop if done

        ;; Copy the input string to the current destination
        (call $_mem_copy (local.get $ptr) (local.get $dest) (local.get $str_len))

        ;; Update the destination pointer
        (i32.add (local.get $dest) (local.get $str_len))
        (local.set $dest)

        ;; Increment loop counter
        (i32.add (local.get $i) (i32.const 1))
        (local.set $i)

        ;; Repeat the loop
        (br $copy_loop)
      ) ;; end of $copy_loop
    ) ;; end of $copy_block

    (local.get $new_ptr) ;; Return pointer to new string.
  )

  ;; Function to concatenate two strings
  ;; $ptr1 and $ptr2 are the pointers to the two strings to concatenate.
  ;; Returns a pointer to the new, combined string.
  (func $_str_concat (param $ptr1 i32) (param $ptr2 i32) (result i32)
    (local $len1 i32)      ;; Length of the first string
    (local $len2 i32)      ;; Length of the second string
    (local $new_ptr i32)   ;; Pointer to the newly allocated string

    ;; Step 1: Get the lengths of the two strings
    (local.get $ptr1)
    (call $_strlen)
    (local.set $len1)

    (local.get $ptr2)
    (call $_strlen)
    (local.set $len2)

    ;; Step 2: Compute the total length of the new string and allocate memory
    (i32.add (local.get $len1) (local.get $len2))
    (call $_alloc_str)
    (local.set $new_ptr)       ;; Store the pointer to the allocated memory

    ;; Step 3: Copy the first string to the new memory
    (local.get $ptr1)
    (local.get $new_ptr)
    (local.get $len1)
    (call $_mem_copy)

    ;; Step 4: Copy the second string to the new memory (after the first string)
    (local.get $ptr2)
    (i32.add (local.get $new_ptr) (local.get $len1))
    (local.get $len2)
    (call $_mem_copy)

    ;; Step 5: Return the pointer to the new string
    (local.get $new_ptr)
  )

  ;; Function to make a copy of a string and return its pointer.
  (func $_str_copy (param $str i32) (result i32)
    (local $size i32)                    ;; Var: Length of string to copy.
    (local $new_ptr i32)                 ;; Var: Location of new string.
    (call $_strlen (local.get $str))     ;; Calculate length of the string to copy.
    (local.set $size)                    ;; Save the string length.
    (call $_alloc_str (local.get $size)) ;; Allocate space for the new string.
    (local.set $new_ptr)                 ;; Save pointer to new string.
    ;; copy memory into the new string...
    (call $_mem_copy (local.get $str) (local.get $new_ptr) (local.get $size))
    (local.get $new_ptr)                 ;; Return the pointer to the new string.
  )

  (func $Init
    ;; Calculate RHS for assignment.
    (i32.const 10)  ;; Literal value
    (global.set $var0)
    ;; Calculate RHS for assignment.
    (i32.const 10)  ;; Literal value
    (global.set $var1)
    ;; Calculate RHS for assignment.
    (i32.const 1)  ;; Literal value
    (global.set $var2)
    ;; Calculate RHS for assignment.
    (i32.const 0)  ;; Literal value
    (global.set $var3)
    ;; Calculate RHS for assignment.
    (i32.const 0)  ;; Literal string "##########"
    (i32.const 11)  ;; Literal string "+ #      #"
    (call $_str_concat)
    (i32.const 22)  ;; Literal string "# # ## # #"
    (call $_str_concat)
    (i32.const 33)  ;; Literal string "# # #  # #"
    (call $_str_concat)
    (i32.const 44)  ;; Literal string "# # # ####"
    (call $_str_concat)
    (i32.const 55)  ;; Literal string "#   #    #"
    (call $_str_concat)
    (i32.const 66)  ;; Literal string "# ###### #"
    (call $_str_concat)
    (i32.const 77)  ;; Literal string "# #   #  #"
    (call $_str_concat)
    (i32.const 88)  ;; Literal string "#   # # ##"
    (call $_str_concat)
    (i32.const 99)  ;; Literal string "#######-##"
    (call $_str_concat)
    (call $_str_copy)
    (global.set $var4)
    ;; Calculate RHS for assignment.
    (i32.const 600)  ;; Literal value
    (global.get $var1)
    (i32.div_s)
    (global.set $var5)
    ;; Calculate RHS for assignment.
    (i32.const 600)  ;; Literal value
    (global.get $var0)
    (i32.div_s)
    (global.set $var6)
  )
  (start $Init)
  (func $Fun0 (param $var7 i32) (param $var8 i32) (param $var9 i32) (result i32)
    (i32.const 110)  ;; Literal string "black"
    (call $setStrokeColor)  ;; Call function LineColor
    (local.get $var9)  ;; Variable 'color'
    (call $setFillColor)  ;; Call function FillColor
    (i32.const 1)  ;; Literal value
    (call $setLineWidth)  ;; Call function LineWidth
    (local.get $var8)  ;; Variable 'col'
    (global.get $var5)
    (i32.mul)
    (local.get $var7)  ;; Variable 'row'
    (global.get $var6)
    (i32.mul)
    (global.get $var6)
    (global.get $var6)
    (call $drawRect)  ;; Call function Rect
    ;; == Generate return code ==
    (i32.const 0)  ;; Literal value
    (return)
  )
  (func $Fun1 (result i32)
    (local $var10 i32) ;; Declare var 'row'
    (local $var11 i32) ;; Declare var 'col'
    (local $var12 i32) ;; Declare var 'id'
    (local $var13 i32) ;; Declare var 'cell_color'
    ;; Calculate RHS for assignment.
    (i32.const 0)  ;; Literal value
    (local.set $var10)  ;; Set variable 'row'
    (block $exit1 ;; Outer block for breaking while loop.
      (loop $loop1 ;; Inner loop for continuing while.
        ;; == WHILE 1 CONDITION ==
        (local.get $var10)  ;; Variable 'row'
        (global.get $var0)
        (i32.lt_s)
        ;; == END WHILE 1 CONDITION ==
        (i32.eqz)       ;; Invert the result of the test condition.
        (br_if $exit1) ;; If condition was false (0), exit the loop
        ;; == WHILE 1 BODY ==
        ;; Calculate RHS for assignment.
        (i32.const 0)  ;; Literal value
        (local.set $var11)  ;; Set variable 'col'
        (block $exit2 ;; Outer block for breaking while loop.
          (loop $loop2 ;; Inner loop for continuing while.
            ;; == WHILE 2 CONDITION ==
            (local.get $var11)  ;; Variable 'col'
            (global.get $var1)
            (i32.lt_s)
            ;; == END WHILE 2 CONDITION ==
            (i32.eqz)       ;; Invert the result of the test condition.
            (br_if $exit2) ;; If condition was false (0), exit the loop
            ;; == WHILE 2 BODY ==
            ;; Calculate RHS for assignment.
            (local.get $var10)  ;; Variable 'row'
            (global.get $var1)
            (i32.mul)
            (local.get $var11)  ;; Variable 'col'
            (i32.add)
            (local.set $var12)  ;; Set variable 'id'
            ;; Calculate RHS for assignment.
            (i32.const 116)  ;; Literal string "white"
            (call $_str_copy)
            (local.set $var13)  ;; Set variable 'cell_color'
            ;; == If Condition ==
            (global.get $var4)
            (local.get $var12)  ;; Variable 'id'
            (i32.add)      ;; Sum pointer and index to get index memory position.
            (i32.load8_u)  ;; Extract value at index.
            (i32.const 35)  ;; Char literal '#' → ASCII 35
            (i32.eq)
            (if ;; Execute code based on result of condition.
              (then ;; 'then' block
                ;; Calculate RHS for assignment.
                (i32.const 122)  ;; Literal string "#202020"
                (call $_str_copy)
                (local.set $var13)  ;; Set variable 'cell_color'
              ) ;; End 'then'
              (else ;; 'else' block
                ;; == If Condition ==
                (global.get $var4)
                (local.get $var12)  ;; Variable 'id'
                (i32.add)      ;; Sum pointer and index to get index memory position.
                (i32.load8_u)  ;; Extract value at index.
                (i32.const 43)  ;; Char literal '+' → ASCII 43
                (i32.eq)
                (if ;; Execute code based on result of condition.
                  (then ;; 'then' block
                    ;; Calculate RHS for assignment.
                    (i32.const 130)  ;; Literal string "green"
                    (call $_str_copy)
                    (local.set $var13)  ;; Set variable 'cell_color'
                  ) ;; End 'then'
                  (else ;; 'else' block
                    ;; == If Condition ==
                    (global.get $var4)
                    (local.get $var12)  ;; Variable 'id'
                    (i32.add)      ;; Sum pointer and index to get index memory position.
                    (i32.load8_u)  ;; Extract value at index.
                    (i32.const 45)  ;; Char literal '-' → ASCII 45
                    (i32.eq)
                    (if ;; Execute code based on result of condition.
                      (then ;; 'then' block
                        ;; Calculate RHS for assignment.
                        (i32.const 136)  ;; Literal string "red"
                        (call $_str_copy)
                        (local.set $var13)  ;; Set variable 'cell_color'
                      ) ;; End 'then'
                    ) ;; End 'if'
                  ) ;; End 'else'
                ) ;; End 'if'
              ) ;; End 'else'
            ) ;; End 'if'
            ;; == If Condition ==
            (local.get $var10)  ;; Variable 'row'
            (global.get $var2)
            (i32.eq)
            (local.get $var11)  ;; Variable 'col'
            (global.get $var3)
            (i32.eq)
            (i32.mul)
            (if ;; Execute code based on result of condition.
              (then ;; 'then' block
                ;; Calculate RHS for assignment.
                (i32.const 140)  ;; Literal string "blue"
                (call $_str_copy)
                (local.set $var13)  ;; Set variable 'cell_color'
              ) ;; End 'then'
            ) ;; End 'if'
            (local.get $var10)  ;; Variable 'row'
            (local.get $var11)  ;; Variable 'col'
            (local.get $var13)  ;; Variable 'cell_color'
            (call $Fun0)  ;; Call function DrawCell
            (drop) ;; Result not used.
            ;; Calculate RHS for assignment.
            (local.get $var11)  ;; Variable 'col'
            (i32.const 1)  ;; Literal value
            (i32.add)
            (local.set $var11)  ;; Set variable 'col'
            ;; == END WHILE 2 BODY ==
            (br $loop2) ;; Branch back to the start of the loop
          ) ;; End loop
        ) ;; End block

        ;; Calculate RHS for assignment.
        (local.get $var10)  ;; Variable 'row'
        (i32.const 1)  ;; Literal value
        (i32.add)
        (local.set $var10)  ;; Set variable 'row'
        ;; == END WHILE 1 BODY ==
        (br $loop1) ;; Branch back to the start of the loop
      ) ;; End loop
    ) ;; End block

    ;; == Generate return code ==
    (i32.const 0)  ;; Literal value
    (return)
  )
  (func $Fun2 (param $var14 i32) (param $var15 i32) (result i32)
    (local $var16 i32) ;; Declare var 'new_id'
    ;; == If Condition ==
    (local.get $var14)  ;; Variable 'new_row'
    (i32.const 0)  ;; Literal value
    (i32.lt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; == Generate return code ==
        (i32.const 0)  ;; Literal value
        (return)
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (local.get $var14)  ;; Variable 'new_row'
    (global.get $var0)
    (i32.ge_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; == Generate return code ==
        (i32.const 0)  ;; Literal value
        (return)
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (local.get $var15)  ;; Variable 'new_col'
    (i32.const 0)  ;; Literal value
    (i32.lt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; == Generate return code ==
        (i32.const 0)  ;; Literal value
        (return)
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (local.get $var15)  ;; Variable 'new_col'
    (global.get $var1)
    (i32.ge_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; == Generate return code ==
        (i32.const 0)  ;; Literal value
        (return)
      ) ;; End 'then'
    ) ;; End 'if'
    ;; Calculate RHS for assignment.
    (local.get $var14)  ;; Variable 'new_row'
    (global.get $var1)
    (i32.mul)
    (local.get $var15)  ;; Variable 'new_col'
    (i32.add)
    (local.set $var16)  ;; Set variable 'new_id'
    ;; == If Condition ==
    (global.get $var4)
    (local.get $var16)  ;; Variable 'new_id'
    (i32.add)      ;; Sum pointer and index to get index memory position.
    (i32.load8_u)  ;; Extract value at index.
    (i32.const 35)  ;; Char literal '#' → ASCII 35
    (i32.ne)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (local.get $var14)  ;; Variable 'new_row'
        (global.set $var2)
        ;; Calculate RHS for assignment.
        (local.get $var15)  ;; Variable 'new_col'
        (global.set $var3)
        (call $Fun1)  ;; Call function DrawBoard
        (drop) ;; Result not used.
        ;; == Generate return code ==
        (i32.const 1)  ;; Literal value
        (return)
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == Generate return code ==
    (i32.const 0)  ;; Literal value
    (return)
  )
  (func $Fun3 (result i32)
    ;; == Generate return code ==
    (global.get $var2)
    (i32.const 1)  ;; Literal value
    (i32.sub)
    (global.get $var3)
    (call $Fun2)  ;; Call function TryMove
    (return)
  )
  (func $Fun4 (result i32)
    ;; == Generate return code ==
    (global.get $var2)
    (i32.const 1)  ;; Literal value
    (i32.add)
    (global.get $var3)
    (call $Fun2)  ;; Call function TryMove
    (return)
  )
  (func $Fun5 (result i32)
    ;; == Generate return code ==
    (global.get $var2)
    (global.get $var3)
    (i32.const 1)  ;; Literal value
    (i32.sub)
    (call $Fun2)  ;; Call function TryMove
    (return)
  )
  (func $Fun6 (result i32)
    ;; == Generate return code ==
    (global.get $var2)
    (global.get $var3)
    (i32.const 1)  ;; Literal value
    (i32.add)
    (call $Fun2)  ;; Call function TryMove
    (return)
  )
  (func $Fun7 (result i32)
    (i32.const 145)  ;; Literal string "Test: Keyboard input"
    (call $setTitle)  ;; Call function SetTitle
    (call $Fun1)  ;; Call function DrawBoard
    (drop) ;; Result not used.
    (i32.const 166)  ;; Literal string "w"
    (i32.const 168)  ;; Literal string "KeyUp"
    (call $addKeyTrigger)  ;; Call function AddKeypress
    (i32.const 174)  ;; Literal string "a"
    (i32.const 176)  ;; Literal string "KeyLeft"
    (call $addKeyTrigger)  ;; Call function AddKeypress
    (i32.const 184)  ;; Literal string "s"
    (i32.const 186)  ;; Literal string "KeyDown"
    (call $addKeyTrigger)  ;; Call function AddKeypress
    (i32.const 194)  ;; Literal string "d"
    (i32.const 196)  ;; Literal string "KeyRight"
    (call $addKeyTrigger)  ;; Call function AddKeypress
    (i32.const 205)  ;; Literal string "ArrowUp"
    (i32.const 168)  ;; Literal string "KeyUp"
    (call $addKeyTrigger)  ;; Call function AddKeypress
    (i32.const 213)  ;; Literal string "ArrowLeft"
    (i32.const 176)  ;; Literal string "KeyLeft"
    (call $addKeyTrigger)  ;; Call function AddKeypress
    (i32.const 223)  ;; Literal string "ArrowDown"
    (i32.const 186)  ;; Literal string "KeyDown"
    (call $addKeyTrigger)  ;; Call function AddKeypress
    (i32.const 233)  ;; Literal string "ArrowRight"
    (i32.const 196)  ;; Literal string "KeyRight"
    (call $addKeyTrigger)  ;; Call function AddKeypress
    ;; == Generate return code ==
    (i32.const 0)  ;; Literal value
    (return)
  )

  (export "DrawCell" (func $Fun0))
  (export "DrawBoard" (func $Fun1))
  (export "TryMove" (func $Fun2))
  (export "KeyUp" (func $Fun3))
  (export "KeyDown" (func $Fun4))
  (export "KeyLeft" (func $Fun5))
  (export "KeyRight" (func $Fun6))
  (export "Main" (func $Fun7))
) ;; End module
