module single_line_buffer #(
    parameter int unsigned DATA_WIDTH = 8,
    parameter int unsigned LINE_LEN   = 640,
    parameter int unsigned ADDR_WIDTH = (LINE_LEN <= 1) ? 1 : $clog2(LINE_LEN)
) (
    input  logic                  clk,
    input  logic                  wr_en,
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic [DATA_WIDTH-1:0] din,
    output logic [DATA_WIDTH-1:0] dout
);

    logic [DATA_WIDTH-1:0] mem [0:LINE_LEN-1];

    assign dout = mem[addr];

    always_ff @(posedge clk) begin
        if (wr_en) begin
            mem[addr] <= din;
        end
    end

endmodule
