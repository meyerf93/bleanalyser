`ifndef DRIVER_SV
`define DRIVER_SV


class Driver;

    int testcase;

    ble_fifo_t sequencer_to_driver_fifo;

    virtual ble_itf vif;

    task drive_packet(BlePacket packet);
//        packet.isAdv = 1;
//        void'(packet.randomize());
        vif.valid_i <= 1;
        for(int i = packet.sizeToSend - 1;i>=0; i--) begin
            vif.serial_i <= packet.dataToSend[i];
            vif.channel_i <= 0;
            vif.rssi_i <= 4;
            @(posedge vif.clk_i);
        end
        vif.serial_i <= 0;
        vif.valid_i <= 0;
        vif.channel_i <= 0;
        vif.rssi_i <= 0;
        for(int i=0; i<9; i++)
            @(posedge vif.clk_i);
    endtask

    task send_packets(input int nbPackets);
        automatic BlePacket packet;

        for(int i=0;i<nbPackets;i++) begin
            packet = new;
            sequencer_to_driver_fifo.get(packet);
            drive_packet(packet);
            $display("Driver: I've sent a packet");
        end
    endtask

    task run;
        automatic BlePacket packet;
        packet = new;
        $display("Driver : start");

        vif.serial_i <= 0;
        vif.valid_i <= 0;
        vif.channel_i <= 0;
        vif.rssi_i <= 0;
        vif.rst_i <= 1;
        @(posedge vif.clk_i);
        vif.rst_i <= 0;
        @(posedge vif.clk_i);
        @(posedge vif.clk_i);

        if (testcase == 1)
            send_packets(10);
        if (testcase == 2)
            send_packets(20);
        if (testcase == 3)
            send_packets(20);
        if (testcase == 4)
            send_packets(22);
        if (testcase == 5)
            send_packets(22);


        for(int i=0;i<99;i++)
            @(posedge vif.clk_i);

        $display("Driver : end");
    endtask : run

endclass : Driver



`endif // DRIVER_SV
