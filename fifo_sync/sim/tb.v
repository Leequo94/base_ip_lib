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
////////////////////////////////////////////////////////////////////////////////
// clock generator 
reg [63:0] n_clocks;
always # (CLK_Cyc/2) clk = ~clk;
////////////////////////////////////////////////////////////////////////////////
// 
parameter DBITS = 16;
parameter ABITS = 10;
parameter SHOWAHEAD = 0;
reg wren;
reg  [DBITS-1:0] wr_data;
wire [DBITS-1:0] rd_data;
wire [ABITS-1:0] counter;
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
        wren <= 1'd0;
        wr_data <= 8'd0;
    end   
    else if (n_clocks[9:0] >=500) begin  
        wren <= 1'd1; //!m_axis_tready;
        wr_data <= wr_data + 1'd1;
    end 
    else begin 
        wren <= 1'd0;//
        wr_data <= wr_data;
    end 
end 
////////////////////////////////////////////////////////////////////////////////
bfm_fifo_sync #(
    .SHOWAHEAD  (SHOWAHEAD      ),
    .ABITS      (ABITS  ),
    .DBITS      (DBITS  ),
    .FTHRD      (900    ),
    .ETHRD      (2      )
) bfm_inst
( 
    .clk         ( clk      ),//input           wire                
    .rst         ( !rst_n   ),//input           wire                
    .wr_data     ( wr_data  ),//input           wire    [DBITS-1:0] 
    .wren        ( wren     ),//input           wire                
    
    .rden        ( rden     ),//input           wire                
    .rd_data     ( rd_data  ),//input           wire                
    .wrfull      ( wrfull   ),//output          wire    [DBITS-1:0] 
    .rdempty     ( rdempty  ),//output          wire                
    .fifo_num    ( counter  ) //output          wire    [ABITS-1:0] 
);
////////////////////////////////////////////////////////////////////////////////
// check data 
reg rden_d;
always @ (posedge clk,negedge rst_n)
begin 
    if (!rst_n) begin 
        rden_d <= 0;
    end 
    else begin 
        rden_d <= rden;
    end 
end 
////////////////////////////////////////////////////////////////////////////////
reg state;
reg [DBITS-1:0] rdcnt;
always @ (posedge clk,negedge rst_n)
begin 
    if (!rst_n) begin 
        state <= 8'd0;
    end 
    else case (state) 
        1'd0: begin 
            if (counter >= 512)  begin 
                state <= 1'd1;
            end 
            rdcnt <= 0;
            end 
        1'd1: begin 
            if (rdcnt >= 500) begin 
                state <= 0;
            end 
            rdcnt <= rdcnt + 1;
            end 
    endcase  
end 
assign rden = (rdcnt >= 1 && rdcnt <= 500);
////////////////////////////////////////////////////////////////////////////////
wire dat_v;
assign dat_v = SHOWAHEAD ? rden : rden_d;
////////////////////////////////////////////////////////////////////////////////
reg [DBITS-1:0] chk_dat;
reg [DBITS-1:0] chk_err;
always @ (posedge clk,negedge rst_n)
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
