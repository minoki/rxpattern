package rxpattern.unicode;
import rxpattern.unicode.CodePointIterator;
#if java
    import java.NativeArray;
#end
#if cs
    import cs.system.Char;
#end

#if (cs || python) extern #end
class CodePoint
{
    @:extern
    public static inline function codePointIterator(s: String): CodePointIterator
    {
        return new CodePointIterator(s);
    }
    /**
       i : index in code units (UTF-16 on JavaScript, Java and C#, UTF-8 on Neko VM, C++, PHP and Lua, UTF-32 on Python)
     */
    #if (java || cs || python)
        @:extern inline
    #end
    public static function codePointAt(s: String, i: Int): Int
    {
        #if java
            return @:privateAccess s.codePointAt(i);
        #elseif cs
            return Char.ConvertToUtf32(s, i);
        #elseif (js || flash)
            /* UTF-16 decode */
            var x = s.charCodeAt(i);
            if (0xD800 <= x && x <= 0xDFFF) {
                if (0xDC00 <= x) {
                    throw "rxpattern.unicode.CodePoint.codePointAt: invalid low surrogate";
                }
                var y = s.charCodeAt(i + 1);
                if (0xDC00 <= y && y <= 0xDFFF) {
                    return (((x & 0x3FF) << 10) + 0x10000) | (y & 0x3FF);
                } else {
                    throw "rxpattern.unicode.CodePoint.codePointAt: invalid low surrogate";
                }
            } else {
                return x;
            }
        #elseif (cpp || neko || php || lua || macro)
            /* UTF-8 decode */
            var x = s.charCodeAt(i);
            if (x < 0x80) {
                return x;
            } else {
                if (x < 0xC0) {
                    throw "rxpattern.unicode.CodePoint.codePointAt: invalid UTF-8 sequence";
                } else if (x < 0xE0) {
                    var x2 = s.charCodeAt(i + 1);
                    var a0 = x & 0x1F;
                    var a1 = x2 & 0x3F;
                    var v = (a0 << 6) | a1;
                    if (v < 0x80 || (x2 & 0xC0) != 0x80) {
                        throw "rxpattern.unicode.CodePoint.codePointAt: invalid UTF-8 sequence";
                    }
                    return v;
                } else if (x < 0xF0) {
                    var x2 = s.charCodeAt(i + 1);
                    var x3 = s.charCodeAt(i + 2);
                    var a0 = x & 0x0F;
                    var a1 = x2 & 0x3F;
                    var a2 = x3 & 0x3F;
                    var v = (a0 << 12) | (a1 << 6) | a2;
                    if (v < 0x800 || (x2 & 0xC0) != 0x80 || (x3 & 0xC0) != 0x80) {
                        throw "rxpattern.unicode.CodePoint.codePointAt: invalid UTF-8 sequence";
                    }
                    return v;
                } else if (x < 0xF8) {
                    var x2 = s.charCodeAt(i + 1);
                    var x3 = s.charCodeAt(i + 2);
                    var x4 = s.charCodeAt(i + 3);
                    var a0 = x & 0x07;
                    var a1 = x2 & 0x3F;
                    var a2 = x3 & 0x3F;
                    var a3 = x4 & 0x3F;
                    var v = (a0 << 18) | (a1 << 12) | (a2 << 6) | a3;
                    if (v < 0x10000 || (x2 & 0xC0) != 0x80 || (x3 & 0xC0) != 0x80 || (x4 & 0xC0) != 0x80) {
                        throw "rxpattern.unicode.CodePoint.codePointAt: invalid UTF-8 sequence";
                    }
                    return v;
                } else {
                    throw "rxpattern.unicode.CodePoint.codePointAt: invalid UTF-8 sequence";
                }
            }
        #else
            /* UTF-32 */
            /* Python */
            return s.charCodeAt(i);
        #end
    }
    #if (cs || python) @:extern inline #end
    public static function fromCodePoint(c: Int): String
    {
        #if java
            /*
              Want to call
                  String(int[] codePoints, int offset, int count)
            */
            var a: NativeArray<Int> = java.NativeArray.make(c);
            return new String(untyped a, 0, 1);
        #elseif cs
            return Char.ConvertFromUtf32(c);
        #elseif (js || flash)
            /* UTF-16 encode */
            if (c < 0x10000) {
                if (0xD800 <= c && c <= 0xDFFF) {
                    throw "rxpattern.unicode.CodePoint.fromCodePoint: invalid surrogate pairs";
                }
                return String.fromCharCode(c);
            } else {
                if (c > 0x10FFFF) {
                    throw "rxpattern.unicode.CodePoint.fromCodePoint: code point out of range";
                }
                var hi = ((c - 0x10000) >> 10) | 0xD800;
                var lo = ((c - 0x10000) & 0x3FF) | 0xDC00;
                #if (js || flash)
                    /* String.fromCharCode accepts multiple arguments */
                    return (untyped String.fromCharCode)(hi, lo);
                #else
                    return String.fromCharCode(hi) + String.fromCharCode(lo);
                #end
            }
        #elseif (cpp || neko || php || lua || macro)
            /* UTF-8 encode */
            if (c < 0x80) {
                return String.fromCharCode(c);
            } else if (c < 0x800) { // 11 bits
                var c1 = (c >> 6) | 0xC0;
                var c2 = (c & 0x3F) | 0x80;
                return String.fromCharCode(c1) + String.fromCharCode(c2);
            } else if (c < 0x10000) { // 16 bits
                if (0xD800 <= c && c <= 0xDFFF) {
                    throw "rxpattern.unicode.CodePoint.fromCodePoint: invalid surrogate pair";
                }
                var c1 = (c >> 12) | 0xE0;
                var c2 = ((c >> 6) & 0x3F) | 0x80;
                var c3 = (c & 0x3F) | 0x80;
                return String.fromCharCode(c1) + String.fromCharCode(c2) + String.fromCharCode(c3);
            } else if (c < 0x110000) { // 21 bits
                var c1 = (c >> 18) | 0xF0;
                var c2 = ((c >> 12) & 0x3F) | 0x80;
                var c3 = ((c >> 6) & 0x3F) | 0x80;
                var c4 = (c & 0x3F) | 0x80;
                return String.fromCharCode(c1) + String.fromCharCode(c2) + String.fromCharCode(c3) + String.fromCharCode(c4);
            } else {
                throw "rxpattern.unicode.CodePoint.fromCodePoint: code point out of range";
            }
        #else /* Python */
            /* UTF-32 */
            return String.fromCharCode(c);
        #end
    }
}
