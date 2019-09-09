////////////////////////////////////////////////////////////////////////////////
//       !###########################!     Copyright(C),ZMvision Technology All 
//      !###########################!      rights FPGA Department
//     !##########!!!!!!###########!       
//    !########!           !######!        FileName:   bfm_src_stream_if.v
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
// stream inner source for image, verify ok
// @todo list :
// 
// History:  //modified list 
//     1.  Date:
//         Author:
//         Modification:
//     2.  ......
////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps 
module bfm_src_stream_if ( 
    input           wire                clk,
    input           wire                rst_n,
    
    input           wire    [15:0]      IMG_WIDTH,
    input           wire    [15:0]      IMG_HEIGHT, 
    input           wire    [15:0]      IMG_LINE_SPACE,
    input           wire    [15:0]      IMG_FRAME_SPACE,
    
    // stream ports
    input           wire                m_axis_tready,
    output          wire                m_axis_tvalid,
    output          wire    [15:0]      m_axis_tdata,
    output          wire                m_axis_tuser,
    output          wire                m_axis_tlast,
    
    output          wire    [15:0]      frame_cnt

);
////////////////////////////////////////////////////////////////////////////////
// parameter 

////////////////////////////////////////////////////////////////////////////////
// internal register and net declare 
reg [15:0] cnt_col;
reg [15:0] cnt_row;
reg [15:0] space_cnt;
reg [15:0] frame_cnt_r;
reg [7:0] m_axis_tdata_r;
reg [1:0]  state;
reg m_axis_tuser_r;
reg m_axis_tlast_r;
reg m_axis_tvalid_r;
////////////////////////////////////////////////////////////////////////////////
// internal interconnect 

////////////////////////////////////////////////////////////////////////////////
// internal logic 
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clk,negedge rst_n)
begin 
    if (!rst_n) begin 
        state <= 2'd0;
    end 
    else case (state)
        2'd0:
            if (m_axis_tready) begin 
                state <= 2'd1;
            end 
            else begin 
                state <= 2'd0;
            end 
        2'd1:
            if ((m_axis_tready&m_axis_tvalid_r) && (cnt_col == IMG_WIDTH -2) && (cnt_row == IMG_HEIGHT -1)) begin 
                state <= 2'd3;
            end 
            else if ((m_axis_tready&m_axis_tvalid_r) && (cnt_col == IMG_WIDTH -2)) begin 
                state <= 2'd2;
            end 
            else begin 
                state <= 2'd1;
            end 
        2'd2:
            if (space_cnt >= IMG_LINE_SPACE-1) begin 
                state <= 2'd1;
            end 
            else begin 
                state <= 2'd2;
            end 
        2'd3:
            if (space_cnt >= IMG_FRAME_SPACE-2) begin 
                state <= 2'd0;
            end 
    endcase 
end 
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clk,negedge rst_n)
begin 
    if (!rst_n) begin 
        cnt_col <= 16'd0;
    end 
    else if (state == 1) begin 
        if (m_axis_tready&m_axis_tvalid_r) begin 
            cnt_col <= cnt_col + 1'd1;
        end 
        else begin 
            cnt_col <= cnt_col;
        end 
    end 
    else begin 
        cnt_col <= 16'd0;
    end 
end 
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clk,negedge rst_n)
begin 
    if (!rst_n) begin 
        cnt_row <= 16'd0;
    end 
    //else if (state == 1) begin 
    else if ((cnt_col == IMG_WIDTH -1) && (cnt_row == IMG_HEIGHT-1) && (m_axis_tready&m_axis_tvalid_r)) begin 
        cnt_row <= 16'd0;
    end 
    else if ((cnt_col == IMG_WIDTH -1) && (m_axis_tready&m_axis_tvalid_r)) begin 
        cnt_row <= cnt_row + 1'd1;
    end 
    else begin 
        cnt_row <= cnt_row;
    end 
end 
////////////////////////////////////////////////////////////////////////////////
always @ (*)
begin 
    if (!rst_n) begin 
        m_axis_tuser_r <= 1'd0;
    end 
    else if (cnt_col == 0 && cnt_row == 0 && (m_axis_tready&m_axis_tvalid_r)) begin 
        m_axis_tuser_r <= 1'd1;
    end 
    else begin 
        m_axis_tuser_r <= 1'd0;
    end 
end 
assign m_axis_tuser = m_axis_tuser_r;
////////////////////////////////////////////////////////////////////////////////
always @ (*)
begin 
    if (!rst_n) begin 
        m_axis_tlast_r <= 1'd0;
    end 
    else if ((m_axis_tready&m_axis_tvalid_r) && cnt_col == IMG_WIDTH-1) begin 
        m_axis_tlast_r <= 1'd1;
    end 
    else begin 
        m_axis_tlast_r <= 1'd0;
    end 
end 
assign m_axis_tlast = m_axis_tlast_r;

////////////////////////////////////////////////////////////////////////////////
always @ (posedge clk,negedge rst_n)
begin 
    if (!rst_n) begin 
        m_axis_tvalid_r <= 1'd0;
    end 
    else if (state == 1 )begin 
        m_axis_tvalid_r <= 1'd1;
    end 
    else begin 
        m_axis_tvalid_r <= 1'd0;
    end 
end 
assign m_axis_tvalid = m_axis_tvalid_r;
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clk,negedge rst_n)
begin 
    if (!rst_n) begin 
        m_axis_tdata_r <= 16'd0;
    end 
    else if (m_axis_tvalid_r&m_axis_tready) begin 
        m_axis_tdata_r <= m_axis_tdata_r + 1'd1;
    end 
    else begin 
        m_axis_tdata_r <= m_axis_tdata_r;
    end 
end 
assign m_axis_tdata = {3{m_axis_tdata_r}};
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clk,negedge rst_n)
begin 
    if (!rst_n) begin 
        space_cnt <= 16'd0;
    end 
    else if (state == 2 || state == 3) begin 
        space_cnt <= space_cnt + 1'd1;
    end 
    else begin 
        space_cnt <= 16'd0;
    end 
end 
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clk,negedge rst_n)
begin 
    if (!rst_n) begin 
        frame_cnt_r <= 16'd0;
    end 
    else if (state == 3 && space_cnt == IMG_FRAME_SPACE-1) begin 
        frame_cnt_r <= frame_cnt_r + 1'd1;
    end 
    else begin 
        frame_cnt_r <= frame_cnt_r;
    end 
end 
assign frame_cnt = frame_cnt_r;
////////////////////////////////////////////////////////////////////////////////
endmodule
////////////////////////////////////////////////////////////////////////////////