/*Test bench ejemplo del half adder en "test"*/
`timescale 1ns/1ps

`include "test.v"

module test_tb;
    // Declarar señales para conectar al DUT
    reg a, b;        // Entradas
    wire y;          // Salida

    // Instanciar el DUT
    and_gate uut (
        .a(a),
        .b(b),
        .y(y)
    );

    // Bloque para generar estímulos
    initial begin
        $dumpfile("test_tb.vcd"); // Crear archivo VCD
        $dumpvars(0, test_tb); // Volcar variables
        // Monitorizar señales
        $monitor("Time: %0d | a: %b | b: %b | y: %b", $time, a, b, y);

        // Generar combinaciones de prueba
        a = 0; b = 0; #10;  // Tiempo 10 ns
        a = 0; b = 1; #10; 
        a = 1; b = 0; #10;
        a = 1; b = 1; #10;

        $finish; // Terminar simulación
    end
endmodule


// Comandos de simulación

// cd .\Inicios_verilog   <-  esto es poner el directorio en el que se encuentran los archivos
// iverilog -o test_tb.vvp test_tb.v
// vvp test_tb.vvp
// gtkwave test_tb.vcd
