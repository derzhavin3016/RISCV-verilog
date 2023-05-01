module rPipe #(parameter WIDTH = 32) (
        input clk,
        input en,
        input clr,
        input [(WIDTH - 1):0] inpData,
        output [(WIDTH - 1):0] outData
    );
    reg [(WIDTH - 1):0] savedData;
    assign outData = savedData;

    always @(posedge clk)
        if (clr)
            savedData <= 0;
        else if (en)
            savedData <= inpData;

endmodule
