module uc (
		 input wire clock, // Clock do CPU
		 input wire reset, // Reset síncrono
		 input wire zoom_done, // Sinal de finalização da operação
		 input wire [23:0] instruction, // Instrução recebida da memória (FIFO)

		 output reg [3:0] ch,
		 output reg [9:0] next_x,
		 output reg [9:0] next_y
	);

		 // Definição dos estados
		 parameter S_FETCH = 3'b000; // Buscar instrução (escrita/leitura FIFO)
		 parameter S_DECODE = 3'b001; // Decodificar campos da instrução
		 parameter S_EXECUTE = 3'b010; // Executar operação (espera zoom_done)
		 parameter S_WRITE = 3'b011; // Concluir ciclo (volta ao FETCH)

		reg [2:0] state, next_state;

		reg [1:0] offset_init;

		// Contador para offset: provoca atraso de dois ciclos de clock para alinhar aos dados da memória
		always @(posedge clock) begin
				offset_init <= offset_init + 1;
				end


		 // FSM sequencial
		 always @(posedge clock or posedge reset) begin
			  if (reset)
					state <= S_FETCH;
			  else
					state <= next_state;
		 end

		 // FSM combinacional
		 always @(*) begin
			  // Valores padrão
			  ch = 4'b0000;
			  next_x = 10'b0;
			  next_y = 10'b0;
			  next_state = state;

			  case (state)
					// ========================
					// Estado 1: Fetch
					// ========================
					S_FETCH: begin

						if (offset_init >= 1)
							next_state = S_DECODE;
					end

					// ========================
					// Estado 2: Decode
					// ========================
					S_DECODE: begin
						 {ch, next_x, next_y} = instruction; // separa os campos
						 next_state = S_EXECUTE;
					end

					// ========================
					// Estado 3: Execute
					// ========================
					S_EXECUTE: begin
						 if (zoom_done)
							  next_state = S_WRITE;
					end

					// ========================
					// Estado 4: Write
					// ========================
					S_WRITE: begin
						 next_state = S_FETCH;
					end

				default: next_state = S_FETCH;
		  endcase
	 end

endmodule