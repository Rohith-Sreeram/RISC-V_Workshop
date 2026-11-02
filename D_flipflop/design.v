module d_ff(
    input wire clk,
    input wire reset,
    input wire D,
    output reg Q
);

always @(posedge clk)
begin
    if(reset)
        Q <= 1'b0;
    else
        Q <= D;
end

endmodule