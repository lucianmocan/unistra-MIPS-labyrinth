.data 


.text

main:
li $a0 7
li $a1 127
jal mettre_bit_a_1
move $a0 $v0 
li $v0 1 
syscall 
li $v0 10 
syscall 


cell_lecture_de_bits:
#prologue
addi $sp $sp -12
sw $ra 0($sp)
sw $a0 4($sp) #bit dont on veut connaitre la valeur
sw $a1 8($sp) #n
#corps
addi $a0 $a0 -1 # position du n-ieme bit -> $a0
srlv $t0 $a1 $a0 # obtenir le n-ieme bit en premier bit de poids faible-> $t0
li $t1 1
and $v0 $t0 $t1 # mettre tous les bits a 0 sauf le bit recherché
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
addi $sp $sp 12
jr $ra 

mettre_bit_a1:
#prologue
addi $sp $sp -12
sw $ra 0($sp)
sw $a0 4($sp) #bit a changer 
sw $a1 8($sp) #n
#corps
jal power 
move $t0 $v0
or $v0 $a1 $t0  
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
addi $sp $sp 12
jr $ra 


cell_mettre_bit_a0:
#prologue
addi $sp $sp -12
sw $ra 0($sp)
sw $a0 4($sp) #bit a changer 
sw $a1 8($sp) #n
#corps
jal function_bis
and $v0 $v0 $a1
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
addi $sp $sp 12
jr $ra 

power:
#prologue
addi $sp $sp -8 
sw $ra 0($sp) 
sw $a0 4($sp)
#corps
li $v0 1 
loop:
beqz $a0 fin
mul $v0 $v0 2
addi $a0 $a0 -1 
b loop
#epilogue
fin:
lw $ra 0($sp)
lw $a0 4($sp)
addi $sp $sp 8
jr $ra

function_bis:
#prologue
addi $sp $sp -8
sw $ra 0($sp)
sw $a0 4($sp)
#corps
li $t0 0
li $t1 0
li $t2 31 
sub $t2 $t2 $a0
loop_funtcion_bis:
bge $t1 31 fin_function_bis
sll $t0 $t0 1
addi $t1 $t1 1
beq $t1 $t2 loop_funtcion_bis
addi $t0 $t0 1
b loop_funtcion_bis
fin_function_bis:
move $v0 $t0 
#epilogue 
lw $ra 0($sp)
lw $a0 4($sp)
addi $sp $sp 8
jr $ra 
