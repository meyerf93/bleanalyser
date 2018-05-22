`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV


class Scoreboard;

    int testcase;
    int nb_error = 0;
    int nbPackets = 0;

    ble_fifo_t sequencer_to_scoreboard_fifo;
    usb_fifo_t monitor_to_scoreboard_fifo;

    task scoreboardTask1(input int nbPackets);
        //Initialisation des variables
        automatic BlePacket ble_packet = new;
        automatic AnalyzerUsbPacket usb_packet = new;

        for(int i=0; i< nbPackets; i++) begin
            sequencer_to_scoreboard_fifo.get(ble_packet);
            monitor_to_scoreboard_fifo.get(usb_packet);

            $display("Scoreboard : I've got two packets, I'll compare them...");

            // Check that everything is fine
            if(ble_packet.addr != usb_packet.addr) begin
                $display("Scoreboard: Adress error");
                $display("Scoreboard: ble packet: %h", ble_packet.addr);
                $display("Scoreboard: usb packet: %h", usb_packet.addr);
                nb_error++;
            end
            if(ble_packet.header != usb_packet.header) begin
                $display("Scoreboard: Header error");
                nb_error++;
            end
            if(ble_packet.rawData != usb_packet.rawData) begin
                $display("Scoreboard: Data error");
                $display("Scoreboard: ble packet : %h", ble_packet.rawData);
                $display("Scoreboard: usb packet : %h", usb_packet.rawData);
                nb_error++;
            end
            if(ble_packet.channel != usb_packet.channel) begin
                $display("Scoreboard: Channel error");
                nb_error++;
            end
            if(ble_packet.isAdv != usb_packet.isAdv) begin
                $display("Scoreboard: Advertising error");
                nb_error++;
            end
            if(ble_packet.rssi != usb_packet.rssi) begin
                $display("Scoreboard: Rssi error");
                $display("Scoreboard: ble packet: %d", ble_packet.rssi);
                $display("Scoreboard: usb packet: %d", usb_packet.rssi);
                nb_error++;
            end
            if(ble_packet.size != (usb_packet.size-10)) begin
                $display("Scoreboard: Size error");
                nb_error++;
            end

            $display("Scoreboard : Compare done!");
        end

        $display("Scoreboard end wit %d error(s)", nb_error);

    endtask

    task scoreboardTask2;

    endtask

    task run;
        automatic BlePacket ble_packet = new;
        automatic AnalyzerUsbPacket usb_packet = new;

        $display("Scoreboard : Start");

        if (testcase == 1)
            scoreboardTask1(10);
        if (testcase == 2)
            scoreboardTask1(20);
        if (testcase == 3)
            scoreboardTask1(20);
        if (testcase == 4)
            scoreboardTask1(22);
        if (testcase == 5)
            scoreboardTask1(22);
        if (testcase == 6)
            scoreboardTask2();

        $display("Scoreboard : End");
    endtask : run

endclass : Scoreboard

`endif // SCOREBOARD_SV
