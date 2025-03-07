; Function: ft_lstsort_asm
; Parameters:
;   R0 - Pointer to the list (address of t_list *)
;   R1 - Pointer to comparison function (address of int (*f_comp)(int, int))
        AREA    Sorting_Code, CODE, READONLY
        ALIGN
        THUMB
        EXPORT  ft_lstsort_asm

ft_lstsort_asm FUNCTION
			PUSH	{R0-R1, LR}
			LDR		R3, [SP]	 						; first argument of the function in R3, starting address of list
			LDR		R4, [SP, #4] 						; second argument of the function in R4, the address of ft_comp function
			LDR		R7, [R3]							; store the starting adress of list in R7
			
; SUBROUTINE TO CALCULATE LIST LENGTH
			LDR		R2,	[R3]							; load the starting address of list into R2
findLenght	LDR		R1, [R2]							; get the first element of the list
			MOVS	R6, #0								; R6 is the return value so we initialize it az zero
			CMP		R1, #0								; compare the current element with zero to check if the list is empty 		
			BEQ		end
			
looplength	ADDS	R6, #1								; R6 stores the length of the list, increment it by 1 in each iteration
			LDR		R1, [R2,#4]							; store next's address into R1
			CMP		R1, #0								; check if next's address is NULL 
			BEQ		end									; finish subroutine if next's address is NULL
			MOVS	R2, R1								; if not, continue with the next element by updating current
			B		looplength
end
	
;BUBBLE SORT STARTS
; R6 stores the length of the list at the beginning, but it will also store the previous node. I used it for both since registers are not enough
; R7 stores the starting address of list at the beginning, R7 is the iterator so it will be updated in each iteration and hold the current node
; R0 will store the next_node and it will be updated in each iteration
; R1 is the index for iteration

			MOVS	R1, #0								; index for iteration
BUBBLESORT	PUSH	{R6}								; R6 will be used for another purposes later since the registers are not enough, so it is pushed into stack to remember its value 
			PUSH	{R7}								; push the current head into stack
			CMP		R1,R6								; while(index < length)
			BGE		endbubble							; finish if index >= length
			MOVS	R6,R7								; R6 will store the previous node in each iteration, firstly it is assigned as the current head
loop		LDR		R0, [R7,#4]							; get the address of next
			CMP		R0, #0								; while(current->next)
			BEQ		endloop								; finish the inner loop if next_node==null 
			PUSH	{R0}								; push next_node's address to remember it later
			PUSH	{R7}								; push current's address to remember it later
			LDR		R5, [R7]							; get current's value
			LDR		R3, [R0]							; get next_node's value	
			PUSH	{R1,R3}								; push these register's content to not lose them with function call ft_comp
			MOVS 	R0, R3								; R0 is the first argument for ft_comp function (next_node's value)
			MOVS 	R1, R5								; R1 is the second argument for ft_comp function (current's value)
			BLX 	R4									; R4 stores the address of ft_comp function, we link and branch to this function			
			POP		{R1,R3}								; pop these register's content back from the stack
			MOVS	R3,R0								; R0 stores the return value of the ft_comp function, move it to R3 to use later
			POP		{R7}								; pop current's address
			POP		{R0}								; pop next_node's address
			CMP 	R3, #1								; R3 now holds the return value of ft_comp function, 1 if next_node<current , 0 if current>next_node
			BEQ		swap								; if next_node < current than we should swap the nodes
			B		getnext								; if not we directly jump to update the current node and continue with next iteration
swap		LDR		R3,	[R0,#4]							; R0 now stores the next_node's address, we save the next_node's next to use it later
			STR		R7,[R0,#4]							; we update next_node's next, next_node->next becomes current's address (next_node->next = current)
			STR		R3,[R7,#4]							; we update the current's next with the value we saved before, current->next becomes next_node->next (current->next = next_node->next)		
			;check if we need to change the head
			POP		{R5}								; pop the current head from the stack
			CMP		R5,R7								; compare it with current node
			BEQ		updatehead							; if they are equal then we need to update the head
			PUSH	{R5}								; if not, head remains the same, so push the same value into stack
			STR		R0,[R6,#4]							; we update the previous node's next, previous->next becomes the next_node (previous->next = next_node)
			MOVS	R6,R0								; we update the previous node for the next iteration, next_node node becomes the previous (previous = next_node) 
			B		loop								; continue with the loop
			
getnext		MOVS	R6,R7								; if we are not swapping, update the previous node as current node (previous = current)
			LDR		R7,[R7,#4]							; update the current node as the next_node (current = current->next)
			B		loop								; continue with the loop


updatehead 	MOVS	R6,R0 								; we swapped therefore we update the previous node for the next iteration, next_node node becomes the previous (previous = next_node)
			PUSH	{R0}								; head updated as the next_node, we push its value into stack because we store the head in stack
			B 		loop								; continue with the loop


endloop		ADDS	R1,#1								; increment the index value by 1
			POP		{R7}								; pop the current head from the stack, now R7 will store the head of the list back
			POP		{R6}								; pop the length of the list from the stack, now R6 will store the length of the list back
			B		BUBBLESORT							; finish the inner loop

endbubble	POP		{R7}								; pop the values we pushed into stack, R7 is the head of the list
			POP		{R6}								; pop the values we pushed into stack, R6 is the lenght of the list
			POP		{R0}								; we need to update the area's starting address since the head might be changed. It is stored in some memory location that pushed into stack. Firstly we pop this location
			STR		R7,[R0]								; we store the final head(stored in R7) in this memory location
			PUSH 	{R0}								; we push this memory location into stack back to have its value properly after returning back from the function
			POP		{R0-R1, PC}
			ENDFUNC
