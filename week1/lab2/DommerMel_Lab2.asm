		.data
hello:		.asciiz	"Hello World"
newline:	.asciiz "\n"

		# Print Hello World\n
		.text
		li	$v0,	4
		la	$a0,	hello
		syscall
		li	$v0,	4		# This may not be needed but just in case. If code is added between.
		la	$a0,	newline
		syscall
		
		# 5 + 2 * 10 - 2
		li	$t1,	2
		li	$t2,	10
		mul	$t0,	$t1,	$t2	# Multiply 2*10 store in $t0
		li	$t1,	-2
		add	$t0,	$t0,	$t1	# add -2 to $t0
		li	$t1,	5
		add	$t0,	$t0,	$t1	# add 5 to $t0
		li	$v0,	1
		la	$a0,	($t0)
		syscall
		li	$v0,	4
		la	$a0,	newline
		syscall
		
		# Clear the registered used for the math above
		la	$t0,	($zero)
		la	$t1,	($zero)
		la	$t2,	($zero)
		
		# Loops
		
		# exit
exit:		li	$v0,	10
		syscall