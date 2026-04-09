`timescale 1ns / 1ps

module data_transfer_8x32_16x16(
    input clk,rst,
    input [4:0]R_in_ad_wr,
    input [7:0]R_in_wr_d,
    input R_in_w_en,
    input [3:0]R_out_ad_rd,
    output [15:0]R_out_rd_d,
    input op,
    output reg done 
    );
    
    parameter [1:0] IDLE=2'd0;
    parameter [1:0] READ_1=2'd1;
    parameter [1:0] READ_2=2'd2;
    parameter [1:0] WRITE_1_2=2'd3;
    
    reg [1:0]state;
    reg [1:0]next_state;
    //FSM RAM-IN PORTS
    reg [4:0]fsm_ad_rd;
    wire [7:0]fsm_rd_d;
    
    reg [4:0]ram_pointer;
    //FSM RAM-OUT PORTS
    reg [3:0]fsm_ad_wr;
    reg [7:0]byte_1;
    reg [7:0]byte_2;
    reg fsm_w_en;
    
    dual_port_asyn_read_SRAM #(.w(8),.d(32)) RAM_in (.clk(clk), 
		.ad_rd(fsm_ad_rd), 
		.ad_wr(R_in_ad_wr), 
		.wr_d(R_in_wr_d), 
		.w_en(R_in_w_en), 
		.rd_d(fsm_rd_d));
    dual_port_asyn_read_SRAM #(.w(16),.d(16)) RAM_out (.clk(clk), 
		.ad_rd(R_out_ad_rd), 
		.ad_wr(fsm_ad_wr), 
		.wr_d({byte_1,byte_2}), 
		.w_en(fsm_w_en), 
		.rd_d(R_out_rd_d));
	
	//FSM STATE TRANSITION	
	always @(*) begin
	   next_state=IDLE;
	   //done=1'b0;
	   fsm_ad_rd=0;
	   fsm_w_en=0;
	   case(state)
	       IDLE    :   if(op==1'b1)
	                       next_state=READ_1;
	                   /*else
	                       next_state=IDLE;*/
	       READ_1  :   begin
	                       fsm_ad_rd=ram_pointer;
	                       next_state=READ_2;
	                   end
	       READ_2  :   begin
	                       fsm_ad_rd=ram_pointer;
	                       next_state=WRITE_1_2;
	                   end
	   WRITE_1_2   :   begin
	                       if(done==1) begin
	                           next_state=IDLE;
	                       end
	                       else begin
	                           next_state=READ_1;
	                       end
	                           fsm_w_en=1'b1;
	                   end
	      default  :   next_state=IDLE;   
	   endcase	  
	end
	
	always @(posedge clk or negedge rst) begin
	   if(!rst)
	       state<=IDLE;
	   else
	       state<=next_state;
	end
	
	//FSM PORT DESIGN
	always @(posedge clk or negedge rst) begin
	   if(!rst)
	       ram_pointer<=0;
	   else if((state==READ_1) || (state==READ_2))
	       ram_pointer<=ram_pointer+1;
	end
	
	always @(posedge clk or negedge rst) begin
        if(!rst)
            fsm_ad_wr<=0;
        else if(state==READ_1)
            fsm_ad_wr<=(ram_pointer>>1);
    end
    
    always @(posedge clk or negedge rst) begin
        if(!rst) 
            done<=0;
        else if(op==1)
            done<=0;
        else if(ram_pointer==5'd31)
            done<=1'b1;
    end
    
    always @(posedge clk or negedge rst) begin
        if(!rst) begin 
            byte_2<=0;
            byte_1<=0;
        end
        else begin
            byte_2<=fsm_rd_d;
            byte_1<=byte_2;
        end
    end
	
endmodule
