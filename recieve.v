module Receive(
    input                   [ 0 : 0]        clk,
    input                   [ 0 : 0]        rst,

    input                   [ 0 : 0]        din,

    output      reg         [ 0 : 0]        din_vld,
    output      reg         [ 7 : 0]        din_data
);

// Counter and parameters
localparam FullT        = 867;
localparam HalfT        = 433;
localparam TOTAL_BITS   = 8;
reg [ 9 : 0] div_cnt;       // 分频计数器，范围 0 ~ 867
reg [ 3 : 0] din_cnt;       // 位计数器，范围 0 ~ 8

// Main FSM
localparam WAIT     = 0;
localparam RECEIVE  = 1;
reg current_state, next_state;
always @(posedge clk) begin
    if (rst)
        current_state <= WAIT;
    else
        current_state <= next_state;
end

always @(*) begin
    next_state = current_state;
    case (current_state)
        0:begin
            if(div_cnt == HalfT)
                next_state = RECEIVE;
            else
                next_state = WAIT;
        end
        1:begin
            if(din_cnt == TOTAL_BITS && div_cnt == FullT)
                next_state = WAIT;
            else
                next_state =RECEIVE;
        end
    endcase
end

// Counter
always @(posedge clk) begin
    if (rst)
        div_cnt <= 10'D0;
    else if (current_state == WAIT) begin // STATE WAIT
        if(din == 0)begin
            if(div_cnt >= HalfT)
                div_cnt <= 10'd0;   
            else
                div_cnt <= div_cnt + 10'd1;
        end
    end
    else begin  // STATE RECEIVE
        if(div_cnt >= FullT)
            div_cnt <= 10'd0;
        else
            div_cnt <= div_cnt + 10'd1;
    end
end

always @(posedge clk) begin
    if (rst)
        din_cnt <= 0;
    else begin
        if(div_cnt == FullT)begin
            if(din_cnt >= TOTAL_BITS)
                din_cnt <= 0;
            else
                din_cnt <= din_cnt + 1; 
        end
    end
end


// Output signals
reg [ 0 : 0] accept_din;    // 位采样信号
always @(*) begin
    accept_din = 1'B0;
    if(current_state == RECEIVE && div_cnt == FullT)
        accept_din = 1'b1;
end

always @(*) begin
    din_vld = 1'B0;
    if(div_cnt == FullT && din_cnt == TOTAL_BITS)
        din_vld = 1'b1;
end

always @(posedge clk) begin
    if (rst)
        din_data <= 8'B0;
    else if (current_state == WAIT)
        din_data <= 8'B0;
    else if (accept_din)
        din_data <= din_data | (din << din_cnt);
end
endmodule
