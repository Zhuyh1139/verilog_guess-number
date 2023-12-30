module Top (
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            btn,
    input                   [ 7 : 0]            sw,
    input                   [ 0 : 0]            uart_din,            
    output                  [ 7 : 0]            led,
    output                  [ 2 : 0]            seg_an,
    output                  [ 0 : 0]            uart_dout,
    output                  [ 3 : 0]            seg_data
);

wire rst = sw[7];
wire check_start,timer_finish,timer_en,timer_set,pulse,generate_random,pulse_system,again,print_over,print;
wire [3:0] hex;
wire [7:0] check_result;
wire [1:0] seg_sel,led_sel;
wire [31:0] dout;
wire [7:0] second,out_second,minute,output_valid; 
wire [11:0]            target_number,micro_second,out_micro_second;
wire [31:0] output_data;
wire btn_edge;
wire [23:0] dout_data_out;

edge_capture top_edge (
    .clk                (clk),
    .rst                (rst),
    .sig_in             (btn),
    .pos_edge           (btn_edge)
);
Control top_control(
    .clk                (clk),
    .rst                (rst),
    .btn                (btn_edge),
    .again              (again),
    .pulse              (pulse_system),
    .check_result       (check_result),
    .timer_finish       (timer_finish),
    .check_start        (check_start),
    .timer_en           (timer_en),
    .timer_set          (timer_set),
    .generate_random    (generate_random),
    .seg_sel            (seg_sel),
    .led_sel            (led_sel)
);
select top_select(
    .clk                (clk),
    .rst                (rst),
    .seg_sel            (seg_sel),
    .led_sel            (led_sel),
    .minute             (minute),
    .second             (out_second),
    .micro_second       (out_micro_second),
    .dout               (dout),
    .target_number      (target_number),
    .check_start        (check_start),
    .check_final        (check_result),
    .output_data        (output_data),
    .led                (led)
);
Random top_random(
    .clk                (clk),
    .rst                (rst),
    .generate_random    (generate_random),
    .sw                 (sw),
    .random_data        (target_number)
);
Input top_input(
    .clk                (clk),
    .rst                (rst),
    .sw                 (sw),
    .hex                (hex),
    .pulse              (pulse)
);
ShiftReg top_shiftreg(
    .clk                (clk),
    .rst                (rst),
    .hex                (hex),
    .pulse              (pulse),
    .dout               (dout)
);
Timer top_timer (
    .clk                (clk), 
    .rst                (rst),
    .set                (timer_set),
    .en                 (timer_en),
    .minute             (minute),
    .second             (second),
    .micro_second       (micro_second),
    .finish             (timer_finish)
);
bin2bcd_second #(
    .BIN_WIDTH(8),
    .BCD_WIDTH(8)
)second_bin2bcd (
    .bin_in             (second),
    .bcd_out            (out_second)
);
bin2bcd_micro_second #(
    .BIN_WIDTH(12),
    .BCD_WIDTH(12)
)micro_second_bin2bcd (
    .bin_in             (micro_second),
    .bcd_out            (out_micro_second)
);
instroctions top_instroction(
   .clk                 (clk),
   .rst                 (rst),
   .uart_din            (uart_din),
   .target_number       (target_number),
   .dout_data_out       (dout_data_out),
   .print_over          (print_over),
   .pulse               (pulse_system),
   .again               (again),
   .print               (print)
);
print_answer top_print(
    .clk                (clk),
    .rst                (rst),
    .print              (print),
    .dout_data_out      (dout_data_out),
    .uart_dout          (uart_dout),
    .print_over         (print_over)
);
led top_led(
    .clk                (clk),
    .rst                (rst),
    .second             (second),
    .output_valid       (output_valid)
);
Segment_pro top_segment(
    .clk                (clk),
    .rst                (rst),
    .output_data        (output_data),
    .output_valid       (output_valid),
    .seg_an             (seg_an),
    .seg_data           (seg_data)
);
endmodule
