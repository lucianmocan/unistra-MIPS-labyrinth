.data

space: .asciiz " "
new_line: .asciiz "\n"
err_mess: .asciiz "Missing argument. Please provide an integer N." 

.text

# $s0 holds N's value 
# $s1 holds N*N's value

main:		  

# in cmd_line_args: $a0 is the argument count
#		            $a1 is the address of array containing pointers to null-terminated argument strings
# reference: https://courses.missouristate.edu/kenvollmar/mars/Help/Help_4_1/MarsHelpCommand.html
cmd_line_args: beqz $a0 exit_err_args     # if no arguments then display error message and exit
	       la $t0 0($a1)	              # the pointer to the string -> $t0	        
	       lw $a0 0($t0)		          # the string -> $a0
	       jal string_to_int	          # string to integer (char*) $a0 -> (int) $v0
	       move $s0, $v0		          # saves N's value -> $s0	
	       move $a0, $v0		  
	       li $v0, 1
	       syscall			              # displays N's value
	       la $a0, new_line
	       li $v0, 4
	       syscall		
						
jal creer_laby                            # function that follows the algorithm described in section 2 and displays the final labyrinth
	
exit: li $v0, 10			 
      syscall				              # terminates execution
      
exit_err_args:  la $a0, err_mess	  
	   	li $v0, 4
	   	syscall			                  # displays error message if no variable is given in the command line
	   	la $a0, new_line
	   	li $v0, 4  
	   	syscall
	   	b exit

      
          
creer_laby:
#prologue
addi $sp $sp -4
sw $ra 0($sp)


#corps
mul $s1 $s0 $s0 # we save in $s1 for utility the value of N*N -> $s1
jal init_laby   # creates an array where all of the integers'  4 least significant bits are set to 1
	            # returns the address of the first integer in the array-> $v0

move $s2 $v0    # address of the array representing the labyrinth -> $s2
li $s3 1        # index of the current cell -> $s3

move $a0 $s1    
li $v0 9 
syscall         # allocates $s1 * bytes in memory and returns the address of the first byte -> $v0

move $s4 $v0    # the stack's address (adresse de la pile de cellules) -> $s4
move $a0 $s2    # arg function cell_visit $a0 contains the labyrinth's address
move $a1 $s3    # arg function cell_visit $a1 contains the index of cell to be visited
jal cell_visit  # visits the cell c0
sw $s3 0($s4)   # pushes on the stack the index of the cell c0 (empile de la cellule c0) 
loop_main:
	move $a0 $s4               # arg function st_est_vide $a0 contains the stack's address (l'adresse de la pile de cellules)
	jal st_est_vide 		   # returns 1 if the stack is empty, else 0
	move $t0 $v0 			   # contains 1 if the stack is empty, else 0 
	beq $t0 1 fin_creer_laby   # checks if the stack is empty (teste si la pile est vide) 
	move $a0 $s2 			   # arg function lab_visited_neighbours -> $a0 - the labyrinth's address
	move $a1 $s3 			   # arg function lab_visited_neighbours -> $a1 - the index of the current cell
	jal lab_visited_neighbours # function that returns the address of an array containing the neighbours that can be visited -> $v0
	move $t6 $v0 			   # $t6 - non-visited neighbour cells
	move $a0 $v0 			
	jal st_est_vide_taille	   # verify if non-visited neighbour cells exist, returns the number of available neighbours -> $v0
	bnez $v0 voisin_non_visite # if no available neighbour continue, else jump to voisin_non_visite
	move $a0, $s4			   
	jal st_depiler			   # pop of the top of the stack (removes the last item of the stack)
	move $a1, $s1
	jal st_sommet			   # returns the index of the cell before the current one (c') -> $v0
	add $s3 $zero $v0		   # make c' the current cell
	b loop_main
voisin_non_visite:
	move $a0 $t6               # arg function cell_au_hasard (random) $a0 - address of the array containing the available neighbour cells
	jal cell_au_hasard		   # returns the index of a cell chosen at random -> $v0
	move $s7 $v0 			   # index of the neighbour chosen cell -> $s7 
	# savoir si la cellule voisine est en haut, en bas, a gauche, a droite
	move $a1 $s3 			   # arg function neighbour_position $a1 contains the index of the current cell
	move $a2 $s7 			   # arg function neighbour_position $a2 contains the index of the neighbour cell
	jal neighbour_position 	   # returns the binary digit (le bit) that has to be changed to 0 
	move $a0 $v0				
	move $a1 $s2
	move $a2 $s3
	jal cell_i_data			   # returns the value of the cell at index i ($a2) in the labyrinth ($a1) (in this case the current cell)
	move $a1 $v0			
	jal cell_mettre_bit_a_0    # returns an integer where the corresponding binary digit ($a0) is at 0 (met le bit indique par $a0 a 0)
	move $a0 $v0
	move $a1 $s2
	move $a2 $s3
	jal cell_i_update 		   # updates the value of the current cell in the actual labyrinth (met a jour la cellule courante)
	move $a1 $s7			   # arg function neighbour_position $a1 contains the index of the neighbour cell
	move $a2 $s3			   # arg function neighbour_position $a2 contains the index of the current cell
	jal neighbour_position 	   # returns the binary digit (le bit) that has to be changed to 0 (donne le bit de la cellule voisine a mettre a 0)
	move $a0 $v0
	move $a1, $s2
	move $a2, $s7
	jal cell_i_data			   # returns the value of the cell at index i ($a2) in the labyrinth ($a1) (in this case the neighbour cell)
	move $a1, $v0
	jal cell_mettre_bit_a_0    # returns an integer where the corresponding binary digit ($a0) is at 0 (met le bit indique par $a0 a 0)
	move $a0, $v0
	move $a1, $s2
	move $a2, $s7
	jal cell_i_update		   # updates the value of the neighbour cell in the actual labyrinth (met a jour la cellule voisine)
	move $s3 $s7			   # make of the neighbour cell c', the current cell (faire de c' la cellule courante)
	move $a0, $s2			   # arg function cell_visit $a0 contains the labyrinth's address -> $s2 (labyrinth)
	move $a1, $s3			   # arg function cell_visit $a1 contains the index of cell to be visited -> c'
	jal cell_visit			   # visits the cell c' (marquer c' comme visitee)
	move $a1, $s3
	move $a0, $s4
	jal st_empiler			   # push c' on the stack (mettre c' au sommet de la pile)				
j loop_main	
	

fin_creer_laby: move $a1, $s2   		 # we want to mark the first cell as the departure point
				li $a2, 1				 # the cell is of index 1
				jal cell_i_data 		 # returns the value of the cell at index 1 ($a2) in the labyrinth ($a1)
				move $a1, $v0   		 # the value of the cell -> $a1
				li $a0, 5				 # the 5th bit is the departure bit (B5)
				jal cell_mettre_bit_a_1  # returns the value of the cell where the 5th bit == 1
				move $a0, $v0   		 # the new value of the cell -> $a0
				move $a1, $s2			 # the labyrinth's address  -> $a1
				li $a2, 1				 # the index of the cell = 1 -> $a2
				jal cell_i_update        # updates the cell in the labyrinth
		
				move $a1, $s2			 # we want to mark the last cell as the end point; labyrinth's address -> $a1
				move $a2, $s1			 # the cell is of index N*N -> $a2
				jal cell_i_data			 # returns the value of the cell at index N*N ($a2) in the labyrinth ($a1)
				move $a1, $v0			 # the value of the cell -> $a1
				li $a0, 4				 # the 4th bit is the departure bit (B4)
				jal cell_mettre_bit_a_1  # returns the value of the cell where the 4th bit == 1
				move $a0, $v0			 # the new value of the cell -> $a0
				move $a1, $s2			 # the labyrinth's address  -> $a1
				move $a2, $s1		     # the index of the cell = N*N -> $a2
				jal cell_i_update		 # updates the cell in the labyrinth


move $a1 $s2      						 # the address of the labyrinth -> $a1
jal affiche_laby						 # displays the labyrinth (the array of integers)

#epilogue
lw $ra 0($sp)
addi $sp $sp 4
jr $ra                            
                        

neighbour_position:
#prologue
addi $sp $sp -12
sw $ra 0($sp)
sw $a1 4($sp) # index of the current cell
sw $a2 8($sp) # index of the neighbour cell
#corps
addi $a1 $a1 -1  # decrement by -1 for the move back -> $a1 ; because in our arrays 0 means nothing, so everything is +1
addi $a2 $a2 -1	 # decrement by -1 for the move back -> $a1
sub $t0 $a2 $a1  # substract to later check if the neighbour is on on top or on bottom -> $t0
abs $t1 $t0 	 # absolute value of $t0 -> $t1 ; useful for the up_or_bottom 				
beq $t1 $s0 up_or_bottom 			# if the distance between the 2 index is N then that means it's either above or under
blt $a1 $a2 right					# if the current index is smaller than the neighbour's then the neighbour is on the right
li $v0, 3 							# else wall on the left
b end_neighbour_position
right:  li $v0, 1 					# wall on the right
	b end_neighbour_position
up_or_bottom: bgt $a1 $a2 up		# if the current index is greater than the neighbour's then the neighbour is on top
	      li $v0, 2 				# else wall on the bottom
	      b end_neighbour_position
up: li $v0, 0						# wall on top
end_neighbour_position:
#epilogue
lw $ra 0($sp) 
lw $a1 4($sp)
lw $a2 8($sp)                               
addi $sp $sp 12
jr $ra

                                                                                                                                                                                                                                                                                                                                                                                                                        
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

init_laby:
#prologue
addi $sp, $sp, -4
sw $ra, 0($sp) 
#corps
move $t3, $s1 	# stores N*N from $s1 (number of integers in the array) -> $t3
move $a0, $s1
jal st_creer 	# allocates in memory N*N * bytes and returns the address of the first cell -> $v0
move $t0 $v0 	# the address of the first cell of the labyrinth array -> $a1
move $t5 $v0 	# saves the array's address for the return
li $t2, 15 		# in binary 15 (F) = 0000 1111 for 4 walls of a cell
li $t1 0 		# $t1 counter for the loop for_init_laby
for_init_laby:  beq $t1 $t3 fin_init_laby # loops while not reaching the end of the array
		 sw $t2 0($t0)  				  # stores 15 at the given address (meaning a 4-walls-cell)
		 addi $t1 $t1 1					  # counter $t1++
		 addi $t0 $t0 4					  # address forwarding $t0 + 4
		 b for_init_laby
fin_init_laby:  move $v0 $t5              # return the address of the labyrinth -> $v0
#epilogue
lw $ra 0($sp)
addi $sp $sp 4
jr $ra

affiche_laby:
#prologue
addi $sp $sp -12
sw $ra 0($sp)
sw $a0 4($sp)
sw $a1 8($sp)     # contains the address of the array
#corps
move $t2, $s0     # initialize $t2 with N
li $t0, 0		  # counter set at 0 -> $t0
for_i_affiche_laby: beq $t0 $t2 fin_affiche_laby # display line by line
		    li $t1, 0 							 # counter set at 0 for every column on the line $t0 -> $t1
		    for_j_affiche_laby: beq $t1 $t2 fin_for_j_affiche_laby
		  		        lw $a0 0($a1)
		  		        li $v0, 1
		  		        syscall 				 # displays the integer at $a1[$t0][$t1]
		  		        la $a0 space
		  		        li $v0, 4
		  		        syscall					 # displays a space
		  		        addi $t1 $t1 1			 # column counter increment +1
		  		        addi $a1 $a1 4			 # address forwarding $a1 + 4 (go to the next cell)
		  		        b for_j_affiche_laby
	        fin_for_j_affiche_laby: addi $t0 $t0 1
	      	  		        la $a0 new_line      
	      			        li $v0, 4
	      			        syscall				 # displays \n (switch to the next line)
	      			        b for_i_affiche_laby
fin_affiche_laby:
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
addi $sp $sp 12
jr $ra

cell_i_update:
#prologue
addi $sp $sp -16
sw $ra 0($sp)
sw $a0 4($sp)     # the new value
sw $a1 8($sp) 	  # the labyrinth's address
sw $a2 12($sp)    # index of the cell
#corps
addi $t0 $a2 -1   # decrement by -1 for the move back -> $a1 ; because in our arrays 0 means nothing, so everything is +1
mul $t0 $t0 4     # index * 4 bytes (integer's coding)
add $a1 $a1 $t0   # the address of the cell of index $a2 -> $a1
sw $a0 0($a1)	  # update the value of the cell with the value in $a0 -> 0($a1)
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
lw $a2 12($sp)
addi $sp $sp 16
jr $ra

cell_i_data:
#prologue
addi $sp $sp -12
sw $ra 0($sp)
sw $a1 4($sp) 	  # the labyrinth's address
sw $a2 8($sp)    # index of the cell
#corps
addi $t0 $a2 -1	  # decrement by -1 for the move back -> $a1 ; because in our arrays 0 means nothing, so everything is +1
mul $t0 $t0 4	  # index * 4 bytes (integer's coding)
add $a1 $a1 $t0   # the address of the cell of index $a2 -> $a1
lw $v0 0($a1)	  # load the value of the cell at 0($a1) -> $v0
#epilogue
lw $ra 0($sp)
lw $a1 4($sp)
lw $a2 8($sp)
addi $sp $sp 12
jr $ra

st_creer:
#prologue
addi $sp $sp -8
sw $ra 0($sp)
sw $a0 4($sp) 	# the size of the array n 
#corps
mul $a0 $a0 4 	# integer coding on 4 bytes; total number of bytes $a0 * 4 -> $a0 
li $v0, 9 		# allocates on the heap $a0 * bytes, first address -> $v0
syscall
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
addi $sp $sp 8
jr $ra

cell_est_visite:
#prologue
addi $sp $sp -12
sw $ra 0($sp)
sw $a0 4($sp) 		# labyrinth's address
sw $a1 8($sp) 		# cell index
#corps
addi $a1 $a1 -1		# decrement by -1 for the move back -> $a1 ; because in our arrays 0 means nothing, so everything is +1
mul $a1 $a1 4	    # integer coding on 4 bytes; total number of bytes $a1 * 4 -> $a1 
add $t0 $a0 $a1 	# the address of the cell of index $a1 -> $t0
lw $a1 0($t0)		# load the value of the cell at 0($t0) -> $a1 for the procedure cell_lecture_de_bits call
li $a0, 6 			# the 6th binary digit is the bit marking if a cell is visited or not -> $a0
jal cell_lecture_de_bits # value of the 6th binary digit -> $v0 (if 1 then is visited, 0 if not)
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
addi $sp $sp 12
jr $ra

st_est_vide:
#prologue
addi $sp $sp -8
sw $ra 0($sp)
sw $a0 4($sp)       # the stack's address
#corps
lw $t0 0($a0)		# if the 1st element (0($a0)) is null then the stack is empty -> $t0
beqz $t0 st_vide	# if $t0 is 0 then return 1 -> $v0
li $v0, 0			# else return 0 -> $v0
b fin_st_vide
st_vide: li $v0, 1
fin_st_vide:
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
addi $sp $sp 8
jr $ra

st_est_vide_taille: # knowing that we have at most 4 neighbours and 4 directions
#prologue
addi $sp $sp -8
sw $ra 0($sp)
sw $a0 4($sp)     # the stack's address
#corps
li $t0, 0		  # count for scanning the array
li $t1, 4		  # size of the array is 4
li $t3, 0		  # count of elements that are not zero
vide_loop: beq $t0 $t1 st_vide_taille
	   lw $t2 0($a0)		# the value of the element -> $t2
	   beqz $t2 elem_null	# if $t2 is null we pass to the next element
	   addi $t3 $t3 1		# else $t2 is not null so $t3++
	   elem_null:
	   addi $t0 $t0 1		# counter of the array $t0++
	   addi $a0 $a0 4		# next address -> $a0
	   b vide_loop
st_vide_taille:
move $v0, $t3			    # number of non null elements -> $v0
fin_st_vide_taille:
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
addi $sp $sp 8
jr $ra

lab_visited_neighbours:
#prologue
addi $sp $sp -12
sw $ra 0($sp) 
sw $a0 4($sp) # labyrinth's address (adresse de la premiere cellule)
sw $a1 8($sp) # index of the cell (indice de la cellule)
#corps
move $t3 $a0  # labyrinth's address (adresse de la premiere cellule)
move $a0 $a1  # index of the cell for the function call -> $a0
jal lab_neighbouring_cells # function that returns an array containing all neighbouring cells -> $v0
move $s5 $v0 			   # address of the array containing all neighbouring cells -> $s5

li $t6 4	    # 4 neighbours at max
mul $a0 $t6 $t6 # 4 * 4 bytes per integer
li $v0 9
syscall  		# creation of the array for the return (tableau de retour)
move $s6 $v0    # address of the return array -> $s6


lw $a0 4($sp)   # labyrinth's address (adresse de la premiere cellule)
voisin_haut:
	lw $t1 0($s5)
	beqz $t1 pas_de_voisin_haut # tests if a neighbour exists (test si il y a un voisin) 
		lw $a1 0($s5) 			# index of the neighbour above (indice du voisin du haut)
		jal cell_est_visite
		bnez $v0 pas_de_voisin_haut  
		sw $a1 0($s6) 			# stores the index of the not visited neighbour above (stocke l'indice du voisin en-haut non-visite)
		b voisin_de_gauche
pas_de_voisin_haut:
	sw $zero 0($s6) 			# no neighbour thus 0 (pas de voisin donc 0)

voisin_de_gauche:
	lw $t1 12($s5)
	beqz $t1 pas_de_voisin_gauche # tests if a neighbour exists (test si il y a un voisin)  
		lw $a1 12($s5) 			  # index of the neighbour to the left (indice du voisin de gauche)
		jal cell_est_visite
		bnez $v0 pas_de_voisin_gauche
		sw $a1 12($s6)   		  # stores the index of the not visited neighbour to the left (stocke l'indice du voisin en-haut non-visite)
		b voisin_de_droite
pas_de_voisin_gauche:
	sw $zero 12($s6) 			  # no neighbour thus 0 (pas de voisin donc 0)
voisin_de_droite:
	lw $t1 4($s5)
	beqz $t1 pas_de_voisin_droite # tests if a neighbour exists (test si il y a un voisin) 
		lw $a1 4($s5) 			  # index of the neighbour to the right (indice du voisin de droite)
		jal cell_est_visite
		bnez $v0 pas_de_voisin_droite
		sw $a1 4($s6)  			  # stores 1 if neighbour is visited else 0 (stocke 1 si le voisin a ete visite 0 sinon)
		b voisin_du_bas
pas_de_voisin_droite:
	sw $zero 4($s6) 			  # no neighbour thus 0 (pas de voisin donc 0)
voisin_du_bas: 
	lw $t1 8($s5)
	beqz $t1 pas_de_voisin_bas    # tests if a neighbour exists (test si il y a un voisin) 
		lw $a1 8($s5) 			  # index of the neighbour under (indice du voisin du bas)
		jal cell_est_visite
		bnez $v0 pas_de_voisin_bas
		sw $a1 8($s6) 			  # stores 1 if neighbour is visited else 0 (stocke 1 si le voisin a ete visite 0 sinon)
	b fin_lab_visited_neighbours
pas_de_voisin_bas:
sw $zero 8($s6) 				  # no neighbour thus 0 (pas de voisin donc 0)
fin_lab_visited_neighbours:
move $v0 $s6
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
addi $sp $sp 12
jr $ra



lab_neighbouring_cells:
#prologue
addi $sp $sp -12
sw $ra 0($sp)
sw $a0 4($sp) # labyrinth's address
sw $a1 8($sp) # the cell's index
#corps
li $t6 4
mul $a0 $t6 $t6
li $v0 9
syscall  	 # creation of the array for the return (tableau de retour) 
move $a0 $v0 # address of the return array (adresse du tableau de retour) -> $a0
move $t1, $a0
li $t0, 0
for_init_zero: beq $t0 $t6 fin_init_zero # set all tab elements at 0
	       sw $zero 0($t1)
	       addi $t0 $t0 1
	       addi $t1 $t1 4
	       b for_init_zero
fin_init_zero:
sub $t0 $a1 $s0
neighbour_up: bltz $t0 no_up 			# no neighbour above
	      sw $t0 0($a0)      			# index of cell above $a1 
no_up:
add $t0 $a1 $s0
neighbour_bottom: bgt $t0 $s1 no_bottom # no neighbour under
		  sw $t0 8($a0)		            # index of cell under $a1
no_bottom:
move $t0 $a1 							# saves index value in $t1
addi $t0 $t0 -1							
rem $t1 $t0 $s0							# we want to check if the cell is on the first column
neighbour_left: beq $t1 $zero no_left	# no neighbour to the left
		sw $t0 12($a0)					# index of cell to the left of $a1
no_left:
move $t0 $a1
rem $t1 $t0 $s0							# we want to check if the cell is on the last column
neighbour_right: beq $t1 $zero no_right # no neighbour to the right
		 addi $t0 $a1 1
		 sw $t0 4($a0)					# index of cell to the right of $a1
no_right:
move $v0, $a0	 						# address of array containing the neighbours -> $v0
#epilogue
sw $a1 8($sp)
sw $a0 4($sp)
sw $ra 0($sp)
addi $sp $sp 12
jr $ra

cell_au_hasard:
#prologue
addi $sp $sp -8
sw $ra 0($sp)
sw $a0 4($sp)   # address of array containing the available neighbours
#corps
jal st_est_vide_taille    # the size of the array of neighbours (la taille du tableau des voisins) -> $v0
move $t2, $v0   # stores the array's size (on sauvegarde la taille contenu en $v0) -> $t2
li $a0, 345     # pseudorandom (le pseudorandom) -> $a0
move $a1, $t2   # upper bound (la borne superieure) -> $a1
li $v0, 42      # generating the integer (generation d'un entier): 0 <= [int] < $a1 -> $a0 
syscall
mul $t1, $a0, 4 # stores the result of random int (on sauvegarde le resultat du random int) -> $t1
li $t3, 16
sub $t2 $t3 $t1
lw $a0 4($sp)   # recovers the address of the array of neighbours (on recupere l'adresse du tableau des voisins) -> $a0
add $a0 $a0 $t1 # finds the address of the chosen neighbour (on trouve l'adresse du bon element dans le tableau) -> $a0
lw $v0 0($a0)   # returns the index of the chosen cell (on retourne l'indice de la cellule choisie au hasard)

check_cell: bnez $v0, fin_hasard   # verifies if the chosen cell's index is not 0, 
								   # if so goes to the next index in the array of neighbours
	    bgt $t1 $t3 hasard_restart # if the end of array then go back to the beggining and search until index not zero
	    addi $a0, $a0, 4		   # else load the value of the index in $v0
	    addi $t1, $t1, 4
	    lw $v0 0($a0)
	    b check_cell
	    hasard_restart: sub $a0 $a0 $t1
	    		    add $t1 $zero $zero
	    b check_cell
fin_hasard:
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
addi $sp $sp 8
jr $ra

st_empiler:
#prologue
addi $sp $sp -12
sw $ra 0($sp)
sw $a0 4($sp)   # the stack's address (adresse de la pile)
sw $a1 8($sp)	# element to push (element a empiler)
#corps
loop_st_empiler: # scan of the stack (parcours de la pile)
lw $t0 0($a0) 
beqz $t0 fin_st_empiler # test si $a0 pointe toujours sur un élément non vide de la pile 
addi $a0 $a0 4 			# increments pointer (incrémentation du pointeur) $a0
b loop_st_empiler 
fin_st_empiler:
sw $a1 0($a0) 			# element gets pushed on the stack (empilement)
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
addi $sp $sp 12
jr $ra

st_depiler:
#prologue
addi $sp $sp -8
sw $ra 0($sp)
sw $a0 4($sp)
#corps
loop_st_depiler:
move $t0 $a0 
addi $t0 $t0 4 				# element following $a0 (élément suivant $a0)
lw $t1 0($t0) 				# the value of the element following $a0 (valeur de l'élément suivant $a0)
beqz $t1 fin_st_depiler 	# test the element following $a0 (test de l'élément suivant $a0)
addi $a0 $a0 4 				# $a0 is not the top of the stack thus increment pointer ($a0 n'est pas le sommet donc incrémentation du pointeur)
b loop_st_depiler
fin_st_depiler: 			# $a0 points to the top of the stack ($a0 pointe sur le sommet)
sw $zero 0($a0) 			# pop (dépilement)
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
addi $sp $sp 8
jr $ra 



st_sommet:
#prologue
addi $sp $sp -12
sw $ra 0($sp)
sw $a0 4($sp) # adresse du tableau
sw $a1 8($sp) # nombre d'entiers maximal que le tableau peut contenir
#corps
li $t0, 0
move $t5, $a0 						  # pour faire le parcours du tableau $t5 contient l'adresse courante
for_st_sommet: beq $t0 $a1 stu_sommet # si on atteint la fin du tableau alors on prend le sommet: $t5 -> $t5 - 4
	       lw $t1 0($t5) 			  # la valeur du element courant du tableau -> $t1
	       beqz $t1 stu_sommet 		  # si $t1 == 0, on prend le sommet $t5 -> $t5 - 4
	       addi $t0, $t0, 1 		  # compteur d'elements -> $t0
	       addi $t5, $t5, 4 		  # adresse du element suivant -> $t5
	       b for_st_sommet
stu_sommet: addi $t5 $t5 -4 		  # on revient sur la bonne adresse qui est $t5 -> $t5 - 4
	    lw $v0 0($t5) 				  # on charge la valeur du sommet -> $v0   
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
addi $sp $sp 12
jr $ra


cell_lecture_de_bits:
#prologue
addi $sp $sp -12
sw $ra 0($sp)
sw $a0 4($sp) # position du n-ieme bit -> $a0
sw $a1 8($sp) # l'entier n dont on veut connaitre le n-ieme bit -> $a1
#corps
srlv $t0 $a1 $a0 # obtenir le n-ieme bit en premier bit de poids faible-> $t0
li $t1 1
and $v0 $t0 $t1 # mettre tous les bits a 0 sauf le bit recherché
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
addi $sp $sp 12
jr $ra 


cell_mettre_bit_a_1:
#prologue
addi $sp $sp -12
sw $ra 0($sp)
sw $a0 4($sp) # position du bit qu'on souhaite changer -> $a0
sw $a1 8($sp) # l'entier n dont on veut changer le n-ième bit -> $a1
#corps
jal pow_2 # fonction qui calcule la n($a0)-ième puissance de 2
move $t0 $v0 # puissance de 2, le seul a bit à 1 est le n-ième
or $v0 $a1 $t0  # on met le n($a0)-ième bit à 1 
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
addi $sp $sp 12
jr $ra 


cell_mettre_bit_a_0:
#prologue
addi $sp $sp -12
sw $ra 0($sp)
sw $a0 4($sp) # position du bit qu'on souhaite changer -> $a0
sw $a1 8($sp) # l'entier n dont on veut changer le n-ième bit -> $a1
#corps
jal function_bis # fonction qui retourne un entier ou le seul bit à 0 est le n-ième
and $v0 $v0 $a1 # met le n-ième bit à 0
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
addi $sp $sp 12
jr $ra 

pow_2: #fonction initialisant le n-ime bit  1 
#prologue
addi $sp $sp -8 
sw $ra 0($sp) 
sw $a0 4($sp) #bit  initialiser  1
#corps
li $v0 1 
loop:
beqz $a0 fin_pow_2
mul $v0 $v0 2
addi $a0 $a0 -1 
b loop
#epilogue
fin_pow_2:
lw $ra 0($sp)
lw $a0 4($sp)
addi $sp $sp 8
jr $ra

function_bis: #mettre tout les bits  1 sauf le n-ime 
#prologue
addi $sp $sp -8
sw $ra 0($sp)
sw $a0 4($sp) #bit  mettre  zro 
#corps
li $t0 0
li $t1 0
li $t2 31 
sub $t2 $t2 $a0 
loop_function_bis:
bge $t1 31 fin_function_bis 
sll $t0 $t0 1
addi $t1 $t1 1
beq $t1 $t2 loop_function_bis
addi $t0 $t0 1
b loop_function_bis
fin_function_bis:
move $v0 $t0 
#epilogue 
lw $ra 0($sp)
lw $a0 4($sp)
addi $sp $sp 8
jr $ra 

cell_visit:
#prologue
addi $sp $sp -12
sw $ra 0($sp)
sw $a0 4($sp) # l'adresse du premier element du tableau
sw $a1 8($sp) # indice du cellule (mettre le 6-bit à 1)
#corps
move $t0, $a1
move $a1, $a0
move $a2, $t0
jal cell_i_data
move $a1, $v0
li $a0, 6 # position du bit qu'on veut verifier -> $a0 = 6;
jal cell_mettre_bit_a_1 # nouveau entier avec le 6Ème bit à 1 -> $v0
move $a0, $v0
lw $a1, 4($sp)
lw $a2, 8($sp)
jal cell_i_update
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
addi $sp $sp 12
jr $ra
