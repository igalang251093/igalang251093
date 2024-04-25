`timescale 1ns / 1ps

module counter0_999(input clk,
                   output [6:0]digit_disp, output [2:0]display);

wire flag_unidades;
wire flag_decenas;
wire div_clk;
wire div_clk_60hz;
wire [3:0]c_centenas;
wire [3:0]c_decenas;
wire [3:0]c_unidades;
wire [2:0]disp_sel;
wire [3:0]num_bin;



freq_div_60Hz(.clk(clk),.div_clk(div_clk_60hz));
shift_reg disp(.clk(div_clk_60hz),.disp(display),.disp2(disp_sel));

freq_div_1Hz(.clk(clk),.div_clk(div_clk));
counter0_9 unidades(.clk(div_clk),.reset(),.flag(flag_unidades),.cnt(c_unidades));
counter0_9 decenas(.clk(flag_unidades),.reset(),.flag(flag_decenas),.cnt(c_decenas));
counter0_9 centenas(.clk(flag_decenas),.reset(),.flag(),.cnt(c_centenas));

mux_cnt c3(.s2(disp_sel[2]),.s1(disp_sel[1]),.s0(disp_sel[0]),.Cinx_1(c_unidades[3]),.Cinx_2(c_decenas[3]),.Cinx_3(c_centenas[3]),.Coutx(num_bin[3]));
mux_cnt c2(.s2(disp_sel[2]),.s1(disp_sel[1]),.s0(disp_sel[0]),.Cinx_1(c_unidades[2]),.Cinx_2(c_decenas[2]),.Cinx_3(c_centenas[2]),.Coutx(num_bin[2]));
mux_cnt c1(.s2(disp_sel[2]),.s1(disp_sel[1]),.s0(disp_sel[0]),.Cinx_1(c_unidades[1]),.Cinx_2(c_decenas[1]),.Cinx_3(c_centenas[1]),.Coutx(num_bin[1]));
mux_cnt c0(.s2(disp_sel[2]),.s1(disp_sel[1]),.s0(disp_sel[0]),.Cinx_1(c_unidades[0]),.Cinx_2(c_decenas[0]),.Cinx_3(c_centenas[0]),.Coutx(num_bin[0]));

decod_bcd(.in_binary(num_bin),.segments(digit_disp));





endmodule

//===============DECODIFICADOR BCD 7 SEGMENTOS=====================================

module decod_bcd(input [3:0]in_binary,
                 output reg[6:0]segments);

 always@(*)
 begin
  case(in_binary)
   0:begin
     segments=7'b1111110;
     end
   1:begin
     segments=6'b0110000;
     end
   2:begin
     segments=7'b1101101;
     end  
   3:begin
     segments=7'b1111001;
     end   
   4:begin
     segments=7'b0110011;
     end
   5:begin
     segments=7'b1011011;
     end
   6:begin
     segments=7'b1011111;
     end  
   7:begin
     segments=7'b1110000;
     end   
   8:begin
     segments=7'b1111111;
     end
   9:begin
     segments=7'b1111011;
     end
   default : segments=7'b0000000;
   
  endcase
end                            
endmodule

//================MULTIPLEXOR 81====================================
                 
module mux_cnt(input s2,s1,s0,Cinx_1,Cinx_2,Cinx_3,
               output Coutx);

assign Coutx = !s2 && !s1 && s0 ? Cinx_1: 
               !s2 &&  s1 && !s0 ? Cinx_2:
                s2 && !s1 && !s0 ? Cinx_3: 1'b0;
                 
endmodule

//=================CONTADOR 0 A 9===================================
module counter0_9(input clk,reset,
                  output reg flag, output reg [3:0]cnt);

always @(posedge clk)begin

    if((reset == 1'b1) || cnt==4'd9)begin
        cnt <= 4'd0;
        flag <=1'b1;
    end 
    else begin
        cnt <= cnt+1'b1;
        flag <=1'b0;
    end   
end

endmodule


//===========SHIFT REGISTER===========================
module shift_reg(input clk,
                output reg [2:0]disp=3'b001, output reg [2:0]disp2=3'b001);


        
always@(posedge clk)
begin
    disp <= {disp[1:0],disp[2]};
    disp2 <= {disp2[1:0],disp2[2]};
end

endmodule

//=============GENERADOR DE SEÑAL A 1 HZ=========================
module freq_div_1Hz(
input clk,
output reg div_clk
);

reg [21:0]counter=22'd0;

always @(posedge clk) begin
    
    counter <= counter+1'b1;
    if(counter == 4000000)begin 
        counter <= 22'd0;
        div_clk <= div_clk^1'b1;
    end
end
endmodule

//=============GENERADOR DE SEÑAL A 60 HZ=========================

module freq_div_60Hz(
input clk,
output reg div_clk
);

reg [21:0]counter=22'd0;

always @(posedge clk) begin
    
    counter <= counter+1'b1;
    if(counter == 33333)begin 
        counter <= 22'd0;
        div_clk <= div_clk^1'b1;
    end
end
endmodule


