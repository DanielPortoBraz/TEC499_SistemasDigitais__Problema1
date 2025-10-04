module divisor(
	input q,
	output reg clock_25mhz
	);
	
	always @(posedge q) begin
		clock_25mhz <= ~clock_25mhz;
	end
	
endmodule
