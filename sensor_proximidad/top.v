`include "./freqDiv.v"

module top(
    input wire hwclk,
    input wire pir_in,
    //output reg motion_detected,
    output reg led_out
);

  freqDiv #(
`ifdef SIM  // Macros de presíntesis
      .FREQ_IN (10),    // 10 Tikcs
      .FREQ_OUT(1)      // 1 Tikcs
`else
      .FREQ_IN (25e6),  // 25 MHz
      .FREQ_OUT(10)    // 1 Hz
`endif
  ) frequencyDivider (
      .CLK_IN (hwclk),
      .CLK_OUT(clk)
);

    always @(posedge clk) begin
        led_out <= pir_in;
/*

        if (pir_in <= 1'b1) begin
                led_out <= pir_in;
        end else begin
                led_out <= pir_in; 
            end      
    */
    end

endmodule
