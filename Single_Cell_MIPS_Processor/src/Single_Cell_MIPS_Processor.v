`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:02:28 03/10/2015 
// Design Name: 
// Module Name:    Single_Cell_MIPS_Processor 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Single_Cell_MIPS_Processor(clk, rstb);

//Establish Inputs
input clk, rstb;

//Local variables
wire [31:0] PC, PC_PLUS_4, next_PC, Instr, ALU_Out, rd_data1, rd_data2, 
rd_data2_Muxed, wr_data_muxed, Immed_Value_Extended, ALU_out, data_mem_out,
add_PC_addr;
wire ZF, RegDst, BranchE, BranchNE, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite,
branch_mux_sel;
wire [4:0] ALUCtl, wr_addr_muxed;

//////////////////////////////////////////////////////////////////////////////////
//Start Program Counter Section of Processor

//Program Counter Module Instantiation
//module PC(clk, rstb, din, dout);
PC Program_Couter(clk, rstb, next_PC, PC);
//Finished with Program Counter Section of Processor								
//////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////
//Start Instruction Memory Section of Processor

//Instruction Memory Module Instantiation
//module InstrMem(PC_addr, Instr);
InstrMem Instruction_Memory(PC, Instr);
//Finished Instruction Memory Section of Processor								
//////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////
//Start Controller Section of Processor

//Controller Module Instantiation
//module Controller (InstHi, InstLo, RegDst, BranchE, BranchNE, MemRead, MemtoReg,
// MemWrite, ALUSrc, RegWrite, ALUCtl);
Controller Control(Instr[31:26], Instr[5:0],RegDst, BranchE, BranchNE, MemRead, 
						 MemtoReg, MemWrite, ALUSrc, RegWrite, ALUCtl);
//Finished with Controller Section of Processor								
//////////////////////////////////////////////////////////////////////////////////						 
						 
						 						 
//////////////////////////////////////////////////////////////////////////////////
//Start Register File Section of Processor					 

//write register address mux 
assign wr_addr_muxed = (RegDst) ? Instr[20:16] : Instr[15:11];

//Register File Module Instantiation
//module register_file(clk, rstb, wr_e, wr_addr, wr_data, rd_addr1, rd_addr2, 
// rd_data1,rd_data2);
register_file Registers(clk, rstb, RegWrite, wr_addr_muxed, wr_data_muxed, 
								Instr[25:21], Instr[20:16], rd_data1, rd_data2);
//Finished with Register File Section of Processor								
//////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////
//Start ALU Section of Processor

//Sign Extend Immediate Value
assign Immed_Value_Extended = {{16{Instr[15]}}, Instr[15:0]}; //Sign-extended  
																		        //Immediate value

//ALU data2 select mux
assign rd_data2_muxed = (ALUSrc) ? rd_data2 : Immed_Value_Extended;															  

//ALU Module Instantiation
//module ALU(sel, A, B, ZF, Y);
ALU ALU_UNIT (ALUCtl, rd_data1, rd_data2_muxed, ZF, ALU_out);
//Finished with ALU Section of Processor 
//////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////
//Start PC Select Section of Processor

//assign PC+4 wire
assign PC_PLUS_4 = PC + 4;

//assign add_PC_addr wire
assign add_PC_addr = PC_PLUS_4 + (Immed_Value_Extended<<2);

//assign the branch_mux_sel wire
assign branch_mux_sel = (BranchE & ZF) | (BranchNE & ~ZF);

//next PC select mux 
assign next_PC = (branch_mux_sel) ? PC_PLUS_4 : add_PC_addr;
//Finished PC Select Section of Processor 
//////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////
//Start Data Memory Section of Processor

//Data Memory Module Instantiation
//module Data_Mem(clk, wr_en, rd_en, addr, wr_data, dout);
Data_Mem Data_Memory(clk, MemWrite, MemRead, ALU_out, rd_data2, data_mem_out);

//Data Memory write data select mux
assign wr_data_muxed = (MemtoReg) ? data_mem_out : ALU_out;
//Finished with Data Memory Section of Processor 
//////////////////////////////////////////////////////////////////////////////////


endmodule
