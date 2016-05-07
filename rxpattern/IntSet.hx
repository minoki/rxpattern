package rxpattern;

@:forward(length, iterator)
abstract IntSet(Array<Int>)
{
    @:extern
    public inline function new(a)
        this = a;

    @:extern
    private inline function asArray(): Array<Int>
        return this;

    @:extern
    public static inline function empty()
        return new IntSet([]);

    @:extern
    public static inline function singleton(x: Int)
        return new IntSet([x]);

    @:extern
    public static inline function fromRange(from: Int, to: Int)
        return new IntSet([for (x in from ... to) x]);

    public static inline function fromIterator(it: Iterator<Int>)
    {
        var set = empty();
        for (x in it) {
            set.add(x);
        }
        return set;
    }
    public static inline function fromIterable(a: Iterable<Int>)
    {
        var set = empty();
        for (x in a) {
            set.add(x);
        }
        return set;
    }
    public function has(x: Int)
    {
        var u = this.length;
        var l = 0;
        while (l < u) {
            var i = Std.int((u + l) / 2);
            if (this[i] < x) {
                l = i + 1;
            } else if (this[i] > x) {
                u = i;
            } else {
                return true;
            }
        }
        return false;
    }
    public function add(x: Int)
    {
        var u = this.length;
        var l = 0;
        while (l < u) {
            var i = Std.int((u + l) / 2);
            if (this[i] < x) {
                l = i + 1;
            } else if (this[i] > x) {
                u = i;
            } else {
                /* already contains x */
                return;
            }
        }
        this.insert(l, x);
    }
    public function remove(x: Int)
    {
        var u = this.length;
        var l = 0;
        while (l < u) {
            var i = Std.int((u + l) / 2);
            if (this[i] < x) {
                l = i + 1;
            } else if (this[i] > x) {
                u = i;
            } else {
                this.splice(i, 1);
                return;
            }
        }
    }

    public static function intersection(x: IntSet, y: IntSet)
    {
        var xa = x.asArray();
        var ya = y.asArray();
        var xl = xa.length;
        var yl = ya.length;
        var xi = 0;
        var yi = 0;
        var a = [];
        while (xi < xl && yi < yl) {
            var cx = xa[xi];
            var cy = ya[yi];
            if (cx < cy) {
                ++xi;
            } else if (cy < cx) {
                ++yi;
            } else {
                a.push(cx);
                ++xi;
                ++yi;
            }
        }
        return new IntSet(a);
    }

    public static function union(x: IntSet, y: IntSet)
    {
        var xa = x.asArray();
        var ya = y.asArray();
        var xl = xa.length;
        var yl = ya.length;
        var xi = 0;
        var yi = 0;
        var a = [];
        while (xi < xl && yi < yl) {
            var cx = xa[xi];
            var cy = ya[yi];
            if (cx < cy) {
                a.push(cx);
                ++xi;
            } else if (cy < cx) {
                a.push(cy);
                ++yi;
            } else {
                a.push(cx);
                ++xi;
                ++yi;
            }
        }
        while (xi < xl) {
            a.push(xa[xi++]);
        }
        while (yi < yl) {
            a.push(ya[yi++]);
        }
        return new IntSet(a);
    }

    public static function difference(x: IntSet, y: IntSet)
    {
        var xa = x.asArray();
        var ya = y.asArray();
        var xl = xa.length;
        var yl = ya.length;
        var xi = 0;
        var yi = 0;
        var a = [];
        while (xi < xl && yi < yl) {
            var cx = xa[xi];
            var cy = ya[yi];
            if (cx < cy) {
                a.push(cx);
                ++xi;
            } else if (cy < cx) {
                ++yi;
            } else {
                ++xi;
                ++yi;
            }
        }
        while (xi < xl) {
            a.push(xa[xi++]);
        }
        return new IntSet(a);
    }
}
