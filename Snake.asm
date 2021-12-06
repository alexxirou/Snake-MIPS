#
#
#                                               .......
#                                     ..  ...';:ccc::,;,'.
#                                 ..'':cc;;;::::;;:::,'',,,.
#                              .:;c,'clkkxdlol::l;,.......',,
#                          ::;;cok0Ox00xdl:''..;'..........';;
#                          o0lcddxoloc'.,. .;,,'.............,'
#                           ,'.,cc'..  .;..;o,.       .......''.
#                             :  ;     lccxl'          .......'.
#                             .  .    oooo,.            ......',.
#                                    cdl;'.             .......,.
#                                 .;dl,..                ......,,
#                                 ;,.                   .......,;
#                                                        ......',
#                                                       .......,;
#                                                       ......';'
#                                                      .......,:.
#                                                     .......';,
#                                                   ........';:
#                                                 ........',;:.
#                                             ..'.......',;::.
#                                         ..';;,'......',:c:.
#                                       .;lcc:;'.....',:c:.
#                                     .coooc;,.....,;:c;.
#                                   .:ddol,....',;:;,.
#                                  'cddl:'...,;:'.
#                                 ,odoc;..',;;.                    ,.
#                                ,odo:,..';:.                     .;
#                               'ldo:,..';'                       .;.
#                              .cxxl,'.';,                        .;'
#                              ,odl;'.',c.                         ;,.
#                              :odc'..,;;                          .;,'
#                              coo:'.',:,                           ';,'
#                              lll:...';,                            ,,''
#                              :lo:'...,;         ...''''.....       .;,''
#                              ,ooc;'..','..';:ccccccccccc::;;;.      .;''.
#          .;clooc:;:;''.......,lll:,....,:::;;,,''.....''..',,;,'     ,;',
#       .:oolc:::c:;::cllclcl::;cllc:'....';;,''...........',,;,',,    .;''.
#      .:ooc;''''''''''''''''''',cccc:'......'',,,,,,,,,,;;;;;;'',:.   .;''.
#      ;:oxoc:,'''............''';::::;'''''........'''',,,'...',,:.   .;,',
#     .'';loolcc::::c:::::;;;;;,;::;;::;,;;,,,,,''''...........',;c.   ';,':
#     .'..',;;::,,,,;,'',,,;;;;;;,;,,','''...,,'''',,,''........';l.  .;,.';
#    .,,'.............,;::::,'''...................',,,;,.........'...''..;;
#   ;c;',,'........,:cc:;'........................''',,,'....','..',::...'c'
#  ':od;'.......':lc;,'................''''''''''''''....',,:;,'..',cl'.':o.
#  :;;cclc:,;;:::;''................................'',;;:c:;,'...';cc'';c,
#  ;'''',;;;;,,'............''...........',,,'',,,;:::c::;;'.....',cl;';:.
#  .'....................'............',;;::::;;:::;;;;,'.......';loc.'.
#   '.................''.............'',,,,,,,,,'''''.........',:ll.
#    .'........''''''.   ..................................',;;:;.
#      ...''''....          ..........................'',,;;:;.
#                                ....''''''''''''''',,;;:,'.
#                                    ......'',,'','''..
#


################################################################################
#                  Fonctions d'affichage et d'entrée clavier                   #
################################################################################

# Ces fonctions s'occupent de l'affichage et des entrées clavier.
# Il n'est pas obligatoire de comprendre ce qu'elles font.

.data

# Tampon d'affichage du jeu 256*256 de manière linéaire.

frameBuffer: .word 0 : 1024  # Frame buffer

# Code couleur pour l'affichage
# Codage des couleurs 0xwwxxyyzz où
#   ww = 00
#   00 <= xx <= ff est la couleur rouge en hexadécimal
#   00 <= yy <= ff est la couleur verte en hexadécimal
#   00 <= zz <= ff est la couleur bleue en hexadécimal

colors: .word 0x00000000, 0x00ff0000, 0xff00ff00, 0x00396239, 0x00ff00ff
.eqv black 0
.eqv red   4
.eqv green 8
.eqv greenV2  12
.eqv rose  16

# Dernière position connue de la queue du serpent.

lastSnakePiece: .word 0, 0

.text
j main

############################# printColorAtPosition #############################
# Paramètres: $a0 La valeur de la couleur
#             $a1 La position en X
#             $a2 La position en Y
# Retour: Aucun
# Effet de bord: Modifie l'affichage du jeu
################################################################################

printColorAtPosition:
lw $t0 tailleGrille
mul $t0 $a1 $t0
add $t0 $t0 $a2
sll $t0 $t0 2
sw $a0 frameBuffer($t0)
jr $ra

################################ resetAffichage ################################
# Paramètres: Aucun
# Retour: Aucun
# Effet de bord: Réinitialise tout l'affichage avec la couleur noir
################################################################################

resetAffichage:
lw $t1 tailleGrille
mul $t1 $t1 $t1
sll $t1 $t1 2
la $t0 frameBuffer
addu $t1 $t0 $t1
lw $t3 colors + black

RALoop2: bge $t0 $t1 endRALoop2
  sw $t3 0($t0)
  add $t0 $t0 4
  j RALoop2
endRALoop2:
jr $ra

################################## printSnake ##################################
# Paramètres: Aucun
# Retour: Aucun
# Effet de bord: Change la couleur de l'affichage aux emplacement ou se
#                trouve le serpent et sauvegarde la dernière position connue de
#                la queue du serpent.
################################################################################

printSnake:
subu $sp $sp 12
sw $ra 0($sp)
sw $s0 4($sp)
sw $s1 8($sp)

lw $s0 tailleSnake
sll $s0 $s0 2
li $s1 0

lw $a0 colors + greenV2
lw $a1 snakePosX($s1)
lw $a2 snakePosY($s1)
jal printColorAtPosition
li $s1 4

PSLoop:
bge $s1 $s0 endPSLoop
  lw $a0 colors + green
  lw $a1 snakePosX($s1)
  lw $a2 snakePosY($s1)
  jal printColorAtPosition
  addu $s1 $s1 4
  j PSLoop
endPSLoop:

subu $s0 $s0 4
lw $t0 snakePosX($s0)
lw $t1 snakePosY($s0)
sw $t0 lastSnakePiece
sw $t1 lastSnakePiece + 4

lw $ra 0($sp)
lw $s0 4($sp)
lw $s1 8($sp)
addu $sp $sp 12
jr $ra

################################ printObstacles ################################
# Paramètres: Aucun
# Retour: Aucun
# Effet de bord: Change la couleur de l'affichage aux emplacement des obstacles.
################################################################################

printObstacles:
subu $sp $sp 12
sw $ra 0($sp)
sw $s0 4($sp)
sw $s1 8($sp)

lw $s0 numObstacles
sll $s0 $s0 2
li $s1 0

POLoop:
bge $s1 $s0 endPOLoop
  lw $a0 colors + red
  lw $a1 obstaclesPosX($s1)
  lw $a2 obstaclesPosY($s1)
  jal printColorAtPosition
  addu $s1 $s1 4
  j POLoop
endPOLoop:

lw $ra 0($sp)
lw $s0 4($sp)
lw $s1 8($sp)
addu $sp $sp 12
jr $ra

################################## printCandy ##################################
# Paramètres: Aucun
# Retour: Aucun
# Effet de bord: Change la couleur de l'affichage à l'emplacement du bonbon.
################################################################################

printCandy:
subu $sp $sp 4
sw $ra ($sp)

lw $a0 colors + rose
lw $a1 candy
lw $a2 candy + 4
jal printColorAtPosition

lw $ra ($sp)
addu $sp $sp 4
jr $ra

eraseLastSnakePiece:
subu $sp $sp 4
sw $ra ($sp)

lw $a0 colors + black
lw $a1 lastSnakePiece
lw $a2 lastSnakePiece + 4
jal printColorAtPosition

lw $ra ($sp)
addu $sp $sp 4
jr $ra

################################## printGame ###################################
# Paramètres: Aucun
# Retour: Aucun
# Effet de bord: Effectue l'affichage de la totalité des éléments du jeu.
################################################################################

printGame:
subu $sp $sp 4
sw $ra 0($sp)

jal eraseLastSnakePiece
jal printSnake
jal printObstacles
jal printCandy

lw $ra 0($sp)
addu $sp $sp 4
jr $ra

############################## getRandomExcluding ##############################
# Paramètres: $a0 Un entier x | 0 <= x < tailleGrille
# Retour: $v0 Un entier y | 0 <= y < tailleGrille, y != x
################################################################################

getRandomExcluding:
move $t0 $a0
lw $a1 tailleGrille
li $v0 42
syscall
beq $t0 $a0 getRandomExcluding
move $v0 $a0
jr $ra

########################### newRandomObjectPosition ############################
# Description: Renvoie une position aléatoire sur un emplacement non utilisé
#              qui ne se trouve pas devant le serpent.
# Paramètres: Aucun
# Retour: $v0 Position X du nouvel objet
#         $v1 Position Y du nouvel objet
################################################################################

newRandomObjectPosition:
subu $sp $sp 4
sw $ra ($sp)

lw $t0 snakeDir
and $t0 0x1
bgtz $t0 horizontalMoving
li $v0 42
lw $a1 tailleGrille
syscall
move $t8 $a0
lw $a0 snakePosY
jal getRandomExcluding
move $t9 $v0
j endROPdir

horizontalMoving:
lw $a0 snakePosX
jal getRandomExcluding
move $t8 $v0
lw $a1 tailleGrille
li $v0 42
syscall
move $t9 $a0
endROPdir:

lw $t0 tailleSnake
sll $t0 $t0 2
la $t0 snakePosX($t0)
la $t1 snakePosX
la $t2 snakePosY
li $t4 0

ROPtestPos:
bge $t1 $t0 endROPtestPos
lw $t3 ($t1)
bne $t3 $t8 ROPtestPos2
lw $t3 ($t2)
beq $t3 $t9 replayROP
ROPtestPos2:
addu $t1 $t1 4
addu $t2 $t2 4
j ROPtestPos
endROPtestPos:

bnez $t4 endROP

lw $t0 numObstacles
sll $t0 $t0 2
la $t0 obstaclesPosX($t0)
la $t1 obstaclesPosX
la $t2 obstaclesPosY
li $t4 1
j ROPtestPos

endROP:
move $v0 $t8
move $v1 $t9
lw $ra ($sp)
addu $sp $sp 4
jr $ra

replayROP:
lw $ra ($sp)
addu $sp $sp 4
j newRandomObjectPosition

################################# getInputVal ##################################
# Paramètres: Aucun
# Retour: $v0 La valeur 0 (haut), 1 (droite), 2 (bas), 3 (gauche), 4 erreur
################################################################################

getInputVal:
lw $t0 0xffff0004
li $t1 115
beq $t0 $t1 GIhaut
li $t1 122
beq $t0 $t1 GIbas
li $t1 113
beq $t0 $t1 GIgauche
li $t1 100
beq $t0 $t1 GIdroite
li $v0 4
j GIend

GIhaut:
li $v0 0
j GIend

GIdroite:
li $v0 1
j GIend

GIbas:
li $v0 2
j GIend

GIgauche:
li $v0 3

GIend:
jr $ra

################################ sleepMillisec #################################
# Paramètres: $a0 Le temps en milli-secondes qu'il faut passer dans cette
#             fonction (approximatif)
# Retour: Aucun
################################################################################

sleepMillisec:
move $t0 $a0
li $v0 30
syscall
addu $t0 $t0 $a0

SMloop:
bgt $a0 $t0 endSMloop
li $v0 30
syscall
j SMloop

endSMloop:
jr $ra

##################################### main #####################################
# Description: Boucle principal du jeu
# Paramètres: Aucun
# Retour: Aucun
################################################################################

main:

# Initialisation du jeu

jal resetAffichage
jal newRandomObjectPosition
sw $v0 candy
sw $v1 candy + 4

# Boucle de jeu

mainloop:

jal getInputVal
move $a0 $v0
jal majDirection
jal updateGameStatus
jal conditionFinJeu
bnez $v0 gameOver
jal printGame
li $a0 500
jal sleepMillisec
j mainloop

gameOver:
jal affichageFinJeu
li $v0 10
syscall

################################################################################
#                                Partie Projet                                 #
################################################################################

# À vous de jouer !

.data

tailleGrille:  .word 16        # Nombre de case du jeu dans une dimension.

# La tête du serpent se trouve à (snakePosX[0], snakePosY[0]) et la queue à
# (snakePosX[tailleSnake - 1], snakePosY[tailleSnake - 1])
tailleSnake:   .word 1         # Taille actuelle du serpent.
snakePosX:     .word 0 : 1024  # Coordonnées Y du serpent ordonné de la tête à la queue.
snakePosY:     .word 0 : 1024  # Coordonnées X du serpent ordonné de la t.

# Les directions sont représentés sous forme d'entier allant de 0 à 3:
snakeDir:      .word 1         # Direction du serpent: 0 (haut), 1 (droite)
                               #                       2 (bas), 3 (gauche)
numObstacles:  .word 0         # Nombre actuel d'obstacle présent dans le jeu.
obstaclesPosX: .word 0 : 1024  # Coordonnées X des obstacles
obstaclesPosY: .word 0 : 1024  # Coordonnées Y des obstacles
candy:         .word 0, 0      # Position du bonbon (X,Y)
scoreJeu:      .word 0         # Score obtenu par le joueur
scoreDis:       .asciiz    "Bien jouait!\nScore: "

.text

################################# majDirection #################################
# Paramètres: $a0 La nouvelle position demandée par l'utilisateur. La valeur
#                 étant le retour de la fonction getInputVal.
# Retour: Aucun
# Effet de bord: La direction du serpent à été mise à jour.
# Post-condition: La valeur du serpent reste intacte si une commande illégale
#                 est demandée, i.e. le serpent ne peut pas faire de demi-tour
#                 en un unique tour de jeu. Cela s'apparente à du cannibalisme
#                 et à été proscrit par la loi dans les sociétés reptiliennes.
################################################################################

majDirection:
la $s1 snakeDir 	   #adresse direction
lw $a0 ($s1)               #valeur direction
beq $v0 4 finDirection 	   #si erreur on change pas la direction 
addu $t2 $v0 1 		   #augmente direction precedente et input par 1 et comparaison du modulo
addu $t3 $a0 1
andi $t2 $t2 1
andi $t3 $t3 1
beq $t2 $t3  finDirection  #si modulo sont egaux finir sans mis à jour la direction
move $a0 $v0  		   #sinon changer la valeur de la direction

finDirection:
sw $a0 snakeDir 	   #sauv la nouvelle valeur à label snakeDir
jr $ra


############################### updateGameStatus ###############################
# Paramètres: Aucun
# Retour: Aucun
# Effet de bord: L'état du jeu est mis à jour d'un pas de temps. Il faut donc :
#                  - Faire bouger le serpent
#                  - Tester si le serpent à manger le bonbon
#                    - Si oui déplacer le bonbon et ajouter un nouvel obstacle
####################################
updateGameStatus:
lw $s1 snakeDir 	#valeur direction
lw $t4 tailleSnake 	#valeur taille
la $s3 snakePosX 	#pos horizontale
la $s2 snakePosY 	#pos verticale
lw $s6 ($s2) 		#dernière position de tête Y
lw $s7 ($s3) 		# X
beq $s1 0 moveUp 	#bouge la tête selon la direction 
beq $s1 1 moveRight
beq $s1 2 moveDown
beq $s1 3 moveLeft



queue:
beq $a1 $t4 mangeCandy 	#t4 taille et a1 1
mul $t3 $a1 4
add $a2 $s2 $t3 	#adresse queue PosY
add $a3 $s3 $t3 	#adresse queue PosX
lw $t6 ($a2) 		# t6 valeur de la pos queue  Y
lw $t7 ($a3) 		# t7 valeur de la pos queue  X
sw $s6 ($a2) 		# s6 valeur de la pos queue  precedente Y (tête au debut)
sw $s7 ($a3) 		# s7 valeur de la pos queue  precedente X (tête au debut)
move $s6 $t6 		#sauve pos precedente de la morceau actuel (pour decaler la queue via boucle)
move $s7 $t7
addi $a1 $a1 1 		#augmente l'indice
j queue

moveUp:
lw $t7 ($s3) 		#valeur X
addi $t7 $t7 1 		#degale X
sw $t7 ($s3) 		#sauve new X
li $a1 1 		#queue du snake compteur
j queue

moveRight:
lw $t6 ($s2) 		#valeur Y
addi $t6 $t6 1 		#decale Y
sw $t6 ($s2) 		#sauv new Y
li $a1 1 		#queue du snake compteur
j queue

moveDown:
lw $t7 ($s3) 		#valeur X
subiu $t7 $t7 1
sw $t7 ($s3)
li $a1 1 		#queue du snake compteur
j queue

moveLeft:
lw $t6 ($s2) 		#valeur Y
subiu $t6 $t6 1
sw $t6 ($s2)
li $a1 1 		#queue du snake compteur
j queue



mangeCandy:
la $s5 candy 		#adresse candy
lw $t6 ($s2) 		#position tete Y
lw $t7 ($s3)	 	#position tete X
lw $t8 4($s5) 		#pos candy X
lw $t9 ($s5) 		#pos candy Y
bne $t6 $t8 updateFin 	#pas de bonbon saut à la fin
bne $t7 $t9 updateFin 
addi $a1 $t4 -1 	#denière pos du queue
mul $t3 $a1 4
add $a2 $s2 $t3 	#adresse queue PosY (après la dernière)
add $a3 $s3 $t3 	#adresse queue PosX '(après la dernière)
sw $s6 ($a2)  		#ajouter un queue au corps
sw $s7 ($a3)
addi $t4 $t4 1 		#augmente la taille snake par 1
sw $t4 tailleSnake 	#augmente la taille du snake

subu $sp $sp 4
sw $ra ($sp)
jal newRandomObjectPosition 	#generer candy
sw  $v1 4($s5) 			#valeur pos candy X
sw  $v0 ($s5) 			#valeur pos candy Y
lw $ra ($sp)
addu $sp $sp 4
lw $t4 numObstacles 		#nombre obstacles (init à 0)
addi $t4 $t4 1 			#nombre des obstacles +1
sw $t4 numObstacles 
la $s6 obstaclesPosX 		#addresse pos obstacle
la $s7 obstaclesPosY 		#addresse pos obstacle
mul $t4 $t4 4 			#nombre obstacles
addu $t1 $s6 $t4 		#parcourir le tableau adresses des obstacles X
addu $t2 $s7 $t4 		# parcourir le tableau adresses des obstacles Y
subu $sp $sp 4
sw $ra ($sp)
jal newRandomObjectPosition 	#cordonnés de l'obstacle
sw  $v1 ($t2) 			#sauve une nouv pos d'obstacle X
sw  $v0 ($t1) 			#sauve une nouv pos d'obstacle Y
lw $ra ($sp)
addu $sp $sp 4
subu $sp $sp 4
sw $ra ($sp)
jal resetAffichage 		#corriger bug visuel 
lw $ra ($sp)
addu $sp $sp 4
lw $t0 scoreJeu 		#valeur score
addi $t0 $t0 100 		 #augmente le score
sw $t0 scoreJeu

j updateFin

updateFin:
jr $ra





############################### conditionFinJeu ################################
# Paramètres: Aucun
# Retour: $v0 La valeur 0 si le jeu doit continuer ou toute autre valeur sinon.
################################################################################

conditionFinJeu:
# getSnakePos, position du corps
la $s0 snakePosX #pos verticale
la $s1 snakePosY #pos horizontale

lw $s2 0($s0) #dernière position de tête
lw $s3 0($s1) 

addi $s0 $s0 4
addi $s1 $s1 4
# if game touches the outside bar, game over
bgeu $s2 16 finJeu
bgeu $s3 16 finJeu


# checkCorps 
li $s4 1 			# i = 1
lw $s7 tailleSnake		# taille de snake

Body:
beq $s4 $s7 endBody		# while i < queue de la snake 
lw $s5 ($s0)			# snakePosX[i]
lw $s6 ($s1)			# snakePosY[i]
bne $s2 $s5 skip		# si headPosX != snakePosX[i], alors saut cette partie
beq $s3 $s6 finJeu		# si headPosY == snakePosY[i], alors finJeu

skip:
addi $s4 $s4 1			# traverser le corps du snake 
addi $s1 $s1 4			# prochain position x du corps de snake 
addi $s0 $s0 4			# prochain position y du corps de snake 
j Body				# repeter pour la prochain partie du corps

endBody:
# getPos des obstacles
la $s0 obstaclesPosX
la $s1 obstaclesPosY

# getPos du corps snake
la $s2 snakePosX
la $s3 snakePosY

# getTete du corps Snake
lw $s2 0($s2)
lw $s3 0($s3)

# getObsLimites 
li $s4 0			# i = 0
lw $s5 numObstacles	

Obstacles:
bgeu $s4 $s5 endObstacles	# while (i < numObstacles
lw $s6 0($s0)			# obstacle[i] x position
lw $s7 0($s1)			# obstacle[j] y position
bne $s6 $s2 skipObs		# skip si x position de la tete et l obstacle sont pas 
beq $s7 $s3 finJeu		# finJeu si position de la tete egaux a la position d obstacle

skipObs:
addi $s4 $s4 1			# go to suivant obstacle
addi $s0 $s0 4			# x position du suiv obstacle
addi $s1 $s1 4			# y position du suiv obstacle
j Obstacles			# repeter pour le suiv obstacle

endObstacles:
j notOver

finJeu:
li $v0 1
jr $ra

notOver:
li $v0 0
jr $ra

############################### affichageFinJeu ################################
# Param�tres: Aucun
# Retour: Aucun
# Effet de bord: Affiche le score du joueur dans le terminal suivi d'un petit
#                mot gentil (Exemple : �Quelle pitoyable prestation !�).
# Bonus: Afficher le score en surimpression du jeu.
################################################################################

affichageFinJeu:

# Display Scores message
li $v0 56
la $a0 scoreDis
lw $a1 scoreJeu
syscall
# Fin.
jr $ra
