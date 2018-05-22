`ifndef MONITOR_SV
`define MONITOR_SV


class Monitor;

    int testcase;
    logic[7:0] dutData[64+10];
    int currentData = 0;
    int frameOK = 0;
    int i = 0;

    virtual usb_itf vif;

    usb_fifo_t monitor_to_scoreboard_fifo;

    task get_packets(input int nbPackets);
        while(i < nbPackets) begin
            //Test s'il y a des donnes valides sur le bus
            if(vif.frame_o == 1) begin
                if(vif.valid_o == 1) begin
                    //Sauvegarde des donnes
                    dutData[currentData] <= vif.data_o;
                    currentData++;
                end
                frameOK = 1;
            end
            if(vif.frame_o == 0 && frameOK == 1) begin
                AnalyzerUsbPacket usb_packet = new;
                usb_packet.size = dutData[0];
                usb_packet.rssi = dutData[1];
                usb_packet.channel = dutData[2][7:1];
                usb_packet.isAdv = dutData[2][0];
                usb_packet.addr[7:0] = dutData[4];
                usb_packet.addr[15:8] = dutData[5];
                usb_packet.addr[23:16] = dutData[6];
                usb_packet.addr[31:24] = dutData[7];
                usb_packet.header[7:0] = dutData[8];
                usb_packet.header[15:8] = dutData[9];

                for(int j=0; j<usb_packet.size-10; j++) begin
                    usb_packet.rawData[(j*8)+:8] = dutData[usb_packet.size-1-j];
                end

                /*$display("Monitor: packet address: %h", usb_packet.addr);
                $display("Monitor: packet is advertising: %d", usb_packet.isAdv);
                $display("Monitor: packet channel: %d", usb_packet.channel);
                $display("Monitor: packet RSSI: %h", usb_packet.rssi);
                $display("Monitor: packet header: %h", usb_packet.header);
                $display("Monitor: packet size: %d", usb_packet.size);
                $display("Monitor: packet data: %h", usb_packet.rawData);*/

                $display("Monitor: I've got a packet from DUT");

                //Envoi de l'usb_packet au scoreboard
                monitor_to_scoreboard_fifo.put(usb_packet);

                frameOK = 0;
                currentData = 0;
                i++;
            end
            @(posedge vif.clk_i);
        end
    endtask


    task run;
        AnalyzerUsbPacket usb_packet = new;
        $display("Monitor : start");

        if (testcase == 1)
            get_packets(10);
        if (testcase == 2)
            get_packets(20);
        if (testcase == 3)
            get_packets(20);
        if (testcase == 4)
            get_packets(22);
        if (testcase == 5)
            get_packets(22);
        if (testcase == 6)

        $display("Monitor : end");
    endtask : run

endclass : Monitor

`endif // MONITOR_SV