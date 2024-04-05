# MIPS Labyrinth/maze

This is project implements algorithms capable of generating, saving and displaying a maze using MIPS assembly.

The final code is in the `laby.s` all the others are parts of the code I keep for history.

1. To run this code you need to download the MARS MIPS Simulator. (In this repository you can find the jar I used to code and test the code).

2. Then on the command line, inside the folder you can generate a maze by running the following command : `java -jar Mars4_5.jar laby.s pa <N> | sed '1,2d' | sed '$d' > laby.txt`.
`<N>` should be replaced by your maze size of choice.

3. Then run `bash print_maze.sh laby.txt` to display the maze in an understandable form for the human eye :).



If you want to check the document describing the assignment : (it is in French)
[Projet MIPS.pdf](https://github.com/lucianmocan/unistra-MIPS-labyrinth/files/14878512/Projet.MIPS.pdf)
