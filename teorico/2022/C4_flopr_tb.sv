
`timescale 1ns / 1ps

module flopr_tb();  

	parameter N = 4;
	
	logic        clk, reset;
	logic [N-1:0]       d, q;
	logic [N-1:0] vectornum, errors;    // bookkeeping variables 
	logic [N-1:0] testvectors [0:2**N-1];
	
	// instantiate device under test
	flopr #(N) dut(clk, reset, d, q);
	
  // at start of test pulse reset
	initial 	begin     
		vectornum = 0; errors=0; d=0; 
		for (int i=0; i<=2**N-1; i++) begin
		   testvectors [i]=i;
		end
		reset = 1; #125; reset = 0;		
	end			
	
	// generate clock
	always     // no sensitivity list, so it always executes
		begin
			clk = 1; #50; clk = 0; #50;
		end
		
// change test vectors little time after the falling edge of clk
	always @(negedge clk) begin
      vectornum=vectornum+1;
		d=vectornum;
	end
	
// check for errors little time after the rising edge of clk if not reset applied
   always @(posedge clk) begin
	   #10;
		if (~reset) begin // skip during reset
		   if (q !== d) begin  
				$display("Error: inputs = %b", d);
				$display("  outputs = %b (%b expected)",q,d);
				errors = errors + 1;
		   end  
		end	
   end	
	
// check for finalization
   always @(negedge clk) begin  
		#10;
		if (vectornum == N) begin 
		   $display("%d tests completed with %d errors", vectornum, errors);
			$stop;
		end
	end
endmodule	


/*
	// at start of test pulse reset
	initial 	begin     
			
			for (int i=0; i<=2**N-1;i++) 
			  begin
			     testvectors[i}=i;
			  end
			  
		   vectornum = 0; errors = 0;
			reset = 1; #27; reset = 0;		
	end
	 
// apply test vectors on rising edge of clk
	always @(posedge clk)
		begin
			#1; vectornum=vectornum+1;
		end




	
	// apply test vectors on rising edge of clk
	always @(posedge clk)
		begin
			#1; d = testvectors[vectornum];
		end
		
 
	// check results on falling edge of clk
   always @(negedge clk)
		if (~reset) begin // skip during reset
			if (q !== testvectors[vectornum];) begin  
				$display("Error: inputs = %b", d);
				$display("  outputs = %b (%b expected)",y,yexpected);
				errors = errors + 1;
			end
		
		// increment array index and read next testvector
      vectornum = vectornum + 1;
			if (testvectors[vectornum] === 4'bx) begin 
				$display("%d tests completed with %d errors", 
                vectornum, errors);
			// $finish;
			$stop;
			end
		end
		
*/
