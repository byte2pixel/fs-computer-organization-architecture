	.text
#adding two numbers together
li	$t0, 1
li	$t1, 2
add	$t2, $t0, $t1
#print number using i/o
li	$v0, 1
move	$a0, $t2
syscall
#program exit
li	$v0, 10
syscall
