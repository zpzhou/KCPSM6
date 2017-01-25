### RESET FUNCTION

function reset(machine::CPU)
	#println("STACK OVERFLOW")
	machine.active_bank = 'A'
	while length(machine.PC_stack) != 0
		pop!(machine.PC_stack)
	end
	machine.PC = 0
	machine.Cflag = 0
	machine.Zflag = 0
end

### REGISTER OPERATION INSTRUCTIONS

function regbank(machine::CPU, bank::Char)
	machine.active_bank = bank
end

### TEST/COMPARE INSTRUCTIONS

function test_reg_reg(machine::CPU, tested, mask)
	machine.active_bank == 'A' ? 
		result = bin(machine.A[tested] & machine.A[mask]):
		result = bin(machine.B[tested] % machine.B[mask])
	result == 0 && (machine.Zflag = 1)
	count = 0
	for i in result
		i == '1' && (count += 1)
	end
	count % 2 != 0 ? machine.Cflag = 1 : machine.Cflag = 0
end

function test_reg_const(machine::CPU, tested, mask)
	machine.active_bank == 'A' ?
		result = bin(machine.A[tested] & mask):
		result = bin(machine.B[tested] & mask)
	result == 0 && (machine.Zflag = 1)
	count = 0
	for i in result
		i == '1' && (count += 1)
	end
	count % 2 != 0 ? machine.Cflag = 1 : machine.Cflag = 0
end

function testcy_reg_reg(machine::CPU, tested, mask)
	machine.active_bank == 'A' ? 
		result = bin(machine.A[tested] & machine.A[mask]):
		result = bin(machine.B[tested] % machine.B[mask])
	if result != 0 | machine.Zflag != 1
		machine.Zflag = 0
	end
	count = 0
	for i in result
		i == '1' && (count += 1)
	end
	if machine.Cflag == 1 & count % 2 != 0
		machine.Cflag = 0
	elseif machine.Cflag == 0 & count % 2 == 0
		machine.Clag = 1
	end
end

function testcy_reg_const(machine::CPU, tested, mask)
	machine.active_bank == 'A' ?
		result = bin(machine.A[tested] & mask):
		result = bin(machine.B[tested] & mask)
	if result != 0 | machine.Zflag != 1
		machine.Zflag = 0
	end
	count = 0
	for i in result
		i == '1' && (count += 1)
	end
	if machine.Cflag == 1 & count % 2 != 0
		machine.Cflag = 0
	elseif machine.Cflag == 0 & count % 2 == 0
		machine.Clag = 1
	end
end
function COMPARE_Register_Register(machine::CPU,register1Index, register2Index)

      machine.active_bank =='B'?
      result = (Int(machine.B[register1Index]) -Int(machine.B[register2Index])):
      result =Int(machine.A[register1Index]) -Int(machine.A[register2Index])

      result < 0 ? machine.Cflag = 1 : machine.Cflag = 0
      result == 0 ? machine.Zflag = 1 : machine.Zflag = 0

      # println("Cflag = $(machine.Cflag)")
      # println("Zflag = $(machine.Zflag)")

end
function COMPARE_Register_Constant(machine::CPU,register1Index, constant)

  if machine.active_bank=='B'
      result = (Int(machine.B[register1Index]) -Int(constant))
      end
  if machine.active_bank=='A'
          result = (Int(machine.A[register1Index]) -Int(constant))
   end
   result < 0 ? machine.Cflag = 1 : machine.Cflag = 0
   result == 0 ? machine.Zflag = 1 : machine.Zflag = 0

      # println("Cflag = $(machine.Cflag)")
      # println("Zflag = $(machine.Zflag)")
end

function COMPARECY_Register_Constant(machine::CPU,register1Index, constant)

  if machine.active_bank=='B'
      SUB_value = (Int(machine.B[register1Index]) -Int(constant))-machine.Cflag
      SUB_value == 0 && machine.Zflag == 1 ? machine.Zflag = 1 : machine.Zflag = 0
      SUB_value < 0 ? machine.Cflag = 1 : machine.Cflag = 0
  end
  if machine.active_bank=='A'
      SUB_value = (Int(machine.A[register1Index]) -Int(constant))-machine.Cflag
      SUB_value == 0 && machine.Zflag == 1 ? machine.Zflag = 1 : machine.Zflag = 0
      SUB_value < 0 ? machine.Cflag = 1 : machine.Cflag = 0      
  end

   # println("Cflag = $(machine.Cflag)")
   # println("Zflag = $(machine.Zflag)")
end

function COMPARECY_Register_Register(machine::CPU,register1Index, register2Index)
    machine.active_bank=='B'?
    result = (Int(machine.B[register1Index]) -Int(machine.B[register2Index])) -Int(machine.Cflag):
   	result =Int(machine.A[register1Index]) -Int(machine.A[register2Index])-Int(machine.Cflag)
   	result == 0 && machine.Zflag == 1 ? machine.Zflag = 1 : machine.Zflag = 0
   	result < 0 ? machine.Cflag = 1 : machine.Cflag = 0
end

### LOAD/STAR INSTRUCTIONS (REGISTERS)

function Load_register_constant(machine::CPU,registerIndex,constant)#instruction file i/o,  which bank is selected
    #CONVERT INPUT INTO BINARY.
    if machine.active_bank=='B'
        machine.B[registerIndex] = constant
       	#println("Register $(registerIndex-1) = $(machine.B[registerIndex])")	
    end
    if machine.active_bank=='A'
        machine.A[registerIndex] = constant   
       	#println("Register $(registerIndex-1) = $(machine.A[registerIndex])")
    end
end

function Load_register_register(machine::CPU, register1Index, register2Index)
   	if machine.active_bank=='B'
       	machine.B[register1Index] = machine.B[register2Index]
     	#println("Register $(register1Index-1) = $(machine.B[register2Index])")
   end
   if machine.active_bank=='A'
      machine.A[register1Index] = machine.A[register2Index]
      #println("Register $(register1Index-1) = $(machine.A[register2Index])")
   end
 end

function Star_reg_reg(machine::CPU, opA, opB)
	machine.active_bank == 'A' ? 
		machine.B[opA] = machine.A[opB]:
		machine.A[opA] = machine.B[opB]
end

function Star_reg_const(machine::CPU, opA, val)
	machine.active_bank == 'A' ? 
		machine.B[opA] = val : 
		machine.A[opA] = val
end

### STORE/FETCH INSTRUCTIONS (SCRATCH MEMORY)

function store_register_constant(machine::CPU,registerIndex::Int,constant::Int)
  if machine.active_bank=='B'
      machine.scratch[constant] = machine.B[registerIndex]
      ##println(machine.scratch[constant])
  end
  if machine.active_bank=='A'
      machine.scratch[constant] = machine.A[registerIndex]
  end
end

function store_register_registerLoc(machine::CPU,registerIndex::Int,registerIndexLoc::Int)
  if machine.active_bank=='B'
      machine.scratch[machine.B[registerIndexLoc]] = machine.B[registerIndex]
  end
  if machine.active_bank=='A'
      machine.scratch[machine.A[registerIndexLoc]] = machine.A[registerIndex]
  end
end

function fetch_register_constant(machine::CPU,registerIndex::Int,constant::Int)
  if machine.active_bank=='B'
      machine.B[registerIndex] = machine.scratch[constant]
      ##println(machine.scratch[constant])
  end
  if machine.active_bank=='A'
      machine.A[registerIndex] = machine.scratch[constant]
  end
end

function fetch_register_registerLoc(machine::CPU,registerIndex::Int,registerIndexLoc::Int)
  if machine.active_bank=='B'
      machine.B[registerIndex] = machine.scratch[machine.B[registerIndexLoc]]
      ##println("Register $(registerIndex-1) = $(machine.B[registerIndex])")

  end
  if machine.active_bank=='A'
      machine.A[registerIndex] = machine.scratch[machine.A[registerIndexLoc]]
      ##println("Register $(registerIndex-1) = $(machine.A[registerIndex])")
  end
end

### ARITHMETIC/LOGICAL INSTRUCTIONS

function AND_Register_Register(machine::CPU,register1Index,register2Index)
          if machine.active_bank=='B' 
              #note new julia allows & allows simbol.
              machine.B[register1Index] =  Int(machine.B[register1Index]) & Int(machine.B[register2Index])
              #println("Register $(register1Index-1) = $(machine.B[register1Index])")
          end
          if machine.active_bank=='A'
              machine.A[register1Index]= Int(machine.A[register1Index]) & Int(machine.A[register2Index])
              #println("Register $(register1Index-1) = $(machine.A[register1Index])")
          end

end

function AND_Register_Constant(machine::CPU,register1Index,constant)


  if machine.active_bank=='B'
      #note new julia allows & allows simbol.
      resulting_And= machine.B[register1Index] & Int(constant)
      machine.B[register1Index] = resulting_And
  	  #println("Register $(register1Index-1) = $(machine.A[register1Index])")
  end

  if machine.active_bank=='A'
       resulting_And= machine.A[register1Index] & Int(constant)
       machine.A[register1Index] = resulting_And
       #println("Register $(register1Index-1) = $(machine.A[register1Index])")
    end

end

function OR_Register_Register(machine::CPU,register1Index,register2Index)
  if machine.active_bank=='B'

      machine.B[register1Index] = machine.B[register1Index] | machine.B[register2Index]
      #println("Register $(register1Index-1) = $(machine.B[register1Index])")
  end
  if machine.active_bank=='A'
      machine.A[register1Index]= Int(machine.A[register1Index]) | Int(machine.A[register2Index])
      #println("Register $(register1Index-1) = $(machine.A[register1Index])")
    end

end

function OR_Register_Constant(machine::CPU,register1Index,constant)
  if machine.active_bank=='B'
      machine.B[register1Index] = machine.B[register1Index] | Int(constant)
      #println("Register $(register1Index-1) = $(machine.B[register1Index])")
  end
  if machine.active_bank=='A'
      machine.A[register1Index]= machine.A[register1Index] | Int(constant)
      #println("Register $(register1Index-1) = $(machine.A[register1Index])")
    end

end

function XOR_Register_Register(machine::CPU,register1Index,register2Index)
  if machine.active_bank=='B'

      machine.B[register1Index] = (Int(machine.B[register1Index]) $ Int(machine.B[register2Index]))
      #println("Register $(register1Index-1) = $(machine.B[register1Index])")
  end
  if machine.active_bank=='A'
      machine.A[register1Index]= (Int(machine.A[register1Index]) $ Int(machine.A[register2Index]))
      #println("Register $(register1Index-1) = $(machine.A[register1Index])")
  end
end

function XOR_Register_Constant(machine::CPU,register1Index,constant)
  if machine.active_bank=='B'

      machine.B[register1Index] = (Int(machine.B[register1Index]) $ Int(constant))
      #println("Register $(register1Index-1) = $(machine.B[register1Index])")
  end
  if machine.active_bank=='A'
      machine.A[register1Index] = (Int(machine.A[register1Index]) $ Int(constant))
      ##println("Register $(register1Index-1) = $(machine.A[register1Index])")
    end
end

function flagcheckADD(machine::CPU,result::Int64)
  if result==0
     machine.Zflag = true
  elseif result != 0
     machine.Zflag = false
  end
  if result>255

     machine.Cflag = true
  else
    machine.Cflag = false
  end
end

function ADD_Register_Constant(machine::CPU,register1Index,constant)
  if machine.active_bank=='B'
      resulting_ADD = (Int(machine.B[register1Index]) + Int(constant))
      if resulting_ADD<=255
      machine.B[register1Index] = resulting_ADD
      machine.Zflag = 0
      machine.Cflag = 0
       else
      	remainder = resulting_ADD - 256
       remainder == 0 && (machine.Zflag = 1)
       machine.Cflag = 1
       machine.B[register1Index] = remainder 
   		end
   	  ##println("Register $(register1Index-1) + $constant = $(machine.B[register1Index])")
   end
     
  if machine.active_bank =='A'
      resulting_ADD = (Int(machine.A[register1Index]) + Int(constant))
      if resulting_ADD<=255
      machine.A[register1Index] = resulting_ADD
      machine.Zflag = 0
      machine.Cflag = 0
      else
      remainder = resulting_ADD - 256
      remainder == 0 && (machine.Zflag = 1)
       machine.Cflag = 1
       machine.A[register1Index] = remainder   
  		end
  		##println("Register $(register1Index-1) + $constant = $(machine.A[register1Index])")
	end
end
  

function ADD_Register_Register(machine::CPU,register1Index,register2Index)
  if machine.active_bank=='B'
      resulting_ADD = (Int(machine.B[register1Index]) + Int(machine.B[register2Index]))
      #print 255
      if resulting_ADD<=255
      machine.B[register1Index] = resulting_ADD
      machine.Zflag = 0
      machine.Cflag = 0
     else
     	remainder = resulting_ADD - 256
      	remainder == 0 && (machine.Zflag = 1)
    	machine.Cflag = 1
     	machine.B[register1Index] = remainder
     end
     ##println("Register $(register1Index-1) + Register $(register2Index-1) = $(machine.B[register1Index])")
  end
  if machine.active_bank=='A'
      resulting_ADD = (Int(machine.A[register1Index]) + Int(machine.A[register2Index]))
      if resulting_ADD<=255
      machine.A[register1Index] = resulting_ADD
      machine.Zflag = 0
      machine.Cflag = 0
      else
      	remainder = resulting_ADD - 256
       remainder == 0 && (machine.Zflag = 1)
       machine.Cflag = 1
       machine.A[register1Index] = remainder
   	  end 
     	##println("Register $(register1Index-1) + Register $(register2Index-1) = $(machine.A[register1Index])")
  end
end
function ADDCY_Register_Constant(machine::CPU,register1Index,constant)
  if machine.active_bank=='B'
      resulting_ADD = (Int(machine.B[register1Index]) + Int(constant))+machine.Cflag
      if resulting_ADD<=255
      machine.B[register1Index] = resulting_ADD
      machine.Cflag = 0
      machine.Zflag = 0

      else 
       remainder = resulting_ADD - 256
       remainder == 0 && (machine.Zflag = 1)
       machine.Cflag = 1
       machine.B[register1Index] = remainder
       
     end
      ##println("Register $(register1Index-1) + $constant = $(machine.B[register1Index])")
  end
  if machine.active_bank=='A'
      resulting_ADD = (Int(machine.A[register1Index]) + Int(constant))+ machine.Cflag
      #print 255
      if resulting_ADD<=255
      machine.A[register1Index] = resulting_ADD
      machine.Cflag = 0
       machine.Zflag = 0
      else
       remainder = resulting_ADD - 256
       remainder == 0 && (machine.Zflag = 1)
       machine.Cflag = 1
       machine.A[register1Index] = remainder
       
     end
       ##println("Register $(register1Index-1) + $constant = $(machine.A[register1Index])")
  end
end

function ADDCY_Register_Register(machine::CPU,register1Index,register2Index)
  if machine.active_bank=='B'
      resulting_ADD = Int(machine.B[register1Index]) + Int(machine.B[register2Index])+machine.Cflag
      #print 255
      if resulting_ADD<=255
      machine.B[register1Index] = resulting_ADD
       machine.Cflag = 0
       machine.Zflag = 0

   else
      remainder = resulting_ADD - 256
       remainder == 0 && (machine.Zflag = 1)
       machine.Cflag = 1
       machine.B[register1Index] = remainder
     end
     ##println("Register $(register1Index-1) + Register $(register2Index-1) = $(machine.B[register1Index])")

  end
  if machine.active_bank=='A'
      resulting_ADD = Int(machine.A[register1Index]) + Int(machine.A[register2Index])+ machine.Cflag
      #println(resulting_ADD)
      if resulting_ADD<=255
      machine.A[register1Index] = resulting_ADD
      machine.Zflag = 0
      machine.Cflag = 0

      else
      	remainder = resulting_ADD - 256
       remainder == 0 && (machine.Zflag = 1)
       machine.Cflag = 1
       machine.A[register1Index] = remainder
     end
     ##println("Register $(register1Index-1) + Register $(register2Index-1) = $(machine.A[register1Index])")

  end
end

function flagcheckSUB(machine::CPU,result)
   result==0 ? machine.Zflag = true : machine.Zflag = false
   result<0 ? machine.Cflag = true : machine.Cflag = false
end

function SUB_Register_Constant(machine::CPU,register1Index,constant)
	machine.active_bank=='B'?
    result = Int(machine.B[register1Index]) -Int(constant):
    result = Int(machine.A[register1Index]) -Int(constant)

    machine.active_bank=='B'?
    flagcheckSUB(machine,result):
    flagcheckSUB(machine,result)

    result = mod(result,256)

    machine.active_bank =='B'?
    machine.B[register1Index] = result:
    machine.A[register1Index] = result

end

function SUB_Register_Register(machine::CPU,register1Index,register2Index)
    machine.active_bank=='B'?
    result = (Int(machine.B[register1Index]) -Int(machine.B[register2Index])):
    result = (Int(machine.A[register1Index]) -Int(machine.B[register2Index]))

    machine.active_bank=='B'?
    flagcheckSUB(machine,result):
    flagcheckSUB(machine,result)

    result = mod(result,256)
   
    machine.active_bank =='B'?
    machine.B[register1Index] = result:
    machine.A[register1Index] = result
end

function SUBCY_Register_Constant(machine::CPU,register1Index,constant)
	machine.active_bank=='B'?
	result = (Int(machine.B[register1Index]) -Int(constant)-machine.Cflag):
    result = (Int(machine.A[register1Index]) -Int(constant)-machine.Cflag)

    machine.active_bank=='B'?
    flagcheckSUB(machine,result):
    flagcheckSUB(machine,result)

    result = mod(result,256)

    machine.active_bank =='B'?
    machine.B[register1Index] = result:
    machine.A[register1Index] = result
 end

function SUBCY_Register_register(machine::CPU,register1Index,register2Index)
	machine.active_bank=='B'?
  	result = (Int(machine.B[register1Index]) -Int(machine.B[register2Index])-machine.Cflag):
  	result = (Int(machine.A[register1Index]) -Int(machine.A[register2Index])-machine.Cflag)

  	machine.active_bank=='B'?
  	flagcheckSUB(machine,result):
  	flagcheckSUB(machine,result)

  	result = mod(result,256)

  	machine.active_bank =='B'?
 	machine.B[register1Index] = result:
  	machine.A[register1Index] = result
end

### SHIFT/ROTATE INSTRUCTIONS


function SL_zero(machine::CPU, reg)#SHIFT  REGISTA OR B
#shift the elements,
#using the shifting
#if the this results in overflow, push to the c flag.
#if bin of integer of first is one, c flag on,
# else just shift the flag.

	if machine.active_bank == 'A'

	  if machine.A[reg] > 255
	    machine.A[reg] = 255
	  end

	  A_temp = machine.A[reg]
	  if A_temp >= 128
	    A_temp = machine.A[reg] << 1
	    machine.Cflag = 1
	    A_temp = A_temp - 2^8
	    machine.A[reg] = A_temp
	    machine.A[reg] == 0 ? machine.Zflag = 1 : machine.Zflag = 0
	  else
	    A_temp = machine.A[reg] << 1
	    machine.Cflag = 0
	    machine.A[reg] = A_temp
	    machine.A[reg] == 0 ? machine.Zflag = 1 : machine.Zflag = 0
	  end

	else  # if machine.active_bank == 'B'

	  if machine.B[reg] > 255
	    machine.B[reg] = 255
	  end

	  B_temp = machine.B[reg] << 1
	  if B_temp >= 128
	    machine.Cflag = 1
	    B_temp = B_temp - 2^8
	    machine.B[reg] = B_temp
	    machine.B[reg] == 0 ? machine.Zflag = 1 : machine.Zflag = 0
	  else
	    machine.Cflag = 0
	    machine.B[reg] = B_temp
	    machine.B[reg] == 0 ? machine.Zflag = 1 : machine.Zflag = 0
	  end
	end

end

function SL_one(machine::CPU,reg)
	if machine.active_bank == 'A'
		if machine.A[reg] >= 128
			machine.Cflag = 1
			machine.A[reg] = (machine.A[reg] << 1) - 2^8 + 1
		else
			machine.Cflag = 0
			machine.A[reg] = (machine.A[reg] << 1) + 1
		end
	else
		if machine.B[reg] >= 128
			machine.Cflag = 1
			machine.B[reg] = (machine.B[reg] << 1) - 2^8 + 1
		else
			machine.Cflag = 0
			machine.B[reg] = (machine.B[reg] << 1) + 1
		end
	end
	machine.Zflag = 0
end

function SL_X(machine::CPU,reg)
	bit = 0
	if machine.active_bank == 'A'
		machine.A[reg] % 2 != 0 ? bit = 1 : bit = 0
		if machine.A[reg] >= 128
			machine.Cflag = 1
			machine.A[reg] = (machine.A[reg] << 1) - 2^8 + bit
		else
			machine.Cflag = 0
			 machine.A[reg] = (machine.A[reg] << 1) + bit
		end
		machine.A[reg] == 0 ? machine.Zflag = 1 : machine.Zflag = 0
	else
		machine.B[reg] % 2 != 0 ? bit = 1 : bit = 0
		if machine.B[reg] >= 128
			machine.Cflag = 1
			machine.B[reg] = (machine.B[reg] << 1) - 2^8 + bit
		else
			machine.Cflag = 0
			 machine.B[reg] = (machine.B[reg] << 1) + bit
		end
		machine.B[reg] == 0 ? machine.Zflag = 1 : machine.Zflag = 0
		
	end
end

function SL_A(machine::CPU,reg)
	old_flag = machine.Cflag
	if machine.active_bank == 'A'
		if machine.A[reg] >= 128
			machine.Cflag = 1
			machine.A[reg] = (machine.A[reg] << 1) - 2^8 + old_flag
		else
			machine.Cflag = 0
			 machine.A[reg] = (machine.A[reg] << 1) + old_flag
		end
		machine.A[reg] == 0 ? machine.Zflag = 1 : machine.Zflag = 0
		
	else
		if machine.B[reg] >= 128
			machine.Cflag = 1
			machine.B[reg] = (machine.B[reg] << 1) - 2^8 + old_flag
		else
			machine.Cflag = 0
			machine.B[reg] = (machine.B[reg] << 1) + old_flag
		end
		machine.B[reg] == 0 ? machine.Zflag = 1 : machine.Zflag = 0
		
	end
end

function SR_zero(machine::CPU, reg)
	if machine.active_bank == 'A' 
		machine.A[reg] % 2 != 0 ? machine.Cflag = 1 : machine.Cflag = 0
		machine.A[reg] = machine.A[reg] >> 1
		machine.A[reg] == 0 ? machine.Zflag = 0 : machine.Zflag = 1
	else
		machine.B[reg] % 2 != 0 ? machine.Cflag = 1 : machine.Cflag = 0
		machine.B[reg] = dec >> 1
		machine.B[reg] == 0 ? machine.Zflag = 1 : machine.Zflag = 0
	end
end

function SR_one(machine::CPU, reg)
	if machine.active_bank == 'A'
		machine.A[reg] % 2 != 0 ? machine.Cflag = 1 : machine.Cflag = 0
		machine.A[reg] = (machine.A[reg] >> 1) + 128
	else
		machine.B[reg] % 2 != 0 ? machine.Cflag = 1 : machine.Cflag = 0
		machine.B[reg] = (dec >> 1) + 128
	end
	machine.Zflag = 0
end

function SR_X(machine::CPU, reg)
	if machine.active_bank == 'A'
		machine.A[reg] % 2 != 0 ? machine.Cflag = 1 : machine.Cflag = 0
		machine.A[reg] >= 128 ? 
			machine.A[reg] = (machine.A[reg] >> 1) + 128 :
			machine.A[reg] =  machine.A[reg] >> 1
		machine.A[reg] == 0 ? machine.Zflag = 1 : machine.Zflag = 0
	else
		machine.B[reg] % 2 != 0 ? machine.Cflag = 1 : machine.Cflag = 0
		machine.B[reg] >= 128 ? 
			machine.B[reg] = (machine.B[reg] >> 1) + 128:
			machine.B[reg] =  machine.B[reg] >> 1
		machine.B[reg] == 0 ? machine.Zflag = 1 : machine.Zflag = 0
	end
end

function SR_A(machine::CPU, reg)
	Cflag_old = machine.Cflag
	if machine.active_bank == 'A'
		machine.A[reg] % 2 != 0 ? machine.Cflag = 1 : machine.Cflag = 0
		Cflag_old == 1 ? 
			machine.A[reg] = (machine.A[reg] >> 1) + 128 :
			machine.A[reg] =  machine.A[reg] >> 1
		machine.A[reg] == 0 ? machine.Zflag = 1 : machine.Zflag = 0
	else
		machine.B[reg] % 2 != 0 ? machine.Cflag = 1 : machine.Cflag = 0
		Cflag_old == 1 ? 
			machine.B[reg] = (machine.B[reg] >> 1) + 128 :
			machine.B[reg] =  machine.B[reg] >> 1
		machine.B[reg] == 0 ? machine.Zflag = 1 : machine.Zflag = 0
	end
end

function RL(machine::CPU, reg)
  if machine.active_bank == 'A'

  if machine.A[reg] > 255
    machine.A[reg] = 255
  end

  A_temp = machine.A[reg]
  if A_temp >= 128
    A_temp = machine.A[reg] << 1
    machine.Cflag = 1
    A_temp = A_temp - 2^8
    machine.A[reg] = A_temp
    machine.A[reg] == 0 ? machine.Zflag = 1 : machine.Zflag = 0
  else
    A_temp = machine.A[reg] << 1
    machine.Cflag = 0
    machine.A[reg] = A_temp
    
  end

  if machine.Cflag == 1
    machine.A[reg] = machine.A[reg] + 1
  end

  machine.A[reg] == 0 ? machine.Zflag = 1 : machine.Zflag = 0

  else  # if machine.active_bank == 'B'

  if machine.B[reg] > 255
    machine.B[reg] = 255
  end

  B_temp = machine.B[reg] << 1
  if B_temp >= 128
    machine.Cflag = 1
    B_temp = B_temp - 2^8
    machine.B[reg] = B_temp
    machine.B[reg] == 0 ? machine.Zflag = 1 : machine.Zflag = 0
  else
    machine.Cflag = 0
    machine.B[reg] = B_temp
    
  end

  if machine.Cflag == 1
    machine.B[reg] = machine.B[reg] + 1
  end

  machine.B[reg] == 0 ? machine.Zflag = 1 : machine.Zflag = 0

  end

end

function RR(machine::CPU, reg)
    if machine.active_bank == 'A' 
        machine.A[reg] % 2 != 0 ? machine.Cflag = 1 : machine.Cflag = 0
        machine.A[reg] = machine.A[reg] >> 1

        if machine.Cflag == 1
          machine.A[reg] = machine.A[reg] + 2^7
        end

        machine.A[reg] == 0 ? machine.Zflag = 1 : machine.Zflag = 0
    else
        machine.B[reg] % 2 != 0 ? machine.Cflag = 1 : machine.Cflag = 0
        machine.B[reg] = machine.B[reg] >> 1

        if machine.Cflag == 1
          machine.B[reg] = machine.B[reg] + 2^7
        end

        machine.B[reg] == 0 ? machine.Zflag = 1 : machine.Zflag = 0
    end
end

### INPUT/OUTPUT INSTRUCTIONS

function input(machine::CPU, reg_index)
	user_input = readline(STDIN)
	machine.active_bank == 'A' ? 
		machine.A[reg_index] = parse(Int,user_input) : 
		machine.B[reg_index] = parse(Int,user_input)
end

function direct_output(machine::CPU, reg_index, port_number)
	machine.active_bank == 'A' ? 
		println("$(hex(port_number,2)) $(hex(machine.A[reg_index],2))") : 
		println("$(hex(port_number,2)) $(hex(machine.B[reg_index],2))")
end

function indirect_output(machine::CPU, reg_index, port_number)
	machine.active_bank == 'A' ?
		println("$(hex(machine.A[port_number],2)) $(hex(machine.A[reg_index],2))") : 
		println("$(hex(machine.B[port_number],2)) $(hex(machine.B[reg_index],2))")
end

function output_k(machine::CPU, val, port)
	println("$(hex(port,2)) $(hex(val,2))")
end

### JUMP INSTRUCTIONS

function jump(machine::CPU, value::Int)
	machine.PC = value-1
end

function jump_c(machine::CPU, value::Int)
	machine.Cflag == 1 ? machine.PC = value-1 : machine.PC += 1
end

function jump_z(machine::CPU, value::Int)
	machine.Zflag == 1 ? machine.PC = value-1 : machine.PC += 1
end

function jump_nc(machine::CPU, value::Int)
	machine.Cflag == 0 ? machine.PC = value-1 : machine.PC += 1
end

function jump_nz(machine::CPU, value::Int)
	machine.Zflag == 0 ? machine.PC = value-1 : machine.PC += 1
end

function jump_at(machine::CPU, sA::Int, sB::Int)
	if machine.active_bank == 'A'
		upper = machine.A[sA] & 0xf
		upper = upper << 8 
		machine.PC = upper | machine.A[sB]
	else
		upper = machine.B[sA] & 0xf
		upper = upper << 8 
		machine.PC = upper | machine.B[sB]
	end
end

### CALL INSTRUCTIONS

function call(machine::CPU, value::Int)
	push!(machine.PC_stack,machine.PC)
	machine.PC = value-1
	length(machine.PC_stack) > 30 && reset(machine)
end

function call_c(machine::CPU, value::Int)
	if machine.Cflag == 1
		push!(machine.PC_stack,machine.PC)
		machine.PC = value-1
		if length(machine.PC_stack) > 30 
			reset(machine)
			return
		end
	else
		machine.PC += 1
	end
end

function call_z(machine::CPU, value::Int)
	if machine.Zflag == 1
		push!(machine.PC_stack,machine.PC)
		machine.PC = value-1
		if length(machine.PC_stack) > 30 
			reset(machine)
			return
		end
	else
		machine.PC += 1
	end
end

function call_nc(machine::CPU, value::Int)
	if machine.Cflag == 0
		push!(machine.PC_stack,machine.PC)
		machine.PC = value-1
		if length(machine.PC_stack) > 30 
			reset(machine)
			return
		end
	else
		machine.PC += 1
	end
end

function call_nz(machine::CPU, value::Int)
	if machine.Zflag == 0
		push!(machine.PC_stack,machine.PC)
		machine.PC = value-1
		if length(machine.PC_stack) > 30 
			reset(machine)
			return
		end
	else
		machine.PC += 1
	end
end

function call_at(machine::CPU, sA::Int, sB::Int)
	if machine.active_bank == 'A'
		push!(machine.PC_stack,machine.PC)
		if length(machine.PC_stack) > 30 
			reset(machine)
			return
		end
		upper = machine.A[sA] & 0xf
		upper = upper << 8 
		machine.PC = upper | machine.A[sB]
	else
		push!(machine.PC_stack,machine.PC)
		if length(machine.PC_stack) > 30 
			reset(machine)
			return
		end
		upper = machine.B[sA] & 0xf
		upper = upper << 8 
		machine.PC = upper | machine.B[sB]
	end
end

### RETURN INSTRUCTIONS

function ret(machine::CPU)
	machine.PC = pop!(machine.PC_stack) + 1
end

function ret_z(machine::CPU)
  if machine.Zflag == 1
    ret_address = pop!(machine.PC_stack)
    machine.PC = ret_address+1
  else
    machine.PC += 1
  end
end

function ret_c(machine::CPU)
  if machine.Cflag == 1
    ret_address = pop!(machine.PC_stack)
  else
    machine.PC += 1
  end
end

function ret_nz(machine::CPU)
  if machine.Zflag == 0
    ret_address = pop!(machine.PC_stack)
    machine.PC = ret_address+1
  else
    machine.PC += 1
  end
end

function ret_nc(machine::CPU)
 	if machine.Cflag == 0
    	ret_address = pop!(machine.PC_stack)
    	machine.PC = ret_address+1
 	else
    	machine.PC += 1
	end
end

function load_and_ret(machine::CPU, reg, val)
	machine.active_bank == 'A' ? machine.A[reg] = val : machine.B[reg] = val
	machine.PC = pop!(machine.PC_stack) + 1
end
		
function hw_build(machine::CPU, reg)
	machine.active_bank == 'A' ? machine.A[reg] = 0 : machine.B[reg] = 0
	machine.Cflag = 1
	machine.Zflag = 1
end




