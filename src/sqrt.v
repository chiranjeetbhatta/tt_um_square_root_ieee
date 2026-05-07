module sqrt8 (
    input  wire clk,
    input  wire reset,
    input  wire start,
    input  wire [7:0] data_in,   
    output reg  [7:0] data_out,  
    output reg  done
);

    reg [15:0] tmp;      
    reg [15:0] rem;    
    reg [7:0]  q;      
    reg [3:0]  i; // Changed from integer to reg for GLS stability

    reg [1:0] state;
    localparam IDLE=0, CALC=1, FINISH=2;

    always @(posedge clk) begin
        if (reset) begin
            state    <= IDLE;
            data_out <= 8'b0;
            done     <= 1'b0;
            tmp      <= 16'b0;
            rem      <= 16'b0;
            q        <= 8'b0;
            i        <= 4'b0; // Explicitly reset the counter
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        tmp   <= {data_in, 8'b0}; 
                        rem   <= 16'b0;
                        q     <= 8'b0;
                        i     <= 7; 
                        state <= CALC;
                    end
                end

                CALC: begin
                    // Check i strictly using defined widths
                    if (i != 4'hF) begin // Using 4'hF as the "underflow" marker (7 down to 0)
                        if ((rem << 2 | tmp >> 14) >= (q << 2 | 1)) begin
                            rem <= (rem << 2 | tmp >> 14) - (q << 2 | 1);
                            q   <= (q << 1 | 1);
                        end else begin
                            rem <= (rem << 2 | tmp >> 14);
                            q   <= (q << 1);
                        end
                        tmp <= tmp << 2;
                        i   <= i - 1;
                    end else begin
                        state <= FINISH;
                    end
                end

                FINISH: begin
                    data_out <= q;
                    done     <= 1'b1;
                    state    <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule
