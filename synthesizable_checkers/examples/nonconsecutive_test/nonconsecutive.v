`default_nettype none
`include "checker_lib.vh"

/* Dummy pattern generator, as follows:
 /`````\/`````\/`````\/`````\/`````\/`````\
 x  A  xx  B  xx  B  xx  B  xx  A  xx  C  x
 \.,.../\.,.../\.,.../\.,.../\.,.../\.,.../
 
 The assertions match two non-consecutive 'A' followed by one C */

module nonconsecutive
  (input  wire i_clk, i_rstn,
   output reg 	    o_running,
   output reg [1:0] o_sequence);

   localparam [1:0] idle = 2'b00, a = 2'b01, b = 2'b10, c = 2'b11;
   reg [1:0] 	    ps, ns;
   reg [0:0] 	    count_ps, count_ns; 
   reg [1:0] 	    countb_ps, countb_ns;
   reg 		    clear, en;
   wire 	    visited_a_completed, visited_b_completed;

   /* To avoid failures due overlapping requests,
    * let constrain i_req to be low for more than
    * 8 cycles after beign asserted */
   wire 	    i_req;
   reg [3:0] 	    shift;
   always @(posedge i_clk) begin
      if (!i_rstn) shift <= 4'h0;
      else shift <= ({1'b1, shift[3:1]});
   end
   assign i_req = shift[0];
   
   assign visited_a_completed = (count_ps == 2'b01);
   assign visited_b_completed = (countb_ps == 2'b10);
   
   always @(posedge i_clk) begin
      if (!i_rstn) begin 
	 ps <= idle;
	 count_ps <= 2'd0;
	 countb_ps <= 2'd0;
      end
      else begin         
	 ps <= ns;
	 count_ps <= count_ns;
	 countb_ps <= countb_ns;
      end
   end
   
   always @(*) begin
      countb_ns <= countb_ps;
      count_ns <= count_ps;
      ns <= ps;
      
      case (ps)
	idle: begin
	   if (i_req) ns <= a;
	   else       ns <= idle;
	end
	a: begin 
	   if (visited_a_completed) begin
	      ns <= c;
	      count_ns <= 2'b0;
	   end
	   else begin
	      count_ns <= count_ps + 1'b1;
	      ns <= b;
	   end
	end
	b: begin
	   if (visited_b_completed) begin
	      ns <= a;
	      countb_ns <= 2'b0;
	   end
	   else begin
	      countb_ns <= countb_ps + 1'b1;
	      ns <= b;
	   end
	end // case: b
	c: begin
	   ns <= idle;
	end
	default: ns <= idle;
      endcase // case (ps)
   end // always @ (*)
   
   always @(posedge i_clk) begin
      o_running <= 1'b0;
      case (ps)
	idle: begin
	   o_sequence <= idle;
	end
	a: begin
	   o_sequence <= a;
	   o_running <= 1'b1;
	end
	b: begin
	   o_sequence <= b;
	   o_running <= 1'b1;
	end
	c: begin
	   o_sequence <= c;
	   o_running <= 1'b1;
	end
      endcase // case (ps)
   end // always @ (posedge i_clk)
   
   // Formal testbench
   always @(*)
     // The system task $initstate evaluates to 1 in the initial state and to 0 otherwise.
     prepare_reset: assume (i_rstn == !$initstate);
   
   reg A, C;
   always @(*) begin
      A <= (o_sequence == a);
      C <= (o_sequence == c);
   end
   
   `NONCONSECUTIVE_A_FOLLOWED_BY_B( ASSERT, i_req, A, 2, C, i_clk, i_rstn, EN_AUTOCOVER, complex_goto_seq ) 
endmodule // nonconsecutive


