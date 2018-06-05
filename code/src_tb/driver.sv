`ifndef DRIVER_SV
`define DRIVER_SV


class Driver;

    int testcase;
    int cnt;
    int j = 0;
    int k_data = 2;
    int k_adv = 0;

    ble_fifo_t sequencer_to_driver_fifo;

    virtual ble_itf vif;

    // Drive a Ble packet to the DUT
    task drive_packet(BlePacket packet);

        for(int i = packet.sizeToSend; i>=0; i=i) begin
            vif.serial_i <= 1;

            if (j == k_adv) begin
                if (packet.isAdv) begin
                    vif.valid_i <= packet.dataValid;
                    vif.serial_i <= packet.dataToSend[i];
                end
            end
            else if (j == k_data) begin
                if(packet.isAdv==0) begin
                    vif.valid_i <= packet.dataValid;
                    vif.serial_i <= packet.dataToSend[i];
                end
            end

            vif.channel_i <= j;
            vif.rssi_i <= packet.rssi;
            vif.valid_i <= 1;

            @(posedge vif.clk_i);

            vif.valid_i <= 0;

            if(j == 78) begin
                j = 0;
                i--;
            end
            else begin
                j = j + 1;
            end
        end

        // Calcul the next channel to send the data or adv
        // This avoid to always use the same channel
        if (packet.isAdv) begin
            if (k_adv == 0) begin
                k_adv = 24;
            end
            else if (k_adv == 24) begin
                k_adv = 78;
            end
            else if (k_adv == 78) begin
                k_adv = 0;
            end
            else begin
                k_adv = 0;
            end
        end
        else begin
            if (k_data == 0) begin
                k_data = 2;
            end
            else if (k_data == 24) begin
                k_data = 26;
            end
            else if (k_data == 78) begin
                k_data = 2;
            end
            else begin
                k_data +=2;
            end
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
            $display("Driver: I've sent a packet");
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
