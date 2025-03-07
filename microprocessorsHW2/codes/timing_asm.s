        AREA    Timing_Code, CODE, READONLY
        ALIGN
        THUMB
        EXPORT  Systick_Start_asm
        EXPORT  Systick_Stop_asm
		EXPORT	SysTick_Handler ; When the correct time comes,
									; remove this from the comments.
		EXTERN	ticks

SysTick_Handler FUNCTION
		PUSH	{LR}
		PUSH	{R2}						; push the registers we will modify in this function
		PUSH	{R3}						; push the registers we will modify in this function
		LDR		R3,=ticks					; load the address of ticks
		LDR		R2,[R3]						; load value of the ticks into R2
		ADDS	R2,#1						; increment the ticks value by 1
		STR		R2,[R3]						; store the modified value of ticks
		POP		{R3}						; pop the registers we will modify in this function
		POP		{R2}						; pop the registers we will modify in this function
		POP		{PC}
		ENDFUNC

Systick_Start_asm FUNCTION
		PUSH	{LR}
		PUSH	{R0-R2}						; push the registers we will modify in this function
		BL		Systick_Stop_asm			; stop the timer at first	 
		; Interval = 10us, SystemCoreClock = 25.000.000
		; Interval = (ReloadValue+1)/SystemCoreClock
		; ReloadValue +1 = SystemCoreClock * Interval
		; ReloadValue + 1 = 25.000.000 / 100000
		; ReloadValue = 249
		LDR		R0,=0xE000E014				; load reload value register's address
		LDR		R1,=249						; reload value 
		STR		R1, [R0]					; load the reload value into reload value register
		LDR		R0,=0xE000E018				; load current value register's address
		MOVS	R1,#0						; current value
		STR		R1,[R0]						; clear current value register
		LDR		R0,=0xE000E010				; load the control and status register's address
		LDR  	R1, [R0]					; get the value inside the control and status register
		MOVS 	R2, #7						; move decimal 7 (binary 111) into R2, this will used to enable CLKSOURCE, TICKINT, and ENABLE flags
		ORRS 	R1, R1, R2					; apply OR operation to set CLKSOURCE, TICKINT, and ENABLE flags
		STR  	R1, [R0]					; update the control and status register					
		POP  	{R0-R2}						; pop the registers we have modified in this function
		POP		{PC}
		ENDFUNC

Systick_Stop_asm FUNCTION
		PUSH	{LR}
		PUSH	{R1-R3}						; push the registers we will modify in this function
		LDR		R0,=0xE000E010				; load the control and status register's address
		LDR		R1,[R0]						; get the value inside the control and status register
		LDR		R2,=0xFFFFFFFC				; load masking value, this will used to disable timer and interrupt
		ANDS 	R1, R1, R2					; apply AND operation to clear TICKINT and ENABLE flags
		STR  	R1, [R0]					; update the control and status register
		LDR		R3,=ticks					; load the address of ticks 
		LDR		R0,[R3]						; load non-zero value of the ticks into R0, this will be the return value
		MOVS	R2,#0						; move 0 into R2
		STR		R2,[R3]						; assign 0 to ticks
		POP  	{R1-R3}						; pop the registers we have modified in this function
		POP		{PC}
		ENDFUNC

		END
