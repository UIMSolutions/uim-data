module uim.data.classes.table;
<<<<<<< HEAD

import uim.data;

@safe:
=======

@safe:
import uim.data;
static import uim.data.classes.rows;

>>>>>>> ca64a2d (Updates)
template AggFuncs(string aggName) {
	const char[] AggFuncs = `
	alias rows`~aggName~` = uim.data.classes.rows.`~aggName~`;

	DataTable!T `~aggName~`(string target, string colName, size_t step, bool direction, T defaultResult = 0) { if (existsCol(target)) `~aggName~`(colName2Index[target], colName, step, direction, defaultResult); return this; }
	DataTable!T `~aggName~`(size_t target, string colName, size_t step, bool direction, T defaultResult = 0) { if (existsCol(colName)) `~aggName~`(target, colName2Index[colName], step, direction, defaultResult); return this; }
	DataTable!T `~aggName~`(string target, size_t col, size_t step, bool direction, T defaultResult = 0)     { if (existsCol(target)) `~aggName~`(colName2Index[target], col, step, direction, defaultResult); return this; }
	DataTable!T `~aggName~`(size_t target, size_t col, size_t step, bool direction, T defaultResult = 0)     { if (existsCol(target)) `~aggName~`(target, col, 0, height, step, direction, defaultResult); return this; }

	DataTable!T `~aggName~`(string target, string colName, size_t rowFrom, size_t rowTo, size_t step, bool direction, T defaultResult = 0) { if (existsCol(target)) `~aggName~`(colName2Index[target], colName, rowFrom, rowTo, step, direction, defaultResult);  return this; }
	DataTable!T `~aggName~`(size_t target, string colName, size_t rowFrom, size_t rowTo, size_t step, bool direction, T defaultResult = 0) { if (existsCol(colName)) `~aggName~`(target, colName2Index[colName], rowFrom, rowTo, step, direction, defaultResult); return this; }
	DataTable!T `~aggName~`(string target, size_t col, size_t rowFrom, size_t rowTo, size_t step, bool direction, T defaultResult = 0)     { if (existsCol(target)) `~aggName~`(colName2Index[target], col, rowFrom, rowTo, step, direction, defaultResult); return this; }
	DataTable!T `~aggName~`(size_t target, size_t col, size_t rowFrom, size_t rowTo, size_t step, bool direction, T defaultResult = 0)     { 
		if (!existsCol(target)) return this; auto targetCol = columns[target];
		if (!existsCol(col)) return this;    auto sourceCol = columns[col];
		
		if (rows) { 
			auto borders = arrayLimits(rowFrom, rowTo, rows); auto rowStart = borders[0]; auto rowEnd = borders[1];
			if (direction) { 
				foreach(i; rowStart..rowEnd) if (targetCol._cells[i]) targetCol[i] = sourceCol.`~aggName~`((step < i+1) ? i-step+1 : 0, i+1, defaultResult);  
			} 
			else {
				foreach(i; rowStart..rowEnd) if (targetCol._cells[i]) targetCol[i] = sourceCol.`~aggName~`(i, i+step, defaultResult); 
			}
		}
		return this; 
	}
	DataTable!T `~aggName~`(string target, string[] colNames, T defaultResult = 0) { if (existsCol(target)) `~aggName~`(colName2Index[target], colNames, defaultResult); return this; }
	DataTable!T `~aggName~`(size_t target, string[] colNames, T defaultResult = 0) { if (auto cols = names2Index(colNames, colName2Index)) `~aggName~`(target, cols, defaultResult); return this; }
	DataTable!T `~aggName~`(string target, size_t[] cols, T defaultResult = 0)     { if (existsCol(target)) `~aggName~`(colName2Index[target], cols, 0, height, defaultResult); return this; }
	DataTable!T `~aggName~`(size_t target, size_t[] cols, T defaultResult = 0)     { if (existsCol(target)) `~aggName~`(target, cols, 0, height, defaultResult); return this; }

	DataTable!T `~aggName~`(string target, string[] colNames, size_t rowFrom, size_t rowTo, T defaultResult = 0) { if (existsCol(target)) `~aggName~`(colName2Index[target], colNames, rowFrom, rowTo, defaultResult); return this; }
	DataTable!T `~aggName~`(size_t target, string[] colNames, size_t rowFrom, size_t rowTo, T defaultResult = 0) { if (auto cols = names2Index(colNames, colName2Index)) `~aggName~`(target, cols, rowFrom, rowTo, defaultResult); return this; }
	DataTable!T `~aggName~`(string target, size_t[] cols, size_t rowFrom, size_t rowTo, T defaultResult = 0)     { if (existsCol(target)) `~aggName~`(colName2Index[target], cols, rowFrom, rowTo, defaultResult); return this; }
	DataTable!T `~aggName~`(size_t target, size_t[] cols, size_t rowFrom, size_t rowTo, T defaultResult = 0)     { 
		if (!existsCol(target)) return this; auto targetCol = columns[target];

		if (rows) { 
			auto borders = arrayLimits(rowFrom, rowTo, rows); auto rowStart = borders[0]; auto rowEnd = borders[1];
			foreach(row; rows[rowStart..rowEnd]) if (row) row.`~aggName~`(target, cols, defaultResult); 
		} 
		return this; 
	}

	T `~aggName~`(string colName, T defaultResult = 0) { 
		// writeln("`~aggName~`(string colName, T defaultResult = 0)");
		if (existsCol(colName)) return `~aggName~`(colName2Index[colName], defaultResult); 
		return defaultResult; }
	T `~aggName~`(size_t col, T defaultResult = 0)     { 
		// writeln("`~aggName~`(size_t col = ", col, ", T defaultResult = 0)");
		if (existsCol(col)) return `~aggName~`(col, 0, height, defaultResult); 
		return defaultResult; }
    T `~aggName~`(string colName, size_t rowFrom, size_t rowTo, T defaultResult = 0) { if (existsCol(colName)) return rows`~aggName~`(rows, colName2Index[colName], rowFrom, rowTo, defaultResult); return defaultResult; }
    T `~aggName~`(size_t col, size_t rowFrom, size_t rowTo, T defaultResult = 0)     { 
		// writeln("T `~aggName~`(size_t col, size_t rowFrom, size_t rowTo, T defaultResult = 0)");
		if (!existsCol(col)) return defaultResult;    
		auto sourceCol = columns[col];
		return sourceCol.`~aggName~`(rowFrom, rowTo, defaultResult); }
 `;
}

template DifFuncs(string aggName) {
	const char[] DifFuncs = `
	alias rows`~aggName~` = uim.data.classes.rows.`~aggName~`;
	
	DataTable!T `~aggName~`(string target, string colName, T distance, size_t step, bool direction, T defaultResult = 0) { if (existsCol(target)) `~aggName~`(colName2Index[target], colName, distance, step, direction, defaultResult); return this; }
	DataTable!T `~aggName~`(size_t target, string colName, T distance, size_t step, bool direction, T defaultResult = 0) { if (existsCol(colName)) `~aggName~`(target, colName2Index[colName], distance, step, direction, defaultResult); return this; }
	DataTable!T `~aggName~`(string target, size_t col, T distance, size_t step, bool direction, T defaultResult = 0)     { if (existsCol(target)) `~aggName~`(colName2Index[target], col, distance, step, direction, defaultResult); return this; }
	DataTable!T `~aggName~`(size_t target, size_t col, T distance, size_t step, bool direction, T defaultResult = 0)     { if (existsCol(target)) `~aggName~`(target, col, distance, 0, height, step, direction, defaultResult); return this; }

	DataTable!T `~aggName~`(string target, string colName, T distance, size_t rowFrom, size_t rowTo, size_t step, bool direction, T defaultResult = 0) { if (existsCol(target)) `~aggName~`(colName2Index[target], colName, distance, rowFrom, rowTo, step, direction, defaultResult);  return this; }
	DataTable!T `~aggName~`(size_t target, string colName, T distance, size_t rowFrom, size_t rowTo, size_t step, bool direction, T defaultResult = 0) { if (existsCol(colName)) `~aggName~`(target, colName2Index[colName], distance, rowFrom, rowTo, step, direction, defaultResult); return this; }
	DataTable!T `~aggName~`(string target, size_t col, T distance, size_t rowFrom, size_t rowTo, size_t step, bool direction, T defaultResult = 0)     { if (existsCol(target)) `~aggName~`(colName2Index[target], col, distance, rowFrom, rowTo, step, direction, defaultResult); return this; }
	DataTable!T `~aggName~`(size_t target, size_t col, T distance, size_t rowFrom, size_t rowTo, size_t step, bool direction, T defaultResult = 0)     { if (existsCol(target)) rows`~aggName~`(rows, target, col, distance, rowFrom, rowTo, step, direction, defaultResult); return this; }

	DataTable!T `~aggName~`(string target, string[] colNames, T distance, T defaultResult = 0) { if (existsCol(target)) `~aggName~`(colName2Index[target], colNames, distance, defaultResult); return this; }
	DataTable!T `~aggName~`(size_t target, string[] colNames, T distance, T defaultResult = 0) { if (auto cols = names2Index(colNames, colName2Index)) `~aggName~`(target, cols, distance, defaultResult); return this; }
	DataTable!T `~aggName~`(string target, size_t[] cols, T distance, T defaultResult = 0)     { if (existsCol(target)) `~aggName~`(colName2Index[target], cols, distance, 0, height, defaultResult); return this; }
	DataTable!T `~aggName~`(size_t target, size_t[] cols, T distance, T defaultResult = 0)     { if (existsCol(target)) `~aggName~`(target, cols, distance, 0, height, defaultResult); return this; }

	DataTable!T `~aggName~`(string target, string[] colNames, T distance, size_t rowFrom, size_t rowTo, T defaultResult = 0) { if (existsCol(target)) `~aggName~`(colName2Index[target], colNames, distance, rowFrom, rowTo, defaultResult); return this; }
	DataTable!T `~aggName~`(size_t target, string[] colNames, T distance, size_t rowFrom, size_t rowTo, T defaultResult = 0) { if (auto cols = names2Index(colNames, colName2Index)) `~aggName~`(target, cols, distance, rowFrom, rowTo, defaultResult); return this; }
	DataTable!T `~aggName~`(string target, size_t[] cols, T distance, size_t rowFrom, size_t rowTo, T defaultResult = 0)     { if (existsCol(target)) `~aggName~`(colName2Index[target], cols, distance, rowFrom, rowTo, defaultResult); return this; }
	DataTable!T `~aggName~`(size_t target, size_t[] cols, T distance, size_t rowFrom, size_t rowTo, T defaultResult = 0)     { if (existsCol(target)) rows`~aggName~`(rows, target, cols, distance, rowFrom, rowTo, defaultResult); return this; }

	T `~aggName~`(string colName, T distance, T defaultResult = 0) { if (existsCol(colName)) return `~aggName~`(colName2Index[colName], distance, defaultResult); return defaultResult; }
	T `~aggName~`(size_t col, T distance, T defaultResult = 0)     { if (existsCol(col)) return `~aggName~`(col, distance, 0, height, defaultResult); return defaultResult; }
    T `~aggName~`(string colName, T distance, size_t rowFrom, size_t rowTo, T defaultResult = 0) { if (existsCol(colName)) return rows`~aggName~`(rows, colName2Index[colName], distance, rowFrom, rowTo, defaultResult); return defaultResult; }
    T `~aggName~`(size_t col, T distance, size_t rowFrom, size_t rowTo, T defaultResult = 0)     { if (existsCol(col)) return rows`~aggName~`(rows, col, distance, rowFrom, rowTo, defaultResult); return defaultResult; }
	`;
}


class DataTable(T) if (isNumeric!T) {
	static if (isFloatingPoint!T) {
		T maxValue = T.max;
		T minValue = -T.max;
	}
	else {
		T maxValue = T.max;
		T minValue = T.min;
	}

	DataRow!(T)[] rows;
	private DataColumn!T[] _columns;
	private string[] _colNames;
	size_t[string] colName2Index;
	string[size_t] colIndex2Name;

	// this() {}
	this(size_t width) {
		string[] cols; cols.length = width;
		foreach(i; 0..width) cols[i] = to!string(i);
		this(cols);
	} 
	this(string[] someColNames) {
		_colNames = someColNames; 

		colName2Index = someColNames.indexAA; 
		colIndex2Name = someColNames.indexAAReverse;
	}
	this(size_t width, size_t height) { this(width); rows.length = height; }
	this(size_t width, size_t height, T defaultValue) { this(width, height); fill(defaultValue); }

	this(string[] someColNames, size_t height) { this(someColNames); rows.length = height; }
	this(string[] someColNames, size_t height, T startValue) { this(someColNames, height);
		fill(startValue); 
		refreshColumns;
	}
	this(DataTable!T table) { 
		this(table.colNames, table.height);
		foreach(i, row; table.rows) rows[i] = new DataRow!T(row); 
		refreshColumns;
	}

	@property string[] colNames() { return _colNames; }
	@property size_t width() { return _colNames.length; }
	@property size_t height() { return rows.length; }
	size_t opDollar(size_t pos)() {
		static if (pos==0) return height;
		else return width; }

	@property DataColumn!T[] columns() { return _columns; }

	DataTable!T fill(T aValue) { return fill(aValue, 0, height); }
	DataTable!T fill(T aValue, size_t rowFrom, size_t rowTo) { 
		mixin(Borders!("row", "rows"));
		foreach(i; rowStart..rowEnd) rows[i] = new DataRow!T(width, aValue); 
		return this; 
	}
	DataTable!T fill(T aValue, size_t rowFrom, size_t rowTo, size_t cellFrom, size_t cellTo) {
		mixin(Borders!("row", "rows"));
		foreach(i; rowStart..rowEnd) rows[i] = (new DataRow!T(width)).fill(aValue, cellFrom, cellTo); 
		return this; 
	}
	DataTable!T fill(T aValue, size_t[] cols) { return fill(aValue, cols, 0, height); }
	DataTable!T fill(T aValue, size_t[] cols, size_t rowFrom, size_t rowTo) { 
		mixin(Borders!("row", "rows"));
		foreach(i; rowStart..rowEnd) rows[i] = (new DataRow!T(width, aValue)).fill(aValue, cols); 
		return this; 
	}

	DataTable!T reset() { foreach(row; rows) if (row) row.reset; return this; }
	DataTable!T unChange() { foreach(row; rows) if (row) row.unChange; return this; }
	void refreshColumns() {
		_columns.length = colNames.length;
		foreach(i, colName; colNames) {
			_columns[i] = new DataColumn!T(this, colName);
		}
	}

	bool existsCol(string name) { return (name in colName2Index) ? true : false; }
	bool existsCol(size_t index) { return (index < width); }

	auto newRow() { rows.length++; return newRow(rows.length-1); }
	auto newRow(T value) { rows.length++; return newRow(rows.length-1, value); }
	auto newRow(T[] values) { rows.length++; return newRow(rows.length-1, values);  }
	auto newRow(DataRow!T row) { rows.length++; return newRow(rows.length-1, row); }

	auto newRow(size_t index) { if (index >= rows.length) rows.length = index+1; rows[index] = new DataRow!T(width); return rows[index]; }
	auto newRow(size_t index, T value) { return newRow(index).fill(value); }
	auto newRow(size_t index, T[] values) { newRow(index); rows[index] = new DataRow!T(values); return rows[index]; }
	auto newRow(size_t index, DataRow!T row) { newRow(index); rows[index] = new DataRow!T(row); return rows[index]; }
	auto newRow(size_t index, T[string] values) { newRow(index); foreach(k, v; values) this[index, k] = v; return rows[index]; }

	void add(DataRow!T row) { row.length = width; rows ~= row; }
	
	auto firstRow() { return rows.first(); }
	auto firstRow(size_t rowFrom, size_t rowTo) { return rows.first(rowFrom, rowTo); }
	auto firstRowIndex() { return rows.firstIndex(); }
	auto firstRowIndex(size_t rowFrom, size_t rowTo) { return rows.firstIndex(rowFrom, rowTo); }

	auto lastRow() { return rows.last(); }
	auto lastRow(size_t rowFrom, size_t rowTo) { return rows.last(rowFrom, rowTo); }
	auto lastRowIndex() { return rows.lastIndex(); }
	auto lastRowIndex(size_t rowFrom, size_t rowTo) { return rows.lastIndex(rowFrom, rowTo); }

	T opIndex(size_t posY, size_t posX) { if ((posY < height) && (rows[posY]) && (posX < width)) return rows[posY][posX]; return T.init; }
	DataRow!T opIndex(size_t posY) { if (posY < height) return rows[posY]; return null; }
	DataRow!T[] opIndex(size_t[2] posY) { 
		if (posY[0] < height) {
			if (posY[1] < height) return rows[posY[0]..posY[1]]; 
			else return rows[posY[0]..$]; 
		}
		return null; }

	void opIndexAssign(DataRow!T row, size_t i) { if (i < height) rows[i] = row; }
	void opIndexAssign(T value, size_t i, size_t j) { if (this[i]) rows[i][j] = value; }
	void opIndexAssign(T value, size_t i, string col) { if (this[i]) if (col in colName2Index) rows[i][colName2Index[col]] = value; }

	DataColumn!T col(string col) { 
		if (col in colName2Index) { 
			auto i = colName2Index[col];
			return _columns[i];
		}
		return null;
	}
	
	mixin(AggFuncs!("add"));
	mixin(AggFuncs!("sub"));
	mixin(AggFuncs!("mul"));
	mixin(AggFuncs!("div"));

	mixin(AggFuncs!("min"));
	mixin(AggFuncs!("max"));
	mixin(AggFuncs!("sum"));
	mixin(AggFuncs!("neg"));
	mixin(AggFuncs!("pos"));
	mixin(AggFuncs!("avg"));
	mixin(AggFuncs!("geo"));

	mixin(AggFuncs!("deltamin"));
	mixin(AggFuncs!("deltamax"));
	mixin(AggFuncs!("deltasum"));
	mixin(AggFuncs!("deltaavg"));
	mixin(AggFuncs!("deltageo"));

	mixin(AggFuncs!("incmin"));
	mixin(AggFuncs!("incmax"));
	mixin(AggFuncs!("incsum"));
	mixin(AggFuncs!("incavg"));
	mixin(AggFuncs!("incgeo"));

	mixin(AggFuncs!("decmin"));
	mixin(AggFuncs!("decmax"));
	mixin(AggFuncs!("decsum"));
	mixin(AggFuncs!("decavg"));
	mixin(AggFuncs!("decgeo"));

	mixin(AggFuncs!("vltmin"));
	mixin(AggFuncs!("vltmax"));
	mixin(AggFuncs!("vltsum"));
	mixin(AggFuncs!("vltavg"));
	mixin(AggFuncs!("vltgeo"));

	//	mixin(DifFuncs!("difmin"));
	//	mixin(DifFuncs!("difmax"));
	//	mixin(DifFuncs!("difsum"));
	//	mixin(DifFuncs!("difavg"));
	//	mixin(DifFuncs!("difgeo"));

	size_t count() { return count(0, height); }
	size_t count(size_t rowFrom, size_t rowTo) { return uim.data.classes.rows.count(rows, rowFrom, rowTo); }
	size_t count(size_t[] rowIndex) { return uim.data.classes.rows.count(rows, rowIndex); }

	auto copy() { return new DataTable!T(this); }
	override string toString() {
		string result;
		result ~= "width:%s\theight:%s\n".format(width, height);
		foreach(i, row; rows) if (row) result ~= "%s:\t%s\n".format(i, row.toString);
		return result;
	}

	auto changedRows() { return uim.data.classes.rows.changedRows(rows); }
	T[size_t][] changedCellsByIndex() { 
		auto cRows = this.changedRows;
		return uim.data.classes.rows.changedCellsByIndex(cRows); }
	T[string][] changedCellsByName() { 
		if (auto cellsByIndex = changedCellsByIndex) {
			T[string][] results; results.length = cellsByIndex.length;
			foreach(i, rowCellsWithIndex; cellsByIndex) if (rowCellsWithIndex) {
				T[string] rowCellsWithName;
				foreach(key; rowCellsWithIndex.byKey) {
					rowCellsWithName[colIndex2Name[key]] = rowCellsWithIndex[key];
				}
				results[i] = rowCellsWithName;
			}
			return results; 
		}
		return null;
	}
	auto changedCellsByName(string[] validNames) { 
		T[string][] results; 
		if (auto cellsNamesRows = changedCellsByName) {
			results.length = cellsNamesRows.length;
			foreach(i, row; cellsNamesRows) {
				T[string] rowResults;
				foreach(name, value; row) if (validNames.canFind(name)) rowResults[name] = value;
				results[i] = rowResults;
			}
		}
		return results;
	}
	
	DataRow!(T)[] find(S)(size_t left, Ops op, S right) {
		DataRow!(T)[] result; size_t rCol;
		if ((op == op.GC) || (op == op.LC)) rCol = to!size_t(right);
		
		foreach(row; rows) if (row) {
			final switch(op) {
				case Ops.GC: if (row[left] > row[rCol]) result ~= row; break;
				case Ops.LC: if (row[left] < row[rCol]) result ~= row; break;
				case Ops.GV: if (row[left] > right) result ~= row; break;
				case Ops.LV: if (row[left] < right) result ~= row; break;
			}
		}
		return result;
	}

	DataTable!T remove(size_t rowFrom, size_t rowTo) { uim.data.classes.rows.remove(rows, rowFrom, rowTo); return this; }
	DataTable!T remove(size_t[] values) { uim.data.classes.rows.remove(rows, values); return this; }

	auto columnCells(size_t col) {
		T[] cells; 
		cells.length = height;
		foreach(i, row; rows) if (col < row.length) cells[i] = row[col]; else cells[i] = 0; 
		return cells;
	}
}

unittest {
	import std.stdio;
	writeln("\f---- START Test table int");
	auto iTable = new DataTable!int(10, 10); iTable.fill(1);
	foreach(i; 0..10) writeln(iTable[i]); writeln;
	foreach(i; 0..10) foreach(j; 0..10) iTable[i][j] = i*10+j;
	foreach(i; 0..10) writeln(iTable[i]); writeln;
	iTable.refreshColumns;
	
	writeln("add(iTable(0))=>", iTable.add(0));
	writeln("sub(iTable(0))=>", iTable.sub(0));
	writeln("mul(iTable(0))=>", iTable.mul(0));
	writeln("div(iTable(0))=>", iTable.div(0));
	
	writeln("min(iTable(0))=>", iTable.min(0));
	writeln("max(iTable(0))=>", iTable.max(0));
	writeln("sum(iTable(0))=>", iTable.sum(0));
	writeln("avg(iTable(0))=>", iTable.avg(0));
	writeln("geo(iTable(0))=>", iTable.geo(0));
	
	writeln("deltamin(iTable(0))=>", iTable.deltamin(0));
	writeln("deltamax(iTable(0))=>", iTable.deltamax(0));
	writeln("deltasum(iTable(0))=>", iTable.deltasum(0));
	writeln("deltaavg(iTable(0))=>", iTable.deltaavg(0));
	writeln("deltageo(iTable(0))=>", iTable.deltageo(0));
	
	writeln("incmin(iTable(0))=>", iTable.incmin(0));
	writeln("incmax(iTable(0))=>", iTable.incmax(0));
	writeln("incsum(iTable(0))=>", iTable.incsum(0));
	writeln("incavg(iTable(0))=>", iTable.incavg(0));
	writeln("incgeo(iTable(0))=>", iTable.incgeo(0));
	
	writeln("decmin(iTable(0))=>", iTable.decmin(0));
	writeln("decmax(iTable(0))=>", iTable.decmax(0));
	writeln("decsum(iTable(0))=>", iTable.decsum(0));
	writeln("decavg(iTable(0))=>", iTable.decavg(0));
	writeln("decgeo(iTable(0))=>", iTable.decgeo(0));
	
	writeln("vltmin(iTable(0))=>", iTable.vltmin(0));
	writeln("vltmax(iTable(0))=>", iTable.vltmax(0));
	writeln("vltsum(iTable(0))=>", iTable.vltsum(0));
	writeln("vltavg(iTable(0))=>", iTable.vltavg(0));
	writeln("vltgeo(iTable(0))=>", iTable.vltgeo(0));
	
	//	writeln("iTable.difmin=>", iTable.difmin(0, 1));
	//	writeln("iTable.difmax=>", iTable.difmax(0, 1));
	//	writeln("iTable.difsum=>", iTable.difsum(0, 1));
	//	writeln("iTable.difavg=>", iTable.difavg(0, 1));
	//	writeln("iTable.difgeo=>", iTable.difgeo(0, 1));
	//	
	//	writeln("iTable.difmin(2)=>", iTable.difmin(0, 2));
	//	writeln("iTable.difmax(2)=>", iTable.difmax(0, 2));
	//	writeln("iTable.difsum(2)=>", iTable.difsum(0, 2));
	//	writeln("iTable.difavg(2)=>", iTable.difavg(0, 2));
	//	writeln("iTable.difgeo(2)=>", iTable.difgeo(0, 2));
	
	// readln;
	
	/* writeln("\f---- START Test table double");
	auto dTable = new DataTable!double(10, 10); dTable.fill(1.1);
	foreach(i; 0..10) foreach(j; 0..10) dTable[i][j] = i*10.0+j;
	foreach(i; 0..10) writeln(dTable[i]); writeln;
	dTable.refreshColumns;
	
	writeln("add(dTable(0))=>", dTable.add(0));
	writeln("sub(dTable(0))=>", dTable.sub(0));
	writeln("mul(dTable(0))=>", dTable.mul(0));
	writeln("div(dTable(0))=>", dTable.div(0));
	
	writeln("min(dTable(0))=>", dTable.min(0));
	writeln("max(dTable(0))=>", dTable.max(0));
	writeln("sum(dTable(0))=>", dTable.sum(0));
	writeln("avg(dTable(0))=>", dTable.avg(0));
	writeln("geo(dTable(0))=>", dTable.geo(0));
	
	writeln("deltamin(dTable(0))=>", dTable.deltamin(0));
	writeln("deltamax(dTable(0))=>", dTable.deltamax(0));
	writeln("deltasum(dTable(0))=>", dTable.deltasum(0));
	writeln("deltaavg(dTable(0))=>", dTable.deltaavg(0));
	writeln("deltageo(dTable(0))=>", dTable.deltageo(0));
	
	writeln("incmin(dTable(0))=>", dTable.incmin(0));
	writeln("incmax(dTable(0))=>", dTable.incmax(0));
	writeln("incsum(dTable(0))=>", dTable.incsum(0));
	writeln("incavg(dTable(0))=>", dTable.incavg(0));
	writeln("incgeo(dTable(0))=>", dTable.incgeo(0));
	
	writeln("decmin(dTable(0))=>", dTable.decmin(0));
	writeln("decmax(dTable(0))=>", dTable.decmax(0));
	writeln("decsum(dTable(0))=>", dTable.decsum(0));
	writeln("decavg(dTable(0))=>", dTable.decavg(0));
	writeln("decgeo(dTable(0))=>", dTable.decgeo(0));
	
	writeln("vltmin(dTable(0))=>", dTable.vltmin(0));
	writeln("vltmax(dTable(0))=>", dTable.vltmax(0));
	writeln("vltsum(dTable(0))=>", dTable.vltsum(0));
	writeln("vltavg(dTable(0))=>", dTable.vltavg(0));
	writeln("vltgeo(dTable(0))=>", dTable.vltgeo(0)); */
	
	//	writeln("dTable.difmin=>", dTable.difmin(0, 1.0));
	//	writeln("dTable.difmax=>", dTable.difmax(0, 1.0));
	//	writeln("dTable.difsum=>", dTable.difsum(0, 1.0));
	//	writeln("dTable.difavg=>", dTable.difavg(0, 1.0));
	//	writeln("dTable.difgeo=>", dTable.difgeo(0, 1.0));
	//	
	//	writeln("dTable.difmin(2)=>", dTable.difmin(0, 2.0));
	//	writeln("dTable.difmax(2)=>", dTable.difmax(0, 2.0));
	//	writeln("dTable.difsum(2)=>", dTable.difsum(0, 2.0));
	//	writeln("dTable.difavg(2)=>", dTable.difavg(0, 2.0));
	//	writeln("dTable.difgeo(2)=>", dTable.difgeo(0, 2.0));

}