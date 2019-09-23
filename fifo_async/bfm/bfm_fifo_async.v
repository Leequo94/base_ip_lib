////////////////////////////////////////////////////////////////////////////////
//       !###########################!     Copyright(C),ZMvision Technology All 
//      !###########################!      rights FPGA Department
//     !##########!!!!!!###########!       
//    !########!           !######!        FileName:   bfm_fifo_async.v
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
// asynchronous fifo includes showahead and normal two modes of operation;
// @todo list :
// 
// History:  //modified list 
//     1.  Date:
//         Author:
//         Modification:
//     2.  ......
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps 
module bfm_fifo_async #(
    parameter   SHOWAHEAD   = 1, // 1-showahead 0-normal 
    parameter   FTHR        = 800, // full active threshold,this value maximum is 2**ABITS;
    parameter   ETHR        = 2, // empty active threshold value,this value minimum is 0;
    parameter   ABITS       = 10,
    parameter   DBITS       = 16
)( 
    input           wire                wr_clk,
    input           wire                rst,
    input           wire    [DBITS-1:0] wr_data,
    input           wire                wr_en,
    output          wire                wr_full,
    
    input           wire                rd_clk,
    input           wire                rd_en,
    output          wire    [DBITS-1:0] rd_data,
    output          wire                rd_empty
);
////////////////////////////////////////////////////////////////////////////////
// parameter 

////////////////////////////////////////////////////////////////////////////////
// internal register and net declare 
wire    [ABITS-1:0] wr_bin_ptr ;
wire                wr_allow   ;
wire    [DBITS-1:0] r_data     ;
wire    [ABITS-1:0] rd_bin_ptr ;

////////////////////////////////////////////////////////////////////////////////
// internal interconnect 

////////////////////////////////////////////////////////////////////////////////
// internal logic 
////////////////////////////////////////////////////////////////////////////////
fifo_wptr_gen #(
    .ABITS ( ABITS ),
    .DBITS ( DBITS )
) fifo_wptr_gen_inst 
( 
    .wrclk       ( wr_clk       ), // input           wire                
    .rst         ( rst          ), // input           wire                
    .wr_en       ( wr_en        ), // input           wire                
    .wr_bin_ptr  ( wr_bin_ptr   ), // output          wire    [ABITS-1:0] 
    .wr_allow    ( wr_allow     ), // output          wire                
    .wr_full     ( wr_full      )  // input           wire                
);
fifo_mem #(
    .ABITS ( ABITS ),
    .DBITS ( DBITS )
)fifo_mem_inst 
( 
    .wclk        ( wr_clk       ), // input           wire                
    .rst         ( rst          ), // input           wire                
    .w_data      ( wr_data      ), // input           wire    [DBITS-1:0] 
    .w_bin_ptr   ( wr_bin_ptr   ), // input           wire    [ABITS-1:0] 
    .w_allow     ( wr_allow     ), // input           wire                
    
    .r_bin_ptr   ( rd_bin_ptr   ), // input           wire    [ABITS-1:0] 
    .r_data      ( r_data       )  // output          wire    [DBITS-1:0] 
);
fifo_rptr_gen #(
    .SHOWAHEAD  ( SHOWAHEAD ),
    .ABITS      ( ABITS     ),
    .DBITS      ( DBITS     )
) fifo_rptr_gen_inst 
( 
    .rdclk       ( rd_clk       ), // input           wire                
    .rst         ( rst          ), // input           wire                
    .rd_en       ( rd_en        ), // input           wire                
    .r_data      ( r_data       ), // input           wire    [DBITS-1:0] 
    .rd_data     ( rd_data      ), // output          wire    [DBITS-1:0] 
    .rd_bin_ptr  ( rd_bin_ptr   ), // output          wire    [ABITS-1:0] 
    .rd_empty    ( rd_empty     )  // input           wire                
);
fifo_full_gen #(
    .FTHR       ( FTHR      ),
    .ABITS      ( ABITS     ),
    .DBITS      ( DBITS     )
) fifo_full_gen_inst 
( 
    .wrclk       ( wr_clk       ), // input           wire                
    .rst         ( rst          ), // input           wire                
    .wr_bin_ptr  ( wr_bin_ptr   ), // input           wire    [ABITS-1:0] 
    .rd_bin_ptr  ( rd_bin_ptr   ), // input           wire    [ABITS-1:0] 
    .wr_full     ( wr_full      )  // output          wire                
);
fifo_empty_gen #(
    .ETHR       ( ETHR      ),
    .ABITS      ( ABITS     ),
    .DBITS      ( DBITS     )
) fifo_empty_gen_inst 
( 
    .rdclk       ( rd_clk       ), // input           wire                
    .rst         ( rst          ), // input           wire                
    .wr_bin_ptr  ( wr_bin_ptr   ), // output          wire    [ABITS-1:0] 
    .rd_bin_ptr  ( rd_bin_ptr   ), // output          wire    [ABITS-1:0] 
    .rd_empty    ( rd_empty     )  // output          wire                
);
endmodule
////////////////////////////////////////////////////////////////////////////////