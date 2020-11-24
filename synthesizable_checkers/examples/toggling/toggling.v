`default_nettype none
`include "checker_lib.vh"

module toggling (input wire clk, rstn, output wire state);
   reg tmp;
   reg tmpns;
   always @(posedge clk) begin
      if (!rstn) tmp <= 1'b0;
      else       tmp <= tmpns;
   end
   always @(*) begin
      tmpns <= !tmp;
   end
   assign state = tmp;
   always @*
     // The system task $initstate evaluates to 1 in the initial state and to 0 otherwise.
     prepare_reset: assume (rstn == !$initstate);   
   
   // the 'state' output changes (toggles) its value each clock cycle 
   `A_IMPLIES_CHANGED_B_NEXTTIME( COVER, 1'b1, state, 1, clk, rstn, EN_AUTOCOVER, toggling )
endmodule // toggling
