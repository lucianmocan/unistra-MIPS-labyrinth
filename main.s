

.data

space: .asciiz " "
new_line: .asciiz "\n"
err_mess: .asciiz "Missing argument. Please provide an integer N." 

.text

# $s0 holds N's value 
#

main:		  

# in cmd_line_args: $a0 is the argument count
#		            $a1 is the address of array containing pointers to null-terminated argument strings
# reference: https://courses.missouristate.edu/kenvollmar/mars/Help/Help_4_1/MarsHelpCommand.html
cmd_line_args: beqz $a0 exit_err_args     # if no arguments then display error message and exit
	       la $t0 0($a1)	              # the pointer to the string -> $t0	        
	       lw $a0 0($t0)		          # the string -> $a0
	       jal string_to_int	          # string to integer (char*) $a0 -> (int) $v0
	       move $s0, $a0		          # saves N's value -> $s0	
	       move $a0, $v0		  
	       li $v0, 1
	       syscall			              # displays N's value

exit: li $v0, 10			 
      syscall				              # terminates execution
      
exit_err_args:  la $a0, err_mess	  
	   	li $v0, 4
	   	syscall			                  # displays error message
	   	la $a0, new_line
	   	li $v0, 4  
	   	syscall
	   	b exit
      
string_to_int:
#prologue
addi $sp $sp -8
sw $ra 0($sp)
sw $a0 4($sp) 	# the string input
#corps  			      
li $t1, -1      # count digits in string $a0 -> $t1 
		        # used later in pow_10, thus $t1 -> $t1 - 1 because 10^0 = 1 and so on
lb $t2, 0($a0)	# first byte from the right of the string (in MIPS strings are stored backwards)
count_digits: beq $t2 $zero end_count_digits  # tests if the current char/byte is equal to the null terminator (0)
	      addi $t1 $t1 1
	      addi $a0 $a0 1
	      lb $t2, 0($a0)
	      b count_digits
end_count_digits:  # $t1 contains the powers of 10 necessary for the conversion
lw $a0 4($sp)	   # restores the string in $a0
lb $t2, 0($a0)	   # the first byte/char of the string, the ASCII value of the digit -> $t2 
li $t0, 0  	       # used to get the right correspondance between the powers because of the backwards storage of a string in MIPS
li $t4, 0	       # initialization at 0, the final number is going to be found in $t4
for_i_string: beq $t2 $zero end_i_string     # tests if the current char/byte is equal to the null terminator (0)
	      addi $t2, $t2 -48		             # this substraction gives the corresponding integer value of the current digit 0 = 48 in ASCII		
	      sub $t6, $t1, $t0		             # substraction to get the right power of 10 -> $t6
	      move $a1, $t6 		             # copies from $t6 the right power of 10 for the function call (jal pow_10) -> $a1 
	      jal pow_10		                 # a power of 10, more exactly 10^($a1) -> $v0
	      mul $t5 $t2 $v0		             # multiplies the current digit with a certain power of 10 ($v0) -> $t5
	      add $t4, $t4, $t5		             # adds the correct value of the current digit to the final number -> $t4
	      addi $t0, $t0, 1		             # the next power of 10 -> $t0
	      addi $a0, $a0, 1		             # forwards to the following byte/char -> $a0
	      lb $t2 0($a0)		                 # sets the new current ASCII value
	      b for_i_string		             # loops
end_i_string: move $v0, $t4		             # final result -> $v0
#epilogue
lw $a0 4($sp)
lw $ra 0($sp)
addi $sp $sp 8
jr $ra
	   		   		   		   	
pow_10:             # fonction returning a certain power of 10 given n
#prologue
addi $sp $sp -8 
sw $ra 0($sp) 
sw $a1 4($sp) 		# n - an integer representing the power that has to be calculated
#corps
li $v0 1 
pow_10_loop:	beqz $a1 fin_pow_10
		mul $v0 $v0 10
		addi $a1 $a1 -1 
		b pow_10_loop
#epilogue
fin_pow_10:
lw $ra 0($sp)
lw $a1 4($sp)
addi $sp $sp 8
jr $ra

