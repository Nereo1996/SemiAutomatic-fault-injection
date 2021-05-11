`timescale 1ns/1ps
module testIO2 #(parameter
  DATA_WIDTH = 8,
  ADDR_WIDTH = 6,
  RAM_DEPTH  = 1 << ADDR_WIDTH,
  CLOCK_CYCLES = 50000
);

reg  ReqR_, ReqW_, clk, tb_clk, reset_;
reg  [DATA_WIDTH-1:0] Data_i;
wire AckR_, AckW_;
wire [DATA_WIDTH-1:0] Data_o;


// set clocks
always begin
  #0.5 clk <= !clk;
  #0.5 Data_i<=Data_i+1;
end

// DUT
IO #(DATA_WIDTH,
  ADDR_WIDTH,
  RAM_DEPTH
) io (
  .clk    (clk),
  .reset  (reset_),
  .ReqW_i (ReqW_),
  .ReqR_i (ReqR_),
  .Data_i (Data_i),
  .AckW_o (AckW_),
  .AckR_o (AckR_),
  .Data_o (Data_o)
);
integer i;
// test cases
initial begin: TEST
  $dumpfile("bridge.vcd");
  $dumpvars(0, testIO2.io);
  clk    <= 0;
  reset_ <= 1;
  ReqR_  <= 0;
  ReqW_  <= 0;
  Data_i <= 0;
  #3;
  reset_ <= 0;
  for (i=0; i < CLOCK_CYCLES; i=i+1) 
  begin
         #2;
  	ReqR_  <= $random;
  	ReqW_  <= $random;
	Data_i <= $random;
  end
  $finish;
end

endmodule