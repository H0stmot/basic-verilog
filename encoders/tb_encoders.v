
`timescale 1ns/1ps

module tb_encoders;

    // Тестовые сигналы
    reg [3:0] test_in_4bit;
    reg [7:0] test_in_8bit;
    reg priority_mode;
    
    // Выходы для 4-битных шифраторов
    wire [1:0] out_priority_4to2, out_simple_4to2;
    wire valid_priority_4to2, valid_simple_4to2;
    wire error_simple_4to2;
    
    // Выходы для 8-битного шифратора
    wire [2:0] out_8to3;
    wire valid_8to3;
    
    // Выходы для параметризованного шифратора
    wire [2:0] out_param;
    wire valid_param;
    
    // Выходы для универсального шифратора
    wire [1:0] out_universal;
    wire valid_universal, error_universal;
    
    // Инстансы всех шифраторов
    encoder_4to2_priority enc_priority_4to2 (
        .in(test_in_4bit),
        .out(out_priority_4to2),
        .valid(valid_priority_4to2)
    );
    
    encoder_4to2_simple enc_simple_4to2 (
        .in(test_in_4bit),
        .out(out_simple_4to2),
        .valid(valid_simple_4to2),
        .error(error_simple_4to2)
    );
    
    encoder_8to3_priority enc_8to3 (
        .in(test_in_8bit),
        .out(out_8to3),
        .valid(valid_8to3)
    );
    
    encoder_param #(.INPUT_WIDTH(8)) enc_param (
        .in(test_in_8bit),
        .out(out_param),
        .valid(valid_param)
    );
    
    encoder_universal #(.WIDTH(4)) enc_universal (
        .in(test_in_4bit),
        .priority_mode(priority_mode),
        .out(out_universal),
        .valid(valid_universal),
        .error(error_universal)
    );

    // Тестирование 4-битных шифраторов
    task test_4bit_encoders;
        input [3:0] test_pattern;
        begin
            test_in_4bit = test_pattern;
            #20;
            $display("in=%4b | Pri: out=%2b valid=%b | Sim: out=%2b valid=%b err=%b | Uni: out=%2b valid=%b err=%b (mode=%b)",
                    test_in_4bit,
                    out_priority_4to2, valid_priority_4to2,
                    out_simple_4to2, valid_simple_4to2, error_simple_4to2,
                    out_universal, valid_universal, error_universal, priority_mode);
        end
    endtask

    // Тестирование 8-битных шифраторов
    task test_8bit_encoders;
        input [7:0] test_pattern;
        begin
            test_in_8bit = test_pattern;
            #20;
            $display("in=%8b | 8to3: out=%3b valid=%b | Param: out=%3b valid=%b",
                    test_in_8bit,
                    out_8to3, valid_8to3,
                    out_param, valid_param);
        end
    endtask

    initial begin
        $display("=== ТЕСТИРОВАНИЕ ШИФРАТОРОВ ===");
        $display("\n--- 4-битные шифраторы (приоритетный режим) ---");
        priority_mode = 1'b1;
        
        $display("\nТест отдельных битов:");
        test_4bit_encoders(4'b0001);
        test_4bit_encoders(4'b0010);
        test_4bit_encoders(4'b0100);
        test_4bit_encoders(4'b1000);
        
        $display("\nТест множественных битов (приоритет):");
        test_4bit_encoders(4'b0011);
        test_4bit_encoders(4'b0110);
        test_4bit_encoders(4'b1100);
        test_4bit_encoders(4'b1111);
        
        $display("\n--- 4-битные шифраторы (простой режим) ---");
        priority_mode = 1'b0;
        
        $display("\nКорректные входы:");
        test_4bit_encoders(4'b0001);
        test_4bit_encoders(4'b0010);
        test_4bit_encoders(4'b0100);
        test_4bit_encoders(4'b1000);
        
        $display("\nНекорректные входы (ошибка):");
        test_4bit_encoders(4'b0000);
        test_4bit_encoders(4'b0011);
        test_4bit_encoders(4'b0101);
        test_4bit_encoders(4'b1111);
        
        $display("\n--- 8-битные шифраторы ---");
        $display("\nТест отдельных битов:");
        test_8bit_encoders(8'b00000001);
        test_8bit_encoders(8'b00000010);
        test_8bit_encoders(8'b00000100);
        test_8bit_encoders(8'b00001000);
        test_8bit_encoders(8'b00010000);
        test_8bit_encoders(8'b00100000);
        test_8bit_encoders(8'b01000000);
        test_8bit_encoders(8'b10000000);
        
        $display("\nТест приоритета:");
        test_8bit_encoders(8'b00001100);
        test_8bit_encoders(8'b00110000);
        test_8bit_encoders(8'b11000000);
        test_8bit_encoders(8'b11111111);
        
        $display("\n=== ТЕСТИРОВАНИЕ ЗАВЕРШЕНО ===");
        $finish;
    end

    // Мониторинг изменений
    initial begin
        $monitor("Time %t: 4bit_in=%b, 8bit_in=%b", $time, test_in_4bit, test_in_8bit);
    end

endmodule