`default_nettype none
`include "checker_lib.vh"

module non_overlapping (input wire clk, rstn, req,
			output reg gnt);

   always @*
     // The system task $initstate evaluates to 1 in the initial state and to 0 otherwise.
     prepare_reset: assume (rstn == !$initstate);
   
   always @(posedge clk) begin
      if (!rstn || !req) gnt <= 1'b0;
      else if (req) gnt <= 1'b1;
   end

   // If gnt is asserted, it should be released in the next clock cycle
   `A_IMPLIES_B_NEXTTIME( COVER, req, gnt, clk, rstn, EN_AUTOCOVER, next_gnt_low)
endmodule // non_overlapping
