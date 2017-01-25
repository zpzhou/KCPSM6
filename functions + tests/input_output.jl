# INPUT sX, pp
# INPUT sX, (sY)
# OUTPUT sX, pp
# OUTPUT sX, (sY)
# OUTPUTK kk, p

# read in number between 0 and 255
# value to be written to target register

user_input = readline(STDIN)



function output(machine::CPU, reg)

	

	if machine.active_bank == 'A'
		index = find(A .== user_input)
		print( hex(A[index]) )
	else	# if machine.active_bank == 'B'
		index = find(B .== user_input)
		println( hex(B[index]) )
	end
end
