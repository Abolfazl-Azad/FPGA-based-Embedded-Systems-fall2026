module window_generator #(
    parameter int unsigned PIXEL_WIDTH = 8
) (
    input  logic                   clk,
    input  logic                   rst,
    input  logic                   pixel_valid,

    input  logic [PIXEL_WIDTH-1:0] top_pixel,
    input  logic [PIXEL_WIDTH-1:0] middle_pixel,
    input  logic [PIXEL_WIDTH-1:0] bottom_pixel,

    output logic [PIXEL_WIDTH-1:0] p00, p01, p02,
    output logic [PIXEL_WIDTH-1:0] p10, p11, p12,
    output logic [PIXEL_WIDTH-1:0] p20, p21, p22
);

    logic [PIXEL_WIDTH-1:0] row0_taps [3];
    logic [PIXEL_WIDTH-1:0] row1_taps [3];
    logic [PIXEL_WIDTH-1:0] row2_taps [3];

    shift_reg #(
        .DATA_WIDTH (PIXEL_WIDTH),
        .DEPTH      (3)
    ) sr_row0 (
        .clk  (clk),
        .rst  (rst),
        .en   (pixel_valid),
        .din  (top_pixel),
        .dout (),
        .taps (row0_taps)
    );

    shift_reg #(
        .DATA_WIDTH (PIXEL_WIDTH),
        .DEPTH      (3)
    ) sr_row1 (
        .clk  (clk),
        .rst  (rst),
        .en   (pixel_valid),
        .din  (middle_pixel),
        .dout (),
        .taps (row1_taps)
    );

    shift_reg #(
        .DATA_WIDTH (PIXEL_WIDTH),
        .DEPTH      (3)
    ) sr_row2 (
        .clk  (clk),
        .rst  (rst),
        .en   (pixel_valid),
        .din  (bottom_pixel),
        .dout (),
        .taps (row2_taps)
    );

    assign p02 = row0_taps[0];
    assign p01 = row0_taps[1];
    assign p00 = row0_taps[2];

    assign p12 = row1_taps[0];
    assign p11 = row1_taps[1];
    assign p10 = row1_taps[2];

    assign p22 = row2_taps[0];
    assign p21 = row2_taps[1];
    assign p20 = row2_taps[2];

endmodule
