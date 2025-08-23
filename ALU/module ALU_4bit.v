module ALU_4bit(
    input [3:0] A,          
    input [3:0] B,          
    input [2:0] OP,         // 3-битный код операции (8 возможных операций)
    output reg [3:0] Result,
    output reg Zero,        // Флаг нуля (1 = результат равен нулю)
    output reg Carry        // Флаг переноса/заема
);

// Временный 5-битный результат для обработки переноса при арифметических операциях
reg [4:0] temp_result;


always @(*) begin
    
    Carry = 1'b0;
    temp_result = 5'b0;
    
   
    case(OP)
        
        
        3'b000: Result = A & B;           //AND
        3'b001: Result = A | B;           // OR
        3'b010: Result = A ^ B;           // XOR
        3'b011: Result = ~A;              // инверсия операнда A
        
        
        3'b100: begin                     // СЛОЖЕНИЕ
            temp_result = A + B;          // Сумма с учетом возможного переноса
            Result = temp_result[3:0];    // Младшие 4 бита - результат
            Carry = temp_result[4];       // 5-й бит - флаг переноса
        end
        
        3'b101: begin                     // ВЫЧИТАНИЕ
            temp_result = A - B;          // Разность с учетом возможного заема
            Result = temp_result[3:0];    // Младшие 4 бита - результат
            Carry = (A < B) ? 1'b1 : 1'b0; // Флаг заема (1 если A < B)
        end
        

        
        3'b110: begin                     // ЛОГИЧЕСКИЙ СДВИГ ВЛЕВО
            Result = {A[2:0], 1'b0};      // Сдвиг влево на 1 бит, младший бит = 0
            Carry = A[3];                 // Старший бит A становится флагом переноса
        end
        
        3'b111: begin                     // ЛОГИЧЕСКИЙ СДВИГ ВПРАВО
            Result = {1'b0, A[3:1]};      // Сдвиг вправо на 1 бит, старший бит = 0
            Carry = A[0];                 // Младший бит A становится флагом переноса
        end
        
        
        default: Result = 4'b0;           
    endcase
    

    // Устанавливается в 1, если все биты результата равны 0
    Zero = (Result == 4'b0) ? 1'b1 : 1'b0;
end

endmodule