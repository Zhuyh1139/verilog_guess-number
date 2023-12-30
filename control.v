module Control (
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst,
    input                   [ 0 : 0]            btn,
    input                   [ 0 : 0]            pulse,
    input                   [ 0 : 0]            again,

    input                   [ 7 : 0]            check_result,
    output      reg         [ 0 : 0]            check_start,
    output      reg         [ 0 : 0]            timer_en,
    output      reg         [ 0 : 0]            timer_set,
    input                   [ 0 : 0]            timer_finish,
    output      reg         [ 0 : 0]            generate_random,
    output      reg         [ 1 : 0]            led_sel,
    output      reg         [ 1 : 0]            seg_sel
);

localparam START = 3'B000;
localparam GEN_RAN = 3'B001;
localparam INPUT_NUM = 3'B010;
localparam CHECK = 3'B011;
localparam RESULT = 3'B100;
localparam OVER = 3'B101;
localparam ENDGAME_S = 3'B110;
localparam ENDGAME_F = 3'B111;

reg [2:0] current_state,next_state;
always @(*) begin
    if(timer_finish)
        next_state = ENDGAME_F;
    else if(again)
        next_state = START;
    else begin
        case (current_state)
        3'b000:next_state = GEN_RAN;
        3'b001:next_state = INPUT_NUM;
        3'b010:begin
            if(btn)
                next_state = CHECK;
            else
                next_state = INPUT_NUM; 
        end
        3'b011:next_state = RESULT;
        3'b100:next_state = OVER;
        3'b101:begin
            if(check_result == 8'b0010_0000)
                next_state = ENDGAME_S;
            else begin
                if(btn)
                    next_state = INPUT_NUM;
                else 
                    next_state = OVER;
                end
        end
        3'b110:begin
            if(btn)
                next_state = START;
            else
                next_state = ENDGAME_S; 
        end
        3'b111:begin
            if(btn)
                next_state = START;
            else
                next_state = ENDGAME_F; 
        end
        default: next_state = START;
        endcase
    end
end

always @(posedge clk) begin
    if(rst)
        current_state <= START;
    else
        current_state <= next_state;
end

always @(posedge clk) begin
    if(pulse && current_state != ENDGAME_F && current_state != ENDGAME_S)
        timer_en <= ~timer_en;
    else begin
        case (current_state)
            3'b000:begin
                timer_en <= 1;
                timer_set <= 1;
                generate_random <= 0;
                check_start <= 0;
                seg_sel <= 2'b00;
                led_sel <= 2'b00;
            end
            3'b001:begin
                generate_random <= 1;
                timer_set <= 0;
            end
            3'b010:begin
                led_sel <= 2'b00;
                generate_random <= 0;
                check_start <= 0;
            end
            3'b011:begin
                check_start <= 1;
            end
            3'b100:begin
                check_start <= 0;
            end
            3'b101:begin    
                led_sel <= 2'b11;
            end
            3'b110:begin
                timer_en <= 0;
                seg_sel <= 2'b01;
                led_sel <= 2'b01;
            end
            3'b111:begin
                timer_en <= 0;
                seg_sel <= 2'b10;
                led_sel <= 2'b10;
            end
            default: timer_set <= 1;
        endcase
    end
end
endmodule