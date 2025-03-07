;				Nurefsan Altin	150210053


Capacity 		EQU 0x32		; Capacity = 50
Size			EQU	0x03		; Size = 3
	
				AREA recursive, code, readonly
				ENTRY
				ALIGN
					
__main			FUNCTION
				EXPORT __main
					
				MOVS	r0,#0				; initialize the return value
				LDR		r1,=profit_array	; load start address of the profit array
				LDR		r2,=weight_array	; load start address of the weight array
				MOVS 	r4,#Size			; load size to use for conditional control
				MOVS	r5,#Capacity		; load capacity of the bag

				BL		knapsack			; branch and link to knapsack function
				B		stop				; stop when we finish
				
knapsack		PUSH	{LR}				; push LR into stack to preserve returning address in case of recursive calls
				CMP		r4,#0				; if n == 0
				BEQ		base_case			; go to base case
				CMP		r5,#0				; if w == 0
				BEQ		base_case			; go to base case
				PUSH	{R4}				; store r4 to remember its value bc we will need its old value after we back from recursive calls
				SUBS	r4,r4,#1			; calculate n-1
				LSLS	r4,r4,#2			; multiply n-1 by 4 (using logical shift left) for proper indexing (4 for a word)
				LDR		r6,[r2,r4]			; weight[n-1]
				CMP		r6,r5				; compare weight[n-1] > w 
				BGT		skip_item			; if current item's weight is more than the capacity than skip this item and continue
				LSRS	r4,r4,#2			; divide [n-1] by 4 in order to go back value before we multiply (4 for a word)		
				SUBS	r3,r5,r6			; calculate weight[n-1] - w
				PUSH	{r3}				; save weight[n-1] - w into stack to use it as new weight value in second recursive call			
				BL		knapsack			; first recursive call for knapsack(W, n-1)
				POP		{r5}				; when we return from first recursive call, pop r5 from the stack as weight[n-1] - w for the second recursive call 
				PUSH	{r0}				; save knapsack(W, n-1)'s return value into stack to remember when we are comparing
				BL		knapsack			; second recursive call for knapsack(W-weight[n-1], n-1)
				POP		{r7}				; pop the knapsack(W, n-1)'s return value back from the stack bc we use it for comparison
				LSLS	r4,r4,#2			; multiply [n-1] by 4 for proper indexing (4 for a word)
				LDR		r3,[r1,r4]			; profit[n-1]
				ADDS	r0,r0,r3			; calculate profit[n-1] + knapsack(W-weight[n-1], n-1)
				POP		{r4}				; save r4's value back from the stack
				CMP		r7,r0				; compare knapsack(W, n-1) and profit[n-1] + knapsack(W-weight[n-1], n-1) to find which one is larger
				BGT		update				; if knapsack(W, n-1) is larger then we need to update r0's content as the return value of knapsack(W, n-1)
				POP		{PC}				; continue with last instruction available in the stack
				
update			MOV		r0,r7				; if r7 > r0 than update r0 as having the same value with r7
				POP		{PC}				; continue with last instruction available in the stack
				
skip_item		LSRS	r4,r4,#2			; divide [n-1] by 4 in order to go back value before we multiply (4 for a word)
				BL		knapsack			; recursive call for knapsack(W,n-1)
				POP		{r4}				; save r4's value back from the stack
				POP		{PC}				; continue with last instruction available in the stack
									
base_case		MOVS	r0,#0				; store 0 in r0 as we are in the base case
				POP		{PC}				; continue with last instruction available in the stack

stop			B		stop				; infitine loop for stop
				ALIGN
				ENDFUNC

profit_array 	DCD		60,100,120			; define profit array
profit_end

weight_array 	DCD		10,20,30			; define weight array
weight_end


				END