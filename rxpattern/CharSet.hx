package rxpattern;
import haxe.macro.Context;
import haxe.macro.Expr;
import rxpattern.IntSet;
import rxpattern.unicode.CodePoint;

@:forward(length)
abstract CharSet(IntSet)
{
    @:extern
    public inline function new(s : IntSet)
        this = s;

    @:extern
    public static inline function empty()
        return new CharSet(IntSet.empty());

    @:extern
    public static inline function singleton(c: String)
        return new CharSet(IntSet.singleton(singleCodePoint(c)));

    @:from
    @:extern
    public static inline function fromStringD(s: String)
        return new CharSet(IntSet.fromIterator(CodePoint.codePointIterator(s)));

    macro public static function fromString(x: ExprOf<String>)
    {
        switch (x.expr) {
        case EConst(CString(s)):
            var pos = Context.currentPos();
            try {
                var is = IntSet.fromIterator(CodePoint.codePointIterator(s)).iterator();
                var elements = [];
                for (c in is) {
                    elements.push({pos: pos, expr: ExprDef.EConst(Constant.CInt("" + c))});
                }
                var array = {pos: pos, expr: ExprDef.EArrayDecl(elements)};
                return macro new rxpattern.CharSet(new rxpattern.IntSet($array));
            } catch (error: String) {
                Context.error(error, pos);
                return null;
            }
        default:
            return macro rxpattern.CharSet.fromStringD($x);
        }
    }

    @:extern
    public inline function getCodePointSet()
        return this;

    @:extern
    public inline function hasCodePoint(x: Int)
        return this.has(x);

    @:extern
    public inline function has(c: String)
        return this.has(singleCodePoint(c));

    @:extern
    public inline function addCodePoint(x: Int)
        this.add(x);

    @:extern
    public inline function add(c: String)
        this.add(singleCodePoint(c));

    @:extern
    public inline function removeCodePoint(x: Int)
        this.remove(x);

    @:extern
    public inline function remove(c: String)
        this.remove(singleCodePoint(c));

    @:extern
    public inline function codePointIterator()
        return this.iterator();

    @:extern
    public static inline function intersection(a: CharSet, b: CharSet)
        return new CharSet(IntSet.intersection(a.getCodePointSet(), b.getCodePointSet()));

    @:extern
    public static inline function union(a: CharSet, b: CharSet)
        return new CharSet(IntSet.union(a.getCodePointSet(), b.getCodePointSet()));

    @:extern
    public static inline function difference(a: CharSet, b: CharSet)
        return new CharSet(IntSet.difference(a.getCodePointSet(), b.getCodePointSet()));

    #if !macro
        private static var rxSingleCodePoint =
            #if (js || cs)
                ~/^(?:[\u0000-\uD7FF\uE000-\uFFFF]|[\uD800-\uDBFF][\uDC00-\uDFFF])$/;
            #else
                ~/^.$/us;
            #end
    #end
    private static function singleCodePoint(s: String): Int
    {
        #if macro
            if (s.length == 0) {
                throw "rxpattern.CharSet: not a single code point";
            }
            var x = CodePoint.codePointAt(s, 0);
            if (CodePoint.fromCodePoint(x) != s) {
                throw "rxpattern.CharSet: not a single code point";
            }
        #else
            if (!rxSingleCodePoint.match(s)) {
                throw "rxpattern.CharSet: not a single code point";
            }
        #end
        return CodePoint.codePointAt(s, 0);
    }
}
