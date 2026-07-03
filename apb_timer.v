`timescale 1ns/1ps
module apb_timer#(parameter WIDTH = 8) (
	input wire  PCLK,		//Active Clock
	input wire  PRESETn,		//Active low reset
	input wire  PSEL,		//Peripheral Select
	input wire  PENABLE,		//Access Phase indicator
	input wire  PWRITE,		//1 = write; 0 = read
	input wire  [7:0] PADDR,	//Register Address
	input wire  [31:0] PWDATA,	//Write data
	output reg   [31:0] PRDATA,	//Read data
	output reg timer_done 	//Timer status output
);

//Internal timer registers
reg [WIDTH-1:0] LOAD_REG;  //Programmed timer value
reg [WIDTH-1:0] COUNT_REG; //Active counter
reg STATUS_REG;		   //Timer enable

//APB Write
//PSEL = 1; PENABLE = 1; PWRITE = 1;

always@(posedge PCLK or negedge PRESETn) begin
	if(!PRESETn) begin
		LOAD_REG <= 0;
		COUNT_REG <= 0;
	end
	else if(PSEL && PENABLE && PWRITE) begin
		case(PADDR)
			8'h00: LOAD_REG <= PWDATA[WIDTH-1:0];
			8'h04: STATUS_REG <= |PWDATA;
		endcase
	end
end

//APB Read
//PSEL = 1; PWRITE = 0;
always@(*) begin
	PRDATA = 32'h0;

	if(PSEL && !PWRITE) begin
		case(PADDR)
			8'h00: PRDATA = {{(32 - WIDTH){1'b0}}, LOAD_REG};
			8'h04: PRDATA = {31'b0, STATUS_REG};
			8'h08: PRDATA = {31'b0, timer_done};
			default: PRDATA = 32'b0;
		endcase
	end
end

//Timer Logic
//Counter decrements while running
//on reaching zero, timer done is asserted

always@(posedge PCLK or negedge PRESETn) begin
	if (!PRESETn) begin
		COUNT_REG <= 0;
		timer_done <= 0;
	end
	else if(STATUS_REG) begin
		if(COUNT_REG == 0) begin
			COUNT_REG <= LOAD_REG;
			timer_done <= 1;
			STATUS_REG <= 0;
		end
		else begin
			COUNT_REG <= COUNT_REG - 1;
			timer_done <= 0;
		end
	end
end
endmodule


			
