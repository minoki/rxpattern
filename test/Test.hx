class Test
{
    static function main()
    {
        var r = new haxe.unit.TestRunner();
        r.add(new IntSetTest());
        r.add(new UnicodeTest());
        r.add(new RxPatternTest());
        r.add(new Example());
        r.run();
    }
}
