module Reg #(
    parameter Data_len = 8
) (
    input [Data_len-1 : 0] IN,
    input clk,
    input rst,
    input RESET,
    input load,
    input Zero,
    output reg [Data_len-1 : 0] OUT
);
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      OUT <= 0;
    end else if (RESET) begin
      OUT <= 0;
    end else if (Zero) begin
      OUT <= 0;
    end else if (load) begin
      OUT <= IN;
    end else begin
      OUT <= OUT;
    end
  end

endmodule

