module StartModule (
    input wire clk,
    input wire rst,
    inout reg out_delay,
    output reg confirm_to_reciver //Variable que debe ir al módulo de lectura

);

reg data_aux;
reg[1:0] selector;

assign out_delay = (selector) ? data_aux : 1'bz;

// Parámetros de tiempos
parameter send_star_signal = 18000;
parameter up_to_request = 30;
parameter dht11_response = 160;

// Variables de la máquina de estados
reg[18:0] counter;
reg[3:0] states;

parameter A=0, B=1, C=2, D=3;

// Definición de salidas de la máquina en el bloque secuencial
always @(posedge clk or posedge rst) begin
    if (rst) begin
        states <= A;
        counter <= 0;
        //data_aux <= 1'b0;
        //confirm_to_reciver <= 1'b0;
        //selector <= 1'b1;
    end else begin
        case (states)
            A:begin
                selector <= 1'b1;
                data_aux <= 1'b0;
                confirm_to_reciver <= 1'b0;
                
                if (counter == send_star_signal) begin
                    states <= B; 
                    counter <= 0; 
                end else begin
                    counter <= counter+1;
                end
            end
            B:begin
                selector <= 1'b1;
                data_aux <= 1'b0;
                confirm_to_reciver <= 1'b0;
                
                if (counter == up_to_request) begin
                    states <= C;
                    counter <= 0;
                end else begin
                    counter <= counter+1;
                end
            end
            C:begin
                selector <= 1'b0;
                data_aux <= 1'bz;
                confirm_to_reciver <= 1'b0;
                
                if (counter == dht11_response) begin
                    states <= D;
                    counter <= 0;
                end else begin
                    counter <= counter+1;
                end
            end
            D:begin
                selector <= 1'b0;
                data_aux <= 1'bz;
                confirm_to_reciver <= 1'b1;

                /*
                if (counter == dht11_response) begin
                    counter <= 0;
                end else begin
                    counter <= counter+1;
                end*/
            end
            default: begin
                states <= D;
                counter <= 0;
                //data_aux <= 1'b1;
                //confirm_to_reciver <= 1'b0;
                //selector <= 1'b0;
            end  
        endcase
    end
end

endmodule
