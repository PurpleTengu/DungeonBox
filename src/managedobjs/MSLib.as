package managedobjs 
{
	import flash.utils.Dictionary;
	
	import org.flixel.FlxObject
	
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
			MSLib.managedIDs[GravityWell.MSType] = GravityWell;
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
		public static function getMFlxSprite(type:int, x:int, y:int, parent:Manager, managedID:int):ManagedFlxSprite {
			if (type != ManagedFlxSprite.TYPE_UNDECLARED) {
				var clazz:Class = MSLib.managedIDs[type];
				return new clazz(x, y, parent, managedID);
			}
			else
			{
				return new ManagedFlxSprite(x, y, parent, managedID, 10);
			}
		}
		
		
		//UTIL functions
		public static function distance(a:FlxObject, b:FlxObject){
			return Math.sqrt( Math.pow(a.x - b.x, 2) + Math.pow(a.y - b.y, 2));
		}
		
	}

}