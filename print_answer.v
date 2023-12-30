module print_answer(
    input           clk,
    input           rst,
    input           print,
    input [23:0]    dout_data_out,
    output          uart_dout,
    output reg      print_over
);

reg [2:0] count_pro;
reg [63:0] counter;
reg dout_vld;
reg [7:0] data;

always @(posedge clk) begin
    if(!print)begin
        counter <= 0;
        count_pro <= 0;
        print_over <= 0;
    end
    else begin
        if(counter >= 64'd12000)
            counter <= 0;
        else begin
            counter <= counter + 1;
            if(counter == 64'd11000)begin
                count_pro <= count_pro + 1;
            end
            if(counter == 64'd10900 && count_pro == 3'd2)
                print_over <= 1;                
        end
    end
end

always @(*) begin
    dout_vld = ((counter == 64'd100) && (count_pro <= 2)) ? 1 : 0 ; 
end

always @(*) begin
    case (count_pro)
        0: data = dout_data_out[23:16]; 
        1: data = dout_data_out[15:8];
        2: data = dout_data_out[7:0];
        default: data = dout_data_out[7:0];
    endcase
end

Send send (
   .clk            (clk), 
   .rst            (rst),
   .dout           (uart_dout),
   .dout_vld       (dout_vld),
   .dout_data      (data)
);
endmodule