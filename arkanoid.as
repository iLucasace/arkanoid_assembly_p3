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
ROW_POSITION	EQU		0d
COL_POSITION	EQU		0d
ROW_SHIFT		EQU		8d
COLUMN_SHIFT	EQU		8d

LINE_BAR        EQU     20d
LENGTH_BAR		EQU     30d

;------------------------------------------------------------------------------
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
Line17Load  STR '                                                                                '
Line18Load  STR '                                                                                '
Line19Load  STR '                                                                                '
Line20Load  STR '                        -> PRESS P TO START THE GAME <-                         '
Line21Load  STR '                                                                                '
Line22Load  STR '                                                                                '
Line23Load  STR '                                                                                ', FIM_TEXTO


Line0Map	STR '   Score: 00 | Lifes: S2 S2 S2                                        Arkanoid  '
Line1Map	STR '|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|'
Line2Map	STR '|                                                                              |'
Line3Map	STR '|                                                                              |'
Line4Map	STR '|         ============================================================         |'
Line5Map   	STR '|         ============================================================         |'
Line6Map   	STR '|         ============================================================         |'
Line7Map   	STR '|         ============================================================         |'
Line8Map   	STR '|         ============================================================         |'
Line9Map   	STR '|                                                                              |'
Line10Map  	STR '|                                                                              |'
Line11Map  	STR '|                                                                              |'
Line12Map  	STR '|                                                                              |'
Line13Map  	STR '|                                                                              |'
Line14Map  	STR '|                                                                              |'
Line15Map  	STR '|                                                                              |'
Line16Map  	STR '|                                      o                                       |'
Line17Map  	STR '|                                                                              |'
Line18Map  	STR '|                                                                              |'
Line19Map  	STR '|                                                                              |'
Line20Map  	STR '|                        ------------------------------                        |'
Line21Map  	STR '|                                                                              |'
Line22Map  	STR '|                                                                              |'
Line23Map  	STR '|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|', FIM_TEXTO

StringToPrint 		WORD 0d  ; Endereco da string que será impressa
LineNumberToPrint 	WORD 0d  ; Número da linha que será impressa
LeftColumnBar 		WORD 25d

Line				STR '-'
EmptySpace			STR ' '

;------------------------------------------------------------------------------
; ZONA II: definicao de tabela de interrupções
;------------------------------------------------------------------------------
                ORIG    FE00h
INT0			WORD	MoveBarLeft
INT1			WORD	MoveBarRight
INT2			WORD	PrintMap

;------------------------------------------------------------------------------
; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas
;------------------------------------------------------------------------------
                ORIG    0000h
                JMP     Main

;------------------------------------------------------------------------------
; Rotina de Interrupção MoveBarLeft e MoveBarRight
;------------------------------------------------------------------------------
MoveBarLeft: 	PUSH R1
				PUSH R2

				MOV R4, M[Line]
				MOV R5, M[EmptySpace]
				
				MOV R3, 1d
				CMP R3, M[LeftColumnBar]
				JMP.Z EndLeft

				MOV R1, M[ LeftColumnBar ]
				DEC M[ LeftColumnBar ]
				MOV R1, M[ LeftColumnBar ]

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

				EndRight:	POP R2
							POP R1
							RTI

;------------------------------------------------------------------------------
; Funções para imprimir o mapa
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

PrintMap:	PUSH R1
			PUSH R2

			MOV R1, Line0Map
			MOV M[StringToPrint], R1
			MOV R1, 0d
   			MOV M[LineNumberToPrint], R1

			CALL PrintLines

			POP R2
	        POP R1
			RTI

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
; Função Main
;------------------------------------------------------------------------------
Main:	ENI

		MOV R1, INITIAL_SP
		MOV SP, R1		 	; We need to initialize the stack
		MOV R1, CURSOR_INIT		; We need to initialize the cursor 
		MOV M[CURSOR], R1		; with value CURSOR_INIT

		CALL PrintLoad

Cycle: 	BR	Cycle	
Halt:   BR	Halt
