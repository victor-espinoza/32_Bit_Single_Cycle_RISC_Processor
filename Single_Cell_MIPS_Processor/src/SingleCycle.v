`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Author:        Victor Espinoza
// Email:         victor.alfonso94@gmail.com
// Project #:     Project 3 - Single Cycle MIPS Processor
// Course:        CECS 440
// Create Date:   11:02:28 03/10/2015
//
// Module Name:   SingleCycle
// File Name:     SingleCycle.v 
// Description:   This top level module combines our previous labs of the register
//                file and the ALU and implements them into a single cycle MIPS
//                processor. This means that one instruction is executed every
//                clock cycle. In order to accommodate being able to execute all 
//                of the instructions that we implemented in one clock cycle, I
//                needed to stretch out the clock according to the instruction
//                that took the longest amount of time to execute. The critical
//                path for this processor (the instruction with the longest
//                delay) was the load instruction, so this instruction is what 
//                determined the clock period. At the beginning of each clock
//                cycle, the Program Counter receives the appropriate address
//                and then it fetches the instruction corresponding to that
//                particular address. Each address in the Program Counter is
//                byte addressable (word-aligned), meaning that it goes up in 
//                increments of 4 (0x00, 0x04, 0x08, 0x0C, 0x10, etc...). In 
//                order to align and interface the Program Counter address with 
//                the physical addresses of the Instruction and Data Memory, I 
//                needed to shift the address right by 2. This allows us to get
//                the physical address of the word-addressable memories. Depending
//                on the type of instruction being executed, the processor then
//                takes the different paths associated with each type of 
//                instruction. There are three different types of instructions
//                being implemented by our processor: register type instructions,
//                Load/Store type instructions, and Branch type instructions. 
//                Each instruction takes a slightly different path through the 
//                processor.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module SingleCycle(clk, rstb);

//Establish Inputs
input clk, rstb;

//Local wire variables
wire [31:0] PC_PLUS_4; 
wire [31:0] next_PC;
wire [31:0] add_PC_addr;
wire [31:0] rd_data1;
wire [31:0] rd_data2;
wire [31:0] Immed_Value_Extended;
wire [31:0] rd_data2_muxed;
wire [31:0] wr_data_muxed;
wire [31:0] ALU_out;
wire [4:0]  ALUCtl; 
wire [4:0]  wr_addr_muxed;
wire        ZF; 
wire        RegDst;
wire        BranchE;
wire        BranchNE;
wire        MemRead;
wire        MemtoReg;
wire        MemWrite;
wire        ALUSrc;
wire        RegWrite;
wire        branch_mux_sel;


//Local reg variables
reg  [31:0] PC;
reg  [31:0] Instr;
reg  [31:0] data_mem_out;
reg  [31:0] InstrMem [0:1023];
reg  [31:0] DataMem  [0:1023];


//////////////////////////////////////////////////////////////////////////////////
//Start Program Counter Section of Processor

always @(posedge clk, negedge rstb)
   if (!rstb)
      PC <= 32'b0;
   else
      PC <= next_PC;
//Finished with Program Counter Section of Processor                        
//////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////
//Start Instruction Memory Section of Processor

always@(*)
   Instr = InstrMem[PC>>2];
//Finished Instruction Memory Section of Processor                        
//////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////
//Start Controller Section of Processor

//Controller Module Instantiation
//module Controller (InstHi, InstLo, RegDst, BranchE, BranchNE, MemRead, MemtoReg,
// MemWrite, ALUSrc, RegWrite, ALUCtl);
Controller Control(
   .InstHi(Instr[31:26]), 
   .InstLo(Instr[5:0]), 
   .RegDst(RegDst), 
   .BranchE(BranchE), 
   .BranchNE(BranchNE), 
   .MemRead(MemRead), 
   .MemtoReg(MemtoReg),
   .MemWrite(MemWrite), 
   .ALUSrc(ALUSrc), 
   .RegWrite(RegWrite), 
   .ALUCtl(ALUCtl)
);
//Finished with Controller Section of Processor                        
//////////////////////////////////////////////////////////////////////////////////
                   
                                      
//////////////////////////////////////////////////////////////////////////////////
//Start Register File Section of Processor                

//write register address mux           1              0
assign wr_addr_muxed = (RegDst) ? Instr[15:11] : Instr[20:16];

//Register File Module Instantiation
//module register_file(clk, rstb, wr_e, wr_addr, wr_data, rd_addr1, rd_addr2, 
// rd_data1,rd_data2);
register_file Registers(
   .clk(clk), 
   .rstb(rstb), 
   .wr_e(RegWrite), 
   .wr_addr(wr_addr_muxed), 
   .wr_data(wr_data_muxed), 
   .rd_addr1(Instr[25:21]), 
   .rd_addr2(Instr[20:16]), 
   .rd_data1(rd_data1),
   .rd_data2(rd_data2)
);
//Finished with Register File Section of Processor                        
//////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////
//Start ALU Section of Processor

//Sign Extend Immediate Value
assign Immed_Value_Extended = {{16{Instr[15]}}, Instr[15:0]}; //Sign-extended  
                                                              //Immediate value

//ALU data2 select mux                     1                 0
assign rd_data2_muxed = (ALUSrc) ? Immed_Value_Extended : rd_data2;

//ALU Module Instantiation
//module ALU(sel, A, B, ZF, Y);
ALU ALU_UNIT(
   .sel(ALUCtl), 
   .A(rd_data1), 
   .B(rd_data2_muxed),
   .ZF(ZF), 
   .Y(ALU_out)
);
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

//next PC select mux                     1            0 
assign next_PC = (branch_mux_sel) ? add_PC_addr : PC_PLUS_4;
//Finished PC Select Section of Processor 
//////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////
//Start Data Memory Section of Processor

//read data from data memory if MemRead is asserted
always @(*)
   data_mem_out = (MemRead) ? DataMem[ALU_out>>2]:32'b0;

//write to data memory if MemWrite is asserted
always @(posedge clk, negedge rstb)
      if (MemWrite)
         DataMem[ALU_out>>2] <= rd_data2;

//Data Memory write data select mux       1           0
assign wr_data_muxed = (MemtoReg) ? data_mem_out : ALU_out;
//Finished with Data Memory Section of Processor 
//////////////////////////////////////////////////////////////////////////////////


endmodule
