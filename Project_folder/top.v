`include "./freqDiv.v"
module moduleName (
    input wire hwclk,
    input wire rst, //Al inicio debe ponerse como wire rst; assign rst = 0, fuera de estas entradas 
);


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
)



endmodule