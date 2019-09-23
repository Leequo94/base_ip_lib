////////////////////////////////////////////////////////////////////////////////
//       !###########################!     Copyright(C),ZMvision Technology All 
//      !###########################!      rights FPGA Department
//     !##########!!!!!!###########!       
//    !########!           !######!        FileName:   fifo_full_gen.v
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
// fifo full signal generator
// @todo list :
// 
// History:  //modified list 
//     1.  Date:
//         Author:
//         Modification:
//     2.  ......
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps 
module fifo_full_gen #(
    parameter   FTHR     = 800,
    parameter   ABITS    = 10,
    parameter   DBITS    = 16
)( 
    input           wire                wrclk,
    input           wire                rst,
    input           wire    [ABITS-1:0] wr_bin_ptr,
    input           wire    [ABITS-1:0] rd_bin_ptr,
    output          wire                wr_full
);
////////////////////////////////////////////////////////////////////////////////
// parameter 
localparam FIFO_DEPTHS = 1<<ABITS;
////////////////////////////////////////////////////////////////////////////////
// internal register and net declare 
wire [ABITS-1 :0] wr_gray_ptr;
wire [ABITS-1 :0] rd_gray_ptr;
reg  [ABITS-1 :0] rd_gray_ptr_r0;
reg  [ABITS-1 :0] rd_gray_ptr_r1;
reg  dirct;
wire dir_set;
wire dir_clr;
wire [ABITS :0]wr_bin_ptr_next;
////////////////////////////////////////////////////////////////////////////////
// internal interconnect 
assign wr_bin_ptr_next = wr_bin_ptr+(FIFO_DEPTHS-1)-FTHR;
assign wr_gray_ptr = bin2gray(wr_bin_ptr_next[ABITS-1:0]);
assign rd_gray_ptr = bin2gray(rd_bin_ptr);
assign dir_set = (wr_gray_ptr[ABITS-1]^rd_gray_ptr_r1[ABITS-2]) & ~(wr_gray_ptr[ABITS-2]^rd_gray_ptr_r1[ABITS-1]);
assign dir_clr = (~(wr_gray_ptr[ABITS-1]^rd_gray_ptr_r1[ABITS-2])) & (wr_gray_ptr[ABITS-2]^rd_gray_ptr_r1[ABITS-1]) | rst;
assign wr_full = dirct & (wr_gray_ptr[ABITS-1:0] == rd_gray_ptr_r1[ABITS-1:0]);
////////////////////////////////////////////////////////////////////////////////
// internal logic 
////////////////////////////////////////////////////////////////////////////////
function [ABITS-1 :0] bin2gray ;
input   [ABITS-1 :0] bin_ptr;
begin 
    // gray_ptr[ABITS-1] = bin_ptr[ABITS-1];
    // gray_ptr[ABITS-2:0] = bin_ptr[ABITS-1:1] ^ bin_ptr[ABITS-2:0];
    bin2gray = (bin_ptr >> 1) ^ bin_ptr;
end 
endfunction 
////////////////////////////////////////////////////////////////////////////////
always @ (posedge wrclk,posedge rst)
begin 
    if (rst) begin 
        rd_gray_ptr_r0 <= {ABITS{1'd0}};
        rd_gray_ptr_r1 <= {ABITS{1'd0}};
    end 
    else begin 
        rd_gray_ptr_r0 <= rd_gray_ptr;
        rd_gray_ptr_r1 <= rd_gray_ptr_r0;
    end 
end 
////////////////////////////////////////////////////////////////////////////////
always @ (*) 
begin 
    if (dir_set)begin 
        dirct <= 1'd1;
    end 
    else if (dir_clr) begin 
        dirct <= 1'd0;
    end 
    else begin 
        dirct <= dirct;//1'd1;
    end 
end 
////////////////////////////////////////////////////////////////////////////////

endmodule
////////////////////////////////////////////////////////////////////////////////