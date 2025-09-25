module cpu (
    input  wire       clk_in,
    input  wire       reset,
    input  wire [9:0] next_x,   // coordenada VGA X
    input  wire [9:0] next_y,   // coordenada VGA Y
    input  wire [2:0] ch,       // controle de zoom
    output wire [9:0] img_x,    // coordenada processada X
    output wire [9:0] img_y,    // coordenada processada Y
    output wire [16:0] address  // endereco da memoria
);

    // ==============================
    // Unidade de Controle
    // ==============================
    wire zoom_done;
    wire [2:0] ch_out;
    wire [9:0] proc_x;
    wire [9:0] proc_y;
	 
    uc u_control_unit (
        .clock      (clk_in),
        .reset      (reset),
        .zoom_done  (zoom_done),

        // Instrução vem direto das entradas
        .instruction({ch, next_x, next_y}),

        // Saídas da UC
        .ch     (ch_out),
        .next_x (proc_x),
        .next_y (proc_y)
    );

    // =================================
    // Unidade de Lógica e Aritmética
    // =================================
    ula u_ula (
        .clock    (clk_in),
        .x_in     (proc_x),
        .y_in     (proc_y),
        .op       (ch_out),

        .zoom_done(zoom_done),
        .x_out    (img_x),
        .y_out    (img_y),
        .address  (address)
    );

endmodule