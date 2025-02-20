module DataReciverModule (
    input wire clk,
    input wire rst,
    input reg confirm_to_reciver,
    inout reg dht11_data
);
reg[15:0] temp_data;
reg[15:0] hum_data;
reg[39:0] data; //Variable que almacena la cadena de bits, luego de las señales de checkeo


reg data_aux;
reg[1:0] selector;

assign out_delay = (selector) ? data_aux : 1'bz;

endmodule
