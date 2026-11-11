module seq_moore (
    input  wire clk,
    input  wire reset,
    input  wire din,
    output wire detected
);

    localparam S0    = 3'd0;
    localparam S1    = 3'd1;
    localparam S10   = 3'd2;
    localparam S101  = 3'd3;
    localparam S1011 = 3'd4;

    reg [2:0] state, next;

    always @(posedge clk) begin
        if (reset) state <= S0;
        else       state <= next;
    end

    always @(*) begin
        case (state)
            S0:      next = din ? S1    : S0;
            S1:      next = din ? S1    : S10;
            S10:     next = din ? S101  : S0;
            S101:    next = din ? S1011 : S10;
            S1011:   next = din ? S1    : S10;
            default: next = S0;
        endcase
    end

    assign detected = (state == S1011);

endmodule