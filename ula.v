

module ULA (
    
    input  wire        clk,
    input  wire        reset,
    input  wire        update_counters_en, 
    input  wire [2:0]  selected_algo,      

    
    input  wire [7:0]  p00_in, 
    input  wire [7:0]  p01_in, 
    input  wire [7:0]  p10_in, 
    input  wire [7:0]  p11_in, 
    
    
    output reg  [16:0] src_addr,  
    output reg  [18:0] dest_addr, 

    
    output wire [7:0]  avg_pixel_out,    
    output reg         process_finished  
);

    
    localparam SRC_WIDTH  = 320;
    localparam SRC_HEIGHT = 240;
    localparam DEST_WIDTH = 640;

    localparam ALGO_REPLICATION = 3'b001;
    localparam ALGO_DECIMATION  = 3'b010;
    localparam ALGO_BLOCK_AVG   = 3'b011;

    
    reg [8:0] x_count; 
    reg [7:0] y_count; 

    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            x_count <= 0;
            y_count <= 0;
            process_finished <= 1'b0;
        end else begin
            if (update_counters_en) begin
                
                if (x_count == SRC_WIDTH - 1) begin
                    x_count <= 0;
                    if (y_count == SRC_HEIGHT - 1) begin
                        y_count <= 0; 
                        process_finished <= 1'b1; 
                    end else begin
                        y_count <= y_count + 1;
                    end
                end else begin
                    x_count <= x_count + 1;
                end
            end else if (process_finished) begin
                 process_finished <= 1'b0; 
            end
        end
    end

    
    always @(*) begin
        
        src_addr = 0;
        dest_addr = 0;

        case (selected_algo)
            ALGO_REPLICATION: begin
                
                src_addr = y_count * SRC_WIDTH + x_count;
                
                dest_addr = (y_count * 2) * DEST_WIDTH + (x_count * 2);
            end

            ALGO_DECIMATION, ALGO_BLOCK_AVG: begin
                
                dest_addr = y_count * SRC_WIDTH + x_count;
                
                src_addr = (y_count * 2) * SRC_WIDTH + (x_count * 2);
            end
            
            default: begin
                src_addr = 0;
                dest_addr = 0;
            end
        endcase
    end

    
    wire [9:0] sum = p00_in + p01_in + p10_in + p11_in;
    assign avg_pixel_out = sum >> 2; 

endmodule