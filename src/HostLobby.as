package
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	
	import managers.NetClientManager;
	import managers.NetServerManager;
	
	import org.flixel.*;
	
	public class HostLobby extends FlxState
	{
		protected var hostSocket:ServerSocket;
		protected var clients:Array = new Array();
		public var listenPort:uint;
		protected var mastraubatorySocket:Socket;
		
		protected var clientTexts:Array;
		protected var focus:uint=0;
		protected var socketBound:Boolean;
		protected var errorQuit:Boolean=false;
		
		protected static var textSpacing:uint = 40;
		protected static var textOrigin:uint = 200;
		
		public function HostLobby(port:uint=1337)
		{
			this.listenPort = port;
		}
		
		public override function create():void{
			//create listening server
			this.hostSocket = new ServerSocket();
			this.hostSocket.addEventListener( ServerSocketConnectEvent.CONNECT, onConnect );
			
			try{
				this.hostSocket.bind( listenPort );
				this.hostSocket.listen();
				
				trace("Serversocket bound "+this.hostSocket.bound);
				trace("Serversocket listening on "+this.hostSocket.localPort);
				this.socketBound=true;
			}catch(error:Error){
				this.errorQuit=true;
				var errorText = new FlxText(0, HostLobby.textOrigin , FlxG.width, "Could not bind server socket.");
				errorText.setFormat (null, 20, 0xFFFFFFFF, "center");
				this.add(errorText);
				errorText = new FlxText(0, HostLobby.textOrigin + 24 , FlxG.width, "Something else is bound to it?");
				errorText.setFormat (null, 12, 0xFFFFFFFF, "center");
				this.add(errorText);
				this.socketBound=false;
			}	 
			
			
			//visual things
			createBonesGUI();
			this.clientTexts = new Array();
			
			//connect to self
			this.mastraubatorySocket = new Socket();
			this.mastraubatorySocket.connect( "127.0.0.1", listenPort );
			this.mastraubatorySocket.addEventListener(ProgressEvent.SOCKET_DATA,clearMastraubatorySocket);
			this.mastraubatorySocket.writeUTF("HOST");
			this.mastraubatorySocket.flush();
		}
		
		public function clearMastraubatorySocket(event:ProgressEvent){
			event.target.readUTF();
			event.target.removeEventListener(ProgressEvent.SOCKET_DATA,clearMastraubatorySocket);
		}
		
		public function createBonesGUI():void{
			var title:FlxText;
			title = new FlxText(0, 16, FlxG.width, "Hosting Lobby");
			title.setFormat (null, 20, 0xFFFFFFFF, "center");
			this.add(title);
			
			var instructions:FlxText;
			instructions = new FlxText(0, FlxG.height - 56, FlxG.width, "k to kick selected (blue) person from lobby");
			instructions.setFormat (null, 8, 0xFFFFFFFF, "center");
			add(instructions);
			
			instructions = new FlxText(0, FlxG.height - 44, FlxG.width, "space / enter to start");
			instructions.setFormat (null, 8, 0xFFFFFFFF, "center");
			add(instructions);
			
			instructions = new FlxText(0, FlxG.height - 32, FlxG.width, "esc to abort lobby and return to main screen");
			instructions.setFormat (null, 8, 0xFFFFFFFF, "center");
			add(instructions);
		}
		
		function doColors(){
			for(var i:int = 0; i<clientTexts.length; i++){
				if(focus==i){
					clientTexts[i].color = 0x00ffff;
				} else{
					clientTexts[i].color = 0xffffff;
				}
			}
		}
		
		
		public override function update():void{
			//moving selector
			var up:Boolean = FlxG.keys.justPressed("UP");
			var down:Boolean = FlxG.keys.justPressed("DOWN");
			if ( up || down ){
				if(up)	{ focus = (focus-1)%clientTexts.length;}
				if(down){ focus = (focus+1)%clientTexts.length;}
				doColors();
			}
			
			if( FlxG.keys.justPressed("K") ){//kicking selected player
				if(clients[focus].remoteAddress!="127.0.0.1"){
					removePlayer(focus);
					focus=focus%clientTexts.length;
				} else{
					trace("cannot kick self from lobby");
				}
			}
			
			if( (FlxG.keys.justPressed("ENTER") || FlxG.keys.justPressed("SPACE")) && !this.errorQuit ){//entering game
				for(var i:uint =0; i<this.clients.length; i++){
					this.clients[i].removeEventListener( ProgressEvent.SOCKET_DATA, getName );
					this.clients[i].removeEventListener( Event.CLOSE, cleanSocket );
					this.clients[i].writeUTF("start game");
					this.clients[i].flush();
					var s:Socket = this.clients[i];
				}
				FlxG.switchState ( new PlayState(new NetClientManager( this.mastraubatorySocket ) , new NetServerManager(clients) ) );
			}
			
			if( FlxG.keys.justPressed("ESCAPE")){//leaving lobby
				if(this.socketBound) {this.abortLobby();}
				FlxG.switchState ( new MenuState() );
			}
			
		}
		
		public function removePlayer(playerNumber:uint):void{
			trace("removing client",playerNumber)
			this.clients[playerNumber].close();
			this.remove(this.clientTexts[playerNumber]);
			delete this.clients[playerNumber];
			delete this.clientTexts[playerNumber];
			for(var i:uint=playerNumber+1; i<clientTexts.length; i++){
				clientTexts[i].y-=HostLobby.textSpacing;
				this.clientTexts[i-1]=this.clientTexts[i];
				this.clients[i-1]=this.clients[i];
			}
			delete this.clientTexts[this.clientTexts.length-1];
		}
		
		public function abortLobby(){
			this.hostSocket.close();
			for(var i:int=0; i<this.clients.length; i++){
				clients[i].close();
			}
		}
		
		
		
		
		public function cleanSocket(event:Event):void{
			trace("cleaning up (removing) socket", event.target, this.clients.indexOf(event.target) );
			this.removePlayer( this.clients.indexOf(event.target) );
		}
		
		private function onConnect( event:flash.events.ServerSocketConnectEvent ):void
		{
			var clientSocket:flash.net.Socket = event.socket;
			clientSocket.addEventListener( ProgressEvent.SOCKET_DATA, getName );
			clientSocket.addEventListener( Event.CLOSE, cleanSocket );
			
			trace( "Connection from " + clientSocket.remoteAddress + ":" + clientSocket.remotePort );
			var newText:FlxText = new FlxText(0, HostLobby.textOrigin+HostLobby.textSpacing*clients.length, FlxG.width, "NO_NAME ("+s.remoteAddress+")" );
			newText.setFormat (null, 12, 0xFFFFFFFF, "center");
			clients.push(clientSocket);
			clientTexts.push(newText);
			this.add(newText);
			doColors();
		}
		
		static var waitTime:Number = 2;
		private function getName(  event:ProgressEvent ):void{
			var clientNum:uint = clients.indexOf(event.target);
			trace("attempting to get name from",event.target.remoteAddress,"client",clientNum);
			var s:Socket = clients[clientNum];
			s.readShort();
			clientTexts[clientNum].text=s.readUTFBytes(s.bytesAvailable ) + " ("+s.remoteAddress+")" ;
			if(clientTexts[clientNum].text==""){
				clientTexts[clientNum].text="un-named client ("+s.remoteAddress+")"
			}
			trace("name is \"",clientTexts[clientNum].text,"\"");
		}
		
	}
	
}