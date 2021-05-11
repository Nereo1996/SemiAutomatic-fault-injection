`timescale 1ns/1ps

module my_memory(
	clka,
	dina,
	addra,
	ena,
	wea,
	douta);


input clka;
input [7 : 0] dina;
input [9 : 0] addra;
input ena;
input [0 : 0] wea;
output [7 : 0] douta;

reg [7:0] douta;

reg [7:0] data[0:1023];

initial
begin	:init
	integer i;
	for(i=0;i<1024;i=i+1)
		data[i]=0;
data[0]='h29;
data[1]='hF6;
data[2]='h29;
data[3]='hC0;
data[4]='h29;
data[5]='hDB;
data[6]='h8B;
data[7]='h56;
data[8]='h1A;
data[9]='h01;
data[10]='hD0;
data[11]='h01;
data[12]='hC3;
data[13]='h89;
data[14]='hC1;
data[15]='h8B;
data[16]='h56;
data[17]='h1E;
data[18]='h29;
data[19]='hD1;
data[20]='h89;
data[21]='h5E;
data[22]='hF0;
data[23]='h75;
data[24]='hED;
data[25]='hF4;
data[26]='h01;
data[27]='h00;
data[28]='h00;
data[29]='h00;
data[30]='h0A;
data[31]='h00;
data[32]='h00;
data[33]='h00;
data[34]='h00;
end

always @(posedge clka)
begin
	if(ena)
		if(wea)
		begin
			data[addra]<=dina;
		end
		else
		begin
			douta<=data[addra];
		end
end


endmodule
`timescale 1ns / 1ps

module memory(input clk, input rst,
              input [31:0] data_in, input [31:0] addr,
				  input RE, input WE, 
				  output [31:0] data_out,
				  output [31:0] magic_out);
				  
  localparam [9:0] magic_location = 'hFFFFFFF0;
  reg [31:0] magic_buffer;
  
  assign magic_out = magic_buffer;
  
  reg [7:0] bufr[3:0];
  reg [7:0] bufw[3:0];
  
  reg [2:0] inx;
  wire [9:0] b_addr;
  
  wire [7:0] mem_in;
  wire [7:0] mem_out;
  
  reg r_b, w_b;
  
  always @(posedge clk) begin
    if(rst) begin
	   inx=0; r_b=0; w_b=0;
    end 
	 else if(r_b) begin
		bufr[inx-1]=mem_out;
		inx=inx+1;
		if(inx==5) begin r_b=0; inx=0; end
	 end 
	 else if(w_b) begin
		inx=inx+1;
		if(inx==4) begin w_b=0; inx=0; end
    end 
	 else if(RE) begin
	   inx=1;
		r_b=1;
	 end
	 else if(WE) begin
	   inx=0;
		bufw[3]<=data_in[31:24];
		bufw[2]<=data_in[23:16];
		bufw[1]<=data_in[15:8];
		bufw[0]<=data_in[7:0];
		if(b_addr==magic_location) magic_buffer = data_in;
		w_b=1;
	 end
  end
  
  assign mem_in = bufw[inx];
  assign b_addr = addr+inx;
  
  my_memory mem(clk, mem_in, b_addr, RE || WE || r_b || w_b, WE || w_b, mem_out);
  
  assign data_out = { bufr[3], bufr[2], bufr[1], bufr[0] };

endmodule
`timescale 1ns / 1ps

module divider(input clk, input rst, output reg div_clk);

  reg [1:0] buffer;
  
  initial
  begin
	div_clk<=0; 
	buffer=0;	
  end

  always @(posedge clk) 
  begin
      buffer=buffer+1;
      if(buffer==0) 
	div_clk <= !div_clk;
  end
  
endmodule
`timescale 1ns / 1ps

module testbench();

  reg clk = 0;
  always #1 clk = !clk;
  
  wire [31:0] addr, data_in, data_out;
  wire WE, RE;
  reg rst;
  wire div_clk;
  wire [31:0] magic_value;
  wire [7:0] opcode;

  divider div(clk, rst, div_clk);
  memory mem(clk, rst, data_out, addr, RE, WE, data_in, magic_value);
  y86_seq y86(div_clk, rst, addr, data_in, data_out, WE, RE, opcode);
  
  initial begin
		$dumpfile("y86_seq.vcd");
		$dumpvars(0, testbench.y86);
    rst=1; #10 rst=0;
  end

endmodule
