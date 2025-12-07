######################################################################
# Author: Mel Dommer                                                 #
#   Date: 2025-12-07                                                 #
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
buffer:		.space 		10		# up to 3 digits for integer and 5 for fractional, 1 for decimal, 1 for null.
instruction1:	.asciiz		"Enter any real number less than 256 (0 - 255.99~) and this program will convert the string to 8.8 fixed notation.\n"
instruction2:	.asciiz		"\nEnter another real number to add to the first one."
prompt:		.asciiz		"\nEnter your number (less than 256): "
error_char:	.asciiz		"\nYou didn't enter a valid number\nUse only '0-9' and '.' Try again.\n"
error_ovflow:	.asciiz		"\nYou entered a number that is too large to fit into 8.8 notation (0 - 255.99~). Try again.\n"
error_unknown:	.asciiz		"\nYou encountered an unknown error, program will exit.\nConsider yourself the ultimate bug finder!"
error_input:	.asciiz		"Nice try... You need to at least enter a number! Try again.\n"
error_frac_ovflow: .asciiz	"\nThe fractional portion is too large to convert accurately to 8.8 notation. Try fewer decimal places.\n"
print_int:	.asciiz		"\nThe integer portion of your number is: "
print_frac:	.asciiz		"\nThe fraction portion of your number is: "
print_bin:	.asciiz		"\nThe binary representation of your number in fixed 8.8 is: "
print_sum:      .asciiz		"\nThe sum of your two numbers in binary (fixed 8.8) is: "
warning_ovflow:	.asciiz		"\nWARNING: Summation overflow detected! Result is not accurate due to exceeding 8.8 notation range (max 255.99~).\n"

        	.text
		li	$v0,	4
		la	$a0,	instruction1	# print instructions
		syscall
# Part 1 - Prompt for first number,
main:		li	$v0,	4
		la	$a0,	prompt		# print prompt
		syscall

		li	$v0,	8		# read the user input into buffer
		li	$a1,	10
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

		# Successful conversion, print and convert to 8.8
print_results:	move	$a0,	$s0		# integer part
		move	$a1,	$s1		# fractional part
		move	$a2,	$s2		# digit count
		jal	print_and_convert	# print and convert to 8.8
		move	$t0,	$v0		# check status
		move	$s3,	$v1		# save result
		
		# Check if conversion failed
		beqz	$t0,	main2		# if no error, proceed to second number

		li	$v0,	4
		la	$a0,	error_frac_ovflow
		syscall
		j	main			# retry first number
# End Part 1 and Part 2
# Part 3 - Prompt for second number to add to the first one
main2:		li	$v0,	4
		la	$a0,	instruction2	# print instructions for second number
		syscall

		li	$v0,	4
		la	$a0,	prompt		# print prompt
		syscall

		li	$v0,	8		# read the user input into buffer
		li	$a1,	10
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

		# Successful conversion, print and convert to 8.8
print_results2:	move	$a0,	$s0		# integer part
		move	$a1,	$s1		# fractional part
		move	$a2,	$s2		# digit count
		jal	print_and_convert	# print and convert to 8.8
		move	$t0,	$v0		# check status
		move	$t1,	$v1		# save result
		
		# Check if conversion failed
		beqz	$t0,	add_nums	# if no error, proceed to addition

		li	$v0,	4
		la	$a0,	error_frac_ovflow
		syscall
		j	main2			# retry second number
		
		# Add the two 8.8 notation numbers
add_nums:	add	$s3,	$s3,	$t1	# add first and second number in 8.8 notation

		# Print the final result in binary (syscall 35)
		li	$v0,	4
		la	$a0,	print_sum
		syscall

		li	$v0,	35
		move	$a0,	$s3
		syscall

		# Check for overflow (if sum >= 65536, it overflowed)
		li	$t2,	65536		# max value + 1 for 16-bit (2^16)
		blt	$s3,	$t2,	exit	# if less than max, no overflow
		
		# Print overflow warning
		li	$v0,	4
		la	$a0,	warning_ovflow
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
parse_real:	addi	$sp,	$sp,	-4		# save return address and $s registers
		sw	$ra,	0($sp)			# because jal is used in this function

		# Parse integer part
		jal	atoi_int			# parse integer portion
		move	$t0,	$v0			# save status
		move	$s0,	$v1			# save integer value
		move	$t2,	$a1			# address after integer part

		bnez	$t0,	pr_error		# if error, return

		bgt	$s0,	255,	pr_overflow	# integer must be 0-255

		# Check if we have a decimal point
		lb	$t3,	0($t2)
		beq	$t3,	0,	pr_no_frac	# null terminator, no fractional part
		beq	$t3,	10,	pr_no_frac	# newline, no fractional part
		bne	$t3,	46,	pr_invalid	# not a '.', invalid

		# Parse fractional part
		addi	$a0,	$t2,	1		# skip the '.'
		jal	atoi_frac			# parse fractional portion
		move	$t3,	$v0			# save status
		move	$s1,	$v1			# save fractional value
		move	$t4,	$a1			# save digit count

		bnez	$t3,	pr_error_t3		# if error, return

		# Success with fractional part
		li	$v0,	0
		move	$v1,	$s0			# integer part from $s0
		move	$a1,	$s1			# fractional part from $s1
		move	$a2,	$t4			# digit count
		j	pr_done				# done

pr_no_frac:	li	$v0,	0			# success
		move	$v1,	$s0			# integer part from $s0
		li	$a1,	0			# no fractional part
		li	$a2,	0			# no digits
		j	pr_done				# done

pr_invalid:	li	$v0,	1			# set invalid character status
		j	pr_done				# done

pr_overflow:	li	$v0,	2			# set overflow status
		j	pr_done				# done

pr_error:	move	$v0,	$t0			# return error status
		j	pr_done				# done

pr_error_t3:	move	$v0,	$t3			# return error status
		j	pr_done				# done

pr_done:	lw	$ra,	0($sp)			# restore return address
		addi	$sp,	$sp,	4
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
atoi_int:	move	$t0,	$a0 			# address pointer
		li	$t1,	0			# result storage
		li	$t3,	10			# multiplier
		li	$t4,	255			# max value

ai_loop:	lb	$t2,	0($t0) 			# load byte
		beq	$t2,	0,	ai_success	# null terminator
		beq	$t2,	10,	ai_success	# newline
		beq	$t2,	46,	ai_success	# decimal point

		subi	$t2,	$t2,	48		# convert to integer
		blt	$t2,	0,	ai_bad_char
		bgt	$t2,	9,	ai_bad_char

		mul	$t1,	$t1,	$t3		# result *= 10
		bgt	$t1,	$t4,	ai_overflow	# check overflow after multiply
		addu	$t1,	$t1,	$t2		# result += digit
		bgt	$t1,	$t4,	ai_overflow	# check overflow after addition
		addi	$t0,	$t0,	1		# next character
		j 	ai_loop

		# Error: invalid character
ai_bad_char:	li	$v0,	1			# return invalid character error
		li	$v1,	0			# clear returned integer
		li	$a1,	0			# clear return address
		j	ai_done

		# Error: overflow
ai_overflow:	li	$v0,	2			# return overflow error
		li	$v1,	0			# clear returned integer
		li	$a1,	0			# clear return address
		j	ai_done

		# Success
ai_success:	li	$v0,	0			# return success
		move	$v1,	$t1			# return integer value
		move	$a1,	$t0			# return address after integer part for atoi_frac to use.

ai_done:	jr	$ra

##################################################################
# atoi_frac                                                      #
# Parse fractional portion (up to 5 digits, max 65535)          #
#                                                                #
# Arguments:                                                     #
#    $a0 - address of string (after decimal point)               #
#                                                                #
# Returns:                                                       #
#    $v0 - status (0=success, 1=invalid, 2=overflow)             #
#    $v1 - Fractional digits as integer (e.g., ".275" -> 275)    #
#    $a1 - Number of digits parsed                               #
##################################################################		
atoi_frac:	move	$t0,	$a0 			# address pointer
		li	$t1,	0			# result storage
		li	$t3,	10			# multiplier
		li	$t5,	0			# digit counter

af_loop:	bge	$t5,	5,	af_success	# max 5 digits (65535 limit)
		lb	$t2,	0($t0) 			# load byte
		beq	$t2,	0,	af_success	# null terminator
		beq	$t2,	10,	af_success	# newline

		subi	$t2,	$t2,	48		# convert to integer
		blt	$t2,	0,	af_bad_char
		bgt	$t2,	9,	af_bad_char

		mul	$t1,	$t1,	$t3		# result *= 10
		addu	$t1,	$t1,	$t2		# result += digit
		addi	$t0,	$t0,	1		# next character
		addi	$t5,	$t5,	1		# increment digit count
		j 	af_loop

		# Error: invalid character
af_bad_char:	li	$v0,	1			# return invalid character error
		li	$v1,	0			# clear fractional value
		li	$a1,	0			# clear digit count
		jr	$ra

		# Success - check if value is too large for 8.8 notation conversion
		# I could not find a better way to do this other than hard coding the max value.
		# If I tested entering 255.99609375 but when applying the shortcut formula it would overflow giving
		# very inaccurate results.
af_success:	li	$t6,	65535			# max value to avoid overflow in shift operation during to_fixed88
		bgt	$t1,	$t6,	af_overflow	# if fraction > 65535, overflow error
		
		li	$v0,	0			# return success
		move	$v1,	$t1			# return fractional value
		move	$a1,	$t5			# return digit count
		jr	$ra

		# Error: fractional value too large
af_overflow:	li	$v0,	2			# return overflow error
		li	$v1,	0			# clear fractional value
		li	$a1,	0			# clear digit count
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
#    $v0 - status (0=success, 1=fractional overflow)             #
#    $v1 - register containing the number in 8.8 notation        #
##################################################################
to_fixed88:	# Shift integer left by 8 bits
		sll	$t0,	$a0,	8	# integer << 8
		beqz	$a2,	tf_no_frac	# if no fractional digits, skip

		# Convert fractional digits to 8-bit fixed point
		# Calculate 10^digit_count
		li	$t3,	10		# base
		li	$t4,	1		# accumulator for 10^digit_count
		move	$t5,	$a2		# counter

power_loop:	beqz	$t5,	power_done	# caclulate 10^digit_count
		mul	$t4,	$t4,	$t3	# store 10^digit_count in $t4
		subi	$t5,	$t5,	1
		j	power_loop

		# Q-format conversion shortcut from lab document
power_done:	sll	$t2,	$a1,	8	# shift fraction << 8 (multiply by 256)
		divu	$t2,	$t4		# divide by 10^digit_count
		mflo	$t2			# get quotient, result of short cut

		# Combine integer and fractional parts using OR described in the lab video.
		or	$v1,	$t0,	$t2	# result = (int << 8) | frac
		li	$v0,	0		# set success
		jr	$ra

		# Edge case: no fractional part
tf_no_frac:	move	$v1,	$t0		# just the integer part shifted
		li	$v0,	0		# set success
		jr	$ra

##################################################################
# print_and_convert                                              #
# Print integer and fractional parts, then convert to 8.8        #
# notation and print binary representation                       #
#                                                                #
# Arguments:                                                     #
#    $a0 - Integer portion                                       #
#    $a1 - Fractional portion (as parsed digits)                 #
#    $a2 - Number of fractional digits                           #
#                                                                #
# Returns:                                                       #
#    $v0 - status (0=success, 1=fractional overflow)             #
#    $v1 - 8.8 notation result                                   #
##################################################################
print_and_convert:
		addi	$sp,	$sp,	-4	# save return address
		sw	$ra,	0($sp)		# needed for jal
		
		# Save arguments to temp registers
		move	$t0,	$a0		# save integer
		move	$t1,	$a1		# save fractional
		move	$t2,	$a2		# save digit count
		
		# Print integer portion
		li	$v0,	4
		la	$a0,	print_int
		syscall
		
		move	$a0,	$t0		# restore integer value
		li	$v0,	1
		syscall
		
		# Print fractional portion
		li	$v0,	4
		la	$a0,	print_frac
		syscall
		
		move	$a0,	$t1		# restore fractional value
		li	$v0,	1
		syscall
		
		# Convert to 8.8 notation
		move	$a0,	$t0		# restore arguments
		move	$a1,	$t1
		move	$a2,	$t2
		jal	to_fixed88
		move	$t0,	$v1		# save 8.8 result in temp register
		
		# Check if conversion succeeded
		bnez	$v0,	pac_done	# if error, return with error status
		
		# Print binary representation
		li	$v0,	4
		la	$a0,	print_bin
		syscall
		
		li	$v0,	35
		move	$a0,	$t0
		syscall
		
		li	$v0,	0		# success status
		move	$v1,	$t0		# return 8.8 result

pac_done:	lw	$ra,	0($sp)		# restore return address
		addi	$sp,	$sp,	4
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
