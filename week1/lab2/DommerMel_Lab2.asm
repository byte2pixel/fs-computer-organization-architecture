		.data
hello:		.asciiz	"Hello World"
clear:		.asciiz "Registers Cleared."
equation:	.asciiz "5 + 2 * 10 - 2 = "
loops:		.asciiz " Loops Completed."
accumulator:	.asciiz "Accumulator = "
part:		.asciiz "Part "
div:		.asciiz "--------------------"
#newline:	.asciiz "\n"	# was using (la $a0, newline) but lb with a byte is probably better!
newline:	.byte	10

###############
# Macros      #
###############
		.macro printnl			# Print a newline
		li	$v0,	11
		lb	$a0,	newline
		syscall
		.end_macro
		
		.macro divider			# Prints newline, divider, newline
		printnl
		li	$v0,	4
		la	$a0,	div
		syscall
		printnl
		.end_macro	

		.text
########################################
# 1) Hello World with a new line       #
########################################
		li	$v0,	4		# Print part
		la	$a0,	part
		syscall
		li	$v0,	1		# Print 1
		li	$a0,	1
		syscall
		printnl
		li	$v0,	4		# Print Hello World
		la	$a0,	hello
		syscall		
		divider
		
########################################
# 2) Break things down: 5 + 2 * 10 - 2 #
########################################
		li	$v0,	4		# Print part
		la	$a0,	part
		syscall
		li	$v0,	1		# Print 2
		li	$a0,	2
		syscall
		li	$v0,	11		# Print newline
		lb	$a0,	newline
		syscall
		li	$v0,	4		# Print equation
		la	$a0,	equation
		syscall
		li	$t1,	2		# load 2
		li	$t2,	10		# load 10
		mul	$t0,	$t1,	$t2	# Multiply 2 * 10 store in $t0
		li	$t1,	-2		# load -2
		add	$t0,	$t0,	$t1	# add -2 to $t0
		li	$t1,	5		# load 5
		add	$t0,	$t0,	$t1	# add 5 to $t0
		
		# Rrint output of equation 23 and new line
		li	$v0,	1		# Print integer
		move	$a0,	$t0		# move answer to print
		syscall				# Print answer
		divider
		
#####################################
# 3) Clear registers                #
#####################################
		li	$v0,	4		# Print part
		la	$a0,	part
		syscall
		li	$v0,	1		# Print 3
		li	$a0,	3
		syscall
		printnl
		
		move	$t0,	$zero		# Clear Resiters
		move	$t1,	$zero
		move	$t2,	$zero
		li	$v0,	4		# Print Registers Cleared
		la	$a0,	clear
		syscall
		divider

#####################################
# 4) Loop using bgt.                #
#####################################
		li	$v0,	4		# Print part
		la	$a0,	part
		syscall
		li	$v0,	1		# Print 4
		li	$a0,	4
		syscall
		printnl
		
		li	$t0,	0		# Load 0
		li	$t1,	2		# Load 2
loop:		addi	$t0,	$t0,	1	# add 1 
		bgt	$t1,	$t0,	loop	# $t0 = 2 here
		li	$v0,	1		# Print loop count
		move	$a0,	$t0
		syscall
		li	$v0,	4		# Print loops completed
		la	$a0,	loops
		syscall
		divider

#####################################
# 5) Convert C++ code into Assembly.#
#####################################
		li	$v0,	4		# Print part
		la	$a0,	part
		syscall
		li	$v0,	1		# Print 4
		li	$a0,	5
		syscall
		printnl
		move	$t0,	$zero		# accumulator = 0
		move	$t1,	$zero		# j = 0
jloop:		bge	$t1,	5,	jend	# goto jend if j >= 5
		addi	$t1,	$t1,	1 	# j++
		addi	$t0,	$t0,	1	# accumulator += 1
		move	$t2,	$zero		# i = 0
iloop:		bge	$t2,	3,	iend	# goto iend if i >= 3
		add	$t2,	$t2,	1	# i++
		add	$t0,	$t0,	2	# accumulator += 2
		j	iloop			# jump to i loop start
iend:		j	jloop			# jump to j loop start

		# Print the accumulator
jend:		li	$v0	4		# Print accumulator =
		la	$a0	accumulator
		syscall
		li	$v0,	1
		move	$a0,	$t0
		syscall
		divider

########
# Exit #
########
exit:		li	$v0,	10
		syscall
