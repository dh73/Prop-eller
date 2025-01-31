module phase_accum_clk_div (
    input  logic        clk,        // Main clock
    input  logic        rst_n,      // Active-low reset
    input  logic [31:0] phase_incr, // Frequency control word
    output logic        clk_out     // Generated clock
);
    logic [31:0] accumulator;
    logic        overflow;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            accumulator <= 32'b0;
        end else begin
            // Accumulate phase increment with overflow detection
            {overflow, accumulator} <= accumulator + phase_incr;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_out <= 1'b0;
        end else if (overflow) begin
            // Toggle output clock on overflow
            clk_out <= ~clk_out;
        end
    end

   // Clock output toggle invariants
    property p_clock_toggle_rose;
        $rose_gclk(overflow) |=> $changed_gclk(clk_out);
    endproperty
    InvariantToggleRose: assert property(p_clock_toggle_rose);

    property p_clock_toggle_fell;
        $fell_gclk(overflow) |=> $stable_gclk(clk_out);
    endproperty
    InvariantToggleFell: assert property(p_clock_toggle_fell);

    // Temporal coverage points
    c0: cover property ($fell_gclk(clk_out) ##1 $rose_gclk(clk_out));
    c1: cover property ($rose_gclk(clk_out) ##1 $fell_gclk(clk_out));
endmodule

