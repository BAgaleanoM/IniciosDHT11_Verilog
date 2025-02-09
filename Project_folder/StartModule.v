
module StartModule (
    input wire clk,
    input wire rst,
    output reg out_delay,
);

//Ciclos de envío de datos y recepctión de datos
parameter send_star_signal = 18000; //Para poner Pin en low por 18ms
parameter up_to_request = 30; //Para poner Pin en alto por 30us
parameter dht11_response = 80; // Tiempos en high y low de respuesta del DHT11

reg[18:0] counter;
reg[2:0] states;

parameter A=0, B=1, C=2, D=3;

initial begin
    states <= A;
    out_delay = 1'b0;
end

//Definición de salidas de la máquina
always @(states) begin

    case (states)
        A: out_delay = 1'b0;
        B: out_delay = 1'b1;
        C: out_delay = 1'b0;
        D: out_delay = 1'b1;

        default: 
    endcase


end



endmodule