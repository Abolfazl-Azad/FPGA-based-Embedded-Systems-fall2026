module sobel_top #(
    parameter int unsigned IMAGE_WIDTH  = 640,
    parameter int unsigned IMAGE_HEIGHT = 853,
    parameter int unsigned PIXEL_WIDTH  = 8,
    parameter bit          PIPELINED     = 1'b0,
    parameter int unsigned COL_WIDTH    = (IMAGE_WIDTH <= 1) ? 1 : $clog2(IMAGE_WIDTH),
    parameter int unsigned ROW_WIDTH    = (IMAGE_HEIGHT <= 1) ? 1 : $clog2(IMAGE_HEIGHT)
) (
    input  logic                   clk,
    input  logic                   rst,
    input  logic                   start,
    input  logic                   pixel_valid,
    input  logic [PIXEL_WIDTH-1:0] pixel_in,

    output logic [PIXEL_WIDTH-1:0] pixel_out,
    output logic                   out_valid,
    output logic                   done
);

    logic [COL_WIDTH-1:0] col_idx;
    logic [ROW_WIDTH-1:0] row_idx;

    logic [PIXEL_WIDTH-1:0] p00, p01, p02;
    logic [PIXEL_WIDTH-1:0] p10, p11, p12;
    logic [PIXEL_WIDTH-1:0] p20, p21, p22;
    logic window_valid;

    sobel_controller #(
        .IMAGE_WIDTH  (IMAGE_WIDTH),
        .IMAGE_HEIGHT (IMAGE_HEIGHT),
        .COL_WIDTH    (COL_WIDTH),
        .ROW_WIDTH    (ROW_WIDTH)
    ) u_controller (
        .clk         (clk),
        .rst         (rst),
        .start       (start),
        .pixel_valid (pixel_valid),
        .col_idx     (col_idx),
        .row_idx     (row_idx),
        .done        (done)
    );

    sobel_line_buffer #(
        .IMAGE_WIDTH  (IMAGE_WIDTH),
        .IMAGE_HEIGHT (IMAGE_HEIGHT),
        .PIXEL_WIDTH  (PIXEL_WIDTH),
        .COL_WIDTH    (COL_WIDTH),
        .ROW_WIDTH    (ROW_WIDTH)
    ) u_line_buffer (
        .clk          (clk),
        .rst          (rst),
        .pixel_valid  (pixel_valid),
        .pixel_in     (pixel_in),
        .col_idx      (col_idx),
        .row_idx      (row_idx),
        .p00(p00), .p01(p01), .p02(p02),
        .p10(p10), .p11(p11), .p12(p12),
        .p20(p20), .p21(p21), .p22(p22),
        .window_valid (window_valid)
    );

    sobel_calc #(
        .PIXEL_WIDTH (PIXEL_WIDTH),
        .PIPELINED   (PIPELINED)
    ) u_calc (
        .clk          (clk),
        .rst          (rst),
        .p00(p00), .p01(p01), .p02(p02),
        .p10(p10), .p11(p11), .p12(p12),
        .p20(p20), .p21(p21), .p22(p22),
        .window_valid (window_valid),
        .pixel_out    (pixel_out),
        .out_valid    (out_valid)
    );

endmodule
