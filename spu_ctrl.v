`timescale 1ns/10ps

module spu_ctrl(

input   clk,
input   rst,

input   start,                 // to start the processor
output  reg stop,              // to show that the processor is stopped

//control signals for instruction memory (im)
input   [15:0] im_r_data,      // 16-bit read data of im
output  [7:0]  im_addr,        // 8-bit data address of im
output  reg im_rd,             // read enable of im


//新增 一條rf to control unit 的輸入
input   rf_rp_zero,

//control signals for data memory (dm)
output  [7:0] dm_addr,         // 8-bit data address of dm
output  reg dm_rd,             // read enable of dm
output  reg dm_wr,             // write enable of dm

//新增一條Mux的選擇線及data  control signal for mux
output  reg rf_s1,
output  reg rf_s0,
output  reg [7:0] rf_w_data,

//control signals for register file (rf)
output  reg [3:0] rf_w_addr,   // 4-bit write address 
output  reg rf_w_wr,           // write enable
 
output  reg [3:0] rf_rp_addr,  // 4-bit p-port read address 
output  reg rf_rp_rd,          // p-port read enable

output  reg [3:0] rf_rq_addr,  // 4-bit q-port read address 
output  reg rf_rq_rd,          // q-port read enable

//新增一條alu的選擇線 control signal for ALU
output  reg alu_s1,
output  reg alu_s0
);

parameter [3:0]  INIT   = 4'd0, 
                 FETCH  = 4'd1,
		           DECODE = 4'd2,
		           LOAD   = 4'd3,
		           STORE  = 4'd4,
                 ADD    = 4'd5,
                 STOP   = 4'd6,
                 ADDI   = 4'd7,
                 SUB    = 4'd8,
                 LDC    = 4'd9,
                 JMPZ   = 4'd10;

parameter [3:0]  OP_LOAD  = 4'd0,
                 OP_STORE = 4'd1,
	              OP_ADD   = 4'd2,
                 OP_LDC   = 4'd3,
                 OP_ADDI  = 4'd4,
                 OP_SUB   = 4'd5,
                 OP_JMPZ  = 4'd6,
	              OP_STOP  = 4'd15;				  
					  
reg [7:0] pc;    // 8-bit program counter
reg pc_inc;
reg pc_clr;
reg pc_ld;

reg [15:0] ir;    // 16-bit instruction register
reg ir_ld;

reg [2:0] cs, ns;  // current state and next state

wire [3:0] ra, rb, rc;  // address for rf

wire [3:0] op;          // op code

wire [7:0] pc_jmpz;    //新增pc_jmpz;

assign im_addr = pc;

assign op = ir[15:12];

assign ra = ir[11:8];
assign rb = ir[7:4];
assign rc = ir[3:0];

assign dm_addr = ir[7:0];

assign pc_jmpz = pc + ir[7:0];

// program counter
always@(posedge clk or posedge rst)
begin
  if(rst)
     pc <= #1 8'd0;
  else if(pc_clr)
     pc <= #1 8'd0;
  else if(pc_inc)
     pc <= #1 (pc + 8'd1);
end

// ir
always@(posedge clk or posedge rst)
begin
  if(rst)
     ir <= #1 16'd0;
  else if(ir_ld)
     ir <= #1 im_r_data;
end

// current state register
always@(posedge clk or posedge rst)
begin
  if(rst)
     cs <= #1 INIT;
  else 
     cs <= #1 ns;
end

// next state combinational logic
always@(*)
begin
  case(cs)
  INIT:    if(start)
              ns = FETCH;
			  else
			     ns = INIT;
  
  FETCH:   ns = DECODE;
  
  DECODE:  case(op)
           OP_LOAD:  ns = LOAD;
			  OP_STORE: ns = STORE;
			  OP_ADD:   ns = ADD;
           OP_LDC:   ns = LDC;
           OP_SUB:   ns = SUB;
           OP_JMPZ:  ns = JMPZ;
			  OP_STOP:  ns = STOP; 
           default:  ns = INIT;
			  endcase
			 
  LOAD:    ns = FETCH;
  
  STORE:   ns = FETCH;
  
  ADD:     ns = FETCH;

  LDC:     ns = FETCH;

  SUB:     ns = FETCH;

  JMPZ:    ns = FETCH;
  
  STOP:    ns = INIT;
  
  default: ns = INIT;
  endcase
end
  

// controller output combinational logic
always@(*)
begin
  im_rd = 1'b0;
  
  pc_clr = 1'b0;
  pc_inc = 1'b0;
  pc_ld  = 1'b0;
  
  ir_ld = 1'b0;  
  
  dm_rd = 1'b0;
  dm_wr = 1'b0;
  
  rf_s1 = 1'b0;
  rf_s0 = 1'b0;

  rf_w_data = 8'd0;

  rf_w_addr  = 4'd0;
  rf_w_wr = 1'b0;
  
  rf_rp_addr = 4'd0;
  rf_rp_rd = 1'b0;  
  
  rf_rq_addr = 4'd0;
  rf_rq_rd = 1'b0;  
  
  alu_s1 = 1'b0;
  alu_s0 = 1'b0;

  
  
  stop = 1'b0; 

  case(cs)
  INIT:    begin
             pc_clr = 1'b1;  
           end
  
  FETCH:   begin
             im_rd  = 1'b1;
				 ir_ld  = 1'b1;
			    pc_inc = 1'b1;  
           end
 
  LOAD:    begin
             dm_rd = 1'b1;
			    rf_s1 = 1'b0;
             rf_s0 = 1'b1; 
			    rf_w_addr = ra;
			    rf_w_wr = 1'b1;			  
           end
  
  STORE:   begin
             dm_wr = 1'b1; 
			    rf_rp_addr = ra;
			    rf_rp_rd = 1'b1;			  
           end
  
  ADD:     begin           
			    rf_rp_addr = rb;
			    rf_rp_rd = 1'b1;
             
             rf_s1 = 1'b0;
             rf_s0 = 1'b0;

			    rf_rq_addr = rc;
			    rf_rq_rd = 1'b1;

			    rf_w_addr = ra;
			    rf_w_wr = 1'b1;

	          alu_s1 = 1'b0;
	          alu_s0 = 1'b1;		  
           end
   SUB:     begin
             rf_rp_addr = rb;
             rf_rp_rd = 1'b1;

             rf_s1 = 1'b0;
             rf_s0 = 1'b0;

             rf_rq_addr = rc;
             rf_rq_rd = 1'b1;

             rf_w_addr = ra;
             rf_w_wr =1'b1;

             alu_s1 = 1'b1;
             alu_s0 = 1'b0;

             
            end
  
  STOP:    begin
             stop = 1'b1;  
           end
			  
  default: begin
             im_rd = 1'b0;
  
             pc_clr = 1'b0;
             pc_inc = 1'b0;
             pc_ld  = 1'b0;
  
             ir_ld = 1'b0;  
  
             dm_rd = 1'b0;
             dm_wr = 1'b0;
            
             rf_s1 = 1'b0;
             rf_s0 = 1'b0;
             
             rf_w_data  = 8'd0;
             rf_w_addr  = 4'd0;
             rf_w_wr = 1'b0;
  
             rf_rp_addr = 4'd0;
             rf_rp_rd = 1'b0;  
  
             rf_rq_addr = 4'd0;
             rf_rq_rd = 1'b0;  
  
             alu_s1 = 1'b0;
             alu_s0 = 1'b0;
  
             stop = 1'b0;
			  end
  endcase
end

endmodule








