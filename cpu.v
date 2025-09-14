module cpu (
    input  wire       clk_in,
    input  wire [9:0] next_x,    // coordenada VGA X
    input  wire [9:0] next_y,    // coordenada VGA Y
    input  wire [2:0] ch,        // controle de zoom
    output reg  [9:0] img_x,     // coordenada processada X
    output reg  [9:0] img_y,     // coordenada processada Y
    output reg  [16:0] address   // endereço da memória (até 320*240 = 76800)
);
	
	 wire [9:0] x_out;
	 wire [9:0] y_out;
	 
	 always @(*) begin
		  // Aplica zoom
		  case (ch)
				3'b010: begin
					 img_x = next_x >> 2; // zoom out
					 img_y = next_y >> 2;
				end
				3'b100: begin
					 img_x = next_x << 2; // zoom in
					 img_y = next_y << 2;
				end
				default: begin
					 img_x = next_x;      // normal
					 img_y = next_y;
				end
		  endcase

		  // Garante que não ultrapasse os limites da imagem
		  if (img_x < 320 && img_y < 240)
				address = img_y * 320 + img_x;
		  else
				address = 0; // fallback (pixel preto ou borda)
	 end

	endmodule
