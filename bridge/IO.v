// Non-ANSI Decl
//
//module IO (
//  clk,    // clock
//  reset,  // reset
//  ReqW_i, // write request
//  ReqR_i, // read request
//  Data_i, // data to write
//  AckW_o, // write acknowledge
//  AckR_o, // read acknowledge
//  Data_o  // data to read
//);
//
//parameter DATA_WIDTH = 8;
//parameter ADDR_WIDTH = 3;
//parameter RAM_DEPTH  = 1 << ADDR_WIDTH;
//
//input wire clk;
//input wire reset;
//input wire ReqW_i;
//input wire ReqR_i;
//input wire [DATA_WIDTH-1:0] Data_i;
//
//output reg AckW_o;
//output reg AckR_o;
//output wire [DATA_WIDTH-1:0] Data_o;
// ------------------------

// ANSI Decl
`timescale 1ns/1ps
module IO #(parameter
  DATA_WIDTH = 8,
  ADDR_WIDTH = 3,
  RAM_DEPTH  = 1 << ADDR_WIDTH
) (
  input wire                   clk,    // clock
  input wire                   reset,  // reset
  input wire                   ReqW_i, // write request
  input wire                   ReqR_i, // read request
  input wire [DATA_WIDTH-1:0]  Data_i, // data to write
  output reg                   AckW_o, // write acknowledge
  output reg                   AckR_o, // read acknowledge
  output wire [DATA_WIDTH-1:0] Data_o  // data to read
);
// -------------------------

localparam IDLE  = 2'b00;
localparam WRITE = 2'b01;
localparam READ  = 2'b01;
localparam WAIT  = 2'b10;
localparam ERROR = 2'b11;

reg [1:0] w_state_, w_state_next_;
reg [1:0] r_state_, r_state_next_;

reg w_ack_next_, r_ack_next_;
reg [DATA_WIDTH-1:0] tmp_buf_, next_in_data_;

wire  WEnable_, REnable_;
wire Empty_,   Full_;

initial begin

  w_state_ <= IDLE;
  r_state_ <= IDLE;
  AckW_o <= 1'b0;
  AckR_o <= 1'b0;
  w_ack_next_ = 1'b0;
  r_ack_next_ = 1'b0;
  tmp_buf_ = 0;
  next_in_data_ = 0;

end

assign WEnable_ = w_state_next_ == WRITE;
assign REnable_ = r_state_next_ == READ;

Mem #(DATA_WIDTH, ADDR_WIDTH, RAM_DEPTH) mem_ (
  .clk       (clk),
  .reset     (reset),
  .REnable_i (REnable_),
  .WEnable_i (WEnable_),
  .Data_i    (next_in_data_),
  .Data_o    (Data_o),
  .Empty_o   (Empty_),
  .Full_o    (Full_)
);

always @(*) begin : WTransitions

case(w_state_)
  IDLE : if (ReqW_i == 1'b0) begin
           w_state_next_ = IDLE;
           w_ack_next_   = 1'b0;
         end else if (Full_ == 1'b0) begin
           w_state_next_ = WRITE;
           w_ack_next_   = 1'b0;
           next_in_data_ = Data_i;
         end else begin
           w_state_next_ = WAIT;
           w_ack_next_   = 1'b0;
           tmp_buf_      = Data_i;
         end
  WAIT : if (Full_ == 1'b1) begin
           w_state_next_ = WAIT;
           w_ack_next_   = 1'b0;
           if (ReqW_i == 1'b1) begin
             tmp_buf_ = Data_i;
           end
         end else begin
           w_state_next_ = WRITE;
           w_ack_next_   = 1'b0;
           next_in_data_ = tmp_buf_;
         end
  WRITE : if (ReqW_i == 1'b0) begin
            w_state_next_ = IDLE;
            w_ack_next_   = 1'b1;
          end else if (Full_ == 1'b0) begin
            w_state_next_ = WRITE;
            w_ack_next_   = 1'b1;
            next_in_data_ = Data_i;
          end else begin
            w_state_next_ = WAIT;
            w_ack_next_   = 1'b1;
            tmp_buf_      = Data_i;
          end
  default : begin
              w_state_next_ = ERROR;
              w_ack_next_   = 1'b0;
            end
endcase

end // End of WTransitions


always @(*) begin : RTransitions

case(r_state_)
  IDLE : if (ReqR_i == 1'b0) begin
           r_state_next_ = IDLE;
           r_ack_next_   = 1'b0;
         end else if (Empty_ == 1'b0) begin
           r_state_next_ = READ;
           r_ack_next_   = 1'b0;
         end else begin
           r_state_next_ = WAIT;
           r_ack_next_   = 1'b0;
         end
  WAIT : if (Empty_ == 1'b1) begin
           r_state_next_ = WAIT;
           r_ack_next_   = 1'b0;
         end else begin
           r_state_next_ = READ;
           r_ack_next_   = 1'b0;
         end
  READ : if (ReqR_i == 1'b0) begin
           r_state_next_ = IDLE;
           r_ack_next_   = 1'b1;
         end else if (Empty_ == 1'b0) begin
           r_state_next_ = READ;
           r_ack_next_   = 1'b1;
         end else begin
           r_state_next_ = WAIT;
           r_ack_next_   = 1'b1;
         end
  default : begin
              r_state_next_ = ERROR;
              r_ack_next_   = 1'b0;
            end
endcase


end // End of RTransitions

always @(posedge clk) begin : FSM_Seq

if (reset) begin

  w_state_ <= IDLE;
  r_state_ <= IDLE;

  AckW_o <= 1'b0;
  AckR_o <= 1'b0;

end else begin

  w_state_ <= w_state_next_;
  AckW_o   <= w_ack_next_;

  r_state_ <= r_state_next_;
  AckR_o   <= r_ack_next_;

end

end // end of FSM_Seq

endmodule // end of module IO
