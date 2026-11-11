// 8-bit up/down counter with synchronous reset, enable and parallel load
module counter (
    input  wire       clk,
    input  wire       reset,      // synchronous, active high
    input  wire       enable,     // count enable
    input  wire       up_down,    // 1 = count up, 0 = count down
    input  wire       load,       // parallel load, active high
    input  wire [7:0] load_data,  // value to load
    output reg  [7:0] count
);

    always @(posedge clk) begin
        if (reset)
            count <= 8'h00;                 // highest priority
        else if (load)
            count <= load_data;             // parallel load
        else if (enable) begin
            if (up_down)
                count <= count + 8'd1;      // count up (wraps FF -> 00)
            else
                count <= count - 8'd1;      // count down (wraps 00 -> FF)
        end
        // else: hold current value
    end

endmodule