package  
{
	import flash.display.StageDisplayState;
	import flash.net.GroupSpecifier;
	import flash.utils.Dictionary;
	
	import managedobjs.*;
	
	import managers.*;
	
	import org.flixel.*;
	
	/**
	 * ...
	 * @author Maxwell Huang-Hobbs
	 */
	
	public class PlayState extends FlxState
	{
		[Embed(source = "/../res/cursor.png")] private var cursor:Class;
		
		[Embed(source = "/../res/T_0.png")] private var T0:Class;
		[Embed(source = "/../res/T_1.png")] private var T1:Class;
		[Embed(source = "/../res/T_2.png")] private var T2:Class;
		[Embed(source = "/../res/T_3.png")] private var T3:Class;
		[Embed(source = "/../res/T_4.png")] private var T4:Class;
		[Embed(source = "/../res/T_5.png")] private var T5:Class;
		[Embed(source = "/../res/T_6.png")] private var T6:Class;
		[Embed(source = "/../res/T_7.png")] private var T7:Class;
		[Embed(source = "/../res/T_8.png")] private var T8:Class;
		var images:Array = new Array( T0, T1, T2, T3, T4, T5, T6, T7, T8);
		
		public static var data:Array = new Array(
			new Array(0,1,1,1,1,1,2),
			new Array(3,4,4,4,4,4,5),
			new Array(3,4,4,4,4,4,5),
			new Array(3,4,4,4,4,4,5),
			new Array(3,4,4,4,4,4,5),
			new Array(3,4,4,4,4,4,5),
			new Array(6,7,7,7,7,7,8)
			 );
		
		public static var simulateNetworkPlay:Boolean = false;
			 
		
		public var manager:Manager;//manager that simulates server connectio
		public var serverManager:Manager //manager that runs fake server (threading doesn't work in as3) 
		
		public var player:PlayerControlled;
		
		public var managedSprites:FlxGroup = new FlxGroup();
		
		public static var consoleOutput:FlxText;
		
		override public function create():void
		{
			PlayState.consoleOutput = new FlxText(0,0,100,"START");
			//FlxG.stage.displayState = StageDisplayState.FULL_SCREEN;
			
			FlxG.bgColor = 0xff000000;
			FlxG.worldBounds = new FlxRect(0, 0,  data[0].length * 32, data.length * 32);
			FlxG.mouse.show(cursor);
			
			if(PlayState.simulateNetworkPlay){
				this.serverManager = new NetServerManager();
				this.manager = new NetClientManager(this);
			}else{
				this.serverManager = new HostManager();
				this.manager = new DummyManager(this, (HostManager)(this.serverManager));
			}
			
			FlxG.camera.zoom = 2;
			for (var y:int = 0; y < data.length; y++ ) {
				for (var x:int = 0; x < data[y].length; x++ ) {
					var b:FlxSprite = new FlxSprite( x * 32, y * 32, images[data[y][x]] );
					this.add(b);
				}
			}
			
			/*
			FlxG.camera.setBounds(
				FlxG.worldBounds.x,
				FlxG.worldBounds.y,
				FlxG.worldBounds.x+FlxG.worldBounds.width,
				FlxG.worldBounds.y+FlxG.worldBounds.height);*/
			this.add(managedSprites);
			
			this.add(PlayState.consoleOutput);
		}
		
		public function setPlayer(p:PlayerControlled):void
		{
			this.player = p;
			//FlxG.camera.follow(player, FlxCamera.STYLE_LOCKON);
		}
		
		override public function update():void
		{
			if(PlayState.simulateNetworkPlay){
				this.serverManager.update();//bullshit
			}
			this.manager.update();
			
			//MOVEMENT, LOCAL STUFF
			
			if(this.player!=null){
				FlxG.camera.scroll.x = player.getMidpoint().x-FlxG.width/2;
				FlxG.camera.scroll.y = player.getMidpoint().y-FlxG.height/2;
			}
			
			for each( var gameObject:FlxBasic in this.managedSprites.members){
				if(gameObject!=null && !gameObject.alive){
					PlayState.consoleOutput.text=gameObject.toString()+" died";
					this.remove(gameObject,true);
				}
			}
			
			for each( var gameObject:FlxBasic in this.members){
				if(gameObject!=null && !gameObject.alive){
					PlayState.consoleOutput.text=gameObject.toString()+" died";
					this.remove(gameObject,true);
				}
			}
			
			super.update();
		}
		
		public static var invOffset:FlxPoint = new FlxPoint(0,0);
		
	}
}