module sobel_line_buffer #(
    parameter int unsigned IMAGE_WIDTH  = 640,
    parameter int unsigned IMAGE_HEIGHT = 853,
    parameter int unsigned PIXEL_WIDTH  = 8,
    parameter int unsigned COL_WIDTH    = (IMAGE_WIDTH <= 1) ? 1 : $clog2(IMAGE_WIDTH),
    parameter int unsigned ROW_WIDTH    = (IMAGE_HEIGHT <= 1) ? 1 : $clog2(IMAGE_HEIGHT)
) (
    input  logic                   clk,
    input  logic                   rst,

    input  logic                   pixel_valid,
    input  logic [PIXEL_WIDTH-1:0] pixel_in,

    input  logic [COL_WIDTH-1:0]   col_idx,
    input  logic [ROW_WIDTH-1:0]   row_idx,

    output logic [PIXEL_WIDTH-1:0] p00,
    output logic [PIXEL_WIDTH-1:0] p01,
    output logic [PIXEL_WIDTH-1:0] p02,

    output logic [PIXEL_WIDTH-1:0] p10,
    output logic [PIXEL_WIDTH-1:0] p11,
    output logic [PIXEL_WIDTH-1:0] p12,

    output logic [PIXEL_WIDTH-1:0] p20,
    output logic [PIXEL_WIDTH-1:0] p21,
    output logic [PIXEL_WIDTH-1:0] p22,

    output logic                   window_valid
);

    logic                   valid_pixel;
    logic [PIXEL_WIDTH-1:0] line1_out;
    logic [PIXEL_WIDTH-1:0] line2_out;

    assign valid_pixel = pixel_valid && (col_idx < IMAGE_WIDTH) && (row_idx < IMAGE_HEIGHT);

    single_line_buffer #(
        .DATA_WIDTH (PIXEL_WIDTH),
        .LINE_LEN   (IMAGE_WIDTH),
        .ADDR_WIDTH (COL_WIDTH)
    ) line_buf1 (
        .clk   (clk),
        .wr_en (valid_pixel),
        .addr  (col_idx),
        .din   (pixel_in),
        .dout  (line1_out)
    );

    single_line_buffer #(
        .DATA_WIDTH (PIXEL_WIDTH),
        .LINE_LEN   (IMAGE_WIDTH),
        .ADDR_WIDTH (COL_WIDTH)
    ) line_buf2 (
        .clk   (clk),
        .wr_en (valid_pixel),
        .addr  (col_idx),
        .din   (line1_out),
        .dout  (line2_out)
    );

    window_generator #(
        .PIXEL_WIDTH (PIXEL_WIDTH)
    ) win_gen (
        .clk          (clk),
        .rst          (rst),
        .pixel_valid  (valid_pixel),
        .top_pixel    (line2_out),
        .middle_pixel (line1_out),
        .bottom_pixel (pixel_in),
        .p00(p00), .p01(p01), .p02(p02),
        .p10(p10), .p11(p11), .p12(p12),
        .p20(p20), .p21(p21), .p22(p22)
    );

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            window_valid <= 1'b0;
        end
        else begin
            window_valid <= 1'b0;
            if (valid_pixel && (row_idx >= 2) && (col_idx >= 2)) begin
                window_valid <= 1'b1;
            end
        end
    end

endmodule
