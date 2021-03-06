package;

import openfl.geom.Rectangle;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.math.FlxVector;
import flixel.util.FlxPath;

import zero.utilities.OgmoUtils;

class OgmoPath extends FlxPath
{
    public var holdPerNode = 0.0;
    public var holdPerLoop = 0.0;
    public var mode(get, set):Int;
    inline function get_mode() return _mode;
    inline function set_mode(value:Int) return _mode = value;
    
    public var onLoopComplete:(OgmoPath)->Void;
    
    var holdTimer = 0.0;
    var wasFirstUpdate = false;
    
    function new () { super(); }
    
    inline public function createPathSprite()
    {
        return new PathSprite(this);
    }
    
    override function update(elapsed:Float)
    {
        wasFirstUpdate = _firstUpdate;
        super.update(elapsed);
        holdTimer -= elapsed;
    }
    
    override function advancePath(Snap:Bool = true):FlxPoint
    {
        if (!wasFirstUpdate)
            holdTimer = holdPerNode;
        
        var oldIndex = nodeIndex;
        var point = super.advancePath(Snap);
        if (oldIndex == 0 && !wasFirstUpdate)
        {
            holdTimer += holdPerLoop;
            if (onLoopComplete != null)
                onLoopComplete(this);
        }
        return point;
    }
    
    override function calculateVelocity(node:FlxPoint, horizontalOnly:Bool, verticalOnly:Bool)
    {
        if (active && holdTimer <= 0)
            super.calculateVelocity(node, horizontalOnly, verticalOnly);
        else
            object.velocity.set();
    }
    
    inline public function resume():Void { active = true; }
    inline public function pause():Void
    {
        active = false;
        object.velocity.set();
    }
    
    static public function fromEntity(data:EntityData):OgmoPath
    {
        if (data.nodes == null)
            return null;
        
        var path = new OgmoPath();
        path.add(data.x, data.y);
        
        for (point in data.nodes)
            path.add(point.x, point.y);
        
        if (Reflect.hasField(data.values, "speed"))
            path.speed = data.values.speed;
        
        if (Reflect.hasField(data.values, "type"))
            path.mode = (data.values.type:PathType).getFlxPathMode();
        
        if (Reflect.hasField(data.values, "holdPerNode"))
            path.holdPerNode = data.values.holdPerNode;
        
        if (Reflect.hasField(data.values, "holdPerLoop"))
            path.holdPerLoop = data.values.holdPerLoop ;
        
        path.setProperties(path.speed, path.mode);
        return path;
    }
}

enum abstract PathType(String) to String from String
{
    var LOOP_FORWARD;
    var LOOP_BACKWARD;
    var FORWARD;
    var BACKWARD;
    var YOYO;
    
    inline public function getFlxPathMode():Int
    {
        return switch this
        {
            case LOOP_FORWARD : FlxPath.LOOP_FORWARD;
            case LOOP_BACKWARD: FlxPath.LOOP_BACKWARD;
            case FORWARD      : FlxPath.FORWARD;
            case BACKWARD     : FlxPath.BACKWARD;
            case YOYO         : FlxPath.YOYO;
            default: throw "Unhandled PathType:" + this;
        }
    }
}

@:forward
abstract PathSprite(FlxTypedSpriteGroup<PathSpriteLink>) to FlxTypedSpriteGroup<PathSpriteLink>
{
    inline public function new (path:OgmoPath)
    {
        this = new FlxTypedSpriteGroup<PathSpriteLink>(path.nodes[0].x, path.nodes[0].y, path.nodes.length);
        for (i in 1...path.nodes.length)
            this.add(new PathSpriteLink(path.nodes[0], path.nodes[i-1], path.nodes[i]));
        if (path.nodes.length > 2 && (path.mode == FlxPath.LOOP_BACKWARD || path.mode == FlxPath.LOOP_FORWARD))
            this.add(new PathSpriteLink(path.nodes[0], path.nodes[path.nodes.length-1], path.nodes[0]));
    }
}

abstract PathSpriteLink(FlxSprite) to FlxSprite
{
    inline public function new (pathStart:FlxPoint, nodeStart:FlxPoint, nodeEnd:FlxPoint)
    {
        
        this = new FlxSprite
            ( nodeStart.x - pathStart.x
            , nodeStart.y - pathStart.y
            );
        var dis = FlxVector.get(nodeEnd.x - nodeStart.x, nodeEnd.y - nodeStart.y);
        // black line with white outline (crude)
        this.makeGraphic(Std.int(Math.max(3, dis.length + 2)), 3, 0xFF39404a);
        this.graphic.bitmap.fillRect(new Rectangle(1, 1, this.width - 2, 1), 0xFFffffff);
        // rotate
        this.angle = dis.degrees;
        this.origin.set(1, 1);
        dis.put();
    }
}