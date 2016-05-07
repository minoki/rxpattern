package rxpattern;
import haxe.macro.Context;
import haxe.macro.Expr;

/* This class is not used at runtime */
#if !macro extern #end
class UnicodePatternUtil
{
    /*
     * Different regexp engines have different syntax for hexadecimal Unicode
     * escape sequence.  This macro translates Unicode escape sequences of
     * the form \uHHHH or \u{HHHHH} into the form recognized by the engine.
     *
     * Input: \uHHHH or \u{HHHHH}
     * Python: \uHHHH or \UHHHHHHHH
     * Perl-like (Neko VM, C++, PHP, Lua and Java): \x{HHHHH}
     * JavaScript, C#, Flash: \uHHHH
     */
    macro public static function translateUnicodeEscape(s: String)
    {
        var pos = Context.currentPos();
        var pythonStyle = Context.defined("python"); // \uHHHH or \UHHHHHHHH
        var perlStyle = Context.defined("neko") || Context.defined("cpp") || Context.defined("php") || Context.defined("lua") || Context.defined("java"); // \x{HHHH}
        var jsStyle = Context.defined("js") || Context.defined("cs") || Context.defined("flash"); // \uHHHH
        var onlyBMP = Context.defined("js") || Context.defined("cs");
        var i = 0;
        var translatedBuf = new StringBuf();
        while (i < s.length) {
            var j = s.indexOf("\\u", i);
            if (j == -1) {
                break;
            }
            translatedBuf.add(s.substring(i, j));
            var m;
            if (s.charAt(j + 2) == '{') {
                var k = s.indexOf('}', j + 3);
                if (k == -1) {
                    Context.error("Invalid unicode escape sequence", pos);
                    return null;
                }
                m = s.substring(j + 3, k);
                i = k + 1;
            } else {
                m = s.substring(j + 2, j + 6);
                i = j + 6;
            }
            var value = 0;
            for (l in 0...m.length) {
                value = value * 16 + hexToInt(m.charAt(l));
            }
            if (perlStyle) {
                translatedBuf.add("\\x{" + StringTools.hex(value) + "}");
            } else {
                if (value > 0x10000) {
                    if (pythonStyle) {
                        translatedBuf.add("\\U" + StringTools.hex(value, 8));
                    } else if (jsStyle || !onlyBMP) {
                        var hi = ((value - 0x10000) >> 10) | 0xD800;
                        var lo = ((value - 0x10000) & 0x3FF) | 0xDC00;
                        translatedBuf.add("\\u" + StringTools.hex(hi, 4) + "\\u" + StringTools.hex(lo, 4));
                    } else {
                        Context.error("This platform does not support Unicode escape beyond BMP.", pos);
                        return null;
                    }
                } else if (jsStyle || pythonStyle) {
                    translatedBuf.add("\\u" + StringTools.hex(value, 4));
                } else {
                    Context.error("This platform does not support Unicode escape.", pos);
                    return null;
                }
            }
        }
        translatedBuf.add(s.substr(i));
        return {pos: pos, expr: ExprDef.EConst(Constant.CString(translatedBuf.toString()))};
    }

    #if macro
        private static function hexToInt(c: String)
        {
            var i = "0123456789abcdef".indexOf(c.toLowerCase());
            if (i == -1) {
                throw "Invalid unicode escape";
            } else {
                return i;
            }
        }
    #end
}
