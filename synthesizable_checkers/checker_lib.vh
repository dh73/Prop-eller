/*
 *  Versatile Formal Checkers for SymbiYosys 
 *
 *  Copyright (C) 2020  Diego Hernandez <diego@symbioticeda.com>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */
`default_nettype none
///////////////////////////////////////////////////////////////////////////////
/*									     *
 *  \----------------------------------\				     *
 *   \					\	 __			     *
 *    \	  Versatile Formal Checkers      \	 | \			     *
 *     >  Part of Prop-peller package     >------|  \	    ______	     *
 *    /					 /	 --- \_____/**|_|_\____	 |   *
 *   /					/	   \_______ --------- __>-}  *
 *  /----------------------------------/		 \_____|_____/	 |   *
 *							      	             *
 *									     */
///////////////////////////////////////////////////////////////////////////////
/* The following parameter names are used to define 
 * the type of check (validity [assert], satisfiability [cover]
 * or constraint [assume/restrict]. As well as the enable/disable
 * of the vacuity check for each checker. 
 * Please refer to the Versatile Formal Checkers User Guide
 * or Quick Start Guide for more information. */
localparam [1:0] ASSERT = 2'b00, COVER = 2'b1, ASSUME = 2'b10, RESTRICT = 2'b11;
localparam [0:0] DIS_AUTOCOVER = 1'b0, EN_AUTOCOVER = 1'b1;
///////////////////////////////////////////////////////////////////////////////
/*									     *
 *  \----------------------------------\				     *
 *   \					\	 __			     *
 *    \	                                 \	 | \			     *
 *     >       Invariants                 >------|  \	    ______	     *
 *    /					 /	 --- \_____/**|_|_\____	 |   *
 *   /					/	   \_______ --------- __>-}  *
 *  /----------------------------------/		 \_____|_____/	 |   *
 *							      	             *
 *									     */
///////////////////////////////////////////////////////////////////////////////
/*  Semantics:
 * G (prop)
 * assert (always (prop)) */
module always_prop #(parameter kind = 1)
   (input wire prop, clk, enable_cond);
   reg always_inv;
   always @(*) always_inv <= prop;
   always @(posedge clk) begin
      if (enable_cond) begin
	 case (kind)
	   ASSERT:   assert_always:   assert (always_inv);
	   COVER:    cover_always:    cover (always_inv);
	   ASSUME:   assume_always:   assume (always_inv);
	   RESTRICT: restrict_always: restrict property (always_inv);
	 endcase // case (kind)
      end
   end
endmodule // always_prop
///////////////////////////////////////////////////////////////////////////////
/*  Semantics:
 * G (¬prop)
 * assert (always (not prop)) */
module never #(parameter kind = 1)
   (input wire prop, clk, enable_cond);
   reg never_prop;
   always @(*) never_prop <=  !(prop);
   always @(posedge clk) begin
      if (enable_cond) begin
	 case (kind)
	   ASSERT:   assert_never:   assert (never_prop);
	   COVER:    cover_never:    cover (never_prop);
	   ASSUME:   assume_never:   assume (never_prop);
	   RESTRICT: restrict_never: restrict property (never_prop);
	 endcase // case (kind)
      end
   end
endmodule // never
///////////////////////////////////////////////////////////////////////////////
/*									     *
 *  \----------------------------------\				     *
 *   \					\	 __			     *
 *    \	                                 \	 | \			     *
 *     >       Suffix Implication         >------|  \	    ______	     *
 *    /					 /	 --- \_____/**|_|_\____	 |   *
 *   /					/	   \_______ --------- __>-}  *
 *  /----------------------------------/		 \_____|_____/	 |   *
 *							      	             *
 *									     */
///////////////////////////////////////////////////////////////////////////////
/* Semantics:
 * G (precond => prop)
 * assert (always (precond |-> prop)) */
module implies_immediate #(parameter kind = 1, en_autocover = 1)
   (input wire precond, prop, clk, enable_cond);
   /* Verify that the antecedent of the property
    * is reachable, to prevent vacuous results. */
   generate
      if (en_autocover == 1 && kind != COVER)
	always @(posedge clk) begin
	   if (enable_cond) check_vacuity_of_implies_immediate: cover (precond);
	end
   endgenerate
   // Internal variables
   reg observed_antecedent;
   always @(*) observed_antecedent <= (precond == 1'b1);
   always @(posedge clk) begin
      if (enable_cond)
	if (observed_antecedent)  begin
	   case (kind)
	     ASSERT:   assert_implies_immediate:   assert (prop);
	     COVER:    cover_implies_immediate:    cover (prop);
	     ASSUME:   assume_implies_immediate:   assume (prop);
	     RESTRICT: restrict_implies_immediate: restrict property (prop);
	     endcase // case (kind)
	end
   end // always @ (posedge clk)
endmodule // implies_immediate
///////////////////////////////////////////////////////////////////////////////
/* Semantics:
 * G (precond => (X(prop)))
 * assert (always (precond |-> ##1 prop)) */
module implies_nexttime #(parameter kind = 1, en_autocover = 1)
   (input wire precond, prop, clk, enable_cond);
   /* Verify that the antecedent of the property
    * is reachable, to prevent vacuous results. */
   generate
      if (en_autocover == 1 && kind != COVER)
	always @(posedge clk) begin
	   if (enable_cond) check_vacuity_of_implies_nexttime: cover (precond);
	end
   endgenerate
   // Internal signals
   reg observed_antecedent;
   reg schedule_check;
   always @(*) observed_antecedent <= (precond == 1'b1);
   always @(posedge clk) begin
      if (!enable_cond) schedule_check <= 1'b0;
      else              schedule_check <= observed_antecedent;
   end
   always @(posedge clk) begin
      if (enable_cond)
	if (schedule_check) begin
	   case (kind)
	     ASSERT:   assert_implies_nexttime:   assert (prop);
	     COVER:    cover_implies_nexttime:    cover (prop);
	     ASSUME:   assume_implies_nexttime:   assume (prop);
	     RESTRICT: restrict_implies_nexttime: restrict property (prop);
	   endcase // case (kind)
	end
   end // always @ (posedge clk) 
endmodule // implies_nexttime
///////////////////////////////////////////////////////////////////////////////
module implies_stable_nexttime #(parameter kind = 1, en_autocover = 1, width = 8)
   (input wire precond, input wire [width-1:0] prop, 
    input wire clk, enable_cond);
   /* Verify that the antecedent of the property
    * is reachable, to prevent vacuous results. */
   generate
      if (en_autocover == 1 && kind != COVER)
	always @(posedge clk) begin
	   if (enable_cond) check_vacuity_of_implies_stable_nexttime: cover (precond);
	end
   endgenerate
   // Internal signals
   reg [width-1:0] observed_antecedent_value;
   reg observed_antecedent;
   reg schedule_check;
   reg unchanged_value;
   always @(*) observed_antecedent <= (precond == 1'b1);
   always @(*) unchanged_value <= (prop == observed_antecedent_value);
   always @(posedge clk) begin
      if (!enable_cond) begin 
	 schedule_check <= 1'b0;
	 observed_antecedent_value <= 1'b0;
      end
      else begin 
	 schedule_check <= observed_antecedent;
	 observed_antecedent_value <= prop;	 
      end
   end
   always @(posedge clk) begin
      if (enable_cond)
	if (schedule_check) begin
	   case (kind)
	     ASSERT:   assert_implies_stable_nexttime:   assert (unchanged_value);
	     COVER:    cover_implies_stable_nexttime:    cover (unchanged_value);
	     ASSUME:   assume_implies_stable_nexttime:   assume (unchanged_value);
	     RESTRICT: restrict_implies_stable_nexttime: restrict property (unchanged_value);
	   endcase // case (kind)
	end
   end // always @ (posedge clk) 
endmodule // implies_stable_nexttime
///////////////////////////////////////////////////////////////////////////////
module implies_changed_nexttime #(parameter kind = 1, en_autocover = 1, width = 8)
   (input wire precond, input wire [width-1:0] prop, 
    input wire clk, enable_cond);
   /* Verify that the antecedent of the property
    * is reachable, to prevent vacuous results. */
   generate
      if (en_autocover == 1 && kind != COVER)
	always @(posedge clk) begin
	   if (enable_cond) check_vacuity_of_implies_changed__nexttime: cover (precond);
	end
   endgenerate
   // Internal signals
   reg [width-1:0] observed_antecedent_value;
   reg observed_antecedent;
   reg schedule_check;
   reg changed_value;
   always @(*) observed_antecedent <= (precond == 1'b1);
   always @(*) changed_value <= (prop != observed_antecedent_value);
   always @(posedge clk) begin
      if (!enable_cond) begin 
	 schedule_check <= 1'b0;
	 observed_antecedent_value <= 1'b0;
      end
      else begin 
	 schedule_check <= observed_antecedent;
	 observed_antecedent_value <= prop;	 
      end
   end
   always @(posedge clk) begin
      if (enable_cond)
	if (schedule_check) begin
	   case (kind)
	     ASSERT:   assert_implies_changed_nexttime:   assert (changed_value);
	     COVER:    cover_implies_changed_nexttime:    cover (changed_value);
	     ASSUME:   assume_implies_changed_nexttime:   assume (changed_value);
	     RESTRICT: restrict_implies_changed_nexttime: restrict property (changed_value);
	   endcase // case (kind)
	end
   end // always @ (posedge clk) 
endmodule // implies_changed_nexttime
///////////////////////////////////////////////////////////////////////////////
module implies_increment #(parameter kind = 1, en_autocover = 1, width = 8)
   (input wire precond, input wire [width-1:0] prop, 
    input wire clk, enable_cond);
   /* Verify that the antecedent of the property
    * is reachable, to prevent vacuous results. */
   generate
      if (en_autocover == 1 && kind != COVER)
	always @(posedge clk) begin
	   if (enable_cond) check_vacuity_of_implies_increment: cover (precond);
	end
   endgenerate
   // Internal signals
   reg [width-1:0] observed_antecedent_value;
   reg 		   observed_antecedent;
   reg 		   schedule_check;
   reg 		   changed_value;
   reg 		   incremented;
   always @(*) observed_antecedent <= (precond == 1'b1);
   always @(*) begin 
      changed_value <= (prop != observed_antecedent_value);
      incremented <= (changed_value && (prop - observed_antecedent_value == 1'b1));
   end
   always @(posedge clk) begin
      if (!enable_cond) begin 
	 schedule_check <= 1'b0;
	 observed_antecedent_value <= 1'b0;
      end
      else begin
	 schedule_check <= observed_antecedent;
	 observed_antecedent_value <= prop;	 
      end
   end
   always @(posedge clk) begin
      if (enable_cond)
	if (schedule_check) begin
	   case (kind)
	     ASSERT:   assert_implies_increment:   assert (incremented);
	     COVER:    cover_implies_increment:    cover (incremented);
	     ASSUME:   assume_implies_increment:   assume (incremented);
	     RESTRICT: restrict_implies_increment: restrict property (incremented);
	   endcase // case (kind)
	end
   end // always @ (posedge clk) 
endmodule // implies_increment
///////////////////////////////////////////////////////////////////////////////
module implies_decrement #(parameter kind = 1, en_autocover = 1, width = 8)
   (input wire precond, input wire [width-1:0] prop, 
    input wire clk, enable_cond);
   /* Verify that the antecedent of the property
    * is reachable, to prevent vacuous results. */
   generate
      if (en_autocover == 1 && kind != COVER)
	always @(posedge clk) begin
	   if (enable_cond) check_vacuity_of_implies_decrement: cover (precond);
	end
   endgenerate
   // Internal signals
   reg [width-1:0] observed_antecedent_value;
   reg 		   observed_antecedent;
   reg 		   schedule_check;
   reg 		   changed_value;
   reg 		   decremented;
   always @(*) observed_antecedent <= (precond == 1'b1);
   always @(*) begin 
      changed_value <= (prop != observed_antecedent_value);
      decremented <= (changed_value && (observed_antecedent_value - prop == 1'b1));
   end
   always @(posedge clk) begin
      if (!enable_cond) begin 
	 schedule_check <= 1'b0;
	 observed_antecedent_value <= 1'b0;
      end
      else begin
	 schedule_check <= observed_antecedent;
	 observed_antecedent_value <= prop;	 
      end
   end
   always @(posedge clk) begin
      if (enable_cond)
	if (schedule_check) begin
	   case (kind)
	     ASSERT:   assert_implies_decrement:   assert (decremented);
	     COVER:    cover_implies_decrement:    cover (decremented);
	     ASSUME:   assume_implies_decrement:   assume (decremented);
	     RESTRICT: restrict_implies_decrement: restrict property (decremented);
	   endcase // case (kind)
	end
   end // always @ (posedge clk) 
endmodule // implies_decrement
///////////////////////////////////////////////////////////////////////////////
/*									     *
 *  \----------------------------------\				     *
 *   \					\	 __			     *
 *    \	                                 \	 | \			     *
 *     >       Sequence Repetition        >------|  \	    ______	     *
 *    /					 /	 --- \_____/**|_|_\____	 |   *
 *   /					/	   \_______ --------- __>-}  *
 *  /----------------------------------/		 \_____|_____/	 |   *
 *							      	             *
 *									     */
///////////////////////////////////////////////////////////////////////////////
/* Semantics:
 * Defining the goto operator (¬b*b n times) as b[->n], 
 * G (trigger => X(non_consecutive_event[->n] (X (following_event))))
 * assert (always trigger |-> ##1 (non_consecutive_event[->n] ##1 following_event)
 */ 
module goto_operator_n #(parameter n = 2, kind = 1, en_autocover = 1)
   (input wire trigger, non_consecutive_event, following_event, clk, enable_cond);
   /* Verify that the antecedent of the property
    * is reachable, to prevent vacuous results. */
   generate
      if (en_autocover == 1 && kind != COVER)
	always @(posedge clk) begin
	   if (enable_cond) check_vacuity_of_goto_n: cover (trigger);
	end
   endgenerate
   // Internal signals
   reg [n-1:0] non_consecutive_event_count;
   reg 	       triggered;
   reg 	       fire_check;
   always @(posedge clk) begin
      if (!enable_cond) begin
	 non_consecutive_event_count <= ({n{1'b0}});
         triggered <= 1'b0;
      end
      else begin
	 if (non_consecutive_event_count == n && following_event) begin
	    non_consecutive_event_count <= ({n{1'b0}});
	    triggered <= 1'b0;
	 end
	 else if (triggered && non_consecutive_event) 
	   non_consecutive_event_count <= non_consecutive_event_count + 1'b1;
	 else if (trigger) 
	   triggered <= 1'b1;
      end // else: !if(!enable_cond)
   end // always @ (posedge clk)
   
   always @(*) begin
      if (enable_cond) begin
	 if (non_consecutive_event_count == n) begin
	    case (kind)
	      ASSERT:   assert_goto_n:   assert (following_event);
	      COVER:    cover_goto_n:    cover (following_event);
	      ASSUME:   assume_goto_n:   assume (following_event);
	      RESTRICT: restrict_goto_n: restrict property (following_event);
	    endcase
	 end
      end
   end
endmodule // goto_operator_n
///////////////////////////////////////////////////////////////////////////////
/*									     *
 *  \----------------------------------\				     *
 *   \					\	 __			     *
 *    \	                                 \	 | \			     *
 *     >       Definitions                >------|  \	    ______	     *
 *    /					 /	 --- \_____/**|_|_\____	 |   *
 *   /					/	   \_______ --------- __>-}  *
 *  /----------------------------------/		 \_____|_____/	 |   *
 *							      	             *
 *									     */
///////////////////////////////////////////////////////////////////////////////
// Invariants
`define NEVER_A( kind, prop, clk, enable_cond, ident ) \
  never #(kind) ident (prop, clk, enable_cond);
`define ALWAYS_A( kind, prop, clk, enable_cond, ident ) \
  always_prop #(kind) ident (prop, clk, enable_cond);
// Suffix implication
`define A_IMPLIES_B_IMMEDIATE( kind, precond, prop, clk, enable_cond, autocover, ident ) \
  implies_immediate #(kind, autocover) ident (precond, prop, clk, enable_cond);
`define A_IMPLIES_B_NEXTTIME( kind, precond, prop, clk, enable_cond, autocover, ident ) \
  implies_nexttime #(kind, autocover) ident (precond, prop, clk, enable_cond);
`define A_IMPLIES_STABLE_B_NEXTTIME( kind, precond, prop, width, clk, enable_cond, autocover, ident )\
  implies_stable_nexttime #(kind, autocover, width) ident (precond, prop, clk, enable_cond);
`define A_IMPLIES_CHANGED_B_NEXTTIME( kind, precond, prop, width, clk, enable_cond, autocover, ident )\
  implies_changed_nexttime #(kind, autocover, width) ident (precond, prop, clk, enable_cond);
`define A_IMPLIES_INCREMENT_B( kind, precond, prop, width, clk, enable_cond, autocover, ident )\
  implies_increment #(kind, autocover, width) ident (precond, prop, clk, enable_cond);
`define A_IMPLIES_DECREMENT_B( kind, precond, prop, width, clk, enable_cond, autocover, ident )\
  implies_decrement #(kind, autocover, width) ident (precond, prop, clk, enable_cond);
// Sequence repetition
`define NONCONSECUTIVE_A_FOLLOWED_BY_B( kind, trigger, a, n, b, clk, enable_cond, autocover, ident ) \
  goto_operator_n #(n, kind, autocover) ident (trigger, a, b, clk, enable_cond);
///////////////////////////////////////////////////////////////////////////////
 
