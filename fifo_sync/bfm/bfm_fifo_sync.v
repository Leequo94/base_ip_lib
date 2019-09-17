////////////////////////////////////////////////////////////////////////////////
//       !###########################!     Copyright(C),ZMvision Technology All 
//      !###########################!      rights FPGA Department
//     !##########!!!!!!###########!       
//    !########!           !######!        FileName:   bfm_fifo_sync.v
//   !######!    !##!      !####!          
//  !#####!     !###!        !#!           Author:     Leequo94
// !#####!     !#####!  !#!                
//            !###########!    !#####!     Email:      likuo@zmvision.cn
//       !!   !##########!    !#####!      
//      !##!   !#######!     !#####!       Version:    v1_0
//      !##!      !#!       !######!       
//     !######!           !########!       Date: 
//    !##########!!!!!!!!!########!        
//   !###########################!         
//  !###########################!          
//                                         
// Module Description:
// synchronous fifo includes showahead and normal two modes of operation;
// @todo list :
// 
// History:  //modified list 
//     1.  Date:
//         Author:
//         Modification:
//     2.  ......
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps 
module bfm_fifo_sync #(
    parameter   SHOWAHEAD = 1, // 1-showahead 0-normal 
    parameter   ABITS    = 10,
    parameter   DBITS    = 16,
    parameter   FTHRD    = 800,
    parameter   ETHRD    = 2
)( 
    input           wire                clk,
    input           wire                rst,
    input           wire    [DBITS-1:0] wr_data,
    input           wire                wren,
    
    input           wire                rden,
    output          wire    [DBITS-1:0] rd_data,
    output          wire                wrfull,
    output          wire                rdempty,
    output          wire    [ABITS-1:0] fifo_num
);
////////////////////////////////////////////////////////////////////////////////
// parameter 

////////////////////////////////////////////////////////////////////////////////
// internal register and net declare 
reg [DBITS-1 :0] dat_mem[2**ABITS-1:0] ;
reg [ABITS-1 :0] wr_point;
reg [ABITS-1 :0] rd_point;
reg [DBITS-1 :0] rd_data_r;
reg [ABITS-1 :0] counter_int;
reg wrfull_r;
reg rdempty_r;
wire wr_allow;
wire rd_allow;
////////////////////////////////////////////////////////////////////////////////
// internal interconnect 
assign wr_allow = wren & (!wrfull_r);
assign rd_allow = rden & (!rdempty_r);
assign wrfull = wrfull_r;
assign rdempty = rdempty_r;
assign fifo_num = counter_int;
////////////////////////////////////////////////////////////////////////////////
// internal logic 
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clk,posedge rst)
begin 
    if (rst) begin 
        wr_point <= {ABITS{1'd0}};
    end 
    else if (wr_allow) begin 
        wr_point <= wr_point + 1'd1;
    end 
    else begin 
        wr_point <= wr_point;
    end 
end 
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clk,posedge rst)
begin 
    if (rst) begin 
        dat_mem[wr_point] <= {DBITS{1'd0}};
    end 
    else if (wr_allow) begin 
        dat_mem[wr_point] <= wr_data;
    end 
    else begin 
        dat_mem[wr_point] <= dat_mem[wr_point];
    end 
end 
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clk,posedge rst)
begin 
    if (rst) begin 
        rd_point <= {ABITS{1'd0}};
    end 
    else if (rd_allow) begin 
        rd_point <= rd_point + 1'd1;
    end 
    else begin 
        rd_point <= rd_point;
    end 
end 
////////////////////////////////////////////////////////////////////////////////
generate 
    if (SHOWAHEAD) begin 
        always @ (*)
        begin 
            if (rst) begin 
                rd_data_r <= {DBITS{1'd0}};
            end 
            else if (rd_allow) begin 
                rd_data_r <= dat_mem[rd_point];
            end 
            else begin 
                rd_data_r <= dat_mem[rd_point];
            end 
        end 
    end 
    else begin 
        always @ (posedge clk,posedge rst)
        begin 
            if (rst) begin 
                rd_data_r <= {DBITS{1'd0}};
            end 
            else if (rd_allow) begin 
                rd_data_r <= dat_mem[rd_point];
            end 
            else begin 
                rd_data_r <= rd_data_r;
            end 
        end 
    end 
endgenerate 
assign rd_data = rd_data_r;
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clk,posedge rst) 
begin 
    if (rst) begin 
        counter_int <= {ABITS{1'd0}};
    end 
    else if (wr_allow == 1 && rd_allow == 0) begin 
        counter_int <= counter_int + 1'd1;
    end 
    else if (wr_allow == 0 && rd_allow == 1) begin 
        counter_int <= counter_int - 1'd1;
    end 
    else begin 
        counter_int <= counter_int;
    end 
end 
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clk,posedge rst)
begin 
    if (rst) begin 
        wrfull_r <= 1'd0;
    end 
    else if (wr_allow) begin 
        if (counter_int >= FTHRD-1) begin 
            wrfull_r <= 1'd1;
        end 
        else begin 
            wrfull_r <= 1'd0;
        end 
    end 
    else if (rd_allow) begin 
        wrfull_r <= 1'd0;
    end 
    else begin 
        wrfull_r <= wrfull_r;
    end 
end 
////////////////////////////////////////////////////////////////////////////////
always @(posedge clk,posedge rst)
begin 
    if (rst) begin 
        rdempty_r <= 1'd1;
    end 
    else if (rd_allow) begin 
        if (counter_int <= ETHRD-1) begin 
            rdempty_r <= 1'd1;
        end 
        else begin 
            rdempty_r <= 1'd0;
        end 
    end 
    else if (wr_allow) begin 
        rdempty_r <= 1'd0;
    end 
    else begin 
        rdempty_r <= rdempty_r;
    end 
end 
////////////////////////////////////////////////////////////////////////////////

endmodule
////////////////////////////////////////////////////////////////////////////////