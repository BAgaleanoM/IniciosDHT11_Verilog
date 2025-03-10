`include "./freqDiv.v"
`include "./StartModule.v"
`include "./DataReciverModule.v"
module top (
    input wire hwclk,
    //input wire rst,
    inout reg dht11_data
);
wire rst; 
assign rst = 0;
wire clk;

// Salidas de StartModule
reg out_data;
wire confirm_to_reciver;


//Divisor de frecuencia
freqDiv #(
`ifdef SIM  // Macros de presíntesis
      .FREQ_IN (10),    // 10 Tikcs
      .FREQ_OUT(1)      // 1 Tikcs
`else
      .FREQ_IN (25e6),  // 25 MHz
      .FREQ_OUT(1e6)    // 1 MHz
`endif
  ) frequencyDivider (
      .CLK_IN (hwclk),
      .CLK_OUT(clk)
);

StartModule startModule(
      .clk(clk),
      .rst(rst),
      .out_delay(dht11_data),
      .confirm_to_reciver(confirm_to_reciver)
);
/*
DataReciverModule dataReciverModule(
      .clk(clk),
      .rst(rst),
      .confirm_to_reciver(confirm_to_reciver),
      .dht11_data(dht11_data),
);
*/
endmodule