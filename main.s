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
		
jal creer_laby
move $s2 $v0 #adresse de la tableau 
li $s3 1 #indice de la cellule courante 
move $a0 $s1 
li $v0 9 
syscall 
move $s4 $v0 #adresse du sommet de la pile de cellule 
move $a0 $s2 
move $a1 $s3 
jal est_visite #visite la cellule c0 
lw $s3 0($s4) #empile de la cellule c0 
loop_main:
	move $a0 $s4 
	jal est_vide 
	move $t0 $v0 #contient 1 si la pile est vide 0 sinon 
	beq $t0 1 #test si la pile est vide 
	move $a0 $s2 
	move $a1 $s3 
	jal lab_visited_neighbours
	move $t1 $v0 #cellules voisines non visitées
	move $a0 $v0 
	jal est_vide
	beqz $v0 voisin_non_visite
	lw $zero 0($s4) #cas où il n'y a pas de cellule voisine non visité 
	subi $s4 $s4 4
	lw $s3 0($s4)
	b loop_main
	voisin_non_visite:
	move $a0 $t1 
	jal cell_au_hasard
	move $t2 $v0 #indice de la cellule voisine 
	#savoir si la cellule voisine est en haut, en bas, a gauche, a droite
	
	




exit: li $v0, 10			 
      syscall				              # terminates execution
      
exit_err_args:  la $a0, err_mess	  
	   	li $v0, 4
	   	syscall			                  # displays error message
	   	la $a0, new_line
	   	li $v0, 4  
	   	syscall
	   	b exit

      
          
creer_laby:
#prologue
addi $sp $sp -8
sw $ra 0($sp)


#corps
mul $s1 $s0 $s0
jal init_laby  # creates an array where all of the integers'  4 least significant bits are set to 1
	       # return the address of the first integer in the array-> $v0
move $a3 $v0   # saves the adress of the array -> $a3






move $a1 $a3
jal affiche_laby

#epilogue
lw $ra 0($sp)
addi $sp $sp 8
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
jal st_creer 	# alloue en mÃ©moire le tableau N*N et retourne l'adresse -> $v0
move $t0 $v0 	# l'adresse du premier element du tableau -> $a1
move $t5 $v0 	# sauvegarder l'adresse du tableau pour le retour
li $t2, 15 	# en binaire 15 (F) = 0000 1111 pour 4 murs autour d'une cellule
li $t1 0 	# $t1 compteur pour la boucle for_init_laby
for_init_laby:  beq $t1 $t3 fin_init_laby
		 sw $t2 0($t0)
		 addi $t1 $t1 1
		 addi $t0 $t0 4
		 b for_init_laby
fin_init_laby:  move $v0 $t5
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
move $t2, $s0
li $t0, 0
for_i_affiche_laby: beq $t0 $t2 fin_affiche_laby
		    li $t1, 0
		    for_j_affiche_laby: beq $t1 $t2 fin_for_j_affiche_laby
		  		        lw $a0 0($a1)
		  		        li $v0, 1
		  		        syscall
		  		        la $a0 space
		  		        li $v0, 4
		  		        syscall
		  		        addi $t1 $t1 1
		  		        addi $a1 $a1 4
		  		        b for_j_affiche_laby
	        fin_for_j_affiche_laby: addi $t0 $t0 1
	      	  		        la $a0 new_line
	      			        li $v0, 4
	      			        syscall
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
sw $a0 4($sp) # valeur Ã  mettre Ã  la place
sw $a1 8($sp) # adresse du premier element du tableau
sw $a2 12($sp) # indice i du cellule
#corps
mul $t0 $a2 4
add $a1 $a1 $t0
sw $a0 0($a1)
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
lw $a2 12($sp)
addi $sp $sp 16
jr $ra

cell_i_data:
#prologue
addi $sp $sp -16
sw $ra 0($sp)
sw $a1 4($sp) # adresse du premier element du tableau
sw $a2 8($sp) # indice i du cellule
sw $a3 12($sp) # indice j du cellule
#corps
mul $t0 $a2 4
add $a1 $a1 $t0
lw $v0 0($a1)
#epilogue
lw $ra 0($sp)
lw $a1 4($sp)
lw $a2 8($sp)
lw $a3 12($sp)
addi $sp $sp 16
jr $

st_creer:
#prologue
addi $sp $sp -8
sw $ra 0($sp)
sw $a0 4($sp)
#corps
mul $a0 $a0 4 	# chaque entier est codÃ© sur 4 octets 
li $v0, 9 	# allocation sur le tas de $a0 * octets, premiere adresse -> $v0
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
sw $a0 4($sp) # contient l'adresse du premier element du tableau
sw $a1 8($sp) # indice de la cellule
#corps
mul $a1 $a1 4
add $t0 $a0 $a1 
lw $a1 0($t0)
li $a0, 6 # position du bit qu'on veut verifier -> $a0
jal cell_lecture_de_bits # valeur du 6 bit -> $v0
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
sw $a0 4($sp)
#corps
lw $t0 0($a0)
beqz $t0 st_vide
li $v0, 0
b fin_st_vide
st_vide: li $v0, 1
fin_st_vide:
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
addi $sp $sp 8
jr $ra

lab_neighbouring_cells:
#prologue  
addi $sp $sp -8
sw $ra 0($sp)
sw $a0 4($sp) #indice de la cellule 
#corps
mul $t0 $s0 $s0 
move $t1 $a0 #transfert de l'indice
li $t6 4
mul $a0 $t6 $t6
li $v0 9
syscall  #cration du tableau de retour 
move $t2 $v0 #traansfert de l'adresse du premier lment du tableau
bne $t1 1 last_cell_test #test si la cellule est la premire 
sw $zero 0($t2) #pas de voisin en-haut 
sw $zero 4($t2) #pas de voisin  gauche
addi $t3 $t1 1
sw $t3 8($t2) #voisin de droite
add $t3 $t1 $s0 
sw $t3 12($t2) #voisin d'en-bas 
b fin_lab_neighbouring_cells
last_cell_test:
bne $t1 $t0 not_first_not_last #test si la cellule est la dernire 
sw $zero 8($t2) #pas de voisin  droite 
sw $zero 12($t2) #pas de voisin en haut 
subi $t3 $t1 1 
sw $t3 4($t2) #voisin de gauche
sub $t3 $t1 $s0 
sw $t3 0($t2) #voisin d'en-haut
b fin_lab_neighbouring_cells
not_first_not_last: #ni la premire cellule ni la dernire 
addi $t3 $t1 1
sw $t3 8($t2) #voisin de droite 
subi $t3 $t1 1
sw $t3 4($t2) #voisin de gauche 
sub $t4 $t0 $s0  
bge $t1 $t4 last_row #test si la cellule est sur la dernire ligne 
add $t3 $t1 $s0 
sw $t3 12($t2) #voisin d'en bas 
sub $t5 $t1 $s0  
ble $t5 $zero first_row #test si la cellule est sur la premire ligne 
sub $t3 $t1 $s0  
sw $t3 0($t2) #voisin d'en-haut
b fin_lab_neighbouring_cells
first_row: #la cellule est sur la premire ligne 
sw $zero 0($t2) #pas de voisin d'en haut 
b fin_lab_neighbouring_cells
last_row: #la cellule est sur la dernire ligne 
sw $zero 12($t2) #pas de voisin en-bas 
sub $t3 $t1 $s0 
sw $t3 0($t2) #voisin du haut 
b fin_lab_neighbouring_cells
fin_lab_neighbouring_cells:
move $v0 $t2 
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
addi $sp $sp 8
jr $ra

lab_visited_neighbours:
addi $sp $sp -12
sw $ra 0($sp) 
sw $a0 4($sp) #adresse du la premire cellule
sw $a1 8($sp) #indice de la cellule 
#corps
move $t3 $a0 #adresse de la premire cellule
move $a0 $a1
jal lab_neighbouring_cells
move $t0 $v0 #adresse du tableau des voisins
li $t6 4
mul $a0 $t6 $t6
li $v0 9
syscall  #cration du tableau de retour
move $t2 $v0 #transfert de l'adresse du tableau de retour
move $t9 $v0 #pointeur
move $a0 $t3 #addresse de la premire cellule
lw $t1 0($t0)
beqz $t1 voisin_de_gauche #test si il y a un voisin 
lw $a1 0($t0) #indice du voisin du haut
jal cell_est_visite
bnez $v0 voisin_de_gauche 
sw $a1 0($t9)
addi $t9 $t9 4
voisin_de_gauche:
lw $t1 4($t0)
beqz $t1 voisin_de_droite #test si il y a un voisin 
lw $a1 4($t0) #indice du voisin de gauche
jal cell_est_visite
bnez $v0 voisin_de_droite
sw $a1 0($t9)
addi $t9 $t9 4
voisin_de_droite:
lw $t1 8($t0)
beqz $t1 voisin_du_bas #test si il y a un voisin 
lw $a1 8($t0) #indice du voisin de droite 
jal cell_est_visite
bnez $v0 voisin_du_bas
sw $a1 0($t9)
addi $t9 $t9 4
b voisin_du_bas
voisin_du_bas: 
lw $t1 12($t0)
beqz $t1 fin_lab_visited_neighbours #test si il y a un voisin 
lw $a1 12($t0) #indice du voisin du bas 
jal cell_est_visite
bnez $v0 fin_lab_visited_neighbours
sw $a1 0($t9)
fin_lab_visited_neighbours:
move $v0 $t2
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
addi $sp $sp 12
jr $ra

cell_au_hasard:
#prologue
addi $sp $sp -8
sw $ra 0($sp)
sw $a0 4($sp)   # adresse du tableau des voisins
#corps
jal tab_size    # la taille du tableau des voisins -> $v0
move $t2, $v0   # on sauvegarde la taille contenu en $v0 -> $t2
li $a0, 345     # le pseudorandom -> $a0
move $a1, $t2   # la borne superieure -> $a1
li $v0, 42      # generation d'un entier: 0 <= [int] < $a1 -> $a0 
syscall
move $t1, $a0   # on sauvegarde le resultat du random int -> $t1
lw $a0 4($sp)   # on recupere l'adresse du tableau des voisins -> $a0
add $a0 $a0 $t1 # on trouve l'adresse du bon element dans le tableau -> $a0
lw $v0 0($a0)   # on retourne l'indice de la cellule choisie au hasard
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
addi $sp $sp 8
jr $ra


tab_size: # fonction qui retourne la taille d'un tableau d'entiers
#prologue
addi $sp $sp -8
sw $ra 0($sp)
sw $a0 4($sp) # l'adresse du tableau
#corps
li $t0, 0
for_i_tab: beq $a0 $zero fin_for
	   addi $t0 $t0 1
	   addi $a0 $a0 4
	   b for_i_tab
fin_for:   addi $t0, $t0 -1
	   li $v0, $t0
#epilogue
lw $a0 4($sp)
lw $a0 0($sp)
addi $sp $sp 8
jr $ra