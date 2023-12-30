module select(
    input               clk,
    input               rst,
    input [1:0]         seg_sel,
    input [7:0]         minute,
    input [7:0]         second,
    input [11:0]        micro_second,
    input [1:0]         led_sel,
    input [31:0]        dout,
    input [11:0]        target_number,
    input               check_start,
    output reg [31: 0]  output_data,
    output reg [7:0]    check_final,
    output reg [7:0]    led
);

wire [7:0] check_result;
wire [7:0] led_result;

Check select_check (
    .clk                (clk), 
    .rst                (rst),
    .input_number       (dout[11:0]),
    .target_number      (target_number),
    .start_check        (check_start),
    .check_result       (check_result)
);

led_affection select_led_affection(
    .clk                (clk),
    .rst                (rst),
    .led                (led_result)
);

always @(*) begin
    case (led_sel)
        2'b00: led = led_result;
        2'b01: led = 8'b1111_1111;
        2'b10: led = 8'b0000_0000;
        2'b11: led = check_result;
        default: led = 8'b0000_0000;
    endcase
    case (seg_sel)
        2'b00: output_data = {{4{1'b0}},minute,second,micro_second};
        2'b01: output_data = 32'h8888_8888;
        2'b10: output_data = 32'h4444_4444;
        default: output_data = 0;
    endcase
    check_final = check_result;
end
endmodule