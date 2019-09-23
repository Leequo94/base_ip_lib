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
////////////////////////////////////////////////////////////////////////////////

reg                     apb_ready      ;
reg                     apb_slverr     =0;
wire                    apb_sel        ;
wire                    apb_enable     ;
wire                    apb_write      ;
wire    [DBITS-1:0]     apb_addr       ;
wire    [ABITS-1:0]     apb_wdata      ;
wire    [15:0]          apb_cfg_err    ;
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
reg usr_transfer;
always @ (posedge clk,negedge rst_n)
begin 
    if (!rst_n) begin 
        usr_transfer <= 1'd0;
    end 
    else if (&n_clocks[9:0]) begin 
        usr_transfer <= 1'd1;
    end 
    else begin 
        usr_transfer <= 1'd0;
    end 
end 
////////////////////////////////////////////////////////////////////////////////
//always @ (posedge clk,negedge rst_n)
//begin 
//    if (!rst_n) begin 
//        apb_ready <= 1'd0;
//    end 
//    else if (~apb_ready & apb_enable) begin 
//        apb_ready <= 1'd1;
//    end 
//    else begin 
//        apb_ready <= 1'd0;
//    end 
//end 
always @ (*)
begin 
    if (!rst_n) begin 
        apb_ready <= 1'd0;
    end 
    else if (apb_enable) begin 
        apb_ready <= 1'd1;
    end 
    else begin 
        apb_ready <= 1'd0;
    end 
end 
////////////////////////////////////////////////////////////////////////////////

apb_master #(
    .DBITS ( DBITS ),
    .ABITS ( ABITS )
) bfm_inst
( 
    .apb_clk        ( clk           ), // input           wire                
    .apb_rst_n      ( rst_n         ), // input           wire                
    .usr_transfer   ( usr_transfer  ), // input           wire                
    .apb_ready      ( apb_ready     ), // input           wire                
    .apb_slverr     ( apb_slverr    ), // input           wire                
    .apb_sel        ( apb_sel       ), // output          wire                
    .apb_enable     ( apb_enable    ), // output          wire                
    .apb_write      ( apb_write     ), // output          wire                
    .apb_addr       ( apb_addr      ), // output          wire    [DBITS-1:0] 
    .apb_wdata      ( apb_wdata     ), // output          wire    [ABITS-1:0] 
    .apb_cfg_err    ( apb_cfg_err   )  // output          wire    [15:0]      
);
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////

endmodule 
