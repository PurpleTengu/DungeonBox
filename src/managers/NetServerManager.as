package managers 
{
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.Dictionary;
	
	import managedobjs.PlayerControlled
		
	import items.BlueStone

	/**
	 * ...
	 * @author Maxwell Huang-Hobbs
	 */
	public class NetServerManager extends HostManager
	{
		protected var clients:Array = new Array();
		
		public function NetServerManager(sockets:Array)
		{
			super(sockets.length);
			this.clients = sockets;
		}
		
		public override function make():void{
			super.make();
			for ( var socketIndex:uint = 0; socketIndex<clients.length ; socketIndex++ ){
				while(clients[socketIndex].bytesAvailable>0){
					trace("server has leftover bytes",clients[socketIndex].bytesAvailable);
					clients[socketIndex].readByte();
				}
				clients[socketIndex].addEventListener( ProgressEvent.SOCKET_DATA, onClientData );
				
				//send id
				trace("sending id",socketIndex);
				clients[socketIndex].writeShort(socketIndex);
				clients[socketIndex].flush();
			}
		}
		
		public override function update():void{
			super.update();
			var msg = getGameEvent();
			while (msg!=null){
				for (var x:int = 0; x<this.clients.length; x++){
					sendEventMessage(this.clients[x],msg);
				}
				msg = getGameEvent();
			}
		}
		
		public function onClientData( event:ProgressEvent ):void {
			var clientNumber = clients.indexOf(event.target);
			while(clients[clientNumber].bytesAvailable>0){
				var msg = handleMessage(this,clients[clientNumber],false);
				if(msg!=null){
					this.parseEvent(msg);
				}
			}
		}
		
		public static function sendEventMessage( client:Socket, message:Array, verbose:Boolean=false):void {
			var msgTyping:String = Manager.msgConfigs[message[0]];
			client.writeInt(message[0]);
			for(var i:int = 1; i<message.length; i++){
				if(msgTyping.charAt(i-1)=='i'){
					client.writeInt(message[i]);
				} else if(msgTyping.charAt(i-1)=='s'){
					client.writeUTF(message[i]);
				} else if (verbose){
					trace(message[0],msgTyping,"i dunno how to '",msgTyping.charAt(i),"'");
				}
			}
			client.flush();
		}
		
		public static function handleMessage( m:Manager, client:Socket, verbose:Boolean=false):Array {
			var evtType:int = client.readInt();
			var argsConfig:String = Manager.msgConfigs[evtType];
			if(argsConfig==null){
				return null;
			}
			
			var args:Array = new Array();
			args.push(evtType);
			
			for (var i:int = 0; i < argsConfig.length; i++ ) {
				if (argsConfig.charAt(i) == 'i') {
					args.push(client.readInt());
				} else if (argsConfig.charAt(i) == 's'){
					args.push(client.readUTF());
				} else if (verbose){
					trace("Server doesn't know how to handle",argsConfig.charAt(i));
					return null;
				}
			}
			if(verbose){
				trace(m, "got Message", argsConfig, args);
			}
			
			return args;
		}
	}

}
