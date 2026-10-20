module sobel_calc #(
    parameter int unsigned PIXEL_WIDTH = 8,
    parameter bit          PIPELINED   = 1'b0
) (
    input  logic                   clk,
    input  logic                   rst,

    input  logic [PIXEL_WIDTH-1:0] p00, p01, p02,
    input  logic [PIXEL_WIDTH-1:0] p10, p11, p12,
    input  logic [PIXEL_WIDTH-1:0] p20, p21, p22,

    input  logic                   window_valid,

    output logic [PIXEL_WIDTH-1:0] pixel_out,
    output logic                   out_valid
);

    logic [10:0] px_step1, pos_x;
    logic [10:0] nx_step1, neg_x;
    logic [10:0] py_step1, pos_y;
    logic [10:0] ny_step1, neg_y;

    logic [10:0] gx_large, gx_small, abs_gx;
    logic [10:0] gy_large, gy_small, abs_gy;

    logic [11:0] total_g;
    logic [PIXEL_WIDTH-1:0] clamped_pixel;

    addorsub #(.DATA_WIDTH(11)) u_add_px1 (
        .add_sub(1'b0),
        .in1({3'b000, p02}),
        .in2({2'b00, p12, 1'b0}),
        .out(px_step1)
    );

    addorsub #(.DATA_WIDTH(11)) u_add_px2 (
        .add_sub(1'b0),
        .in1(px_step1),
        .in2({3'b000, p22}),
        .out(pos_x)
    );

    addorsub #(.DATA_WIDTH(11)) u_add_nx1 (
        .add_sub(1'b0),
        .in1({3'b000, p00}),
        .in2({2'b00, p10, 1'b0}),
        .out(nx_step1)
    );

    addorsub #(.DATA_WIDTH(11)) u_add_nx2 (
        .add_sub(1'b0),
        .in1(nx_step1),
        .in2({3'b000, p20}),
        .out(neg_x)
    );

    addorsub #(.DATA_WIDTH(11)) u_add_py1 (
        .add_sub(1'b0),
        .in1({3'b000, p20}),
        .in2({2'b00, p21, 1'b0}),
        .out(py_step1)
    );

    addorsub #(.DATA_WIDTH(11)) u_add_py2 (
        .add_sub(1'b0),
        .in1(py_step1),
        .in2({3'b000, p22}),
        .out(pos_y)
    );

    addorsub #(.DATA_WIDTH(11)) u_add_ny1 (
        .add_sub(1'b0),
        .in1({3'b000, p00}),
        .in2({2'b00, p01, 1'b0}),
        .out(ny_step1)
    );

    addorsub #(.DATA_WIDTH(11)) u_add_ny2 (
        .add_sub(1'b0),
        .in1(ny_step1),
        .in2({3'b000, p02}),
        .out(neg_y)
    );

    assign gx_large = (pos_x >= neg_x) ? pos_x : neg_x;
    assign gx_small = (pos_x >= neg_x) ? neg_x : pos_x;

    addorsub #(.DATA_WIDTH(11)) u_sub_gx (
        .add_sub(1'b1),
        .in1(gx_large),
        .in2(gx_small),
        .out(abs_gx)
    );
    

    assign gy_large = (pos_y >= neg_y) ? pos_y : neg_y;
    assign gy_small = (pos_y >= neg_y) ? neg_y : pos_y;

    addorsub #(.DATA_WIDTH(11)) u_sub_gy (
        .add_sub(1'b1),
        .in1(gy_large),
        .in2(gy_small),
        .out(abs_gy)
    );

    addorsub #(.DATA_WIDTH(12)) u_add_total (
        .add_sub(1'b0),
        .in1({1'b0, abs_gx}),
        .in2({1'b0, abs_gy}),
        .out(total_g)
    );

    assign clamped_pixel = (total_g > 12'd255) ? {PIXEL_WIDTH{1'b1}} : total_g[PIXEL_WIDTH-1:0];

    generate
        if (PIPELINED) begin : gen_pipelined
            always_ff @(posedge clk or posedge rst) begin
                if (rst) begin
                    pixel_out <= '0;
                    out_valid <= 1'b0;
                end else begin
                    out_valid <= window_valid;
                    pixel_out <= window_valid ? clamped_pixel : '0;
                end
            end
        end else begin : gen_combinational
            assign pixel_out = window_valid ? clamped_pixel : '0;
            assign out_valid = window_valid;
        end
    endgenerate

endmodule
