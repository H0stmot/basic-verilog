module mux_4to1_assign (
    input [1:0] sel,       
    input [3:0] data0,     
    input [3:0] data1,     
    input [3:0] data2,     
    input [3:0] data3,     
    output [3:0] out      
);

    assign out = (sel == 2'b00) ? data0 :
                 (sel == 2'b01) ? data1 :
                 (sel == 2'b10) ? data2 :
                 (sel == 2'b11) ? data3 : 4'b0000;

endmodule