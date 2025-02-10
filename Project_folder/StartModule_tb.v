`timescale 1ns/1ps
`include "StartModule.v"
module StartModule_tb;
    reg clk;
    reg rst;
    wire out_delay;
    wire confirm_to_reciver;
    
    // Instanciar el módulo a probar
    StartModule uut (
        .clk(clk),
        .rst(rst),
        .out_delay(out_delay),
        .confirm_to_reciver(confirm_to_reciver)
    );
    
    // Generación de reloj
    always #5 clk = ~clk; // Periodo de 10ns
    
    initial begin
        // Inicialización de señales
        clk = 0;
        rst = 1;
        #20;
        
        // Liberar reset
        rst = 0;
        
        // Monitoreo de señales
        $monitor("Time: %0t | State: %b | out_delay: %b | confirm_to_reciver: %b", $time, uut.states, out_delay, confirm_to_reciver);
        
        // Simulación por un tiempo suficiente para verificar las transiciones de estado
        #500000;
        
        $finish;
    end
endmodule
