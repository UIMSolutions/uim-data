module uim.data.classes.rows;

import std.array;
import std.string;
import std.stdio;
import std.conv;
@safe:
import uim.data;

template RowsAggFunc(string aggName) {
	const char[] RowsAggFunc = `
	alias row`~aggName~` = uim.data.row.`~aggName~`;

	auto `~aggName~`(T)(DataRow!(T)[] rows, size_t target, size_t[] cols, T defaultResult = 0) if (isNumeric!T) { return `~aggName~`(rows, target, cols, 0, rows.length, defaultResult); }
	auto `~aggName~`(T)(DataRow!(T)[] rows, size_t target, size_t[] cols, size_t rowFrom, size_t rowTo, T defaultResult = 0)  if (isNumeric!T) { 
		if (rows) { 
			auto borders = arrayLimits(rowFrom, rowTo, rows); auto rowStart = borders[0]; auto rowEnd = borders[1];
			foreach(row; rows[rowStart..rowEnd]) if (row) row.`~aggName~`(target, cols, defaultResult); } 
		return rows; }

	auto `~aggName~`(T)(DataRow!(T)[] rows, size_t target, size_t col, size_t step, bool direction, T defaultResult = 0) if (isNumeric!T) { return `~aggName~`(rows, target, col, 0, rows.length, step, direction, defaultResult); }
	auto `~aggName~`(T)(DataRow!(T)[] rows, size_t target, size_t col, size_t rowFrom, size_t rowTo, size_t step, bool direction, T defaultResult = 0)  if (isNumeric!T) { 
		if (rows) { auto borders = arrayLimits(rowFrom, rowTo, rows); auto rowStart = borders[0]; auto rowEnd = borders[1];
			if (direction) {
				foreach(i; rowStart..rowEnd) if (auto row = rows[i]) row[target] = rows.`~aggName~`(col, (step < i+1) ? i-step+1 : 0, i+1, defaultResult); 
			}
			else {
				foreach(i; rowStart..rowEnd) if (auto row = rows[i]) row[target] = rows.`~aggName~`(col, i, i+step, defaultResult);  
			}
		}
		return rows; }
	
	T `~aggName~`(T)(DataRow!(T)[] rows, size_t col, T defaultResult = 0)  if (isNumeric!T) { if (rows) return `~aggName~`(rows, col, 0, rows.length, defaultResult); return defaultResult; }
    T `~aggName~`(T)(DataRow!(T)[] rows, size_t col, size_t rowFrom, size_t rowTo, T defaultResult = 0) if (isNumeric!T) { if (rows) { return uim.data.cells.`~aggName~`(rowsColToCells(rows, col, rowFrom, rowTo), defaultResult); } return defaultResult; }
  `;
}			

template RowsDifFunc(string aggName) {
	const char[] RowsDifFunc = `
	alias row`~aggName~` = uim.data.row.`~aggName~`;

    auto `~aggName~`(T)(DataRow!(T)[] rows, size_t target, size_t[] cols, int distance) if (isNumeric!T) { if (rows) `~aggName~`(rows, target, cols, 0, rows.length, distance); return rows; }
    auto `~aggName~`(T)(DataRow!(T)[] rows, size_t target, size_t[] cols, size_t rowFrom, size_t rowTo, int distance)  if (isNumeric!T) { 
	  if (rows) {
		auto borders = arrayLimits(rowFrom, rowTo, rows); auto rowStart = borders[0]; auto rowEnd = borders[1];
	  	foreach(row; rows[rowStart..rowEnd]) if (row) row.`~aggName~`(target, cols, distance); 
	  }
      return rows;
    }

    T `~aggName~`(T)(DataRow!(T)[] rows, size_t col, int distance)  if (isNumeric!T) { return `~aggName~`(rows, col, 0, rows.length, distance); }
	T `~aggName~`(T)(DataRow!(T)[] rows, size_t col, size_t rowFrom, size_t rowTo, int distance)  if (isNumeric!T) { 
		auto borders = arrayLimits(rowFrom, rowTo, rows); auto rowStart = borders[0]; auto rowEnd = borders[1];
		auto cells = rows.rowsColToCells(col, rowStart, rowEnd);
		return uim.data.cells.`~aggName~`(cells, distance);
	}
	T `~aggName~`(T)(DataRow!(T)[] rows, size_t col, size_t[] rowIndex, int distance)  if (isNumeric!T) { 
		auto cells = rows.rowsColToCells(col, rowIndex);
		return uim.data.cells.`~aggName~`(cells, distance);
	}
  `;
}
auto newRows(T)(size_t height, size_t width) {
	DataRow!T[] result; result.length = height;
	foreach(i; 0..height) result[i] = new DataRow!T(width);
	return result;
} 
auto newRows(T)(size_t height, size_t width, T initValue) {
	DataRow!T[] result; result.length = height;
	foreach(i; 0..height) result[i] = new DataRow!T(width, initValue);
	return result;
} 

auto get(T)(DataRow!(T)[] rows, size_t index) { return (index < rows.length) ? rows[index] : null; }
auto set(T)(DataRow!(T)[] rows, size_t index, DataRow!T row) { if (index < rows.length) rows[index] = row; return rows; }

auto first(T)(DataRow!(T)[] rows) { return first(rows, 0, rows.length); }
auto first(T)(DataRow!(T)[] rows, size_t rowFrom, size_t rowTo) { if (rows) {
		mixin(Borders!("row", "rows"));
		foreach(i; rowStart..rowEnd) if (auto row = rows[i]) return row;
	} return null; }
auto first(T)(DataRow!(T)[] rows, size_t[] index) { if (rows) {
		foreach(i; index) if (auto row = rows.get(i)) return row;
	} return null; }

auto firstIndex(T)(DataRow!(T)[] rows) { return firstIndex(rows, 0, rows.length); }
auto firstIndex(T)(DataRow!(T)[] rows, size_t rowFrom, size_t rowTo) { if (rows) {
		mixin(Borders!("row", "rows"));
		foreach(i; rowStart..rowEnd) if (rows[i]) return i; 
	} return -1; }
auto firstIndex(T)(DataRow!(T)[] rows, size_t[] index) { if (rows) {
		foreach(i; index) if (rows.get(i)) return i; 
	} return -1; }

auto last(T)(DataRow!(T)[] rows) { return last(rows, 0, rows.length); }
auto last(T)(DataRow!(T)[] rows, size_t rowFrom, size_t rowTo) { if (rows) {
		mixin(Borders!("row", "rows"));
		foreach_reverse(i; rowStart..rowEnd) if (auto row = rows[i]) return row;
	} return null; }
auto last(T)(DataRow!(T)[] rows, size_t[] index) { if (rows) {
		foreach_reverse(i; index) if (auto row = rows.get(i)) return row;
	} return null; }

auto lastIndex(T)(DataRow!(T)[] rows) { return lastIndex(rows, 0, rows.length); }
auto lastIndex(T)(DataRow!(T)[] rows, size_t rowFrom, size_t rowTo) { 
	if (rows) {
		mixin(Borders!("row", "rows"));
		foreach_reverse(i; rowStart..rowEnd) if (rows[i]) return i;
	} return -1; }
auto lastIndex(T)(DataRow!(T)[] rows, size_t[] index) { if (rows) {
		foreach_reverse(i; index) if (rows.get(i)) return i;
	} return -1; }

size_t count(T)(DataRow!(T)[] rows) { return count(rows, 0, rows.length); }
size_t count(T)(DataRow!(T)[] rows, size_t rowFrom, size_t rowTo) { 
	size_t counter; 
	if (rows) {
		mixin(Borders!("row", "rows"));
		foreach(i; rowStart..rowEnd) if (rows[i]) counter++;
	} return counter; }
size_t count(T)(DataRow!(T)[] rows, size_t[] index) { 
	size_t counter = 0; 
	foreach(i; index) if (rows.get(i)) counter++; 
	return counter; }

mixin(RowsAggFunc!("add"));
mixin(RowsAggFunc!("sub"));
mixin(RowsAggFunc!("mul"));
mixin(RowsAggFunc!("div"));

mixin(RowsAggFunc!("min"));
mixin(RowsAggFunc!("max"));
mixin(RowsAggFunc!("sum"));
mixin(RowsAggFunc!("pos"));
mixin(RowsAggFunc!("neg"));
mixin(RowsAggFunc!("avg"));
mixin(RowsAggFunc!("geo"));

mixin(RowsAggFunc!("deltamin"));
mixin(RowsAggFunc!("deltamax"));
mixin(RowsAggFunc!("deltasum"));
mixin(RowsAggFunc!("deltaavg"));
mixin(RowsAggFunc!("deltageo"));

mixin(RowsAggFunc!("incmin"));
mixin(RowsAggFunc!("incmax"));
mixin(RowsAggFunc!("incsum"));
mixin(RowsAggFunc!("incavg"));
mixin(RowsAggFunc!("incgeo"));

mixin(RowsAggFunc!("decmin"));
mixin(RowsAggFunc!("decmax"));
mixin(RowsAggFunc!("decsum"));
mixin(RowsAggFunc!("decavg"));
mixin(RowsAggFunc!("decgeo"));

mixin(RowsAggFunc!("vltmin"));
mixin(RowsAggFunc!("vltmax"));
mixin(RowsAggFunc!("vltsum"));
mixin(RowsAggFunc!("vltavg"));
mixin(RowsAggFunc!("vltgeo"));

mixin(RowsDifFunc!("difmin"));
mixin(RowsDifFunc!("difmax"));
mixin(RowsDifFunc!("difsum"));
mixin(RowsDifFunc!("difavg"));
mixin(RowsDifFunc!("difgeo"));

bool hasValues(T)(DataRow!(T)[] rows) {
	if (rows.length == 0) return false;
	foreach(row; rows) if (row) { if (hasValues.row) return true; }
	return false;
}
bool isRect(T)(DataRow!(T)[] rows) {
	if (rows) {
		auto size = rows[0].length;
		foreach(row; rows) {
			if (!row) return false;
			if (row.length != size) return false;
		}
		return true;
	}
	return false;
}

size_t width(T)(DataRow!(T)[] rows) {
	if (rows) return rows[0].length;
	return 0;
}

string toString(T)(DataRow!(T)[] rows) {
	string result;
	foreach(row; rows) if (row)  { result ~= row.toString; }
	return result;
}


size_t count(T)(DataRow!(T)[] rows, size_t left, Ops op, T right) if (isBasicType!T) {	
	import std.conv;
	size_t result, rCol;
	if ((op == op.GTC) || (op == op.LTC)) rCol = to!size_t(right);
	
	switch(op) {
		case Ops.GTC: foreach(row; rows) if (row) if (row[left] > row[rCol]) result++; break;
		case Ops.LTC: foreach(row; rows) if (row) if (row[left] < row[rCol]) result++; break;
		case Ops.GTV: foreach(row; rows) if (row) if (row[left] > right) result++; break;
		case Ops.LTV: foreach(row; rows) if (row) if (row[left] < right) result++; break;
		default:break;
	}

	return result;
}

DataRow!(T)[] find(T, S)(DataRow!(T)[] rows, size_t left, Ops op, S right) if (isBasicType!T) {	
	import std.conv;
	DataRow!(T)[] result; 

	size_t rCol;
	if ((op == op.GTC) || (op == op.LTC)) rCol = to!size_t(right);
	
	final switch(op) {
		case Ops.GTC: foreach(row; rows) if (row) if (row[left] > row[rCol]) result ~= row; break;
		case Ops.LTC: foreach(row; rows) if (row) if (row[left] < row[rCol]) result ~= row; break;
		case Ops.GTV: foreach(row; rows) if (row) if (row[left] > right) result ~= row; break;
		case Ops.LTV: foreach(row; rows) if (row) if (row[left] < right) result ~= row; break;
	}
	return result;
}

DataRow!(T)[] compress(T)(DataRow!(T)[] rows) if (isBasicType!T) {	
	DataRow!(T)[] result;  result.length = rows.length;
	size_t counter;	
	foreach(row; rows) if (row) { result[counter] = row; counter++; }
	result.length = counter;
	return result;
}
DataRow!(T)[] selectColCol(T)(DataRow!(T)[] rows, size_t left, Relations relation, size_t right) if (isBasicType!T) {	
	// writeln("selectColCol(T)(DataRow!(T)[] rows, %s, %s, %s)".format(left, relation, right));
	import std.conv;
	DataRow!(T)[] result;  result.length = rows.length;
	size_t counter;	
	switch(relation) {
		case Relations.GT: foreach(row; rows) if (row) { if (row[left] > row[right])  { result[counter] = row; counter++; }} break;
		case Relations.GE: foreach(row; rows) if (row) { if (row[left] >= row[right]) { result[counter] = row; counter++; }} break;
		case Relations.EQ: foreach(row; rows) if (row) { if (row[left] == row[right])  { result[counter] = row; counter++; }} break;
		case Relations.NEQ: foreach(row; rows) if (row) { if (row[left] != row[right])  { result[counter] = row; counter++; }} break;
		case Relations.LE: foreach(row; rows) if (row) { if (row[left] <= row[right]) { result[counter] = row; counter++; }} break;
		case Relations.LT: foreach(row; rows) if (row) { if (row[left] < row[right])  { result[counter] = row; counter++; }} break;
		default: break;
	}
	result.length = counter;
	return result;
}
void selectColCol(T)(DataRow!(T)[] rows, size_t left, Relations relation, size_t right, ref DataRow!(T)[] toRows) if (isBasicType!T) {	
	toRows.length = rows.length;
	size_t counter;	
	switch(relation) {
		case Relations.GT: foreach(row; rows) if (row) { if (row[left] > row[right])  { toRows[counter] = row; counter++; }} break;
		case Relations.GE: foreach(row; rows) if (row) { if (row[left] >= row[right]) { toRows[counter] = row; counter++; }} break;
		case Relations.EQ: foreach(row; rows) if (row) { if (row[left] == row[right])  { toRows[counter] = row; counter++; }} break;
		case Relations.NEQ: foreach(row; rows) if (row) { if (row[left] != row[right])  { toRows[counter] = row; counter++; }} break;
		case Relations.LE: foreach(row; rows) if (row) { if (row[left] <= row[right]) { toRows[counter] = row; counter++; }} break;
		case Relations.LT: foreach(row; rows) if (row) { if (row[left] < row[right])  { toRows[counter] = row; counter++; }} break;
		default: break;
	}
	toRows.length = counter;
}

DataRow!(T)[] selectColVal(T)(DataRow!(T)[] rows, size_t left, Relations relation, T right) if (isBasicType!T) {	
	// writeln("selectColVal(T)(DataRow!(T)[] rows, size_t left, Relations relation, T right)");
	import std.conv;
	DataRow!(T)[] result;  result.length = rows.length;
	size_t counter;	
	switch(relation) {
		case Relations.GT: foreach(row; rows) if (row) { if (row[left] > right)  { result[counter] = row; counter++; }} break;
		case Relations.GE: foreach(row; rows) if (row) { if (row[left] >= right) { result[counter] = row; counter++; }} break;
		case Relations.NEQ: foreach(row; rows) if (row) { if (row[left] != right)  { result[counter] = row; counter++; }} break;
		case Relations.EQ: foreach(row; rows) if (row) { if (row[left] == right)  { result[counter] = row; counter++; }} break;
		case Relations.LE: foreach(row; rows) if (row) { if (row[left] <= right) { result[counter] = row; counter++; }} break;
		case Relations.LT: foreach(row; rows) if (row) { if (row[left] < right)  { result[counter] = row; counter++; }} break;
		default: break;
	}
	result.length = counter;
	return result;
}
void selectColVal(T)(DataRow!(T)[] rows, size_t left, Relations relation, T right, ref DataRow!(T)[] toRows) if (isBasicType!T) {	
	toRows.length = rows.length;
	size_t counter;	
	switch(relation) {
		case Relations.GT: foreach(row; rows) if (row) { if (row[left] > right)  { toRows[counter] = row; counter++; }} break;
		case Relations.GE: foreach(row; rows) if (row) { if (row[left] >= right) { toRows[counter] = row; counter++; }} break;
		case Relations.NEQ: foreach(row; rows) if (row) { if (row[left] != right)  { toRows[counter] = row; counter++; }} break;
		case Relations.EQ: foreach(row; rows) if (row) { if (row[left] == right)  { toRows[counter] = row; counter++; }} break;
		case Relations.LE: foreach(row; rows) if (row) { if (row[left] <= right) { toRows[counter] = row; counter++; }} break;
		case Relations.LT: foreach(row; rows) if (row) { if (row[left] < right)  { toRows[counter] = row; counter++; }} break;
		default: break;
	}
	toRows.length = counter;
}

DataRow!(T)[] selectValCol(T)(DataRow!(T)[] rows, T left, Relations relation, size_t right) if (isBasicType!T) {	
	// writeln("selectValCol(T)(DataRow!(T)[] rows, T left, Relations relation, size_t right)");
	import std.conv;
	DataRow!(T)[] result;  result.length = rows.length;
	size_t counter;	
	switch(relation) {
		case Relations.GT: foreach(row; rows) if (row) { if (left > row[right])  { result[counter] = row; counter++; }} break;
		case Relations.GE: foreach(row; rows) if (row) { if (left >= row[right]) { result[counter] = row; counter++; }} break;
		case Relations.EQ: foreach(row; rows) if (row) { if (left == row[right])  { result[counter] = row; counter++; }} break;
		case Relations.NEQ: foreach(row; rows) if (row) { if (left != row[right])  { result[counter] = row; counter++; }} break;
		case Relations.LE: foreach(row; rows) if (row) { if (left <= row[right]) { result[counter] = row; counter++; }} break;
		case Relations.LT: foreach(row; rows) if (row) { if (left < row[right])  { result[counter] = row; counter++; }} break;
		default: break;
	}
	result.length = counter;
	return result;
}
void selectValCol(T)(DataRow!(T)[] rows, T left, Relations relation, size_t right, ref DataRow!(T)[] toRows) if (isBasicType!T) {	
	toRows.length = rows.length;
	size_t counter;	
	switch(relation) {
		case Relations.GT: foreach(row; rows) if (row) { if (left > row[right])  { toRows[counter] = row; counter++; }} break;
		case Relations.GE: foreach(row; rows) if (row) { if (left >= row[right]) { toRows[counter] = row; counter++; }} break;
		case Relations.EQ: foreach(row; rows) if (row) { if (left == row[right])  { toRows[counter] = row; counter++; }} break;
		case Relations.NEQ: foreach(row; rows) if (row) { if (left != row[right])  { toRows[counter] = row; counter++; }} break;
		case Relations.LE: foreach(row; rows) if (row) { if (left <= row[right]) { toRows[counter] = row; counter++; }} break;
		case Relations.LT: foreach(row; rows) if (row) { if (left < row[right])  { toRows[counter] = row; counter++; }} break;
		default: break;
	}
	toRows.length = counter;
}

DataRow!(T)[] selectValVal(T)(DataRow!(T)[] rows, T left, Relations relation, T right) if (isBasicType!T) {	
	// writeln("selectValVal(T)(DataRow!(T)[] rows, T left, Relations relation, T right)");
	import std.conv;
	DataRow!(T)[] result;  result.length = rows.length;
	size_t counter;	
	switch(relation) {
		case Relations.GT: foreach(row; rows) if (row) { if (left > right)  { result[counter] = row; counter++; }} break;
		case Relations.GE: foreach(row; rows) if (row) { if (left >= right) { result[counter] = row; counter++; }} break;
		case Relations.EQ: foreach(row; rows) if (row) { if (left == right)  { result[counter] = row; counter++; }} break;
		case Relations.NEQ: foreach(row; rows) if (row) { if (left != right)  { result[counter] = row; counter++; }} break;
		case Relations.LE: foreach(row; rows) if (row) { if (left <= right) { result[counter] = row; counter++; }} break;
		case Relations.LT: foreach(row; rows) if (row) { if (left < right)  { result[counter] = row; counter++; }} break;
		default: break;
	}
	result.length = counter;
	return result;
}
void selectValVal(T)(DataRow!(T)[] rows, T left, Relations relation, T right, ref DataRow!(T)[] toRows) if (isBasicType!T) {	
	toRows.length = rows.length;
	size_t counter;	
	switch(relation) {
		case Relations.GT: foreach(row; rows) if (row) { if (left > right)  { toRows[counter] = row; counter++; }} break;
		case Relations.GE: foreach(row; rows) if (row) { if (left >= right) { toRows[counter] = row; counter++; }} break;
		case Relations.EQ: foreach(row; rows) if (row) { if (left == right)  { toRows[counter] = row; counter++; }} break;
		case Relations.NEQ: foreach(row; rows) if (row) { if (left != right)  { toRows[counter] = row; counter++; }} break;
		case Relations.LE: foreach(row; rows) if (row) { if (left <= right) { toRows[counter] = row; counter++; }} break;
		case Relations.LT: foreach(row; rows) if (row) { if (left < right)  { toRows[counter] = row; counter++; }} break;
		default: break;
	}
	toRows.length = counter;
}

auto fill(T)(DataRow!(T)[] rows, T value) { if (rows) rows.fill(value, 0, rows.length); return rows; }  
auto fill(T)(DataRow!(T)[] rows, T value, size_t rowFrom, size_t rowTo) { 
	if (rows) {
		auto borders = arrayLimits(rowFrom, rowTo, rows); auto rowStart = borders[0]; auto rowEnd = borders[1];

		foreach(row; rows[rowStart..rowEnd]) if (row) { row.fill(value); } 
	}
	return rows; }  

auto fill(T)(DataRow!(T)[] rows, T value, size_t[] cols) { if (rows) rows.fill(value, cols, 0, rows.length); return rows; }  
auto fill(T)(DataRow!(T)[] rows, T value, size_t[] colse, size_t rowFrom, size_t rowTo) { 
	if (rows) {
		auto borders = arrayLimits(rowFrom, rowTo, rows); auto rowStart = borders[0]; auto rowEnd = borders[1];

		foreach(row; rows[rowStart..rowEnd]) if (row) { row.fill(value, cols); }
	}
	return rows; }  

string toString(T)(DataRow!(T)[] rows) {
	string result;
	foreach(row; rows) if (row) { result ~= row.toString; }
	return result;
}

auto newRows(T)(size_t height, size_t width) {
	DataRow!(T)[] result;
	foreach(i; 0..height) result ~= new DataRow!T(width); 
	return result;
}

auto remove(T)(DataRow!(T)[] rows) { return remove(rows, 0, rows.length); } 
auto remove(T)(DataRow!(T)[] rows, size_t rowFrom, size_t rowTo) { 
	mixin(Borders!("row", "rows"));
	foreach(i; rowStart..rowEnd) rows[i] = null; return rows; 
}
auto remove(T)(DataRow!(T)[] rows, size_t[] values) { foreach(i; values) if (i < rows.length) rows[i] = null; return rows; }

auto fill(T)(DataRow!(T)[] rows, T value) { 
	foreach(row; rows) if (row) { row.fill(value); }
	return rows; 
}

auto changedRows(T)(DataRow!(T)[] rows) {
	DataRow!(T)[] results; results.length = rows.length;
	foreach(i, row; rows) if (row) if (row.changed) results[i] = row;
	return results;
}
T[size_t][] changedCellsByIndex(T)(DataRow!(T)[] rows) {
	//writeln("T[size_t][] changedCells(T)(DataRow!(T)[] rows)");
	T[size_t][] results; results.length = rows.length;
	foreach(i, row; rows) if (row) {
		if (row.changed) results[i] = row.changedCellsByIndex;
	} 
	return results;
}

T[string][] changedCellsByName(T)(DataRow!(T)[] rows, string[size_t] index2Name) { 
	if (auto cRows = changedRows(rows)) {
		T[string][] results; results.length = cRows.length;
		foreach(i, row; rows) if (row) { results[i] = row.changedCellsByName(index2Name); }
		return results; 
	}
	return null;
}
T[string][] changedCellsByName(T)(DataRow!(T)[] rows, string[size_t] index2Name, string[] validNames) { 
	if (auto cRows = changedRows(rows)) {
		T[string][] results; results.length = cRows.length;
		foreach(i, row; rows) if (row) { results[i] = row.changedCellsByName(index2Name, validNames); }
		return results; 
	}
	return null;
}
auto rowsColToCells(T)(DataRow!(T)[] rows, size_t col) { return rowsColToCells(rows, col, 0, rows.length); }
auto rowsColToCells(T)(DataRow!(T)[] rows, size_t col, size_t rowFrom, size_t rowTo) { 
	T[] result; result.length = rows.length; size_t counter;
	auto borders = arrayLimits(rowFrom, rowTo, rows); auto rowStart = borders[0]; auto rowEnd = borders[1];
	foreach(i; rowStart..rowEnd) if (auto row = rows[i]) { if (col < row.length) { result[counter] = row[col]; counter++; }}
	result.length = counter;
	return result;
}
auto rowsColToCells(T)(DataRow!(T)[] rows, size_t col, size_t[] rowsIndex) { 
	T[] result; result.length = rows.length; size_t counter;
	foreach(index; rowIndex) if (index < rows.length) if (auto row = rows[index]) { if (col < row.length) { result[counter] = row[col]; counter++; }}
	result.length = counter;
	return result;
}

auto toValues(T)(DataRow!(T)[] rows, size_t col) { return toValues(rows, col, 0, rows.length); }
auto toValues(T)(DataRow!(T)[] rows, size_t col, size_t rowFrom, size_t rowTo) { 
	T[] result; result.length = rows.length; size_t counter;
	auto borders = arrayLimits(rowFrom, rowTo, rows); auto rowStart = borders[0]; auto rowEnd = borders[1];
	foreach(i; rowStart..rowEnd) if (auto row = rows[i]) { if (col < row.length) { result[counter] = row[col]; counter++; }}
	result.length = counter;
	return result;
}
auto toValues(T)(DataRow!(T)[] rows, size_t col, size_t[] rowsIndex) { 
	T[] result; result.length = rows.length; size_t counter;
	foreach(index; rowIndex) if (index < rows.length) if (auto row = rows[index]) { if (col < row.length) { result[counter] = row[col]; counter++; }}
	result.length = counter;
	return result;
}

unittest {
	import std.stdio;
	writeln("---- START Test rows int");
	
	auto iRows = newRows!int(10, 10, 1);
	foreach(i; 0..10) { foreach(j; 0..10) iRows[i][j] = i*10+j; iRows[i][9] = 2; }
	foreach(i; 0..10) writeln(iRows[i]); writeln;
	
	writeln("add(iRows(0))=>", uim.data.rows.add(iRows, 0));
	writeln("sub(iRows(0))=>", uim.data.rows.sub(iRows, 0));
	writeln("mul(iRows(0))=>", uim.data.rows.mul(iRows, 0));
	writeln("div(iRows(0))=>", uim.data.rows.div(iRows, 0));
	
	writeln("min(iRows(0))=>", uim.data.rows.min(iRows, 0));
	writeln("max(iRows(0))=>", uim.data.rows.max(iRows, 0));
	writeln("sum(iRows(0))=>", uim.data.rows.sum(iRows, 0));
	writeln("avg(iRows(0))=>", uim.data.rows.avg(iRows, 0));
	writeln("geo(iRows(0))=>", uim.data.rows.geo(iRows, 0));
	
	writeln("deltamin(iRows(0))=>", uim.data.rows.deltamin(iRows, 0));
	writeln("deltamax(iRows(0))=>", uim.data.rows.deltamax(iRows, 0));
	writeln("deltasum(iRows(0))=>", uim.data.rows.deltasum(iRows, 0));
	writeln("deltaavg(iRows(0))=>", uim.data.rows.deltaavg(iRows, 0));
	writeln("deltageo(iRows(0))=>", uim.data.rows.deltageo(iRows, 0));
	
	writeln("incmin(iRows(0))=>", uim.data.rows.incmin(iRows, 0));
	writeln("incmax(iRows(0))=>", uim.data.rows.incmax(iRows, 0));
	writeln("incsum(iRows(0))=>", uim.data.rows.incsum(iRows, 0));
	writeln("incavg(iRows(0))=>", uim.data.rows.incavg(iRows, 0));
	writeln("incgeo(iRows(0))=>", uim.data.rows.incgeo(iRows, 0));
	
	writeln("decmin(iRows(0))=>", uim.data.rows.decmin(iRows, 0));
	writeln("decmax(iRows(0))=>", uim.data.rows.decmax(iRows, 0));
	writeln("decsum(iRows(0))=>", uim.data.rows.decsum(iRows, 0));
	writeln("decavg(iRows(0))=>", uim.data.rows.decavg(iRows, 0));
	writeln("decgeo(iRows(0))=>", uim.data.rows.decgeo(iRows, 0));
	
	writeln("vltmin(iRows(0))=>", uim.data.rows.vltmin(iRows, 0));
	writeln("vltmax(iRows(0))=>", uim.data.rows.vltmax(iRows, 0));
	writeln("vltsum(iRows(0))=>", uim.data.rows.vltsum(iRows, 0));
	writeln("vltavg(iRows(0))=>", uim.data.rows.vltavg(iRows, 0));
	writeln("vltgeo(iRows(0))=>", uim.data.rows.vltgeo(iRows, 0));
	
	writeln("difmin(iRows(0))=>", uim.data.rows.difmin(iRows, 0, 1));
	writeln("difmax(iRows(0))=>", uim.data.rows.difmax(iRows, 0, 1));
	writeln("difsum(iRows(0))=>", uim.data.rows.difsum(iRows, 0, 1));
	writeln("difavg(iRows(0))=>", uim.data.rows.difavg(iRows, 0, 1));
	writeln("difgeo(iRows(0))=>", uim.data.rows.difgeo(iRows, 0, 1));
	
	writeln("difmin(iRows(0, 2))=>", uim.data.rows.difmin(iRows, 0, 2));
	writeln("difmax(iRows(0, 2))=>", uim.data.rows.difmax(iRows, 0, 2));
	writeln("difsum(iRows(0, 2))=>", uim.data.rows.difsum(iRows, 0, 2));
	writeln("difavg(iRows(0, 2))=>", uim.data.rows.difavg(iRows, 0, 2));
	writeln("difgeo(iRows(0, 2))=>", uim.data.rows.difgeo(iRows, 0, 2));
	
	writeln("---- START Test rows double");
	
	auto dRows = newRows!double(10, 10, 1);
	foreach(i; 0..10) { foreach(j; 0..10) dRows[i][j] = i*10+j+1.1; dRows[i][9] = 2; }
	foreach(i; 0..10) writeln(dRows[i]); writeln;
	
	writeln("add(dRows(0))=>", uim.data.rows.add(dRows, 0));
	writeln("sub(dRows(0))=>", uim.data.rows.sub(dRows, 0));
	writeln("mul(dRows(0))=>", uim.data.rows.mul(dRows, 0));
	writeln("div(dRows(0))=>", uim.data.rows.div(dRows, 0));
	
	writeln("min(dRows(0))=>", uim.data.rows.min(dRows, 0));
	writeln("max(dRows(0))=>", uim.data.rows.max(dRows, 0));
	writeln("sum(dRows(0))=>", uim.data.rows.sum(dRows, 0));
	writeln("avg(dRows(0))=>", uim.data.rows.avg(dRows, 0));
	writeln("geo(dRows(0))=>", uim.data.rows.geo(dRows, 0));
	
	writeln("deltamin(dRows(0))=>", uim.data.rows.deltamin(dRows, 0));
	writeln("deltamax(dRows(0))=>", uim.data.rows.deltamax(dRows, 0));
	writeln("deltasum(dRows(0))=>", uim.data.rows.deltasum(dRows, 0));
	writeln("deltaavg(dRows(0))=>", uim.data.rows.deltaavg(dRows, 0));
	writeln("deltageo(dRows(0))=>", uim.data.rows.deltageo(dRows, 0));
	
	writeln("incmin(dRows(0))=>", uim.data.rows.incmin(dRows, 0));
	writeln("incmax(dRows(0))=>", uim.data.rows.incmax(dRows, 0));
	writeln("incsum(dRows(0))=>", uim.data.rows.incsum(dRows, 0));
	writeln("incavg(dRows(0))=>", uim.data.rows.incavg(dRows, 0));
	writeln("incgeo(dRows(0))=>", uim.data.rows.incgeo(dRows, 0));
	
	writeln("decmin(dRows(0))=>", uim.data.rows.decmin(dRows, 0));
	writeln("decmax(dRows(0))=>", uim.data.rows.decmax(dRows, 0));
	writeln("decsum(dRows(0))=>", uim.data.rows.decsum(dRows, 0));
	writeln("decavg(dRows(0))=>", uim.data.rows.decavg(dRows, 0));
	writeln("decgeo(dRows(0))=>", uim.data.rows.decgeo(dRows, 0));
	
	writeln("vltmin(dRows(0))=>", uim.data.rows.vltmin(dRows, 0));
	writeln("vltmax(dRows(0))=>", uim.data.rows.vltmax(dRows, 0));
	writeln("vltsum(dRows(0))=>", uim.data.rows.vltsum(dRows, 0));
	writeln("vltavg(dRows(0))=>", uim.data.rows.vltavg(dRows, 0));
	writeln("vltgeo(dRows(0))=>", uim.data.rows.vltgeo(dRows, 0));
	
	writeln("difmin(dRows(0))=>", uim.data.rows.difmin(dRows, 0, 1));
	writeln("difmax(dRows(0))=>", uim.data.rows.difmax(dRows, 0, 1));
	writeln("difsum(dRows(0))=>", uim.data.rows.difsum(dRows, 0, 1));
	writeln("difavg(dRows(0))=>", uim.data.rows.difavg(dRows, 0, 1));
	writeln("difgeo(dRows(0))=>", uim.data.rows.difgeo(dRows, 0, 1));
	
	writeln("difmin(dRows(0, 2))=>", uim.data.rows.difmin(dRows, 0, 2));
	writeln("difmax(dRows(0, 2))=>", uim.data.rows.difmax(dRows, 0, 2));
	writeln("difsum(dRows(0, 2))=>", uim.data.rows.difsum(dRows, 0, 2));
	writeln("difavg(dRows(0, 2))=>", uim.data.rows.difavg(dRows, 0, 2));
	writeln("difgeo(dRows(0, 2))=>", uim.data.rows.difgeo(dRows, 0, 2));

}