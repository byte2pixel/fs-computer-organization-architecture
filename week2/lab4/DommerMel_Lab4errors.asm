#########################################################################################
#The .data section is memory that is allocated in the data segment of memory 		#
#Include the following in this section.  						#
#Use the .space directive to allocate several things:					#
#	space for user input								#
#Use .asciiz directive to create several things (not limited to):			#
#	a user prompt									#
#	a user notification of the legnth of their entry				#
#########################################################################################
		.data
buffer:		.space 	101
prompt:		.asciiz	"Type a string and press enter.\nI will tell you how many characters are in the string!\n"
final_count:	.asciiz "\nThe total characters of the string is: "

#########################################################################################
#The .text section is executed at runtime.						#
#Include the following in this section.  						#	
#Ask user for a string input.								#
#Call the stringLen by using the jal instruction and the appropriate label.		#
#	use caller/callee convention							#
#	pass any argument(s) by placing them in the $a0-$a3 registers			#
#	#read any return values by looking in $v0-$v1 after calling the function	#
#Print out the length of the user input.						#					#
#Exit syscall										#
#########################################################################################
		.text
		li	$v0,	4
		la	$a0,	prompt	# prints prompt
		syscall
		
		li	$v0,	8	# read string syscall
		li	$a1,	101	# read up to 101 (100 + null)
		la 	$a0,	buffer
		syscall
		
		jal	StringLen
		move	$t0,	$v0		# store the length
		
		li	$v0,	4		# print out the results of stringlenth
		la	$a0,	final_count	# Print the final count text
		syscall
		
		li	$v0,	1		# Print the count
		move	$a0,	$t0		# move the count into $a0
		syscall
		
		li 	$v0,	10		# exit the program
		syscall

		# function to figure out string length
StringLen: 	move	$t0,	$a0 		# moves address (from $a0 to $t0) that was passed in from the main part of the program
		li	$t1,	0		# counter for number of characters. Set to 0
		
loop:		lb	$t2,	0($t0) 		# loads the first byte of the word into $t2
		beq	$t2,	0,	done	# if the current byte is a null space, go to exit
		beq	$t2,	10,	done	# if the current byte is a new line, go to exit

		addi 	$t1,	$t1,	1 	# adds 1 to the counter
		addi	$t0,	$t0,	1	# adds 1 to the address to (next character)
		j 	loop 
		
done:		move	$v0,	$t1		# moves the result of counter to $v0 so the main part of the program can "see" it
		jr	$ra