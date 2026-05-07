module sqrt8 (
    input  wire clk,
    input  wire reset,
    input  wire start,
    input  wire [7:0] data_in,   // Integer input
    output reg  [7:0] data_out,  // Q4.4 Fixed-point output
    output reg  done
);

    // Internal registers
    reg [15:0] x;      // Input padded with 8 zeros for 4 fractional bits
    reg [15:0] rem;    // Remainder
    reg [7:0]  q;      // Result accumulator
    integer i;

   reg [1:0] state;
   localparam IDLE=0, CALC=1, FINISH=2;

    always @(posedge clk) begin
        if (reset) begin
            state    <= IDLE;
            data_out <= 8'b0;
            done     <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        // Pad 8-bit input with 8 zeros for Q4.4 output
                        x     <= {data_in, 8'b0}; 
                        rem   <= 16'b0;
                        q     <= 8'b0;
                        i     <= 7; // 8 iterations for 8-bit result
                        state <= CALC;
                    end
                end

                CALC: begin
                    // Non-restoring / Digit-by-digit algorithm logic
                    if (i >= 0) begin
                        // Test subtraction for the next bit
                        if ((rem << 2 | x >> 14) >= (q << 2 | 1)) begin
                            rem <= (rem << 2 | x >> 14) - (q << 2 | 1);
                            q   <= (q << 1 | 1);
                        end else begin
                            rem <= (rem << 2 | x >> 14);
                            q   <= (q << 1);
                        end
                        x <= x << 2;
                        i <= i - 1;
                    end else begin
                        state <= FINISH;
                    end
                end

                FINISH: begin
                    data_out <= q;
                    done     <= 1'b1;
                    state    <= IDLE;
                end
            endcase
        end
    end
endmodule