/********************
* Filename:	    LBDR.v
* Description:  LBDR with minimal support only (no deroutes and no forks). The input is 8 routing bits, two per output port, and 4 connectivity bits, one per output port
*
* $Revision: 25 $
* $Id: LBDR.v 25 2015-11-21 13:19:20Z ranga $
* $Date: 2015-11-21 15:19:20 +0200 (Sat, 21 Nov 2015) $
* $Author: ranga $
*********************/

`include "../include/parameters.v"

module LBDR(clk, rst,
            empty,
            Rxy_rst, Cx_rst, 
            flit_id, dst_addr, cur_addr_rst,
            Nport, Eport, Wport, Sport, Lport
            );
            
  input clk, rst;
  input empty;
  input [7:0] Rxy_rst;
  input [3:0] Cx_rst;
  input [2:0] flit_id;
  input [3:0] dst_addr, cur_addr_rst;
  
  output reg Nport, Wport, Eport, Sport, Lport;
  
  // Declaring the local variables
  reg [7:0] Rxy;
  reg [3:0] Cx;
  reg [3:0] cur_addr;

  // Assigning the Routing bits for 8 quadrants
  wire Rne = Rxy[0];
  wire Rnw = Rxy[1];
  wire Ren = Rxy[2];
  wire Res = Rxy[3];
  wire Rwn = Rxy[4];
  wire Rws = Rxy[5];
  wire Rse = Rxy[6];
  wire Rsw = Rxy[7];
  
  // Assigning the Connecting bits for 4 connections
  wire Cn = Cx[0];
  wire Ce = Cx[1];
  wire Cw = Cx[2];
  wire Cs = Cx[3];
  
  // Assigning the current and destination for XY co-ordinates
  wire [1:0] x_cur = cur_addr[1:0];
  wire [1:0] y_cur = cur_addr[3:2];
  wire [1:0] x_dst = dst_addr[1:0];
  wire [1:0] y_dst = dst_addr[3:2];
  
  always @ (posedge clk) begin
    if (rst) begin
      Rxy      <= Rxy_rst;
      Cx       <= Cx_rst;
      cur_addr <= cur_addr_rst;
    end
  end
  
  // Logic 1 -- Comparator logic checks the XY co-ordinates for current and destination and assigns the respective direction
  wire N1 = y_dst < y_cur;
  wire E1 = x_cur < x_dst;
  wire W1 = x_dst < x_cur;
  wire S1 = y_cur < y_dst;
  
  // Logic 2 -- The final output port direction based on the comparator logic and Routing, connecting bits
  // LBDR routing logic works on HEADER flit alone and it maintains the same port direction for PAYLOAD and TAIL flit of the same packet, until a new HEADER flit arrives
  
  always @ (posedge clk) begin
    if (rst || empty) begin
      {Nport, Eport, Wport, Sport, Lport} <= 0;
    end
    else if (flit_id == `HEADER) begin
      Nport <= ((N1 & ~E1 & ~W1) | (N1 & E1 & Rne) | (N1 & W1 & Rnw)) & Cn;
      Eport <= ((E1 & ~N1 & ~S1) | (E1 & N1 & Ren) | (E1 & S1 & Res)) & Ce;
      Wport <= ((W1 & ~N1 & ~S1) | (W1 & N1 & Rwn) | (W1 & S1 & Rws)) & Cw;
      Sport <= ((S1 & ~E1 & ~W1) | (S1 & E1 & Rse) | (S1 & W1 & Rsw)) & Cs;
      Lport <= ~N1 & ~ E1 & ~W1 & ~S1;
	  end
  end
 
endmodule