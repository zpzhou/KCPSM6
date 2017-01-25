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