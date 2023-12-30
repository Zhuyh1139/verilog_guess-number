module Input(
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst,
    input                   [ 7 : 0]            sw,

    output      reg         [ 3 : 0]            hex,
    output                  [ 0 : 0]            pulse
);
// 三级寄存器边沿检测
reg [7:0] sw_reg_1, sw_reg_2, sw_reg_3;
always @(posedge clk) begin
    if (rst) begin
        sw_reg_1 <= 0;
        sw_reg_2 <= 0;
        sw_reg_3 <= 0;
    end
    else begin
        sw_reg_1 <= sw;
        sw_reg_2 <= sw_reg_1;
        sw_reg_3 <= sw_reg_2;
    end
end

wire [7:0] sw_change;  // TODO：检测上升沿
assign sw_change = sw_reg_2 - sw_reg_3;

always @(*) begin
    if(rst)begin
        hex = 0;
    end
    else begin
        case (sw_change)
        8'd1:hex = 4'd0;
        8'd2:hex = 4'd1;
        8'd4:hex = 4'd2; 
        8'd8:hex = 4'd3;
        8'd16:hex = 4'd4;
        8'd32:hex = 4'd5;
        8'd64:hex = 4'd6;
        8'd128:hex = 4'd7;
        default: hex = 0;
     endcase
    end   
end
assign pulse = (sw_change > 0) ? 1: 0;
// TODO：编写代码，产生 hex 和 pulse 信号。
// Hint：这两个信号均为组合逻辑产生。

endmodule
