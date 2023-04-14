module spu(
input  clk,
input  rst,

input  start,                  // to start the processor
output stop,                   // to show that the processor is stopped

//control signals for instruction memory (im)
input   [15:0] im_r_data,      // 16-bit read data of im
output  [7:0]  im_addr,        // 8-bit data address of im
output  im_rd,                 // read enable of im

//control signals for data memory (dm)
output  [7:0] dm_addr,         // 8-bit data address of dm
output  dm_rd,                 // read enable of dm
output  dm_wr,                 // write enable of dm

//data for data memory (dm)
input  [15:0] dm_r_data,       // 16-bit read data
output [15:0] dm_w_data        // 16-bit write data
);

//新增一條rf多工器的選擇線 control signal for mux
wire rf_s1;
wire rf_s0;
wire [7:0] rf_w_data;

//control signals for register file (rf)
wire [3:0] rf_w_addr;   // 4-bit write address 
wire rf_w_wr;           // write enable
 
wire [3:0] rf_rp_addr;  // 4-bit p-port read address 
wire rf_rp_rd;          // p-port read enable

wire [3:0] rf_rq_addr;  // 4-bit q-port read address 
wire rf_rq_rd;          // q-port read enable

//新增一條signal back from datapath
wire rf_rp_zero;

//新增一條alu多工器的選擇線 control signal for ALU
wire alu_s1;
wire alu_s0;

spu_ctrl c1(.clk(clk),
            .rst(rst),
         
            .start(start),            // to start the processor
            .stop(stop),              // to show that the processor is stopped

            //control signals for instruction memory (im)
            .im_r_data(im_r_data),    // 16-bit read data of im
            .im_addr(im_addr),        // 8-bit data address of im
            .im_rd(im_rd),            // read enable of im

            //control signals for data memory (dm)
            .dm_addr(dm_addr),        // 8-bit data address of dm
            .dm_rd(dm_rd),            // read enable of dm
            .dm_wr(dm_wr),            // write enable of dm

            //新增rf選擇和data線 control signal for mux
            .rf_s1(rf_s1),
            .rf_s0(rf_s0),
            .rf_w_data(rf_w_data),

            //control signals for register file (rf)
            .rf_w_addr(rf_w_addr),    // 4-bit write address 
            .rf_w_wr(rf_w_wr),        // write enable
 
            .rf_rp_addr(rf_rp_addr),  // 4-bit p-port read address 
            .rf_rp_rd(rf_rp_rd),      // p-port read enable

            .rf_rq_addr(rf_rq_addr),  // 4-bit q-port read address 
            .rf_rq_rd(rf_rq_rd),      // q-port read enable

            //新增 signal back from rf
            .rf_rp_zero(rf_rp_zero),

            //新增 control signal for ALU
            .alu_s1(alu_s1),
            .alu_s0(alu_s0)
);

spu_datapath d1(.clk(clk),
                .rst(rst),

                //新增控制線及rf_w_data control signal for mux
                .rf_s1(rf_s1),
                .rf_s0(rf_s0),
                .rf_w_data(rf_w_data),

                //control signals for register file (rf)
                .rf_w_addr(rf_w_addr),      // 4-bit write address 
                .rf_w_wr(rf_w_wr),          // write enable

                .rf_rp_addr(rf_rp_addr),    // 4-bit p-port read address 
                .rf_rp_rd(rf_rp_rd),        // p-port read enable

                .rf_rq_addr(rf_rq_addr),    // 4-bit q-port read address 
                .rf_rq_rd(rf_rq_rd),        // q-port read enable

                //新增rf_rp_zero線
                .rf_rp_zero(rf_rp_zero),

                //新增選擇線 control signal for ALU
                .alu_s1(alu_s1),
                .alu_s0(alu_s0),

                //data for data memory (dm)
                .dm_r_data(dm_r_data),      // 16-bit read data
                .dm_w_data(dm_w_data)       // 16-bit write data
);

endmodule
