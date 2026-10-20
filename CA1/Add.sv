module adder #(
    parameter int unsigned DATA_WIDTH = 8
) (
    input  logic [DATA_WIDTH-1:0] in1,
    input  logic [DATA_WIDTH-1:0] in2,
    output logic [DATA_WIDTH-1:0] out
);

    assign out = in1 + in2;

endmodule
