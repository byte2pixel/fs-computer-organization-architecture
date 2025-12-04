		.data
instructions:	.asciiz "Welcome to Planet Cipher!\nYou will enter a planet name that must use only [A-Z][a-z].\nThen pick a cipher key any valid 32-bit signed integer.\nAny deviation from these rules may result in incorrect output."
askplanet:	.asciiz	"Enter the name of a planet and press enter (Only use [A-Z][a-z]): "
askcipher:	.asciiz "Enter your cipher key any valid 32-bit signed integer (will be normalized to 0-25): "
newplanet:	.asciiz "Here is your planet with cipher applied: "
no_offset:	.asciiz "Error: The cipher key you entered resulted in no offset being applied.\nRun the program again and try a different cipher key that is not 0 or a multiple of 26."
div:		.asciiz "--------------------"
newline:	.byte	10
Z:		.byte	90
z:		.byte	122
buffer:		.space  10

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
		li	$v0,	4		# Print Instructions
		la	$a0,	instructions
		syscall
		divider
#####################################
# 1) Ask for planet                 #
#####################################
		li	$v0,	4		# Ask user for planet
		la	$a0,	askplanet
		syscall
		printnl
		
		li	$v0,	8		# Read planet into buffer
		la	$a0,	buffer		# load starting address of buffer
		la	$a1,	10		# read only 10 characters (length of buffer.)
		syscall
		la	$t0,	buffer		# Move buffer to $t0
		divider
#####################################
# 2) Ask Cipher key                 #
#####################################
		li	$v0,	4		# Ask user for cipher key
		la	$a0,	askcipher	
		syscall
		printnl

		li	$v0,	5		# Read cipher key after syscall integer is in $v0
		syscall				# Unhandled exception if it is not a 32bit integer.
		move	$t2,	$v0		# Move cipher key from $v0 into $t2
#####################################
# 4) Normalize Cipher Key           #
#####################################
		div 	$t2, 	$t2,	26     	# Divide $t2 by 26 and use remainder (HI)
		mfhi 	$t2               	# load HI into $t2 which is now normalized to (-25 to 0) or (0 to 25) now.
		bltz	$t2,	neg_adjust	# if they entered negative make it the equivalent positive.
		j	adjust_done		# The number was positive so skip adjusting for negative.
neg_adjust:	addi	$t2,	$t2,	26	# add 26 to make the negative positive, Example: -9 is the same as +17.
#####################################
# 5) Make sure key is not 0         #
#####################################
adjust_done:	bnez	$t2,	valid_key	# Continue the cipher if the key > 0 otherwise the key is 0 and no cipher can be done.
		li	$v0,	4		# Print no offset error message.
		la	$a0,	no_offset	# No point in applying an offset of 0, 26, 52, 78 etc...
		syscall
		j	exit			# Exit program
#####################################
# 6) Apply Cipher Key               #
#####################################		
valid_key:	jal	cipher			# Call the cipher function using jal
		divider
#####################################
# 4) Print planet /w cipher         #
#####################################
		li	$v0,	4		# Print completed cipher message
		la	$a0,	newplanet
		syscall
		printnl
		li	$v0,	4		# Print new planet name
		la	$a0,	buffer
		syscall
		printnl
########
# Exit #
########
exit:		li	$v0,	10
		syscall


#####################################
# 3) Apply cipher function          #
#####################################
cipher:		lb	$t1,	0($t0)		# load the byte into $t1 so we can work with it.
		beq	$t1,	0,	done	# If we are on a null, then jump to done.
		beq	$t1,	10,	done	# If we are on a newline, then jump to done.

		andi	$t3,	$t1,	32	# Check if it is uppercase or lowercase before adding the cipher
						# In ASCII if bit 5 is 1 = lowercase, 0 = uppercase (for A-Z,a-z)

		add	$t1,	$t1,	$t2	# Add the normalized cipher key value then handle wrapping.
		bnez	$t3,	is_lower	# Jump to lowercase handler
		beqz	$t3,	is_upper	# Jump to uppercase handler

is_lower:					# Lowercase Handler
		addi	$t1,	$t1,	-97	# subtract 97 ('a')
		div	$t1,	$t1,	26	# divide $t1 by 26 so we can look at remainder in HI using mfhi
		mfhi	$t1			# load remainder into $t1
		add	$t1,	$t1,	97	# add 97 back ('a') giving us the correct shifted value.
		j	store

is_upper:					# Uppercase Handler (only difference is using 65 instead of 97
		addi	$t1,	$t1,	-65	# subtract 65 ('A')
		div	$t1,	$t1,	26	# divide $t1 by 26 so we can use the remainder in HI using mfhi
		mfhi	$t1			# load remainder into $t1
		add	$t1,	$t1,	65	# add 65 back ('A') giving us the correct shifted value.
		j	store

store:		sb	$t1,	0($t0)		# Store the shifted value back into the byte we are working with.
		addi	$t0,	$t0,	1	# Increment the address by one
		j	cipher			# loop and go through again

done:		jr	$ra			# Done, return back to instruction in $ra
