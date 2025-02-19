
module StartModule (
    input wire clk,
    input wire rst,
    inout wire out_delay,
    output reg  confirm_to_reciver //Variable que debe ir al módulo de lectura
);

reg data_aux;
reg[1:0] selector;

assign out_delay = (selector) ? data_aux : 1'bz;

//Ciclos de envío de datos y recepctión de datos
parameter send_star_signal = 18000; //Para poner Pin en low por 18ms
parameter up_to_request = 30; //Para poner Pin en alto por 30us
parameter dht11_response = 160; // Tiempos en high y low de respuesta del DHT11

//Variables de la máquina de estados
reg[18:0] counter;
reg[3:0] states;

parameter A=0, B=1, C=2, D=3;

//Definición de salidas de la máquina
always @(states) begin

    case (states)
        A:begin
            selector = 1'b1;
            data_aux = 1'b0;
            confirm_to_reciver = 1'b0;
        end
        B: begin 
            selector = 1'b1;
            data_aux = 1'b1; 
            confirm_to_reciver = 1'b0;
        end 
        C: begin
            selector = 1'b0;
            data_aux = 1'b0;
            confirm_to_reciver = 1'b0;
        end
        D: begin
            selector = 1'b0;
            data_aux = 1'b0;
            confirm_to_reciver = 1'b1;
        end
        default:begin
            selector = 1'b1;
            data_aux = 1'b1;
            confirm_to_reciver = 1'b0;
        end 
    endcase

end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        states <= A;
        counter <= 0;
        data_aux <= 1'b0;
        confirm_to_reciver <= 1'b0;
    end else begin
        
        case (states)
            A:begin
                if (counter == send_star_signal) begin
                    states <= B; // Para pasar al otro estado de la salida
                    counter <= 0; //Para reiniciar el contador a 0
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
                    counter <= 0;
                end else begin
                    states <= D;
                    counter <= counter+1;
                end
            end
            default: begin
                states <= A;
                counter <= 0;
            end  
        endcase
    end
end
endmodule