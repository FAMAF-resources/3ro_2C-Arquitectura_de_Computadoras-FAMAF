
`timescale 1ns / 1ps

module signext_tb5();  

	parameter N = 64;
	
	logic          clk, reset;          				//Solo hace falta clok en este caso pero mantenemos 
																	//reset por tradición
	logic [31:0]   a;                					//Por aqui entran los 32 bits de la instrucción
	logic [N-1:0]  y, yexpected;    						// Salida es el campo de offset de la instruccion extendido a 64 bits  
	
	logic [31:0]   vectornum, errors,contvect;		// bookkeeping variables 
	logic [95:0]  testvectors [0:15];	        		// 32 bits de la entrada y 64 de la salida dan 96 bits
	
	// instantiate design under test
	signext #(N) dut(a, y);
	int f3;
	int f4;
	 
  // at start of test pulse reset
	initial 	begin     
		vectornum = 0; errors=0; contvect=0;
		
		f3=$fopen("C:/Temp/ADC_2021/Moodle/TPS/TP1/code/signtv5.txt","r");
		f4=$fopen("C:/Temp/ADC_2021/Moodle/TPS/TP1/code/signout5.txt","w");

		
		while(!$feof(f3)) begin
		   $fscanf(f3,"%x",testvectors[contvect]);
			{a,yexpected}=testvectors[contvect];
			$display("linea %d es : %x ",contvect,testvectors[contvect]);
			$display("entrada es : %x y salida es %x",a,yexpected);
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
		{a,yexpected}=testvectors[vectornum];
		if(a==='x) begin
		   yexpected='0;
		end
	end
	
// check for errors little time after the rising edge of clk if not reset applied
   always @(posedge clk) begin
	   #1;
		if (~reset) begin // skip during reset (en realidad esto no hace falta aqui porque signext es un combinacional)
		   if (y !== yexpected) begin  
				$display("Error: inputs = %x vector numero %d", a, vectornum);
				$display("  outputs = %x (%x expected)",y,yexpected);
				errors = errors + 1;
		   end  
		#1;
		vectornum=vectornum+1;	
		$fdisplay(f4,"%x   %x   %x", a,y,yexpected);
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


