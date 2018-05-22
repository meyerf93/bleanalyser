`ifndef SEQUENCER_SV
`define SEQUENCER_SV

class Sequencer;

    int testcase;

    ble_fifo_t sequencer_to_driver_fifo;
    ble_fifo_t sequencer_to_scoreboard_fifo;

    task test_case1();
        automatic BlePacket packet;
        $display("First test case");

        packet = new;
        packet.isAdv = 1;
        void'(packet.randomize());

        sequencer_to_driver_fifo.put(packet);
        sequencer_to_scoreboard_fifo.put(packet);

        $display("I sent an advertising packet!!!!");


        for(int i=0;i<9;i++) begin

            packet = new;
            packet.isAdv = 0;
            void'(packet.randomize());

            sequencer_to_driver_fifo.put(packet);
            sequencer_to_scoreboard_fifo.put(packet);

            $display("I sent a packet!!!!");
        end
        $display("Sequencer : end");
    endtask

    task test_case2();
        automatic BlePacket packet;

        $display("Second test case");

        for(int i=0; i<2; i++) begin
            packet = new;
            packet.isAdv = 1;
            void'(packet.randomize());

            sequencer_to_driver_fifo.put(packet);
            sequencer_to_scoreboard_fifo.put(packet);

            $display("Sequencer: I sent an advertising packet!!!!");


            for(int j=0;j<9;j++) begin

                packet = new;
                packet.isAdv = 0;
                void'(packet.randomize());

                sequencer_to_driver_fifo.put(packet);
                sequencer_to_scoreboard_fifo.put(packet);

                $display("Sequencer: I sent a packet!!!!");
            end
        end
    endtask

    task test_case3();
        automatic BlePacket packet;

        $display("Third test case");

        //Genere deux paquets advertising
        for(int i=0; i<2; i++) begin
            packet = new;
            packet.isAdv = 1;
            void'(packet.randomize());

            sequencer_to_driver_fifo.put(packet);
            sequencer_to_scoreboard_fifo.put(packet);

            $display("Sequencer: I sent an advertising packet!!!!");
        end

        //Genere 18 paquets de donnees avec adresses correspondants
        //aux advertising. Change d'adresse une fois sur deux.
        for(int i=0;i<18;i++) begin
            packet = new;
            packet.isAdv = 0;
            void'(packet.randomize());
            packet.nextAddr = (i%2)+1;

            sequencer_to_driver_fifo.put(packet);
            sequencer_to_scoreboard_fifo.put(packet);

            $display("Sequencer: I sent a packet!!!!");
        end
    endtask

    task test_case4();
        automatic BlePacket packet;

        $display("Fourth test case");
        //Genere deux paquets advertising
        for(int i=0; i<2; i++) begin
            packet = new;
            packet.isAdv = 1;
            void'(packet.randomize());

            sequencer_to_driver_fifo.put(packet);
            sequencer_to_scoreboard_fifo.put(packet);

            $display("Sequencer: I sent an advertising packet!!!!");
        end

        //Genere 18 paquets de donnees avec adresses correspondants
        //aux advertising. Change d'adresse une fois sur deux.
        for(int i=0;i<18;i++) begin
            packet = new;
            packet.isAdv = 0;
            void'(packet.randomize());
            packet.nextAddr = (i%2)+1;

            sequencer_to_driver_fifo.put(packet);
            sequencer_to_scoreboard_fifo.put(packet);

            $display("Sequencer: I sent a packet!!!!");
        end

        //Genere deux paquets avec adresse bidon, devrait etre ignores
        //par le DUT
        for(int i=0; i<2; i++) begin
            packet = new;
            packet.isAdv = 0;
            void'(packet.randomize());
            packet.addr = packet.addr + 1 + i;

            sequencer_to_driver_fifo.put(packet);
            sequencer_to_scoreboard_fifo.put(packet);
        end
    endtask

    task test_case5();
        automatic BlePacket packet;

        $display("Fifth test case");
        //Genere paquet advertising mais ne l'envoi pas
        packet = new;
        packet.isAdv = 1;
        void'(packet.randomize());

        //Genere deux paquets de donnees, devrait etre ignores
        //par le DUT
        for(int i=0; i<2; i++) begin
            packet = new;
            packet.isAdv = 0;
            void'(packet.randomize());

            sequencer_to_driver_fifo.put(packet);
        end

        //Genere deux paquets advertising
        for(int i=0; i<2; i++) begin
            packet = new;
            packet.isAdv = 1;
            void'(packet.randomize());

            sequencer_to_driver_fifo.put(packet);
            sequencer_to_scoreboard_fifo.put(packet);

            $display("Sequencer: I sent an advertising packet!!!!");
        end

        //Genere 18 paquets de donnees avec adresses correspondants
        //aux advertising. Change d'adresse une fois sur deux.
        for(int i=0;i<18;i++) begin
            packet = new;
            packet.isAdv = 0;
            void'(packet.randomize());
            packet.nextAddr = (i%2)+1;

            sequencer_to_driver_fifo.put(packet);
            sequencer_to_scoreboard_fifo.put(packet);

            $display("Sequencer: I sent a packet!!!!");
        end
    endtask

    task test_case6();
        automatic BlePacket packet;

        $display("Sixth test case");

        packet = new;
        packet.isAdv = 1;
        void'(packet.randomize());

        sequencer_to_driver_fifo.put(packet);
        sequencer_to_scoreboard_fifo.put(packet);

        $display("Sequencer: I sent an advertising packet!!!!");


        for(int i=0;i<9;i++) begin

            packet = new;
            packet.isAdv = 0;
            void'(packet.randomize());

            sequencer_to_driver_fifo.put(packet);
            sequencer_to_scoreboard_fifo.put(packet);

            $display("Sequencer: I sent a packet!!!!");
        end
    endtask


    task run;
          $display("Sequencer : Start");

          case (testcase)
            0 : begin
              test_case1();
              test_case2();
              test_case3();
              test_case4();
              test_case5();
              test_case6();
            end
            1 : begin
              test_case1();
            end
            2 : begin
              test_case2();
            end
            3 : begin
              test_case3();
            end
            4 : begin
              test_case4();
            end
            5 : begin
              test_case5();
            end
            6 : begin
              test_case6();
            end
            default : begin
              test_case1();
            end
          endcase

          $display("Sequencer : end");
    endtask: run
endclass : Sequencer


`endif // SEQUENCER_SV
