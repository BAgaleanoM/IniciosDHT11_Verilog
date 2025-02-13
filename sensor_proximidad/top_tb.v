`timescale 1ns / 1ps
`include "./top.v"
module top_tb;

    // Inputs
    reg hwclk;
    reg pir_in;

    // Outputs
    wire led_out;

    // Instantiate the Unit Under Test (UUT)
    top uut (
        .hwclk(hwclk), 
        .pir_in(pir_in), 
        .led_out(led_out)
    );

    // Clock generation
    initial begin
        hwclk = 0;
        forever #10 hwclk = ~hwclk; // Toggle clock every 10 time units
    end

    // Test sequence
    initial begin
        // Initialize inputs
        pir_in = 0;

        // Wait for the global reset
        #100;

        // Test case 1: pir_in is low
        pir_in = 0;
        #100; // Wait for 100 time units

        // Test case 2: pir_in is high
        pir_in = 1;
        #100; // Wait for 100 time units

        // Test case 3: pir_in toggles
        pir_in = 0;
        #50;
        pir_in = 1;
        #50;
        pir_in = 0;
        #50;
        pir_in = 1;
        #50;

        // End simulation
        $stop;
    end

endmodule