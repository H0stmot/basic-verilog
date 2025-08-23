module demux_1to4_assign (
    input in,           
    input [1:0] sel,    
    output out0,        
    output out1,        
    output out2,        
    output out3         
);

    assign out0 = (sel == 2'b00) ? in : 1'b0;
    assign out1 = (sel == 2'b01) ? in : 1'b0;
    assign out2 = (sel == 2'b10) ? in : 1'b0;
    assign out3 = (sel == 2'b11) ? in : 1'b0;

endmodule