// Test Bench 

`timescale 1us/1ps

module logic_op_tb()

  reg A, B, C, D; 
  wire out_1, out_2, out_3;
  
  _case uut(A, B, C, D,out_1, out_2, out_3);

//Acá se generan los estímulos

initial begin
  A = 1'b1;
  B = 1'b0;
  C = 1'b1;
  D = 1'b1;
  #10;
  A = 1'b0;
  B = 1'b0;
  C = 1'b1;
  D = 1'b0;
end

endmodule
