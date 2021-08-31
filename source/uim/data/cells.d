module uim.data.cells;

@safe:
import std.math;
import std.array;
import uim.data;
import core.stdc.math;

T[] collectCells(T)(T[] cells, size_t[] cols) {
	// writeln("collectCells(T)(T[] cells, size_t[] cols)");
	T[] results; results.length = cols.length; size_t counter;
	foreach(col; cols) if (col < cells.length) { results[counter] = cells[col]; counter++; }
	results.length = counter;
	return results;
}

template Switch(string Func) {
	const char[] Switch = `
			switch(cellEnd-cellStart) {
				case 0: return defaultResult;
				case 1: return cells[cellStart];
				default: 
					T result = cells[cellStart]; 
					foreach(cell; cells[cellStart+1..cellEnd]) `~Func~`; 
					return result; 
			}`;
}
template CellsAggFunc(string aggName) {
	const char[] CellsAggFunc = `
    auto `~aggName~`(T)(T[] cells, size_t target, T defaultResult = 0) if (isNumeric!T) { 
		return `~aggName~`(cells, target, 0, cells.length, defaultResult); 
	}
    auto `~aggName~`(T)(T[] cells, size_t target, size_t cellFrom, size_t cellTo, T defaultResult = 0)  if (isNumeric!T) { 
		if (target < cells.length) cells[target] = `~aggName~`(cells, cellFrom, cellTo, defaultResult); 
		return cells; 
	}
	auto `~aggName~`(T)(T[] cells, size_t target, size_t[] cols, T defaultResult = 0)  if (isNumeric!T) { 
		if (target < cells.length) cells[target] = `~aggName~`(cells, cols, defaultResult); 
		return cells; 
	}
	
	T `~aggName~`(T)(T[] cells, size_t[] cols, T defaultResult = 0) { return `~aggName~`(collectCells(cells, cols), defaultResult); }  
	T `~aggName~`(T)(T[] cells, T defaultResult = 0) { return `~aggName~`(cells, 0, cells.length, defaultResult); }
`;
}

template CellsAggFunc(string left, string right) {
	const char[] CellsAggFunc = `
auto `~left~right~`(T)(T[] cells, size_t target, T defaultResult = 0) if (isNumeric!T) { 
	`~left~right~`(cells, target, 0, cells.length, defaultResult); 
	return cells; 
}
auto `~left~right~`(T)(T[] cells, size_t target, size_t cellFrom, size_t cellTo, T defaultResult = 0)  if (isNumeric!T) { 
	if (target < cells.length) cells[target] = `~left~right~`(cells, cellFrom, cellTo, defaultResult); 
	return cells; 
}
auto `~left~right~`(T)(T[] cells, size_t target, size_t[] cols, T defaultResult = 0) if (isNumeric!T) { 
	if (target < cells.length) cells[target] = `~left~right~`(cells, cols, defaultResult); 
	return cells; 
}

T `~left~right~`(T)(T[] cells, size_t[] cols, T defaultResult = 0) {
	debug writeln("T `~left~right~`(T)(T[] cells, cols = ",cols,", T defaultResult = 0)");
	if (!cells) return defaultResult;
	
	T[] results = collectCells(cells, cols);
	debug writeln(results);
	return `~left~right~`(results, 0, results.length, defaultResult); 
}  
T `~left~right~`(T)(T[] cells, T defaultResult = 0) {
	if (!cells) return defaultResult;
	return `~left~right~`(cells, 0, cells.length, defaultResult); 
}
T `~left~right~`(T)(T[] cells, size_t cellFrom, size_t cellTo, T defaultResult = 0) {
	debug writeln("`~left~right~`(T)(T[] cells, size_t cellFrom, size_t cellTo, T defaultResult = 0)");
	if (!cells) return defaultResult;
	
	auto borders = arrayLimits(cellFrom, cellTo, cells); auto cellStart = borders[0]; auto cellEnd = borders[1];
	switch(cellEnd-cellStart) {
		case 0: return defaultResult;
		case 1: return cells[cellStart];
		default: 
			T[] result; result.length = cells.length; size_t counter;
			foreach(i; cellStart..cellEnd-1) { result[counter] = cell`~left~`(cells[i], cells[i+1]); counter++; } 
			result.length = counter;
			return `~right~`(result, defaultResult); 
	}
}`;
}
template CellsDifFunc(string aggName) {
	const char[] CellsDifFunc = `
    auto `~aggName~`(T)(T[] cells, size_t target, int distance, T defaultResult = 0) if (isNumeric!T) { 
		if (target < cells.length) cells[target] = `~aggName~`(cells, 0, cells.length, distance, defaultResult); return cells; 
	}
    auto `~aggName~`(T)(T[] cells, size_t target, size_t cellFrom, size_t cellTo, int distance, T defaultResult = 0)  if (isNumeric!T) { 
		if (target < cells.length) cells[target] = `~aggName~`(cells, cellFrom, cellTo, distance, defaultResult); return cells; 
	}
	auto `~aggName~`(T)(T[] cells, size_t target, size_t[] cols, int distance, T defaultResult = 0)  if (isNumeric!T) { 
		if (target < cells.length) cells[target] = `~aggName~`(cells, cols, distance, defaultResult); return cells; 
	}
	
	T `~aggName~`(T)(T[] cells, size_t[] cols, int distance, T defaultResult = 0) {
		T[] results; results.length = cols.length; size_t counter;
		foreach(col; cols) if (col < cells.length) { results[counter] = cells[col]; counter++; }
		results.length = counter;
		return `~aggName~`(results, distance, defaultResult); 
	}  
	T `~aggName~`(T)(T[] cells, int distance, T defaultResult = 0) { 
		return `~aggName~`(cells, 0, cells.length, distance, defaultResult); 
	}
`;
}
T[] copy(T)(T[] cells) {
	T[] result;
	result.length = cells.length;
	foreach(i, c; cells) result[i] = c;
	return result;
}
auto copyTo(T)(T[] cells, T[] targetcells) { foreach(i, cell; cells) originCells[i] = cells[i]; return this; }
auto copyTo(T)(T[] cells, T[] targetcells, size_t[] cols) { foreach(col; cols) if (col < length) originCells[col] = cells[col]; return this; }

auto newCells(T)(size_t length, T value) {
	T[] result; result.length = length;
	result[] = value;
	return result;
} 
auto fill(T)(T[] cells, T value) { foreach(i, cell; cells) cells[i] = value; return cells; }
auto fill(T)(T[] cells, T value, size_t[] cols) { foreach(col; cols) if (col < cells.length) cells[col] = value; return cells; }
auto fill(T)(T[] cells, T value, size_t cellFrom, size_t cellTo) { 
	mixin(Borders!("cell", "cells"));
	foreach(i; cellStart..cellEnd) cells[i] = value; return cells; }

S[] opCast(S, T)(T[] cells) {
	S[] result; result.length = cells.length;
	foreach(i, c; cells) result[i] = cast(S)c;
	return result; }

alias celladd = uim.data.cell.add;
mixin(CellsAggFunc!"add");
T add(T)(T[] cells, size_t cellFrom, size_t cellTo, T defaultResult = 0) { 
	if (!cells) return defaultResult;
	mixin(Borders!("cell", "cells"));
	switch(cellEnd-cellStart) {
		case 0: return defaultResult;
		case 1: return cells[cellStart];
		default: 
			T result = cells[cellStart];
			foreach(i; cellStart+1..cellEnd) result += cells[i]; 
			return result; 
	}
}

alias cellsub = uim.data.cell.sub;
mixin(CellsAggFunc!"sub");
T sub(T)(T[] cells, size_t cellFrom, size_t cellTo, T defaultResult = 0) { 
	if (!cells) return defaultResult;
	mixin(Borders!("cell", "cells"));
	switch(cellEnd-cellStart) {
		case 0: return defaultResult;
		case 1: return cells[cellStart];
		default: 
			T result = cells[cellStart]; 
			foreach(cell; cells[cellStart+1..cellEnd]) result -= cell; 
			return result; 
	}
}

alias cellmul = uim.data.cell.mul;
mixin(CellsAggFunc!"mul");
T mul(T)(T[] cells, size_t cellFrom, size_t cellTo, T defaultResult = 0) { 
	if (!cells) return defaultResult;
	mixin(Borders!("cell", "cells"));
	switch(cellEnd-cellStart) {
		case 0: return defaultResult;
		case 1: return cells[cellStart];
		default: 
			T result = cells[cellStart]; 
			foreach(cell; cells[cellStart+1..cellEnd]) result *= cell; 
			return result; 
	}
}
alias celldiv = uim.data.cell.div;
mixin(CellsAggFunc!"div");
T div(T)(T[] cells, size_t cellFrom, size_t cellTo, T defaultResult = 0) { 
	if (!cells) return defaultResult;
	mixin(Borders!("cell", "cells"));
	switch(cellEnd-cellStart) {
		case 0: return defaultResult;
		case 1: return cells[cellStart];
		default: 
			T result = cells[cellStart]; 
			foreach(cell; cells[cellStart+1..cellEnd]) if (cell != 0) result /= cell;
			return result;
	}
}

alias cellmin = uim.data.cell.min;
mixin(CellsAggFunc!"min");
T min(T)(T[] cells, size_t cellFrom, size_t cellTo, T defaultResult = 0) {
	if (!cells) return defaultResult;
	mixin(Borders!("cell", "cells"));
	switch(cellEnd-cellStart) {
		case 0: return defaultResult;
		case 1: return cells[cellStart];
		default: 
			T result = cells[cellStart];
			foreach(cell; cells[cellStart+1..cellEnd]) if (result > cell) result = cell;
			return result; 
	}
}

alias cellmax = uim.data.cell.max;
mixin(CellsAggFunc!"max");
T max(T)(T[] cells, size_t cellFrom, size_t cellTo, T defaultResult = 0) {
	if (!cells) return defaultResult;
	mixin(Borders!("cell", "cells"));
	switch(cellEnd-cellStart) {
		case 0: return defaultResult;
		case 1: return cells[cellStart];
		default: 
			T result = cells[cellStart];
			foreach(cell; cells[cellStart+1..cellEnd]) if (result < cell) result = cell;
			return result; 
	}
}

alias cellsum = uim.data.cell.sum;
mixin(CellsAggFunc!"sum");
T sum(T)(T[] cells, size_t cellFrom, size_t cellTo, T defaultResult = 0) {
	if (!cells) return defaultResult;
	mixin(Borders!("cell", "cells"));
	mixin(Switch!("result += cell"));
}

mixin(CellsAggFunc!"pos");
T pos(T)(T[] cells, size_t cellFrom, size_t cellTo, T defaultResult = 0) {
	if (!cells) return defaultResult;
	mixin(Borders!("cell", "cells"));
	mixin(Switch!("result += (cell > 0) ? 1 : 0"));
}

mixin(CellsAggFunc!"neg");
T neg(T)(T[] cells, size_t cellFrom, size_t cellTo, T defaultResult = 0) {
	if (!cells) return defaultResult;
	mixin(Borders!("cell", "cells"));
	mixin(Switch!("result += (cell < 0) ? 1 : 0"));
}

alias cellavg = uim.data.cell.avg;
mixin(CellsAggFunc!"avg");
T avg(T)(T[] cells, size_t cellFrom, size_t cellTo, T defaultResult = 0) { 
	if (!cells) return defaultResult;
	mixin(Borders!("cell", "cells"));
	switch(cellEnd-cellStart) {
		case 0: return defaultResult;
		case 1: return cells[cellStart];
		default: 
			T result = cells[cellStart]; 
			foreach(cell; cells[cellStart+1..cellEnd]) result += cell;
			return cast(T)(result/cast(T)(cellEnd-cellStart));
	}
}

alias cellgeo = uim.data.cell.geo;
mixin(CellsAggFunc!"geo");
T geo(T)(T[] cells, size_t cellFrom, size_t cellTo, T defaultResult = 0) {
	if (!cells) return defaultResult;
	mixin(Borders!("cell", "cells"));
	switch(cellEnd-cellStart) {
		case 0: return defaultResult;
		case 1: return cells[cellStart];
		default: 
			double result = cells[cellStart];
			foreach(cell; cells[cellStart+1..cellEnd]) result *= cell; 
		return cast(T)core.stdc.math.pow(abs(result), 1.0/cells.length); }
}

alias celldelta = uim.data.cell.delta;
mixin(CellsAggFunc!("delta", "sum"));
mixin(CellsAggFunc!("delta", "avg"));
mixin(CellsAggFunc!("delta", "geo"));
mixin(CellsAggFunc!("delta", "min"));
mixin(CellsAggFunc!("delta", "max"));

alias cellinc = uim.data.cell.inc;
mixin(CellsAggFunc!("inc", "sum"));
mixin(CellsAggFunc!("inc", "avg"));
mixin(CellsAggFunc!("inc", "geo"));
mixin(CellsAggFunc!("inc", "min"));
mixin(CellsAggFunc!("inc", "max"));

alias celldec = uim.data.cell.dec;
mixin(CellsAggFunc!("dec", "sum"));
mixin(CellsAggFunc!("dec", "avg"));
mixin(CellsAggFunc!("dec", "geo"));
mixin(CellsAggFunc!("dec", "min"));
mixin(CellsAggFunc!("dec", "max"));

alias cellvlt = uim.data.cell.vlt;
mixin(CellsAggFunc!("vlt", "sum"));
mixin(CellsAggFunc!("vlt", "avg"));
mixin(CellsAggFunc!("vlt", "geo"));
mixin(CellsAggFunc!("vlt", "min"));
mixin(CellsAggFunc!("vlt", "max"));

alias celldif = uim.data.cell.dif;
mixin(CellsDifFunc!"difsum");
T difsum(T)(T[] cells, size_t cellFrom, size_t cellTo, int distance, T defaultResult = 0) {
	if (!cells) return defaultResult;
	mixin(Borders!("cell", "cells"));
	switch(cellEnd-cellStart) {
		case 0: return defaultResult;
		case 1: return cells[cellStart];
		default: 
			T[] results; results.length = cells.length-1;
			foreach(i; 0..results.length) results[i] = celldif(cells[i], cells[i+1], distance);
			return sum(results, defaultResult); 
	}
}

mixin(CellsDifFunc!"difavg");
T difavg(T)(T[] cells, size_t cellFrom, size_t cellTo, int distance, T defaultResult = 0) {
	if (!cells) return defaultResult;
	mixin(Borders!("cell", "cells"));
	switch(cellEnd-cellStart) {
		case 0: return defaultResult;
		case 1: return cells[cellStart];
		default: 
			T[] results; results.length = cells.length-1;
			foreach(i; 0..results.length) results[i] = celldif(cells[i], cells[i+1], distance);
		return avg(results, defaultResult); }
}

mixin(CellsDifFunc!"difgeo");
T difgeo(T)(T[] cells, size_t cellFrom, size_t cellTo, int distance, T defaultResult = 0) {
	if (!cells) return defaultResult;
	mixin(Borders!("cell", "cells"));
	switch(cellEnd-cellStart) {
		case 0: return defaultResult;
		case 1: return cells[cellStart];
		default: 
			T[] results; results.length = cells.length-1;
			foreach(i; 0..results.length) results[i] = celldif(cells[i], cells[i+1], distance);
		return geo(results, defaultResult); }
}

mixin(CellsDifFunc!"difmin");
T difmin(T)(T[] cells, size_t cellFrom, size_t cellTo, int distance, T defaultResult = 0) {
	if (!cells) return defaultResult;
	mixin(Borders!("cell", "cells"));
	switch(cellEnd-cellStart) {
		case 0: return defaultResult;
		case 1: return cells[cellStart];
		default: 
			T[] results; results.length = cells.length-1;
			foreach(i; 0..results.length) results[i] = celldif(cells[i], cells[i+1], distance);
		return min(results, defaultResult); }
}

mixin(CellsDifFunc!"difmax");
T difmax(T)(T[] cells, size_t cellFrom, size_t cellTo, int distance, T defaultResult = 0) { 
	if (!cells) return defaultResult;
	mixin(Borders!("cell", "cells"));
	switch(cellEnd-cellStart) {
		case 0: return defaultResult;
		case 1: return cells[cellStart];
		default: 
			T[] results; results.length = cells.length-1;
			foreach(i; 0..results.length) results[i] = celldif(cells[i], cells[i+1], distance);
		return max(results, defaultResult); }
}

T[size_t] cellsToAA(T)(T[] cells) {
	T[size_t] result;
	foreach(i, cell; cells) result[i] = cell;
	return result; }
size_t[T] cellsToAARotate(T)(T[] cells) {
	size_t[T] result;
	foreach(i, cell; cells) result[cell] = i;
	return result; }

bool isIn(T)(T value, T[] cells) {
	foreach(cell; cells) if (cell == value) return true;
	return false;
}
bool isNotIn(T)(T value, T[] cells) {
	foreach(cell; cells) if (v == cell) return false;
	return true;
}

unittest {
	import std.stdio;
	writeln("Testing uim.data.cells...");
	
	int[] cells = newCells(10, 1);
	foreach(i; 0..cells.length) cells[i] = cast(int)i; cells[9] = 2;
	writeln(cells);
	
	writeln("add(cells)=>", add(cells));
	writeln("sub(cells)=>", sub(cells));
	writeln("mul(cells)=>", mul(cells));
	writeln("div(cells)=>", div(cells));
	
	writeln("min(cells)=>", min(cells));
	writeln("max(cells)=>", uim.data.cells.max(cells));
	writeln("sum(cells)=>", sum(cells));
	writeln("avg(cells)=>", avg(cells));
	writeln("geo(cells)=>", geo(cells));
	
	writeln("incmin(cells)=>", incmin(cells));
	writeln("incmax(cells)=>", incmax(cells));
	writeln("incsum(cells)=>", incsum(cells));
	writeln("incavg(cells)=>", incavg(cells));
	writeln("incgeo(cells)=>", incgeo(cells));
	
	writeln("decmin(cells)=>", decmin(cells));
	writeln("decmax(cells)=>", decmax(cells));
	writeln("decsum(cells)=>", decsum(cells));
	writeln("decavg(cells)=>", decavg(cells));
	writeln("decgeo(cells)=>", decgeo(cells));
	
	writeln("deltamin(cells)=>", deltamin(cells));
	writeln("deltamax(cells)=>", deltamax(cells));
	writeln("deltasum(cells)=>", deltasum(cells));
	writeln("deltaavg(cells)=>", deltaavg(cells));
	writeln("deltageo(cells)=>", deltageo(cells));
	
	writeln("vltmin(cells)=>", vltmin(cells));
	writeln("vltmax(cells)=>", vltmax(cells));
	writeln("vltsum(cells)=>", vltsum(cells));
	writeln("vltavg(cells)=>", vltavg(cells));
	writeln("vltgeo(cells)=>", vltgeo(cells));
	
	writeln("difmin(cells)=>", difmin(cells,1));
	writeln("difmax(cells)=>", difmax(cells,1));
	writeln("difsum(cells)=>", difsum(cells,1));
	writeln("difavg(cells)=>", difavg(cells,1));
	writeln("difgeo(cells)=>", difgeo(cells,1));
	
	writeln("difmin(cells,2)=>", difmin(cells,2));
	writeln("difmax(cells,2)=>", difmax(cells,2));
	writeln("difsum(cells,2)=>", difsum(cells,2));
	writeln("difavg(cells,2)=>", difavg(cells,2));
	writeln("difgeo(cells,2)=>", difgeo(cells,2));
	
	writeln("---- START Test cells...double");
	
	double[] dCells = newCells(10, 1.1);
	writeln(dCells);
	foreach(i; 0..dCells.length) dCells[i] = i+0.1; dCells[9] = 2.0;
	writeln(dCells);
	writeln("add(dCells)=>", add(dCells));
	writeln("sub(dCells)=>", sub(dCells));
	writeln("mul(dCells)=>", mul(dCells));
	writeln("div(dCells)=>", div(dCells));
	
	writeln("min(dCells)=>", min(dCells));
	writeln("max(dCells)=>", max(dCells));
	writeln("sum(dCells)=>", sum(dCells));
	writeln("avg(dCells)=>", avg(dCells));
	
	writeln("incmin(dCells)=>", incmin(dCells));
	writeln("incmax(dCells)=>", incmax(dCells));
	writeln("incsum(dCells)=>", incsum(dCells));
	writeln("incavg(dCells)=>", incavg(dCells));
	writeln("incgeo(dCells)=>", incgeo(dCells));
	
	writeln("decmin(dCells)=>", decmin(dCells));
	writeln("decmax(dCells)=>", decmax(dCells));
	writeln("decsum(dCells)=>", decsum(dCells));
	writeln("decavg(dCells)=>", decavg(dCells));
	writeln("decgeo(dCells)=>", decgeo(dCells));
	
	writeln("deltamin(dCells)=>", deltamin(dCells));
	writeln("deltamax(dCells)=>", deltamax(dCells));
	writeln("deltasum(dCells)=>", deltasum(dCells));
	writeln("deltaavg(dCells)=>", deltaavg(dCells));
	writeln("deltageo(dCells)=>", deltageo(dCells));
	
	writeln("vltmin(dCells)=>", vltmin(dCells));
	writeln("vltmax(dCells)=>", vltmax(dCells));
	writeln("vltsum(dCells)=>", vltsum(dCells));
	writeln("vltavg(dCells)=>", vltavg(dCells));
	writeln("vltgeo(dCells)=>", vltgeo(dCells));
	
	writeln("difmin(dCells)=>", difmin(dCells,1));
	writeln("difmax(dCells)=>", difmax(dCells,1));
	writeln("difsum(dCells)=>", difsum(dCells,1));
	writeln("difavg(dCells)=>", difavg(dCells,1));
	writeln("difgeo(dCells)=>", difgeo(dCells,1));
	
	writeln("difmin(dCells,2)=>", difmin(dCells,2));
	writeln("difmax(dCells,2)=>", difmax(dCells,2));
	writeln("difsum(dCells,2)=>", difsum(dCells,2));
	writeln("difavg(dCells,2)=>", difavg(dCells,2));
	writeln("difgeo(dCells,2)=>", difgeo(dCells,2));
}