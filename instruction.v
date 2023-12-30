module instroctions (
    input           clk,
    input           rst,
    input           uart_din,
    input           print_over,
    input [11:0]    target_number,
    output [23:0]   dout_data_out,
    output reg      again,
    output reg      pulse,
    output reg      print
);

wire [ 7 : 0]   din_data;
wire [ 0 : 0]   din_vld;
reg  [15 : 0]   output_data;

Receive receive (
    .clk        (clk),
    .rst        (rst),
    .din        (uart_din),
    .din_vld    (din_vld),
    .din_data   (din_data)
);

always @(posedge clk) begin
    if (rst)
        output_data <= 32'B0;
    else if (din_vld)
        output_data <= {output_data[7:0], din_data};
end

reg [ 0 : 0]   dout_vld;
wire [23: 0] dout_data;
reg [7:0] data;

assign dout_data_out ={{4{1'b0}},target_number[11:8],{4{1'b0}},target_number[7:4],{4{1'b0}},target_number[3:0]} + 24'h303030;

reg [2:0] count;
reg [63:0] counter;
reg [2:0] count_pro;

localparam  WAIT = 3'B000;
localparam PRINT = 3'B001;
localparam PULSE = 3'B010;
localparam AGAIN = 3'B011;
localparam OVER = 3'B100; 

reg [2:0] current_state,next_state;
always @(*) begin
    case (current_state)
        3'b000:begin
            if(output_data == 16'h613b)
                next_state = PRINT;
            else if(output_data == 16'h6e3b)
                next_state = AGAIN;
            else if(output_data == 16'h703b)
                next_state = PULSE;
            else 
                next_state = WAIT;
        end 
        3'b001:begin
            if(print_over)
                next_state = OVER;
            else
                next_state = PRINT;
        end
        3'b010:next_state = OVER;
        3'b011:next_state = OVER;
        3'b100:begin
            if(din_vld)begin
                next_state = WAIT;     
            end
            else 
                next_state = OVER;
        end
        default:next_state = WAIT; 
    endcase
end   

always @(posedge clk) begin
    if(rst)
        current_state <= WAIT;
    else
        current_state <= next_state;
end

always @(posedge clk) begin
    case (current_state)
        3'b000:begin
            again <= 0;
            pulse <= 0;
            dout_vld <= 0;
            counter <= 0;
            count_pro <= 0;
            count <= 0;
            print <= 0;
        end 
        3'b001:begin  
            print <= 1;
        end
        3'b010:pulse <= 1;
        3'b011:again <= 1;
        3'b100:begin
            pulse <= 0;
            again <= 0;
            print <= 0;
        end
        default: count_pro <= 0;
    endcase
end

endmodule