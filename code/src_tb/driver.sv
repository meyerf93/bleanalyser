`ifndef DRIVER_SV
`define DRIVER_SV


class Driver;

    int testcase;
    int nb_send_packets = 0;

    ble_fifo_t sequencer_to_driver_fifo;

    virtual ble_itf vif;

    // Drive a Ble packet to the DUT
    task drive_packet(BlePacket packet);
        int j = 0;
        int k =0;
        $display("data to send : %h",packet.dataToSend);
        for(int i = packet.sizeToSend - 1; i>=0; i--) begin
            j = packet.channel+1;
            vif.valid_i <= packet.dataValid;
            vif.serial_i <= packet.dataToSend[i];
            vif.channel_i <= packet.channel;
            vif.rssi_i <= packet.rssi;
            @(posedge vif.clk_i);
            while(j != packet.channel) begin
              vif.valid_i <= 1;
              vif.serial_i <= 0;
              vif.channel_i = j;
              j = j + 1;
              if( j == 79) begin
                j = 0;
              end
              @(posedge vif.clk_i);
            end
        end
        $display("Driver: I've sent a packet %d, sur channel %d, adv = %d",nb_send_packets, packet.channel, packet.isAdv);
        $display("Driver: I've sent a packet %d, with rssi %h : %b", nb_send_packets, packet.rssi,packet.rssi);
        k = 0;
        j = 0;
        for(k = 0 ; k == 1000; k++) begin
          while(j != packet.channel) begin
            vif.valid_i <= 0;
            vif.serial_i <= 0;
            vif.channel_i = j;
            j = j + 1;
            if( j == 79) begin
              j = 0;
            end
            @(posedge vif.clk_i);
          end
        end;

        for(int i=0; i<9; i++)
            @(posedge vif.clk_i);
    endtask


    task send_packets(input int nbPackets);
        automatic BlePacket packet;

        for(int i=0;i<nbPackets;i++) begin
            packet = new;
            //$display("taille fifo Sequencer = %d", sequencer_to_driver_fifo.num);
            sequencer_to_driver_fifo.get(packet);
            nb_send_packets++;
            drive_packet(packet);

            /*$display("Driver: packet address: %h", packet.addr);
            $display("Driver: packet is advertising: %d", packet.isAdv);
            $display("Driver: packet channel: %d", packet.channel);
            $display("Driver: packet RSSI: %h", packet.rssi);
            $display("Driver: packet header: %h", packet.header);
            $display("Driver: packet size: %d", packet.size);
            $display("Driver: packet data: %h", packet.rawData);*/
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
            send_packets(20);
        if (testcase == 2)
            send_packets(22);
        if (testcase == 3)
            send_packets(17);
        if (testcase == 4)
            send_packets(10);
        if (testcase == 5)
            send_packets(10);

        for(int i=0;i<99;i++)
            @(posedge vif.clk_i);

        $display("driver : nb packet envoyé au DUT %d", nb_send_packets);

        $display("Driver : end");
    endtask : run

endclass : Driver



`endif // DRIVER_SV
