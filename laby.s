


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

lab_visited_neighbours:
addi $sp $sp -12
sw $ra 0($sp) 
sw $a0 4($sp) #adresse du la premiËre cellule
sw $a1 8($sp) #indice de la cellule 
#corps
move $t3 $a0 #adresse de la premiËre cellule
move $a0 $a1
jal lab_neighbouring_cells
move $t0 $v0 #adresse du tableau des voisins
li $t6 4
mul $a0 $t6 $t6
li $v0 9
syscall  #crÈation du tableau de retour
move $t2 $v0 #transfert de l'adresse du tableau de retour
move $a0 $t3 #addresse de la premiËre cellule
lw $t1 0($t0)
beqz $t1 pas_de_voisin_haut #test si il y a un voisin 
lw $a1 0($t0) #indice du voisin du haut
jal cell_est_visite
sw $v0 0($t2) #stocke 1 si le voisin a ÈtÈ visitÈ 0 sinon
b voisin_de_gauche
pas_de_voisin_haut:
sw $zero 0($t2) #pas de voisin donc 0
voisin_de_gauche:
lw $t1 4($t0)
beqz $t1 pas_de_voisin_gauche #test si il y a un voisin 
lw $a1 4($t0) #indice du voisin de gauche
jal cell_est_visite
sw $v0 4($t2)  #stocke 1 si le voisin a ÈtÈ visitÈ 0 sinon
b voisin_de_droite
pas_de_voisin_gauche:
sw $zero 4($t2) #pas de voisin donc 0
voisin_de_droite:
lw $t1 8($t0)
beqz $t1 pas_de_voisin_droite #test si il y a un voisin 
lw $a1 8($t0) #indice du voisin de droite 
jal cell_est_visite
sw $v0 8($t2)  #stocke 1 si le voisin a ÈtÈ visitÈ 0 sinon
b voisin_du_bas
pas_de_voisin_droite:
sw $zero 8($t2) #pas de voisin donc 0
voisin_du_bas: 
lw $t1 12($t0)
beqz $t1 pas_de_voisin_bas #test si il y a un voisin 
lw $a1 12($t0) #indice du voisin du bas 
jal cell_est_visite
sw $v0 12($t2) #stocke 1 si le voisin a ÈtÈ visitÈ 0 sinon
b fin_lab_visited_neighbours
pas_de_voisin_bas:
sw $zero 12($t2) #pas de voisin donc 0
fin_lab_visited_neighbours:
move $v0 $t2
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
addi $sp $sp 12
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
syscall  #crÈation du tableau de retour 
move $t2 $v0 #traansfert de l'adresse du premier ÈlÈment du tableau
bne $t1 1 last_cell_test #test si la cellule est la premiËre 
sw $zero 0($t2) #pas de voisin en-haut 
sw $zero 4($t2) #pas de voisin ‡ gauche
addi $t3 $t1 1
sw $t3 8($t2) #voisin de droite
add $t3 $t1 $s0 
sw $t3 12($t2) #voisin d'en-bas 
b fin_lab_neighbouring_cells
last_cell_test:
bne $t1 $t0 not_first_not_last #test si la cellule est la derniËre 
sw $zero 8($t2) #pas de voisin ‡ droite 
sw $zero 12($t2) #pas de voisin en haut 
subi $t3 $t1 1 
sw $t3 4($t2) #voisin de gauche
sub $t3 $t1 $s0 
sw $t3 0($t2) #voisin d'en-haut
b fin_lab_neighbouring_cells
not_first_not_last: #ni la premiËre cellule ni la derniËre 
addi $t3 $t1 1
sw $t3 8($t2) #voisin de droite 
subi $t3 $t1 1
sw $t3 4($t2) #voisin de gauche 
sub $t4 $t0 $s0  
bge $t1 $t4 last_row #test si la cellule est sur la derniËre ligne 
add $t3 $t1 $s0 
sw $t3 12($t2) #voisin d'en bas 
sub $t5 $t1 $s0  
ble $t5 $zero first_row #test si la cellule est sur la premiËre ligne 
sub $t3 $t1 $s0  
sw $t3 0($t2) #voisin d'en-haut
b fin_lab_neighbouring_cells
first_row: #la cellule est sur la premiËre ligne 
sw $zero 0($t2) #pas de voisin d'en haut 
b fin_lab_neighbouring_cells
last_row: #la cellule est sur la derniËre ligne 
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
sw $a0 4($sp) # valeur √† mettre √† la place
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
jal st_creer # alloue en m√©moire le tableau N*N et retourne l'adresse -> $v0
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
mul $a0 $a0 4 # chaque entier est cod√© sur 4 octets 
li $v0, 9 # allocation sur le tas de $a0 * octets, premiere adresse -> $v0
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

cell_lecture_de_bits:
#prologue
addi $sp $sp -12
sw $ra 0($sp)
sw $a0 4($sp) # position du n-ieme bit -> $a0
sw $a1 8($sp) # l'entier n dont on veut connaitre le n-ieme bit -> $a1
#corps
srlv $t0 $a1 $a0 # obtenir le n-ieme bit en premier bit de poids faible-> $t0
li $t1 1
and $v0 $t0 $t1 # mettre tous les bits a 0 sauf le bit recherch√©
#epilogue
lw $ra 0($sp)
lw $a0 4($sp)
lw $a1 8($sp)
addi $sp $sp 12
jr $ra 
