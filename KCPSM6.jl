# Assembly language parser for KCPSM6.

# type CPU encapsulates state of the processor
type CPU
	A::Array{Int,1} # reg_bank A
	B::Array{Int,1} # reg_bank B
	scratch::Array{Int,1}
	PC_stack::Array{Int,1}
	active_bank::Char
	PC::Int
	Cflag::Bool
	Zflag::Bool
	CPU(A::Array{Int,1},B::Array{Int,1}) = new(A,B,Array{Int}(256),Array{Int}(0),'A',0,0,0)
end

### INITIALIZE PROCESSOR AND OPEN PROGRAM

include("functions.jl")
f = open(ARGS[1]) 

labels = Dict()
program_memory = Array{AbstractString}(0)
machine = CPU(zeros(Int,16), zeros(Int,16))

### READ THROUGH FILE TO FIND AND STORE LABELS

i = 1; 
flines = readlines(f)
for line in flines # check every line
	if ismatch(r":",line) == true
		line = split(line,':')
		get!(labels,line[1],i) # push label and corresponding line number onto hash table
		line = line[2]
		push!(program_memory,line)
	else
		push!(program_memory,line)
	end
	i += 1
end

### EXECUTE PROGRAM

count = 0 # count to 10 unconditional jumps
flag = 0 # set if previous instruction was unconditional jump
reference = 0 # reference to previous JUMP label - increment count if curr = prev
opA = Int; opB = Int # operands to be passed into function call
while count != 10
	
	i = (machine.PC)+1
	#println(i)
	line = program_memory[i]
	line = lstrip(line) # removed leading white space
	line = chomp(line) # remove newline char
	len = length(line)
	
	# parse the current instruction, and prepare the correct operands
	# first operand is always register.
	# account for julia indexing starting at 1 when working with registers
	if contains(line,"HWBUILD") == true
		line[10] >= 97 ? opA = Int(line[10]-87)+1 : opA = parse(Int,line[10])+1
		hw_build(machine,opA)
		machine.PC += 1

	elseif contains(line,"LOAD&RETURN") == true 
		line[14] >= 97 ? opA = Int(line[14]-87)+1 : opA = parse(Int,line[14])+1
		opB = parse(Int,line[17:len])
		load_and_ret(machine,opA,opB)

	elseif line[1:4] == "LOAD" 
		line[7] >= 97 ? opA = Int(line[7]-87)+1 : opA = parse(Int,line[7])+1
		if line[len-1] == 's'
			line[len] >= 97 ? opB = Int(line[len]-87)+1 : opB = parse(Int,line[len])+1
			Load_register_register(machine,opA,opB)
		else
			opB = parse(Int,line[10:len])
			Load_register_constant(machine,opA,opB)
		end
		machine.PC += 1

	elseif line[1:4] == "STAR"
		line[7] >= 97 ? opA = Int(line[7]-87)+1 : opA = parse(Int,line[7])+1
		if line[len-1] == 's'
			line[len] >= 97 ? opB = Int(line[len]-87)+1 : opB = parse(Int,line[len])+1
			Star_reg_reg(machine,opA,opB)
		else 
			opB = parse(Int,line[10:len])
			Star_reg_const(machine,opA,opB)
		end
		machine.PC += 1
		#println(machine.B[opA])
	elseif line[1:5] == "STORE"
		line[8] >= 97? opA = Int(line[8]-87)+1 : opA = parse(Int,line[8])+1
		if line[len-2] == 's'
			line[len-1] >= 97 ? opB = Int(line[len-1]-87)+1 : opB = parse(Int,line[len-1])+1
			store_register_registerLoc(machine,opA,opB)
		else
			opB = parse(Int,line[10:len-1])+1
			store_register_constant(machine,opA,opB)
		end
		machine.PC += 1

	elseif line[1:5] == "FETCH"
		line[8] >= 97? opA = Int(line[8]-87)+1 : opA = parse(Int,line[8])+1
		if line[len-2] == 's'
			line[len-1] >= 97 ? opB = Int(line[len-1]-87)+1 : opB = parse(Int,line[len-1])+1
			fetch_register_registerLoc(machine,opA,opB)
		else
			opB = parse(Int,line[10:len-1])+1
			fetch_register_constant(machine,opA,opB)
		end
		machine.PC += 1

	elseif line[1:5] == "INPUT"
		line[8] >= 97? opA = Int(line[8]-87)+1 : opA = parse(Int,line[8])+1
		input(machine,opA)
		machine.PC += 1

	elseif line[1:6] == "OUTPUT"
		if line[7] == 'K'
			opA = parse(Int,line[9:10])
			opB = parse(Int,line[13:len])
			output_k(machine,opA,opB)
		else
			line[9] >= 97? opA = Int(line[9]-87)+1 : opA = parse(Int,line[9])+1
			if line[len-2] == 's'
				line[len-1] >= 97 ? opB = Int(line[len-1]-87)+1 : opB = parse(Int,line[len-1])+1
				indirect_output(machine,opA,opB)
			else
				opB = parse(Int,line[12:len-1])
				direct_output(machine,opA,opB)
			end
		end
		machine.PC += 1

	elseif line[1:3] == "AND"
		line[6] >= 97 ? opA = Int(line[6]-87)+1 : opA = parse(Int,line[6])+1
		if line[len-1] == 's'
			line[len] >= 97 ? opB = Int(line[len]-87)+1 : opB = parse(Int,line[len])+1
			AND_Register_Register(machine,opA,opB)
		else
			opB = parse(Int,line[9:len])
			AND_Register_Constant(machine,opA,opB)
		end
		machine.PC += 1

	elseif line[1:3] == "XOR"
		line[6] >= 97 ? opA = Int(line[6]-87)+1 : opA = parse(Int,line[6])+1
		if line[len-1] == 's'
			line[len] >= 97 ? opB = Int(line[len]-87)+1 : opB = parse(Int,line[len])+1
			XOR_Register_Register(machine,opA,opB)
		else
			opB = parse(Int,line[9:len])
			XOR_Register_Constant(machine,opA,opB)
		end
		machine.PC += 1

	elseif line[1:2] == "OR"
		line[5] >= 97 ? opA = Int(line[5]-87)+1 : opA = parse(Int,line[5])+1
		if line[len-1] == 's'
			line[len] >= 97 ? opB = Int(line[len]-87)+1 : opB = parse(Int,line[len])+1
			OR_Register_Register(machine,opA,opB)
		else
			opB = parse(Int,line[8:len])
			OR_Register_Constant(machine,opA,opB)
		end	
		machine.PC += 1

	elseif line[1:5] == "ADDCY"
		line[8] >= 97 ? opA = Int(line[8]-87)+1 : opA = parse(Int,line[8])+1
		if line[len-1] == 's'
			line[len] >= 97 ? opB = Int(line[6]-87)+1 : opB = parse(Int,line[len])+1
			ADDCY_Register_Register(machine,opA,opB)
		else
			opB = parse(Int,line[11:len])
			ADDCY_Register_Constant(machine,opA,opB)
		end
		machine.PC += 1
	
	elseif line[1:3] == "ADD"
		line[6] >= 97 ? opA = Int(line[6]-87)+1 : opA = parse(Int,line[6])+1
		if line[len-1] == 's'
			line[len] >= 97 ? opB = Int(line[6]-87)+1 : opB = parse(Int,line[len])+1
			ADD_Register_Register(machine,opA,opB)
		else
			opB = parse(Int,line[9:len])
			ADD_Register_Constant(machine,opA,opB)
		end
		machine.PC += 1
	
	elseif line[1:5] == "SUBCY"
		line[8] >= 97 ? opA = Int(line[8]-87)+1 : opA = parse(Int,line[8])+1
		if line[len-1] == 's'
			line[len] >= 97 ? opB = Int(line[6]-87)+1 : opB = parse(Int,line[len])+1
			SUBCY_Register_Register(machine,opA,opB)
		else
			opB = parse(Int,line[11:len])
			SUBCY_Register_Constant(machine,opA,opB)
		end
		machine.PC += 1
	
	elseif line[1:3] == "SUB"
		line[6] >= 97 ? opA = Int(line[6]-87)+1 : opA = parse(Int,line[6])+1
		if line[len-1] == 's'
			line[len] >= 97 ? opB = Int(line[6]-87)+1 : opB = parse(Int,line[len])+1
			SUB_Register_Register(machine,opA,opB)
		else
			opB = parse(Int,line[9:len])
			SUB_Register_Constant(machine,opA,opB)
		end
		machine.PC += 1
	
	elseif line[1:6] == "TESTCY"
		line[9] >= 97 ? opA = Int(line[9]-87)+1 : opA = parse(Int,line[9])+1
		if line[len-1] == 's' 
			line[len] >= 97 ? opB = Int(line[len]-87)+1 : opB = parse(Int,line[len])+1
			testcy_reg_reg(machine,opA,opB)
		else
			opB = parse(Int,line[13:len])
			testcy_reg_const(machine,opA,opB)
		end
		machine.PC +=1
	
	elseif line[1:4] == "TEST" 
		line[7] >= 97 ? opA = Int(line[7]-87)+1 : opA = parse(Int,line[7])+1
		if line[len-1] == 's' 
			line[len] >= 97 ? opB = Int(line[len]-87)+1 : opB = parse(Int,line[len])+1
			test_reg_reg(machine,opA,opB)
		else
			opB = parse(Int,line[11:len])
			test_reg_const(machine,opA,opB)
		end
		machine.PC += 1
	
	elseif contains(line,"COMPARECY") == true
		line[12] >= 97 ? opA = Int(line[12]-87)+1 : opA = parse(Int,line[12])+1
		if line[len-1] == 's' 
			line[len] >= 97 ? opB = Int(line[len]-87)+1 : opB = parse(Int,line[len])+1
			COMPARECY_Register_Register(machine,opA,opB)
		else
			opB = parse(Int,line[15:len])
			COMPARECY_Register_Constant(machine,opA,opB)
		end
		machine.PC +=1

	elseif contains(line,"COMPARE") == true
		line[10] >= 97 ? opA = Int(line[10]-87)+1 : opA = parse(Int,line[10])+1
		if line[len-1] == 's' 
			line[len] >= 97 ? opB = Int(line[len]-87)+1 : opB = parse(Int,line[len])+1
			COMPARE_Register_Register(machine,opA,opB)
		else
			opB = parse(Int,line[13:len])
			COMPARE_Register_Constant(machine,opA,opB)
		end
		machine.PC +=1
	
	elseif line[1:2] == "SL"
		line[6] >= 97 ? opA = Int(line[6]-87)+1 : opA = parse(Int,line[6])+1
		if line[3] == '0'
			SL_zero(machine,opA)
		elseif line[3] == '1'
			SL_one(machine,opA)
		elseif line[3] == 'X'
			SL_X(machine,opA)
		else
			SL_A(machine,opA)
		end
		machine.PC += 1
	
	elseif line[1:2] == "SR"
		line[6] >= 97 ? opA = Int(line[6]-87)+1 : opA = parse(Int,line[6])+1
		if line[3] == '0'
			SR_zero(machine,opA)
		elseif line[3] == '1'
			SR_one(machine,opA)
		elseif line[3] == 'X'
			SR_X(machine,opA)
		else
			SR_A(machine,opA)
		end
		machine.PC += 1

	elseif line[1:2] == "RL"
		line[5] >= 97 ? opA = Int(line[5]-87)+1 : opA = parse(Int,line[5])+1
		RL(machine,opA)
		machine.PC += 1

	elseif line[1:2] == "RR"
		line[5] >= 97 ? opA = Int(line[5]-87)+1 : opA = parse(Int,line[5])+1
		RR(machine,opA)
		machine.PC += 1
	
	elseif contains(line,"REGBANK") == true
		line[9] == 'A' ? regbank(machine,'A') : regbank(machine,'B')
		machine.PC += 1

	elseif line[1:4] == "JUMP"
		if line[5] == "@"
			line[9] <= 97 ? opA = Int(line[9]-87)+1 : opA = line[9]+1
			line[13] <= 97 ? opB = Int[line[13]-87]+1 : opB = line[13]+1
			jump_at(machine,opA,opB)
		elseif line[6] == 'C'
			key = line[9:len]
			value = get(labels,key,0)
			jump_c(machine,value)
		elseif line[6] == 'Z'
			key = line[9:len]
			value = get(labels,key,0)
			jump_z(machine,value)
		elseif line[6:7] == "NC"
			key = line[10:len]
			value = get(labels,key,0)
			jump_nc(machine,value)
		elseif line[6:7] == "NZ"
			key = line[10:len]
			value = get(labels,key,0)
			jump_nc(machine,value)
		else
			flag = 1
			key = line[6:len]
			value = get(labels,key,0)
			value == reference ? count += 1 : count = 1 
			reference = value
			jump(machine,value)
		end
	
	elseif line[1:4] == "CALL"
		if line[5] == "@"
			line[9] <= 97 ? opA = Int(line[9]-87)+1 : opA = line[9]+1
			line[13] <= 97 ? opB = Int[line[13]-87]+1 : opB = line[13]+1
			call_at(machine,opA,opB)
		elseif line[6] == 'C'
			key = line[9:len]
			value = get(labels,key,0)
			call_c(machine,value)
		elseif line[6] == 'Z'
			key = line[9:len]
			value = get(labels,key,0)
			call_z(machine,value)
		elseif line[6:7] == "NC"
			key = line[10:len]
			value = get(labels,key,0)
			call_nc(machine,value)
		elseif line[6:7] == "NZ"
			key = line[10:len]
			value = get(labels,key,0)
			call_nz(machine,value)
		else
			key = line[6:len]
			value = get(labels,key,0)
			call(machine,value)
		end

	elseif line[1:6] == "RETURN"
		if line[len] == 'N'
			ret(machine)
		elseif line[8] == 'C'
		 	ret_c(machine)
		elseif line[8] == 'Z'
		 	ret_z(machine)
		elseif line[8:9] == "NC"
		 	ret_nc(machine)
		else
			ret_nz(machine)
		end
	end

	flag != 1 && (count = 0)
	flag = 0

end




