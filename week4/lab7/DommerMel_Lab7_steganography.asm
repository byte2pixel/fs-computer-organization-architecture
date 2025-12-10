######################################################################
# Author: Mel Dommer                                                 #
#   Date: 2025-12-09                                                 #
#                                                                    #
# Lab 7 - Steganography                                              #
#                                                                    #
# Part 1                                                             #
#    - Print out the first two bytes of the file                     #
#    - Print out the file size                                       #
#    - Print out the offset value where the pixel data starts        #
#                                                                    #
# Part 2                                                             #
#    - Allocate space on heap (syscall 9)                            #
#    - Open file onto the heap                                       #
#    - Print out the heap address given (appropriate data type)      #
#                                                                    #
# Part 3                                                             #
#    - Shift through the information on the hidden info.             #
#    - Clue: �the answer lies before a sequence of 3 stars�          #
#        Possibly meaning 3 '*' or 42 or 0x2A                        #
#        Print out the city                                          #
######################################################################
	        .data
file_name:      .asciiz         "pillarscipher.bmp"
print_first2:	.asciiz		"The first two bytes of the file: "
print_size:	.asciiz		"\nThe files size: "
print_offset:   .asciiz		"\nThe offset where the pixel data starts: "
print_heapaddr:	.asciiz		"\nThe heap address given: "
print_city:	.asciiz		"\nWe are meeting in: "
print_fin:	.asciiz		"\nSee you soon!"
error_open:	.asciiz		"\nUnabled to open the file, check the location of the file vs. cwd."
file_header:	.space	54	# reserve 54 bytes for the bmp header.
hidden_data:	.space	256	# reserve space for the city.
no_stars_msg:   .asciiz 	"\nAbort! The mission has been compromised. We are not meeting.\n"


        	.text
################################################################
# Part 1, open file, read header, print the required items.    #
################################################################
		li	$v0,	13		# Open the file.
		la	$a0,	file_name
		li	$a1,	0		# Open for read.
		li	$a2,	0		# ignored?
		syscall

		bgtz    $v0,	file_opened	# if neg, file open failed
		li      $v0,	4		# error opening file
		la      $a0,	error_open	# print file error message
		syscall
		j       exit			# GOTO exit

file_opened:	move    $s6,	$v0		# save the file descriptor
		li	$v0,	14		# read from file
		move	$a0,	$s6		# load fild discriptor into $a0
		la	$a1,	file_header	# address of input buffer where data will be read
		li	$a2,	54		# read maximum of 54 bytes (header size.)
		syscall

		# Print sig
		lb	$t0,	file_header     # first byte 'B' - not sure if using lh could work would have to some how setup a 3 byte with BM\n and print
		lb	$t1,	file_header+1   # second 'M'       seems easier to just print the two chars.
		li	$v0,	4		# Print helper text
		la	$a0,	print_first2
		syscall

		li	$v0,	11              # Print both 'B' and 'M'
		move	$a0,	$t0
		syscall
		move	$a0,	$t1
		syscall

		# Print file size
        	la	$a0,	file_header+2	# Base address
		jal	get_size		# funciton to get size
		move	$s0,	$v0		# store result
		li	$v0,	4		# Print helper text
		la	$a0,	print_size
		syscall
		li	$v0,	1		# Print the file size
		move	$a0,	$s0
		syscall
		
		# Print offset value where pixels start
        	la	$a0,	file_header+10	# Base address
		jal	get_size		# Call function
		move	$s1,	$v0		# Get result
		li	$v0,	4		# Print helper text
		la	$a0,	print_offset
		syscall
		li	$v0,	1		# Print the offset
		move	$a0,	$s1
		syscall

################################################################
# Part 2, allocate heap, read full file, print heap address.   #
################################################################
		# Allocate heap space for the entire file
		li	$v0,	9		# allocate heap
		move	$a0,	$s0		# file size in bytes
		syscall

		move	$s2,	$v0		# Save heap address in $s2

		# Read entire file into heap
		li	$v0,	14		# Read from file
		move	$a0,	$s6		# file descriptor
		move	$a1,	$s2		# Heap address as buffer input
		move	$a2,	$s0		# Read entire file size
		syscall

		# Print heap address
		li	$v0,	4		# Print helper text
		la	$a0,	print_heapaddr
		syscall
		li	$v0,	1		# Print heap address (as integer)
		move	$a0,	$s2
		syscall

################################################################
# Part 3, extract hidden city before '***'.                    #
################################################################
		add	$t0,	$s2,	$s1	# store start of pixel data (where to start searching)
		li	$t3,	0		# star_count (this will handle knowing we found 3 in a row)
		li	$t4,	0		# pointer to first '*' (this will be my marker for end of city)

		# Search for 3 stars in a row.
find_stars:	
		# Check if we've reached the end of the file (heap + file size)
		add     $t8,    $s2,    $s0         # $t8 = end address (heap + file size)
		bge     $t0,    $t8,    no_stars_found   # if scan pointer >= end, not found
		lb	$t5,	0($t0)		# Load byte if not at the end.
		bne	$t5,	0x2A,	reset_stars
		addi	$t3,	$t3,	1	# Increment star_count
		beq	$t3,	1,	set_first_star	# if count is 1, jump to save first '*' pos.
		j	check_three		# check the count

# No stars found error handler
no_stars_found:
		li      $v0,	4
		la      $a0,	no_stars_msg
		syscall
		j       exit

# Star found, check for 3 and extract city name.
set_first_star:	move	$t4,	$t0		# save pointer to first '*' (end of city marker.)
		j	check_three

reset_stars:	li	$t3,	0		# reset star_count
		li	$t4,	0		# reset first '*'

check_three:	bne	$t3,	3,	next_byte # check if 3 '*' have been found or not.
		
		# Found three '*', now work backwards from $t4 - 1 until non-alpha found.
		addi	$t6,	$t4,	-1		# Start before first '*'
backwards:	lb	$t5,	0($t6)			# Load byte
		blt	$t5,	'A',	not_alpha	# not alpha so now the the city starts at $t6 + 1 and goes until $t4 - 1 (first star - 1)
		bgt	$t5,	'Z',	check_lower	# not capital but could be lowercase, check for lower.
		j	next_back			# this one was a capital letter so move back to the next one.
check_lower:	blt	$t5,	'a',	not_alpha	# not upper or lower case, done, print city.
		bgt	$t5,	'z',	not_alpha	# not upper or lower case, done, print city.
		j	next_back			# this was a lower case leter so move back one and look for another.
not_alpha:	addi	$t7,	$t6,	1		# found non-alpha, $t7 = $t6 +1 first city letter to $t4 - 1  (kind of assuming a city was found and there isn't like !*** in the file.)

		li	$v0,	4		# Print helper text
		la	$a0,	print_city	# Meeting in ____
		syscall

		# Loop from the starting city letter to the ending city letter printing each character.
city_loop:	beq	$t7,	$t4,	done_print	# exit loop if our counter reaches the first star held in $t4.
		lbu	$t5,	0($t7)			# load the city letter to print it.
		li	$v0,	11			# print char syscall
		move	$a0,	$t5			# load char into $a0
		syscall
		
		addi	$t7,	$t7,	1		# increment to next letter
		j	city_loop			# jump to print the next if we are not as the star yet.
		
next_back:	addi	$t6,	$t6,	-1		# move one back to check the next letter.
		j	backwards
		
next_byte:	addi	$t0,	$t0,	1		# move one forward looking for star.
		j	find_stars

################################################################
# Cleanup and exit                                             #
################################################################
done_print:	li	$v0,	16		# close file
		move	$a0,	$s6		# file discriptor to close
		syscall

		li	$v0,	4		# print fin message
		la	$a0,	print_fin
		syscall

exit:		li	$v0,	10		# exit
		syscall

##########################################################
# Function: get_size                                     #
#   Args: $a0 address where size starts                  #
#   Returns: $v0 = 4-byte LE word                        #
##########################################################
get_size:	move	$t0,	$a0		# $t0 = address of first byte
		lbu	$t1,	0($t0)		# Load byte 0 LSB?
		lbu	$t2,	1($t0)		# Load byte 1
		lbu	$t3,	2($t0)		# Load byte 2
		lbu	$t4,	3($t0)		# Load byte 3 MSB?
		sll	$t4,	$t4,	24	# Shift to bits 24-31
		sll	$t3,	$t3,	16	# Shift to bits 16-23
        	sll	$t2,	$t2,	8	# Shift to bits 8-15
        	or	$v0,	$t4,	$t3	# Combine byte 3 and 2
        	or	$v0,	$v0,	$t2	# Combine with byte 1
        	or	$v0,	$v0,	$t1	# Combine with byte 0
        	jr	$ra			# Return $v0 has the size
