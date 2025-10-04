module cpa (
    input  wire        clk_in,
    input  wire        reset,
    input  wire [23:0] instruction, // Formato: Zoom + Coordenada Eixo (X e Y)
    output wire [16:0] address
);

    // Saídas da UC
    wire [3:0] ch_out;
    wire [9:0] proc_x;
    wire [9:0] proc_y;
    wire zoom_done;

    // ==============================
    // Unidade de Controle
    // ==============================
    uc u_control_unit (
        .clock      (clk_in),
        .reset      (reset),
        .zoom_done  (zoom_done),
        .instruction(instruction),
        .ch         (ch_out),     
        .next_x     (proc_x),
        .next_y     (proc_y)
    );

    // ==============================
    // Unidade de Lógica e Aritmética
    // ==============================
    ula u_ula (
        .clock       (clk_in),
        .reset       (reset),
        .x_in        (proc_x),
        .y_in        (proc_y),
        .op          (ch_out), 
        .zoom_done   (zoom_done),
        .address     (address)
    );

endmodule
