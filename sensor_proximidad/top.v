`include "./freqDiv.v"

module top(
    input wire hwclk,
    input wire pir_in,
    output wire led_out
);


//reg [7:0] duty_cycle = 8'd20; 
reg [7:0] counter = 0;
// reg duty_cycle_20 = 
// reg duty_cycle_100 = 

always @(posedge hwclk) begin
    
    if (counter < 100) begin
        counter <= counter+1;
    end else begin
        counter <= 0;
    end

end

// 20% duty cycle
assign led_out = pir_in ? 1 : (counter < 20);


endmodule
