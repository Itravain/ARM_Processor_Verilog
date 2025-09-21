	unnamed u0 (
		.clk        (<connected-to-clk>),        //                clk.clk
		.reset      (<connected-to-reset>),      //              reset.reset
		.address    (<connected-to-address>),    //  avalon_irda_slave.address
		.chipselect (<connected-to-chipselect>), //                   .chipselect
		.byteenable (<connected-to-byteenable>), //                   .byteenable
		.read       (<connected-to-read>),       //                   .read
		.write      (<connected-to-write>),      //                   .write
		.writedata  (<connected-to-writedata>),  //                   .writedata
		.readdata   (<connected-to-readdata>),   //                   .readdata
		.irq        (<connected-to-irq>),        //          interrupt.irq
		.IRDA_TXD   (<connected-to-IRDA_TXD>),   // external_interface.TXD
		.IRDA_RXD   (<connected-to-IRDA_RXD>)    //                   .RXD
	);

