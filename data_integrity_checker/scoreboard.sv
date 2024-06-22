`default_nettype none
module scoreboard #(parameter DATA_WIDTH=8, ITEMS=12)
   (input wire                    in_clk,
    input wire 			  rstn,
    input wire 			  in_valid,
    input wire [DATA_WIDTH-1:0]   in_data,
    input wire 			  out_clk,
    input wire 			  out_valid,
    output logic [DATA_WIDTH-1:0] out_data,
    output logic 		  full,
    output logic 		  empty);

   localparam CNT_WIDTH = (ITEMS > 1) ? $clog2(ITEMS) : 1;

   typedef struct 		  packed {
      logic 			  valid;
      logic [DATA_WIDTH-1:0] 	  data;
   } pipe_t;
   pipe_t [0:ITEMS-1] data_ps, data_ns;

   logic [DATA_WIDTH-1:0] 	  read_data_ns, read_data_ps;
   logic 			  full_ps, full_ns;
   logic 			  empty_ps, empty_ns;
   assign full = full_ps;
   assign empty = empty_ps;
   assign out_data = read_data_ns;

   always_comb begin
      pipe_t \-> ;
      data_ns = data_ps;
      read_data_ns = read_data_ps;
      full_ns = full_ps;
      empty_ns = empty_ps;

      // Read part
      for(int i = ITEMS-1; i >= 0; i--) begin
	 \->  = data_ns[i];
	 if(\-> .valid) begin
	    if(out_valid) begin
	       \-> .valid = 1'b0;
	       data_ns[i].valid = 1'b0;
	       read_data_ns = \-> .data;
	       break;
	    end
	 end
	 data_ns[i] = \-> ;
      end

      // Write part
      \->  = {in_valid, in_data};
      foreach(data_ns[i]) begin
	 if(\-> .valid && !full_ps)
	   {data_ns[i], \-> } = {\-> , data_ns[i]};
      end

      foreach(data_ns[i]) begin
	 empty_ns = 1'b1;
	 if( |data_ns[i].valid ) begin
	    empty_ns = 1'b0;
	    break;
	 end
      end // foreach (data_ns[i])

      foreach(data_ns[i]) begin
	 full_ns = 1'b1;
	 if (!data_ns[i].valid) begin
	    full_ns = 1'b0;
	    break;
	 end
      end
   end // always_comb

   always_ff @(posedge in_clk) begin
      if(!rstn) begin
	 data_ps <= '{default:0};
	 full_ps <= 1'b0;
	 empty_ps <= 1'b1;
      end else begin
	 data_ps <= data_ns;
	 full_ps <= full_ns;
	 empty_ps <= empty_ns;
      end
   end

   always_ff @(posedge out_clk) begin
      if(!rstn) begin
	 read_data_ps <= '0;
      end else begin
	 read_data_ps <= read_data_ns;
      end
   end
endmodule // scoreboard
`default_nettype wire

