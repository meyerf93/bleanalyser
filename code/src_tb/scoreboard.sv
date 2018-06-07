`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV


class Scoreboard;

    int testcase;

    int timeout;
    // Compteur d'erreur
    int nb_error = 0;

    // Variable récupérant le nombre de paquets
    int nb_packets = 0;


    ble_fifo_t sequencer_to_scoreboard_fifo;
    usb_fifo_t monitor_to_scoreboard_fifo;

    task compare(BlePacket ble_packet, AnalyzerUsbPacket usb_packet);

        $display("Let's compare USB & BLE packets");

        // Comparaison du slot advertising des paquets
        if(ble_packet.isAdv == usb_packet.isAdv)
          $display("Scoreboard: Comparaison Advertising OK");
        else begin
          $display("Scoreboard: Comparaison Advertising fail");
          $display("Scoreboard: False Advertising of ble packet: %h", ble_packet.isAdv);
          $display("Scoreboard: False Advertising of usb packet: %h", usb_packet.isAdv);
          nb_error++;
        end

        // Comparaison du header des paquets
        if(ble_packet.header == usb_packet.header)
          $display("Scoreboard: Comparaison Header OK");
        else begin
          $display("Scoreboard: Comparaison Header fail");
          $display("Scoreboard: False Header of ble packet: %h", ble_packet.header);
          $display("Scoreboard: False Header of usb packet: %h", usb_packet.header);
          nb_error++;
        end

        // Comparaison des adresses des paquets
        if(ble_packet.addr == usb_packet.addr)
          $display("Scoreboard: Comparaison Adress OK");
        else begin
          $display("Scoreboard: Comparaison Adress fail");
          $display("Scoreboard: False Adress of ble packet: %h", ble_packet.addr);
          $display("Scoreboard: False Adress of usb packet: %h", usb_packet.addr);
          nb_error++;
        end

        // Comparaison des datas des paquets
        if(ble_packet.rawData == usb_packet.rawData)
          $display("Scoreboard: Comparaison Data OK");
        else begin
          $display("Scoreboard: Comparaison Data fail");
          $display("Scoreboard: False Data of ble packet: %h", ble_packet.rawData);
          $display("Scoreboard: False Data of usb packet: %h", usb_packet.rawData);
          nb_error++;
        end

        // Comparaison des RSSI des paquets
        if(ble_packet.rssi == usb_packet.rssi)
          $display("Scoreboard: Comparaison RSSI OK");
        else begin
          $display("Scoreboard: Comparaison RSSI fail");
          $display("Scoreboard: False RSSI of ble packet: %h : %b", ble_packet.rssi,ble_packet.rssi);
          $display("Scoreboard: False RSSI of usb packet: %h : %b", usb_packet.rssi,usb_packet.rssi);
          nb_error++;
        end

        // Comparaison des tailles des paquets
        if(ble_packet.size == usb_packet.size-10)
          $display("Scoreboard: Comparaison Size OK");
        else begin
          $display("Scoreboard: Comparaison Size fail");
          $display("Scoreboard: False Size of ble packet: %h", ble_packet.size);
          $display("Scoreboard: False Size of usb packet: %h", usb_packet.size-10);
          nb_error++;
        end

        // Comparaison des channels des paquets
        if(ble_packet.channel == usb_packet.channel)
          $display("Scoreboard: Comparaison Channel OK");
        else begin
          $display("Scoreboard: Comparaison Channel fail");
          $display("Scoreboard: False Channel of ble packet: %h", ble_packet.channel);
          $display("Scoreboard: False Channel of usb packet: %h", usb_packet.channel);
          nb_error++;
        end

    endtask : compare

    function integer nb_packets_definition(int testcase);

      int nb_packets = 0;

      // Définition du nombre de paquets selon le testcase
      if (testcase == 1)
        nb_packets = 20;
      else if (testcase == 2)
        nb_packets = 22;
      else if (testcase == 3)
        nb_packets = 17;
      else
        nb_packets = 10;


      return nb_packets;

    endfunction


    task run;

        // Création des variables de stockage des paquets pour la vérification
        automatic BlePacket ble_packet;
        automatic AnalyzerUsbPacket usb_packet;

        $display("Scoreboard : Start");

        // Récupération du nombre de paquets en fonction du testcase
        nb_packets = nb_packets_definition(testcase);


        // Test de la fonction num pour les mailbox
        //$display("Scoreboard : There is %d BLE packets and %d USB Packet", sequencer_to_scoreboard_fifo.num, monitor_to_scoreboard_fifo.num);

        $display("Scoreboard : There is %d BLE packets and %d USB Packet, nb packets : %d",
                  sequencer_to_scoreboard_fifo.num, monitor_to_scoreboard_fifo.num,nb_packets);

        timeout = 0;
        while(sequencer_to_scoreboard_fifo.num < nb_packets && timeout < 1000000) begin
            //$display("Scoreboard : boucle sequenceur %d", sequencer_to_scoreboard_fifo.num);
            #10;
            //$display("Scoreboard : sequencer timeout : %d", timeout);
            timeout ++;
        end

        timeout = 0;
        while(monitor_to_scoreboard_fifo.num < nb_packets && timeout < 1000000) begin
          //$display("Scoreboard : boucle monitor %d", monitor_to_scoreboard_fifo.num);
          #10;
          //$display(" Scoreboard : monitor timeout : %d", timeout);
          timeout ++;
        end

          $display("Scoreboard : There is %d BLE packets and %d USB Packet", sequencer_to_scoreboard_fifo.num, monitor_to_scoreboard_fifo.num);

        // Vérification s'il y a le même nombre de paquets USB et BLE
        if (sequencer_to_scoreboard_fifo.num == monitor_to_scoreboard_fifo.num) begin
          $display("Scoreboard : There is the same number of BLE & USB packets");
          // Récupération des paquets BLE et USB et comparaison
          for(int i=0; i< nb_packets; i++) begin
              ble_packet = new;
              usb_packet = new;
              sequencer_to_scoreboard_fifo.get(ble_packet);
              monitor_to_scoreboard_fifo.get(usb_packet);
              compare(ble_packet, usb_packet);
          end
        end
        else if (sequencer_to_scoreboard_fifo.num > monitor_to_scoreboard_fifo.num) begin
          $display("Scoreboard : There is more BLE : %d packets than USB packets : %d",
                    sequencer_to_scoreboard_fifo.num,monitor_to_scoreboard_fifo.num);
          nb_error++;
        end
        else begin
          $display("Scoreboard : There is more USB packets : %d than BLE packets : %d",
                  monitor_to_scoreboard_fifo.num,sequencer_to_scoreboard_fifo.num);
          nb_error++;
        end
        //------------------



        // Vérification que tous les paquets BLE ont été récupérés
        if (sequencer_to_scoreboard_fifo.num == 0)
          $display("Scoreboard : All messages from sequencer have been retrieved!");
        else begin
          $display("Scoreboard : There is still messages in the sequencer's FIFO");
          nb_error++;
        end

        //-------------------

        // Vérification que tous les paquets USB ont été récupérés
        if (monitor_to_scoreboard_fifo.num == 0)
            $display("Scoreboard : All messages from monitor have been retrieved!");
        else begin
            $display("Scoreboard : There is still messages in the monitor's FIFO");
            nb_error++;
        end
        //-------------------

        $display("Comparaison finished with %d errors", nb_error);

        $display("Scoreboard : End");
    endtask : run

endclass : Scoreboard

`endif // SCOREBOARD_SV
