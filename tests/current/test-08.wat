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
  (data (i32.const 0) "black\00while\00orange\00purple\00yellow\00pink\00brown\00gray\00#000080\00#800000\00#008000\00Test: Buttons to modify the image.\00Bigger!\00IncSize\00Smaller!\00DecSize\00")
  (global $free_mem (mut i32) (i32.const 141))

  (global $var0 (mut i32) (i32.const 0))
  (global $var1 (mut i32) (i32.const 0))
  (global $var2 (mut i32) (i32.const 0))
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
    (i32.const 80)  ;; Literal value
    (global.set $var2)
  )
  (start $Init)
  (func $Fun0 (param $var3 i32) (result i32)
    (local.get $var3)  ;; Variable 'color'
    (call $setStrokeColor)  ;; Call function LineColor
    (i32.const 4)  ;; Literal value
    (call $setLineWidth)  ;; Call function LineWidth
    (global.get $var0)
    (global.get $var1)
    (global.get $var0)
    (global.get $var2)
    (i32.add)
    (global.get $var1)
    (global.get $var2)
    (i32.add)
    (call $drawLine)  ;; Call function Line
    (global.get $var0)
    (global.get $var2)
    (i32.add)
    (global.get $var1)
    (global.get $var0)
    (global.get $var1)
    (global.get $var2)
    (i32.add)
    (call $drawLine)  ;; Call function Line
    ;; Calculate RHS for assignment.
    (global.get $var0)
    (global.get $var2)
    (i32.add)
    (i32.const 20)  ;; Literal value
    (i32.add)
    (global.set $var0)
    ;; == If Condition ==
    (global.get $var0)
    (global.get $var2)
    (i32.add)
    (i32.const 600)  ;; Literal value
    (i32.gt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (i32.const 10)  ;; Literal value
        (global.set $var0)
        ;; Calculate RHS for assignment.
        (global.get $var1)
        (global.get $var2)
        (i32.add)
        (i32.const 20)  ;; Literal value
        (i32.add)
        (global.set $var1)
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == Generate return code ==
    (i32.const 0)  ;; Literal value
    (return)
  )
  (func $Fun1 (result i32)
    (i32.const 0)  ;; Literal string "black"
    (call $setStrokeColor)  ;; Call function LineColor
    (i32.const 6)  ;; Literal string "while"
    (call $setFillColor)  ;; Call function FillColor
    (i32.const 4)  ;; Literal value
    (call $setLineWidth)  ;; Call function LineWidth
    (i32.const 0)  ;; Literal value
    (i32.const 0)  ;; Literal value
    (i32.const 600)  ;; Literal value
    (i32.const 600)  ;; Literal value
    (call $drawRect)  ;; Call function Rect
    (i32.const 12)  ;; Literal string "orange"
    (call $Fun0)  ;; Call function DrawX
    (drop) ;; Result not used.
    (i32.const 19)  ;; Literal string "purple"
    (call $Fun0)  ;; Call function DrawX
    (drop) ;; Result not used.
    (i32.const 26)  ;; Literal string "yellow"
    (call $Fun0)  ;; Call function DrawX
    (drop) ;; Result not used.
    (i32.const 33)  ;; Literal string "pink"
    (call $Fun0)  ;; Call function DrawX
    (drop) ;; Result not used.
    (i32.const 38)  ;; Literal string "brown"
    (call $Fun0)  ;; Call function DrawX
    (drop) ;; Result not used.
    (i32.const 44)  ;; Literal string "gray"
    (call $Fun0)  ;; Call function DrawX
    (drop) ;; Result not used.
    (i32.const 49)  ;; Literal string "#000080"
    (call $Fun0)  ;; Call function DrawX
    (drop) ;; Result not used.
    (i32.const 57)  ;; Literal string "#800000"
    (call $Fun0)  ;; Call function DrawX
    (drop) ;; Result not used.
    (i32.const 65)  ;; Literal string "#008000"
    (call $Fun0)  ;; Call function DrawX
    (drop) ;; Result not used.
    ;; == Generate return code ==
    (i32.const 0)  ;; Literal value
    (return)
  )
  (func $Fun2 (result i32)
    ;; Calculate RHS for assignment.
    (i32.const 10)  ;; Literal value
    (global.set $var0)
    ;; Calculate RHS for assignment.
    (i32.const 10)  ;; Literal value
    (global.set $var1)
    ;; Calculate RHS for assignment.
    (global.get $var2)
    (i32.const 20)  ;; Literal value
    (i32.add)
    (global.set $var2)
    ;; == If Condition ==
    (global.get $var2)
    (i32.const 300)  ;; Literal value
    (i32.gt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (i32.const 300)  ;; Literal value
        (global.set $var2)
      ) ;; End 'then'
    ) ;; End 'if'
    (call $Fun1)  ;; Call function DrawScreen
    (drop) ;; Result not used.
    ;; == Generate return code ==
    (i32.const 0)  ;; Literal value
    (return)
  )
  (func $Fun3 (result i32)
    ;; Calculate RHS for assignment.
    (i32.const 10)  ;; Literal value
    (global.set $var0)
    ;; Calculate RHS for assignment.
    (i32.const 10)  ;; Literal value
    (global.set $var1)
    ;; Calculate RHS for assignment.
    (global.get $var2)
    (i32.const 20)  ;; Literal value
    (i32.sub)
    (global.set $var2)
    ;; == If Condition ==
    (global.get $var2)
    (i32.const 20)  ;; Literal value
    (i32.lt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (i32.const 20)  ;; Literal value
        (global.set $var2)
      ) ;; End 'then'
    ) ;; End 'if'
    (call $Fun1)  ;; Call function DrawScreen
    (drop) ;; Result not used.
    ;; == Generate return code ==
    (i32.const 0)  ;; Literal value
    (return)
  )
  (func $Fun4 (result i32)
    (i32.const 73)  ;; Literal string "Test: Buttons to modify the image."
    (call $setTitle)  ;; Call function SetTitle
    (call $Fun1)  ;; Call function DrawScreen
    (drop) ;; Result not used.
    (i32.const 108)  ;; Literal string "Bigger!"
    (i32.const 116)  ;; Literal string "IncSize"
    (call $addButton)  ;; Call function AddButton
    (i32.const 124)  ;; Literal string "Smaller!"
    (i32.const 133)  ;; Literal string "DecSize"
    (call $addButton)  ;; Call function AddButton
    ;; == Generate return code ==
    (i32.const 0)  ;; Literal value
    (return)
  )

  (export "DrawX" (func $Fun0))
  (export "DrawScreen" (func $Fun1))
  (export "IncSize" (func $Fun2))
  (export "DecSize" (func $Fun3))
  (export "Main" (func $Fun4))
  (export "free_mem" (global $free_mem))
) ;; End module
