`default_nettype none
`define _SYNTHESIS_
module implies_nexttime #(parameter kind = 1, en_autocover = 1)
   (input wire precond, prop, clk, enable_cond, output reg sample);
   /* Verify that the antecedent of the property
    * is reachable, to prevent vacuous results. */
`ifndef _SYNTHESIS_
   generate
      if (en_autocover == 1)
        always @(posedge clk) begin
           if (enable_cond) check_vacuity_of_implies_nexttime: cover (precond);
        end
   endgenerate
`endif
   // Internal signals
   reg observed_antecedent;
   reg schedule_check;
   always @(*) observed_antecedent <= (precond == 1'b1);
   always @(posedge clk) begin
      if (!enable_cond) schedule_check <= 1'b0;
      else              schedule_check <= observed_antecedent;
   end
   always @(posedge clk) begin
      if (!enable_cond || ! schedule_check) sample <= 1'b0;
      if (enable_cond)
        if (schedule_check) begin
           if (prop) sample <= 1;
        end
   end // always @ (posedge clk)
endmodule // implies_nexttime

