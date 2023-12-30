module Timer(
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst,

    input                   [ 0 : 0]            set,
    input                   [ 0 : 0]            en,

    output                  [ 7 : 0]            minute,
    output                  [ 7 : 0]            second,
    output                  [11 : 0]            micro_second,

    output                  [ 0 : 0]            finish
);

reg current_state, next_state;
localparam ON = 1;
localparam OFF = 0;

always @(posedge clk) begin
    if (rst)
        current_state <= OFF;
    else
        current_state <= next_state;
end

always @(*) begin
    case (current_state)
        0:begin
            if(en)
                next_state = ON;
            else 
                next_state = OFF;
        end 
        1:begin
            if(en)
                next_state = ON;
            else 
                next_state = OFF;
        end
        default: next_state = OFF;
    endcase
end


localparam TIME_1MS = 100_000_000 / 1000;
reg [31 : 0] counter_1ms;
// TODO: Finish the counter
always @(posedge clk) begin
    if(set || rst)
        counter_1ms <= 0;
    else begin
        if(current_state == ON)begin
            if(counter_1ms >= TIME_1MS)
                counter_1ms <= 0;
            else
                counter_1ms <= counter_1ms + 1; 
        end
    end
end
wire carry_in[2:0];
assign carry_in[0] = (counter_1ms == 1) ? 1 : 0;
Clock # (
    .WIDTH                  (8)    ,
    .MIN_VALUE              (0)    ,
    .MAX_VALUE              (59)   ,
    .SET_VALUE              (1)      
) minute_clock (
    .clk                    (clk),
    .rst                    (rst),
    .set                    (set),
    .carry_in               (carry_in[2]),
    .carry_out              (finish),
    .value                  (minute)
);
Clock # (
    .WIDTH                  (8)   ,
    .MIN_VALUE              (0)   ,
    .MAX_VALUE              (59)  ,
    .SET_VALUE              (0)      
) second_clock (
    .clk                    (clk),
    .rst                    (rst),
    .set                    (set),
    .carry_in               (carry_in[1]),
    .carry_out              (carry_in[2]),
    .value                  (second)
);
Clock # (
    .WIDTH                  (12)   ,
    .MIN_VALUE              (0)    ,
    .MAX_VALUE              (999)  ,
    .SET_VALUE              (0)      
) micro_second_clock (
    .clk                    (clk),
    .rst                    (rst),
    .set                    (set),
    .carry_in               (carry_in[0]),
    .carry_out              (carry_in[1]),
    .value                  (micro_second)
);
// TODO: what's carry_in[0] ?


endmodule
