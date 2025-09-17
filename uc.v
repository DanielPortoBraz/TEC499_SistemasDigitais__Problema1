


module uc (
    
    input  wire        clk,
    input  wire        reset,
    input  wire [2:0]  chaves,          
    input  wire        botao_aplicar,     
    input  wire        cpu_done,          
    
    output reg         sistema_ocupado,   
    
    output reg         cpu_start,
    
    input  wire [18:0] addr_from_vga_calc,

    input  wire [16:0] src_addr_from_cpu,
    input  wire [18:0] dest_addr_from_cpu,
    input  wire [7:0]  data_from_cpu,
    input  wire        wren_from_cpu,

    output reg [16:0]  src_mem_addr,
    output reg [18:0]  dest_mem_addr,
    output reg [7:0]   dest_mem_data,
    output reg         dest_mem_wren
);

    
    localparam S_IDLE              = 2'd0; 
    localparam S_INICIAR_PROCESSO  = 2'd1; 
    localparam S_AGUARDANDO_CPU    = 2'd2; 

    reg [1:0] state, next_state;

    
    always @(posedge clk or posedge reset) begin
        if (reset) state <= S_IDLE;
        else       state <= next_state;
    end
	 
	 

    always @(*) begin
        
        next_state = state;
        cpu_start = 1'b0;
        sistema_ocupado = (state != S_IDLE);

        src_mem_addr = 0; 
        dest_mem_addr = addr_from_vga_calc; 
        dest_mem_data = 8'd0;
        dest_mem_wren = 1'b0;

		  
        case(state)
            S_IDLE: begin
                if (botao_aplicar) begin
                    next_state = S_INICIAR_PROCESSO;
                end
            end
            
            S_INICIAR_PROCESSO: begin
                cpu_start = 1'b1; 
                next_state = S_AGUARDANDO_CPU;
            end

            S_AGUARDANDO_CPU: begin
                
                src_mem_addr = src_addr_from_cpu;
                dest_mem_addr = dest_addr_from_cpu;
                dest_mem_data = data_from_cpu;
                dest_mem_wren = wren_from_cpu;

                if (cpu_done) begin
                    next_state = S_IDLE; 
                end
            end
        endcase
    end

endmodule