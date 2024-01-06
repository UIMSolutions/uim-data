/***********************************************************************************
*	Copyright: ©2015-2023 Ozan Nurettin Süel (sicherheitsschmiede)                   *
*	License  : Licensed under Apache 2 [https://apache.org/licenses/LICENSE-2.0.txt] *
*	Author   : Ozan Nurettin Süel (Sicherheitsschmiede)										           * 
***********************************************************************************/
module uim.data.classes.splice;

import uim.data;

template AggRowColSplice(string name) {
	const char[] AggRowColSplice = `
T `~name~`Row(size_t posY, T defaultValue = 0) { return uim.data.classes.cells.`~name~`(row(posY), defaultValue); }
T `~name~`Row(size_t posY, size_t[] posX, T defaultValue = 0) { return uim.data.classes.cells.`~name~`(row(posY), posX, defaultValue); }
T `~name~`Row(size_t posY, size_t startX, size_t endX, T defaultValue = 0) { return uim.data.classes.cells.`~name~`(row(posY), startX, endX, defaultValue); }

T `~name~`Rows(size_t[] posY, T defaultValue = 0) { T[] result; foreach(y; posY) result ~= uim.data.classes.cells.`~name~`(row(y), defaultValue); return uim.data.classes.cells.`~name~`(result, defaultValue); }
T `~name~`Rows(size_t[] posY, size_t[] posX, T defaultValue = 0) { T[] result; foreach(y; posY) result ~= uim.data.classes.cells.`~name~`(row(y), posX, defaultValue); return uim.data.classes.cells.`~name~`(result, defaultValue); }
T `~name~`Rows(size_t[] posY, size_t startX, size_t endX, T defaultValue = 0) { T[] result; foreach(y; posY) result ~= uim.data.classes.cells.`~name~`(row(y), startX, endX, defaultValue); return uim.data.classes.cells.`~name~`(result, defaultValue); }

T `~name~`Col(size_t posX, T defaultValue = 0) { return uim.data.classes.cells.`~name~`(col(posX), defaultValue); }
T `~name~`Col(size_t posX, size_t[] posY, T defaultValue = 0) { return uim.data.classes.cells.`~name~`(col(posX), posY, defaultValue); }
T `~name~`Col(size_t posX, size_t startY, size_t endY, T defaultValue = 0) { return uim.data.classes.cells.`~name~`(col(posX), startY, endY, defaultValue); }

T `~name~`Cols(size_t[] posX, T defaultValue = 0) { T[] result; foreach(x; posX) result ~= uim.data.classes.cells.`~name~`(col(x), defaultValue); return uim.data.classes.cells.`~name~`(result, defaultValue); }
T `~name~`Cols(size_t[] posX, size_t[] posY, T defaultValue = 0) { T[] result; foreach(x; posX) result ~= uim.data.classes.cells.`~name~`(col(x), posY, defaultValue); return uim.data.classes.cells.`~name~`(result, defaultValue); }
T `~name~`Cols(size_t[] posX, size_t startY, size_t endY, T defaultValue = 0) { T[] result; foreach(x; posX) result ~= uim.data.classes.cells.`~name~`(col(x), startY, endY, defaultValue); return uim.data.classes.cells.`~name~`(result, defaultValue); }
`;
}

class DataSplice(T) {
	size_t height, width;
	T[] data;
	bool _readOnly = false;
	T defaultValue;
	T[][] _cols;
	T[][] _rows;

	this(size_t aHeight, size_t aWidth) {
		height = aHeight;
		width = aWidth;

		data.length = height*width;
	}
	this(size_t aHeight, size_t aWidth, T aDefaultValue) {
		this(aHeight, aWidth);
		defaultValue = aDefaultValue;
		data[] = defaultValue;
	}
	this(size_t aHeight, size_t aWidth, T aDefaultValue, T[] values) {
		this(aHeight, aWidth, aDefaultValue);
		data[] = values;
		data.length = height*width;
	}
	
	@property void readOnly(bool on) { 
		_readOnly = on; 

		_cols.length = width;
		foreach(i, col; _cols) {
			_cols[i].length = height;
			
			foreach(h; 0..height) _cols[i][h] = this[h, i];
		}

		_rows.length = height;
		foreach(i, row; _rows) {
			_rows[i].length = width;
			
			foreach(w; 0..width) _rows[i][w] = this[i, w];
		}

	}

	@property bool readOnly() { return _readOnly; }
	
	T[] opIndex(size_t posY) { if (posY < height) return data[posY*width..(posY+1)*width]; return null; }
	T[][] opIndex(size_t[2] posY) {
		if ((posY[0] < height) && (posY[1] < height)) {
			T[][] result;
			foreach(y; posY[0]..posY[1]) result ~= this[y];
			return result;
		}
		return null;
	}
	T[][] opIndex(size_t[] posY) {
		T[][] result;
		foreach(y; posY) result ~= this[y];
		return result;
	}
	T opIndex(size_t posY, size_t posX) {
		if ((posY < height) && (posX < width)) return data[posY*width + posX];
		return T.init; }
	T[] opIndex(size_t posY, size_t[2] posX) {
		if ((posY < height) && (posX[0] < width) && (posX[1] < width)) return data[(posY*width + posX[0])..(posY*width + posX[1])];
		return null; }
	T[][] opIndex(size_t[2] posY, size_t[2] posX) {
		if ((posY[0] < height) && (posY[1] < height) && (posX[0] < width) && (posX[1] < width)) {
			T[][] result;
			foreach(y; posY[0]..posY[1]) result ~= this[y, posX];
			return result;
		}
		return null;
	}
	void opIndexAssign(T value) {
		if (readOnly) return;
		if (!readOnly) data[] = value;
	}
	void opIndexAssign(T value, size_t posY) {
		if (readOnly) return;
		if (posY < height) { data[posY*width..(posY+1)*width] = value; }
	}
	void opIndexAssign(T value, size_t[2] pos) {
		if (readOnly) return;
		if (pos[0] < height) {
			if (pos[1] < height) { data[pos[0]*width..pos[1]*width] = value; }
			else  { data[pos[0]*width..$] = value; }
		}
	}
	void opIndexAssign(T value, size_t posY, size_t posX) {
		if (readOnly) return;
		if ((posY < height) && (posX < width)) { data[posY*width + posX] = value; }
	}

	T[] row(size_t posY) {
		if (!(posY < height)) return null;
		
		if (readOnly) return _rows[posY];
		
		return data[posY*width..(posY+1)*width];
	}
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
		string[] result;
		foreach(i; 0..height) {
			result ~= "%s\n".format(data[i*width..(i+1)*width]);
		}
		return result.join();
	}
}
