module cpuu2 (
    // Controle
    input  wire        clk,
    input  wire        reset,
    input  wire        start,       // vem da UC (cpu_start)
    output reg         done,        // volta para a UC (cpu_done)

    // Memória de origem (320x240)
    output reg  [16:0] src_mem_addr,
    input   wire [7:0] src_mem_data_in,

    // Memória de destino (640x480)
    output reg  [18:0] dest_mem_addr,
    output reg  [7:0]  dest_mem_data_out,
    output reg         dest_mem_wr_en
);

    // --- Parâmetros ---
    localparam SRC_WIDTH  = 320;
    localparam SRC_HEIGHT = 240;
    localparam DEST_WIDTH = 640;

    // Contadores
    reg [8:0]  x_count; // até 319
    reg [7:0]  y_count; // até 239
    wire       last_pixel;

    assign last_pixel = (x_count == SRC_WIDTH-1) && (y_count == SRC_HEIGHT-1);

    // --- Controle simples ---
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            x_count <= 0;
            y_count <= 0;
            done <= 0;
        end else if (start) begin
            // grava pixel atual
            src_mem_addr      <= y_count * SRC_WIDTH + x_count;
            dest_mem_addr     <= y_count * DEST_WIDTH + x_count;
            dest_mem_data_out <= src_mem_data_in;
            dest_mem_wr_en    <= 1'b1;

            // avança contadores
            if (last_pixel) begin
                done <= 1'b1;
                x_count <= 0;
                y_count <= 0;
            end else if (x_count == SRC_WIDTH-1) begin
                x_count <= 0;
                y_count <= y_count + 1;
            end else begin
                x_count <= x_count + 1;
            end
        end else begin
            // quando não está rodando
            dest_mem_wr_en <= 1'b0;
            done <= 0;
        end
    end

endmodule