module top(
    
    input wire hclk,
    // Pinouts led y pir
    input wire pir_in,
    input wire LDR_in,
    output wire led_out

);

// Control del led y el pir

reg [7:0] counter = 0;


always @(posedge hclk) begin
    
    if (counter < 100) begin
        counter <= counter+1;
    end else begin
        counter <= 0;
    end

end

// 20% duty cycle, apaga si no hay demasiada luz (LDR_in = 0)
assign led_out = (LDR_in) ? ((pir_in) ? 1'b1 : (counter < 20)) : 1'b0;

endmodule