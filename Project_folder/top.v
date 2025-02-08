module moduleName (
    ports
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
      .CLK_IN (clk),
      .CLK_OUT(dht11_data)
)



endmodule