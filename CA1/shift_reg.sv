module shift_reg #(
    parameter int unsigned DATA_WIDTH = 8,
    parameter int unsigned DEPTH      = 3
) (
    input  logic                   clk,
    input  logic                   rst,
    input  logic                   en,
    input  logic [DATA_WIDTH-1:0]  din,
    output logic [DATA_WIDTH-1:0]  dout,
    output logic [DATA_WIDTH-1:0]  taps [DEPTH]
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < DEPTH; i++) begin
                taps[i] <= '0;
            end
        end
        else if (en) begin
            taps[0] <= din;
            for (int i = 1; i < DEPTH; i++) begin
                taps[i] <= taps[i-1];
            end
        end
    end

    assign dout = taps[DEPTH-1];

endmodule
