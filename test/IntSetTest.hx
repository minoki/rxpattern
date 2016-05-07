import rxpattern.IntSet;
class IntSetTest extends haxe.unit.TestCase
{
    function testAdd()
    {
        var a = IntSet.empty();
        assertFalse(a.has(0));
        a.add(3);
        assertTrue(a.has(3));
        a.add(8);
        assertTrue(a.has(3));
        assertTrue(a.has(8));
    }
    function testRemove()
    {
        var b = IntSet.fromIterable([1, 3, 5, 7]);
        assertTrue(b.has(3));
        assertTrue(b.has(5));
        assertTrue(b.has(7));
        assertFalse(b.has(4));
        b.remove(5);
        assertFalse(b.has(5));
    }
    function testFromRange()
    {
        var d = IntSet.fromRange(1, 10);
        assertTrue(d.has(1));
        assertTrue(d.has(5));
        assertTrue(d.has(9));
        assertFalse(d.has(10));
    }
    function testIntersection()
    {
        var a = IntSet.fromIterable([3, 8]);
        var b = IntSet.fromIterable([1, 3, 7]);
        var c = IntSet.intersection(a, b);
        assertFalse(c.has(1));
        assertTrue(c.has(3));
        assertFalse(c.has(7));
        assertFalse(c.has(8));
    }
    function testUnion()
    {
        var a = IntSet.fromIterable([3, 8]);
        var b = IntSet.fromIterable([1, 3, 7]);
        var c = IntSet.union(a, b);
        assertTrue(c.has(1));
        assertTrue(c.has(3));
        assertTrue(c.has(7));
        assertTrue(c.has(8));
    }
    function testDifference()
    {
        var c = IntSet.fromIterable([1, 3, 7, 8]);
        var d = IntSet.fromRange(1, 10);
        var e = IntSet.difference(d, c);
        assertFalse(e.has(1));
        assertTrue(e.has(2));
        assertFalse(e.has(3));
        assertTrue(e.has(4));
        assertTrue(e.has(5));
        assertTrue(e.has(6));
        assertFalse(e.has(7));
        assertFalse(e.has(8));
        assertTrue(e.has(9));
        assertFalse(e.has(10));
    }
    static function main()
    {
        var r = new haxe.unit.TestRunner();
        r.add(new IntSetTest());
        r.run();
    }
}
