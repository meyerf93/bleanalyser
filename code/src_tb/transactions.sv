`ifndef TRANSACTIONS_SV
`define TRANSACTIONS_SV



/******************************************************************************
  Input transaction
******************************************************************************/
class BlePacket;

  logic[(64*8+16+32+8):0] dataToSend;
  int sizeToSend;
  int sizeData;

  /* pool of adress */
  static int nextAddr = 0;
  static logic[31:0] addrPool[16];

  /* Champs generes aleatoirement */
  logic isAdv;
  logic dataValid = 1;
  rand logic[31:0] addr;
  rand logic[15:0] header;
  rand logic[(64*8):0] rawData;
  rand logic[5:0] size;
  rand logic[7:0] rssi;
  rand logic[6:0] channel;

  /* Contrainte sur la taille des donnees en fonction du type de paquet */
  constraint size_range {
    (isAdv == 1) -> size inside {[4:15]};
    (isAdv == 0) -> size inside {[0:63]};
  }

  /* Contrainte sur les canaux utiliser pour les différents packets */
  constraint channel_range {
    (isAdv == 1) -> {
      channel dist{
        0  := 1,
        24 := 1,
        78 := 1
      };
    }
    (isAdv == 0) -> {
      (channel inside{[0:78]}) &&
      (channel %2 == 0) &&
      (channel != 0) &&
      (channel != 24) &&
      (channel != 78)
    };
  }

  function string psprint();
    $sformat(psprint, "BlePacket, isAdv : %b, addr= %h, time = %t\nsizeSend = %d, dataSend = %h\n",
                                                       this.isAdv, this.addr, $time,sizeToSend,dataToSend);
  endfunction : psprint

  function void post_randomize();

	logic[7:0] preamble=8'h55;

	/* Initialisation des données à envoyer */
  	dataToSend = 0;
  	sizeToSend=size*8+16+32+8;
    sizeData = sizeToSend;

    for(int i=0;i<6;i++)
      header[i] = size[i];

	/* Cas de l'envoi d'un paquet d'advertizing */
	if (isAdv == 1) begin
        // DeviceAddr = 0. Pour l'exemple
        for(int i=0; i<32;i++) begin
            rawData[size*8-1-i] = addr[31-i];
        end;
        //sauve l'addresse de la transaction dans le pull valide
        addrPool[nextAddr%15] = addr;
        nextAddr++;
	end

	/* Cas de l'envoi d'un paquet de données */
  else if (isAdv == 0) begin
        // Reprend une adresse dans le pull
		addr = addrPool[nextAddr-1];
  end


	/* Affectation des données à envoyer */
	for(int i=0;i<8;i++)
    // Data
 		dataToSend[sizeToSend-8+i]=preamble[i];
    // Adresse spécifique pour Advertising
    if(isAdv)
      addr = 32'h12345678;
	for(int i=0;i<32;i++)
		dataToSend[sizeToSend-8-32+i]=addr[i];
    $display("Sending packet with address %h\n",addr);
	for(int i=0;i<16;i++)
		dataToSend[sizeToSend-8-32-16+i]=0;
	for(int i=0;i<6;i++)
		dataToSend[sizeToSend-8-32-16+i]=size[i];
	for(int i=0;i<size*8;i++)
		dataToSend[sizeToSend-8-32-16-1-i]=rawData[size*8-1-i];
    if (isAdv) begin
        logic[31:0] ad;
        for(int i=0; i < 32; i++)
            ad[i] = dataToSend[sizeToSend-8-32-16-32+i];
        $display("Advertising with address %h\n",ad);
    end
  endfunction : post_randomize

endclass : BlePacket

class AnalyzerUsbPacket;
    logic[7:0] size = 0;
    logic[7:0] rssi = 0;
    logic[6:0] channel = 0;
    logic isAdv = 0;
    logic[7:0] reserved = 0;
    logic[31:0] addr = 0;
    logic[15:0] header = 0;
    logic[(64*8):0] rawData = 0;
endclass : AnalyzerUsbPacket

class DriverFifo;
    logic[10*(64*8+16+32+8):0] dataToSend[80] = '{80{0}};
    int index[80] = '{80{0}};
    logic[7:0] rssi[80] = '{80{0}};
    int fifo_counter = 0;
endclass : DriverFifo

typedef mailbox #(BlePacket) ble_fifo_t;

typedef mailbox #(AnalyzerUsbPacket) usb_fifo_t;

`endif // TRANSACTIONS_SV
