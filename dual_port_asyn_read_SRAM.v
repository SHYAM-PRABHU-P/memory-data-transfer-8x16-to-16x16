`timescale 1ns / 1ps


module dual_port_asyn_read_SRAM #(parameter w=8,parameter d=16)(
    input clk,w_en,
	 input [$clog2(d)-1:0]ad_rd,
	 input [$clog2(d)-1:0]ad_wr,
	 input [w-1:0]wr_d,
    output [w-1:0]rd_d
    );
    reg [w-1:0] ram [0:d-1];
	 
	 always @(posedge clk) begin
		if(w_en) begin
			ram[ad_wr]<=wr_d;
		end
	 end
		assign rd_d=ram[ad_rd];
endmodule
