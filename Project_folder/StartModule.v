
module StartModule (
    input wire clk,
    input wire rst,
    output reg out_delay,
    output reg  confirm_to_reciver
);

//Ciclos de envío de datos y recepctión de datos
parameter send_star_signal = 18000; //Para poner Pin en low por 18ms
parameter up_to_request = 30; //Para poner Pin en alto por 30us
parameter dht11_response = 80; // Tiempos en high y low de respuesta del DHT11

reg[18:0] counter;
reg[2:0] states;

parameter A=0, B=1, C=2, D=3;

//Definición de salidas de la máquina
always @(states) begin

    case (states)
        A: out_delay = 1'b0, confirm_to_reciver = 1'b1;
        B: out_delay = 1'b1, confirm_to_reciver = 1'b1;
        C: out_delay = 1'b0, confirm_to_reciver = 1'b1;
        D: out_delay = 1'b1, confirm_to_reciver = 1'b1;
        default: out_delay = 1'b0;
    endcase

end

initial begin
    states <= A;
    out_delay = 1'b0;
end

always @(posedge clk or posedge rst) begin
    if (rst)
        states <= A;
        counter <= 0;
    else begin
        
        case (states)
            A:begin
                if (counter == send_star_signal) begin
                    states <= B; // Para pasar al otro estado de la salida
                    counter = 0; //Para reiniciar el contador a 0
                end else begin
                    states <= A;
                    counter <= counter+1;
                end
           end
            B:begin
                if (counter == up_to_request) begin
                    states <= C;
                    counter <= 0;
                end else begin
                    states <= B;
                    counter <= counter+1;
                end
            end
            C:begin
                if (counter == dht11_response) begin
                    states <= D;
                    counter <= 0;
                end else begin
                    states <= C;
                    counter <= counter+1;
                end
            end
            D:begin
                if (counter == dht11_response) begin
                    states <= A;
                    counter <= 0;
                end else begin
                    
                    counter <= counter+1;
                end
            end
            default: counter <= 0; 
        endcase
    end
end
endmodule