////////////////////////////////////////////////////////////////////////////////
//       !###########################!     Copyright(C),ZMvision Technology All 
//      !###########################!      rights FPGA Department
//     !##########!!!!!!###########!       
//    !########!           !######!        FileName:   fifo_mem.v
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
// 
// @todo list :
// 
// History:  //modified list 
//     1.  Date:
//         Author:
//         Modification:
//     2.  ......
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps 
module fifo_mem #(
    parameter   ABITS    = 10,
    parameter   DBITS    = 16
)( 
    input           wire                wclk,
    input           wire                rst,
    input           wire    [DBITS-1:0] w_data,
    input           wire    [ABITS-1:0] w_bin_ptr,
    input           wire                w_allow,
    
    input           wire    [ABITS-1:0] r_bin_ptr,
    output          wire    [DBITS-1:0] r_data
);
////////////////////////////////////////////////////////////////////////////////
// parameter 

////////////////////////////////////////////////////////////////////////////////
// internal register and net declare 
reg [DBITS-1 :0] dat_mem[2**ABITS-1:0] ;
////////////////////////////////////////////////////////////////////////////////
// internal interconnect 
assign r_data = dat_mem[r_bin_ptr];
////////////////////////////////////////////////////////////////////////////////
// internal logic 
////////////////////////////////////////////////////////////////////////////////
integer i;
always @ (posedge wclk,posedge rst)
begin 
    if (rst) begin 
        for (i = 0; i<2**ABITS; i = i+1 ) begin 
            dat_mem[i] <= {DBITS{1'd0}};
        end 
    end 
    else if (w_allow) begin 
        dat_mem[w_bin_ptr] <= w_data;
    end 
    else begin 
        dat_mem[w_bin_ptr] <= dat_mem[w_bin_ptr];
    end 
end 
////////////////////////////////////////////////////////////////////////////////

endmodule
////////////////////////////////////////////////////////////////////////////////