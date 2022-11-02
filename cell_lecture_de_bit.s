.data 


.text

main:
li $a0 7
li $a1 127
jal cell_mettre_bit_a_0
move $a0 $v0 
li $v0 1 
syscall 
li $v0 10 
syscall 

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
