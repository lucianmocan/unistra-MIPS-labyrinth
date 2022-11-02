
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
