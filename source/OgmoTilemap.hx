package;

import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;

import zero.flixel.utilities.FlxOgmoUtils;
import zero.utilities.OgmoUtils;

using zero.utilities.OgmoUtils;
using zero.flixel.utilities.FlxOgmoUtils;

@:forward
abstract OgmoTilemap(FlxTilemap) to FlxTilemap
{
	inline public function new(ogmo:OgmoPackage, layerName:String, path = 'assets/data/')
	{
		this = new FlxTilemap();
		var layer = ogmo.level.get_tile_layer(layerName);
		var tileset = ogmo.project.get_tileset_data(layer.tileset);
		@:privateAccess//get_export_mode
		switch layer.get_export_mode() {
			case CSV    : loadOgmoCSVMap(layer, tileset, path);
			case ARRAY  : loadOgmoArrayMap(layer, tileset, path);
			case ARRAY2D: loadOgmo2DArrayMap(layer, tileset, path);
		}
	}
	
	function loadOgmoCSVMap(layer:TileLayer, tileset:ProjectTilesetData, path:String, startingIndex = 0, drawIndex = 0)
	{
		return this.loadMapFromCSV
			( layer.dataCSV
			, getPaddedTileset(tileset, path)
			, tileset.tileWidth
			, tileset.tileHeight
			, null
			, startingIndex
			, drawIndex
			);
	}
	
	function loadOgmoArrayMap(layer:TileLayer, tileset:ProjectTilesetData, path:String, startingIndex = 0, drawIndex = 0)
	{
		return this.loadMapFromArray
			( layer.data
			, layer.gridCellsX
			, layer.gridCellsY
			, getPaddedTileset(tileset, path)
			, tileset.tileWidth
			, tileset.tileHeight
			, null
			, startingIndex
			, drawIndex
			);
	}
	
	function loadOgmo2DArrayMap(layer:TileLayer, tileset:ProjectTilesetData, path:String, startingIndex = 0, drawIndex = 0)
	{
		return this.loadMapFrom2DArray
			( layer.data2D
			, getPaddedTileset(tileset, path)
			, tileset.tileWidth
			, tileset.tileHeight
			, null
			, startingIndex
			, drawIndex
			);
	}
	
	inline function getPaddedTileset(tileset:ProjectTilesetData, path, padding = 2)
	{
		return FlxTileFrames.fromBitmapAddSpacesAndBorders
			( tileset.get_tileset_path(path)
			, FlxPoint.get(tileset.tileWidth, tileset.tileHeight)
			, FlxPoint.get(tileset.tileSeparationX, tileset.tileSeparationY)
			, FlxPoint.get(padding)
			);
	}
}

@:forward
abstract CameraTilemap(OgmoTilemap) to FlxTilemap
{
	public function new(ogmo:OgmoPackage)
	{
		this = new OgmoTilemap(ogmo, 'CameraView');
	}
	
	public function getTileTypeAt(x:Float, y:Float):CameraTileType
	{
		return this.getTileByIndex(this.getTileIndexByCoords(FlxPoint.weak(x, y))) == 0 ? Up : Down;
	}
}

enum CameraTileType
{
	Up;
	Down;
}