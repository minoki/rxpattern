import rxpattern.CharSet;
import rxpattern.RxPattern;
class RxPatternTest extends haxe.unit.TestCase
{
    public function assertPatStrEquals(s: String, p: RxPattern, ?pos: haxe.PosInfos)
    {
        assertEquals(s, RxPattern.getPattern(p), pos);
    }
    public function assertMatch(s: String, p, ?pos: haxe.PosInfos)
    {
        assertTrue(RxPattern.buildEReg(p).match(s), pos);
    }
    public function assertNotMatch(s: String, p, ?pos: haxe.PosInfos)
    {
        assertFalse(RxPattern.buildEReg(p).match(s), pos);
    }

    // Prevent static compilation
    function str(s: String) return s;

    public function testBasic()
    {
        assertPatStrEquals("a|xyz\\^\\\\", RxPattern.Char("a") | RxPattern.String("xyz^\\"));
        assertMatch("a", RxPattern.Char("a") | RxPattern.String("xyz^\\"));
        assertMatch("xyz^\\", RxPattern.Char("a") | RxPattern.String("xyz^\\"));
        assertPatStrEquals("[a-c]*|xyz", RxPattern.CharSet("abc").many() | RxPattern.String("xyz"));
        assertPatStrEquals("[a-c]*|(?:xyz)+", RxPattern.CharSet("abc").many() | RxPattern.String("xyz").many1());
        assertPatStrEquals("[a-c]*|(?:xyz)+", RxPattern.CharSetLit("abc").many() | RxPattern.String("xyz").many1());
        assertPatStrEquals("[a-c]?", RxPattern.CharSet("abc").option());
    }

    public function testAny()
    {
        assertMatch("A", RxPattern.AtStart >> RxPattern.AnyCodePoint >> RxPattern.AtEnd);
        assertMatch("A", RxPattern.AtStart >> RxPattern.AnyExceptNewLine >> RxPattern.AtEnd);
        assertMatch("x\ny", RxPattern.Char("x") >> RxPattern.AnyCodePoint >> RxPattern.Char("y"));
        assertNotMatch("x\ny", RxPattern.Char("x") >> RxPattern.AnyExceptNewLine >> RxPattern.Char("y"));
        assertNotMatch("\n", RxPattern.AtStart >> RxPattern.AnyExceptNewLine >> RxPattern.AtEnd);
    }

    public function testAssertion()
    {
        assertNotMatch("A\n", RxPattern.Char("A") >> RxPattern.AtEnd);
        assertNotMatch("A\nB\n", RxPattern.AtStart >> RxPattern.Char("B"));
    }

    public function testBasic2()
    {
        assertPatStrEquals("a|b", RxPattern.Char("a") | RxPattern.Char("b"));
        assertPatStrEquals("(a|b)c", RxPattern.Group(RxPattern.Char("a") | RxPattern.Char("b")) >> RxPattern.Char("c"));
        assertPatStrEquals("(?:a|b)c", (RxPattern.Char("a") | RxPattern.Char("b")) >> RxPattern.Char("c"));
        assertPatStrEquals("(?:ab)*", (RxPattern.Char("a") >> RxPattern.Char("b")).many());
        assertPatStrEquals("(?:ab)+", (RxPattern.Char("a") >> RxPattern.Char("b")).many1());
    }

    public function testNever()
    {
        assertNotMatch("abc", RxPattern.Never);
        assertNotMatch("abc", RxPattern.String("abc") >> RxPattern.Never);
        assertMatch("abc", RxPattern.Never | RxPattern.String("abc"));
    }

    public function testEscape()
    {
        assertPatStrEquals("a", RxPattern.Char("a"));
        assertPatStrEquals("a", RxPattern.Char(str("a")));
        assertMatch("\\", RxPattern.Char("\\"));
        assertPatStrEquals("\\^", RxPattern.Char("^"));
        assertMatch("[^xyz]\\A", RxPattern.String("[^xyz]\\A"));
        assertMatch("aaa[^xyz]\\A", RxPattern.String("[^xyz]\\A"));
        assertNotMatch("aaa[^xyz]\\A", RxPattern.AtStart >> RxPattern.String("[^xyz]\\A"));
        assertMatch("[^xyz]\\A", RxPattern.String(str("[^xyz]\\A")));
        assertMatch("\u{12345}", RxPattern.Char("\u{12345}"));
        assertMatch("\u{12345}", RxPattern.Char(str("\u{12345}")));
    }

    public function testUnicode()
    {
        assertMatch("\u{10000}", RxPattern.Char("\u{10000}"));
        assertMatch("\u{10000}", RxPattern.Char(str("\u{10000}")));
        assertMatch("\u{10000}\u{10FFFF}", RxPattern.String("\u{10000}\u{10FFFF}"));
        assertMatch("\u{10000}\u{10FFFF}", RxPattern.String(str("\u{10000}\u{10FFFF}")));
        assertMatch("x\u{10000}y", RxPattern.Char("x") >> RxPattern.AnyExceptNewLine >> RxPattern.Char("y"));
        assertNotMatch("x\u{10000}y", RxPattern.Char("x") >> RxPattern.AnyExceptNewLine >> RxPattern.AnyExceptNewLine >> RxPattern.Char("y"));
        assertMatch("x\u{10000}y", RxPattern.Char("x") >> RxPattern.AnyCodePoint >> RxPattern.Char("y"));
        assertMatch("\u{12345}", RxPattern.AtStart >> RxPattern.AnyCodePoint >> RxPattern.AtEnd);
        assertMatch("\u{12345}", RxPattern.AtStart >> RxPattern.AnyExceptNewLine >> RxPattern.AtEnd);
    }

    public function testSet()
    {
        assertPatStrEquals("[ehlo]", RxPattern.CharSet(CharSet.fromString("hello")));

        var p = RxPattern.NotInSet(CharSet.fromString("hello"));
        assertNotMatch("h", p);
        assertNotMatch("e", p);
        assertNotMatch("l", p);
        assertNotMatch("o", p);
        assertMatch("AaZ", RxPattern.Char("A") >> p >> RxPattern.Char("Z"));
        assertNotMatch("AoZ", RxPattern.Char("A") >> p >> RxPattern.Char("Z"));
        assertMatch("A\u{10000}Z", RxPattern.Char("A") >> p >> RxPattern.Char("Z"));

        var q = RxPattern.CharSet(CharSet.fromString("a\u{10000}\u{10002}"));
        assertMatch("a", q);
        assertMatch("\u{10000}", q);
        assertNotMatch("\u{10001}", q);
        assertMatch("\u{10002}", q);

        var r = RxPattern.NotInSet(CharSet.fromString("a\u{10000}\u{10002}"));
        assertNotMatch("a", r);
        assertNotMatch("\u{10000}", r);
        assertMatch("\u{10001}", r);
        assertNotMatch("\u{10002}", r);
        assertMatch("\u{3042}", r);
    }

    public function testSetDyn()
    {
        assertPatStrEquals("[ehlo]", RxPattern.CharSet(CharSet.fromString(str("hello"))));

        var p = RxPattern.NotInSet(CharSet.fromString(str("hello")));
        assertNotMatch("h", p);
        assertNotMatch("e", p);
        assertNotMatch("l", p);
        assertNotMatch("o", p);
        assertMatch("AaZ", RxPattern.Char("A") >> p >> RxPattern.Char("Z"));
        assertNotMatch("AoZ", RxPattern.Char("A") >> p >> RxPattern.Char("Z"));
        assertMatch("A\u{10000}Z", RxPattern.Char("A") >> p >> RxPattern.Char("Z"));

        var q = RxPattern.CharSet(CharSet.fromString(str("a\u{10000}\u{10002}")));
        assertMatch("a", q);
        assertMatch("\u{10000}", q);
        assertNotMatch("\u{10001}", q);
        assertMatch("\u{10002}", q);

        var r = RxPattern.NotInSet(CharSet.fromString(str("a\u{10000}\u{10002}")));
        assertNotMatch("a", r);
        assertNotMatch("\u{10000}", r);
        assertMatch("\u{10001}", r);
        assertNotMatch("\u{10002}", r);
        assertMatch("\u{3042}", r);
    }

    public function testSetLit()
    {
        assertPatStrEquals("[ehlo]", RxPattern.CharSetLit("hello"));

        var p = RxPattern.NotInSetLit("hello");
        assertNotMatch("h", p);
        assertNotMatch("e", p);
        assertNotMatch("l", p);
        assertNotMatch("o", p);
        assertMatch("AaZ", RxPattern.Char("A") >> p >> RxPattern.Char("Z"));
        assertNotMatch("AoZ", RxPattern.Char("A") >> p >> RxPattern.Char("Z"));
        assertMatch("A\u{10000}Z", RxPattern.Char("A") >> p >> RxPattern.Char("Z"));

        var q = RxPattern.CharSetLit("a\u{10000}\u{10002}");
        assertMatch("a", q);
        assertMatch("\u{10000}", q);
        assertNotMatch("\u{10001}", q);
        assertMatch("\u{10002}", q);

        var r = RxPattern.NotInSetLit("a\u{10000}\u{10002}");
        assertNotMatch("a", r);
        assertNotMatch("\u{10000}", r);
        assertMatch("\u{10001}", r);
        assertNotMatch("\u{10002}", r);
        assertMatch("\u{3042}", r);
    }

    public static function main()
    {
        var r = new haxe.unit.TestRunner();
        r.add(new RxPatternTest());
        r.run();
    }
}
