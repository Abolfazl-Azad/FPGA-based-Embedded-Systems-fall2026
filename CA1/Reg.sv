module Reg #(
    parameter int unsigned DATA_WIDTH = 8
) (
    input  logic                  clk,
    input  logic                  rst,    
    input  logic                  clr,   
    input  logic                  load,   
    input  logic [DATA_WIDTH-1:0] din,
    output logic [DATA_WIDTH-1:0] dout
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            dout <= '0;
        end
        else if (clr) begin
            dout <= '0;
        end
        else if (load) begin
            dout <= din;
        end
    end

endmodule
