package ui;

import flixel.FlxG;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

@:forward
abstract Nokia8Text(BitmapText) to BitmapText
{
	static var font:Font = null;
	inline public function new (x = 0.0, y = 0.0, text = "", borderColor = 0xFF202e38)
	{
		this = new BitmapText(x, y, text, borderColor, 1, getFont());
	}
	
	public static function getFont():Font
	{
		if (font == null)
		{
			@:privateAccess
			font = Font.fromImage
				( "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&*()-_+=[]',.|:?/"
				, "Nokia8"
				, 4
				);
		}
		return font;
	}
}

@:forward
abstract Nokia16Text(BitmapText) to BitmapText
{
	static var font:Font = null;
	inline public function new (x = 0.0, y = 0.0, text = "", borderColor = 0xFF202e38, borderSize = 2)
	{
		this = new BitmapText(x, y, text, borderColor, borderSize, getFont());
	}
	
	public static function getFont():Font
	{
		if (font == null)
		{
			@:privateAccess
			font = Font.fromImage
				( "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&*()-_+=[]',.|:?/"
				, "Nokia16"
				, 8
				);
		}
		return font;
	}
}

@:forward
abstract GravText(BitmapText) to BitmapText
{
	static var font:Font = null;
	inline public function new (x = 0.0, y = 0.0, text = "", borderColor = 0xFF202e38)
	{
		this = new BitmapText(x, y, text, borderColor, 1, getFont());
	}
	
	public static function getFont():Font
	{
		if (font == null)
		{
			@:privateAccess
			font = Font.fromImage("1234567890", "Grav5", 4);
		}
		return font;
	}
}

class BitmapText extends flixel.text.FlxBitmapText
{
	public function new (x = 0.0, y = 0.0, text = "", borderColor = 0xFF202e38, borderSize = 2, ?font:FlxBitmapFont):Void
	{
		if (font == null)
			font = Nokia16Text.getFont();
		
		super(font);
		
		this.x = x;
		this.y = y;
		this.text = text;
		moves = false;
		active = false;
		
		if (borderColor >= 0xFF000000)
		{
			setBorderStyle(OUTLINE, borderColor, borderSize, 0);
			lineHeight = font.lineHeight + borderSize * 2;
		}
	}
	
	override function set_alpha(value:Float):Float
	{
		if (borderColor & 0xFF000000 > 0)
			setBorderStyle
				( borderStyle
				, borderColor & 0xffffff | (Std.int(value * 0xFF) << 24)
				, borderSize
				, borderQuality
				);
		
		return super.set_alpha(value);
	}
}

@:forward
abstract Font(FlxBitmapFont) to FlxBitmapFont
{
    function new (chars:String, widths:Array<Int>, path:String, lineHeight = 9, spaceWidth = 4)
    {
        @:privateAccess
        this = cast new FlxBitmapFont(FlxG.bitmap.add(path).imageFrame.frame);
        @:privateAccess
        this.lineHeight = lineHeight;
        this.spaceWidth = spaceWidth;
        var frame:FlxRect;
        var x:Int = 0;
        for (i in 0...widths.length)
        {
            frame = FlxRect.get(x, 0, widths[i] - 1, this.lineHeight);
            @:privateAccess
            this.addCharFrame(chars.charCodeAt(i), frame, FlxPoint.weak(), widths[i]);
            x += widths[i];
        }
    }
    
    static function fromImage(chars:String, name:String, spaceWidth:Int, separatorColor = 0xfbf236):Font
    {
        final widths = [];
        final path = 'assets/images/ui/fonts/$name.png';
        var bmd = openfl.Assets.getBitmapData(path);
        var curWidth = 0;
        var bottom = bmd.height - 1;
        for (x in 0...bmd.width)
        {
            if (bmd.getPixel(x, bottom) == separatorColor)
            {
                if (curWidth > 0)
                    widths.push(curWidth + 1);
                curWidth = 0;
            }
            else
                curWidth++;
        }
        if (curWidth > 0)
            widths.push(curWidth + 1);
        
        return new Font(chars, widths, path, bmd.height - 1, 8);
    }
}
