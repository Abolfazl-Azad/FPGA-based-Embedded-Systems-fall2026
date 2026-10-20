`timescale 1ns/1ps

module sobel_tb;

    parameter int WIDTH = 640;
    parameter int HEIGHT = 853;
    parameter int TOTAL_PIXELS = WIDTH * HEIGHT;

    logic clk = 0;
    logic rst = 1;
    logic start = 0;
    logic pixel_valid = 0;
    logic [7:0] pixel_in = 0;

    logic [7:0] pixel_out;
    logic out_valid;
    logic done;

    logic [7:0] mem_in [0:TOTAL_PIXELS-1];
    logic [7:0] img_out [0:HEIGHT-1][0:WIDTH-1];

    integer fd;
    integer i, r, c;

    sobel_top #(
        .IMAGE_WIDTH(WIDTH),
        .IMAGE_HEIGHT(HEIGHT),
        .PIXEL_WIDTH(8),
        .PIPELINED(0)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .pixel_valid(pixel_valid),
        .pixel_in(pixel_in),
        .pixel_out(pixel_out),
        .out_valid(out_valid),
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        $readmemh("image_in.hex", mem_in);

        for (r = 0; r < HEIGHT; r++) begin
            for (c = 0; c < WIDTH; c++) begin
                img_out[r][c] = 8'h00;
            end
        end

        #20;
        @(negedge clk);
        rst = 0;
        start = 1;
        @(negedge clk);
        start = 0;

        pixel_valid = 1;
        for (i = 0; i < TOTAL_PIXELS; i++) begin
            pixel_in = mem_in[i];
            @(negedge clk);
            if (out_valid) begin
                img_out[dut.row_idx - 1][dut.col_idx - 2] = pixel_out;
            end
        end
        pixel_valid = 0;

        while (!done) begin
            @(negedge clk);
            if (out_valid) begin
                img_out[dut.row_idx - 1][dut.col_idx - 2] = pixel_out;
            end
        end

        #50;

        fd = $fopen("image_out.hex", "w");
        for (r = 0; r < HEIGHT; r++) begin
            for (c = 0; c < WIDTH; c++) begin
                $fdisplay(fd, "%02X", img_out[r][c]);
            end
        end
        $fclose(fd);

        $display("Processing finished. image_out.hex generated.");
        $finish;
    end

endmodule
