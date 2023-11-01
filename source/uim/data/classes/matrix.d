module uim.data.classes.matrix;

@safe:
import uim.data;
import std.traits;
import std.string;
import std.container.array;

template AggRowColMatrix(string name) {
	const char[] AggRowColSplice = `
T `~name~`Row(size_t posY, T defaultValue = 0) { return uim.data.cells.`~name~`(row(posY), defaultValue); }
T `~name~`Row(size_t posY, size_t[] posX, T defaultValue = 0) { return uim.data.cells.`~name~`(row(posY), posX, defaultValue); }
T `~name~`Row(size_t posY, size_t startX, size_t endX, T defaultValue = 0) { return uim.data.cells.`~name~`(row(posY), startX, endX, defaultValue); }

T `~name~`Rows(size_t[] posY, T defaultValue = 0) { T[] result; foreach(y; posY) result ~= uim.data.cells.`~name~`(row(y), defaultValue); return uim.data.cells.`~name~`(result, defaultValue); }
T `~name~`Rows(size_t[] posY, size_t[] posX, T defaultValue = 0) { T[] result; foreach(y; posY) result ~= uim.data.cells.`~name~`(row(y), posX, defaultValue); return uim.data.cells.`~name~`(result, defaultValue); }
T `~name~`Rows(size_t[] posY, size_t startX, size_t endX, T defaultValue = 0) { T[] result; foreach(y; posY) result ~= uim.data.cells.`~name~`(row(y), startX, endX, defaultValue); return uim.data.cells.`~name~`(result, defaultValue); }

T `~name~`Col(size_t posX, T defaultValue = 0) { return uim.data.cells.`~name~`(col(posX), defaultValue); }
T `~name~`Col(size_t posX, size_t[] posY, T defaultValue = 0) { return uim.data.cells.`~name~`(col(posX), posY, defaultValue); }
T `~name~`Col(size_t posX, size_t startY, size_t endY, T defaultValue = 0) { return uim.data.cells.`~name~`(col(posX), startY, endY, defaultValue); }

T `~name~`Cols(size_t[] posX, T defaultValue = 0) { T[] result; foreach(x; posX) result ~= uim.data.cells.`~name~`(col(x), defaultValue); return uim.data.cells.`~name~`(result, defaultValue); }
T `~name~`Cols(size_t[] posX, size_t[] posY, T defaultValue = 0) { T[] result; foreach(x; posX) result ~= uim.data.cells.`~name~`(col(x), posY, defaultValue); return uim.data.cells.`~name~`(result, defaultValue); }
T `~name~`Cols(size_t[] posX, size_t startY, size_t endY, T defaultValue = 0) { T[] result; foreach(x; posX) result ~= uim.data.cells.`~name~`(col(x), startY, endY, defaultValue); return uim.data.cells.`~name~`(result, defaultValue); }
`;
}

class DataMatrix(T) {
	size_t height, width;
	bool _readOnly = false;

	T[][] _rows;
	T[][] _cols;

	this(size_t aHeight, size_t aWidth) {
		height = aHeight;
		width = aWidth;

		_rows.length = height;
		foreach(ref row; _rows) { row.length = width; }  
	}
	this(size_t aHeight, size_t aWidth, T defaultValue) {
		this(aHeight, aWidth);
		foreach(ref row; _rows) row[] = defaultValue;
	}

	@property void readOnly(bool on) { 
		_readOnly = on; 
		
		_cols.length = width;
		foreach(i, col; _cols) {
			_cols[i].length = height;
			
			foreach(h; 0..height) _cols[i][h] = this[h, i];
		}
	}
	
	@property bool readOnly() { return _readOnly; }
	T opIndex(size_t posY, size_t posX) {
		if ((posY < height) && (posX < width)) return _rows[posY][posX]; 
		return T.init;  
	}
	T[] opIndex(size_t posY) {
		if (posY < height) return _rows[posY]; 
		return null;  
	}
	T[][] opIndex(size_t[2] posY) {
		if (posY[0] < height) {
			if (posY[1] < height) {
				return _rows[posY[0]..posY[1]];
			}
			else {
				return _rows[posY[0]..$];
			}
		}
		return null;
	}
	T[][] opIndex(size_t[] posY) {
		T[][] result;
		foreach(y; posY) {
			if (auto row = this[y]) result ~= row;
		} 
		return result;
	}

	void opIndexAssign(T value) {
		foreach(ref row; _rows) { row[] = value; }  
	}
	void opIndexAssign(T value, size_t posY) {
		if (posY < height) { _rows[posY][] = value; }  
	}
	void opIndexAssign(T value, size_t[2] pos) {
		if (pos[0] < height) {
			if (pos[1] < height) { foreach(ref row; _rows[pos[0]..pos[1]]) row[] = value; }  
			else  { foreach(ref row; _rows[pos[0]..$]) row[] = value; }  
		}  
	}
	void opIndexAssign(T value, size_t posY, size_t posX) {
		if ((posY < height) && (posX < width)) { _rows[posY][posX] = value; }  
	}

	T[] row(size_t posY) {
		if (posY < height) return _rows[posY];
		return null;
	}
	T[][] rows() { return _rows; }
	T[][] rows(size_t[] posY...) {
		T[][] result;
		foreach(y; posY) if (auto r = this[y]) result ~= r;
		return result;
	}
	T[] col(size_t posX) {
		if (!(posX < width)) return null;
		
		if (readOnly) return _cols[posX];
		
		T[] result; result.length = height;
		foreach(h; 0..height) result[h] = this[h, posX];
		return result;
	}
	T[][] cols(size_t[] posX...) {
		T[][] result; 
		foreach(x; posX) if (auto c = col(x)) result ~= c;
		return result;
	}

	mixin(AggRowColSplice!"sum");
	mixin(AggRowColSplice!"avg");
	mixin(AggRowColSplice!"min");
	mixin(AggRowColSplice!"max");
	
	override string toString() {
		return "%s".format(rows);
	}
}

T[][] selectColCol(T)(T[][] rows, size_t left, Relations relation, size_t right) if (isBasicType!T) {	
	// writeln("selectColCol(T)(T[][] rows, %s, %s, %s)".format(left, relation, right));
	import std.conv;
	T[][] result;  result.length = rows.length;
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
void selectColCol(T)(T[][] rows, size_t left, Relations relation, size_t right, ref T[][] toRows) if (isBasicType!T) {	
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

T[][] selectColVal(T)(T[][] rows, size_t left, Relations relation, T right) if (isBasicType!T) {	
	// writeln("selectColVal(T)(T[][] rows, size_t left, Relations relation, T right)");
	import std.conv;
	T[][] result;  result.length = rows.length;
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
void selectColVal(T)(T[][] rows, size_t left, Relations relation, T right, ref T[][] toRows) if (isBasicType!T) {	
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

T[][] selectValCol(T)(T[][] rows, T left, Relations relation, size_t right) if (isBasicType!T) {	
	// writeln("selectValCol(T)(T[][] rows, T left, Relations relation, size_t right)");
	import std.conv;
	T[][] result;  result.length = rows.length;
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
void selectValCol(T)(T[][] rows, T left, Relations relation, size_t right, ref T[][] toRows) if (isBasicType!T) {	
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

T[][] selectValVal(T)(T[][] rows, T left, Relations relation, T right) if (isBasicType!T) {	
	// writeln("selectValVal(T)(T[][] rows, T left, Relations relation, T right)");
	import std.conv;
	T[][] result;  result.length = rows.length;
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
void selectValVal(T)(T[][] rows, T left, Relations relation, T right, ref T[][] toRows) if (isBasicType!T) {	
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

// ------------
void selectColCol(T)(ref Array!(T[]) outRows, T[][] inRows, size_t left, Relations relation, size_t right) if (isBasicType!T) {	
	outRows.clear;
	switch(relation) {
		case Relations.GT: foreach(row; inRows) { if (row[left] > row[right])  { outRows ~= row;}} break;
		case Relations.GE: foreach(row; inRows) { if (row[left] >= row[right]) { outRows ~= row;}} break;
		case Relations.EQ: foreach(row; inRows) { if (row[left] == row[right])  { outRows ~= row;}} break;
		case Relations.NEQ: foreach(row; inRows) { if (row[left] != row[right])  { outRows ~= row;}} break;
		case Relations.LE: foreach(row; inRows) { if (row[left] <= row[right]) { outRows ~= row;}} break;
		case Relations.LT: foreach(row; inRows) { if (row[left] < row[right])  { outRows ~= row;}} break;
		default: break;
	}
}

void selectColCol2(T)(ref Array!(T[]) outRows, T[][] inRows, T[] left, Relations relation, T[] right) if (isBasicType!T) {	
	outRows.clear;
	switch(relation) {
		case Relations.GT: foreach(i; 0..inRows.length) { if (left[i] > right[i])  { outRows ~= inRows[i];}} break;
		case Relations.GE: foreach(i; 0..inRows.length) { if (left[i] >= right[i]) { outRows ~= inRows[i];}} break;
		case Relations.EQ: foreach(i; 0..inRows.length) { if (left[i] == right[i])  { outRows ~= inRows[i];}} break;
		case Relations.NEQ: foreach(i; 0..inRows.length) { if (left[i] != right[i])  { outRows ~= inRows[i];}} break;
		case Relations.LE: foreach(i; 0..inRows.length) { if (left[i] <= right[i]) { outRows ~= inRows[i];}} break;
		case Relations.LT: foreach(i; 0..inRows.length) { if (left[i] < right[i])  { outRows ~= inRows[i];}} break;
		default: break;
	}
}

void selectColVal(T)(ref Array!(T[]) outRows, T[][] inRows, size_t left, Relations relation, T right) if (isBasicType!T) {	
	outRows.clear;
	switch(relation) {
		case Relations.GT: foreach(row; inRows) { if (row[left] > right)  { outRows ~= row;}} break;
		case Relations.GE: foreach(row; inRows) { if (row[left] >= right) { outRows ~= row;}} break;
		case Relations.NEQ: foreach(row; inRows){ if (row[left] != right)  { outRows ~= row;}} break;
		case Relations.EQ: foreach(row; inRows) { if (row[left] == right)  { outRows ~= row;}} break;
		case Relations.LE: foreach(row; inRows) { if (row[left] <= right) { outRows ~= row;}} break;
		case Relations.LT: foreach(row; inRows) { if (row[left] < right)  { outRows ~= row;}} break;
		default: break;
	}
}

void selectValCol(T)(ref Array!(T[]) outRows, T[][] inRows, T left, Relations relation, size_t right) if (isBasicType!T) {	
	outRows.clear;
	switch(relation) {
		case Relations.GT: foreach(row; inRows) { if (left > row[right])  { outRows ~= row;}} break;
		case Relations.GE: foreach(row; inRows) { if (left >= row[right]) { outRows ~= row;}} break;
		case Relations.EQ: foreach(row; inRows) { if (left == row[right])  { outRows ~= row;}} break;
		case Relations.NEQ: foreach(row; inRows) { if (left != row[right])  { outRows ~= row;}} break;
		case Relations.LE: foreach(row; inRows) { if (left <= row[right]) { outRows ~= row;}} break;
		case Relations.LT: foreach(row; inRows) { if (left < row[right])  { outRows ~= row;}} break;
		default: break;
	}
}

void selectValVal(T)(ref Array!(T[]) outRows, T[][] inRows, T left, Relations relation, T right) if (isBasicType!T) {	
	outRows.clear;
	switch(relation) {
		case Relations.GT: foreach(row; inRows) { if (left > right)  { outRows ~= row;}} break;
		case Relations.GE: foreach(row; inRows) { if (left >= right) { outRows ~= row;}} break;
		case Relations.EQ: foreach(row; inRows) { if (left == right)  { outRows ~= row;}} break;
		case Relations.NEQ: foreach(row; inRows) { if (left != right)  { outRows ~= row;}} break;
		case Relations.LE: foreach(row; inRows) { if (left <= right) { outRows ~= row;}} break;
		case Relations.LT: foreach(row; inRows) { if (left < right)  { outRows ~= row;}} break;
		default: break;
	}
}
