class transaction;

	rand logic[`ADDR_WIDTH-1:0]addr;
	rand logic sel;
	rand logic penable;
	rand logic pwrite;
	rand logic [`DATA_WIDTH-1:0]pwdata;
	rand logic [`DATA_WIDTH/8-1:0]pstrb;
	logic [`DATA_WIDTH-1:0]prdata;
	logic pready;
	logic pslverr;	
	rand states next_state;
	states present_state=idle;
	logic[`ADDR_WIDTH-1:0]temp_addr;
	logic [`DATA_WIDTH-1:0]temp_pwdata;
	logic [`DATA_WIDTH/8-1:0]temp_pstrb;
	logic temp_pwrite;
 		
	constraint c{
		if(present_state==idle){
			sel==0;
			penable==0;
			next_state inside{idle,setup};
		}
  		else if(present_state==setup){
			sel==1;
			penable==0;
			next_state==access;
		}
		else if(present_state==access){
			sel==1;
			penable==1;
			addr==temp_addr;
			pwdata==temp_pwdata;
			pstrb==temp_pstrb;
			pwrite==temp_pwrite;
			next_state inside {idle,setup};}
	}
	constraint c1{
		
		     if(!pwrite)
			     pstrb==4'b0;
		
	}
	constraint c2{pwrite dist {0:=50,1:=50};}
 
	function void post_randomize();
		if(present_state==setup)begin
		temp_addr=addr;
		temp_pwdata=pwdata;
		temp_pstrb=pstrb;
		temp_pwrite=pwrite;end

		present_state=next_state;
	endfunction

	function void print(string tag=" ");
		
		$display("[%s]",tag);
		$display("%0t",$time);
		$display("operation pwrite:%b",pwrite);
		$display("address:%d",addr);
		$display("pwdata:%d",pwdata);
		$display("pstrb:%b",pstrb);
		$display("psel:%b",sel);
		$display("penable:%b",penable);        		
	endfunction
	function transaction copy();
		transaction tx;
		tx=new();
		tx.addr=this.addr;
		tx.pwdata=this.pwdata;
		tx.pstrb=this.pstrb;
		tx.prdata=this.prdata;
		tx.pready=this.pready;
		tx.pslverr=this.pslverr;
		tx.sel=this.sel;
		tx.penable=this.penable;
		tx.pwrite=this.pwrite;
		return tx;
	endfunction

endclass
