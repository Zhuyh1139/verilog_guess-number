module Check(
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst,

    input                   [11 : 0]            input_number,
    input                   [11 : 0]            target_number,
    input                   [ 0 : 0]            start_check,

    output        reg      [ 7 : 0]            check_result
);
// 模块内部用寄存器暂存输入信号，从而避免外部信号突变带来的影响
reg [11:0] current_input_data, current_target_data;
always @(posedge clk) begin
    if (rst) begin
        current_input_data <= 0;
        current_target_data <= 0;
    end
    else if (start_check) begin 
        current_input_data <= input_number;
        current_target_data <= target_number;
    end
end

// 使用组合逻辑产生比较结果
wire [3:0] target_number_3, target_number_2, target_number_1;
wire [3:0] input_number_3, input_number_2, input_number_1;
assign input_number_1 = current_input_data[3:0];
assign input_number_2 = current_input_data[7:4];
assign input_number_3 = current_input_data[11:8];
assign target_number_1 = current_target_data[3:0];
assign target_number_2 = current_target_data[7:4];
assign target_number_3 = current_target_data[11:8];

reg i1t1, i1t2, i1t3, i2t1, i2t2, i2t3, i3t1, i3t2, i3t3;
always @(*) begin
    i1t1 = (input_number_1 == target_number_1);
    i1t2 = (input_number_1 == target_number_2);
    i1t3 = (input_number_1 == target_number_3);
    i2t1 = (input_number_2 == target_number_1);
    i2t2 = (input_number_2 == target_number_2);
    i2t3 = (input_number_2 == target_number_3);
    i3t1 = (input_number_3 == target_number_1);
    i3t2 = (input_number_3 == target_number_2);
    i3t3 = (input_number_3 == target_number_3);
end

wire [3:0] num_correct;
assign num_correct = i1t1 + i1t2 + i1t3 + i2t1 + i2t2 + i2t3 + i3t1 + i3t2 + i3t3;
wire [2:0] pos_correct;
assign pos_correct = i1t1 + i2t2 + i3t3;
// TODO：按照游戏规则，补充 check_result 信号的产生逻辑
always @(*) begin
    // if(start_check)begin
        case (num_correct)
            0:check_result = 8'b00_000_000;
            1:begin
                case (pos_correct)
                    0:check_result = 8'b00_000_001; 
                    1:check_result = 8'b00_001_000;
                    default: check_result = 8'b00_000_000;
                endcase
            end 
            2:begin
                case (pos_correct)
                    0:check_result = 8'b00_000_010;
                    1:check_result = 8'b00_001_001;
                    2:check_result = 8'b00_010_000; 
                    default: check_result = 8'b00_000_000;
                endcase
            end
            3:begin
                case (pos_correct)
                    0:check_result = 8'b00_000_100;
                    1:check_result = 8'b00_001_010;
                    3:check_result = 8'b00_100_000; 
                    default: check_result = 8'b00_000_000;
                endcase
            end
            default: check_result = 8'b00_000_000;
        endcase
end
endmodule
