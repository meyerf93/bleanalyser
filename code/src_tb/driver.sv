`ifndef DRIVER_SV
`define DRIVER_SV


class Driver;

    int testcase;

    ble_fifo_t sequencer_to_driver_fifo;

    virtual ble_itf vif;

    // Drive a Ble packet to the DUT
    task drive_packet(BlePacket packet);

        for(int i = packet.sizeToSend - 1; i>=0; i--) begin
            vif.valid_i <= packet.dataValid;
            vif.serial_i <= packet.dataToSend[i];
            vif.channel_i <= packet.channel;
            vif.rssi_i <= packet.rssi;
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
            //$display("taille fifo Sequencer = %d", sequencer_to_driver_fifo.num);
            sequencer_to_driver_fifo.get(packet);
            drive_packet(packet);
            $display("Driver: I've sent a packet %d",i);
        end
    endtask

    task run;
        automatic BlePacket packet;
        packet = new;
        $display("Driver : start");
        //$display("taille fifo Sequencer = %d", sequencer_to_driver_fifo.num);
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
            send_packets(10);
        if (testcase == 3)
            send_packets(10);
        if (testcase == 4)
            send_packets(10);
        if (testcase == 5)
            send_packets(10);

        for(int i=0;i<99;i++)
            @(posedge vif.clk_i);

        $display("Driver : end");
    endtask : run

endclass : Driver



`endif // DRIVER_SV
