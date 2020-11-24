`default_nettype none
`include "checker_lib.vh"

module counter #(parameter WIDTH = 8)
   (input wire clk, rstn, en,
    output reg [0:0] start, start_delayed,
    output reg [WIDTH-1:0] q);
   
   always @*
     // The system task $initstate evaluates to 1 in the initial state and to 0 otherwise.
     prepare_reset: assume (rstn == !$initstate);
   
   always @(posedge clk) begin
      if (!rstn)   q <= 0;
      else if (en) q <= q + 1'b1;
   end
   
   always @* begin
      if (en) start <= 1'b1;
      else    start <= 1'b0;
   end
   
   always @(posedge clk) begin
      start_delayed <= start;
   end
   
   // If en is deasserted, the value at q should be stable in the next clock cycle
   `A_IMPLIES_STABLE_B_NEXTTIME( ASSERT, (!en), q, WIDTH, clk, rstn, EN_AUTOCOVER, stable_q )
   // If enable is asserted, the counter should increment. Overflow and underflow conditions 
   // are not defined in this rule.
   wire fire = en & (q != {WIDTH{1'b0}} & q != {WIDTH{1'b1}});
   `A_IMPLIES_INCREMENT_B( ASSERT, fire, q, WIDTH, clk, rstn, EN_AUTOCOVER, increment_q ) 
   // If en is asserted, the counter should assert the start flag
   `A_IMPLIES_B_IMMEDIATE( ASSERT, en, start, clk, rstn, EN_AUTOCOVER, en_implies_start ) 
   // Start_delayed is shown one cycle after start is asserted. In other
   // words, start implies start_delayed in the next clock cycle.
   `A_IMPLIES_B_NEXTTIME( ASSERT, start, start_delayed, clk, rstn, EN_AUTOCOVER, start_nexttime_start_delayed)
   
endmodule // counter

