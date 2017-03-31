`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:07:19 03/07/2015
// Design Name:   SingleCycle
// Module Name:   C:/Users/John Tramel/Desktop/SingleCycle/SingleCycle/
// SingleCycle_tb.v
// Project Name:  SingleCycle
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: SingleCycle
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module SingleCycle_tb;

   // Inputs
   reg clk;
   reg rstb;
   
   //Local variables
   integer i;

   // Instantiate the Unit Under Test (UUT)
   SingleCycle uut (
      .clk(clk), 
      .rstb(rstb)
   );
   
   initial begin
      for(i=0; i<1024; i=i+1)
         uut.DataMem[i] <= 32'b0;
   end 
   
   always #10 clk = ~clk;
   
   initial $readmemh("memfileh",uut.InstrMem); 
   
   initial begin
      // Initialize Inputs
      clk  = 0;
      rstb = 0;

      // Wait 100 ns for global reset to finish
      #100 rstb = 1;
        
      // Add stimulus here

   end
      
endmodule

