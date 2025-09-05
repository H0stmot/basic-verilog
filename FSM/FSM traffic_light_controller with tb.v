module traffic_light_controller(
    input wire clk,          
    input wire reset_n,       
    input wire sensor,       
    output reg red_light,    
    output reg yellow_light,  
    output reg green_light    
);

// Определение состояний автомата
parameter [2:0] RED      = 3'b000;
parameter [2:0] RED_YELLOW = 3'b001;
parameter [2:0] GREEN    = 3'b010;
parameter [2:0] YELLOW   = 3'b011;
parameter [2:0] ALL_RED  = 3'b100;  // аварийный режим

// Таймеры 
parameter RED_TIME      = 20;     
parameter RED_YELLOW_TIME = 5;    
parameter GREEN_TIME    = 30;     
parameter YELLOW_TIME   = 10;      
reg [2:0] current_state;
reg [2:0] next_state;
reg [7:0] timer;  // счетчик времени

// Регистр текущего состояния
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        current_state <= RED;
        timer <= 0;
    end else begin
        current_state <= next_state;
        // Счетчик времени для текущего состояния
        if (timer == 0) begin
            case (current_state)
                RED: timer <= RED_TIME;
                RED_YELLOW: timer <= RED_YELLOW_TIME;
                GREEN: timer <= GREEN_TIME;
                YELLOW: timer <= YELLOW_TIME;
                default: timer <= 0;
            endcase
        end else begin
            timer <= timer - 1;
        end
    end
end

// Логика переходов между состояниями
always @(*) begin
    case (current_state)
        RED: begin
            if (timer == 0) 
                next_state = RED_YELLOW;
            else
                next_state = RED;
        end
        
        RED_YELLOW: begin
            if (timer == 0) 
                next_state = GREEN;
            else
                next_state = RED_YELLOW;
        end
        
        GREEN: begin
            if (timer == 0 || sensor)  // переходим если время вышло ИЛИ есть транспорт
                next_state = YELLOW;
            else
                next_state = GREEN;
        end
        
        YELLOW: begin
            if (timer == 0) 
                next_state = RED;
            else
                next_state = YELLOW;
        end
        
        ALL_RED: begin
            next_state = ALL_RED;  // аварийный режим - остаемся в нем
        end
        
        default: next_state = RED;
    endcase
end

// Выходная логика - управление светофором
always @(*) begin
    case (current_state)
        RED: begin
            red_light = 1'b1;
            yellow_light = 1'b0;
            green_light = 1'b0;
        end
        
        RED_YELLOW: begin
            red_light = 1'b1;
            yellow_light = 1'b1;
            green_light = 1'b0;
        end
        
        GREEN: begin
            red_light = 1'b0;
            yellow_light = 1'b0;
            green_light = 1'b1;
        end
        
        YELLOW: begin
            red_light = 1'b0;
            yellow_light = 1'b1;
            green_light = 1'b0;
        end
        
        ALL_RED: begin
            red_light = 1'b1;
            yellow_light = 1'b0;
            green_light = 1'b0;
        end
        
        default: begin
            red_light = 1'b1;
            yellow_light = 1'b0;
            green_light = 1'b0;
        end
    endcase
end

endmodule




module tb_traffic_light;

reg clk;
reg reset_n;
reg sensor;
wire red_light;
wire yellow_light;
wire green_light;


traffic_light_controller dut (
    .clk(clk),
    .reset_n(reset_n),
    .sensor(sensor),
    .red_light(red_light),
    .yellow_light(yellow_light),
    .green_light(green_light)
);


always #5 clk = ~clk;

initial begin

    clk = 0;
    reset_n = 0;
    sensor = 0;
    

    #10 reset_n = 1;
    

    #200 sensor = 1;  // имитация появления транспорта
    #50 sensor = 0;
    
    #500 $finish;
end


initial begin
    $monitor("Time=%0t State: R=%b Y=%b G=%b Sensor=%b", 
             $time, red_light, yellow_light, green_light, sensor);
end

endmodule