module source.uim.data.classes.row;

@safe:
import std.stdio;
import std.conv;
import std.string;
import std.array;
@safe:
import uim.data;

import Cell = uim.data.cell;

enum RowStatus {
	invalid,
	valid,
	changed
}

template RowAggFunc(string aggName) {
	const char[] RowAggFunc = `
	alias cells`~aggName~` = uim.data.cells.`~aggName~`;

	auto `~aggName~`(size_t target, T defaultResult = 0) { 
		this[target] = `~aggName~`(0, length, defaultResult); return this; }
	auto `~aggName~`(size_t target, size_t[] cols, T defaultResult = 0) { 
		this[target] = `~aggName~`(cols, defaultResult); 
		return this; }
	auto `~aggName~`(size_t target, size_t colFrom, size_t colTo, T defaultResult = 0) { 
		this[target] = `~aggName~`(colFrom, colTo, defaultResult); 
		return this; }
	
	T `~aggName~`(T defaultResult = 0) { 
		return `~aggName~`(0, length, defaultResult); }
	T `~aggName~`(size_t[] cols, T defaultResult = 0) { 
		return cells`~aggName~`(rowColsToCells(this, cols), defaultResult); 
	}
	T `~aggName~`(size_t colFrom, size_t colTo, T defaultResult = 0) { 
		return cells`~aggName~`(cells, colFrom, colTo, defaultResult); }
    `;
}

template RowDifFunc(string aggName) {
	const char[] RowDifFunc = `
	alias cells`~aggName~` = uim.data.cells.`~aggName~`;
	auto `~aggName~`(T)(size_t target, int distance, T defaultResult = 0) { this[target] = cells`~aggName~`(cells, distance, defaultResult); return this; }
	auto `~aggName~`(T)(size_t target, size_t[] cols, int distance, T defaultResult = 0) { this[target] = cells`~aggName~`(cells, cols, distance, defaultResult); return this; }
	auto `~aggName~`(size_t target,size_t from, size_t to, int distance, T defaultResult = 0) { this[target] = cells`~aggName~`(cells, from, to, distance, defaultResult); return this; }
	
	T `~aggName~`(int distance, T defaultResult = 0) { return cells`~aggName~`(cells, distance, defaultResult); }
	T `~aggName~`(T)(size_t[] cols, int distance, T defaultResult = 0) { return cells`~aggName~`(cells, cols, distance, defaultResult); }
	T `~aggName~`(T)(size_t from, size_t to, int distance, T defaultResult = 0) { return cells`~aggName~`(cells, from, to, distance, defaultResult); }
    `;
}

class DataRow(T) {
	static if (isFloatingPoint!T) {
		T maxValue = T.max;
		T minValue = -T.max;
	}
	else {
		T maxValue = T.max;
		T minValue = T.min;
	}
	RowStatus status = RowStatus.invalid;
	T[] cells;
	T[] originCells;

	this(size_t aLength) { cells.length = aLength; originCells.length = aLength; }
	this(size_t aLength, T aValue) { this(aLength); uim.data.cells.fill(originCells, aValue); uim.data.cells.fill(cells, aValue); }
	this(T[] values) { 
		this(values.length);  
		foreach(i, value; values) { 
			originCells[i] = value; cells[i] = value; 
		}
	}
	this(DataRow!T row) { this(row.cells); }

	DataRow!T  fill(T aValue) { uim.data.cells.fill(cells, aValue); return this; }
	DataRow!T  fill(T aValue, size_t[] cols) { cells.fill(aValue, cols); return this; }
	DataRow!T  fill(T aValue, size_t from, size_t to) { cells.fill(aValue, from, to); return this; }

	DataRow!T  dup() { return new DataRow!T(this); }

	DataRow!T  reset() { foreach(i, cell; cells) cells[i] = originCells[i]; return this; }
	DataRow!T  reset(size_t[] cols) { foreach(col; cols) if (col < length) cells[col] = originCells[col]; return this; }

	DataRow!T  commit() { foreach(i, cell; cells) originCells[i] = cells[i]; return this; }
	DataRow!T  commit(size_t[] cols) { foreach(col; cols) if (col < length) originCells[col] = cells[col]; return this; }
	DataRow!T  commit(size_t cellFrom, size_t cellTo) { 
		mixin(Borders!("cell", "cells"));
		foreach(i; cellStart+1..cellEnd) originCells[i] = cells[i]; 
		return this; }

	DataRow!T  unChange() { foreach(i, cell; cells) originCells[i] = cells[i]; return this; }
	DataRow!T  unChange(size_t[] cols) { foreach(col; cols) if (col < length) originCells[col] = cells[col]; return this; }

	@property void length(size_t aLength) { cells.length = aLength; }
	@property auto length() { return cells.length; }
	bool hasValues() { return (length > 0); }

	DataRow!T init(T initValue) { cells[] = initValue; return this; }
	DataRow!T value(T val) { cells[] = val; return this; }

	bool changed() { return !equal(cells, originCells); }
	T[size_t] changedCellsByIndex() {
		T[size_t] cellsIndex; 
		foreach(i, c; cells) if (c != originCells[i]) cellsIndex[i] = c;
		return cellsIndex; }

	T[string] changedCellsByName(string[size_t] index2Name, string[] validColNames) { 
		T[string] rowCells;
		if (validColNames.length == 0)  return rowCells;

		foreach(index, value; cells) if (value != originCells[index]) { 
			auto colName = index2Name[index]; if (colName.isIn(validColNames)) rowCells[colName] = value; }
		return rowCells; 
	}
	T[string] changedCellsByName(string[size_t] index2Name) { 
		T[string] rowCells;
		foreach(index, value; cells) if (value != originCells[index]) rowCells[index2Name[index]] = value;
		return rowCells; 
	}

	void opIndexAssign(S=T)(S value, size_t i) { if (i < length) cells[i] = cast(T)value; }
	T opIndex(size_t i) { return (i < length) ? cells[i] : 0; }
	
	mixin(RowAggFunc!"add");
	mixin(RowAggFunc!"sub");
	mixin(RowAggFunc!"mul");
	mixin(RowAggFunc!"div");

	mixin(RowAggFunc!"min");
	mixin(RowAggFunc!"max");
	mixin(RowAggFunc!"sum");
	mixin(RowAggFunc!"neg");
	mixin(RowAggFunc!"pos");
	mixin(RowAggFunc!"avg");
	mixin(RowAggFunc!"geo");

	mixin(RowAggFunc!"deltasum");
	mixin(RowAggFunc!"deltaavg");
	mixin(RowAggFunc!"deltageo");
	mixin(RowAggFunc!"deltamin");
	mixin(RowAggFunc!"deltamax");

	mixin(RowAggFunc!"incsum");
	mixin(RowAggFunc!"incavg");
	mixin(RowAggFunc!"incgeo");
	mixin(RowAggFunc!"incmin");
	mixin(RowAggFunc!"incmax");

	mixin(RowAggFunc!"decsum");
	mixin(RowAggFunc!"decavg");
	mixin(RowAggFunc!"decgeo");
	mixin(RowAggFunc!"decmin");
	mixin(RowAggFunc!"decmax");

	mixin(RowAggFunc!"vltsum");
	mixin(RowAggFunc!"vltavg");
	mixin(RowAggFunc!"vltgeo");
	mixin(RowAggFunc!"vltmin");
	mixin(RowAggFunc!"vltmax");

	mixin(RowDifFunc!"difmin");
	mixin(RowDifFunc!"difmax");
	mixin(RowDifFunc!"difsum");
	mixin(RowDifFunc!"difavg");
	mixin(RowDifFunc!"difgeo");

	auto copy() { return new DataRow!T(this); } 

	override string toString() {
		string[] values;
		foreach(x; cells) values ~= to!string(x);
		return "["~values.join(",\t")~"]";
	}
	T[string] toAT(size_t[string] name2Index) {
		T[string] results;
		foreach(name, index; name2Index) results[name] = this[index];
		return results; }
}

auto rowColsToCells(T)(DataRow!(T) row, size_t[] cols) { 
	T[] result; result.length = cols.length; size_t counter;
	foreach(col; cols) if (col < row.length) { result[counter] = row[col]; counter++; }
	result.length = counter;
	return result;
}

unittest {
	import std.stdio;
	writeln("Loading uim.data...");
	
	writeln("---- START Test row int");
	
	auto iRow = new DataRow!int(10, 1);
	foreach(i; 0..iRow.length) iRow[i] = i; iRow[9] = 2;
	writeln(iRow);
	writeln("iRow.add=>", iRow.add);
	writeln("iRow.sub=>", iRow.sub);
	writeln("iRow.mul=>", iRow.mul);
	writeln("iRow.div=>", iRow.div);
	
	writeln("iRow.min=>", iRow.min);
	writeln("iRow.max=>", iRow.max);
	writeln("iRow.sum=>", iRow.sum);
	writeln("iRow.avg=>", iRow.avg);
	writeln("iRow.geo=>", iRow.geo);
	
	writeln("iRow.incmin=>", iRow.incmin);
	writeln("iRow.incmax=>", iRow.incmax);
	writeln("iRow.incsum=>", iRow.incsum);
	writeln("iRow.incavg=>", iRow.incavg);
	writeln("iRow.incgeo=>", iRow.incgeo);
	
	writeln("iRow.decmin=>", iRow.decmin);
	writeln("iRow.decmax=>", iRow.decmax);
	writeln("iRow.decsum=>", iRow.decsum);
	writeln("iRow.decavg=>", iRow.decavg);
	writeln("iRow.decgeo=>", iRow.decgeo);
	
	writeln("iRow.deltamin=>", iRow.deltamin);
	writeln("iRow.deltamax=>", iRow.deltamax);
	writeln("iRow.deltasum=>", iRow.deltasum);
	writeln("iRow.deltaavg=>", iRow.deltaavg);
	writeln("iRow.deltageo=>", iRow.deltageo);
	
	writeln("iRow.vltmin=>", iRow.vltmin);
	writeln("iRow.vltmax=>", iRow.vltmax);
	writeln("iRow.vltsum=>", iRow.vltsum);
	writeln("iRow.vltavg=>", iRow.vltavg);
	writeln("iRow.vltgeo=>", iRow.vltgeo);
	
	writeln("iRow.difmin=>", iRow.difmin(1));
	writeln("iRow.difmax=>", iRow.difmax(1));
	writeln("iRow.difsum=>", iRow.difsum(1));
	writeln("iRow.difavg=>", iRow.difavg(1));
	writeln("iRow.difgeo=>", iRow.difgeo(1));
	
	writeln("iRow.difmin(2)=>", iRow.difmin(2));
	writeln("iRow.difmax(2)=>", iRow.difmax(2));
	writeln("iRow.difsum(2)=>", iRow.difsum(2));
	writeln("iRow.difavg(2)=>", iRow.difavg(2));
	writeln("iRow.difgeo(2)=>", iRow.difgeo(2));
	
	readln;
	writeln("---- START Test row double");
	
	auto dRow = new DataRow!double(10, 1.1);
	foreach(i; 0..dRow.length) dRow[i] = i+0.1; dRow[9] = 2.0;
	writeln(dRow);
	writeln("dRow.add=>", dRow.add);
	writeln("dRow.sub=>", dRow.sub);
	writeln("dRow.mul=>", dRow.mul);
	writeln("dRow.div=>", dRow.div);
	
	writeln("dRow.min=>", dRow.min);
	writeln("dRow.max=>", dRow.max);
	writeln("dRow.sum=>", dRow.sum);
	writeln("dRow.avg=>", dRow.avg);
	writeln("dRow.geo=>", dRow.geo);
	
	writeln("dRow.incmin=>", dRow.incmin);
	writeln("dRow.incmax=>", dRow.incmax);
	writeln("dRow.incsum=>", dRow.incsum);
	writeln("dRow.incavg=>", dRow.incavg);
	writeln("dRow.incgeo=>", dRow.incgeo);
	
	writeln("dRow.decmin=>", dRow.decmin);
	writeln("dRow.decmax=>", dRow.decmax);
	writeln("dRow.decsum=>", dRow.decsum);
	writeln("dRow.decavg=>", dRow.decavg);
	writeln("dRow.decgeo=>", dRow.decgeo);
	
	writeln("dRow.deltamin=>", dRow.deltamin);
	writeln("dRow.deltamax=>", dRow.deltamax);
	writeln("dRow.deltasum=>", dRow.deltasum);
	writeln("dRow.deltaavg=>", dRow.deltaavg);
	writeln("dRow.deltageo=>", dRow.deltageo);
	
	writeln("dRow.vltmin=>", dRow.vltmin);
	writeln("dRow.vltmax=>", dRow.vltmax);
	writeln("dRow.vltsum=>", dRow.vltsum);
	writeln("dRow.vltavg=>", dRow.vltavg);
	writeln("dRow.vltgeo=>", dRow.vltgeo);
	
	writeln("dRow.difmin=>", dRow.difmin(1));
	writeln("dRow.difmax=>", dRow.difmax(1));
	writeln("dRow.difsum=>", dRow.difsum(1));
	writeln("dRow.difavg=>", dRow.difavg(1));
	writeln("dRow.difgeo=>", dRow.difgeo(1));
	
	writeln("dRow.difmin(2)=>", dRow.difmin(2));
	writeln("dRow.difmax(2)=>", dRow.difmax(2));
	writeln("dRow.difsum(2)=>", dRow.difsum(2));
	writeln("dRow.difavg(2)=>", dRow.difavg(2));
	writeln("dRow.difgeo(2)=>", dRow.difgeo(2));
}