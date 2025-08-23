`timescale 1ns/1ps

module tb_decoders;

    // Тестовые сигналы
    reg [1:0] test_in_2bit;
    reg [2:0] test_in_3bit;
    reg [3:0] test_in_4bit;
    reg enable, enable_n, data_in;
    
    // Выходы для 2-to-4 дешифраторов
    wire [3:0] out_basic, out_active_low, out_demux;
    wire [3:0] out_param_2to4;
    
    // Выходы для 3-to-8 дешифраторов
    wire [7:0] out_3to8, out_shift, out_param_3to8;
    
    // Выходы для 4-to-16 дешифратора
    wire [15:0] out_4to16;
    
    // Инстансы дешифраторов
    decoder_2to4_basic dec_basic (
        .in(test_in_2bit),
        .enable(enable),
        .out(out_basic)
    );
    
    decoder_2to4_active_low dec_active_low (
        .in(test_in_2bit),
        .enable_n(enable_n),
        .out_n(out_active_low)
    );
    
    decoder_demux dec_demux (
        .sel(test_in_2bit),
        .data_in(data_in),
        .enable(enable),
        .out(out_demux)
    );
    
    decoder_param #(.INPUT_WIDTH(2)) dec_param_2to4 (
        .in(test_in_2bit),
        .enable(enable),
        .out(out_param_2to4)
    );
    
    decoder_3to8 dec_3to8 (
        .in(test_in_3bit),
        .enable(enable),
        .out(out_3to8)
    );
    
    decoder_shift dec_shift (
        .in(test_in_3bit),
        .enable(enable),
        .out(out_shift)
    );
    
    decoder_param #(.INPUT_WIDTH(3)) dec_param_3to8 (
        .in(test_in_3bit),
        .enable(enable),
        .out(out_param_3to8)
    );
    
    decoder_4to16_cascade dec_4to16 (
        .in(test_in_4bit),
        .enable(enable),
        .out(out_4to16)
    );

    // Тестирование 2-to-4 дешифраторов
    task test_2to4_decoders;
        input [1:0] pattern;
        input en;
        input data;
        begin
            test_in_2bit = pattern;
            enable = en;
            enable_n = ~en;
            data_in = data;
            #20;
            $display("in=%2b en=%b | Basic: %4b | ActiveLow: %4b | Demux: %4b | Param: %4b",
                    test_in_2bit, enable,
                    out_basic,
                    out_active_low,
                    out_demux,
                    out_param_2to4);
        end
    endtask

    // Тестирование 3-to-8 дешифраторов
    task test_3to8_decoders;
        input [2:0] pattern;
        input en;
        begin
            test_in_3bit = pattern;
            enable = en;
            #20;
            $display("in=%3b en=%b | 3to8: %8b | Shift: %8b | Param: %8b",
                    test_in_3bit, enable,
                    out_3to8,
                    out_shift,
                    out_param_3to8);
        end
    endtask

    // Тестирование 4-to-16 дешифратора
    task test_4to16_decoder;
        input [3:0] pattern;
        input en;
        begin
            test_in_4bit = pattern;
            enable = en;
            #20;
            $display("in=%4b en=%b | 4to16: %16b",
                    test_in_4bit, enable,
                    out_4to16);
        end
    endtask

    initial begin
        $display("=== ТЕСТИРОВАНИЕ ДЕШИФРАТОРОВ ===");
        
        $display("\n--- 2-to-4 Дешифраторы (enable=0) ---");
        test_2to4_decoders(2'b00, 1'b0, 1'b1);
        test_2to4_decoders(2'b01, 1'b0, 1'b1);
        test_2to4_decoders(2'b10, 1'b0, 1'b1);
        test_2to4_decoders(2'b11, 1'b0, 1'b1);
        
        $display("\n--- 2-to-4 Дешифраторы (enable=1) ---");
        test_2to4_decoders(2'b00, 1'b1, 1'b1);
        test_2to4_decoders(2'b01, 1'b1, 1'b1);
        test_2to4_decoders(2'b10, 1'b1, 1'b1);
        test_2to4_decoders(2'b11, 1'b1, 1'b1);
        
        $display("\n--- Демультиплексор (data_in=0) ---");
        test_2to4_decoders(2'b00, 1'b1, 1'b0);
        test_2to4_decoders(2'b01, 1'b1, 1'b0);
        test_2to4_decoders(2'b10, 1'b1, 1'b0);
        test_2to4_decoders(2'b11, 1'b1, 1'b0);
        
        $display("\n--- 3-to-8 Дешифраторы (enable=1) ---");
        test_3to8_decoders(3'b000, 1'b1);
        test_3to8_decoders(3'b001, 1'b1);
        test_3to8_decoders(3'b010, 1'b1);
        test_3to8_decoders(3'b011, 1'b1);
        test_3to8_decoders(3'b100, 1'b1);
        test_3to8_decoders(3'b101, 1'b1);
        test_3to8_decoders(3'b110, 1'b1);
        test_3to8_decoders(3'b111, 1'b1);
        
        $display("\n--- 4-to-16 Дешифратор ---");
        test_4to16_decoder(4'b0000, 1'b1);
        test_4to16_decoder(4'b0001, 1'b1);
        test_4to16_decoder(4'b0010, 1'b1);
        test_4to16_decoder(4'b0111, 1'b1);
        test_4to16_decoder(4'b1000, 1'b1);
        test_4to16_decoder(4'b1001, 1'b1);
        test_4to16_decoder(4'b1111, 1'b1);
        
        $display("\n=== ТЕСТИРОВАНИЕ ЗАВЕРШЕНО ===");
        $finish;
    end

    initial begin
        $monitor("Time %t: 2bit_in=%b, 3bit_in=%b, enable=%b", 
                 $time, test_in_2bit, test_in_3bit, enable);
    end

endmodule