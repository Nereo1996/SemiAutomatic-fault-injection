`timescale 1ns/1ps
module Mem #(parameter
  DATA_WIDTH = 8,
  ADDR_WIDTH = 5,
  RAM_DEPTH  = 1 << ADDR_WIDTH
) (
  input wire                clk,       // clock
  input wire                reset,     // reset
  input wire                REnable_i, // read enable
  input wire                WEnable_i, // write enable
  input wire [DATA_WIDTH-1:0] Data_i,  // data input
  output reg [DATA_WIDTH-1:0] Data_o,  // Data output
  output reg                  Empty_o, // is empty?
  output reg                  Full_o   // is full?
);

// Internal Signals
reg [ADDR_WIDTH-1:0] r_id_;    // read index
reg [ADDR_WIDTH-1:0] w_id_;    // write index
reg [DATA_WIDTH-1:0] mem_ [0:RAM_DEPTH-1]; // memory block
wire [ADDR_WIDTH-1:0] r_next_id_, w_next_id_;

task doReset;
begin
  Empty_o = 1'b1;
  Full_o  = 1'b0;
  Data_o  = 0;
  r_id_   = 0;
  w_id_   = 0;
end
endtask

initial begin

  doReset();

end

always @(posedge clk) begin : Read_Op

	if(reset)
	begin
	end
	else
  if (REnable_i) begin
    Data_o <= mem_[r_id_];
  end

end // end of Read_Op

always @(posedge clk) begin : Write_Op

	if(reset)
	begin
	end
	else
  if (WEnable_i) begin
    mem_[w_id_] <= Data_i;
  end

end // end of Write_Op

assign r_next_id_ = r_id_ + 1;
assign w_next_id_ = w_id_ + 1;

always @(posedge clk) begin : FSM_Seq

  if (reset) begin

    doReset();

  end else begin

  case({REnable_i, WEnable_i})
    // do nothing for 2'b00
    2'b00: begin
      Empty_o <= Empty_o;
      Full_o <= Full_o;
 	end
    2'b10: begin
      if (~Empty_o) begin
        r_id_ <= r_next_id_;
        Full_o <= 1'b0;
        if (r_next_id_ == w_id_) begin
          Empty_o <= 1'b1;
        end
        else
        begin
        	Empty_o <= Empty_o;
        end
      end
      else
      begin
      Empty_o <= Empty_o;
      Full_o <= Full_o;      
      end
    end

    2'b01: begin
      if (~Full_o) begin
        w_id_ <= w_next_id_;
        Empty_o <= 1'b0;
        if (w_next_id_ == r_id_) begin
          Full_o <= 1'b1;
        end
        else
        begin
        Full_o <= Full_o;
        end
      end
      else
      begin
       Empty_o <= Empty_o;
      Full_o <= Full_o;        
      end
    end

    2'b11: begin
      r_id_ <= r_next_id_;
      w_id_ <= w_next_id_;
      Empty_o <= Empty_o;
      Full_o <= Full_o;
    end

  endcase
  end
end // end of FSM_Seq

endmodule // End of Module Mem
