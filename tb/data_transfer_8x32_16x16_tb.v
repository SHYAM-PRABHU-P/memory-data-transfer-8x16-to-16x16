`timescale 1ns / 1ps


module data_transfer_8x32_16x16_tb();
    reg clk=1;
    reg rst;
    reg[4:0]wr_ad;
    reg [7:0]wr_d;
    reg w_en;
    reg [3:0]rd_ad;
    wire [15:0]rd_d;
    reg op;
    wire done ;
    integer i;
    
    data_transfer_8x32_16x16 utt(.clk(clk),.rst(rst),.R_in_ad_wr(wr_ad),.R_in_wr_d(wr_d),.R_in_w_en(w_en),
    .R_out_ad_rd(rd_ad),.R_out_rd_d(rd_d),.op(op),.done(done));
    
    always begin
        clk=~clk;#0.5;
    end
    
    
    task write(input [4:0]ad,input [7:0]data);
        begin
            @(posedge clk);
            w_en=1'b1;
            wr_ad=ad;
            wr_d=data;
            @(posedge clk);
            $display("WRITE---ADDRESS IN:%0d,DATA_IN:%0d",wr_ad,wr_d);
            w_en=1'b0;
        end
    endtask
    
    task read(input [3:0]ad);
        begin
            @(posedge clk);
            rd_ad=ad;
            @(posedge clk);
            $display("READ---ADDRESS OUT:%0d,DATA_OUT:%0d",rd_ad,rd_d);
        end
    endtask
    
    initial begin
        w_en=0;//
        wr_ad=0;//
        op=0;//
        rst=0;
        @(posedge clk);
        rst=1;
        //WRITE IN DATA TO THE 8X32 RAM
      
        for(i=0;i<32;i=i+1) begin
            write(i,2*i);
        end
        
        @(posedge clk);
          op=1;
        @(posedge clk);
        op=0;
        
        //READ OUT FROM THE 16X16 RAM 
        @(posedge clk);
        wait(done==1);
        for(i=0;i<16;i=i+1) begin
            read(i);    
        end
    end
endmodule
