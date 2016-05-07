import rxpattern.RxPattern;
import rxpattern.GeneralCategory;

class Example extends haxe.unit.TestCase
{
    function test1()
    {
        var pattern1 = (RxPattern.Char("a") | RxPattern.Char("b")).many();
        var rx1 : EReg = pattern1.build();
        assertTrue(rx1.match("abaab"));
    }

    function test2()
    {
        var pattern2 = RxPattern.String("gr")
                       >> (RxPattern.Char("a") | RxPattern.Char("e"))
                       >> RxPattern.String("y");
        var rx2 = pattern2.build();
        assertTrue(rx2.match("grey"));
        assertTrue(rx2.match("gray"));
    }

    function test3()
    {
        var pattern3 = RxPattern.AtStart
                       >> RxPattern.String("colo")
                       >> RxPattern.Char("u").option()
                       >> RxPattern.String("r")
                       >> RxPattern.AtEnd;
        var rx3 = pattern3.build();
        assertTrue(rx3.match("color"));
        assertTrue(rx3.match("colour"));
        assertFalse(rx3.match("color\n"));
        assertFalse(rx3.match("\ncolour"));
    }

    function test4()
    {
        var wordStart = GeneralCategory.Letter | RxPattern.Char("_");
        var wordChar = wordStart | GeneralCategory.Number;
        var word = wordStart >> wordChar.many();
        var pattern4 = RxPattern.AtStart >> word >> RxPattern.AtEnd;
        var rx4 = pattern4.build();
        assertTrue(rx4.match("function"));
        assertTrue(rx4.match("int32_t"));
        assertTrue(rx4.match("\u3042"));
        assertFalse(rx4.match("24hours"));
    }

    public static function main()
    {
        var r = new haxe.unit.TestRunner();
        r.add(new Example());
        r.run();
    }
}
