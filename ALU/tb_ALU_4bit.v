module test_ALU_4bit;

reg [3:0] A, B;
reg [2:0] OP;
wire [3:0] Result;
wire Zero, Carry;

ALU_4bit uut(.A(A), .B(B), .OP(OP), .Result(Result), .Zero(Zero), .Carry(Carry));

integer errors = 0;

initial begin
    run_test(4'b1010, 4'b1100, 3'b000, 4'b1000, 0, 0);
    run_test(4'b1010, 4'b1100, 3'b001, 4'b1110, 0, 0);
    run_test(4'b1010, 4'b1100, 3'b010, 4'b0110, 0, 0);
    run_test(4'b1010, 4'b0000, 3'b011, 4'b0101, 0, 0);
    
    run_test(4'b0111, 4'b0011, 3'b100, 4'b1010, 0, 0);
    run_test(4'b0111, 4'b0011, 3'b101, 4'b0100, 0, 0);
    run_test(4'b0011, 4'b0111, 3'b101, 4'b1100, 0, 1);
    
    run_test(4'b1011, 4'b0000, 3'b110, 4'b0110, 0, 1);
    run_test(4'b1011, 4'b0000, 3'b111, 4'b0101, 0, 1);
    
    run_test(4'b1111, 4'b0001, 3'b100, 4'b0000, 1, 1);
    run_test(4'b0000, 4'b0000, 3'b100, 4'b0000, 1, 0);
    
    if (errors == 0)
        $display("Все тесты пройдены успешно!");
    else
        $display("Найдено ошибок: %0d", errors);
    
    $finish;
end

task run_test;
    input [3:0] a, b;
    input [2:0] op;
    input [3:0] exp_r;
    input exp_z, exp_c;
    
    begin
        A = a; B = b; OP = op;
        #1;
        
        if (Result !== exp_r || Zero !== exp_z || Carry !== exp_c) begin
            errors++;
            $display("Ошибка! OP=%b A=%b B=%b", op, a, b);
            $display("Получено: R=%b Z=%b C=%b", Result, Zero, Carry);
            $display("Ожидалось: R=%b Z=%b C=%b", exp_r, exp_z, exp_c);
        end
    end
endtask

endmodule