######################################################################
# Author: Mel Dommer                                                 #
#   Date: 2025-12-06                                                 #
#                                                                    #
# ATOI (16-bit unsigned version)                                     #
#                                                                    #
# This program takes an ASCII string representation of a number and  #
# converts it to a 16-bit unsigned integer.                          #
#                                                                    #
######################################################################
        .data
buffer:		.space 		6		# Changed: max 5 digits + null for 65535
instructions:	.asciiz		"You can enter any positive number from 0 to 65535 and this program will convert the string to integer.\n"  # Changed
prompt:		.asciiz		"Enter your number (0-65535): "  # Changed
error_char:	.asciiz		"\nYou didn't enter a valid number\nUse only 0-9. Try again.\n"
error_ovflow:	.asciiz		"\nYou entered a number that is too large to fit into 16-bits (0-65535). Try again.\n"  # Changed
error_unknown:	.asciiz		"\nYou encountered an unknown error, program will exit.\nConsider yourself the ultimate bug finder!"
error_input:	.asciiz		"Nice try... You need to at least enter a number! Try again.\n"
finished:	.asciiz 	"\nThe integer is: "

		.text
		li	$v0,	4
		la	$a0,	instructions	# print instructions
		syscall
        
main:		li	$v0,	4
		la	$a0,	prompt		# print prompt
		syscall
        
		li	$v0,	8		# read the user input into buffer
		li	$a1,	6		# Changed: 5 digits + null
		la 	$a0,	buffer
		syscall
        
		# Verify they user entered at least one character and didn't just press enter....
		lb	$t0,	($a0)		# get the first digit
		bne	$t0,	10,	process	# if it is not a newline then procees else,
		li	$v0,	4		# print you must enter something...
		la	$a0,	error_input
		syscall
		j	main			# Try again.
        
		# Process the string they entered.
process:	jal	atoi			# Convert their string into an integer (atoi)
		move	$t0,	$v0		# move status to $t0
		move	$t1,	$v1		# move result to $t1

		# Check the status codes from the atoi function.
		# 0 = Succes
		# 1 = Non-numeric characters
		# 2 = Overflow
		# anything else is unknown
		beqz	$t0,	print_results		# If 0 (success), print results.
e_invalid:	bne	$t0,	1,	e_overflow	# If 1 (invalid characters) print error, else check for overflow.
		li	$v0,	4			# Print invalid characters error.
		la	$a0,	error_char
		syscall
		j	main			# try again!
        
e_overflow:	bne	$t0,	2,	e_unknown	# If 2 (Overflow) print error, else, unknown eeror.
		li	$v0,	4			# print overflow error
		la	$a0,	error_ovflow
		syscall
		j	main				# try again!
        
e_unknown:	li	$v0,	4			# print unknown error (you shouldn't get here ever...)
		la	$a0,	error_unknown
		syscall
		j	exit				# exit.

		# Successful conversion, print the unsigned integer.
print_results:	li	$v0,	4			# print the finished text
		la	$a0,	finished
		syscall
		
		li	$v0,	1			# Changed: use syscall 1 for signed int (works for 16-bit values)
		move	$a0,	$t1
		syscall

exit:		li 	$v0,	10			# exit the program
		syscall

##################################################################
# ATOI (16-bit unsigned)                                         #
# Function to convert a string to 16-bit unsigned integer.       #
#                                                                #
# Arguments:                                                     #
#    $a0 - address of string to convert.                         #
#                                                                #
# Returns:                                                       #
#    $v0 - flag for conversion status                            #
#        0 = Success                                             #
#        1 = Invalid characters                                  #
#        2 = Overflow                                            #
#    $v1 - Converted integer                                     #
##################################################################		
atoi:		move	$t0,	$a0 		# moves address (from $a0 to $t0) that was passed in from the main part of the program
		li	$t1,	0			# result storage
		li	$t5,	65535			# Added: 16-bit max value constant

loop:		lb	$t2,	0($t0) 			# loads the first byte of the word into $t2
		beq	$t2,	0,	success		# if the current byte is a null space, go to exit
		beq	$t2,	10,	success		# if the current byte is a new line, go to exit

		subi	$t2,	$t2,	48		# Subtract 48 from the character.
		blt	$t2,	0,	bad_char	# if less than 0, return invalid characters
		bgt	$t2,	9,	bad_char	# if greater than 9, return invalid characters

convert:	move	$t3,	$zero			# initialize $t3 to 0
		li	$t4,	10			# set $t4 to 10 for multiplication base 10 adjustment
		mul	$t3,	$t1,	$t4		# Changed: use mul (simpler, result in $t3)
		bgt	$t3,	$t5,	overflow	# Added: check if result * 10 > 65535
		addu	$t3,	$t3,	$t2		# add the current digit to the result
		bgt	$t3,	$t5,	overflow	# Added: check if result + digit > 65535
		move	$t1,	$t3			# set the new result.
		addi	$t0,	$t0,	1		# adds 1 to the address to (next character)
		j 	loop 				# loop to process next character.
		
bad_char:	li	$v0,	1			# Set status to 1, invalid characters		
		move	$v1,	$zero			# Set $v1 (converted integer to 0)
		j	done

overflow:	li	$v0,	2			# set status to 2, overflow
		move	$v1,	$zero			# set $v1 (converted integer to 0)
		j	done
success:	move	$v0,	$zero			# set success status 0 into $v0
		move	$v1,	$t1			# set result move $t1 into $v1

done:		jr	$ra