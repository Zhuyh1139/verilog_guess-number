module Segment_pro(
    input                       clk,
    input                       rst,
    input       [31:0]          output_data,
    input       [ 7:0]          output_valid,
    output reg  [ 3:0]          seg_data,
    output reg  [ 2:0]          seg_an
);

reg [31:0] counter;
always @(posedge clk) begin
    if(rst)
        counter <= 0;
    else begin
        if(counter >= 250_000)
            counter <= 0;
        else
            counter <= counter + 32'd1;
    end
end

reg [2:0] seg_id;
always @(posedge clk) begin
    if(rst)
        seg_id <= 0;
    else begin
        if(seg_id > 7)
            seg_id <= 0;
        else if(counter == 1)
            seg_id <= seg_id + 2'd1;
    end
end
wire [31:0] output_data;
always @(*) begin
    seg_data = 0;
    if(rst)begin
        seg_an = 0;
        seg_data = 0;
    end
    else begin

        case (seg_id)
            0: seg_data = output_data[3:0];
            1: seg_data = output_data[7:4];
            2: seg_data = output_data[11:8];
            3: seg_data = output_data[15:12];
            4: seg_data = output_data[19:16];
            5: seg_data = output_data[23:20];
            6: seg_data = output_data[27:24];
            7: seg_data = output_data[31:28];
            default: seg_data = 4'b0000; 
        endcase
        if(!output_valid[seg_id])begin
            seg_an = 0;
            seg_data = output_data[3:0];
        end
        else 
            seg_an = seg_id;
    end     
end
endmodule
