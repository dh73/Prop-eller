`default_nettype none
checker cache_chk
  (logic clk = 0,
   logic rst = 0,
   logic valid = 0,
   logic write = 0,
   untyped address,
   untyped wdata,
   untyped rdata,
   logic hit,
   untyped index_bits,
   untyped tag_bits);

   default clocking fpv_clk @(posedge clk); endclocking
   default disable iff(rst);

   // Looking at a single cache line, for all cache lines
   bit [$bits(address)-1:0] selected_addr;
   asm0: assume property($stable(selected_addr));
   logic [index_bits-1:0] selected_index;
   assign selected_index = selected_addr[index_bits-1:0];

   // Original index and tag bits
   logic [index_bits-1:0] index;
   assign index = address[index_bits-1:0];
   logic [tag_bits-1:0] tag;
   assign tag  = address[$bits(address)-1:index_bits];

   // Update checker
   var logic [$bits(wdata)-1:0] h_data;
   var logic [tag_bits-1:0] h_tag;
   logic wr_seen;
   let write_valid = valid & write & selected_index == index;
   always_ff @(posedge clk) begin
      if(rst) begin
         h_data <= '0;
	 wr_seen <= '0;
	 h_tag <= '0;
      end else if(write_valid) begin
	 h_data <= wdata;
	 wr_seen <= '1;
	 h_tag <= tag;
      end
   end

   let read_valid = wr_seen & valid & ~write & selected_index == index & tag == h_tag;
   am0: assert property(read_valid |=> h_data == rdata);
   am1: assert property(read_valid |=> hit);
   cm0: cover property(wr_seen && valid && !write && selected_index == index #=# !hit);

   covergroup foo @(posedge clk);
      data: coverpoint rdata iff ($past(read_valid && !rst));
      ad:   coverpoint address iff (write_valid && !rst);
      option.per_instance = 1;
   endgroup // foo
   foo foo_cg = new();
endchecker // cache_chk

module cache #(
    parameter ADDR_SIZE = 4,  // Total address size
    parameter DATA_WIDTH = 8, // Data width
    parameter INDEX_BITS = 2, // Bits used for indexing into the cache
    parameter TAG_BITS = ADDR_SIZE - INDEX_BITS // Remaining bits used for tag
)(
    input wire clk,
    input wire rst,
    input wire valid,                  // Valid input signal for read/write operation
    input wire write,                  // Write enable (1 for write, 0 for read)
    input wire [ADDR_SIZE-1:0] address,// Memory address
    input wire [DATA_WIDTH-1:0] wdata, // Data to write
    output reg [DATA_WIDTH-1:0] rdata, // Data read from cache
    output reg hit                     // Cache hit signal
);

    typedef struct packed {
        bit valid;
        bit [TAG_BITS-1:0] tag;
        bit [DATA_WIDTH-1:0] data;
    } cache_line_t;

    cache_line_t cache_mem[0:(1<<INDEX_BITS)-1];

   wire [INDEX_BITS-1:0] index = address[INDEX_BITS-1:0];
   wire [TAG_BITS-1:0] tag = address[ADDR_SIZE-1:INDEX_BITS];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < (1<<INDEX_BITS); i++) begin
                cache_mem[i].valid <= 0;
            end
        end
        else if (valid) begin
            if (write) begin
                cache_mem[index].valid <= '1;
                cache_mem[index].tag <= tag;
                cache_mem[index].data <= wdata;
            end
            else begin
                if (cache_mem[index].valid && cache_mem[index].tag == tag) begin
                    hit <= 1;
                    rdata <= cache_mem[index].data;
                end
                else begin
                    hit <= 0;
                end
            end
        end
    end
endmodule // cache
bind cache cache_chk test (.*, .index_bits(2), .tag_bits(2));
`default_nettype wire

