module top #(parameter WAIT_READ=25000000,         //25MHz (?) o ciclos de reloj
                                    INIT_PULSE_DOWN=2250000,    //Inicio del impulso "0"
                                    INIT_PULSE_UP=3750,         //Inicio impulso "1"
                                    WAIT_RESPONSE_INIT=20000,   //Tiempo de espera de respuesta del sensor 
                                    WAIT_50u = 6250,            //Espera de 50u pero porque 6.25kHz
                                    ZERO_26u=3000,              
                                    ONE_70u=8750)(
    input wire clk,               
    input wire rst,               
    inout wire dht11_io         

);
    reg [15:0] humidity;    
    reg [15:0] temperature; 
    reg valid;
    reg [2:0] state;

    reg [2:0] fsm_state;                                    //registro del estado maquina de estado
    reg [2:0] next_state;                                   //regsitro siguiente estado
    reg [39:0] shift_reg;                                   //bus de datos de 40bits
    reg [5:0] bit_count;                                    //contador de bits
    reg [$clog2(WAIT_READ)-1:0] timer_init;                 //en este pasa el tiempo de espera a cantidad de bits 
    reg [$clog2(INIT_PULSE_UP)-1:0] timer_start_up;
    reg [$clog2(INIT_PULSE_DOWN)-1:0] timer_start_down; 
    reg [$clog2(WAIT_RESPONSE_INIT)-1:0] timer_response; 
    reg [$clog2(WAIT_50u)-1:0] timer_wait_data; 
    reg [$clog2(ONE_70u)-1:0] timer_bits;
    reg bit_done;                       

    reg dht11_out;
    wire dht11_dir;
    
    
    reg [2:0] count_clk50; // Contador de 2 bits
    reg clk_50M;

    always @(posedge clk) begin
        if (rst) begin
            count_clk50 <= 0;
            clk_50M <= 0;
        end else begin
            if (count_clk50 == 2) begin  // Alternar entre 2 y 3 ciclos
                count_clk50 <= 0;
                clk_50M <= ~clk_50M; // Cambia cada 2.5 ciclos en promedio
            end else begin
                count_clk50 <= count_clk50 + 1;
            end
        end
    end
      

    assign dht11_io = dht11_dir ? dht11_out : 1'bz;     //alterna el como actua dht11_io por alta impedancia

    localparam IDLE          = 3'b000;          //define los S0 al S6 de los estados de la maquina
    localparam START_DOWN    = 3'b001;
    localparam START_UP      = 3'b010;
    localparam WAIT_RESPONSE = 3'b011;
    localparam WAIT_DATA     = 3'b100;
    localparam RECEIVE_BITS  = 3'b101;
    localparam CHECKSUM      = 3'b110;

    initial begin
        dht11_out <= 1'b1;              //estados iniciales
        humidity <= 'b0;
        temperature <= 'b0;
        valid <= 1'b0;
        timer_init <= 'b0;
        timer_start_up <= 'b0;
        timer_start_down <= 'b0;
        timer_response <= 'b0;
        timer_wait_data <= 'b0;
        timer_bits <= 'b0;
        bit_count <= 'b0;
        shift_reg <= 'b0;
        fsm_state <= IDLE;
        bit_done <= 'b0;
        clk_50M <= 'b0;
        count_clk50 <= 'b0;
        state <='b0;
    end

    always @(posedge clk) begin
        if (rst) begin
            fsm_state <= IDLE;          //1er estado donde se mantiene en 0's
        end else begin
            fsm_state <= next_state;
        end
    end

    always @(*) begin
        next_state = fsm_state;      // se especifica las condiciones para las transiciones entre los estados
        case(fsm_state)
            IDLE: begin                   
                next_state = (timer_init == WAIT_READ)? START_DOWN : IDLE;
            end
            START_DOWN: begin
                next_state = (timer_start_down == INIT_PULSE_DOWN)? START_UP : START_DOWN;
            end
            START_UP: begin
                next_state = (timer_start_up == INIT_PULSE_UP)? WAIT_RESPONSE : START_UP;
            end
            WAIT_RESPONSE: begin
                next_state = (timer_response == WAIT_RESPONSE_INIT & dht11_io == 0)? RECEIVE_BITS : WAIT_RESPONSE;
            end
            WAIT_DATA:begin
                next_state = (timer_wait_data == WAIT_50u & dht11_io == 1)? RECEIVE_BITS : WAIT_DATA;  
            end
            RECEIVE_BITS: begin
                next_state = (bit_count < 40)? ((bit_done)? WAIT_DATA: RECEIVE_BITS) : CHECKSUM;
            end
            CHECKSUM: begin
                next_state = IDLE;
            end
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin                  //aca empieza la magia, donde se mantienen en 0 varios de lso registros
            dht11_out <= 1'b1;
            valid <= 1'b0;
            timer_init <= 'b0;
            timer_start_up <= 'b0;
            timer_start_down <= 'b0;
            timer_response <= 'b0;
            timer_wait_data <= 'b0;
            timer_bits <= 'b0;
            bit_count <= 'b0;
            shift_reg <= 'b0;
            bit_done <= 1'b0;
        end else begin
            case (next_state)
                IDLE: begin
                    valid <= 1'b0;
                    timer_init <= timer_init + 1;       //se le empieza a sumar al registro de inicio que entregamos
                end
                START_DOWN: begin
                    dht11_out <= 1'b0;                  //se empieza a sumar al tiempo de impulso "0"
                    timer_start_down <= timer_start_down + 1;
                end
                START_UP: begin
                    dht11_out <= 1'b1;
                    timer_start_up <= timer_start_up + 1; //se empieza a con el impulso "1"
                end
                WAIT_RESPONSE: begin        //aca esta el punto importante
                    if (dht11_io == 1'b0 & timer_response < 8750) begin  //podriamos estar hablando de no darle tiempo a dht a sacar las respuestar y pueda pasar a transmitir los datos
                         timer_response <= timer_response + 1;
                    end
                    if (timer_response == 8750)begin
                         if (dht11_io == 1'b1) begin
                             timer_response <= timer_response + 1;
                         end
                    end
                    timer_response <= timer_response + 1;
                end
                WAIT_DATA:begin
                    bit_done <= 1'b0;
                    timer_bits <= 'b0;
                    if (dht11_io == 1'b0) begin
                        timer_wait_data <= timer_wait_data + 1;
                    end
                end
                RECEIVE_BITS: begin
                    if(dht11_io == 1'b1) begin
                        timer_bits <= timer_bits +1;
                    end else begin
                        if(timer_bits == ZERO_26u)begin
                            shift_reg <= {shift_reg[38:0], 1'b0};
                            bit_done <= 1'b1;
                        end else if (timer_bits == ONE_70u)begin
                            shift_reg <= {shift_reg[38:0], 1'b1};
                            bit_done <= 1'b1;
                        end
                    end
                end
                CHECKSUM: begin
                    valid <= (shift_reg[7:0] + shift_reg[15:8] + shift_reg[23:16] + shift_reg[31:24] == shift_reg[39:32]) ;
                end
            endcase
        end
    end

    assign dht11_dir = (fsm_state == START_UP || fsm_state == START_DOWN)? 1'b1 : 1'b0;


    always@(posedge clk)begin
        if(rst)begin
            humidity <= 0;
            temperature <= 0;
        end else begin
            humidity <= shift_reg[15:0];
            temperature <= shift_reg[31:16];
        end
    end

    always@(posedge clk)begin
        if(rst)begin
            state = 'b0;
        end else begin
            state <= fsm_state;
        end
    end
        
endmodule
