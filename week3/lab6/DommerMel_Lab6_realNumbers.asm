######################################################################
# Author: Mel Dommer                                                 #
#   Date: 2025-12-06                                                 #
#                                                                    #
# Lab 6 - Real Numbers                                               #
#                                                                    #
# 1. Use I/O to have the user input a real number in string format   #
#    Translate that into integers using modified ATOI from lab 5     #
#    - Store the integer portion in one register                     #
#    - Store the fraction portion in another register                #
#    - Error if they do not fit or not valid numbers                 #
#    - In the console window, display, in decimal notation,          #
#      the contents of the two registers.                            #
#                                                                    #
######################################################################
	        .data
buffer:		.space 		14		# up to 3 digits for integer and 8 for fractional, 1 for decimal, 1 for null.
instruction1:	.asciiz		"Enter any real number less than 256 (0 - 255.99~) and this program will convert the string to 8.8 fixed notation.\n"
instruction2:	.asciiz		"\nEnter another real number to add to the first one."
prompt:		.asciiz		"\nEnter your number (less than 256): "
error_char:	.asciiz		"\nYou didn't enter a valid number\nUse only '0-9' and '.' Try again.\n"
error_ovflow:	.asciiz		"\nYou entered a number that is too large to fit into 8.8 notation (0 - 255.99~). Try again.\n"
error_unknown:	.asciiz		"\nYou encountered an unknown error, program will exit.\nConsider yourself the ultimate bug finder!"
error_input:	.asciiz		"Nice try... You need to at least enter a number! Try again.\n"
print_int:	.asciiz		"\nThe integer porition of your number is: "
print_frac:	.asciiz		"\nThe fraction porition of your number is: "
print_bin:	.asciiz		"\nThe sum of your numbers in fixed 8.8 is: "

        	.text
		li	$v0,	4
		la	$a0,	instruction1	# print instructions
		syscall
# Part 1 - Prompt for first number,
main:		li	$v0,	4
		la	$a0,	prompt		# print prompt
		syscall

		li	$v0,	8		# read the user input into buffer
		li	$a1,	14
		la 	$a0,	buffer
		syscall

		# Verify they user entered at least one character and didn't just press enter....
		lb	$t0,	($a0)		# get the first digit
		bne	$t0,	10,	process	# if it is not a newline then proceed else,
		li	$v0,	4		# print you must enter something...
		la	$a0,	error_input
		syscall
		j	main			# Try again.

		# Process the string they entered.
process:	la	$a0,	buffer
		jal	parse_real		# Parse the real number
		move	$t0,	$v0		# move status to $t0
		move	$s0,	$v1		# save integer part to $s0
		move	$s1,	$a1		# save fractional part to $s1
		move	$s2,	$a2		# save digit count to $s2

		# Check the status codes
		# 0 = Success
		# 1 = Non-numeric characters
		# 2 = Overflow
		beqz	$t0,	print_results	# If 0 (success), print results.
		
		# Handle error (non-zero status)
		jal	handle_parse_error
		j	main			# retry

		# Successful conversion, print both parts
print_results:	li	$v0,	4		# print integer label
		la	$a0,	print_int
		syscall
        
		li	$v0,	1		# print integer part
		move	$a0,	$s0
		syscall

		li	$v0,	4		# print fractional label
		la	$a0,	print_frac
		syscall

		li	$v0,	1		# print fractional part
		move	$a0,	$s1
		syscall
# End Part 1
# Part 2 combine the two into 8.8 notation
		move    $a0,	$s0		# load integer into $a0
		move	$a1,	$s1		# load fraction into $a1
		move	$a2,	$s2		# load digit count into $a2
		jal	to_fixed88
		move	$s3,	$v0		# save the result into $s3
		
		# Print the 8.8 notation in binary, (syscall 35)
		li	$v0,	4
		la	$a0,	print_bin
		syscall
		
		li	$v0,	35
		move	$a0,	$s3
		syscall
# End Part 2
# Part 3 - Prompt for second number to add to the first one
main2:		li	$v0,	4
		la	$a0,	instruction2	# print instructions for second number
		syscall

		li	$v0,	4
		la	$a0,	prompt		# print prompt
		syscall

		li	$v0,	8		# read the user input into buffer
		li	$a1,	14
		la 	$a0,	buffer
		syscall

		# Verify they user entered at least one character and didn't just press enter....
		lb	$t0,	($a0)		# get the first digit
		bne	$t0,	10,	process2	# if it is not a
		li	$v0,	4		# print you must enter something...
		la	$a0,	error_input
		syscall
		j	main2			# Try again.
		
		# Process the string they entered.
process2:	la	$a0,	buffer
		jal	parse_real		# Parse the real number
		move	$t0,	$v0		# move status to $t0
		move	$s0,	$v1		# save integer part to $s0
		move	$s1,	$a1		# save fractional part to $s1
		move	$s2,	$a2		# save digit count to $s2

		# Check the status codes
		# 0 = Success
		# 1 = Non-numeric characters
		# 2 = Overflow
		beqz	$t0,	print_results2	# If 0 (success), print results.
		
		# Handle error (non-zero status)
		jal	handle_parse_error
		j	main2			# retry
		
		# Successful conversion, print both parts
		# set part 2 to 8.8 notation
print_results2:	move    $a0,	$s0		# load integer into $a0
		move	$a1,	$s1		# load fraction into $a1
		move	$a2,	$s2		# load digit count into $a2
		jal	to_fixed88
		move	$t1,	$v0		# save the result into $t1
		# Add the two 8.8 notation numbers
		add	$s3,	$s3,	$t1	# add first and second number in 8.8 notation
		# Print the final result in binary (syscall 35)
		li	$v0,	4
		la	$a0,	print_bin
		syscall
		
		li	$v0,	35
		move	$a0,	$s3
		syscall

exit:		li 	$v0,	10		# exit the program
		syscall

##################################################################
# parse_real                                                     #
# Function to parse a real number string into integer and        #
# fractional parts.                                              #
#                                                                #
# Arguments:                                                     #
#    $a0 - address of string to convert.                         #
#                                                                #
# Returns:                                                       #
#    $v0 - flag for conversion status                            #
#        0 = Success                                             #
#        1 = Invalid characters                                  #
#        2 = Overflow                                            #
#    $v1 - Integer portion                                       #
#    $a1 - Fractional portion (as integer)                       #
#    $a2 - Number of fractional digits                           #
##################################################################
parse_real:	addi	$sp,	$sp,	-16		# save registers to the stack
		sw	$ra,	0($sp)
		sw	$s0,	4($sp)
		sw	$s1,	8($sp)
		sw	$s2,	12($sp)

		move	$s2,	$a0			# save buffer address of the user input

		# Parse integer part
		jal	atoi_int		# parse integer portion
		move	$t0,	$v0		# status
		move	$s0,	$v1		# save integer value to $s0
		move	$t2,	$a1		# address after integer part

		bnez	$t0,	pr_error	# if error, return
		
		bgt	$s0,	255,	pr_overflow	# integer must be 0-255
		
		# Check if we have a decimal point
		lb	$t3,	0($t2)
		beq	$t3,	0,	pr_no_frac	# null terminator, no fractional part
		beq	$t3,	10,	pr_no_frac	# newline, no fractional part
		bne	$t3,	46,	pr_invalid	# not a '.', invalid
		
		# Parse fractional part
		addi	$a0,	$t2,	1	# skip the '.'
		jal	atoi_frac		# parse fractional portion
		move	$t3,	$v0		# status
		move	$s1,	$v1		# save fractional value to $s1
		move	$t4,	$a1		# save digit count
		
		bnez	$t3,	pr_error_t3	# if error, return
		
		# Success with fractional part
		li	$v0,	0
		move	$v1,	$s0		# integer part from $s0
		move	$a1,	$s1		# fractional part from $s1
		move	$a2,	$t4		# digit count
		j	pr_done

pr_no_frac:	li	$v0,	0		# success
		move	$v1,	$s0		# integer part from $s0
		li	$a1,	0		# no fractional part
		li	$a2,	0		# no digits
		j	pr_done

pr_invalid:	li	$v0,	1		# invalid character
		j	pr_done

pr_overflow:	li	$v0,	2		# overflow
		j	pr_done

pr_error:	move	$v0,	$t0		# return error status
		j	pr_done

pr_error_t3:	move	$v0,	$t3		# return error status

pr_done:	lw	$s2,	12($sp)
		lw	$s1,	8($sp)
		lw	$s0,	4($sp)
		lw	$ra,	0($sp)
		addi	$sp,	$sp,	16
		jr	$ra

##################################################################
# atoi_int                                                       #
# Parse integer portion of number (stops at '.', null, newline) #
#                                                                #
# Arguments:                                                     #
#    $a0 - address of string to convert.                         #
#                                                                #
# Returns:                                                       #
#    $v0 - status (0=success, 1=invalid, 2=overflow)             #
#    $v1 - Converted integer                                     #
#    $a1 - Address of character after integer part               #
##################################################################		
atoi_int:	move	$t0,	$a0 		# address pointer
		li	$t1,	0		# result storage
		li	$t3,	10		# multiplier
		li	$t4,	255		# max value

ai_loop:	lb	$t2,	0($t0) 		# load byte
		beq	$t2,	0,	ai_success	# null terminator
		beq	$t2,	10,	ai_success	# newline
		beq	$t2,	46,	ai_success	# decimal point

		subi	$t2,	$t2,	48	# convert ASCII to digit
		blt	$t2,	0,	ai_bad_char
		bgt	$t2,	9,	ai_bad_char

		mul	$t1,	$t1,	$t3	# result *= 10
		bgt	$t1,	$t4,	ai_overflow
		addu	$t1,	$t1,	$t2	# result += digit
		bgt	$t1,	$t4,	ai_overflow
		addi	$t0,	$t0,	1	# next character
		j 	ai_loop

ai_bad_char:	li	$v0,	1
		li	$v1,	0
		j	ai_done

ai_overflow:	li	$v0,	2
		li	$v1,	0
		j	ai_done

ai_success:	li	$v0,	0
		move	$v1,	$t1
		move	$a1,	$t0		# return address after integer

ai_done:	jr	$ra

##################################################################
# atoi_frac                                                      #
# Parse fractional portion (up to 8 digits)                      #
#                                                                #
# Arguments:                                                     #
#    $a0 - address of string (after decimal point)               #
#                                                                #
# Returns:                                                       #
#    $v0 - status (0=success, 1=invalid, 2=overflow)             #
#    $v1 - Fractional digits as integer (e.g., "275" -> 275)     #
#    $a1 - Number of digits parsed                               #
##################################################################		
atoi_frac:	move	$t0,	$a0 			# address pointer
		li	$t1,	0			# result storage
		li	$t3,	10			# multiplier
		li	$t5,	0			# digit counter

af_loop:	bge	$t5,	8,	af_success	# max 8 digits
		lb	$t2,	0($t0) 			# load byte
		beq	$t2,	0,	af_success	# null terminator
		beq	$t2,	10,	af_success	# newline

		subi	$t2,	$t2,	48		# convert ASCII to digit
		blt	$t2,	0,	af_bad_char
		bgt	$t2,	9,	af_bad_char

		mul	$t1,	$t1,	$t3		# result *= 10
		addu	$t1,	$t1,	$t2		# result += digit
		addi	$t0,	$t0,	1		# next character
		addi	$t5,	$t5,	1		# increment digit count
		j 	af_loop

af_bad_char:	li	$v0,	1
		li	$v1,	0
		li	$a1,	0
		jr	$ra

af_success:	li	$v0,	0
		move	$v1,	$t1
		move	$a1,	$t5			# return digit count
		jr	$ra

##################################################################
# to_fixed88                                                     #
# Take the two parts and store in one register 8.8 notation      #
#   Integer part in the upper 8 bits.                            #
#   Fractional part in the lower 8 bits.                         #
#                                                                #
# Arguments:                                                     #
#    $a0 - Integer portion                                       #
#    $a1 - Fractional portion (as parsed digits)                 #
#    $a2 - Number of fractional digits                           #
#                                                                #
# Returns:                                                       #
#    $v0 - register containing the number in 8.8 notation        #
##################################################################
to_fixed88:	# Step 1: Shift integer left by 8 bits
		sll	$t0,	$a0,	8	# integer << 8
		
		# Step 2: Convert fractional digits to 8-bit fixed point
		# Formula: (frac_digits * 256) / (10^digit_count)
		
		beqz	$a2,	tf_no_frac	# if no fractional digits, skip
		
		# Multiply fractional part by 256
		li	$t1,	256
		mul	$t2,	$a1,	$t1	# frac * 256
		
		# Divide by 10^digit_count
		li	$t3,	10		# divisor
		li	$t4,	1		# accumulator for 10^digit_count
		move	$t5,	$a2		# counter
		
power_loop:	beqz	$t5,	power_done
		mul	$t4,	$t4,	$t3	# accumulator *= 10
		subi	$t5,	$t5,	1
		j	power_loop
		
power_done:	div	$t2,	$t4		# divide by 10^digit_count
		mflo	$t2			# get quotient
		
		# Combine integer and fractional parts
		or	$v0,	$t0,	$t2	# result = (int << 8) | frac
		jr	$ra
		
tf_no_frac:	move	$v0,	$t0		# just the integer part shifted
		jr	$ra

##################################################################
# handle_parse_error                                             #
# Display appropriate error message based on error code          #
#                                                                #
# Arguments:                                                     #
#    $t0 - error code (1=invalid char, 2=overflow, other=unknown)#
#                                                                #
# Returns:                                                       #
#    Does not return for fatal errors (jumps to exit)           #
##################################################################
handle_parse_error:
		li	$v0,	4		# prepare to print string
		
		bne	$t0,	1,	hpe_overflow
		la	$a0,	error_char	# invalid character error
		syscall
		jr	$ra
		
hpe_overflow:	bne	$t0,	2,	hpe_unknown
		la	$a0,	error_ovflow	# overflow error
		syscall
		jr	$ra
		
hpe_unknown:	la	$a0,	error_unknown	# unknown error (fatal)
		syscall
		j	exit			# don't return, exit program	
