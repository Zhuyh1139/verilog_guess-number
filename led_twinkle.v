module led(
    input               clk,
    input               rst,
    input [7:0]         second,
    input               timer_finish,
    input [5:0]         check_result,
    output reg [7:0]    output_valid
);
localparam Hz = 100_000_000;
reg [63:0] counter;

always @(posedge clk) begin
    if(rst)
        counter <= 0;
    else begin
        if(counter >= Hz)
            counter <= 0;
        else
            counter <= counter + 1;
    end
end

always @(posedge clk) begin
    if(timer_finish == 1 || check_result == 6'b111_111)
        output_valid <= 8'b1111_1111;
    else begin
        if(second > 8'd10)
            output_valid <= 8'b1111_1111;
        else if(second > 8'd3 && second <= 8'd10) begin
            if(counter == Hz)
                output_valid <= ~output_valid;
        end
        else if(second > 8'd0 && second <= 8'd3)begin
            if(counter == Hz || counter == Hz/2)
                output_valid <= ~output_valid;
        end
    end
end
endmodule