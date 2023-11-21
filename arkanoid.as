;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;------------------------------------------------------------------------------
CR              EQU     0Ah
FIM_TEXTO       EQU     '@'
IO_READ         EQU     FFFFh
IO_WRITE        EQU     FFFEh
IO_STATUS       EQU     FFFDh
INITIAL_SP      EQU     FDFFh
CURSOR			EQU     FFFCh
CURSOR_INIT		EQU     FFFFh

LINE_BAR        EQU     20d
LENGTH_BAR		EQU     30d

TIMER_UNITS     EQU     FFF6h
ACTIVATE_TIMER  EQU     FFF7h

RIGHT_UP        EQU     1d
RIGHT_DOWN      EQU     2d
LEFT_UP         EQU     3d
LEFT_DOWN       EQU     4d

FALSE			EQU		0d
TRUE			EQU		1d

MAP_LINE_SIZE	EQU		80d

MAX_SCORE		EQU		100d

COLUMN_UNIT		EQU		12d
COLUMN_TENTHS	EQU		11d
COLUMN_HUNDREDS	EQU		10d

BASE_ASCII		EQU		48d

FINAL_COLUMN_UNIT		EQU		44d
FINAL_COLUMN_TENTHS		EQU		43d
FINAL_COLUMN_HUNDREDS	EQU		42d

INITIAL_X	EQU		40d
INITIAL_Y	EQU		14d

TOP_ROW			EQU		2d
BOTTOM_ROW		EQU		22d
LEFT_COLUMN		EQU		1d
RIGHT_COLUMN 	EQU		78d

BAR_ROW		EQU		19d
BAR_COLUMN	EQU		29d

;-----------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
;------------------------------------------------------------------------------
			ORIG    8000h

Line0Load	STR '                                                                                '
Line1Load	STR '                                                                                '
Line2Load	STR '               ___  ______ _   __  ___   _   _ _____ ___________                '
Line3Load	STR '              / _ \ | ___ \ | / / / _ \ | \ | |  _  |_   _|  _  \               '
Line4Load	STR '             / /_\ \| |_/ / |/ / / /_\ \|  \| | | | | | | | | | |               '
Line5Load   STR '             |  _  ||    /|    \ |  _  || . ` | | | | | | | | | |               '
Line6Load   STR '             | | | || |\ \| |\  \| | | || |\  \ \_/ /_| |_| |/ /                '
Line7Load   STR '             \_| |_/\_| \_\_| \_/\_| |_/\_| \_/\___/ \___/|___/                 '
Line8Load   STR '                                                                                '
Line9Load   STR '                                                                                '
Line10Load  STR '                           Developed by Lucas Eckhardt                          '
Line11Load  STR '                                                                                '
Line12Load  STR '                                                                                '
Line13Load  STR '                                                                                '
Line14Load  STR '                                                                                '
Line15Load  STR '                                                                                '
Line16Load  STR '                                                                                '
Line17Load  STR '                            Score 100 points to win!                            '
Line18Load  STR '                                                                                '
Line19Load  STR '                        -> PRESS P TO START THE GAME <-                         '
Line20Load  STR '                                                                                '
Line21Load  STR '                                                                                '
Line22Load  STR '                                                                                '
Line23Load  STR '                                                                                ', FIM_TEXTO


Line0Map	STR '   Score: 000 | Lifes: S2 S2 S2                                       Arkanoid  '
Line1Map	STR '|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|'
Line2Map	STR '|                                                                              |'
Line3Map	STR '|                                                                              |'
Line4Map	STR '|         ===============       ===============       ===============          |'
Line5Map   	STR '|         ===============       ===============       ===============          |'
Line6Map   	STR '|         ===============       ===============       ===============          |'
Line7Map   	STR '|         ===============       ===============       ===============          |'
Line8Map   	STR '|         ===============       ===============       ===============          |'
Line9Map   	STR '|                                                                              |'
Line10Map  	STR '|                                                                              |'
Line11Map  	STR '|                                                                              |'
Line12Map  	STR '|                                                                              |'
Line13Map  	STR '|                                                                              |'
Line14Map  	STR '|                                                                              |'
Line15Map  	STR '|                                                                              |'
Line16Map  	STR '|                                                                              |'
Line17Map  	STR '|                                                                              |'
Line18Map  	STR '|                                                                              |'
Line19Map  	STR '|                                                                              |'
Line20Map  	STR '|                        ------------------------------                        |'
Line21Map  	STR '|                                                                              |'
Line22Map  	STR '|                                                                              |'
Line23Map  	STR '|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|', FIM_TEXTO

LineLoose 	STR '|                       ----------> YOU LOSE! <----------                      |', FIM_TEXTO
LineWin 	STR '|                       ----------> YOU WIN! <----------                       |', FIM_TEXTO

StringToPrint 		WORD 0d  ; Endereco da string que será impressa
LineNumberToPrint 	WORD 0d  ; Número da linha que será impressa
LeftColumnBar 		WORD 25d

Line                STR '-'
Brick				STR '='
EmptySpace          STR ' '

BallDirection       STR RIGHT_UP
xBall               WORD 40d
yBall               WORD 14d

Lifes				WORD 3d
Score				WORD 0d

Flag				WORD FALSE

;------------------------------------------------------------------------------
; ZONA II: definicao de tabela de interrupções
;------------------------------------------------------------------------------
                ORIG    FE00h
INT0			WORD	MoveBarLeft
INT1			WORD	MoveBarRight
INT2			WORD	PrintMap

				ORIG    FE0Fh
INT15           WORD    Timer

;------------------------------------------------------------------------------
; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas
;------------------------------------------------------------------------------
                ORIG    0000h
                JMP     Main

;------------------------------------------------------------------------------
; Rotina de Interrupção Timer
; -> Responsável por toda a movimentação da bolinha, incluindo as colisões.
;------------------------------------------------------------------------------
Timer:		PUSH R1
			PUSH R2

			MOV R1, M[BallDirection]
			CMP R1, RIGHT_UP
			JMP.Z RightUp
			CMP R1, RIGHT_DOWN
			JMP.Z RightDown
			CMP R1, LEFT_UP
			JMP.Z LeftUp
			CMP R1, LEFT_DOWN
			JMP.Z LeftDown

			RightUp:	MOV R1, M[yBall]
						MOV R2, M[xBall]
						MOV R3, MAP_LINE_SIZE

						MUL R1, R3
						ADD R3, R2	
						MOV R2, Line0Map
						ADD R3, R2
						MOV R1, M[ R3 ]
						MOV R2, '='
						CMP R1, R2
						JMP.Z BrickDetected_RU
						JMP ContinueRightUp

					BrickDetected_RU: 	MOV R2, ' '
										MOV M[R3], R2
										
										CALL UpdateScore
										MOV R1, M[Flag]
										CMP R1, FALSE
										JMP.Z EndGame

										MOV R1, M[yBall]
										MOV R2, M[xBall]

										SHL R1, 8d
										OR R1, R2
										MOV M[CURSOR], R1
										MOV R1, ' '
										MOV M[IO_WRITE], R1

										MOV R1, M[yBall]
										MOV R2, M[xBall]
										INC R1
										INC R2
										MOV R3, MAP_LINE_SIZE

										MUL R1, R3
										ADD R3, R2
										MOV R2, Line0Map
										ADD R3, R2
										MOV R1, M[R3]
										MOV R2, ' '
										CMP R1, R2
										JMP.Z UpLine_RU

										MOV R1, M[yBall]
										MOV R2, M[xBall]
										DEC R1
										DEC R2
										MOV R3, MAP_LINE_SIZE

										MUL R1, R3
										ADD R3, R2
										MOV R2, Line0Map
										ADD R3, R2
										MOV R1, M[R3]
										MOV R2, ' '
										CMP R1, R2
										JMP.Z RightLine_RU

										MOV R1, LEFT_DOWN
										MOV M[BallDirection], R1
										JMP End

					ContinueRightUp:	MOV R1, M[yBall]
										MOV R2, M[xBall]
										
										CMP R1, TOP_ROW
										JMP.Z UpLine_RU
										CMP R2, RIGHT_COLUMN
										JMP.Z RightLine_RU

										MOV R1, M[yBall]
										MOV R2, M[xBall]

										SHL R1, 8d
										OR R1, R2
										MOV M[CURSOR], R1
										MOV R1, ' '
										MOV M[IO_WRITE], R1

										MOV R1, M[yBall]
										MOV R2, M[xBall]
										DEC R1
										INC R2

										MOV M[yBall], R1
										MOV M[xBall], R2

										SHL R1, 8d
										OR R1, R2
										MOV M[CURSOR], R1
										MOV R1, 'o'
										MOV M[IO_WRITE], R1
										JMP End

			RightDown:	MOV R1, M[yBall]
						MOV R2, M[xBall]

						MOV R3, MAP_LINE_SIZE

						MUL R1, R3
						ADD R3, R2	
						MOV R2, Line0Map
						ADD R3, R2
						MOV R1, M[ R3 ]
						MOV R2, '='
						CMP R1, R2
						JMP.Z BrickDetected_RD
						JMP ContinueRightDown

						BrickDetected_RD:	MOV R2, ' '
											MOV M[R3], R2
											
											CALL UpdateScore
											MOV R1, M[Flag]
											CMP R1, FALSE
											JMP.Z EndGame

											MOV R1, M[yBall]
											MOV R2, M[xBall]

											SHL R1, 8d
											OR R1, R2
											MOV M[CURSOR], R1
											MOV R1, ' '
											MOV M[IO_WRITE], R1

											MOV R1, M[yBall]
											MOV R2, M[xBall]
											DEC R1
											INC R2
											MOV R3, MAP_LINE_SIZE

											MUL R1, R3
											ADD R3, R2
											MOV R2, Line0Map
											ADD R3, R2
											MOV R1, M[R3]
											MOV R2, ' '
											CMP R1, R2
											JMP.Z DownLine_RD

											MOV R1, M[yBall]
											MOV R2, M[xBall]
											INC R1
											DEC R2
											MOV R3, MAP_LINE_SIZE

											MUL R1, R3
											ADD R3, R2
											MOV R2, Line0Map
											ADD R3, R2
											MOV R1, M[R3]
											MOV R2, ' '
											CMP R1, R2
											JMP.Z RightLine_RD

											MOV R1, LEFT_UP
											MOV M[BallDirection], R1
											JMP End

						ContinueRightDown: 	MOV R1, M[yBall]
											MOV R2, M[xBall]

											MOV R3, M[LeftColumnBar]

											CMP R1, BAR_ROW
											JMP.NZ NoBarCollision_RD
											CMP R2, R3
											JMP.NP NoBarCollision_RD

											MOV R4, BAR_COLUMN
											ADD R3, R4
											CMP R3, R2
											JMP.NP NoBarCollision_RD

											JMP DownLine_RD

											NoBarCollision_RD:	CMP R1, BOTTOM_ROW
																CALL.Z LoseLifes
																MOV R1, M[Lifes]
																CMP R1, 0d
																JMP.Z EndGame

																CMP R2, RIGHT_COLUMN
																JMP.Z RightLine_RD

																MOV R1, M[yBall]
																MOV R2, M[xBall]

																SHL R1, 8d
																OR R1, R2
																MOV M[CURSOR], R1
																MOV R1, ' '
																MOV M[IO_WRITE], R1

																MOV R1, M[yBall]
																MOV R2, M[xBall]
																INC R1
																INC R2

																MOV M[yBall], R1
																MOV M[xBall], R2

																SHL R1, 8d
																OR R1, R2
																MOV M[CURSOR], R1
																MOV R1, 'o'
																MOV M[IO_WRITE], R1
																JMP End

			LeftUp:		MOV R1, M[yBall]
						MOV R2, M[xBall]
						MOV R3, MAP_LINE_SIZE

						MUL R1, R3
						ADD R3, R2	
						MOV R2, Line0Map
						ADD R3, R2
						MOV R1, M[ R3 ]
						MOV R2, '='
						CMP R1, R2
						JMP.Z BrickDetected_LU
						JMP ContinueLeftUp

						BrickDetected_LU:	MOV R2, ' '
											MOV M[R3], R2

											CALL UpdateScore
											MOV R1, M[Flag]
											CMP R1, FALSE
											JMP.Z EndGame

											MOV R1, M[yBall]
											MOV R2, M[xBall]

											SHL R1, 8d
											OR R1, R2
											MOV M[CURSOR], R1
											MOV R1, ' '
											MOV M[IO_WRITE], R1

											MOV R1, M[yBall]
											MOV R2, M[xBall]
											INC R1
											DEC R2
											MOV R3, MAP_LINE_SIZE

											MUL R1, R3
											ADD R3, R2
											MOV R2, Line0Map
											ADD R3, R2
											MOV R1, M[R3]
											MOV R2, ' '
											CMP R1, R2
											JMP.Z UpLine_LU

											MOV R1, M[yBall]
											MOV R2, M[xBall]
											DEC R1
											INC R2
											MOV R3, MAP_LINE_SIZE

											MUL R1, R3
											ADD R3, R2
											MOV R2, Line0Map
											ADD R3, R2
											MOV R1, M[R3]
											MOV R2, ' '
											CMP R1, R2
											JMP.Z LeftLine_LU

											MOV R1, RIGHT_DOWN
											MOV M[BallDirection], R1
											JMP End
	
						ContinueLeftUp:	MOV R1, M[yBall]
										MOV R2, M[xBall]
										
										CMP R1, TOP_ROW
										JMP.Z UpLine_LU
										CMP R2, LEFT_COLUMN
										JMP.Z LeftLine_LU

										MOV R1, M[yBall]
										MOV R2, M[xBall]

										SHL R1, 8d
										OR R1, R2
										MOV M[CURSOR], R1
										MOV R1, ' '
										MOV M[IO_WRITE], R1

										MOV R1, M[yBall]
										MOV R2, M[xBall]
										DEC R1
										DEC R2

										MOV M[yBall], R1
										MOV M[xBall], R2

										SHL R1, 8d
										OR R1, R2
										MOV M[CURSOR], R1
										MOV R1, 'o'
										MOV M[IO_WRITE], R1
										JMP End
			
			LeftDown:	MOV R1, M[yBall]
						MOV R2, M[xBall]

						MOV R3, MAP_LINE_SIZE

						MUL R1, R3
						ADD R3, R2	
						MOV R2, Line0Map
						ADD R3, R2
						MOV R1, M[ R3 ]
						MOV R2, '='
						CMP R1, R2
						JMP.Z BrickDetected_LD
						JMP ContinueLeftDown

						BrickDetected_LD:	MOV R2, ' '
											MOV M[R3], R2

											CALL UpdateScore
											MOV R1, M[Flag]
											CMP R1, FALSE
											JMP.Z EndGame

											MOV R1, M[yBall]
											MOV R2, M[xBall]

											SHL R1, 8d
											OR R1, R2
											MOV M[CURSOR], R1
											MOV R1, ' '
											MOV M[IO_WRITE], R1

											MOV R1, M[yBall]
											MOV R2, M[xBall]
											DEC R1
											DEC R2
											MOV R3, MAP_LINE_SIZE

											MUL R1, R3
											ADD R3, R2
											MOV R2, Line0Map
											ADD R3, R2
											MOV R1, M[R3]
											MOV R2, ' '
											CMP R1, R2
											JMP.Z DownLine_LD

											MOV R1, M[yBall]
											MOV R2, M[xBall]
											INC R1
											INC R2
											MOV R3, MAP_LINE_SIZE

											MUL R1, R3
											ADD R3, R2
											MOV R2, Line0Map
											ADD R3, R2
											MOV R1, M[R3]
											MOV R2, ' '
											CMP R1, R2
											JMP.Z LeftLine_LD

											MOV R1, LEFT_UP
											MOV M[BallDirection], R1
											JMP End

						ContinueLeftDown:	MOV R1, M[yBall]
											MOV R2, M[xBall]
											MOV R3, M[LeftColumnBar]

											CMP R1, BAR_ROW
											JMP.NZ NoBarCollision_LD
											CMP R2, R3
											JMP.NP NoBarCollision_LD

											MOV R4, BAR_COLUMN
											ADD R3, R4
											CMP R3, R2
											JMP.NP NoBarCollision_LD

											JMP DownLine_LD

											NoBarCollision_LD:	CMP R1, BOTTOM_ROW
																CALL.Z LoseLifes
																MOV R1, M[Lifes]
																CMP R1, 0d
																JMP.Z EndGame

																CMP R2, LEFT_COLUMN
																JMP.Z LeftLine_LD

																MOV R1, M[yBall]
																MOV R2, M[xBall]

																SHL R1, 8d
																OR R1, R2
																MOV M[CURSOR], R1
																MOV R1, ' '
																MOV M[IO_WRITE], R1

																MOV R1, M[yBall]
																MOV R2, M[xBall]
																INC R1
																DEC R2

																MOV M[yBall], R1
																MOV M[xBall], R2

																SHL R1, 8d
																OR R1, R2
																MOV M[CURSOR], R1
																MOV R1, 'o'
																MOV M[IO_WRITE], R1
																JMP End

			UpLine_RU:	MOV R1, RIGHT_DOWN
						MOV M[BallDirection], R1
						JMP End
			
			RightLine_RU:	MOV R1, LEFT_UP
							MOV M[BallDirection], R1
							JMP End
			
			DownLine_RD:	MOV R1, RIGHT_UP
							MOV M[BallDirection], R1
							JMP End
			
			RightLine_RD:	MOV R1, LEFT_DOWN
							MOV M[BallDirection], R1
							JMP End

			UpLine_LU:	MOV R1, LEFT_DOWN
						MOV M[BallDirection], R1
						JMP End
			
			LeftLine_LU:	MOV R1, RIGHT_UP
							MOV M[BallDirection], R1
							JMP End

			DownLine_LD:	MOV R1, LEFT_UP
							MOV M[BallDirection], R1
							JMP End
			
			LeftLine_LD:	MOV R1, RIGHT_DOWN
							MOV M[BallDirection], R1
							JMP End

			End:	CALL SetTimer
					POP R2
					POP R1
					RTI

			EndGame: 	POP R2
						POP R1
						RTI

;------------------------------------------------------------------------------
; Rotina de Interrupção PrintMap
; -> Imprime o mapa do jogo.
;------------------------------------------------------------------------------
PrintMap:	PUSH R1
			PUSH R2

			MOV R1, M[Flag]
			CMP R1, TRUE
			JMP.Z EndMap

			MOV R1, Line0Map
			MOV M[StringToPrint], R1
			MOV R1, 0d
   			MOV M[LineNumberToPrint], R1

			CALL PrintLines

			MOV R1, TRUE
			MOV M[Flag], R1

			MOV R1, INITIAL_X
			MOV M[xBall], R1
			MOV R1, INITIAL_Y
			MOV M[yBall], R1

			MOV R1, RIGHT_UP
			MOV M[BallDirection], R1

			MOV R1, 3d
			MOV M[Lifes], R1

			CALL SetTimer
			JMP EndMap

			EndMap: POP R2
	        	 	POP R1
			     	RTI

;------------------------------------------------------------------------------
; Rotina de Interrupção MoveBarLeft e MoveBarRight
; -> Movimenta a barrinha para esquerda e para direita.
;------------------------------------------------------------------------------
MoveBarLeft: 	PUSH R1
				PUSH R2

				MOV R1, M[Flag]
				CMP R1, FALSE
				JMP.Z EndLeft

				MOV R4, M[Line]
				MOV R5, M[EmptySpace]
				
				MOV R3, 1d
				CMP R3, M[LeftColumnBar]
				JMP.Z EndLeft

				DEC M[LeftColumnBar]
				MOV R1, M[LeftColumnBar]

				MOV R2, LINE_BAR
				SHL R2, 8d
				OR R2, R1

				MOV	M[CURSOR], R2
				MOV M[IO_WRITE], R4

				MOV R2, LINE_BAR
				ADD R1, LENGTH_BAR
				SHL R2, 8d
				OR R2, R1

				MOV	M[CURSOR], R2
				MOV M[IO_WRITE], R5

				DEC M[LeftColumnBar]
				MOV R1, M[LeftColumnBar]

				MOV R2, LINE_BAR
				SHL R2, 8d
				OR R2, R1

				MOV	M[CURSOR], R2
				MOV M[IO_WRITE], R4

				MOV R2, LINE_BAR
				ADD R1, LENGTH_BAR
				SHL R2, 8d
				OR R2, R1

				MOV	M[CURSOR], R2
				MOV M[IO_WRITE], R5

				EndLeft: 	POP R2
							POP R1
							RTI

MoveBarRight: 	PUSH R1
				PUSH R2

				MOV R1, M[Flag]
				CMP R1, FALSE
				JMP.Z EndRight

				MOV R3, 79d
				MOV R4, M[EmptySpace]
				MOV R5, M[Line]
				MOV R6, LENGTH_BAR
				MOV R7, M[LeftColumnBar]
				ADD R6, R7

				CMP R3, R6
				JMP.Z EndRight

				MOV R1, M[LeftColumnBar]

				MOV R2, LINE_BAR
				SHL R2, 8d
				OR R2, R1

				MOV	M[CURSOR], R2
				MOV M[IO_WRITE], R4
				
				MOV R2, LINE_BAR
				ADD R1, LENGTH_BAR
				SHL R2, 8d
				OR R2, R1

				MOV	M[CURSOR], R2
				MOV M[IO_WRITE], R5

				INC M[LeftColumnBar]
				MOV R1, M[LeftColumnBar]

				MOV R6, LENGTH_BAR
				MOV R7, M[LeftColumnBar]
				ADD R6, R7

				CMP R3, R6
				JMP.Z EndRight

				MOV R1, M[LeftColumnBar]

				MOV R2, LINE_BAR
				SHL R2, 8d
				OR R2, R1

				MOV	M[CURSOR], R2
				MOV M[IO_WRITE], R4
				
				MOV R2, LINE_BAR
				ADD R1, LENGTH_BAR
				SHL R2, 8d
				OR R2, R1

				MOV	M[CURSOR], R2
				MOV M[IO_WRITE], R5

				INC M[LeftColumnBar]
				MOV R1, M[LeftColumnBar]

				EndRight:	POP R2
							POP R1
							RTI

;------------------------------------------------------------------------------
; Função PrintLines
; -> Imprime 24 linhas com 80 colunas.
;------------------------------------------------------------------------------
PrintLines:	PUSH R1
			PUSH R2
			MOV R4, M[StringToPrint]

			while_Columns:	MOV R2, 0d

			while_Lines: 	MOV R1, M[LineNumberToPrint]
							MOV R3, M[R4]

							SHL R1, 8d
							OR R1, R2
							MOV M[CURSOR], R1
							MOV M[IO_WRITE], R3

							INC R2
							INC R4

							CMP R2, 80d
							JMP.NZ while_Lines

							MOV R1, M[LineNumberToPrint]
							INC R1
							MOV M[LineNumberToPrint], R1

							CMP R1, 24d
							JMP.NZ while_Columns

			POP R2
			POP R1
			RET

;------------------------------------------------------------------------------
; Função PrintString
; -> Imprime uma string.
;------------------------------------------------------------------------------
PrintString:	PUSH R1
				PUSH R2

				MOV R2, 0d

				while: 	MOV R1, M[LineNumberToPrint]
						MOV R4, M[StringToPrint]
						ADD R4, R2
						MOV R3, M[R4]

						SHL R1, 8d
						OR R1, R2
						MOV M[CURSOR], R1
						MOV M[IO_WRITE], R3

						INC R2
						CMP R2, 80d
						JMP.NZ while

						POP R2
						POP R1
						RET

;------------------------------------------------------------------------------
; Função PrintLoad
; -> Imprime a tela de carregamento inicial.
;------------------------------------------------------------------------------
PrintLoad:	PUSH R1
			PUSH R2

			MOV R1, Line0Load
			MOV M[StringToPrint], R1
			MOV R1, 0d
   			MOV M[LineNumberToPrint], R1

			CALL PrintLines

			POP R2
	        POP R1
			RET

;------------------------------------------------------------------------------
; Função SetTimer
; -> Ativa o temporizador e define seu intervalo de tempo.
;------------------------------------------------------------------------------
SetTimer:	PUSH R1

			MOV R1, 1d
			MOV M[TIMER_UNITS], R1

			MOV R1, 1d
			MOV M[ACTIVATE_TIMER], R1

			POP R1
			RET

;------------------------------------------------------------------------------
; Função LoseLifes
; -> Diminui as vidas e imprime a string de derrota caso as vidas sejam < 3.
;------------------------------------------------------------------------------
LoseLifes:	PUSH R1
			PUSH R2

			MOV R1, M[Lifes]
			CMP R1, 3d
			JMP.Z LoseFirstLife
			CMP R1, 2d
			JMP.Z LoseSecondLife
			CMP R1, 1d
			JMP.Z LoseThirdLife

			LoseFirstLife:	MOV R1, 2d
							MOV M[Lifes], R1

							MOV R1, M[yBall]
							MOV R2, M[xBall]

							SHL R1, 8d
							OR R1, R2
							MOV M[CURSOR], R1
							MOV R2, M[EmptySpace]
							MOV M[IO_WRITE], R2
			
							MOV R1, INITIAL_X
							MOV M[xBall], R1
							MOV R1, INITIAL_Y
							MOV M[yBall], R1

							MOV R1, LEFT_UP
							MOV M[BallDirection], R1

							MOV R1, 0d
							MOV R2, 30d

							SHL R1, 8d
							OR R1, R2
							MOV M[CURSOR], R1
							MOV R2, M[EmptySpace]
							MOV M[IO_WRITE], R2

							MOV R1, 0d
							MOV R2, 29d

							SHL R1, 8d
							OR R1, R2
							MOV M[CURSOR], R1
							MOV R2, M[EmptySpace]
							MOV M[IO_WRITE], R2
							JMP End_LF
			
			LoseSecondLife: MOV R1, 1d
							MOV M[Lifes], R1

							MOV R1, M[yBall]
							MOV R2, M[xBall]

							SHL R1, 8d
							OR R1, R2
							MOV M[CURSOR], R1
							MOV R2, M[EmptySpace]
							MOV M[IO_WRITE], R2
			
							MOV R1, INITIAL_X
							MOV M[xBall], R1
							MOV R1, INITIAL_Y
							MOV M[yBall], R1

							MOV R1, RIGHT_UP
							MOV M[BallDirection], R1

							MOV R1, 0d
							MOV R2, 27d

							SHL R1, 8d
							OR R1, R2
							MOV M[CURSOR], R1
							MOV R2, M[EmptySpace]
							MOV M[IO_WRITE], R2

							MOV R1, 0d
							MOV R2, 26d

							SHL R1, 8d
							OR R1, R2
							MOV M[CURSOR], R1
							MOV R2, M[EmptySpace]
							MOV M[IO_WRITE], R2
							JMP End_LF

			LoseThirdLife:  MOV R1, 0d
							MOV M[Lifes], R1
							
							MOV R1, M[yBall]
							MOV R2, M[xBall]

							SHL R1, 8d
							OR R1, R2
							MOV M[CURSOR], R1
							MOV R2, M[EmptySpace]
							MOV M[IO_WRITE], R2

							MOV R1, 0d
							MOV R2, 24d

							SHL R1, 8d
							OR R1, R2
							MOV M[CURSOR], R1
							MOV R2, M[EmptySpace]
							MOV M[IO_WRITE], R2

							MOV R1, 0d
							MOV R2, 23d

							SHL R1, 8d
							OR R1, R2
							MOV M[CURSOR], R1
							MOV R2, M[EmptySpace]
							MOV M[IO_WRITE], R2

							MOV R1, 0d
							MOV M[ACTIVATE_TIMER], R1

							MOV R1, LineLoose
							MOV M[StringToPrint], R1
							MOV R1, 15d
   							MOV M[LineNumberToPrint], R1

							CALL PrintString

							MOV R1, FALSE
							MOV M[Flag], R1
							JMP End_LF
		
			End_LF: POP R2
					POP R1
					RET

;----------------------------------------------------------------------------------------
; Função UpdateScore
; -> Aumenta o score em 1 e imprime a tela de vitória caso chegue na pontuação máxima.
;----------------------------------------------------------------------------------------
UpdateScore:	PUSH R1
				PUSH R2
				PUSH R3

				INC M[Score]
				MOV R1, M[Score]
				MOV R2, 100d

				DIV R1, R2
				ADD R1, BASE_ASCII
				MOV R3, 0d
				MOV R4, COLUMN_HUNDREDS
				SHL R3, 8d
				OR R3, R4
				MOV M[CURSOR], R3
				MOV M[IO_WRITE], R1

				MOV R1, 10d
				DIV R2, R1
				
				ADD R2, BASE_ASCII
				MOV R3, 0d
				MOV R4, COLUMN_TENTHS
				SHL R3, 8d
				OR R3, R4
				MOV M[CURSOR], R3
				MOV M[IO_WRITE], R2

				ADD R1, BASE_ASCII
				MOV R3, 0d
				MOV R4, COLUMN_UNIT
				SHL R3, 8d
				OR R3, R4
				MOV M[CURSOR], R3
				MOV M[IO_WRITE], R1

				MOV R1, M[Score]
				MOV R2, 100d

				DIV R1, R2
				CMP R1, 3d
				JMP.Z WinGame

				JMP EndScore

				WinGame: 	MOV R1, M[yBall]
							MOV R2, M[xBall]

							SHL R1, 8d
							OR R1, R2
							MOV M[CURSOR], R1
							MOV R2, M[EmptySpace]
							MOV M[IO_WRITE], R2
				
							MOV R1, 0d
							MOV M[ACTIVATE_TIMER], R1

							MOV R1, LineWin
							MOV M[StringToPrint], R1
							MOV R1, 15d
   							MOV M[LineNumberToPrint], R1

							CALL PrintString

							MOV R1, FALSE
							MOV M[Flag], R1
							JMP EndScore

				EndScore: 	POP R3
							POP R2
							POP R1
							RET
							
;---------------------------------------------------------------------------------------------
; Função Main
; -> Inicializa as variáveis de ambiente e chama a função que imprime a tela de carregamento.
;---------------------------------------------------------------------------------------------
Main:	ENI

		MOV R1, INITIAL_SP
		MOV SP, R1		 		; We need to initialize the stack
		MOV R1, CURSOR_INIT		; We need to initialize the cursor 
		MOV M[CURSOR], R1		; with value CURSOR_INIT

		CALL PrintLoad

Cycle: 	BR	Cycle	
Halt:   BR	Halt