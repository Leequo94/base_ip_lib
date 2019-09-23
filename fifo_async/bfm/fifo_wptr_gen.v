////////////////////////////////////////////////////////////////////////////////
//       !###########################!     Copyright(C),ZMvision Technology All 
//      !###########################!      rights FPGA Department
//     !##########!!!!!!###########!       
//    !########!           !######!        FileName:   fifo_wptr_gen.v
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
// fifo write pointer generator
// @todo list :
// 
// History:  //modified list 
//     1.  Date:
//         Author:
//         Modification:
//     2.  ......
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps 
module fifo_wptr_gen #(
    parameter   ABITS    = 10,
    parameter   DBITS    = 16
)( 
    input           wire                wrclk,
    input           wire                rst,
    input           wire                wr_en,
    output          wire    [ABITS-1:0] wr_bin_ptr,
    output          wire                wr_allow,
    input           wire                wr_full
);
////////////////////////////////////////////////////////////////////////////////
// parameter 

////////////////////////////////////////////////////////////////////////////////
// internal register and net declare 
reg [ABITS-1 :0] wr_bin_ptr_r;
////////////////////////////////////////////////////////////////////////////////
// internal interconnect 
assign wr_allow = wr_en&(~wr_full);
assign wr_bin_ptr = wr_bin_ptr_r;
////////////////////////////////////////////////////////////////////////////////
// internal logic 
////////////////////////////////////////////////////////////////////////////////
always @ (posedge wrclk,posedge rst)
begin 
    if (rst) begin 
        wr_bin_ptr_r <= {ABITS{1'd0}};
    end 
    else if (wr_allow) begin 
        wr_bin_ptr_r <= wr_bin_ptr_r + 1'd1;
    end 
    else begin 
        wr_bin_ptr_r <= wr_bin_ptr_r;
    end 
end 
////////////////////////////////////////////////////////////////////////////////

endmodule
////////////////////////////////////////////////////////////////////////////////