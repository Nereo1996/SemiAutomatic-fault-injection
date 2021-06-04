/********************
* Filename:     bfm_arbiter.v
* Description:  Bus functional model to check the functionality of Arbiter which decides which of the Input port buffer gets the highest priority among the others. Arbitration is based on Round-Robin Scheduling policy with the last served as least priority. Priority direction Local, North, East, South, West
*
* $Revision: 26 $
* $Id: bfm_arbiter.v 26 2015-11-22 19:24:28Z ranga $
* $Date: 2015-11-22 21:24:28 +0200 (Sun, 22 Nov 2015) $
* $Author: ranga $
*********************/
`include "../include/parameters.v"
`include "../include/state_defines.v"

module bfm_arbiter(bfm_clk, bfm_command, bfm_grant);

  input bfm_clk;
  input [5:0] bfm_command;
  
  output reg bfm_grant;
  
  // Declaring the port variables for DUT
  wire        clk;
  
  reg         rst;
  reg [2:0]   Lflit_id, Nflit_id, Eflit_id, Wflit_id, Sflit_id;
  reg [11:0]  Llength, Nlength, Elength, Wlength, Slength;
  reg         Lreq, Nreq, Ereq, Wreq, Sreq;
  
  wire [5:0] nextstate;
  
  // Specifying timeout period
  parameter TIMEOUT = 5;
  integer loop;
  
  always @(negedge clk) begin
    if(!rst) begin
      {Lflit_id, Nflit_id, Eflit_id, Wflit_id, Sflit_id} = {`HEADER, `HEADER, `HEADER, `HEADER, `HEADER};
      Llength = TIMEOUT;
      Nlength = TIMEOUT;
      Elength = TIMEOUT;
      Wlength = TIMEOUT;
      Slength = TIMEOUT;
      for(loop = 0; loop < TIMEOUT-1; loop = loop + 1) begin
        @(negedge clk) begin
          {Lflit_id, Nflit_id, Eflit_id, Wflit_id, Sflit_id} = {`PAYLOAD, `PAYLOAD, `PAYLOAD, `PAYLOAD, `PAYLOAD};
        end
      end
      {Lflit_id, Nflit_id, Eflit_id, Wflit_id, Sflit_id} = {`TAIL, `TAIL, `TAIL, `TAIL, `TAIL};
    end
  end
  
  // Specifying the single pulse request parameter
  parameter NR = 3'b000,        // No request
            RS = 3'b001,        // Request to south
            RW = 3'b010,        // Request to west
            RE = 3'b011,        // Request to east
            RN = 3'b100,        // Request to north
            RL = 3'b101;        // Request to local
            
  // Specifying the continuous pulse(with access time) request parameter
  // Adding Extra bit for FSM Transition. To differentiate L-->N(00001), N-->L(10001). MSB stands for forward/backward
  parameter NRQ = 5'b00000,           // No request
            RLN = 5'b00001,           // Local to north
            RLE = 5'b00010,           // Local to east
            RLW = 5'b00011,           // Local to west
            RLS = 5'b00100,           // Local to south
            RLL = 5'b00101,           // Local to local
            RNE = 5'b00110,           // North to east
            RNW = 5'b00111,           // North to west
            RNS = 5'b01000,           // North to south
            RNL = 5'b10001,           // North to local
            RNN = 5'b01001,           // North to north
            REW = 5'b01010,           // East to west
            RES = 5'b01011,           // East to south
            REL = 5'b10010,           // East to local
            REN = 5'b10110,           // East to north
            REE = 5'b01100,           // East to east
            RWS = 5'b01101,           // West to south
            RWL = 5'b10011,           // West to local
            RWN = 5'b10111,           // West to north
            RWE = 5'b11010,           // West to east
            RWW = 5'b01110,           // West to west
            RSL = 5'b10100,           // South to local
            RSN = 5'b11000,           // South to north
            RSE = 5'b11011,           // South to east
            RSW = 5'b11101,           // South to west
            RSS = 5'b01111;           // South to south
            
  // BFM commands Declaration
  parameter NOREQ1 = 6'd1,
            REQFL  = 6'd2,
            REQFN  = 6'd3,
            REQFE  = 6'd4,
            REQFW  = 6'd5,
            REQFS  = 6'd6,
            NOREQ2 = 6'd7,
            REQFLN = 6'd8,
            REQFLE = 6'd9,
            REQFLW = 6'd10,
            REQFLS = 6'd11,
            REQFLL = 6'd12,
            REQFNE = 6'd13,
            REQFNW = 6'd14,
            REQFNS = 6'd15,
            REQFNL = 6'd16,
            REQFNN = 6'd17,
            REQFEW = 6'd18,
            REQFES = 6'd19,
            REQFEL = 6'd20,
            REQFEN = 6'd21,
            REQFEE = 6'd22,
            REQFWS = 6'd23,
            REQFWL = 6'd24,
            REQFWN = 6'd25,
            REQFWE = 6'd26,
            REQFWW = 6'd27,
            REQFSL = 6'd28,
            REQFSN = 6'd29,
            REQFSE = 6'd30,
            REQFSW = 6'd31,
            REQFSS = 6'd32;
            
  assign clk = bfm_clk;
  
  // Instantiate ARBITER DUT              
  arbiter DUT (clk, rst,
                Lflit_id, Nflit_id, Eflit_id, Wflit_id, Sflit_id,
                Llength, Nlength, Elength, Wlength, Slength,
                Lreq, Nreq, Ereq, Wreq, Sreq,
                nextstate
              );
              
  // Task to generate reset
  task reset;
    begin
      rst                                                 = 1;
      {Lflit_id, Nflit_id, Eflit_id, Wflit_id, Sflit_id}  = 0;
      {Llength, Nlength, Elength, Wlength, Slength}       = 0;
      {Lreq, Nreq, Ereq, Wreq, Sreq}                      = 0;
      @(negedge clk);
        if(nextstate != `IDLE) begin
          $display("Reset is not working\n");
          $display("Error at time %0t", $time);
          $stop; 
        end
        $display("TIME:%0t Reset is working\n", $time);
        repeat(2)
          @(negedge clk);
        rst = 0;
    end
  endtask
  
  // Task to request buffer for first time -- single pulse
  task request1;
    input [2:0] data;
    begin
      @(negedge clk) begin
        if(data == 0) begin
          {Lreq, Nreq, Ereq, Wreq, Sreq} = 0;
        end
        else begin
          {Lreq, Nreq, Ereq, Wreq, Sreq} = (1 << (data-1)); // To assert the particular bit since data == 0 is used for IDLE
        end
      end
    end
  endtask
  
  // Task to request buffer for first time withoout last request -- continuous pulse requested by any buffer
  task request2;
    input Lr, Nr, Er, Wr, Sr;
    input [4:0] data;
    begin
      @(negedge clk) begin
        if(data == 0) begin
          {Lreq, Nreq, Ereq, Wreq, Sreq} = 0;
        end
        else begin
          {Lreq, Nreq, Ereq, Wreq, Sreq} = {Lr, Nr, Er, Wr, Sr};
        end
      end
      
      repeat(TIMEOUT+2) //Repeating the request for a particular buffer till timeout occurs followed by round robin priority request
        @(negedge clk);
    end
  endtask
  
  // Sampling and executing Commands
  always @(posedge clk) begin
    case(bfm_command)
      NOREQ1 :
        begin
          bfm_grant = 1'b0;
          request1(NR);
          bfm_grant = 1'b1;
        end
      REQFL :
        begin
          bfm_grant = 1'b0;
          request1(RL);
          request1(NR);
          bfm_grant = 1'b1;
        end
      REQFN :
        begin
          bfm_grant = 1'b0;
          request1(RN);
          request1(NR);
          bfm_grant = 1'b1;
        end
      REQFE :
        begin
          bfm_grant = 1'b0;
          request1(RE);
          request1(NR);
          bfm_grant = 1'b1;
        end
      REQFW :
        begin
          bfm_grant = 1'b0;
          request1(RW);
          request1(NR);
          bfm_grant = 1'b1;
        end
      REQFS :
        begin
          bfm_grant = 1'b0;
          request1(RS);
          request1(NR);
          bfm_grant = 1'b1;
        end
      NOREQ2 :
        begin
          bfm_grant = 1'b0;
          request2(0, 0, 0, 0, 0, NRQ);
          bfm_grant = 1'b1;
        end
      REQFLN :
        begin
          bfm_grant = 1'b0;
          request2(1, 1, 1, 1, 1, RLN);
          bfm_grant = 1'b1;
        end
      REQFLE :
        begin
          bfm_grant = 1'b0;
          request2(1, 0, 1, 1, 1, RLE);
          bfm_grant = 1'b1;
        end
      REQFLW :
        begin
          bfm_grant = 1'b0;
          request2(0, 0, 0, 1, 0, RLW);
          bfm_grant = 1'b1;
        end
      REQFLS :
        begin
          bfm_grant = 1'b0;
          request2(1, 0, 0, 0, 1, RLS);
          bfm_grant = 1'b1;
        end
      REQFLL :
        begin
          bfm_grant = 1'b0;
          request2(1, 0, 0, 0, 0, RLL);
          bfm_grant = 1'b1;
        end
      REQFNE :
        begin
          bfm_grant = 1'b0;
          request2(1, 1, 1, 1, 1, RNE);
          bfm_grant = 1'b1;
        end
      REQFNW :
        begin
          bfm_grant = 1'b0;
          request2(1, 1, 0, 1, 1, RNW);
          bfm_grant = 1'b1;
        end
      REQFNS :
        begin
          bfm_grant = 1'b0;
          request2(1, 1, 0, 0, 1, RNS);
          bfm_grant = 1'b1;
        end
      REQFNL :
        begin
          bfm_grant = 1'b0;
          request2(1, 0, 0, 0, 0, RNL);
          bfm_grant = 1'b1;
        end
      REQFNN :
        begin
          bfm_grant = 1'b0;
          request2(0, 1, 0, 0, 0, RNN);
          bfm_grant = 1'b1;
        end
      REQFEW :
        begin
          bfm_grant = 1'b0;
          request2(1, 1, 1, 1, 1, REW);
          bfm_grant = 1'b1;
        end
      REQFES :
        begin
          bfm_grant = 1'b0;
          request2(1, 1, 1, 0, 1, RES);
          bfm_grant = 1'b1;
        end
      REQFEL :
        begin
          bfm_grant = 1'b0;
          request2(1, 1, 1, 0, 0, REL);
          bfm_grant = 1'b1;
        end
      REQFEN :
        begin
          bfm_grant = 1'b0;
          request2(0, 1, 1, 0, 0, REN);
          bfm_grant = 1'b1;
        end
      REQFEE :
        begin
          bfm_grant = 1'b0;
          request2(0, 0, 1, 0, 0, REE);
          bfm_grant = 1'b1;
        end
      REQFWS :
        begin
          bfm_grant = 1'b0;
          request2(1, 1, 1, 1, 1, RWS);
          bfm_grant = 1'b1;
        end
      REQFWL :
        begin
          bfm_grant = 1'b0;
          request2(1, 1, 1, 1, 0, RWL);
          bfm_grant = 1'b1;
        end
      REQFWN :
        begin
          bfm_grant = 1'b0;
          request2(0, 1, 1, 1, 0, RWN);
          bfm_grant = 1'b1;
        end
      REQFWE :
        begin
          bfm_grant = 1'b0;
          request2(0, 0, 1, 1, 0, RWE);
          bfm_grant = 1'b1;
        end
      REQFWW :
        begin
          bfm_grant = 1'b0;
          request2(0, 0, 0, 1, 0, RWW);
          bfm_grant = 1'b1;
        end
      REQFSL :
        begin
          bfm_grant = 1'b0;
          request2(1, 0, 0, 0, 0, RSL);
          bfm_grant = 1'b1;
        end
      REQFSN :
        begin
          bfm_grant = 1'b0;
          request2(0, 1, 0, 0, 0, RSN);
          bfm_grant = 1'b1;
        end
      REQFSE :
        begin
          bfm_grant = 1'b0;
          request2(0, 0, 1, 0, 0, RSE);
          bfm_grant = 1'b1;
        end
      REQFSW :
        begin
          bfm_grant = 1'b0;
          request2(0, 0, 0, 1, 0, RSW);
          bfm_grant = 1'b1;
        end
      REQFSS :
        begin
          bfm_grant = 1'b0;
          request2(0, 0, 0, 0, 1, RSS);
          bfm_grant = 1'b1;
        end
    endcase
  end
  
endmodule
