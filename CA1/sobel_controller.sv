module sobel_controller #(
    parameter int unsigned IMAGE_WIDTH  = 640,
    parameter int unsigned IMAGE_HEIGHT = 853,
    parameter int unsigned COL_WIDTH    = (IMAGE_WIDTH <= 1) ? 1 : $clog2(IMAGE_WIDTH),
    parameter int unsigned ROW_WIDTH    = (IMAGE_HEIGHT <= 1) ? 1 : $clog2(IMAGE_HEIGHT)
) (
    input  logic                 clk,
    input  logic                 rst,
    input  logic                 start,
    input  logic                 pixel_valid,

    output logic [COL_WIDTH-1:0] col_idx,
    output logic [ROW_WIDTH-1:0] row_idx,
    output logic                 done
);

    typedef enum logic [1:0] {
        IDLE,
        ACTIVE,
        FINISHED
    } state_t;

    state_t state;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state   <= IDLE;
            col_idx <= '0;
            row_idx <= '0;
            done    <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        state   <= ACTIVE;
                        col_idx <= '0;
                        row_idx <= '0;
                    end
                end

                ACTIVE: begin
                    done <= 1'b0;
                    if (pixel_valid) begin
                        if (col_idx == IMAGE_WIDTH - 1) begin
                            col_idx <= '0;
                            if (row_idx == IMAGE_HEIGHT - 1) begin
                                row_idx <= '0;
                                done    <= 1'b1;
                                state   <= FINISHED;
                            end else begin
                                row_idx <= row_idx + 1'b1;
                            end
                        end else begin
                            col_idx <= col_idx + 1'b1;
                        end
                    end
                end

                FINISHED: begin
                    done  <= 1'b0;
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
