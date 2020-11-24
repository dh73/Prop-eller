`default_nettype none
`include "checker_lib.vh"

module athenb (input wire clk, rstn,
	       output wire delayed_rst, output reg trigger);
   
   reg [1:0] 		   rst_dly;
   always @(posedge clk) begin
      if (!rstn) rst_dly <= 2'b00;
      else rst_dly <= {1'b1, rst_dly[1]};
   end
   
   assign delayed_rst = rst_dly[1];
   
   always @*
     // The system task $initstate evaluates to 1 in the initial state and to 0 otherwise.
     prepare_reset: assume (rstn == !$initstate);
   
   // The delayed_rst is always asserted in te next clock cycle after reset is
   // deasserted.
   `A_IMPLIES_B_NEXTTIME( COVER, rstn, delayed_rst, clk, rstn, EN_AUTOCOVER, en_then_y)
`endif
endmodule // athenb
