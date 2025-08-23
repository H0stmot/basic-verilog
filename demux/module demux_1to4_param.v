module demux_1to4_param #(
    parameter WIDTH = 1  
) (
    input [WIDTH-1:0] in,     
    input [1:0] sel,          
    output reg [WIDTH-1:0] out0,  
    output reg [WIDTH-1:0] out1,  
    output reg [WIDTH-1:0] out2,  
    output reg [WIDTH-1:0] out3   
);

    always @(*) begin
        
        out0 = {WIDTH{1'b0}};
        out1 = {WIDTH{1'b0}};
        out2 = {WIDTH{1'b0}};
        out3 = {WIDTH{1'b0}};
        
        
        case (sel)
            2'b00: out0 = in;
            2'b01: out1 = in;
            2'b10: out2 = in;
            2'b11: out3 = in;
        endcase
    end

endmodule