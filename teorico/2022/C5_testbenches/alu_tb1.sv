
`timescale 1ns / 1ps

module alu_tb1();  

	parameter N = 16;
	
	logic          clk, reset;          				//Solo hace falta clok en este caso pero mantenemos 
																	//reset por tradición
	logic [N-1:0]   a,b;                				//Entrads a y b de N bits
	logic [3:0]  ALUControl;								//Entrada AluControl
	logic [N-1:0]  result, resultexpected;    		// Salida real (result) y salida ideal (resultexpected)
	logic zero, zeroexpected;								//Salida real (zero) y salida zero ideal (zeroexpected) 
   
	
	logic [N-1:0]   vectornum, errors, contvect;		// bookkeeping variables 
	logic [3*N+4:0]  testvectors [0:15];	        	// N bits para a, y b y resultado, 4 bits para Alucontrol 
																	//y 1 bit para	zero
	// instantiate design under test
	alu #(N) dut(a, b, ALUControl,result,zero);
	int f3;
	int f4;
	 
  // at start of test pulse reset
	initial 	begin     
		vectornum = 0; errors=0; contvect=0;
		
		f3=$fopen("C:/Temp/ADC_2021/Moodle/TPS/TP1/code/alu_tv_1.txt","r");
		f4=$fopen("C:/Temp/ADC_2021/Moodle/TPS/TP1/code/alu_out1.txt","w");

		
		while(!$feof(f3)) begin
		   //$fscanf(f3,"%x",testvectors[contvect]);
			$fscanf(f3,"%x %x %x %x %b",a, b, ALUControl,resultexpected,zeroexpected );
			//{a,b,ALUControl,resultexpected,zeroexpected}=testvectors[contvect];
			testvectors[contvect] = {a,b,ALUControl,resultexpected,zeroexpected};
			$display("linea %d es : %x ",contvect,testvectors[contvect]);
			$display("a: %x b: %x ALUControl %x resultexpected %x zeroexpexted %b",a,b, ALUControl,resultexpected,zeroexpected);
			contvect=contvect+1;
			end
		
		reset = 1; #125; reset = 0;	
	   $fclose(f3);	
	end			
	
	// generate clock
	always     // no sensitivity list, so it always executes
		begin
			clk = 1; #50; clk = 0; #50;
		end
		
// change test vectors little time after the falling edge of clk
	always @(negedge clk) begin
      #1;
		{a,b,ALUControl,resultexpected,zeroexpected}=testvectors[vectornum];
		if((a==='x)||(b==='x)||(ALUControl==='x)) begin
		   resultexpected='x;
			zeroexpected='x;
		end
	end
	
// check for errors little time after the rising edge of clk if not reset applied
   always @(posedge clk) begin
	   #1;
		if (~reset) begin // skip during reset (en realidad esto no hace falta aqui porque signext es un combinacional)
		   if ((result !== resultexpected)||(zero!==zeroexpected)) begin  
				$display("Error: inputs = %x %x %x vector numero %d", a, b, ALUControl, vectornum);
				$display("  outputs = %x (%x expected)  %b (%b expected)",result,resultexpected,zero,zeroexpected);
				errors = errors + 1;
		   end  
		#1;
		vectornum=vectornum+1;	
		$fdisplay(f4,"%x %x %x %x %b %x %b", a,b,ALUControl, result, zero, resultexpected,zeroexpected);
		end	
   end	
	
// check for finalization
   always @(negedge clk) begin  
		#10;
		if (vectornum == 7) begin 
		   $display("%d tests completed with %d errors", vectornum, errors);
			$fclose(f4);
			$stop;
		end
	end
		
endmodule	


