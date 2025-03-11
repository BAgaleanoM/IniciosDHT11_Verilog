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