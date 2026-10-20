module Reg #(
    parameter int unsigned Data_len = 8
) (
    input  logic [Data_len-1:0] IN,
    input  logic               clk,
    input  logic               rst,
    input  logic               RESET,
    input  logic               load,
    input  logic               Zero,
    output logic [Data_len-1:0] OUT
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            OUT <= '0;
        end
        else if (RESET) begin
            OUT <= '0;
        end
        else if (Zero) begin
            OUT <= '0;
        end
        else if (load) begin
            OUT <= IN;
        end
    end

endmodule