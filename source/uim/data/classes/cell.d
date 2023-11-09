<<<<<<< HEAD
=======
/***********************************************************************************
*	Copyright: ©2015-2023 Ozan Nurettin Süel (sicherheitsschmiede)                   *
*	License  : Licensed under Apache 2 [https://apache.org/licenses/LICENSE-2.0.txt] *
*	Author   : Ozan Nurettin Süel (Sicherheitsschmiede)										           * 
***********************************************************************************/
>>>>>>> ca64a2d (Updates)
module uim.data.classes.cell;

import uim.data;

@safe:
T checkFor(T, S)(S value, T minValue = T.min, T maxValue = T.max) if (isIntegral!S) {
	import std.conv;
	if (value < minValue) return minValue;
	if (value > maxValue) return maxValue;
	return to!T(value);
}
T checkFor(T, S)(S value, T minValue = T.min, T maxValue = T.max) if (isFloatingPoint!S) {
	import std.conv;
	if (value== S.nan) return 0; 
	if (value < minValue) return minValue;
	if (value > maxValue) return maxValue;
	return to!T(value);
}

T min(T)(T left, T right) if (isNumeric!T) { return (left<right) ? left : right; }
T max(T)(T left, T right) if (isNumeric!T) { return (left>right) ? left : right; }
T sum(T)(T left, T right) if (isNumeric!T) { return right+left; }
T avg(T)(T left, T right) if (isNumeric!T) { return (right+left)/2; }
T geo(T)(T left, T right) if (isNumeric!T) { return cast(T)sqrt(cast(double)abs(right * left)); }

T add(T)(T left, T right) if (isNumeric!T) { return (left+right); }
T sub(T)(T left, T right) if (isNumeric!T) { return (left-right); }
T mul(T)(T left, T right) if (isNumeric!T) { return (left*right); }
T div(T)(T left, T right) if (isNumeric!T) { return cast(T)(right != 0) ? (left/right) : 0; }

T vlt(T)(T left, T right) if (isNumeric!T) { return div(right - left, left); }
T inc(T)(T left, T right) if (isNumeric!T) { return cast(T)(right>left) ? 1 : 0; }
T dec(T)(T left, T right) if (isNumeric!T) { return cast(T)(right<left) ? 1 : 0; }
T delta(T)(T left, T right) if (isNumeric!T) { return right-left; }
T dif(T)(T left, T right, T distance = 1) if (isNumeric!T) { return div(right-left, distance); }
T diff(T)(T left, T middle, T right, T distance = 1) if (isNumeric!T) { 
	auto l = dif(left, middle, distance);
	auto r = dif(middle, right, distance);
	return dif(l,r, distance);
}

unittest {
	import std.stdio;
	
	writeln("Testing uim.data.classes.cell...");

	writeln("---- START Test cell...(int)");
	
	assert(add(1, 2) == 3);
	assert(sub(1, 2) == -1);
	assert(sub(2, 1) == 1);
	assert(mul(1, 2) == 2);
	assert(mul(-1, 2) == -2);
	writeln("div(1,2)=>", div(1, 2));
	writeln("div(2,1)=>", div(2, 1));
	writeln("div(4,2)=>", div(4, 2));
	writeln("div(1,0)=>", div(1, 0));
	
	writeln("min(1,2)=>", min(1, 2));
	writeln("max(1,2)=>", max(1, 2));
	writeln("sum(1,2)=>", sum(1, 2));
	writeln("avg(3,1)=>", avg(3, 1));
	writeln("geo(3,1)=>", geo(3, 1));
	writeln("geo(2,2)=>", geo(3, 1));
	
	writeln("dif(1,2)=>", dif(1, 2));
	writeln("dif(0,2)=>", dif(0, 2));
	writeln("dif(1,0)=>", dif(1, 0));
	writeln("dif(10,20,2)=>", dif(10, 20,2));
	writeln("dif(0,20,2)=>", dif(0, 20,2));
	writeln("dif(10,0,2)=>", dif(10, 0,2));
	writeln("inc(1,2)=>", inc(1, 2));
	writeln("inc(2,1)=>", inc(2, 1));
	writeln("dec(1,2)=>", dec(1, 2));
	writeln("dec(2,1)=>", dec(2, 1));
	
	writeln("vlt(10,20)=>", vlt(10, 20));

	writeln("---- START Test cell...(double)");
	
	writeln("add(1.0,2.0)=>", add(1.0, 2.0));
	writeln("sub(1.0, 2.0)=>", sub(1.0, 2.0));
	writeln("sub(2.0, 1.0)=>", sub(2.0, 1.0));
	writeln("mul(1.0, 2.0)=>", mul(1.0, 2.0));
	writeln("div(1.0, 2.0)=>", div(1.0, 2.0));
	writeln("div(4.0,2.0)=>", div(4.0, 2.0));
	writeln("div(1.0,0.0)=>", div(1.0, 0));
	
	writeln("min(1.0, 2.0)=>", min(1.0, 2.0));
	writeln("max(1.0, 2.0)=>", max(1.0, 2.0));
	writeln("sum(1.0, 2.0)=>", sum(1.0, 2.0));
	writeln("avg(3.0,1.0)=>", avg(3.0, 1.0));
	writeln("geo(3.0,1.0)=>", geo(3.0, 1.0));
	
	writeln("dif(1.0, 2.0)=>", dif(1.0, 2.0));
	writeln("dif(0,2.0)=>", dif(0, 2.0));
	writeln("dif(1.0,0)=>", dif(1.0, 0));
	writeln("dif(1.0,1.0)=>", dif(1.0, 1.0));
	writeln("dif(10.0,20,2.0)=>", dif(10.0, 20.0,2.0));
	writeln("dif(0,20.0,2.0)=>", dif(0, 20.0,2.0));
	writeln("dif(10.0,0,2.0)=>", dif(10.0, 0,2.0));
	
	writeln("inc(1.0, 2.0)=>", inc(1.0, 2.0));
	writeln("inc(2.0,1.0)=>", inc(2.0, 1.0));
	writeln("dec(1.0, 2.0)=>", dec(1.0, 2.0));
	writeln("dec(2.0,1.0)=>", dec(2.0, 1.0));
	writeln("vlt(10.0,20.0)=>", vlt(10.0, 20.0));
}