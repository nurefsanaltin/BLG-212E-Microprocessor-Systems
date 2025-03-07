;				Nurefsan Altin	150210053

Capacity 		EQU 0x32		; Capacity = 50
Size			EQU	0x03		; Size = 3
	
				AREA iterative, code, readonly
				ENTRY
				ALIGN
					
__main			FUNCTION
				EXPORT __main

				MOVS	r0,#0					; initialize the return value
				LDR		r1,=profit_array		; load start address of the profit array
				LDR		r2,=weight_array		; load start address of the weight array
				LDR		r3,=dp_array			; load start address of the dp array				
				MOVS 	r4,#4					; i = 1 as index value (move 4 for word)	
				MOVS 	r5,#Size				; load size to use for conditional control
				LSLS	r5,r5,#2				; multiply the size by 4 to calculate total size of array (4 for each word)
				MOVS	r6,#Capacity			; load capacity of the bag

				ADDS	r5,r5,#4				; n+1 (incremented by 4 for word)
				
				; initialize the dp array with zero in all entries
				PUSH	{r3,r6}					; save their values into stack bc we will modify them in initializeDp branch
				ADDS	r6,r6,#1				; we need to increase capacity by 1 when initializing bc my array's size is capacity + 1
				B		initializeDp			; branch for initialize
				; after initialization we will continue with loop 1


loop1			CMP		r4,r5					; check if i < n+1, compare array size and current index to finish the loop1
				BGE		getReturnValue			; stop if i >= n+1

loop2			CMP		r6,#0					; check if w >= 0
				BLT		endOfLoop2				; if w<0, we finish the loop2
				PUSH	{r4}					; save r4 to not lose its value since we decrement it later
				SUBS	r4,r4,#4				; decrement index i by 1 -> i-1 (decremented by 4 for word)
				LDR		r7,[r2,r4]				; load weight[i-1] to temp register r7
				CMP		r7,r6					; check if weight[i-1] <= w
				BLE		max						; go for calculating max value in case of suitable weight
				SUBS	r6,r6,#1				; decrement w by 1 for next iteration -> w--
				POP		{r4}					; store r4's value back from the stack
				B		loop2					; return back to loop2 for next iteration with decremented w

max				PUSH	{r6}					; save r6 into stack in order to remember its value bc we will need extra registers in this part and use r6 for this purpose
				LSLS	r6,r6, #2				; arrange the index according to word size, multiply by 4 by applying logical shift left
				LDR		r0,[r3,r6]				; load dp[w] value into R0
				POP		{r6}					; store r6's value back from the stack;
				PUSH	{r6}					; save r6 into stack in order to remember its value bc we will need extra registers in this part and use r6 for this purpose
				SUBS	r6,r6,r7				; calculate w-weight[i-1]
				LSLS	r6,r6, #2				; arrange the index according to word size, multiply by 4 by applying logical shift left
				LDR		r6,[r3,r6]				; load dp[w - weight[i-1]] into r6
				PUSH	{r3}					; save r3 into stack in order to remember its value bc we will need extra registers in this part and use r3 for this purpose
				LDR		r3,[r1,r4]				; load profit[i-1] into r3
				ADDS	r6,r6,r3				; calculate dp[w - weight[i-1]] + profit[i-1]
				POP		{r3}					; store R3's value back from the stack
				CMP		r6,r0					; check for the max of dp[w] and dp[w - weight[i-1]] + profit[i-1]
				BGE		includeCurrent			; if dp[w - weight[i-1]] + profit[i-1] is larger, which means we include current object then branch to includeCurrent
storeMax		POP		{r6}					; store R6's value back from the stack
				PUSH	{r6}					; push r6 into stack in order to remember its value bc we will update its value according to word size to use it as an index value in dp array
				LSLS	r6,r6, #2				; arrange the index according to word size, multiply by 4 by applying logical shift left
				STR		r0,[r3,r6]				; store r0's value -current max- into dp array
				POP		{r6}					; store r6's value back from the stack
				SUBS	r6,r6,#1				; decrement w by 1 for next iteration -> w--
				POP		{r4}					; store R4's value back from the stack
				B		loop2					; go back to loop2
				
				
includeCurrent	MOVS	r0,r6					; update r0 by the new max value
				B		storeMax				; go back to store max value in dp array

endOfLoop2		ADDS	r4,r4,#4				; increment index i by 1 ->i++
				MOVS	r6,#Capacity			; update the capacity register for weight checking in loop2
				B		loop1					; go back loop1


				; Initialize dp array

initializeDp	STR		r0,[r3]					; store 0 (I used r0 bc its value is already zero)
				ADDS	r3,r3,#4				; increment r3 by 4 for next iteration
				SUBS	r6,r6,#1				; decrement capacity to check if we finished writing
				BNE		initializeDp			; if capacity is not zero than continue with next iteration
				POP		{r3,r6}					; if we finished, pop r3 and r6 back from the stack
			    B 		loop1					; branch loop1
				

				; Final edits before we stop 
				
getReturnValue	MOVS	r6,#Capacity			; move capacity to r6 
				LSLS	r6,r6, #2				; arrange the index according to word size, multiply by 4 by applying logical shift left
				LDR		r0,[r3,r6]				; load ro from dp array as return value -> dp[w]
				LDR		r1,=profit_array		; r1 stores the starting address of profit array
				LDR		r2,=weight_array		; r2 stores the starting address of weight array
				LDR		r3,=dp_array			; r3 stores the starting address of dp array
				B		stop					; stop the function
					
stop			B 		stop
				ALIGN
				ENDFUNC

profit_array 	DCD		60,100,120					; define profit array
profit_end

weight_array 	DCD		10,20,30					; define weight array
weight_end

				AREA DataSection, DATA, READWRITE
dp_array 		SPACE	(Capacity+1)*4 			; dp array 
dp_end


				END