`include "./freqDiv.v"
`include "./bin2bcd.v"
`include "./LCD.v"

module top(
    
    input wire hclk,
    // Pinouts led y pir
    input wire pir_in,
    output wire led_out,

    //pinouts de la pantalla
    output RS, RW, E,
    output D0, D1, D2, D3, D4, D5, D6, D7
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

// 20% duty cycle
assign led_out = pir_in ? 1 : (counter < 20);


//Top de la LCD
reg [7:0] humedad;
    reg [7:0] temperatura;


    wire clk_count;
    wire [7:0] dat;
    wire [3:0] hum_hundreds, hum_tens, hum_units;
    wire [3:0] temp_hundreds, temp_tens, temp_units;



    freqDiv clk1 (
        .CLK_IN(hclk),
        .CLK_OUT(clk_count)
    );

 bin2bcd hum_bcd (
        .bin(humedad),
        .hundreds(hum_hundreds),
        .tens(hum_tens),
        .units(hum_units)
    );

 bin2bcd temp_bcd (
        .bin(temperatura),
        .hundreds(temp_hundreds),
        .tens(temp_tens),
        .units(temp_units)
    );


    LCD lcd_inst (
        .hum_hundreds(hum_hundreds),
        .hum_tens(hum_tens),
        .hum_units(hum_units),
        .temp_hundreds(temp_hundreds),
        .temp_tens(temp_tens),
        .temp_units(temp_units),
        .clk(clk_count),
        .rs(RS),
        .en(E),
        .rw(RW),
        .dat(dat)
    );


    assign D0 = dat[0];
    assign D1 = dat[1];
    assign D2 = dat[2];
    assign D3 = dat[3];
    assign D4 = dat[4];
    assign D5 = dat[5];
    assign D6 = dat[6];
    assign D7 = dat[7];


endmodule





