`include "./freqDiv.v"

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



    divFreq clk1 (
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


//Módulos de la LCD
module bin2bcd (
    input [7:0] bin,  // Entrada binaria de 8 bits
    output reg [3:0] hundreds,  // Centenas
    output reg [3:0] tens,      // Decenas
    output reg [3:0] units      // Unidades
);

    integer i;
    reg [11:0] bcd;  // 12 bits para almacenar el resultado BCD (3 dígitos)

    always @(*) begin  
        bcd = 0;  // Inicializar el registro BCD
        for (i = 0; i < 8; i = i + 1) begin
            // Desplazar y ajustar los dígitos BCD
            if (bcd[3:0] >= 5) bcd[3:0] = bcd[3:0] + 3;
            if (bcd[7:4] >= 5) bcd[7:4] = bcd[7:4] + 3;
            if (bcd[11:8] >= 5) bcd[11:8] = bcd[11:8] + 3;
            bcd = {bcd[10:0], bin[7-i]};  // Desplazar el bit siguiente
        end
        // Separar los dígitos
        hundreds = bcd[11:8];
        tens = bcd[7:4];
        units = bcd[3:0];
    end

endmodule

module LCD(
    input clk,
    input [3:0] hum_hundreds, 
    input [3:0] hum_tens, 
    input [3:0] hum_units,
    input [3:0] temp_hundreds, 
    input [3:0] temp_tens, 
    input [3:0] temp_units,
    output rs, en, rw,
    output reg [7:0] dat
    );

    //reg [7:0] dat;
    reg rs;
    reg [15:0] counter;
    reg [5:0] current, next;
    reg clkR;

    initial begin
        dat = 0;
        rs = 0;
        counter = 0;
        current = 0;
        next = 0;
        clkR = 0;
    end

    always @(posedge clk) begin
        counter = counter + 1;
        if (counter == 16'h0FFF) clkR = ~clkR;
    end

// Función para convertir binario a ASCII
    function [7:0] bin_to_ascii;
        input [3:0] bin;
        begin
            if (bin <= 4'b1001) // 0-9
                bin_to_ascii = 8'h30 + bin;
            else // A-F
                bin_to_ascii = 8'h41 + (bin - 4'b1010);
        end
    endfunction


reg [7:0] hum_hundreds_ASCII, hum_tens_ASCII, hum_units_ASCII, tem_hundreds_ASCII, tem_tens_ASCII, tem_units_ASCII;



    always @(posedge clkR) begin
        // Convertir los valores binarios a ASCII
        hum_hundreds_ASCII = bin_to_ascii({3'b000, hum_hundreds});
        hum_tens_ASCII = bin_to_ascii({3'b000, hum_tens});
        hum_units_ASCII = bin_to_ascii({3'b000, hum_units});
        tem_hundreds_ASCII = bin_to_ascii({3'b000, tem_hundreds});
        tem_tens_ASCII = bin_to_ascii({3'b000, tem_tens});
        tem_units_ASCII = bin_to_ascii({3'b000, temp_units});
        
        current = next;
        case (current)
            0:  begin rs <= 0; dat <= 8'h38; next <= 1; end // Config 8bit
            1:  begin rs <= 0; dat <= 8'h38; next <= 2; end 
            2:  begin rs <= 0; dat <= 8'h0E; next <= 4; end 
            3:  begin rs <= 0; dat <= 8'h01; next <= 4; end 
            
            // Fila 1: Humedad
            4:  begin rs <= 0; dat <= 8'h80; next <= 5; end
            5:  begin rs <= 1; dat <= 8'h48; next <= 6; end // H
            6:  begin rs <= 1; dat <= 8'h75; next <= 7; end // u
            7:  begin rs <= 1; dat <= 8'h6D; next <= 8; end // m
            8:  begin rs <= 1; dat <= 8'h65; next <= 9; end // e
            9:  begin rs <= 1; dat <= 8'h64; next <= 10; end // d
            10: begin rs <= 1; dat <= 8'h61; next <= 11; end // a
            11: begin rs <= 1; dat <= 8'h64; next <= 12; end // d
            12: begin rs <= 1; dat <= 8'h3A; next <= 13; end // :
            13: begin rs <= 1; dat <= hum_hundreds_ASCII; next <= 14; end // Centenas
            14: begin rs <= 1; dat <= hum_tens_ASCII; next <= 15; end // Decenas
            15: begin rs <= 1; dat <= hum_units_ASCII; next <= 16; end // Unidades
            16: begin rs <= 1; dat <= 8'h25; next <= 17; end // %
            17: begin rs <= 1; dat <= 8'h20; next <= 18; end // Espacio
            
            // Fila 2: Temperatura
            18: begin rs <= 0; dat <= 8'hC0; next <= 19; end
            19: begin rs <= 1; dat <= 8'h54; next <= 20; end // T
            20: begin rs <= 1; dat <= 8'h65; next <= 21; end // e
            21: begin rs <= 1; dat <= 8'h6D; next <= 22; end // m
            22: begin rs <= 1; dat <= 8'h70; next <= 23; end // p
            23: begin rs <= 1; dat <= 8'h3A; next <= 24; end // :
            24: begin rs <= 1; dat <= tem_hundreds_ASCII; next <= 25; end // Centenas
            25: begin rs <= 1; dat <= tem_tens_ASCII; next <= 26; end // Decenas
            26: begin rs <= 1; dat <= tem_units_ASCII; next <= 27; end // Unidades
            27: begin rs <= 1; dat <= 8'hDF; next <= 28; end // °
            28: begin rs <= 1; dat <= 8'h43; next <= 29; end // C
            29: begin rs <= 1; dat <= 8'h20; next <= 30; end // Espacio
            default: next = 0;
        endcase
    end

    assign en = clkR;
    assign rw = 0;
endmodule

module divFreq #(
  parameter integer FREQ_IN = 25000000,
  parameter integer FREQ_OUT = 8000000,
  parameter integer INIT = 0
) (
    input CLK_IN,
    output reg CLK_OUT = 0
);

  localparam integer COUNT = (FREQ_IN / FREQ_OUT) / 2;
  localparam integer SIZE = $clog2(COUNT);
  localparam integer LIMIT = COUNT - 1;

  reg [SIZE-1:0] count = INIT;

  always @(posedge CLK_IN) begin
    if (count == LIMIT) begin
      count   <= 0;
      CLK_OUT <= ~CLK_OUT;
    end else begin
      count <= count + 1;
    end
  end
endmodule