;				Nurefsan Altin	150210053

Capacity 		EQU 0x08		; Capacity = 50
Size			EQU	0x04		; Size = 3
	
				AREA iterative, code, readonly
				ENTRY
				ALIGN
					
__main			FUNCTION
				EXPORT __main
				
				MOVS		R2,#4
				LDR			r1,=0x20000000
				MOVS		r0,#4
loop			STR			r0,[r1]
				adds		R0,R0,#1
				ADDS		r1,r1,#4
				SUBS		r2,r2,#1
				BNE			loop
				
				LDR			r1,=0x20000000
				LDM			R1!, {R3,R4,R5,R6}
				
				PUSH		{R3,R4,R5,R6}

				








					
stop			B 		stop
				ALIGN
				ENDFUNC




				END