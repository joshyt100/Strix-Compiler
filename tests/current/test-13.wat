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
  (data (i32.const 0) "black\00#6e6a00ff\00#6e6a00d6\00#303030\00#808080\00green\00white\00blue\00red\00yellow\00You Win!\00Test: Continuous Animation\00s\00ActivateShield\00ArrowUp\00KeyUp\00ArrowLeft\00KeyLeft\00ArrowDown\00KeyDown\00ArrowRight\00KeyRight\00UpdateBoard\00")
  (global $free_mem (mut i32) (i32.const 205))

  (global $var0 (mut i32) (i32.const 0))
  (global $var1 (mut i32) (i32.const 0))
  (global $var2 (mut i32) (i32.const 100))
  (global $var3 (mut i32) (i32.const 10))
  (global $var4 (mut i32) (i32.const 0))
  (global $var5 (mut i32) (i32.const 0))
  (global $var6 (mut i32) (i32.const 80))
  (global $var7 (mut i32) (i32.const 2))
  (global $var8 (mut i32) (i32.const 0))
  (global $var9 (mut i32) (i32.const 0))
  (global $var10 (mut i32) (i32.const 70))
  (global $var11 (mut i32) (i32.const 3))
  (global $var12 (mut i32) (i32.const 0))
  (global $var13 (mut i32) (i32.const 0))
  (global $var14 (mut i32) (i32.const 60))
  (global $var15 (mut i32) (i32.const 4))
  (global $var16 (mut i32) (i32.const 0))
  (global $var17 (mut i32) (i32.const 0))
  (global $var18 (mut i32) (i32.const 50))
  (global $var19 (mut i32) (i32.const 5))
  (global $var20 (mut i32) (i32.const 0))
  (global $var21 (mut i32) (i32.const 0))
  (global $var22 (mut i32) (i32.const 0))
  (global $var23 (mut i32) (i32.const 0))
  (global $var24 (mut i32) (i32.const 0))
  (global $var25 (mut i32) (i32.const 0))
  (global $var26 (mut i32) (i32.const 0))
  (global $var27 (mut i32) (i32.const 0))
  (global $var28 (mut i32) (i32.const 0))
  (global $var29 (mut i32) (i32.const 0))
  (global $var30 (mut i32) (i32.const 0))
  (global $var31 (mut i32) (i32.const 0))
  (global $var32 (mut i32) (i32.const 0))
  (global $var33 (mut i32) (i32.const 0))
  (global $var34 (mut i32) (i32.const 0))
  (global $var35 (mut i32) (i32.const 0))
  (global $var36 (mut i32) (i32.const 0))
  (global $var37 (mut i32) (i32.const 0))
  (global $var38 (mut i32) (i32.const 0))
  (global $var39 (mut i32) (i32.const 0))
  (global $var40 (mut i32) (i32.const 0))
  (global $var41 (mut i32) (i32.const 500))
  (global $var42 (mut i32) (i32.const 500))
  (global $var43 (mut i32) (i32.const 5500))
  (global $var44 (mut i32) (i32.const 5500))
  (global $var45 (mut i32) (i32.const 1750))
  (global $var46 (mut i32) (i32.const 500))
  (global $var47 (mut i32) (i32.const 4250))
  (global $var48 (mut i32) (i32.const 5500))
  (global $var49 (mut i32) (i32.const 3000))
  (global $var50 (mut i32) (i32.const 500))
  (global $var51 (mut i32) (i32.const 3000))
  (global $var52 (mut i32) (i32.const 5500))
  (global $var53 (mut i32) (i32.const 4250))
  (global $var54 (mut i32) (i32.const 500))
  (global $var55 (mut i32) (i32.const 1750))
  (global $var56 (mut i32) (i32.const 5500))
  (global $var57 (mut i32) (i32.const 5500))
  (global $var58 (mut i32) (i32.const 500))
  (global $var59 (mut i32) (i32.const 500))
  (global $var60 (mut i32) (i32.const 5500))
  (global $var61 (mut i32) (i32.const 5500))
  (global $var62 (mut i32) (i32.const 1750))
  (global $var63 (mut i32) (i32.const 500))
  (global $var64 (mut i32) (i32.const 4250))
  (global $var65 (mut i32) (i32.const 5500))
  (global $var66 (mut i32) (i32.const 3000))
  (global $var67 (mut i32) (i32.const 500))
  (global $var68 (mut i32) (i32.const 3000))
  (global $var69 (mut i32) (i32.const 5500))
  (global $var70 (mut i32) (i32.const 4250))
  (global $var71 (mut i32) (i32.const 500))
  (global $var72 (mut i32) (i32.const 1750))
  (global $var73 (mut i32) (i32.const 10))
  (global $var74 (mut i32) (i32.const 0))
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

  (func $Fun0 (result i32)
    ;; == If Condition ==
    (global.get $var22)
    (i32.const 0)  ;; Literal value
    (i32.gt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; == Generate return code ==
        (i32.const 0)  ;; Literal value
        (return)
      ) ;; End 'then'
    ) ;; End 'if'
    ;; Calculate RHS for assignment.
    (global.get $var0)
    (global.set $var20)
    ;; Calculate RHS for assignment.
    (global.get $var1)
    (global.set $var21)
    ;; Calculate RHS for assignment.
    (i32.const 800)  ;; Literal value
    (global.set $var22)
    ;; == Generate return code ==
    (i32.const 1)  ;; Literal value
    (return)
  )
  (func $Fun1 (result i32)
    ;; Calculate RHS for assignment.
    (i32.const 3000)  ;; Literal value
    (global.set $var0)
    ;; Calculate RHS for assignment.
    (i32.const 3000)  ;; Literal value
    (global.set $var1)
    ;; Calculate RHS for assignment.
    (i32.const 1000)  ;; Literal value
    (global.set $var4)
    ;; Calculate RHS for assignment.
    (i32.const 1000)  ;; Literal value
    (global.set $var5)
    ;; Calculate RHS for assignment.
    (i32.const 5000)  ;; Literal value
    (global.set $var8)
    ;; Calculate RHS for assignment.
    (i32.const 1000)  ;; Literal value
    (global.set $var9)
    ;; Calculate RHS for assignment.
    (i32.const 1000)  ;; Literal value
    (global.set $var12)
    ;; Calculate RHS for assignment.
    (i32.const 5000)  ;; Literal value
    (global.set $var13)
    ;; Calculate RHS for assignment.
    (i32.const 5000)  ;; Literal value
    (global.set $var16)
    ;; Calculate RHS for assignment.
    (i32.const 5000)  ;; Literal value
    (global.set $var17)
    ;; Calculate RHS for assignment.
    (i32.const 0)  ;; Literal value
    (global.set $var23)
    ;; Calculate RHS for assignment.
    (i32.const 0)  ;; Literal value
    (global.set $var24)
    ;; Calculate RHS for assignment.
    (i32.const 0)  ;; Literal value
    (global.set $var22)
    ;; Calculate RHS for assignment.
    (i32.const 0)  ;; Literal value
    (global.set $var25)
    ;; Calculate RHS for assignment.
    (i32.const 0)  ;; Literal value
    (global.set $var26)
    ;; Calculate RHS for assignment.
    (i32.const 0)  ;; Literal value
    (global.set $var27)
    ;; Calculate RHS for assignment.
    (i32.const 0)  ;; Literal value
    (global.set $var28)
    ;; Calculate RHS for assignment.
    (i32.const 0)  ;; Literal value
    (global.set $var29)
    ;; Calculate RHS for assignment.
    (i32.const 0)  ;; Literal value
    (global.set $var30)
    ;; Calculate RHS for assignment.
    (i32.const 0)  ;; Literal value
    (global.set $var31)
    ;; Calculate RHS for assignment.
    (i32.const 0)  ;; Literal value
    (global.set $var32)
    ;; Calculate RHS for assignment.
    (i32.const 0)  ;; Literal value
    (global.set $var33)
    ;; Calculate RHS for assignment.
    (i32.const 0)  ;; Literal value
    (global.set $var34)
    ;; Calculate RHS for assignment.
    (i32.const 0)  ;; Literal value
    (global.set $var35)
    ;; Calculate RHS for assignment.
    (i32.const 0)  ;; Literal value
    (global.set $var36)
    ;; Calculate RHS for assignment.
    (i32.const 0)  ;; Literal value
    (global.set $var37)
    ;; Calculate RHS for assignment.
    (i32.const 0)  ;; Literal value
    (global.set $var38)
    ;; Calculate RHS for assignment.
    (i32.const 0)  ;; Literal value
    (global.set $var39)
    ;; Calculate RHS for assignment.
    (i32.const 0)  ;; Literal value
    (global.set $var40)
    (call $Fun0)  ;; Call function ActivateShield
    (drop) ;; Result not used.
    ;; == Generate return code ==
    (i32.const 0)  ;; Literal value
    (return)
  )
  (func $Fun2 (param $var75 i32) (param $var76 i32) (param $var77 i32) (param $var78 i32) (param $var79 i32) (result i32)
    (local $var80 i32) ;; Declare var 'max_sqr'
    (local $var81 i32) ;; Declare var 'x_dist'
    (local $var82 i32) ;; Declare var 'x_sqr'
    (local $var83 i32) ;; Declare var 'y_dist'
    (local $var84 i32) ;; Declare var 'y_sqr'
    ;; Calculate RHS for assignment.
    (local.get $var79)  ;; Variable 'max_dist'
    (local.get $var79)  ;; Variable 'max_dist'
    (i32.mul)
    (local.set $var80)  ;; Set variable 'max_sqr'
    ;; Calculate RHS for assignment.
    (local.get $var75)  ;; Variable 'x1'
    (local.get $var77)  ;; Variable 'x2'
    (i32.sub)
    (local.set $var81)  ;; Set variable 'x_dist'
    ;; Calculate RHS for assignment.
    (local.get $var81)  ;; Variable 'x_dist'
    (local.get $var81)  ;; Variable 'x_dist'
    (i32.mul)
    (local.set $var82)  ;; Set variable 'x_sqr'
    ;; Calculate RHS for assignment.
    (local.get $var76)  ;; Variable 'y1'
    (local.get $var78)  ;; Variable 'y2'
    (i32.sub)
    (local.set $var83)  ;; Set variable 'y_dist'
    ;; Calculate RHS for assignment.
    (local.get $var83)  ;; Variable 'y_dist'
    (local.get $var83)  ;; Variable 'y_dist'
    (i32.mul)
    (local.set $var84)  ;; Set variable 'y_sqr'
    ;; == Generate return code ==
    (local.get $var80)  ;; Variable 'max_sqr'
    (local.get $var82)  ;; Variable 'x_sqr'
    (local.get $var84)  ;; Variable 'y_sqr'
    (i32.add)
    (i32.ge_s)
    (return)
  )
  (func $Fun3 (param $var85 i32) (param $var86 i32) (param $var87 i32) (param $var88 i32) (param $var89 i32) (param $var90 i32) (result i32)
    ;; == If Condition ==
    (local.get $var87)  ;; Variable 'r1'
    (i32.const 0)  ;; Literal value
    (i32.le_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; == Generate return code ==
        (i32.const 0)  ;; Literal value
        (return)
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (local.get $var90)  ;; Variable 'r2'
    (i32.const 0)  ;; Literal value
    (i32.le_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; == Generate return code ==
        (i32.const 0)  ;; Literal value
        (return)
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == Generate return code ==
    (local.get $var85)  ;; Variable 'x1'
    (local.get $var86)  ;; Variable 'y1'
    (local.get $var88)  ;; Variable 'x2'
    (local.get $var89)  ;; Variable 'y2'
    (local.get $var87)  ;; Variable 'r1'
    (local.get $var90)  ;; Variable 'r2'
    (i32.add)
    (call $Fun2)  ;; Call function TestInRange
    (return)
  )
  (func $Fun4 (result i32)
    (i32.const 0)  ;; Literal string "black"
    (call $setFillColor)  ;; Call function FillColor
    (i32.const 0)  ;; Literal string "black"
    (call $setFillColor)  ;; Call function FillColor
    (i32.const 6)  ;; Literal value
    (call $setLineWidth)  ;; Call function LineWidth
    (i32.const 0)  ;; Literal value
    (i32.const 0)  ;; Literal value
    (i32.const 600)  ;; Literal value
    (i32.const 600)  ;; Literal value
    (call $drawRect)  ;; Call function Rect
    ;; == If Condition ==
    (global.get $var22)
    (i32.const 0)  ;; Literal value
    (i32.gt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        (i32.const 6)  ;; Literal string "#6e6a00ff"
        (call $setStrokeColor)  ;; Call function LineColor
        (i32.const 16)  ;; Literal string "#6e6a00d6"
        (call $setFillColor)  ;; Call function FillColor
        (i32.const 1)  ;; Literal value
        (call $setLineWidth)  ;; Call function LineWidth
        (global.get $var20)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var21)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var22)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (call $drawCircle)  ;; Call function Circle
      ) ;; End 'then'
    ) ;; End 'if'
    (i32.const 26)  ;; Literal string "#303030"
    (call $setFillColor)  ;; Call function FillColor
    (i32.const 34)  ;; Literal string "#808080"
    (call $setStrokeColor)  ;; Call function LineColor
    (i32.const 4)  ;; Literal value
    (call $setLineWidth)  ;; Call function LineWidth
    ;; == If Condition ==
    (global.get $var25)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        (global.get $var41)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var42)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var73)
        (call $drawCircle)  ;; Call function Circle
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var26)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        (global.get $var43)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var44)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var73)
        (call $drawCircle)  ;; Call function Circle
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var27)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        (global.get $var45)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var46)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var73)
        (call $drawCircle)  ;; Call function Circle
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var28)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        (global.get $var47)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var48)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var73)
        (call $drawCircle)  ;; Call function Circle
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var29)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        (global.get $var49)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var50)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var73)
        (call $drawCircle)  ;; Call function Circle
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var30)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        (global.get $var51)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var52)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var73)
        (call $drawCircle)  ;; Call function Circle
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var31)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        (global.get $var53)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var54)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var73)
        (call $drawCircle)  ;; Call function Circle
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var32)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        (global.get $var55)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var56)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var73)
        (call $drawCircle)  ;; Call function Circle
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var33)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        (global.get $var57)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var58)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var73)
        (call $drawCircle)  ;; Call function Circle
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var34)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        (global.get $var59)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var60)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var73)
        (call $drawCircle)  ;; Call function Circle
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var35)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        (global.get $var61)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var62)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var73)
        (call $drawCircle)  ;; Call function Circle
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var36)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        (global.get $var63)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var64)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var73)
        (call $drawCircle)  ;; Call function Circle
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var37)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        (global.get $var65)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var66)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var73)
        (call $drawCircle)  ;; Call function Circle
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var38)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        (global.get $var67)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var68)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var73)
        (call $drawCircle)  ;; Call function Circle
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var39)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        (global.get $var69)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var70)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var73)
        (call $drawCircle)  ;; Call function Circle
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var40)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        (global.get $var71)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var72)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var73)
        (call $drawCircle)  ;; Call function Circle
      ) ;; End 'then'
    ) ;; End 'if'
    (i32.const 42)  ;; Literal string "green"
    (call $setFillColor)  ;; Call function FillColor
    (i32.const 48)  ;; Literal string "white"
    (call $setStrokeColor)  ;; Call function LineColor
    (i32.const 1)  ;; Literal value
    (call $setLineWidth)  ;; Call function LineWidth
    ;; == If Condition ==
    (global.get $var25)
    (i32.eqz)  ;; Do operator '!'
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        (global.get $var41)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var42)
        (i32.const 10)  ;; Literal value
        (i32.div_s)
        (global.get $var73)
        (call $drawCircle)  ;; Call function Circle
      ) ;; End 'then'
      (else ;; 'else' block
        ;; == If Condition ==
        (global.get $var26)
        (i32.eqz)  ;; Do operator '!'
        (if ;; Execute code based on result of condition.
          (then ;; 'then' block
            (global.get $var43)
            (i32.const 10)  ;; Literal value
            (i32.div_s)
            (global.get $var44)
            (i32.const 10)  ;; Literal value
            (i32.div_s)
            (global.get $var73)
            (call $drawCircle)  ;; Call function Circle
          ) ;; End 'then'
          (else ;; 'else' block
            ;; == If Condition ==
            (global.get $var27)
            (i32.eqz)  ;; Do operator '!'
            (if ;; Execute code based on result of condition.
              (then ;; 'then' block
                (global.get $var45)
                (i32.const 10)  ;; Literal value
                (i32.div_s)
                (global.get $var46)
                (i32.const 10)  ;; Literal value
                (i32.div_s)
                (global.get $var73)
                (call $drawCircle)  ;; Call function Circle
              ) ;; End 'then'
              (else ;; 'else' block
                ;; == If Condition ==
                (global.get $var28)
                (i32.eqz)  ;; Do operator '!'
                (if ;; Execute code based on result of condition.
                  (then ;; 'then' block
                    (global.get $var47)
                    (i32.const 10)  ;; Literal value
                    (i32.div_s)
                    (global.get $var48)
                    (i32.const 10)  ;; Literal value
                    (i32.div_s)
                    (global.get $var73)
                    (call $drawCircle)  ;; Call function Circle
                  ) ;; End 'then'
                  (else ;; 'else' block
                    ;; == If Condition ==
                    (global.get $var29)
                    (i32.eqz)  ;; Do operator '!'
                    (if ;; Execute code based on result of condition.
                      (then ;; 'then' block
                        (global.get $var49)
                        (i32.const 10)  ;; Literal value
                        (i32.div_s)
                        (global.get $var50)
                        (i32.const 10)  ;; Literal value
                        (i32.div_s)
                        (global.get $var73)
                        (call $drawCircle)  ;; Call function Circle
                      ) ;; End 'then'
                      (else ;; 'else' block
                        ;; == If Condition ==
                        (global.get $var30)
                        (i32.eqz)  ;; Do operator '!'
                        (if ;; Execute code based on result of condition.
                          (then ;; 'then' block
                            (global.get $var51)
                            (i32.const 10)  ;; Literal value
                            (i32.div_s)
                            (global.get $var52)
                            (i32.const 10)  ;; Literal value
                            (i32.div_s)
                            (global.get $var73)
                            (call $drawCircle)  ;; Call function Circle
                          ) ;; End 'then'
                          (else ;; 'else' block
                            ;; == If Condition ==
                            (global.get $var31)
                            (i32.eqz)  ;; Do operator '!'
                            (if ;; Execute code based on result of condition.
                              (then ;; 'then' block
                                (global.get $var53)
                                (i32.const 10)  ;; Literal value
                                (i32.div_s)
                                (global.get $var54)
                                (i32.const 10)  ;; Literal value
                                (i32.div_s)
                                (global.get $var73)
                                (call $drawCircle)  ;; Call function Circle
                              ) ;; End 'then'
                              (else ;; 'else' block
                                ;; == If Condition ==
                                (global.get $var32)
                                (i32.eqz)  ;; Do operator '!'
                                (if ;; Execute code based on result of condition.
                                  (then ;; 'then' block
                                    (global.get $var55)
                                    (i32.const 10)  ;; Literal value
                                    (i32.div_s)
                                    (global.get $var56)
                                    (i32.const 10)  ;; Literal value
                                    (i32.div_s)
                                    (global.get $var73)
                                    (call $drawCircle)  ;; Call function Circle
                                  ) ;; End 'then'
                                  (else ;; 'else' block
                                    ;; == If Condition ==
                                    (global.get $var33)
                                    (i32.eqz)  ;; Do operator '!'
                                    (if ;; Execute code based on result of condition.
                                      (then ;; 'then' block
                                        (global.get $var57)
                                        (i32.const 10)  ;; Literal value
                                        (i32.div_s)
                                        (global.get $var58)
                                        (i32.const 10)  ;; Literal value
                                        (i32.div_s)
                                        (global.get $var73)
                                        (call $drawCircle)  ;; Call function Circle
                                      ) ;; End 'then'
                                      (else ;; 'else' block
                                        ;; == If Condition ==
                                        (global.get $var34)
                                        (i32.eqz)  ;; Do operator '!'
                                        (if ;; Execute code based on result of condition.
                                          (then ;; 'then' block
                                            (global.get $var59)
                                            (i32.const 10)  ;; Literal value
                                            (i32.div_s)
                                            (global.get $var60)
                                            (i32.const 10)  ;; Literal value
                                            (i32.div_s)
                                            (global.get $var73)
                                            (call $drawCircle)  ;; Call function Circle
                                          ) ;; End 'then'
                                          (else ;; 'else' block
                                            ;; == If Condition ==
                                            (global.get $var35)
                                            (i32.eqz)  ;; Do operator '!'
                                            (if ;; Execute code based on result of condition.
                                              (then ;; 'then' block
                                                (global.get $var61)
                                                (i32.const 10)  ;; Literal value
                                                (i32.div_s)
                                                (global.get $var62)
                                                (i32.const 10)  ;; Literal value
                                                (i32.div_s)
                                                (global.get $var73)
                                                (call $drawCircle)  ;; Call function Circle
                                              ) ;; End 'then'
                                              (else ;; 'else' block
                                                ;; == If Condition ==
                                                (global.get $var36)
                                                (i32.eqz)  ;; Do operator '!'
                                                (if ;; Execute code based on result of condition.
                                                  (then ;; 'then' block
                                                    (global.get $var63)
                                                    (i32.const 10)  ;; Literal value
                                                    (i32.div_s)
                                                    (global.get $var64)
                                                    (i32.const 10)  ;; Literal value
                                                    (i32.div_s)
                                                    (global.get $var73)
                                                    (call $drawCircle)  ;; Call function Circle
                                                  ) ;; End 'then'
                                                  (else ;; 'else' block
                                                    ;; == If Condition ==
                                                    (global.get $var37)
                                                    (i32.eqz)  ;; Do operator '!'
                                                    (if ;; Execute code based on result of condition.
                                                      (then ;; 'then' block
                                                        (global.get $var65)
                                                        (i32.const 10)  ;; Literal value
                                                        (i32.div_s)
                                                        (global.get $var66)
                                                        (i32.const 10)  ;; Literal value
                                                        (i32.div_s)
                                                        (global.get $var73)
                                                        (call $drawCircle)  ;; Call function Circle
                                                      ) ;; End 'then'
                                                      (else ;; 'else' block
                                                        ;; == If Condition ==
                                                        (global.get $var38)
                                                        (i32.eqz)  ;; Do operator '!'
                                                        (if ;; Execute code based on result of condition.
                                                          (then ;; 'then' block
                                                            (global.get $var67)
                                                            (i32.const 10)  ;; Literal value
                                                            (i32.div_s)
                                                            (global.get $var68)
                                                            (i32.const 10)  ;; Literal value
                                                            (i32.div_s)
                                                            (global.get $var73)
                                                            (call $drawCircle)  ;; Call function Circle
                                                          ) ;; End 'then'
                                                          (else ;; 'else' block
                                                            ;; == If Condition ==
                                                            (global.get $var39)
                                                            (i32.eqz)  ;; Do operator '!'
                                                            (if ;; Execute code based on result of condition.
                                                              (then ;; 'then' block
                                                                (global.get $var69)
                                                                (i32.const 10)  ;; Literal value
                                                                (i32.div_s)
                                                                (global.get $var70)
                                                                (i32.const 10)  ;; Literal value
                                                                (i32.div_s)
                                                                (global.get $var73)
                                                                (call $drawCircle)  ;; Call function Circle
                                                              ) ;; End 'then'
                                                              (else ;; 'else' block
                                                                ;; == If Condition ==
                                                                (global.get $var40)
                                                                (i32.eqz)  ;; Do operator '!'
                                                                (if ;; Execute code based on result of condition.
                                                                  (then ;; 'then' block
                                                                    (global.get $var71)
                                                                    (i32.const 10)  ;; Literal value
                                                                    (i32.div_s)
                                                                    (global.get $var72)
                                                                    (i32.const 10)  ;; Literal value
                                                                    (i32.div_s)
                                                                    (global.get $var73)
                                                                    (call $drawCircle)  ;; Call function Circle
                                                                  ) ;; End 'then'
                                                                ) ;; End 'if'
                                                              ) ;; End 'else'
                                                            ) ;; End 'if'
                                                          ) ;; End 'else'
                                                        ) ;; End 'if'
                                                      ) ;; End 'else'
                                                    ) ;; End 'if'
                                                  ) ;; End 'else'
                                                ) ;; End 'if'
                                              ) ;; End 'else'
                                            ) ;; End 'if'
                                          ) ;; End 'else'
                                        ) ;; End 'if'
                                      ) ;; End 'else'
                                    ) ;; End 'if'
                                  ) ;; End 'else'
                                ) ;; End 'if'
                              ) ;; End 'else'
                            ) ;; End 'if'
                          ) ;; End 'else'
                        ) ;; End 'if'
                      ) ;; End 'else'
                    ) ;; End 'if'
                  ) ;; End 'else'
                ) ;; End 'if'
              ) ;; End 'else'
            ) ;; End 'if'
          ) ;; End 'else'
        ) ;; End 'if'
      ) ;; End 'else'
    ) ;; End 'if'
    (i32.const 48)  ;; Literal string "white"
    (call $setStrokeColor)  ;; Call function LineColor
    (i32.const 54)  ;; Literal string "blue"
    (call $setFillColor)  ;; Call function FillColor
    (i32.const 2)  ;; Literal value
    (call $setLineWidth)  ;; Call function LineWidth
    (global.get $var0)
    (i32.const 10)  ;; Literal value
    (i32.div_s)
    (global.get $var1)
    (i32.const 10)  ;; Literal value
    (i32.div_s)
    (global.get $var2)
    (i32.const 10)  ;; Literal value
    (i32.div_s)
    (call $drawCircle)  ;; Call function Circle
    (i32.const 48)  ;; Literal string "white"
    (call $setStrokeColor)  ;; Call function LineColor
    (i32.const 59)  ;; Literal string "red"
    (call $setFillColor)  ;; Call function FillColor
    (i32.const 1)  ;; Literal value
    (call $setLineWidth)  ;; Call function LineWidth
    (global.get $var4)
    (i32.const 10)  ;; Literal value
    (i32.div_s)
    (global.get $var5)
    (i32.const 10)  ;; Literal value
    (i32.div_s)
    (global.get $var6)
    (i32.const 10)  ;; Literal value
    (i32.div_s)
    (call $drawCircle)  ;; Call function Circle
    (global.get $var8)
    (i32.const 10)  ;; Literal value
    (i32.div_s)
    (global.get $var9)
    (i32.const 10)  ;; Literal value
    (i32.div_s)
    (global.get $var10)
    (i32.const 10)  ;; Literal value
    (i32.div_s)
    (call $drawCircle)  ;; Call function Circle
    (global.get $var12)
    (i32.const 10)  ;; Literal value
    (i32.div_s)
    (global.get $var13)
    (i32.const 10)  ;; Literal value
    (i32.div_s)
    (global.get $var14)
    (i32.const 10)  ;; Literal value
    (i32.div_s)
    (call $drawCircle)  ;; Call function Circle
    (global.get $var16)
    (i32.const 10)  ;; Literal value
    (i32.div_s)
    (global.get $var17)
    (i32.const 10)  ;; Literal value
    (i32.div_s)
    (global.get $var18)
    (i32.const 10)  ;; Literal value
    (i32.div_s)
    (call $drawCircle)  ;; Call function Circle
    ;; == If Condition ==
    (global.get $var40)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (i32.const 1)  ;; Literal value
        (global.set $var74)
        (i32.const 0)  ;; Literal string "black"
        (call $setFillColor)  ;; Call function FillColor
        (i32.const 48)  ;; Literal string "white"
        (call $setStrokeColor)  ;; Call function LineColor
        (i32.const 5)  ;; Literal value
        (call $setLineWidth)  ;; Call function LineWidth
        (i32.const 180)  ;; Literal value
        (i32.const 30)  ;; Literal value
        (i32.const 240)  ;; Literal value
        (i32.const 60)  ;; Literal value
        (call $drawRect)  ;; Call function Rect
        (i32.const 63)  ;; Literal string "yellow"
        (call $setFillColor)  ;; Call function FillColor
        (i32.const 190)  ;; Literal value
        (i32.const 40)  ;; Literal value
        (i32.const 50)  ;; Literal value
        (i32.const 70)  ;; Literal string "You Win!"
        (call $drawText)  ;; Call function Text
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == Generate return code ==
    (i32.const 0)  ;; Literal value
    (return)
  )
  (func $Fun5 (param $var91 f64) (result i32)
    (local $var92 i32) ;; Declare var 'old_x'
    (local $var93 i32) ;; Declare var 'old_y'
    ;; == If Condition ==
    (global.get $var74)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; == Generate return code ==
        (i32.const 0)  ;; Literal value
        (return)
      ) ;; End 'then'
    ) ;; End 'if'
    ;; Calculate RHS for assignment.
    (global.get $var4)
    (local.set $var92)  ;; Set variable 'old_x'
    ;; Calculate RHS for assignment.
    (global.get $var5)
    (local.set $var93)  ;; Set variable 'old_y'
    ;; == If Condition ==
    (global.get $var4)
    (global.get $var0)
    (i32.lt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (global.get $var4)
        (i32.const 2)  ;; Literal value
        (i32.add)
        (global.set $var4)
      ) ;; End 'then'
      (else ;; 'else' block
        ;; Calculate RHS for assignment.
        (global.get $var4)
        (i32.const 2)  ;; Literal value
        (i32.sub)
        (global.set $var4)
      ) ;; End 'else'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var5)
    (global.get $var1)
    (i32.lt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (global.get $var5)
        (i32.const 2)  ;; Literal value
        (i32.add)
        (global.set $var5)
      ) ;; End 'then'
      (else ;; 'else' block
        ;; Calculate RHS for assignment.
        (global.get $var5)
        (i32.const 2)  ;; Literal value
        (i32.sub)
        (global.set $var5)
      ) ;; End 'else'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var0)
    (global.get $var1)
    (global.get $var2)
    (global.get $var4)
    (global.get $var5)
    (global.get $var6)
    (call $Fun3)  ;; Call function TestCollide
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        (call $Fun1)  ;; Call function Reset
        (drop) ;; Result not used.
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var20)
    (global.get $var21)
    (global.get $var22)
    (global.get $var4)
    (global.get $var5)
    (global.get $var6)
    (call $Fun3)  ;; Call function TestCollide
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (local.get $var92)  ;; Variable 'old_x'
        (global.set $var4)
        ;; Calculate RHS for assignment.
        (local.get $var93)  ;; Variable 'old_y'
        (global.set $var5)
      ) ;; End 'then'
    ) ;; End 'if'
    ;; Calculate RHS for assignment.
    (global.get $var8)
    (local.set $var92)  ;; Set variable 'old_x'
    ;; Calculate RHS for assignment.
    (global.get $var9)
    (local.set $var93)  ;; Set variable 'old_y'
    ;; == If Condition ==
    (global.get $var8)
    (global.get $var0)
    (i32.lt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (global.get $var8)
        (i32.const 3)  ;; Literal value
        (i32.add)
        (global.set $var8)
      ) ;; End 'then'
      (else ;; 'else' block
        ;; Calculate RHS for assignment.
        (global.get $var8)
        (i32.const 3)  ;; Literal value
        (i32.sub)
        (global.set $var8)
      ) ;; End 'else'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var9)
    (global.get $var1)
    (i32.lt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (global.get $var9)
        (i32.const 3)  ;; Literal value
        (i32.add)
        (global.set $var9)
      ) ;; End 'then'
      (else ;; 'else' block
        ;; Calculate RHS for assignment.
        (global.get $var9)
        (i32.const 3)  ;; Literal value
        (i32.sub)
        (global.set $var9)
      ) ;; End 'else'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var0)
    (global.get $var1)
    (global.get $var2)
    (global.get $var8)
    (global.get $var9)
    (global.get $var10)
    (call $Fun3)  ;; Call function TestCollide
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        (call $Fun1)  ;; Call function Reset
        (drop) ;; Result not used.
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var20)
    (global.get $var21)
    (global.get $var22)
    (global.get $var8)
    (global.get $var9)
    (global.get $var10)
    (call $Fun3)  ;; Call function TestCollide
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (local.get $var92)  ;; Variable 'old_x'
        (global.set $var8)
        ;; Calculate RHS for assignment.
        (local.get $var93)  ;; Variable 'old_y'
        (global.set $var9)
      ) ;; End 'then'
    ) ;; End 'if'
    ;; Calculate RHS for assignment.
    (global.get $var12)
    (local.set $var92)  ;; Set variable 'old_x'
    ;; Calculate RHS for assignment.
    (global.get $var13)
    (local.set $var93)  ;; Set variable 'old_y'
    ;; == If Condition ==
    (global.get $var12)
    (global.get $var0)
    (i32.lt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (global.get $var12)
        (i32.const 4)  ;; Literal value
        (i32.add)
        (global.set $var12)
      ) ;; End 'then'
      (else ;; 'else' block
        ;; Calculate RHS for assignment.
        (global.get $var12)
        (i32.const 4)  ;; Literal value
        (i32.sub)
        (global.set $var12)
      ) ;; End 'else'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var13)
    (global.get $var1)
    (i32.lt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (global.get $var13)
        (i32.const 4)  ;; Literal value
        (i32.add)
        (global.set $var13)
      ) ;; End 'then'
      (else ;; 'else' block
        ;; Calculate RHS for assignment.
        (global.get $var13)
        (i32.const 4)  ;; Literal value
        (i32.sub)
        (global.set $var13)
      ) ;; End 'else'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var0)
    (global.get $var1)
    (global.get $var2)
    (global.get $var12)
    (global.get $var13)
    (global.get $var14)
    (call $Fun3)  ;; Call function TestCollide
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        (call $Fun1)  ;; Call function Reset
        (drop) ;; Result not used.
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var20)
    (global.get $var21)
    (global.get $var22)
    (global.get $var12)
    (global.get $var13)
    (global.get $var14)
    (call $Fun3)  ;; Call function TestCollide
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (local.get $var92)  ;; Variable 'old_x'
        (global.set $var12)
        ;; Calculate RHS for assignment.
        (local.get $var93)  ;; Variable 'old_y'
        (global.set $var13)
      ) ;; End 'then'
    ) ;; End 'if'
    ;; Calculate RHS for assignment.
    (global.get $var16)
    (local.set $var92)  ;; Set variable 'old_x'
    ;; Calculate RHS for assignment.
    (global.get $var17)
    (local.set $var93)  ;; Set variable 'old_y'
    ;; == If Condition ==
    (global.get $var16)
    (global.get $var0)
    (i32.lt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (global.get $var16)
        (i32.const 5)  ;; Literal value
        (i32.add)
        (global.set $var16)
      ) ;; End 'then'
      (else ;; 'else' block
        ;; Calculate RHS for assignment.
        (global.get $var16)
        (i32.const 5)  ;; Literal value
        (i32.sub)
        (global.set $var16)
      ) ;; End 'else'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var17)
    (global.get $var1)
    (i32.lt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (global.get $var17)
        (i32.const 5)  ;; Literal value
        (i32.add)
        (global.set $var17)
      ) ;; End 'then'
      (else ;; 'else' block
        ;; Calculate RHS for assignment.
        (global.get $var17)
        (i32.const 5)  ;; Literal value
        (i32.sub)
        (global.set $var17)
      ) ;; End 'else'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var0)
    (global.get $var1)
    (global.get $var2)
    (global.get $var16)
    (global.get $var17)
    (global.get $var18)
    (call $Fun3)  ;; Call function TestCollide
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        (call $Fun1)  ;; Call function Reset
        (drop) ;; Result not used.
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var20)
    (global.get $var21)
    (global.get $var22)
    (global.get $var16)
    (global.get $var17)
    (global.get $var18)
    (call $Fun3)  ;; Call function TestCollide
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (local.get $var92)  ;; Variable 'old_x'
        (global.set $var16)
        ;; Calculate RHS for assignment.
        (local.get $var93)  ;; Variable 'old_y'
        (global.set $var17)
      ) ;; End 'then'
    ) ;; End 'if'
    ;; Calculate RHS for assignment.
    (global.get $var0)
    (global.get $var23)
    (i32.add)
    (global.set $var0)
    ;; == If Condition ==
    (global.get $var0)
    (i32.const 0)  ;; Literal value
    (i32.lt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (i32.const 0)  ;; Literal value
        (global.set $var0)
        ;; Calculate RHS for assignment.
        (i32.const 0)  ;; Literal value
        (global.set $var23)
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var0)
    (i32.const 6000)  ;; Literal value
    (i32.gt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (i32.const 6000)  ;; Literal value
        (global.set $var0)
        ;; Calculate RHS for assignment.
        (i32.const 0)  ;; Literal value
        (global.set $var23)
      ) ;; End 'then'
    ) ;; End 'if'
    ;; Calculate RHS for assignment.
    (global.get $var1)
    (global.get $var24)
    (i32.add)
    (global.set $var1)
    ;; == If Condition ==
    (global.get $var1)
    (i32.const 0)  ;; Literal value
    (i32.lt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (i32.const 0)  ;; Literal value
        (global.set $var1)
        ;; Calculate RHS for assignment.
        (i32.const 0)  ;; Literal value
        (global.set $var24)
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var1)
    (i32.const 6000)  ;; Literal value
    (i32.gt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (i32.const 6000)  ;; Literal value
        (global.set $var1)
        ;; Calculate RHS for assignment.
        (i32.const 0)  ;; Literal value
        (global.set $var24)
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var25)
    (i32.eqz)  ;; Do operator '!'
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; == If Condition ==
        (global.get $var0)
        (global.get $var1)
        (global.get $var2)
        (global.get $var41)
        (global.get $var42)
        (global.get $var73)
        (call $Fun3)  ;; Call function TestCollide
        (if ;; Execute code based on result of condition.
          (then ;; 'then' block
            ;; Calculate RHS for assignment.
            (i32.const 1)  ;; Literal value
            (global.set $var25)
          ) ;; End 'then'
        ) ;; End 'if'
      ) ;; End 'then'
      (else ;; 'else' block
        ;; == If Condition ==
        (global.get $var26)
        (i32.eqz)  ;; Do operator '!'
        (if ;; Execute code based on result of condition.
          (then ;; 'then' block
            ;; == If Condition ==
            (global.get $var0)
            (global.get $var1)
            (global.get $var2)
            (global.get $var43)
            (global.get $var44)
            (global.get $var73)
            (call $Fun3)  ;; Call function TestCollide
            (if ;; Execute code based on result of condition.
              (then ;; 'then' block
                ;; Calculate RHS for assignment.
                (i32.const 1)  ;; Literal value
                (global.set $var26)
              ) ;; End 'then'
            ) ;; End 'if'
          ) ;; End 'then'
          (else ;; 'else' block
            ;; == If Condition ==
            (global.get $var27)
            (i32.eqz)  ;; Do operator '!'
            (if ;; Execute code based on result of condition.
              (then ;; 'then' block
                ;; == If Condition ==
                (global.get $var0)
                (global.get $var1)
                (global.get $var2)
                (global.get $var45)
                (global.get $var46)
                (global.get $var73)
                (call $Fun3)  ;; Call function TestCollide
                (if ;; Execute code based on result of condition.
                  (then ;; 'then' block
                    ;; Calculate RHS for assignment.
                    (i32.const 1)  ;; Literal value
                    (global.set $var27)
                  ) ;; End 'then'
                ) ;; End 'if'
              ) ;; End 'then'
              (else ;; 'else' block
                ;; == If Condition ==
                (global.get $var28)
                (i32.eqz)  ;; Do operator '!'
                (if ;; Execute code based on result of condition.
                  (then ;; 'then' block
                    ;; == If Condition ==
                    (global.get $var0)
                    (global.get $var1)
                    (global.get $var2)
                    (global.get $var47)
                    (global.get $var48)
                    (global.get $var73)
                    (call $Fun3)  ;; Call function TestCollide
                    (if ;; Execute code based on result of condition.
                      (then ;; 'then' block
                        ;; Calculate RHS for assignment.
                        (i32.const 1)  ;; Literal value
                        (global.set $var28)
                      ) ;; End 'then'
                    ) ;; End 'if'
                  ) ;; End 'then'
                  (else ;; 'else' block
                    ;; == If Condition ==
                    (global.get $var29)
                    (i32.eqz)  ;; Do operator '!'
                    (if ;; Execute code based on result of condition.
                      (then ;; 'then' block
                        ;; == If Condition ==
                        (global.get $var0)
                        (global.get $var1)
                        (global.get $var2)
                        (global.get $var49)
                        (global.get $var50)
                        (global.get $var73)
                        (call $Fun3)  ;; Call function TestCollide
                        (if ;; Execute code based on result of condition.
                          (then ;; 'then' block
                            ;; Calculate RHS for assignment.
                            (i32.const 1)  ;; Literal value
                            (global.set $var29)
                          ) ;; End 'then'
                        ) ;; End 'if'
                      ) ;; End 'then'
                      (else ;; 'else' block
                        ;; == If Condition ==
                        (global.get $var30)
                        (i32.eqz)  ;; Do operator '!'
                        (if ;; Execute code based on result of condition.
                          (then ;; 'then' block
                            ;; == If Condition ==
                            (global.get $var0)
                            (global.get $var1)
                            (global.get $var2)
                            (global.get $var51)
                            (global.get $var52)
                            (global.get $var73)
                            (call $Fun3)  ;; Call function TestCollide
                            (if ;; Execute code based on result of condition.
                              (then ;; 'then' block
                                ;; Calculate RHS for assignment.
                                (i32.const 1)  ;; Literal value
                                (global.set $var30)
                              ) ;; End 'then'
                            ) ;; End 'if'
                          ) ;; End 'then'
                          (else ;; 'else' block
                            ;; == If Condition ==
                            (global.get $var31)
                            (i32.eqz)  ;; Do operator '!'
                            (if ;; Execute code based on result of condition.
                              (then ;; 'then' block
                                ;; == If Condition ==
                                (global.get $var0)
                                (global.get $var1)
                                (global.get $var2)
                                (global.get $var53)
                                (global.get $var54)
                                (global.get $var73)
                                (call $Fun3)  ;; Call function TestCollide
                                (if ;; Execute code based on result of condition.
                                  (then ;; 'then' block
                                    ;; Calculate RHS for assignment.
                                    (i32.const 1)  ;; Literal value
                                    (global.set $var31)
                                  ) ;; End 'then'
                                ) ;; End 'if'
                              ) ;; End 'then'
                              (else ;; 'else' block
                                ;; == If Condition ==
                                (global.get $var32)
                                (i32.eqz)  ;; Do operator '!'
                                (if ;; Execute code based on result of condition.
                                  (then ;; 'then' block
                                    ;; == If Condition ==
                                    (global.get $var0)
                                    (global.get $var1)
                                    (global.get $var2)
                                    (global.get $var55)
                                    (global.get $var56)
                                    (global.get $var73)
                                    (call $Fun3)  ;; Call function TestCollide
                                    (if ;; Execute code based on result of condition.
                                      (then ;; 'then' block
                                        ;; Calculate RHS for assignment.
                                        (i32.const 1)  ;; Literal value
                                        (global.set $var32)
                                      ) ;; End 'then'
                                    ) ;; End 'if'
                                  ) ;; End 'then'
                                  (else ;; 'else' block
                                    ;; == If Condition ==
                                    (global.get $var33)
                                    (i32.eqz)  ;; Do operator '!'
                                    (if ;; Execute code based on result of condition.
                                      (then ;; 'then' block
                                        ;; == If Condition ==
                                        (global.get $var0)
                                        (global.get $var1)
                                        (global.get $var2)
                                        (global.get $var57)
                                        (global.get $var58)
                                        (global.get $var73)
                                        (call $Fun3)  ;; Call function TestCollide
                                        (if ;; Execute code based on result of condition.
                                          (then ;; 'then' block
                                            ;; Calculate RHS for assignment.
                                            (i32.const 1)  ;; Literal value
                                            (global.set $var33)
                                          ) ;; End 'then'
                                        ) ;; End 'if'
                                      ) ;; End 'then'
                                      (else ;; 'else' block
                                        ;; == If Condition ==
                                        (global.get $var34)
                                        (i32.eqz)  ;; Do operator '!'
                                        (if ;; Execute code based on result of condition.
                                          (then ;; 'then' block
                                            ;; == If Condition ==
                                            (global.get $var0)
                                            (global.get $var1)
                                            (global.get $var2)
                                            (global.get $var59)
                                            (global.get $var60)
                                            (global.get $var73)
                                            (call $Fun3)  ;; Call function TestCollide
                                            (if ;; Execute code based on result of condition.
                                              (then ;; 'then' block
                                                ;; Calculate RHS for assignment.
                                                (i32.const 1)  ;; Literal value
                                                (global.set $var34)
                                              ) ;; End 'then'
                                            ) ;; End 'if'
                                          ) ;; End 'then'
                                          (else ;; 'else' block
                                            ;; == If Condition ==
                                            (global.get $var35)
                                            (i32.eqz)  ;; Do operator '!'
                                            (if ;; Execute code based on result of condition.
                                              (then ;; 'then' block
                                                ;; == If Condition ==
                                                (global.get $var0)
                                                (global.get $var1)
                                                (global.get $var2)
                                                (global.get $var61)
                                                (global.get $var62)
                                                (global.get $var73)
                                                (call $Fun3)  ;; Call function TestCollide
                                                (if ;; Execute code based on result of condition.
                                                  (then ;; 'then' block
                                                    ;; Calculate RHS for assignment.
                                                    (i32.const 1)  ;; Literal value
                                                    (global.set $var35)
                                                  ) ;; End 'then'
                                                ) ;; End 'if'
                                              ) ;; End 'then'
                                              (else ;; 'else' block
                                                ;; == If Condition ==
                                                (global.get $var36)
                                                (i32.eqz)  ;; Do operator '!'
                                                (if ;; Execute code based on result of condition.
                                                  (then ;; 'then' block
                                                    ;; == If Condition ==
                                                    (global.get $var0)
                                                    (global.get $var1)
                                                    (global.get $var2)
                                                    (global.get $var63)
                                                    (global.get $var64)
                                                    (global.get $var73)
                                                    (call $Fun3)  ;; Call function TestCollide
                                                    (if ;; Execute code based on result of condition.
                                                      (then ;; 'then' block
                                                        ;; Calculate RHS for assignment.
                                                        (i32.const 1)  ;; Literal value
                                                        (global.set $var36)
                                                      ) ;; End 'then'
                                                    ) ;; End 'if'
                                                  ) ;; End 'then'
                                                  (else ;; 'else' block
                                                    ;; == If Condition ==
                                                    (global.get $var37)
                                                    (i32.eqz)  ;; Do operator '!'
                                                    (if ;; Execute code based on result of condition.
                                                      (then ;; 'then' block
                                                        ;; == If Condition ==
                                                        (global.get $var0)
                                                        (global.get $var1)
                                                        (global.get $var2)
                                                        (global.get $var65)
                                                        (global.get $var66)
                                                        (global.get $var73)
                                                        (call $Fun3)  ;; Call function TestCollide
                                                        (if ;; Execute code based on result of condition.
                                                          (then ;; 'then' block
                                                            ;; Calculate RHS for assignment.
                                                            (i32.const 1)  ;; Literal value
                                                            (global.set $var37)
                                                          ) ;; End 'then'
                                                        ) ;; End 'if'
                                                      ) ;; End 'then'
                                                      (else ;; 'else' block
                                                        ;; == If Condition ==
                                                        (global.get $var38)
                                                        (i32.eqz)  ;; Do operator '!'
                                                        (if ;; Execute code based on result of condition.
                                                          (then ;; 'then' block
                                                            ;; == If Condition ==
                                                            (global.get $var0)
                                                            (global.get $var1)
                                                            (global.get $var2)
                                                            (global.get $var67)
                                                            (global.get $var68)
                                                            (global.get $var73)
                                                            (call $Fun3)  ;; Call function TestCollide
                                                            (if ;; Execute code based on result of condition.
                                                              (then ;; 'then' block
                                                                ;; Calculate RHS for assignment.
                                                                (i32.const 1)  ;; Literal value
                                                                (global.set $var38)
                                                              ) ;; End 'then'
                                                            ) ;; End 'if'
                                                          ) ;; End 'then'
                                                          (else ;; 'else' block
                                                            ;; == If Condition ==
                                                            (global.get $var39)
                                                            (i32.eqz)  ;; Do operator '!'
                                                            (if ;; Execute code based on result of condition.
                                                              (then ;; 'then' block
                                                                ;; == If Condition ==
                                                                (global.get $var0)
                                                                (global.get $var1)
                                                                (global.get $var2)
                                                                (global.get $var69)
                                                                (global.get $var70)
                                                                (global.get $var73)
                                                                (call $Fun3)  ;; Call function TestCollide
                                                                (if ;; Execute code based on result of condition.
                                                                  (then ;; 'then' block
                                                                    ;; Calculate RHS for assignment.
                                                                    (i32.const 1)  ;; Literal value
                                                                    (global.set $var39)
                                                                  ) ;; End 'then'
                                                                ) ;; End 'if'
                                                              ) ;; End 'then'
                                                              (else ;; 'else' block
                                                                ;; == If Condition ==
                                                                (global.get $var40)
                                                                (i32.eqz)  ;; Do operator '!'
                                                                (if ;; Execute code based on result of condition.
                                                                  (then ;; 'then' block
                                                                    ;; == If Condition ==
                                                                    (global.get $var0)
                                                                    (global.get $var1)
                                                                    (global.get $var2)
                                                                    (global.get $var71)
                                                                    (global.get $var72)
                                                                    (global.get $var73)
                                                                    (call $Fun3)  ;; Call function TestCollide
                                                                    (if ;; Execute code based on result of condition.
                                                                      (then ;; 'then' block
                                                                        ;; Calculate RHS for assignment.
                                                                        (i32.const 1)  ;; Literal value
                                                                        (global.set $var40)
                                                                      ) ;; End 'then'
                                                                    ) ;; End 'if'
                                                                  ) ;; End 'then'
                                                                ) ;; End 'if'
                                                              ) ;; End 'else'
                                                            ) ;; End 'if'
                                                          ) ;; End 'else'
                                                        ) ;; End 'if'
                                                      ) ;; End 'else'
                                                    ) ;; End 'if'
                                                  ) ;; End 'else'
                                                ) ;; End 'if'
                                              ) ;; End 'else'
                                            ) ;; End 'if'
                                          ) ;; End 'else'
                                        ) ;; End 'if'
                                      ) ;; End 'else'
                                    ) ;; End 'if'
                                  ) ;; End 'else'
                                ) ;; End 'if'
                              ) ;; End 'else'
                            ) ;; End 'if'
                          ) ;; End 'else'
                        ) ;; End 'if'
                      ) ;; End 'else'
                    ) ;; End 'if'
                  ) ;; End 'else'
                ) ;; End 'if'
              ) ;; End 'else'
            ) ;; End 'if'
          ) ;; End 'else'
        ) ;; End 'if'
      ) ;; End 'else'
    ) ;; End 'if'
    ;; == If Condition ==
    (global.get $var22)
    (i32.const 0)  ;; Literal value
    (i32.gt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (global.get $var22)
        (i32.const 1)  ;; Literal value
        (i32.sub)
        (global.set $var22)
      ) ;; End 'then'
    ) ;; End 'if'
    (call $Fun4)  ;; Call function DrawBoard
    (drop) ;; Result not used.
    ;; == Generate return code ==
    (i32.const 0)  ;; Literal value
    (return)
  )
  (func $Fun6 (result i32)
    ;; Calculate RHS for assignment.
    (global.get $var24)
    (global.get $var3)
    (i32.sub)
    (global.set $var24)
    ;; == If Condition ==
    (global.get $var24)
    (global.get $var3)
    (i32.const -1)  ;; Setup negation.
    (i32.mul)       ;; Perform unary minus ('-')
    (i32.lt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (global.get $var3)
        (i32.const -1)  ;; Setup negation.
        (i32.mul)       ;; Perform unary minus ('-')
        (global.set $var24)
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == Generate return code ==
    (i32.const 0)  ;; Literal value
    (return)
  )
  (func $Fun7 (result i32)
    ;; Calculate RHS for assignment.
    (global.get $var24)
    (global.get $var3)
    (i32.add)
    (global.set $var24)
    ;; == If Condition ==
    (global.get $var24)
    (global.get $var3)
    (i32.gt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (global.get $var3)
        (global.set $var24)
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == Generate return code ==
    (i32.const 0)  ;; Literal value
    (return)
  )
  (func $Fun8 (result i32)
    ;; Calculate RHS for assignment.
    (global.get $var23)
    (global.get $var3)
    (i32.sub)
    (global.set $var23)
    ;; == If Condition ==
    (global.get $var23)
    (global.get $var3)
    (i32.const -1)  ;; Setup negation.
    (i32.mul)       ;; Perform unary minus ('-')
    (i32.lt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (global.get $var3)
        (i32.const -1)  ;; Setup negation.
        (i32.mul)       ;; Perform unary minus ('-')
        (global.set $var23)
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == Generate return code ==
    (i32.const 0)  ;; Literal value
    (return)
  )
  (func $Fun9 (result i32)
    ;; Calculate RHS for assignment.
    (global.get $var23)
    (global.get $var3)
    (i32.add)
    (global.set $var23)
    ;; == If Condition ==
    (global.get $var23)
    (global.get $var3)
    (i32.gt_s)
    (if ;; Execute code based on result of condition.
      (then ;; 'then' block
        ;; Calculate RHS for assignment.
        (global.get $var3)
        (global.set $var23)
      ) ;; End 'then'
    ) ;; End 'if'
    ;; == Generate return code ==
    (i32.const 0)  ;; Literal value
    (return)
  )
  (func $Fun10 (result i32)
    (i32.const 79)  ;; Literal string "Test: Continuous Animation"
    (call $setTitle)  ;; Call function SetTitle
    (call $Fun1)  ;; Call function Reset
    (drop) ;; Result not used.
    (call $Fun4)  ;; Call function DrawBoard
    (drop) ;; Result not used.
    (i32.const 106)  ;; Literal string "s"
    (i32.const 108)  ;; Literal string "ActivateShield"
    (call $addKeyTrigger)  ;; Call function AddKeypress
    (i32.const 123)  ;; Literal string "ArrowUp"
    (i32.const 131)  ;; Literal string "KeyUp"
    (call $addKeyTrigger)  ;; Call function AddKeypress
    (i32.const 137)  ;; Literal string "ArrowLeft"
    (i32.const 147)  ;; Literal string "KeyLeft"
    (call $addKeyTrigger)  ;; Call function AddKeypress
    (i32.const 155)  ;; Literal string "ArrowDown"
    (i32.const 165)  ;; Literal string "KeyDown"
    (call $addKeyTrigger)  ;; Call function AddKeypress
    (i32.const 173)  ;; Literal string "ArrowRight"
    (i32.const 184)  ;; Literal string "KeyRight"
    (call $addKeyTrigger)  ;; Call function AddKeypress
    (i32.const 193)  ;; Literal string "UpdateBoard"
    (call $addAnimFun)  ;; Call function AddAnimFun
    ;; == Generate return code ==
    (i32.const 0)  ;; Literal value
    (return)
  )

  (export "ActivateShield" (func $Fun0))
  (export "Reset" (func $Fun1))
  (export "TestInRange" (func $Fun2))
  (export "TestCollide" (func $Fun3))
  (export "DrawBoard" (func $Fun4))
  (export "UpdateBoard" (func $Fun5))
  (export "KeyUp" (func $Fun6))
  (export "KeyDown" (func $Fun7))
  (export "KeyLeft" (func $Fun8))
  (export "KeyRight" (func $Fun9))
  (export "Main" (func $Fun10))
) ;; End module
