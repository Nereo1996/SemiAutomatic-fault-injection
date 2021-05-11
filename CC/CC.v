
`include "fault_injection.v"
//`include "fp.v"

`define fp 2

module CC  (
  input wire                   clk,    
  input wire                   reset,  
  input wire                   enable, 
  output wire [7:0] out  // data to read
);


reg [7:0] count;

assign out = count;


`GENERATE_FAULT_INJECTION_FUNCTION(faultinj1, 1)

always @(posedge clk) begin

	if (reset) begin
		count <= 0;
	end 
	//else if(enable)
	else if(faultinj1(enable, 0, 1))
	begin 
		count<=count+1;
	end

end 

endmodule

