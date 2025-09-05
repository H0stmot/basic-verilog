module mealy_fsm_detector (
    input wire clk,       
    input wire rst_n,     
    input wire data_in,   
    output reg data_out   
);


    parameter [1:0] IDLE = 2'b00,
                    S1   = 2'b01,
                    S10  = 2'b10;

    reg [1:0] current_state, next_state;




    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end



    // Определяем, куда перейти из текущего состояния в зависимости от входа.
    always @(*) begin
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
                    next_state = S1; // Подряд идущие "11"
            end

            S10: begin
                if (data_in == 1'b1)
                    next_state = S1;  // После "101" получаем новую "1", это начало новой последовательности
                else
                    next_state = IDLE; // 100 >> сброс
            end

            default: next_state = IDLE;
        endcase
    end



    // для мили выход зависит от текущ сост и data_in
    always @(*) begin
        // Значение по умолчанию
        data_out = 1'b0;

        case (current_state)
            S10: begin
                // выход активен только если в состоянии S10 пришел data_in=1
                if (data_in == 1'b1)
                    data_out = 1'b1;
            end


        endcase
    end

endmodule



`timescale 1ns/1ps

module tb_mealy_fsm;
    reg clk;
    reg rst_n;
    reg data_in;
    wire data_out;


    mealy_fsm_detector uut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .data_out(data_out)
    );


    always #5 clk = ~clk; 

    initial begin

        clk = 0;
        rst_n = 0;
        data_in = 0;
        #20;
        rst_n = 1;

        
        $display("Testing sequence 1 0 1...");
        @(negedge clk); data_in = 1; // 1
        @(negedge clk); data_in = 0; // 10
        @(negedge clk); data_in = 1; // 101 +


        #10;

        
        $display("Testing sequence 1 0 0...");
        @(negedge clk); data_in = 1; // 1
        @(negedge clk); data_in = 0; // 10
        @(negedge clk); data_in = 0; // 100 -

        #10;


        $display("Testing overlapping sequence 1 0 1 0 1...");
        @(negedge clk); data_in = 1; // 1
        @(negedge clk); data_in = 0; // 10
        @(negedge clk); data_in = 1; // 101
        @(negedge clk); data_in = 0; // 10 
        @(negedge clk); data_in = 1; // 101 

        #30;
        $finish;
    end

    // Monitor results
    initial begin
        $monitor("Time = %t | State = %b | In = %b | Out = %b",
                 $time, uut.current_state, data_in, data_out);
    end

endmodule