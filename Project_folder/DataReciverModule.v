module DataReciverModule (
    input wire clk,
    input wire rst,
    input wire confirm_to_reciver,
    inout reg dht11_data
);
reg[15:0] temp_data;
reg[15:0] hum_data;
reg[39:0] data; //Variable que almacena la cadena de bits, luego de las señales de checkeo


//Tiempos de bit para codificación
parameter down_signal = 50;
parameter up_to_one = 27; //Tiempo en up para "0"
parameter  up_to_zero= 70; //Tiempo en up para "1"


reg data_aux;
reg[1:0] selector; 
reg[18:0] counter;


assign dht11_data = (selector) ? data_aux :  1'bz; 

reg[3:0] states;
parameter idle = 2'b01,
          read_one = 2'b10,
          read_zero = 2'b11;


always @(confirm_to_reciver) begin
    if (rst) begin
        selector <= 1'b0;
        states <= idle; 
    end else begin
        case (states)
            idle : begin
                if (counter == read_one) begin
                    
                end
            end 
            default: 
        endcase
    end

end



endmodule
