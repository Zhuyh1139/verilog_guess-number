module Clock # (
    parameter               WIDTH               = 32,
    parameter               MIN_VALUE           = 0,
    parameter               MAX_VALUE           = 999,
    parameter               SET_VALUE           = 500    
) (
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst,

    input                   [ 0 : 0]            set,
    input                   [ 0 : 0]            carry_in,
    output      reg         [ 0 : 0]            carry_out,
    output      reg         [WIDTH-1: 0]        value
);

always @(posedge clk) begin
    if (rst)
        value = 0;
    else if (set)
        value = SET_VALUE;
    else if (carry_in) begin
        if (value <= MIN_VALUE)
            value <= MAX_VALUE;
        else
            value <= value - 1;
    end
end
always @(*)
    carry_out = (carry_in) && (value == MIN_VALUE);
endmodule
