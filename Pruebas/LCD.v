module LCD(
    input clk,
    input [3:0] hum_hundreds, 
    input [3:0] hum_tens, 
    input [3:0] hum_units,
    input [3:0] temp_hundreds, 
    input [3:0] temp_tens, 
    input [3:0] temp_units,
    input wire micro,  // Entrada de control
    output rs, en, rw,
    output reg [7:0] dat
    );

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

    reg [7:0] hum_hundreds_ASCII, hum_tens_ASCII, hum_units_ASCII;
    reg [7:0] tem_hundreds_ASCII, tem_tens_ASCII, tem_units_ASCII;

    always @(posedge clkR) begin
        // Convertir los valores binarios a ASCII
        hum_hundreds_ASCII = bin_to_ascii(hum_hundreds);
        hum_tens_ASCII = bin_to_ascii(hum_tens);
        hum_units_ASCII = bin_to_ascii(hum_units);
        tem_hundreds_ASCII = bin_to_ascii(temp_hundreds);
        tem_tens_ASCII = bin_to_ascii(temp_tens);
        tem_units_ASCII = bin_to_ascii(temp_units);
        
        current = next;
        case (current)    
            0:  begin rs <= 0; dat <= 8'h38; next <= 1; end // Config 8bit
            1:  begin rs <= 0; dat <= 8'h38; next <= 2; end 
            2:  begin rs <= 0; dat <= 8'h0E; next <= 3; end 
            3:  begin rs <= 0; dat <= 8'h01; next <= 4; end 
            
            // Si micro == 1, mostrar "Demasiado Ruido"
            4: begin
                if (micro) next <= 5;
                else next <= 16;
            end
            
            5:  begin rs <= 0; dat <= 8'h80; next <= 6; end
            6:  begin rs <= 1; dat <= 8'h44; next <= 7; end // D
            7:  begin rs <= 1; dat <= 8'h65; next <= 8; end // e
            8:  begin rs <= 1; dat <= 8'h6D; next <= 9; end // m
            9:  begin rs <= 1; dat <= 8'h61; next <= 10; end // a
            10: begin rs <= 1; dat <= 8'h73; next <= 11; end // s
            11: begin rs <= 1; dat <= 8'h69; next <= 12; end // i
            12: begin rs <= 1; dat <= 8'h61; next <= 13; end // a
            13: begin rs <= 1; dat <= 8'h64; next <= 14; end // d
            14: begin rs <= 1; dat <= 8'h6F; next <= 15; end // o
            15: begin rs <= 1; dat <= 8'h20; next <= 16; end // Espacio

            16: begin rs <= 0; dat <= 8'hC0; next <= 17; end
            17: begin
                if (micro) next <= 18;
                else next <= 23;
            end

            18: begin rs <= 1; dat <= 8'h52; next <= 19; end // R
            19: begin rs <= 1; dat <= 8'h75; next <= 20; end // u
            20: begin rs <= 1; dat <= 8'h69; next <= 21; end // i
            21: begin rs <= 1; dat <= 8'h64; next <= 22; end // d
            22: begin rs <= 1; dat <= 8'h6F; next <= 23; end // o

            default: next = 0;
        endcase
    end

    assign en = clkR;
    assign rw = 0;
endmodule
