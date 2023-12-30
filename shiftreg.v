module ShiftReg(
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst,
    input                   [ 3 : 0]            hex,
    input                   [ 0 : 0]            pulse,
    output      reg         [31 : 0]            dout
);
always @(posedge clk) begin
    if (rst)
        dout <= 0;
    else if (pulse)
        dout <= {{dout[27: 0]}, {hex}};
end
endmodule
