////////////////////////////////////////////////////////////////////////////////
//       !###########################!     Copyright(C),ZMvision Technology All 
//      !###########################!      rights FPGA Department
//     !##########!!!!!!###########!       
//    !########!           !######!        FileName:   fifo_rptr_gen.v
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
// fifo read pointer generator
// @todo list :
// 
// History:  //modified list 
//     1.  Date:
//         Author:
//         Modification:
//     2.  ......
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps 
module fifo_rptr_gen #(
    parameter   SHOWAHEAD    = 1,
    parameter   ABITS        = 10,
    parameter   DBITS        = 16
)( 
    input           wire                rdclk,
    input           wire                rst,
    input           wire                rd_en,
    input           wire    [DBITS-1:0] r_data,
    output          wire    [DBITS-1:0] rd_data,
    output          wire    [ABITS-1:0] rd_bin_ptr,
    input           wire                rd_empty
);
////////////////////////////////////////////////////////////////////////////////
// parameter 

////////////////////////////////////////////////////////////////////////////////
// internal register and net declare 
reg [ABITS-1 :0] rd_bin_ptr_r;
wire             rd_allow;
////////////////////////////////////////////////////////////////////////////////
// internal interconnect 
assign rd_allow = rd_en&(~rd_empty);
assign rd_bin_ptr = rd_bin_ptr_r;
////////////////////////////////////////////////////////////////////////////////
// internal logic 
////////////////////////////////////////////////////////////////////////////////
always @ (posedge rdclk,posedge rst)
begin 
    if (rst) begin 
        rd_bin_ptr_r <= {ABITS{1'd0}};
    end 
    else if (rd_allow) begin 
        rd_bin_ptr_r <= rd_bin_ptr_r + 1'd1;
    end 
    else begin 
        rd_bin_ptr_r <= rd_bin_ptr_r;
    end 
end 
////////////////////////////////////////////////////////////////////////////////
generate 
    if (SHOWAHEAD == 1) begin 
        assign rd_data[DBITS-1:0] = r_data[DBITS-1:0];
    end 
    else begin 
        reg [DBITS-1:0] rd_data_r;
        always @ (posedge rdclk,posedge rst) begin 
            if (rst) begin 
                rd_data_r <= {DBITS{1'd0}};
            end 
            else if (rd_allow) begin 
                rd_data_r <= r_data;
            end 
            else begin 
                rd_data_r <= rd_data_r;
            end 
        end 
        assign rd_data = rd_data_r;
    end 
endgenerate 
////////////////////////////////////////////////////////////////////////////////

endmodule
////////////////////////////////////////////////////////////////////////////////