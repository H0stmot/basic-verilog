module sequence_detector (
    input wire clk,       
    input wire rst_n,     
    input wire data_in,   
    output reg data_out   
);

    // Определение состояний автомата
    parameter [2:0] IDLE  = 3'b000,
                    S1    = 3'b001,
                    S10   = 3'b010,
                    S101  = 3'b011,
                    S1011 = 3'b100;

 
    reg [2:0] current_state, next_state;

    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    
    always @(*) begin

        next_state = current_state;

        case (current_state)
            IDLE: begin
                if (data_in == 1'b1)
                    next_state = S1;
                else
                    next_state = IDLE;
            end

            S1: begin
                if (data_in == 1'b0)
                    next_state = S10;
                else
                    next_state = S1; // если 1 >> в s1
            end

            S10: begin
                if (data_in == 1'b1)
                    next_state = S101;
                else
                    next_state = IDLE; // 00 >> сброс
            end

            S101: begin
                if (data_in == 1'b1)
                    next_state = S1011; 
                else
                    next_state = S10; //1010 >> в S10
            end

            S1011: begin
                // После обнаружения, см след бит, если он 1, это начало новой последовательности 1,иначе заново
                if (data_in == 1'b1)
                    next_state = S1;
                else
                    next_state = IDLE;
            end

            default: next_state = IDLE; // Обработка неопределенных состояний
        endcase
    end


    // Для автомата Мура выход зависит только от текущего состояния.
    always @(*) begin
        case (current_state)
            S1011: data_out = 1'b1; // только в S1011
            default: data_out = 1'b0;
        endcase
    end

endmodule


`timescale 1ns/1ps

module tb_sequence_detector;
    reg clk;
    reg rst_n;
    reg data_in;
    wire data_out;


    sequence_detector uut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .data_out(data_out)
    );


    always #5 clk = ~clk; // 10ns period clock


    initial begin

        clk = 0;
        rst_n = 0;
        data_in = 0;

        #20;
        rst_n = 1;


        @(negedge clk);
        data_in = 1; // 1
        @(negedge clk);
        data_in = 0; // 10
        @(negedge clk);
        data_in = 1; // 101
        @(negedge clk);
        data_in = 1; // 1011 +

        #20; 

 
        @(negedge clk);
        data_in = 1; // 1
        @(negedge clk);
        data_in = 0; // 10
        @(negedge clk);
        data_in = 1; // 101
        @(negedge clk);
        data_in = 0; // 1010 -

        #20;
        $finish;
    end

    initial begin
        $monitor("Time = %t | data_in = %b | current_state = %b | data_out = %b",
                 $time, data_in, uut.current_state, data_out);
    end

endmodule