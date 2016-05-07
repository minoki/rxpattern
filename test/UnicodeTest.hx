import rxpattern.unicode.CodePoint;
class UnicodeTest extends haxe.unit.TestCase
{
    public function testFromCodePoint()
    {
        assertEquals("\u{32}", CodePoint.fromCodePoint(0x32));
        assertEquals("\u{304}", CodePoint.fromCodePoint(0x304));
        assertEquals("\u{3042}", CodePoint.fromCodePoint(0x3042));
        assertEquals("\u{12345}", CodePoint.fromCodePoint(0x12345));
    }

    public function testCodePointAt()
    {
        assertEquals(0x32, CodePoint.codePointAt("\u0032", 0));
        assertEquals(0x304, CodePoint.codePointAt("\u0304", 0));
        assertEquals(0x3042, CodePoint.codePointAt("\u3042", 0));
        assertEquals(0x12345, CodePoint.codePointAt("\u{12345}", 0));
    }

    public function testCodePointIterator()
    {
        var it = CodePoint.codePointIterator("\u0000x\u3042\u{12345}\u{20A0}");
        assertEquals(it.next(), 0);
        assertEquals(it.next(), 'x'.charCodeAt(0));
        assertEquals(it.next(), 0x3042);
        assertEquals(it.next(), 0x12345);
        assertEquals(it.next(), 0x20A0);
        assertFalse(it.hasNext());
    }

    static function main()
    {
        var r = new haxe.unit.TestRunner();
        r.add(new UnicodeTest());
        r.run();
    }
}
