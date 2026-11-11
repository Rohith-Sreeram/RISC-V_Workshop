module seq_mealy (
    input  wire clk,
    input  wire reset,
    input  wire din,
    output wire detected
);

    localparam S0   = 2'd0;
    localparam S1   = 2'd1;
    localparam S10  = 2'd2;
    localparam S101 = 2'd3;

    reg [1:0] state, next;

    always @(posedge clk) begin
        if (reset) state <= S0;
        else       state <= next;
    end

    always @(*) begin
        case (state)
            S0:      next = din ? S1   : S0;
            S1:      next = din ? S1   : S10;
            S10:     next = din ? S101 : S0;
            S101:    next = din ? S1   : S10;
            default: next = S0;
        endcase
    end

    assign detected = (state == S101) && din;

endmodule