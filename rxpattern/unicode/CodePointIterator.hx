package rxpattern.unicode;
import rxpattern.unicode.CodePoint;
#if cpp
    import cpp.FastIterator;
#end

@:final
class CodePointIterator
    /* Extend cpp.FastIterator<Int> to allow fast iteration in for-in statement */
    #if cpp extends FastIterator<Int> #end
{
    var s: String;
    var index: Int;
    public function new(s: String, index: Int = 0)
    {
        this.s = s;
        this.index = index;
    }
    #if cpp override #end
    public inline function hasNext()
    {
        return this.index < this.s.length;
    }
    #if cpp override #end
    public function next()
    {
        var x = CodePoint.codePointAt(this.s, this.index++);
        #if (js || java || cs || flash)
            /* UTF-16 */
            if (x >= 0x10000) {
                this.index++;
            }
        #elseif (cpp || neko || php || lua)
            /* UTF-8 */
            if (x >= 0x10000) {
                this.index += 3;
            } else if (x >= 0x800) {
                this.index += 2;
            } else if (x >= 0x80) {
                this.index += 1;
            }
        #else /* python */
            /* UTF-32 */
        #end
        return x;
    }
}
