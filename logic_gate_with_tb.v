module and_gate #(parameter WIDTH = 1) (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output [WIDTH-1:0] y
);
    assign y = a & b;
endmodule

module or_gate #(parameter WIDTH = 1) (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output [WIDTH-1:0] y
);
    assign y = a | b;
endmodule

module not_gate #(parameter WIDTH = 1) (
    input [WIDTH-1:0] a,
    output [WIDTH-1:0] y
);
    assign y = ~a;
endmodule

module xor_gate #(parameter WIDTH = 1) (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output [WIDTH-1:0] y
);
    assign y = a ^ b;
endmodule

module nand_gate #(parameter WIDTH = 1) (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output [WIDTH-1:0] y
);
    assign y = ~(a & b);
endmodule

module nor_gate #(parameter WIDTH = 1) (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output [WIDTH-1:0] y
);
    assign y = ~(a | b);
endmodule

module xnor_gate #(parameter WIDTH = 1) (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output [WIDTH-1:0] y
);
    assign y = ~(a ^ b);
endmodule

module logic_gate #(
    parameter WIDTH = 1,
    parameter TYPE = "AND" // AND, OR, NOT, XOR, NAND, NOR, XNOR
) (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output [WIDTH-1:0] y
);
    
    generate
        if (TYPE == "AND") assign y = a & b;
        else if (TYPE == "OR") assign y = a | b;
        else if (TYPE == "NOT") assign y = ~a;
        else if (TYPE == "XOR") assign y = a ^ b;
        else if (TYPE == "NAND") assign y = ~(a & b);
        else if (TYPE == "NOR") assign y = ~(a | b);
        else if (TYPE == "XNOR") assign y = ~(a ^ b);
        else assign y = {WIDTH{1'b0}}; // По умолчанию
    endgenerate
    
endmodule

module tb_basic_gates;
    reg a, b;
    wire and_out, or_out, not_out, xor_out, nand_out, nor_out, xnor_out;
    
    // Инстансы всех вентилей
    and_gate and1 (.a(a), .b(b), .y(and_out));
    or_gate or1 (.a(a), .b(b), .y(or_out));
    not_gate not1 (.a(a), .y(not_out));
    xor_gate xor1 (.a(a), .b(b), .y(xor_out));
    nand_gate nand1 (.a(a), .b(b), .y(nand_out));
    nor_gate nor1 (.a(a), .b(b), .y(nor_out));
    xnor_gate xnor1 (.a(a), .b(b), .y(xnor_out));
    
    initial begin
        $display("Testing basic gates:");
        $display("A B | AND OR NOT XOR NAND NOR XNOR");
        $display("-------------------------------");
        
        a = 0; b = 0; #10;
        $display("%b %b |  %b  %b   %b   %b   %b   %b   %b", 
                 a, b, and_out, or_out, not_out, xor_out, nand_out, nor_out, xnor_out);
        
        a = 0; b = 1; #10;
        $display("%b %b |  %b  %b   %b   %b   %b   %b   %b", 
                 a, b, and_out, or_out, not_out, xor_out, nand_out, nor_out, xnor_out);
        
        a = 1; b = 0; #10;
        $display("%b %b |  %b  %b   %b   %b   %b   %b   %b", 
                 a, b, and_out, or_out, not_out, xor_out, nand_out, nor_out, xnor_out);
        
        a = 1; b = 1; #10;
        $display("%b %b |  %b  %b   %b   %b   %b   %b   %b", 
                 a, b, and_out, or_out, not_out, xor_out, nand_out, nor_out, xnor_out);
        
        $finish;
    end
endmodule