# Lab_3_Single_Cycle_MIPS_Processor
Project Overview:  
32-Bit Single Cycle MIPS Processor using Verilog.  
  
The purpose of this lab was to combine our register file and ALU modules (made in previous labs), together and use them to help create a Single Cycle MIPS Processor. I used these modules, along with the Controller module and Test bench module provided to us by the professor, to help me create the Single Cycle MIPS Processor.   
  
Aside from these modules, I needed to implement a Program Counter, an Instruction Memory, a Data Memory, and other various multiplexors, adders, and logical gates in order to implement the processor. The processor module only has two input variables: clock and reset. It does not contain any output variables. All of the other variables contained within the processor are local to the Single Cell Processor module. The verilog source code files contain an in-depth discussion of each module and its purpose within the project.
  
Here is the block-diagram for this project:      
![ScreenShot](https://cloud.githubusercontent.com/assets/14812721/24940286/0c93931e-1ef7-11e7-8c45-b3658d81031e.jpg)      

Dependencies:   
This project was created using the Xilinx ISE Project Navigator Version: 14.7.  
   
Project Verification:  
This project was verified using the SingleCycle_tb module.
  
The test bench for this lab was extremely simple. First, the local variables were declared and then the unit under test (the Single Cycle Processor) was instantiated. Next, I initialized the Data Memory within the Processor to contain all 0 values. Then it was established that the clock would complement itself every #10 and the Instruction Memory File was read into the InstrMem variable. Finally, the clk and rstb variables were initialized to being low and a reset occurred for #100, then the processor began to execute the instructions.   
  
The first instruction in the Instruction Memory was lui $r1, 0xFEDB. This is a load upper immediate instruction, meaning that the 0xFEDB will get loaded into the upper 16 bits of the destination register and the lower 16 bits will be filled in with 0's (0xFEDB0000). The ALUCtl variable of 0x12 signified that a load upper immediate instruction was to be executed within the ALU. The fact that my ALU_out wire variable contained this value proves that this instruction executed properly.   

The second instruction in the Instruction Memory was ori $r1, $r1, 0xA987, meaning that an bitwise OR immediate instruction was to be executed within the ALU. This was signified by an ALUCtl value of 0x10. OR-ing the value of 0xFEDB0000 with 0x0000A987 should result in the value of 0xFEDBA987, which is exactly what my ALU_out variable contained.   
  
The third instruction in the Instruction Memory was lui $r2, $r2, 0x1234. This instruction was just like the first instruction, instead now we are storing the value of 0x12340000 in register 2 instead of register 1. My ALU_out variable had a value of 0x12340000, which was expected.   
  
The fourth instruction was ori $r2, $r2, 0x5678. This instruction was similar to the second instruction, instead now we are Or-ing the value in register 2 with 0x00005678. My ALU_out variable contained a 0x12345678 value, which is as expected.   
  
The fifth instruction was add $r3, $r2, $r1. This instruction adds the value stored in register 2 (0x12345678) with the value stored in register 1 (0x FEDBA987) and stores that value in register 3. The ALUCtl variable for this instruction was 0x01, which indicates that a signed add instruction was going to be taking place. This resulted in a value of 0x110FFFFF, which matches the value that was displayed in my ALU_out variable.   
  
The sixth and final instruction within the Instruction Memory was beq $r0, $r0, 0xFFE8. This instruction is a Branch if Equal instruction. To execute this instruction, we first subtract the two source registers from each other and if they result of that subtraction is zero, then the zero flag is set. Being that we are subtracting register 0 from itself in this instruction, the result will be 0 and hence the zero flag will be set. The next step is finding out the effective address that we are going to be branching to. In order to do this, we sign-extend the offset address provided in the branch instruction (0xFFE8), which results in 0xFFFFFFE8. We then shift this value left by 2 (resulting in 0xFFFFFFA0) and then add that to the value stored in the PC_plus_4 variable (0x00000018). Once this is finished, we then end up with a value of 0xFFFFFFB8, which is the instruction that we end up branching to.   
  
The Program Counter is now at address location 0xFFFFFFB8. Since there is no instruction within the Instruction Memory available at this address, we do not execute any instructions. The Program Counter then starts counting up addresses in increments of 4 and the same is true for these instruction as well: there are no instructions that correspond to these addresses in the Instruction Memory. This goes on until the Program Counter rolls over to the value of 0x00000000 (where the first instruction in the Instruction Memory is located). At this point, the Processor has looped back to the beginning and it executes the same six instructions that it previously executed. In this way, our processor is a self-contained processor that loops back to itself. The processor will continue to infinitely loop back to itself and re-execute the same set of instructions that was provided to it inside of the Instruction Memory.
