module async_fifo_tb;

    // Parameters
    localparam DATA_WIDTH = 8;
    localparam ADDR_WIDTH = 4;

    // Inputs
    reg wr_clk;
    reg rd_clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [DATA_WIDTH-1:0] data_in;

    // Outputs
    wire [DATA_WIDTH-1:0] data_out;
    wire full;
    wire empty;

    // Instantiate FIFO
    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    // Clock generation
    always #5 wr_clk = ~wr_clk;
    always #7 rd_clk = ~rd_clk;

    // Testbench procedure
    initial begin
        // Initialize inputs
        wr_clk = 0;
        rd_clk = 0;
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        data_in = 0;

        // Reset FIFO
        #10;
        rst = 0;

        // Write data to FIFO
        #10;
        wr_en = 1;
        data_in = 8'hAA; // Example data
        #10;
        data_in = 8'h55; // Example data
        #10;
        wr_en = 0;

        // Read data from FIFO
        #10;
        rd_en = 1;
        #10;
        rd_en = 0;

        // Test FIFO full and empty flags
        // Write until FIFO is full
        #10;
        wr_en = 1;
        repeat (2**ADDR_WIDTH - 2) begin
            data_in = $random;
            #10;
        end
        wr_en = 0;

        // Try to write to a full FIFO
        #10;
        wr_en = 1;
        data_in = $random;
        #10;
        wr_en = 0;

        // Read all data from FIFO
        #10;
        rd_en = 1;
        repeat (2**ADDR_WIDTH - 1) #10;
        rd_en = 0;

        // Finish simulation
        #10;
        $finish;
    end

    // Monitor signals
    initial begin
        $monitor("Time: %0t | data_in: %h | data_out: %h | full: %b | empty: %b", $time, data_in, data_out, full, empty);
    end

endmodule
