`timescale 1ns/1ps

module tb;

localparam CLK_Cyc = 10;

reg clk,rst_n;
reg rclk;
initial begin 
    clk = 0;
    rclk = 0;
    rst_n = 0;
    #200;
    rst_n = 1;
end 
////////////////////////////////////////////////////////////////////////////////
// clock generator 
reg [63:0] n_clocks;
always # (CLK_Cyc/2) clk = ~clk;
always # (CLK_Cyc*2/2) rclk = ~rclk;
wire wr_clk = clk;
wire rd_clk = rclk;
////////////////////////////////////////////////////////////////////////////////
// 
parameter DBITS = 16;
parameter ABITS = 10;
parameter SHOWAHEAD = 1;
reg wren;
reg  [DBITS-1:0] wr_data;
wire [DBITS-1:0] rd_data;
wire rd_empty;
wire rd_en = ~rd_empty;
////////////////////////////////////////////////////////////////////////////////
always @ (posedge wr_clk,negedge rst_n) begin 
    if (!rst_n) begin 
        n_clocks <= 'd0;
    end 
    else begin 
        n_clocks <= n_clocks + 1'd1;
    end 
end 
////////////////////////////////////////////////////////////////////////////////
always @ (posedge wr_clk,negedge rst_n)
begin 
    if (!rst_n) begin 
        wren <= 1'd0;
        wr_data <= 8'd0;
    end   
    else if (n_clocks[9:0] >=800) begin  
        wren <= 1'd1; //!m_axis_tready;
        wr_data <= wr_data + 1'd1;
    end 
    else begin 
        wren <= 1'd0;//
        wr_data <= wr_data;
    end 
end 
////////////////////////////////////////////////////////////////////////////////
bfm_fifo_async #(
    .SHOWAHEAD  (SHOWAHEAD      ),
    .FTHR       (800    ),
    .ETHR       (2      ),
    .ABITS      (ABITS  ),
    .DBITS      (DBITS  )
) bfm_inst
( 
    .wr_clk      ( wr_clk   ),//input           wire                
    .rst         ( !rst_n   ),//input           wire                
    .wr_data     ( wr_data  ),//input           wire    [DBITS-1:0] 
    .wr_en       ( wren     ),//input           wire                
    .wr_full     ( wr_full  ),//output          wire                
    
    .rd_clk      ( rd_clk   ),//input           wire                
    .rd_en       ( rd_en    ),//input           wire                
    .rd_data     ( rd_data  ),//input           wire                
    .rd_empty    ( rd_empty )//output          wire    [DBITS-1:0] 
);

////////////////////////////////////////////////////////////////////////////////
// check data 

reg rden_d;
always @ (posedge rd_clk,negedge rst_n)
begin 
    if (!rst_n) begin 
        rden_d <= 0;
    end 
    else begin 
        rden_d <= rd_en;
    end 
end 
////////////////////////////////////////////////////////////////////////////////
wire dat_v;
assign dat_v = SHOWAHEAD ? rd_en : rden_d;
////////////////////////////////////////////////////////////////////////////////
reg [DBITS-1:0] chk_dat;
reg [DBITS-1:0] chk_err;
always @ (posedge rd_clk,negedge rst_n)
begin 
    if (!rst_n) begin 
        chk_dat <= 1;
        chk_err <= 0;
    end 
    else if (dat_v) begin 
        chk_dat <= chk_dat + 1;
        if(chk_dat != rd_data) begin 
            chk_err <= chk_err+1;
        end 
    end 
    else begin 
        chk_dat <= chk_dat;
        chk_err <= chk_err;
    end 
end 
////////////////////////////////////////////////////////////////////////////////

endmodule 
