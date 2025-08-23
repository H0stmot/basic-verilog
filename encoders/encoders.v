// 1. Приоритетный шифратор 4-to-2
module encoder_4to2_priority (
    input [3:0] in,           
    output reg [1:0] out,     
    output valid              
);

    always @(*) begin
        casez (in)
            4'b1???: out = 2'b11; 
            4'b01??: out = 2'b10;
            4'b001?: out = 2'b01;
            4'b0001: out = 2'b00;
            default: out = 2'b00;
        endcase
    end

    assign valid = |in;

endmodule

// 2. Обычный шифратор 4-to-2 (без приоритета)
module encoder_4to2_simple (
    input [3:0] in,
    output reg [1:0] out,
    output valid,
    output error              // Флаг ошибки
);

    always @(*) begin
        case (in)
            4'b0001: out = 2'b00;
            4'b0010: out = 2'b01;
            4'b0100: out = 2'b10;
            4'b1000: out = 2'b11;
            default: out = 2'b00;
        endcase
    end

    assign valid = |in;
    // Ошибка если не ровно один активный вход
    assign error = valid & (~((in == 4'b0001) | (in == 4'b0010) | 
                            (in == 4'b0100) | (in == 4'b1000)));

endmodule

// 3. Приоритетный шифратор 8-to-3
module encoder_8to3_priority (
    input [7:0] in,
    output reg [2:0] out,
    output valid
);

    always @(*) begin
        casez (in)
            8'b1???????: out = 3'b111;
            8'b01??????: out = 3'b110;
            8'b001?????: out = 3'b101;
            8'b0001????: out = 3'b100;
            8'b00001???: out = 3'b011;
            8'b000001??: out = 3'b010;
            8'b0000001?: out = 3'b001;
            8'b00000001: out = 3'b000;
            default: out = 3'b000;
        endcase
    end

    assign valid = |in;

endmodule

// 4. Параметризованный шифратор
module encoder_param #(
    parameter INPUT_WIDTH = 8,
    parameter OUTPUT_WIDTH = $clog2(INPUT_WIDTH)
) (
    input [INPUT_WIDTH-1:0] in,
    output reg [OUTPUT_WIDTH-1:0] out,
    output valid
);

    integer i;
    always @(*) begin
        out = {OUTPUT_WIDTH{1'b0}};
        for (i = INPUT_WIDTH-1; i >= 0; i = i-1) begin
            if (in[i]) begin
                out = i[OUTPUT_WIDTH-1:0];
                disable find_active;
            end
        end
        find_active: ;
    end

    assign valid = |in;

endmodule

// 5. Универсальный шифратор с выбором режима
module encoder_universal #(
    parameter WIDTH = 4
) (
    input [WIDTH-1:0] in,
    input priority_mode, // 0 - простой, 1 - приоритетный
    output reg [$clog2(WIDTH)-1:0] out,
    output valid,
    output error
);

    localparam OUT_WIDTH = $clog2(WIDTH);
    
    // Простой режим
    function [OUT_WIDTH-1:0] simple_encode;
        input [WIDTH-1:0] data;
        integer j;
        begin
            simple_encode = {OUT_WIDTH{1'b0}};
            for (j = 0; j < WIDTH; j = j+1) begin
                if (data[j]) simple_encode = j[OUT_WIDTH-1:0];
            end
        end
    endfunction
    
    // Приоритетный режим
    function [OUT_WIDTH-1:0] priority_encode;
        input [WIDTH-1:0] data;
        integer k;
        begin
            priority_encode = {OUT_WIDTH{1'b0}};
            for (k = WIDTH-1; k >= 0; k = k-1) begin
                if (data[k]) begin
                    priority_encode = k[OUT_WIDTH-1:0];
                    disable priority_loop;
                end
            end
            priority_loop: ;
        end
    endfunction

    always @(*) begin
        if (priority_mode)
            out = priority_encode(in);
        else
            out = simple_encode(in);
    end

    assign valid = |in;
    
    // Проверка на единственный активный бит в простом режиме
    wire multiple_active;
    assign multiple_active = (|(in & (in - 1))) && (|in);
    assign error = (~priority_mode) & multiple_active;

endmodule