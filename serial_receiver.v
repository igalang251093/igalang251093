`timescale 1ns / 1ps


/*
SERIAL RECEIVER
This project is being implemented with CMOD A7-35T Board by Digilent which has an Integrated Clock of 12 MHz.
The speed that is configured is 115200 bauds, in order to make this possible is necesary to scan data each
 12000000/115200 = 104.16 clock cycles

*/

module Serial_Rx_TOP(input i_Clk, i_Rx_Data, output reg[6:0]o_Disp, output display1, output display2);

    parameter LIMIT =66666;
    wire [7:0] Binary_Data_8bit;
    wire [6:0] r_Disp1;
    wire [6:0] r_Disp2;
    reg  [22:0] cnt_register;
    reg [1:0] r_display = 2'b01;
    reg flag;
    Serial_Rx #(104)(.i_Clk(i_Clk), .Rx_Data(i_Rx_Data), .Data(Binary_Data_8bit));
    decod_bcd disp_decenas (.in_binary(Binary_Data_8bit[7:4]), .segments(r_Disp1));
    decod_bcd disp_unidades (.in_binary(Binary_Data_8bit[3:0]), .segments(r_Disp2));
    
    
    always@(posedge i_Clk)begin
        
        if(cnt_register == LIMIT)begin
            r_display[1] <= r_display[0];
            r_display[0] <= r_display[1];
            cnt_register <= 0;
            if(r_display == 2'b01)
                o_Disp <= r_Disp1;
            else
                o_Disp <= r_Disp2;
        end 
        
        else
            cnt_register <= cnt_register + 1;   
    end

assign display1 = r_display[0];
assign display2 = r_display[1];

endmodule



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
   10:begin
     segments=7'b1110111;
     end
   11:begin
     segments=7'b0011111;
     end
   12:begin
     segments=7'b1001110;
     end
   13:begin
     segments=7'b0111101;
     end
   14:begin
     segments=7'b1001111;
     end
   15:begin
     segments=7'b1000111;
     end
     

   default : segments=7'b0000000;
   
  endcase
end                            
endmodule




module Serial_Rx#(parameter CLK_PER_BIT=104)(input i_Clk, input Rx_Data, output reg [7:0] Data);


parameter IDLE = 3'd0;
parameter START = 3'd1;
parameter READ = 3'd2;
parameter STOP = 3'd3;
parameter CLEAN = 3'd4;


reg [3:0]State;
reg [7:0]Cycle_Cnt;
reg [3:0]Index_Bit;
reg [7:0]r_Data;

always @(posedge i_Clk)
begin 
    case(State)
    
    IDLE: 
    begin
        Cycle_Cnt <= 0;
        Index_Bit <= 0;
        
        if(Rx_Data == 0)
            State <= START;
        else
            State <= IDLE;
    end
    
    START: 
    begin 
        if(Cycle_Cnt == (CLK_PER_BIT-1)/2)begin
            if(Rx_Data == 0)begin
                State <= READ;
                Cycle_Cnt <= 0;
            end
            else
                State <= IDLE;
         end
         
         else begin
            Cycle_Cnt <= Cycle_Cnt + 1;
            State <= START;     
         end    
    end
    
    READ: 
    begin
        if(Cycle_Cnt < CLK_PER_BIT)begin
            Cycle_Cnt <= Cycle_Cnt + 1;
            State <= READ;
        end
        
        else begin
            r_Data[Index_Bit] <= Rx_Data;
            Cycle_Cnt <= 0;
            
            if(Index_Bit < 7)begin
                Index_Bit = Index_Bit +1 ;
                State <= READ;
            end
            
            else begin
                Index_Bit <= 0;
                State <= STOP;
            end
            
        end
    
    end
    
    STOP: 
    begin
        if(Cycle_Cnt < CLK_PER_BIT)begin
            Cycle_Cnt <= Cycle_Cnt + 1;
            State <= STOP;
        end
        
        else begin
            Data <= r_Data;
            State <= CLEAN;
            Cycle_Cnt <= 0;
            
        end
    end

    CLEAN: 
    begin
        State <= IDLE;
    end
    
    default:
    begin
        State <= IDLE;
    end
    
    endcase
    
end


endmodule

