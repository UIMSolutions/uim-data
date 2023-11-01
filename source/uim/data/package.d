module uim.data;


public import std.stdio;
public import std.string;
public import std.conv;
public import std.traits;
public import std.math;
public import std.array;

// UIM libraries 
public import uim.core;
public import uim.oop;

// uim-data packages or modules 
public import uim.data.cell;
public import uim.data.cells;
public import uim.data.row;
public import uim.data.column;
public import uim.data.rows;
public import uim.data.table;
public import uim.data.matrix;
public import uim.data.splice;

@safe:

alias BASE = double;
alias NORM = int;

enum Ops {
	GTV, // greater than value
	EQV, // equal to value
	LTV, // less than value
	GEV, // greater equal value
	LEV, // less equal value
	EQC, // equal to column
	GTC, // greater than column
	LTC, // less than column
	GEC, // greater equal column
	LEC // less equal column
}

enum Relations {
	NN, // unknown
	GT, // greater than value
	EQ, // equal to value
	NEQ, // equal to value
	LT, // less than value
	GE, // greater equal value
	LE // less equal value
}

template MinMax(T) {
	static if (isFloatingPoint!T) {
		T maxValue = T.max;
		T minValue = -T.max;
	}
	else {
		T maxValue = T.max;
		T minValue = T.min;
	}
}

template Borders(string itemName, string arrayName) {
	const char[] Borders = `auto borders = arrayLimits(`~itemName~`From, `~itemName~`To, `~arrayName~`); auto `~itemName~`Start = borders[0]; auto `~itemName~`End = borders[1];`;
}
template StrMinMax(T:T) {
	const char[] StrMinMax= `
	static if (isFloatingPoint!T) {
		T maxValue = T.max;
		T minValue = -T.max;
	}
	else {
		T maxValue = T.max;
		T minValue = T.min;
	}`;
}

bool inside(T)(size_t col, T[] row) {
	if (col > row.length-1) return false;
	return true;
}
void set(T, S)(T[] row, size_t col, S value) {
	if (col > row.length-1) return;
	row[col] = checkFor!T(value);
}

void set(T, S)(T[][] rows, size_t index, size_t col, S value) {
	if (!isIn(index, rows)) return;
	rows[index].set(col, value);
}
void set(T, S, G)(T[][G] rows, G group, size_t col, S value) {
	if (group !in rows) return;
	rows[group].set(col, value);
}

void set(T, S, G, C)(T[][G][C] rows, C category, G group, size_t col, S value) {
	if (category !in rows) return;
	rows[category].set(group, col, value);
}

size_t[] names2Index(string[] names, size_t[string] nameIndex) { 
	size_t[] index; 
	foreach(name; names) if (name in nameIndex) index ~= nameIndex[name]; 
	return index; 
}

unittest {
	import std.stdio;

	auto dTable = new DataTable!double(10, 10); dTable.fill(1.1);
	foreach(i; 0..10) writeln(dTable[i]); writeln;
	writeln; writeln("col Tests");
	auto col = new DataColumn!double(dTable, 3);
/* 	writeln(col);
	writeln(col.toValues);
 */	col[3] = 100;
	col[4] = 100;
	col[5] = 100;
/* 	writeln(col.toValues);
	foreach(i; 0..10) writeln(dTable[i]); writeln;
 */	
/* 	writeln("col.min\t", col.min);
	writeln("tab.min\t", dTable.min(3));
	writeln("col.max\t", col.max);
	writeln("tab.max\t", dTable.max(3));
 */	
	// col = 666;
	dTable.rows[4] = null; col._cells[4] = null;
	dTable.rows[5] = null; col._cells[5] = null;
/* 	foreach(i; 0..10) writeln(dTable[i]); writeln;
	
	writeln("col.sum\t", col.sum);
	writeln("tab.sum\t", dTable.sum(3));
	writeln("col.avg\t", col.avg);
	writeln("tab.avg\t", dTable.avg(3));
	writeln("col.min\t", col.min);
	writeln("tab.min\t", dTable.min(3));
	writeln("col.max\t", col.max);
	writeln("tab.max\t", dTable.max(3));
	writeln("----top");	
	writeln("col.sum\t", col.sum(0, 3));
	writeln("tab.sum\t", dTable.sum(3, 0, 3));
	writeln("col.avg\t", col.avg(0, 3));
	writeln("tab.avg\t", dTable.avg(3, 0, 3));
	writeln("col.min\t", col.min(0, 3));
	writeln("tab.min\t", dTable.min(3, 0, 3));
	writeln("col.max\t", col.max(0, 3));
	writeln("tab.max\t", dTable.max(3, 0, 3));
	writeln("----bot");
	writeln("col.sum\t", col.sum(8, 11));
	writeln("tab.sum\t", dTable.sum(3, 8, 11));
	writeln("col.avg\t", col.avg(8, 11));
	writeln("tab.avg\t", dTable.avg(3, 8, 11));
	writeln("col.min\t", col.min(8, 11));
	writeln("tab.min\t", dTable.min(3, 8, 11));
	writeln("col.max\t", col.max(8, 11));
	writeln("tab.max\t", dTable.max(3, 8, 11));
 */	
	//readln;
	
/* 	writeln("\f---- START Test matrix int");
	auto iMatrix = new DataMatrix!int(10, 15, 0); 
	writeln(iMatrix);
	foreach(i; 0..10) iMatrix[i] = i;
	writeln(iMatrix);
	foreach(i; 0..10) foreach(j; 0..10) iMatrix[i, j] = 10*i+j;
	writeln(iMatrix);
	writeln("row(3) = ", iMatrix.row(3));
	writeln("col(3) = ", iMatrix.col(3));
	writeln("rows(3,4) = ", iMatrix.rows(3, 4));
	writeln("cols(3,4) = ", iMatrix.cols(3, 4));
	writeln("sumRow(0) = ", iMatrix.sumRow(0));
	writeln("sumRow(0, [2, 3, 4]) = ", iMatrix.sumRow(0, [2, 3, 4]));
	writeln("sumRow(3) = ", iMatrix.sumRow(3));
	writeln("sumRow(3, [2, 3, 4]) = ", iMatrix.sumRow(3, [2, 3, 4]));
	writeln("maxRow(3) = ", iMatrix.maxRow(3));
	writeln("maxRow(3, [2, 3, 4]) = ", iMatrix.maxRow(3, [2, 3, 4]));
	writeln("maxCol(3) = ", iMatrix.maxCol(3));
	writeln("maxCol(3, [2, 3, 4]) = ", iMatrix.maxCol(3, [2, 3, 4]));
	readln;
	
	writeln("\f---- START Test splice int");
	auto iSplice = new DataSplice!int(10, 10); 
	writeln(iSplice);
	foreach(i; 0..10) iSplice[i] = i;
	writeln(iSplice);
	foreach(i; 0..10) foreach(j; 0..10) iSplice[i, j] = 10*i+j;
	writeln(iSplice);
	writeln("row(3) = ", iSplice.row(3));
	writeln("col(3) = ", iSplice.col(3));
	writeln("rows(3,4) = ", iSplice.rows(3, 4));
	writeln("cols(3,4) = ", iSplice.cols(3, 4));
	writeln("sumRow(0) = ", iSplice.sumRow(0));
	writeln("sumRow(0, [2, 3, 4]) = ", iSplice.sumRow(0, [2, 3, 4]));
	writeln("sumRow(3) = ", iSplice.sumRow(3));
	writeln("sumRow(3, [2, 3, 4]) = ", iSplice.sumRow(3, [2, 3, 4]));
	writeln("maxRow(3) = ", iSplice.maxRow(3));
	writeln("maxRow(3, [2, 3, 4]) = ", iSplice.maxRow(3, [2, 3, 4]));
	writeln("maxCol(3) = ", iSplice.maxCol(3));
	writeln("maxCol(3, [2, 3, 4]) = ", iSplice.maxCol(3, [2, 3, 4]));
 */}

@safe pure T[size_t] indexAAReverse(T)(T[] values, size_t startPos = 0) {
	T[size_t] results;
	foreach(i, value; values) results[i + startPos] = value;
	return results;
}
unittest {
	//
}
