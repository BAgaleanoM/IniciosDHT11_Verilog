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