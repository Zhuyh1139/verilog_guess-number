module Send(
    input                   [ 0 : 0]        clk, 
    input                   [ 0 : 0]        rst,

    output      reg         [ 0 : 0]        dout,

    input                   [ 0 : 0]        dout_vld,
    input                   [ 7 : 0]        dout_data
);

// Counter and parameters
localparam FullT        = 867;
localparam TOTAL_BITS   = 9;
reg [ 9 : 0] div_cnt;           // 分频计数器，范围 0 ~ 867
reg [ 4 : 0] dout_cnt;          // 位计数器，范围 0 ~ 9

// Main FSM
localparam WAIT     = 0;
localparam SEND     = 1;
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
            if(dout_vld)begin
                next_state = 1;
            end
            else
                next_state = 0;
        end
        1:begin
            if(dout_cnt == TOTAL_BITS && div_cnt == FullT)
                next_state = 0;
            else
                next_state = 1;
        end
    endcase
end

// Counter
always @(posedge clk) begin
    if (rst)
        div_cnt <= 10'H0;
    else if (current_state == SEND) begin
        if(div_cnt >= FullT)
            div_cnt <= 10'h0;
        else
            div_cnt <= div_cnt + 1;
    end
    else
        div_cnt <= 10'H0;
end

always @(posedge clk) begin
    if (rst)
        dout_cnt <= 4'H0;
    else if (current_state == SEND) begin
        if(div_cnt == FullT)begin
            if(dout_cnt >= TOTAL_BITS)begin  
                dout_cnt <= 4'h0;
            end
            else begin
                dout_cnt <= dout_cnt + 1;
            end
        end
    end
    else
        dout_cnt <= 4'H0;
end

reg [7 : 0] temp_data;      // 用于保留待发送数据，这样就不怕 dout_data 的变化了
always @(posedge clk) begin
    if (rst)
        temp_data <= 8'H0;
    else if (current_state == WAIT && dout_vld)
        temp_data <= dout_data;
end

always @(posedge clk) begin
    if (rst)
        dout <= 1'B1;
    else begin
        if(current_state == SEND)begin
            if(dout_cnt == 0)begin
                dout <= 1'b1;
            end
            else if(dout_cnt == 1)begin
                dout <= 1'b0;
            end
            else begin
                dout <= temp_data[dout_cnt-2];
            end
        end
        else begin
            dout <= 1'b1;
        end
    end
end
endmodule
