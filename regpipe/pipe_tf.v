module tf_VCBDmSE;

    // Inputs
    reg clr;
    reg clk;
    reg en;
    reg [31:0] inp;

    // Outputs
    wire [31:0] Q;

    // Instantiate the Unit Under Test (UUT)
    rPipe #(32) pipe(.clk(clk), .en(en), .clr(clr), .inpData(inp), .outData(Q));

    // Генратор периодичеккого сигнала синхронизации clk
    parameter Tclk=20; // Период сигнала синхронизации 20 нс
    always begin
        clk=1;
        #(Tclk/2);
        clk=0;
        #(Tclk/2);
    end

    initial begin // Initialize Inputs
        $dumpfile("VCBDmSE.vcd");
        $dumpvars(0, tf_VCBDmSE);

        inp = 228;
        en = 0;
        clr = 0;
        #100;
        en = 1;
        #50;
        clr = 1;
        #50;

        $finish;
    end
endmodule
