module async_fifo #(
    parameter DATA_WIDTH = 8,  // Data width
    parameter ADDR_WIDTH = 4   // Address width (depth = 2^ADDR_WIDTH)
)(
    input wr_clk,              // Write clock
    input rd_clk,              // Read clock
    input rst,                 // Reset
    input wr_en,               // Write enable
    input rd_en,               // Read enable
    input [DATA_WIDTH-1:0] data_in,  // Data input
    output reg [DATA_WIDTH-1:0] data_out, // Data output
    output reg full,           // FIFO full flag
    output reg empty           // FIFO empty flag
);

    // Internal parameters
    localparam DEPTH = 1 << ADDR_WIDTH;

    // Internal signals
    reg [DATA_WIDTH-1:0] fifo_mem[DEPTH-1:0];
    reg [ADDR_WIDTH-1:0] wr_ptr;
    reg [ADDR_WIDTH-1:0] rd_ptr;
    reg [ADDR_WIDTH:0] wr_count;
    reg [ADDR_WIDTH:0] rd_count;

    // Synchronization signals
    reg [ADDR_WIDTH-1:0] wr_ptr_sync1, wr_ptr_sync2;
    reg [ADDR_WIDTH-1:0] rd_ptr_sync1, rd_ptr_sync2;

    // Write logic
    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            wr_count <= 0;
            full <= 0;
        end else if (wr_en && !full) begin
            fifo_mem[wr_ptr] <= data_in;
            wr_ptr <= wr_ptr + 1;
            wr_count <= wr_count + 1;
        end
        
        // Update full flag
        if (wr_count == DEPTH) full <= 1;
        else full <= 0;
    end

    // Read logic
    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            rd_ptr <= 0;
            rd_count <= 0;
            empty <= 1;
        end else if (rd_en && !empty) begin
            data_out <= fifo_mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
            rd_count <= rd_count + 1;
        end
        
        // Update empty flag
        if (rd_count == 0) empty <= 1;
        else empty <= 0;
    end

    // Synchronize write pointer to read clock domain
    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            wr_ptr_sync1 <= 0;
            wr_ptr_sync2 <= 0;
        end else begin
            wr_ptr_sync1 <= wr_ptr;
            wr_ptr_sync2 <= wr_ptr_sync1;
        end
    end

    // Synchronize read pointer to write clock domain
    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            rd_ptr_sync1 <= 0;
            rd_ptr_sync2 <= 0;
        end else begin
            rd_ptr_sync1 <= rd_ptr;
            rd_ptr_sync2 <= rd_ptr_sync1;
        end
    end

    // Update full and empty flags based on synchronized pointers
    always @* begin
        full = (wr_ptr_sync2 == rd_ptr_sync1 - 1);
        empty = (wr_ptr_sync2 == rd_ptr_sync2);
    end

endmodule
