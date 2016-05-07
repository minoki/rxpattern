class PlatformReport {
    static function allMatches(r : EReg, s : String) {
        var pos = 0;
        var a = [];
        while (r.matchSub(s, pos)) {
            var p = r.matchedPos();
            pos = p.pos + p.len;
            a.push(r.matched(0));
        }
        return a;
    }
    static function reportBeginningRx()
    {
        {
            var line = new StringBuf();
            line.add(StringTools.rpad("Pattern", " ", 19));
            line.add(" | ");
            line.add(StringTools.rpad("beginning of string", " ", 19));
            line.add(" | ");
            line.add(StringTools.rpad("beginning of line", " ", 17));
            trace(line.toString());
        }
        {
            var line = new StringBuf();
            line.add(StringTools.rpad("", "-", 19));
            line.add("-+-");
            line.add(StringTools.rpad("", "-", 19));
            line.add("-+-");
            line.add(StringTools.rpad("", "-", 17));
            trace(line.toString());
        }
        for (p in ["^", "\\A"]) {
            try {
                for (mode in [["u", "default"], ["um", "multiline mode"]]) {
                    var r = new EReg('${p}X', mode[0]);
                    var line = new StringBuf();
                    line.add(StringTools.rpad('${p} (${mode[1]})', " ", 19));
                    line.add(" | ");
                    line.add(StringTools.rpad(r.match("Xabc") ? "matches" : "does not match", " ", 19));
                    line.add(" | ");
                    line.add(StringTools.rpad(r.match("\nX") ? "matches" : "does not match", " ", 17));
                    trace(line.toString());
                }
            } catch (e: Dynamic) {
                trace('\'${p}\' is not supported');
            }
        }
    }
    static function reportEndingRx()
    {
        {
            var line = new StringBuf();
            line.add(StringTools.rpad("Pattern", " ", 19));
            line.add(" | ");
            line.add(StringTools.rpad("end of string", " ", 14));
            line.add(" | ");
            line.add(StringTools.rpad("final end of line", " ", 17));
            line.add(" | ");
            line.add(StringTools.rpad("end of line", " ", 14));
            trace(line.toString());
        }
        {
            var line = new StringBuf();
            line.add(StringTools.rpad("", "-", 19));
            line.add("-+-");
            line.add(StringTools.rpad("", "-", 14));
            line.add("-+-");
            line.add(StringTools.rpad("", "-", 17));
            line.add("-+-");
            line.add(StringTools.rpad("", "-", 14));
            trace(line.toString());
        }
        for (p in ["$", "\\Z", "\\z"]) {
            try {
                for (mode in [["u", "default"], ["um", "multiline mode"]]) {
                    var r = new EReg('X${p}', mode[0]);
                    var line = new StringBuf();
                    line.add(StringTools.rpad('${p} (${mode[1]})', " ", 19));
                    line.add(" | ");
                    line.add(StringTools.rpad(r.match("abcX") ? "matches" : "does not match", " ", 14));
                    line.add(" | ");
                    line.add(StringTools.rpad(r.match("X\n") ? "matches" : "does not match", " ", 17));
                    line.add(" | ");
                    line.add(StringTools.rpad(r.match("X\nY") ? "matches" : "does not match", " ", 14));
                    trace(line.toString());
                }
            } catch (e: Dynamic) {
                trace('\'${p}\' is not supported');
            }
        }
    }
    static function reportUnicodeVersion()
    {
        var letter = new EReg("\\p{L}", "u");
        var assigned = new EReg("\\P{Cn}", "u");
        if (assigned.match("\u20BE")) {
            trace("Unicode 8.0.0 is supported");
        } else if (assigned.match("\u20BD")) {
            trace("Unicode 7.0.0 is supported");
        } else if (assigned.match("\u061C")) {
            trace("Unicode 6.3.0 is supported");
        } else if (assigned.match("\u20BA")) {
            trace("Unicode 6.2.0 is supported");
        } else if (assigned.match("\u058F")) {
            trace("Unicode 6.1.0 is supported");
        } else if (assigned.match("\u20B9")) {
            trace("Unicode 6.0.0 is supported");
        } else if (assigned.match("\u23E8")) {
            trace("Unicode 5.2.0 is supported");
        } else if (assigned.match("\u2064")) {
            trace("Unicode 5.1.0 is supported");
        } else if (assigned.match("\u0242")) {
            trace("Unicode 5.0.0 is supported");
        }
    }
    static function main()
    {
        {
            var s1 = "\u{3042}";
            trace("[U+3042] charCodeAt(0) = " + StringTools.hex(s1.charCodeAt(0), 4));
            trace("[U+3042] length = " + s1.length);
            trace("[U+3042] length (with EReg) = " + allMatches(~/./u, "\u{3042}").length);
        }
        {
            var s2 = "\u{1F37A}";
            trace("[U+1F37A] charCodeAt(0) = " + StringTools.hex(s2.charCodeAt(0), 4));
            trace("[U+1F37A] length = " + s2.length);
        }
        {
            var s3 = "\u{20BB7}";
            trace("[U+20BB7] charCodeAt(0) = " + StringTools.hex(s3.charCodeAt(0), 4));
            trace("[U+20BB7] length = " + s3.length);
            trace("[U+20BB7] length (with EReg) = " + allMatches(~/./u, "\u{20BB7}").length);
        }
        try {
            var r = new EReg("\\p{L}", "u");
            if (r.match("\u{3042}")) {
                trace("This platform supports \\p{} syntax.");
                if (!r.match("\u{20BB7}")) {
                    trace("The support for non-BMP characters with EReg is incomplete");
                }
                reportUnicodeVersion();
            } else {
                trace("This platform does not support \\p{} syntax.");
            }
        } catch (e: Dynamic) {
            trace("This platform does not support \\p{} syntax.");
        }
        try {
            var r = new EReg("\\x{20BB7}", "u");
            if (r.match("\u{20BB7}")) {
                trace("This platform supports \\x{} syntax.");
            } else {
                trace("This platform does not support \\x{} syntax.");
            }
        } catch (e: Dynamic) {
            trace("This platform does not support \\x{} syntax.");
        }
        try {
            var r = new EReg("[]]", "u");
            if (!r.match("]")) {
                trace("This platform allows empty character class (~/[]/).");
            } else {
                trace("This platform does not interpret empty character class.");
            }
        } catch (e: Dynamic) {
            trace("Parse error in ~/[]]/");
        }
        reportBeginningRx();
        reportEndingRx();
    }
}
