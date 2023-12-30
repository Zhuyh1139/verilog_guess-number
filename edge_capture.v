module edge_capture(
    input             clk,
    input             rst,
    input             sig_in,  
    output            pos_edge
);

reg sig_r1, sig_r2;
always @(posedge clk) begin
    if (rst) begin
        sig_r1 <= 0;
        sig_r2 <= 0;
    end
    else begin
        sig_r1 <= sig_in;
        sig_r2 <= sig_r1;
    end
end
assign pos_edge = (sig_r1 && ~sig_r2) ? 1 : 0;
endmodule
