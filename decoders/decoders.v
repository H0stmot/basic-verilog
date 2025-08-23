// 1. Дешифратор 2-to-4 
module decoder_2to4_basic (
    input [1:0] in,           
    input enable,            
    output reg [3:0] out      
);

    always @(*) begin
        if (!enable) begin
            out = 4'b0000;    // Все выходы 0 если disable
        end else begin
            case (in)
                2'b00: out = 4'b0001;
                2'b01: out = 4'b0010;
                2'b10: out = 4'b0100;
                2'b11: out = 4'b1000;
                default: out = 4'b0000;
            endcase
        end
    end

endmodule

// 2. Дешифратор 3-to-8
module decoder_3to8 (
    input [2:0] in,
    input enable,
    output reg [7:0] out
);

    always @(*) begin
        if (!enable) begin
            out = 8'b00000000;
        end else begin
            case (in)
                3'b000: out = 8'b00000001;
                3'b001: out = 8'b00000010;
                3'b010: out = 8'b00000100;
                3'b011: out = 8'b00001000;
                3'b100: out = 8'b00010000;
                3'b101: out = 8'b00100000;
                3'b110: out = 8'b01000000;
                3'b111: out = 8'b10000000;
                default: out = 8'b00000000;
            endcase
        end
    end

endmodule

// 3. Дешифратор с активным низким уровнем
module decoder_2to4_active_low (
    input [1:0] in,
    input enable_n,           
    output reg [3:0] out_n    
);

    always @(*) begin
        if (enable_n) begin
            out_n = 4'b1111;  // Все выходы 1 если disable
        end else begin
            case (in)
                2'b00: out_n = 4'b1110;
                2'b01: out_n = 4'b1101;
                2'b10: out_n = 4'b1011;
                2'b11: out_n = 4'b0111;
                default: out_n = 4'b1111;
            endcase
        end
    end

endmodule

// 4. Параметризованный дешифратор
module decoder_param #(
    parameter INPUT_WIDTH = 3,
    parameter OUTPUT_WIDTH = 2**INPUT_WIDTH
) (
    input [INPUT_WIDTH-1:0] in,
    input enable,
    output reg [OUTPUT_WIDTH-1:0] out
);

    always @(*) begin
        if (!enable) begin
            out = {OUTPUT_WIDTH{1'b0}};
        end else begin
            out = {OUTPUT_WIDTH{1'b0}};
            out[in] = 1'b1;
        end
    end

endmodule

// 5. Дешифратор с использованием сдвига
module decoder_shift (
    input [2:0] in,
    input enable,
    output [7:0] out
);

    assign out = enable ? (8'b00000001 << in) : 8'b00000000;

endmodule

// 6. Дешифратор-демультиплексор
module decoder_demux (
    input [1:0] sel,          // Сигнал выбора
    input data_in,            
    input enable,
    output reg [3:0] out
);

    always @(*) begin
        if (!enable) begin
            out = 4'b0000;
        end else begin
            out = 4'b0000;
            case (sel)
                2'b00: out[0] = data_in;
                2'b01: out[1] = data_in;
                2'b10: out[2] = data_in;
                2'b11: out[3] = data_in;
                default: out = 4'b0000;
            endcase
        end
    end

endmodule

// 7. Каскадный дешифратор 4-to-16 из двух 3-to-8
module decoder_4to16_cascade (
    input [3:0] in,
    input enable,
    output [15:0] out
);

    wire enable_low, enable_high;
    
    // Младшие 3 бита для дешифраторов
    // Старший бит выбирает какой дешифратор активировать
    assign enable_low = enable & (~in[3]);
    assign enable_high = enable & in[3];
    
    decoder_3to8 dec_low (
        .in(in[2:0]),
        .enable(enable_low),
        .out(out[7:0])
    );
    
    decoder_3to8 dec_high (
        .in(in[2:0]),
        .enable(enable_high),
        .out(out[15:8])
    );

endmodule