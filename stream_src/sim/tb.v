`timescale 1ns/1ps

module tb;

localparam CLK_Cyc = 10;

reg clk,rst_n;
initial begin 
    clk = 0;
    rst_n = 0;
    #200;
    rst_n = 1;
end 
parameter N = 100;
always # (CLK_Cyc/2) clk = ~clk;

reg [63:0] n_clocks;
reg m_axis_tready;
wire [15:0] m_axis_tdata;
reg [7:0] chk_data;
wire m_axis_tlast;
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clk,negedge rst_n) begin 
    if (!rst_n) begin 
        n_clocks <= 'd0;
    end 
    else begin 
        n_clocks <= n_clocks + 1'd1;
    end 
end 
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clk,negedge rst_n)
begin 
    if (!rst_n) begin 
        m_axis_tready <= 1'd0;
    end   
    else if (n_clocks[9:0] >=50) begin  
        m_axis_tready <= 1'd1; //!m_axis_tready;
    end 
    else begin 
        m_axis_tready <= 1'd0;//
    end 
end 
////////////////////////////////////////////////////////////////////////////////


bfm_src_stream_if bfm_inst( 
    .clk             ( clk              ),//input           wire               
    .rst_n           ( rst_n            ),//input           wire               
                                                                               
    .IMG_WIDTH       ( 1024             ),//input           wire    [15:0]     
    .IMG_HEIGHT      ( 64               ),//input           wire    [15:0]     
    .IMG_LINE_SPACE  ( 10               ),//input           wire    [15:0]     
    .IMG_FRAME_SPACE ( 20               ),//input           wire    [15:0]     
                                                                               
    // stream ports                                                            
    .m_axis_tready   ( m_axis_tready    ),//input           wire               
    .m_axis_tvalid   ( m_axis_tvalid    ),//output          wire               
    .m_axis_tdata    ( m_axis_tdata     ),//output          wire    [15:0]     
    .m_axis_tuser    ( m_axis_tuser     ),//output          wire               
    .m_axis_tlast    ( m_axis_tlast     ),//output          wire               
                                                                               
    .frame_cnt       ( frame_cnt        ) //output          wire    [15:0]     

);

////////////////////////////////////////////////////////////////////////////////
always @ (posedge clk,negedge rst_n)
begin 
    if (!rst_n) begin 
        chk_data <= 8'd0;
    end 
    else if (m_axis_tready & m_axis_tvalid) begin 
        chk_data <= chk_data + 1'd1;
    end 
    else begin 
        chk_data <= chk_data;
    end 
end 
////////////////////////////////////////////////////////////////////////////////
reg [7:0] chk_err;
always @ (posedge clk,negedge rst_n)
begin 
    if (!rst_n) begin 
        chk_err <= 0;
    end 
    else if ((m_axis_tready & m_axis_tvalid) && (m_axis_tdata != {chk_data,chk_data})) begin 
        chk_err <= chk_err + 1;
    end 
    else begin 
        chk_err <= chk_err;
    end 
end 
////////////////////////////////////////////////////////////////////////////////

endmodule 
