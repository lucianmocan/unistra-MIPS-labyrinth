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
#li $s0, 4
#li $a0, 4
#li $v0, 1
#syscall
#la $a0, new_line
#li $v0, 4
#syscall	
						
jal creer_laby
	



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
addi $sp $sp -4
sw $ra 0($sp)


#corps
mul $s1 $s0 $s0
jal init_laby  # creates an array where all of the integers'  4 least significant bits are set to 1
	       # return the address of the first integer in the array-> $v0

move $s2 $v0 # adresse du tableau -> $s2
li $s3 1     # indice de la cellule courante -> $s3

move $a0 $s1 
li $v0 9 
syscall 

move $s4 $v0 # adresse du sommet de la pile de cellule 
move $a0 $s2 # arg fonction cell_visiter $a0 contient l'adresse du labyrinthe
move $a1 $s3 # arg fonction cell_visiter $a1 contient l'indice de la cellule a visiter
jal cell_visiter #visite la cellule c0 et retourne son indice
move $t0 $v0
sw $s3 0($s4) #empile de la cellule c0 
loop_main:
	move $a0 $s4 # arg fonction st_est_vide $a0 contient l'adresse du sommet de la pile de cellules
	jal st_est_vide # retourne 1 si la pile est vide, 0 sinon
	move $t0 $v0 # contient 1 si la pile est vide 0 sinon 
	beq $t0 1 fin_creer_laby # test si la pile est vide 
	move $a0 $s2 
	move $a1 $s3 # indice de la cellule courante -> $a1
	jal lab_visited_neighbours
	move $t6 $v0 # cellules voisines non visitées
	move $a0 $v0 
	jal st_est_vide_taille
	bnez $v0 voisin_non_visite
	move $a0, $s4
	jal st_depiler
	move $a1, $s1
	jal st_sommet
	add $s3 $zero $v0
	#lw $zero 0($s4) # cas où il n'y a pas de cellule voisine non visité 
	#subi $s4 $s4 4
	#lw $s3 0($s4)
	b loop_main
voisin_non_visite:
	move $a0 $t6 
	jal cell_au_hasard
	move $s7 $v0 # indice de la cellule voisine 
	# savoir si la cellule voisine est en haut, en bas, a gauche, a droite
	move $a1 $s3 # arg fonction neighbour_position $a1 contient l'indice de la cellule courante
	move $a2 $s7 # arg fonction neighbour_position $a2 contient l'indice de la cellule voisine
	jal neighbour_position # donne le bit de la cellule courante a mettre a 0 
	move $a0 $v0
	move $a1 $s2
	move $a2 $s3
	jal cell_i_data
	move $a1 $v0
	jal cell_mettre_bit_a_0 # met le bit a 0
	move $a0 $v0
	move $a1 $s2
	move $a2 $s3
	jal cell_i_update # met a jour la cellule courante
	move $a1 $s7
	move $a2 $s3
	jal neighbour_position # donne le bit de la cellule voisine a mettre a 0
	move $a0 $v0
	move $a1, $s2
	move $a2, $s7
	jal cell_i_data
	move $a1, $v0
	jal cell_mettre_bit_a_0 
	move $a0, $v0
	move $a1, $s2
	move $a2, $s7
	jal cell_i_update
	move $s3 $s7
	#addi $s3 $t2 1
	move $a0, $s2
	move $a1, $s3
	jal cell_visiter
	move $a1, $s3
	move $a0, $s4
	jal st_empiler
	move $s3, $s7
j loop_main	
	

fin_creer_laby: move $a1, $s2
		li $a2, 1
		jal cell_i_data
		move $a1, $v0
		li $a0, 5
		jal cell_mettre_bit_a_1
		move $a0, $v0
		move $a1, $s2
		li $a2, 1
		jal cell_i_update
		
		move $a1, $s2
		move $a2, $s1
		jal cell_i_data
		move $a1, $v0
		li $a0, 4
		jal cell_mettre_bit_a_1
		move $a0, $v0
		move $a1, $s2
		move $a2, $s1
		jal cell_i_update


move $a1 $s2
jal affiche_laby


#epilogue
lw $ra 0($sp)
addi $sp $sp 4
jr $ra                            
                        

neighbour_position:
#prologue
addi $sp $sp -12
sw $ra 0($sp)
sw $a1 4($sp) # indice cellule courante
sw $a2 8($sp) # indice cellule voisine
#corps
addi $a1 $a1 -1
addi $a2 $a2 -1
sub $t0 $a2 $a1
abs $t1 $t0
beq $t1 $s0 up_or_bottom
blt $a1 $a2 right
li $v0, 3 # wall on the left
b end_neighbour_position
right:  li $v0, 1 # wall on the right
	b end_neighbour_position
up_or_bottom: bgt $a1 $a2 up
	      li $v0, 2 # wall on the bottom
	      b end_neighbour_position
	      up: li $v0, 0
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
sw $a0 4($sp) # valeur a  mettre a  la place
sw $a1 8($sp) # adresse du premier element du tableau
sw $a2 12($sp) # indice i du cellule
#corps
addi $t0 $a2 -1
mul $t0 $t0 4
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
addi $sp $sp -12
sw $ra 0($sp)
sw $a1 4($sp) # adresse du premier element du tableau
sw $a2 8($sp) # indice i du cellule
#corps
addi $t0 $a2 -1
mul $t0 $t0 4
add $a1 $a1 $t0
lw $v0 0($a1)
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
addi $a1 $a1 -1
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

st_est_vide_taille:
#prologue
addi $sp $sp -8
sw $ra 0($sp)
sw $a0 4($sp)
#corps
li $t0, 0
li $t1, 4
li $t3, 0
vide_loop: beq $t0 $t1 st_vide_taille
	   lw $t2 0($a0)
	   beqz $t2 elem_null
	   addi $t3 $t3 1
	   elem_null:
	   addi $t0 $t0 1
	   addi $a0 $a0 4
	   b vide_loop
st_vide_taille:
move $v0, $t3
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
sw $a0 4($sp) # adresse de la premiere cellule
sw $a1 8($sp) # indice de la cellule 
#corps
move $t3 $a0 #adresse de la premiere cellule
move $a0 $a1
jal lab_neighbouring_cells
move $s5 $v0 #adresse du tableau des voisins -> $s5

li $t6 4
mul $a0 $t6 $t6
li $v0 9
syscall  #cration du tableau de retour
move $s6 $v0 #transfert de l'adresse du tableau de retour -> $s6


lw $a0 4($sp) #addresse de la premire cellule
voisin_haut:
	lw $t1 0($s5)
	beqz $t1 pas_de_voisin_haut #test si il y a un voisin 
		lw $a1 0($s5) #indice du voisin du haut
		jal cell_est_visite
		bnez $v0 pas_de_voisin_haut  
		sw $a1 0($s6) # stocke l'indice du voisin en-haut non-visite
		b voisin_de_gauche
pas_de_voisin_haut:
	sw $zero 0($s6) #pas de voisin donc 0

voisin_de_gauche:
	lw $t1 12($s5)
	beqz $t1 pas_de_voisin_gauche #test si il y a un voisin 
		lw $a1 12($s5) #indice du voisin de gauche
		jal cell_est_visite
		bnez $v0 pas_de_voisin_gauche
		sw $a1 12($s6)  # stocke l'indice du voisin en-haut non-visite
		b voisin_de_droite
pas_de_voisin_gauche:
	sw $zero 12($s6) #pas de voisin donc 0
voisin_de_droite:
	lw $t1 4($s5)
	beqz $t1 pas_de_voisin_droite #test si il y a un voisin 
		lw $a1 4($s5) #indice du voisin de droite 
		jal cell_est_visite
		bnez $v0 pas_de_voisin_droite
		sw $a1 4($s6)  #stocke 1 si le voisin a t visit 0 sinon
		b voisin_du_bas
pas_de_voisin_droite:
	sw $zero 4($s6) #pas de voisin donc 0
voisin_du_bas: 
	lw $t1 8($s5)
	beqz $t1 pas_de_voisin_bas #test si il y a un voisin 
		lw $a1 8($s5) #indice du voisin du bas 
		jal cell_est_visite
		bnez $v0 pas_de_voisin_bas
		sw $a1 8($s6) #stocke 1 si le voisin a t visit 0 sinon
	b fin_lab_visited_neighbours
pas_de_voisin_bas:
sw $zero 8($s6) #pas de voisin donc 0
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
sw $a0 4($sp) # adresse du laby
sw $a1 8($sp) # indice du element
#corps
li $t6 4
mul $a0 $t6 $t6
li $v0 9
syscall  #creation du tableau de retour 
move $a0 $v0 # adresse du tableau de retour -> $a0
move $t1, $a0
li $t0, 0
for_init_zero: beq $t0 $t6 fin_init_zero # set all tab elements at 0
	       sw $zero 0($t1)
	       addi $t0 $t0 1
	       addi $t1 $t1 4
	       b for_init_zero
fin_init_zero:
sub $t0 $a1 $s0
neighbour_up: bltz $t0 no_up
	      sw $t0 0($a0) # index of cell above $a1 
no_up:
add $t0 $a1 $s0
neighbour_bottom: bgt $t0 $s1 no_bottom
		  sw $t0 8($a0)
no_bottom:
move $t0 $a1 # saves index value in $t1
addi $t0 $t0 -1
rem $t1 $t0 $s0
neighbour_left: beq $t1 $zero no_left
		sw $t0 12($a0)
no_left:
move $t0 $a1
rem $t1 $t0 $s0
neighbour_right: beq $t1 $zero no_right
		 addi $t0 $a1 1
		 sw $t0 4($a0)
no_right:
move $v0, $a0	 
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
sw $a0 4($sp)   # adresse du tableau des voisins
#corps
jal st_est_vide_taille    # la taille du tableau des voisins -> $v0
move $t2, $v0   # on sauvegarde la taille contenu en $v0 -> $t2
li $a0, 345     # le pseudorandom -> $a0
move $a1, $t2   # la borne superieure -> $a1
li $v0, 42      # generation d'un entier: 0 <= [int] < $a1 -> $a0 
syscall
mul $t1, $a0, 4   # on sauvegarde le resultat du random int -> $t1
li $t3, 16
sub $t2 $t3 $t1
lw $a0 4($sp)   # on recupere l'adresse du tableau des voisins -> $a0
add $a0 $a0 $t1 # on trouve l'adresse du bon element dans le tableau -> $a0
lw $v0 0($a0)   # on retourne l'indice de la cellule choisie au hasard

check_cell: bnez $v0, fin_hasard
	    bgt $t1 $t3 hasard_restart 
	    addi $a0, $a0, 4
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


tab_size: # fonction qui retourne la taille d'un tableau d'entiers
#prologue
addi $sp $sp -8
sw $ra 0($sp)
sw $a0 4($sp) # l'adresse du tableau
#corps
li $t0, 0
li $t1, 4
#for_i_tab: beq $t0 $t1 fin_for_i_tab
#	   lw $t2 0($a0)
###	   addi $t0 $t0 1
#	   addi $a0 $a0 4
#	   b for_i_tab
#f#in_for:   addi $t0, $t0 -1
	   move $v0, $t0
#epilogue
lw $a0 4($sp)
lw $a0 0($sp)
addi $sp $sp 8
jr $ra

st_empiler:
#prologue
addi $sp $sp -12
sw $ra 0($sp)
sw $a0 4($sp)   # adresse de la pile
sw $a1 8($sp)	# element a empiler
#corps
loop_st_empiler: #parcours de la pile
lw $t0 0($a0) 
beqz $t0 fin_st_empiler #test si $a0 pointe toujours sur un élément non vide de la pile 
addi $a0 $a0 4 #incrémentation du pointeur
b loop_st_empiler 
fin_st_empiler:
sw $a1 0($a0) #empilement 
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
addi $t0 $t0 4 #élémenbt suivant $a0 
lw $t1 0($t0) #valeur de l'élément suivant $a0
beqz $t1 fin_st_depiler #test de l'élément suivant $a0  
addi $a0 $a0 4 #$a0 n'est pas le sommet donc incrémentation du pointeur 
b loop_st_depiler
fin_st_depiler: #$a0 pointe sur le sommet 
sw $zero 0($a0) #dépilement  
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
move $t5, $a0 # pour faire le parcours du tableau $t5 contient l'adresse courante
for_st_sommet: beq $t0 $a1 stu_sommet # si on atteint la fin du tableau alors on prend le sommet: $t5 -> $t5 - 4
	       lw $t1 0($t5) # la valeur du element courant du tableau -> $t1
	       beqz $t1 stu_sommet # si $t1 == 0, on prend le sommet $t5 -> $t5 - 4
	       addi $t0, $t0, 1 # compteur d'elements -> $t0
	       addi $t5, $t5, 4 # adresse du element suivant -> $t5
	       b for_st_sommet
stu_sommet: addi $t5 $t5 -4 # on revient sur la bonne adresse qui est $t5 -> $t5 - 4
	    lw $v0 0($t5) # on charge la valeur du sommet -> $v0   
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

cell_visiter:
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
move $v0, $a0
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
addi $sp $sp 12
jr $ra
