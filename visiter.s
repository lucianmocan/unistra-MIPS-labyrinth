


.data


.text



main:
li $a0, 5
li $a1, 5
jal st_creer
move $a0 $v0
move $t0 $a0 
li $t1 0
	sw $t1 0($a0)
	sw $t1 4($a0)
	sw $t1 8($a0)
	sw $t1 12($a0) 
move $a3, $a0 # je sauvegarde l'adresse du 1er element du tableau -> $a3
lw $a1, 0($a0) # entier de la cellule a verifier -> $a1
	jal cell_est_visité
move $a0, $v0
li $v0, 1
syscall
move $a0, $a3
	jal cell_visiter
	move $a0, $v0  # entier avec le 6 bit à 1 -> $a0
	sw $a0, 0($a3) # on change l'ancien entier avec le nouveau -> 0($a3)
	lw $a0, 0($a3) # pour afficher le nouveau entier
li $v0, 1
syscall
move $a0, $a3
	jal cell_est_visité
	move $a0, $v0
li $v0, 1
syscall

li $v0, 10
syscall


cell_est_visité:
#prologue
addi $sp $sp -8
sw $ra 0($sp)
sw $a0 4($sp) # contient l'adresse du premier element du tableau
#corps
li $a0, 6 # position du bit qu'on veut verifier -> $a0
jal cell_lecture_de_bits # valeur du 6 bit -> $v0
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
sw $a1 8($sp) # valeur du cellule à visiter (mettre le 6-bit à 1)
#corps
li $a0, 6 # position du bit qu'on veut verifier -> $a0 = 6;
jal cell_mettre_bit_a_1 # nouveau entier avec le 6Ème bit à 1 -> $v0
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

st_creer:
#prologue
addi $sp $sp -8
sw $ra 0($sp)
sw $a0 4($sp) # nombre maximal d'entiers que la tableau pourra contenir -> $a0
#corps
mul $a0 $a0 4 # chaque entier est codÃ© sur 4 octets 
li $v0, 9 # allocation sur le tas de $a0 * octets, premiere adresse -> $v0
syscall
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
addi $sp $sp 8
jr $ra

