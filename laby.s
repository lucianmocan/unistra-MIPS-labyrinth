


.data
space: .asciiz " "
new_line: .asciiz "\n"


.text

main:
li $a0, 5
li $s0, 5 # on sauvegarde la valeur du N, on ne la modifie pas -> $s0
jal creer_laby
move $a1, $v0 # adresse du tableau -> $a1
jal affiche_laby
la $a0, new_line
li $v0, 4
syscall
li $a0, 5
addi $a2 $zero 2
addi $a3 $zero 3
jal cell_i_j_data
move $a0, $v0
li $v0, 1
syscall
la $a0, new_line
li $v0, 4
syscall
li $a0, 52
jal cell_i_j_update
li $a0, 5
jal affiche_laby
move $a0 $a1 
li $a1 20
li $a2 15
jal lab_direction_ind
move $a0 $v0
li $v0 1 
syscall 
li $v0, 10
syscall

lab_direction_ind:
#prologue
addi $sp $sp -16
sw $ra 0($sp)
sw $a0 4($sp) #adresser du labyrinthe
sw $a1 8($sp) #indice de la cellule c 
sw $a2 12($sp) #direction 
#corps
bne $a2 -1 droite #gauche 
subi $v0 $a1 1
b fin_lab_direction_ind
droite: #droite 
bne $a2 1 bas 
addi $v0 $a1 1 
b fin_lab_direction_ind
bas: #bas 
bne $a2 $s0 haut
add $v0 $a1 $s0 
b fin_lab_direction_ind
haut: #haut 
sub $v0 $a1 $s0 
fin_lab_direction_ind:
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
lw $a2 12($sp)
addi $sp $sp 16
jr $ra




cell_i_j_update:
#prologue
addi $sp $sp -20
sw $ra 0($sp)
sw $a0 4($sp) # valeur à mettre à la place
sw $a1 8($sp) # adresse du premier element du tableau
sw $a2 12($sp) # indice i du cellule
sw $a3 16($sp) # indice j du cellule
#corps
mul $t0 $s0 $a2
mul $t0 $t0 4
mul $t1 $a3 4
add $t2 $t0 $t1
add $a1 $a1 $t2
sw $a0 0($a1)
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
lw $a2 12($sp)
lw $a3 16($sp)
addi $sp $sp 20
jr $ra

cell_i_j_data:
#prologue
addi $sp $sp -16
sw $ra 0($sp)
sw $a1 4($sp) # adresse du premier element du tableau
sw $a2 8($sp) # indice i du cellule
sw $a3 12($sp) # indice j du cellule
#corps
mul $t0 $s0 $a2
mul $t0 $t0 4
mul $t1 $a3 4
add $t2 $t0 $t1
add $a1 $a1 $t2
lw $v0 0($a1)
#epilogue
lw $ra 0($sp)
lw $a1 4($sp)
lw $a2 8($sp)
lw $a3 12($sp)
addi $sp $sp 16
jr $ra

creer_laby:
#prologue
addi $sp $sp -4
sw $ra 0($sp) 
#corps
mul $t3 $s0 $s0
jal st_creer # alloue en mémoire le tableau N*N et retourne l'adresse -> $v0
move $t0 $v0 # l'adresse du premier element du tableau -> $a1
move $t5 $v0 # sauvegarder l'adresse du tableau pour le retour
li $t2, 15 # en binaire 15 (F) = 0000 1111 pour 4 murs autour d'une cellule
li $t1 0 # $t1 compteur pour la boucle for_creer_laby
for_creer_laby:  beq $t1 $t3 fin_creer_laby
		 sw $t2 0($t0)
		 addi $t1 $t1 1
		 addi $t0 $t0 4
		 b for_creer_laby
fin_creer_laby:  move $v0 $t5
#epilogue
lw $ra 0($sp)
addi $sp $sp 4
jr $ra

affiche_laby:
#prologue
addi $sp $sp -12
sw $ra 0($sp)
sw $a0 4($sp)
sw $a1 8($sp)
#corps
move $t2 $a0
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


st_creer:
#prologue
addi $sp $sp -8
sw $ra 0($sp)
sw $a0 4($sp) # nombre maximal d'entiers que la tableau pourra contenir -> $a0
#corps
mul $a0 $a0 4 # chaque entier est codé sur 4 octets 
li $v0, 9 # allocation sur le tas de $a0 * octets, premiere adresse -> $v0
syscall
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
addi $sp $sp 8
jr $ra

