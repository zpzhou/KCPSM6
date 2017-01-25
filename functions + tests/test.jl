type CPU
  A::Array{UInt16,1} # reg_bank A
  B::Array{UInt16,1} # reg_bank B
  PC_stack::Array{Int16,1}
  active_bank::Char
  PC::Int16
  Cflag::Bool
  Zflag::Bool
  CPU(A::Array{UInt16,1},B::Array{UInt16,1}) = new(A,B,Array{UInt}(0),'A',0,0,0)
end

# for testing

machine = CPU(zeros(UInt16,16), zeros(UInt16,16))
machine.A = [128, 85, 100, 354]

#=
# SHIFT LEFT ZERO FUNCTION

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



i = 1
println("decimal number before sl_zero:\t", machine.A[i])
println("binary number before sl_zero:\t", bin(machine.A[i]))
SL_zero(machine, i)
println("binary number after sl_zero:\t", bin(machine.A[i]))
println("decimal number after sl_zero:\t", machine.A[i])


println("carry flag:\t", machine.Cflag)
println("zero flag:\t", machine.Zflag)
=#


#=
# ROTATE LEFT FUNCTION

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

i = 1
println("decimal number before RL:\t", machine.A[i])
println("binary number before RL:\t", bin(machine.A[i]))
RL(machine, i)
println("binary number after RL:\t\t", bin(machine.A[i]))
println("decimal number after RL:\t", machine.A[i])


println("carry flag:\t", machine.Cflag)
println("zero flag:\t", machine.Zflag)
=#


# ROTATE RIGHT FUNCTION
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


i = 3
println("decimal number before RR:\t", machine.A[i])
println("binary number before RR:\t", bin(machine.A[i]))
RR(machine, i)
println("binary number after RR:\t\t", bin(machine.A[i]))
println("decimal number after RR:\t", machine.A[i])


println("carry flag:\t", machine.Cflag)
println("zero flag:\t", machine.Zflag)
