/* 
 * Do not change Module name 
*/


`define GENERATE_FAULT_INJECTION_FUNCTION(FUN_NAME, WIDTH) \
	function [WIDTH-1:0] FUN_NAME; \
		input [WIDTH-1:0] var; \
		input [7:0] fp; \
		input [7:0] toggle_start; \
		input [7:0] toggle_end; \
		reg [WIDTH-1:0] mask; \
		begin \
			mask = (fp < toggle_start || fp >= toggle_end) \
				? 0 : (1 << (fp - toggle_start)); \
			FUN_NAME = var ^ mask; \
		end \
	endfunction

// module main;
// 
//     `GENERATE_FAULT_INJECTION_FUNCTION(faultinj1, 1)
//     `GENERATE_FAULT_INJECTION_FUNCTION(faultinj8, 8)
//     
//     initial 
//         begin
//             $display("Hello, World");
//             $finish ;
//         end
//     
// endmodule

module CC  (
  input wire                   clk,    
  input wire                   reset,  
  input wire                   enable, 
  input wire [7:0]             fp,
  output wire [7:0]            out  // data to read
);

    `GENERATE_FAULT_INJECTION_FUNCTION(faultinj1, 1)

    reg [7:0] count;
    
    assign out = count;
    
    always @(posedge clk) begin
    
    	if (reset) begin
    		count <= 0;
    	end 
    	else if(faultinj1(enable, fp, 0, 1))
    	begin 
    		count<=count+1;
    	end
    
    end 

endmodule


unsigned char f_oper(unsigned char var1, unsigned char var2, unsigned char fp, unsigned char toggle_start, unsigned char toggle_end, unsigned char oper) {
    
    unsigned char result;
    bool flag[] = {false, false, false, false};
    
    for(int i=0; i<4; i++){
      if(i >= oper)
        flag[i]=true;
    }

    if(fp < toggle_start || fp >= toggle_end) {
        switch (oper){
          case 0:
            result= var1+var2;
            break;
          case 1:
            result= var1-var2;
            break;
          case 2:
            result= var1*var2;
            break;
          case 3:
            result= var1/var2;
            break;
      } 
    } else { 
        switch (fp-toggle_start){
          case 0:
            if(flag[fp-toggle_start])
              result= var1-var2;
            else
              result= var1+var2;
            break;
          case 1:
            if(flag[fp-toggle_start])
              result= var1*var2;
            else
              result= var1-var2;
            break;
          case 2:
            if(flag[fp-toggle_start])
              result= var1/var2;
            else
              result= var1*var2;
            break;
    }
  }
    
    return result;
}

function [7:0] mutant_injection;
  input [7:0] var1;
  input [7:0] var2;
  input [7:0] fp;
  input [7:0] toggle_start;
  input [7:0] toggle_end;
  input [7:0] oper;
  reg [7:0] result;
  begin

  end
  
endfunction : 

// dimensione costante
//function [7:0] fault_injection;
////  input [7:0] var;
/// input [7:0] fp;
 // input [7:0] toggle_start;
//  input [7:0] toggle_end;
//  reg [7:0] mask;
//  begin
 //   mask = (fp < toggle_start || fp >= toggle_end)
  ////    ? 0 : (1 << (fp - toggle_start));
///   fault_injection = var ^ mask;
//  end
//endfunction

// dimensione variabili
//parameter MAX_BITS_VAR = 8;
//parameter MAX_BITS_FP  = 8;
//function [MAX_BITS_VAR-1:0] fault_injection;
  //input [MAX_BITS_VAR-1:0] var;
  //input [MAX_BITS_FP -1:0] fp;
  //input [MAX_BITS_FP -1:0] toggle_start;
  //parameter MAX_BITS_FP  = 8;
//input [MAX_BITS_FP -1:0] toggle_end;
  //reg   [MAX_BITS_VAR-1:0] mask;
  //begin
  //  mask = (fp < toggle_start or fp >= toggle_end)
  //    ? 0 : (1 << (fp - toggle_start));
  //  fault_injection = var ^ mask;
  //end
//endfunction