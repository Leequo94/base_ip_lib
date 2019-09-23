////////////////////////////////////////////////////////////////////////////////
//       !###########################!     Copyright(C),ZMvision Technology All 
//      !###########################!      rights FPGA Department
//     !##########!!!!!!###########!       
//    !########!           !######!        FileName:   apb_master.v
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
// amba-apb3.0 master behavior function module, and compatible amba2.0 
// @todo list :
// 
// History:  //modified list 
//     1.  Date:
//         Author:
//         Modification:
//     2.  ......
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps 

`define AMBA3_APB

module apb_master #(
    parameter       DBITS = 32,
    parameter       ABITS = 16
)( 
    input           wire                apb_clk,
    input           wire                apb_rst_n,
    input           wire                usr_transfer,
    `ifdef AMBA3_APB
    input           wire                apb_ready,
    input           wire                apb_slverr,
    `endif 
    output          wire                apb_sel,
    output          wire                apb_enable,
    output          wire                apb_write,
    output          wire    [DBITS-1:0] apb_addr,
    output          wire    [ABITS-1:0] apb_wdata,
    output          wire    [15:0]      apb_cfg_err
);
////////////////////////////////////////////////////////////////////////////////
// parameter 
parameter TRANS_NUM = 8;
parameter IDLE      = 0;
parameter SETUP     = 1;
parameter ACCESS    = 2;
parameter DELAY     = 3;
////////////////////////////////////////////////////////////////////////////////
// internal register and net declare 
`ifndef AMBA3_APB
    reg apb_ready = 1'd1;
    reg apb_slverr = 1'd0;
`endif 
reg             apb_sel_r;
reg             apb_enable_r;
reg             apb_write_r;
reg [ABITS-1:0] apb_addr_r;
reg [DBITS-1:0] apb_wdata_r;
reg [ABITS-1:0] apb_addr_reg[TRANS_NUM-1:0];
reg [DBITS-1:0] apb_data_reg[TRANS_NUM-1:0];
reg [1:0] state;
reg [15:0] trans_cnt;
reg [15:0] error_cnt;
////////////////////////////////////////////////////////////////////////////////
// internal interconnect 
assign apb_sel = apb_sel_r;
assign apb_enable = apb_enable_r;
assign apb_write = apb_write_r;
assign apb_addr = apb_addr_r;
assign apb_wdata = apb_wdata_r;
assign apb_cfg_err = error_cnt;
////////////////////////////////////////////////////////////////////////////////
// internal logic 
////////////////////////////////////////////////////////////////////////////////
always @ (posedge apb_clk) 
begin 
    apb_addr_reg[0] <= 32'h00;
    apb_addr_reg[1] <= 32'h01;
    apb_addr_reg[2] <= 32'h02;
    apb_addr_reg[3] <= 32'h03;
    apb_addr_reg[4] <= 32'h04;
    apb_addr_reg[5] <= 32'h05;
    apb_addr_reg[6] <= 32'h06;
    apb_addr_reg[7] <= 32'h07;
    
    apb_data_reg[0] <= 32'h00;
    apb_data_reg[1] <= 32'h11;
    apb_data_reg[2] <= 32'h22;
    apb_data_reg[3] <= 32'h33;
    apb_data_reg[4] <= 32'h44;
    apb_data_reg[5] <= 32'h55;
    apb_data_reg[6] <= 32'h66;
    apb_data_reg[7] <= 32'h77;
end 
////////////////////////////////////////////////////////////////////////////////
reg usr_transfer_d0;
reg usr_transfer_d1;
always @ (posedge apb_clk,posedge apb_rst_n)
begin 
    if (!apb_rst_n) begin 
        usr_transfer_d0 <= 1'd0;
        usr_transfer_d1 <= 1'd0;
    end 
    else begin 
        usr_transfer_d0 <= usr_transfer;
        usr_transfer_d1 <= usr_transfer_d0;
    end 
end 
////////////////////////////////////////////////////////////////////////////////
always @ (posedge apb_clk,negedge apb_rst_n)
begin 
    if (!apb_rst_n) begin 
        state <= IDLE;
    end 
    else case (state)
        IDLE: 
            if (!usr_transfer_d1 & usr_transfer_d0) begin 
                state <= SETUP;
            end 
            else begin 
                state <= IDLE;
            end 
        SETUP:
            begin 
                state <= ACCESS;
            end 
        ACCESS: 
            if (apb_ready) begin 
                if (trans_cnt < TRANS_NUM-1) begin 
                    state <= DELAY;
                end 
                else begin 
                    state <= IDLE;
                end 
            end 
            else begin 
                state <= ACCESS;
            end 
        DELAY:
            state <= SETUP;
    endcase 
end 
////////////////////////////////////////////////////////////////////////////////
always @ (posedge apb_clk,negedge apb_rst_n)
begin 
    if (!apb_rst_n) begin 
        apb_sel_r <= 1'd0;
        apb_write_r <= 1'd0;
    end 
    else if (state == IDLE) begin 
        if (!usr_transfer_d1 & usr_transfer_d0) begin 
            apb_sel_r <= 1'd1;
            apb_write_r <= 1'd1;
        end 
        else begin 
            apb_sel_r <= 1'd0;
            apb_write_r <= 1'd0;
        end 
    end 
    else begin 
        apb_sel_r <= apb_sel_r;
        apb_write_r <= apb_write_r;
    end 
end 
////////////////////////////////////////////////////////////////////////////////
always @ (posedge apb_clk,negedge apb_rst_n)
begin 
    if (!apb_rst_n) begin 
        apb_enable_r <= 1'd0;
    end 
    else if (state == SETUP) begin 
        apb_enable_r <= 1'd1;
    end 
    else if ((state == ACCESS) & apb_ready) begin 
        apb_enable_r <= 1'd0;
    end 
    else begin 
        apb_enable_r <= apb_enable_r;
    end 
end 
////////////////////////////////////////////////////////////////////////////////
always @ (posedge apb_clk,negedge apb_rst_n)
begin 
    if (!apb_rst_n) begin 
        apb_addr_r  <= apb_addr_reg[0];
        apb_wdata_r <= apb_data_reg[0];
    end 
    else begin 
        apb_addr_r  <= apb_addr_reg[trans_cnt];
        apb_wdata_r <= apb_data_reg[trans_cnt];
    end 
end 
////////////////////////////////////////////////////////////////////////////////
always @ (posedge apb_clk,negedge apb_rst_n)
begin 
    if (!apb_rst_n) begin 
        trans_cnt <= 16'd0;
    end 
    else if (state == IDLE) begin 
        trans_cnt <= 16'd0;
    end 
    else if (state == DELAY)begin 
        trans_cnt <= trans_cnt + 1'd1;
    end 
end 
////////////////////////////////////////////////////////////////////////////////
always @ (posedge apb_clk,negedge apb_rst_n)
begin 
    if (!apb_rst_n) begin 
        error_cnt <= 16'd0;
    end 
    else if (state == IDLE) begin 
        error_cnt <= 16'd0;
    end 
    else if ((state == ACCESS)&(apb_ready&apb_slverr)) begin 
        error_cnt <= error_cnt + 1'd0;
    end 
    else begin 
        error_cnt <= error_cnt;
    end 
end 
////////////////////////////////////////////////////////////////////////////////

endmodule
////////////////////////////////////////////////////////////////////////////////