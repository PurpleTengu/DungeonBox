package managedobjs 
{
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Maxwell Huang-Hobbs
	 */
	public class MSLib 
	{
		
		public static var managedIDs:Dictionary = new Dictionary();
		
		public static function instanciateMSLib():void 
		{
			MSLib.managedIDs[Player.MSType] = Player;
			MSLib.managedIDs[ExampleEnemy.MSType] = ExampleEnemy;
			MSLib.managedIDs[ShortLaser.MSType] = ShortLaser;
		}
		
		/**
		 * used to get a sprite from an ID.
		 * 
		 * @param	type the ID by which the class is registered in MSLib.managedIDs
		 * @param	x the x coordinate of the sprite
		 * @param	y the y coordinate of the sprite
		 * @param	parent the Manager which this managed sprite should report to
		 * @param	managedID the ID in the manager
		 */
		public static function getMFlxSprite(type:int, x:int, y:int, parent:Manager, managedID:int, facing:int):ManagedFlxSprite {
			if (type != ManagedFlxSprite.TYPE_UNDECLARED) {
				var clazz:Class = MSLib.managedIDs[type];
				var f = new clazz(x, y, parent, managedID);
				f.facing = facing;
				return f;
			}
			else
			{
				var f:ManagedFlxSprite = new ManagedFlxSprite(x, y, parent, managedID, 10);
				f.facing = facing;
				
				PlayState.consoleOutput.text = f.facing.toString();
				return f;
			}
		}
		
	}

}