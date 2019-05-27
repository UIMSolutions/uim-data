module uim.data.column;

import std.stdio;
import std.conv;
import std.string;
import std.array;
import std.traits;
import uim.data;

template ColCellFunc(string name, string notFound, string found, string init = "", string result = "(found) ? result : defaultValue;") {
	const char[] ColCellFunc = `
	T `~name~`(T defaultValue = 0) { return `~name~`(0, height, defaultValue); }
	T `~name~`(size_t from, size_t to, T defaultValue = 0) {
		// writeln("T `~name~`(size_t from, size_t to, T defaultValue = 0)");
		bool found = false; `~init~`
		T result = defaultValue; 
		auto borders = arrayLimits(from, to, _cells); auto start = borders[0]; auto end = borders[1];
		foreach(i; start..end) if (_cells[i]) {
			if (found) {
				`~found~`
			}
			else {
				`~notFound~`
				found = true;
			}
		}
		return `~result~`
	} 
	T `~name~`(size_t[] index, T defaultValue = 0) {
		bool found = false; `~init~`
		T result = 0; 
		foreach(i; index) if (i < height) if (_cells[i]) { 
			if (found) {
				`~found~`
			}
			else {
				`~notFound~`
				found = true;
			}
		} 
		return `~result~`
	} 	`;
}

template ColCellCollectFunc(string name) {
	const char[] ColCellCollectFunc = `
	alias cells`~name~` = uim.data.cells.`~name~`;
 
	T `~name~`(T defaultValue = 0) { return `~name~`(0, height, defaultValue); }
	T `~name~`(size_t from, size_t to, T defaultValue = 0) {
		return  cells`~name~`(toValues(from, to), defaultValue);
	}
	T `~name~`(size_t[] index, T defaultValue = 0) {
		return  cells`~name~`(toValues(index), defaultValue);
	} 	`;
}


class DataColumn(T) {

	string _name;
	size_t _index;
	T*[] _cells; 
	DataTable!T _table; 

	this() { 
	}

	this(string aColName) { this(); _name = aColName; }
	this(DataTable!T aTable) { this(); _table = aTable; }
	this(size_t height) { this(); _cells.length = height; }

	this(string aColName, size_t height) { this(aColName); _cells.length = height; }

	this(DataTable!T aTable, string aColName) { this(aTable); name = aColName; }
	this(DataTable!T aTable, size_t anIndex) { this(aTable); index = anIndex; }

	@property void name(string aName) { _name = aName; 
		_cells.length = 0;
		_cells.length = _table.height;

		if (_name !in _table.colName2Index) return;
		index = _table.colName2Index[_name];
	}
	@property string name() { return _name; }

	@property void index(size_t aIndex) { _index = aIndex; 
		_cells.length = 0;
		_cells.length = _table.height;

		foreach(i, row; _table.rows) {
			if (row) { if (_index < row.length) _cells[i] = &row.cells[_index]; } 
			else { _cells[i] = null; }
		}
	}

	@property void height(size_t aHeight) { _cells.length = aHeight; }
	@property size_t height() { return _cells.length; }

	void opAssign(T)(T value) if (isNumeric!T) {
		foreach(i, c; _cells) if (c) *c = cast(T)value;
	}

	void opIndexAssign(S=T)(S value, size_t i) { if (i < height) *_cells[i] = cast(T)value; }
	T opIndex(size_t i) { return (i < height) ? *_cells[i] : 0; }

	T[] toValues() { return toValues(0, height); } 
	T[] toValues(size_t from, size_t to) {
		auto borders = arrayLimits(from, to, _cells); auto start = borders[0]; auto end = borders[1];
		T[] result; result.length = height; size_t counter;
		foreach(i; start..end) if (_cells[i]) { result[counter] = *_cells[i]; counter++; }
		result.length = counter;
		return result;
	} 
	T[] toValues(size_t[] index) {
		T[] result; result.length = index.length; size_t counter;
		foreach(i; index) if (i < height) if (_cells[i]) { result[counter] = *_cells[i]; counter++; }
		result.length = counter;
		return result;
	} 

	mixin(ColCellFunc!("count", "counter = 1;", "counter++;", "size_t counter;", "cast(T)counter;"));

	mixin(ColCellFunc!("add", "result = *_cells[i];", "result += *_cells[i];"));
	mixin(ColCellFunc!("sub", "result = *_cells[i];", "result -= *_cells[i];"));
	mixin(ColCellFunc!("mul", "result = *_cells[i];", "result *= *_cells[i];"));
	mixin(ColCellFunc!("div", "result = *_cells[i];", "result = (*_cells[i] != 0) ? result / *_cells[i] : 0;"));

	mixin(ColCellFunc!("sum", "result = *_cells[i];", "result += *_cells[i];"));
	mixin(ColCellFunc!("neg", "result = (*_cells[i] < 0) ? 1 : 0;", "result += (*_cells[i] < 0) ? 1 : 0;"));
	mixin(ColCellFunc!("pos", "result = (*_cells[i] > 0) ? 1 : 0;", "result += (*_cells[i] > 0) ? 1 : 0;"));
	mixin(ColCellFunc!("avg", "result = *_cells[i]; counter = 1;", "result += *_cells[i]; counter++;", "size_t counter;", "(counter) ? result/cast(T)counter : defaultValue;"));
	mixin(ColCellFunc!("min", "result = *_cells[i];", "result = (result > *_cells[i]) ? *_cells[i] : result;"));
	mixin(ColCellFunc!("max", "result = *_cells[i];", "result = (result < *_cells[i]) ? *_cells[i] : result;"));

	mixin(ColCellCollectFunc!"geo");

	mixin(ColCellCollectFunc!("deltamin"));
	mixin(ColCellCollectFunc!("deltamax"));
	mixin(ColCellCollectFunc!("deltasum"));
	mixin(ColCellCollectFunc!("deltaavg"));
	mixin(ColCellCollectFunc!("deltageo"));
	
	mixin(ColCellCollectFunc!("incmin"));
	mixin(ColCellCollectFunc!("incmax"));
	mixin(ColCellCollectFunc!("incsum"));
	mixin(ColCellCollectFunc!("incavg"));
	mixin(ColCellCollectFunc!("incgeo"));
	
	mixin(ColCellCollectFunc!("decmin"));
	mixin(ColCellCollectFunc!("decmax"));
	mixin(ColCellCollectFunc!("decsum"));
	mixin(ColCellCollectFunc!("decavg"));
	mixin(ColCellCollectFunc!("decgeo"));
	
	mixin(ColCellCollectFunc!("vltmin"));
	mixin(ColCellCollectFunc!("vltmax"));
	mixin(ColCellCollectFunc!("vltsum"));
	mixin(ColCellCollectFunc!("vltavg"));
	mixin(ColCellCollectFunc!("vltgeo"));

}