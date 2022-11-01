
.data

.text

main:
li $a0, 5
li $a1, 5
jal st_creer
move $a0 $v0
move $t0 $a0 
li $t1 2
sw $t1 0($a0)
sw $t1 4($a0)
sw $t1 8($a0)
sw $t1 12($a0)
jal st_empiler
jal st_est_pleine
move $a0, $v0
li $v0, 1
syscall

li $v0, 10
syscall

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

st_est_vide:
#prologue
addi $sp $sp -4
sw $ra 0($sp)
#corps
lw $t0 0($a0)
beqz $t0 st_vide
li $v0, 0
b fin_st_vide
st_vide: li $v0, 1
fin_st_vide:
#epilogue
lw $ra 0($sp)
addi $sp $sp 4
jr $ra

st_est_pleine:
#prologue
addi $sp $sp -12
sw $ra 0($sp)
sw $a0 4($sp) # adresse du tableau
sw $a1 8($sp) # nombre d'entiers maximal que le tableau peut contenir
#corps
li $t0, 0
move $t5, $a0 # pour faire le parcours du tableau $t5 contient l'adresse courante
for_est_pleine: beq $t0 $a1 st_pleine # si on atteint la fin du tableau alors il est plein
		lw $t1 0($t5) # la valeur du element courant du tableau -> $t1
		beqz $t1 st_non_pleine # si c'est zero alors le tableau n'est pas plein
		addi $t0, $t0, 1 # compteur d'elements -> $t0
		addi $t5 $t5 4 # adresse du element suivant -> $t5
		b for_est_pleine
st_pleine: li $v0, 1
b fin_st
st_non_pleine: li $v0, 0
fin_st:
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
addi $sp $sp 8
jr $ra

st_sommet:
#prologue
addi $sp $sp -8
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
addi $sp $sp 8
jr $ra

st_empiler:
#prologue
addi $sp $sp -12
sw $ra 0($sp)
sw $a0 4($sp)
sw $a1 8($sp)
#corps
loop_st_empiler:
lw $t0 0($a0)
beqz $t0 fin_st_empiler
addi $a0 $a0 4
b loop_st_empiler
fin_st_empiler:
sw $a1 0($a0)
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
addi $sp $sp 12
jr $ra