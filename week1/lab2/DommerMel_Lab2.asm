		.data
hello:		.asciiz	"Hello World"
newline:	.asciiz "\n"

		# Print Hello World
		.text
		li	$v0,	4		# Print string
		la	$a0,	hello		# Print the starting address of the string to print.
		syscall
		
		# 1) Hello World with a new line
		li	$v0,	4		# Print string - This may not be needed but just in case. If code is added between.
		la	$a0,	newline		# load address of newline
		syscall				# Print newline
		
		# 2) Break things down: 5 + 2 * 10 - 2
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
		li	$v0,	4		# Print string
		la	$a0,	newline		# load address newline
		syscall				# Print newline
		
		# 3) Clear registers
		move	$t0,	$zero		# Clear t0
		move	$t1,	$zero		# Clear t1
		move	$t2,	$zero		# Clear t2
		
		# 4) Loops - example BEQ and BNE loops $t0 = 2 at the end.
		li	$t0,	0		# Load 0
		li	$t1,	2		# Load 2
loop:		addi	$t0,	$t0,	1	# add 1 
		bgt	$t1,	$t0,	loop	# $t0 = 2 here
		
		# 5) Convert C++ code into Assembly.
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

		# Print the accumulator and newline
jend:		li	$v0,	1
		move	$a0,	$t0
		syscall		
		
		# Exit
exit:		li	$v0,	10
		syscall
