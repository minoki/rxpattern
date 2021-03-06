# RxPattern

This library provides a human-friendly way to write complex regular expression patterns.

The patterns generated by this library always work with Unicode code points, even if the target is JavaScript or C#.

## Examples

```haxe
var pattern1 = (RxPattern.Char("a") | RxPattern.Char("b")).many();
var rx1 : EReg = pattern1.build();
rx1.match("abaab"); // => true
```

```haxe
var pattern2 = RxPattern.String("gr")
               >> (RxPattern.Char("a") | RxPattern.Char("e"))
               >> RxPattern.String("y");
var rx2 = pattern2.build();
rx2.match("grey"); // => true
rx2.match("gray"); // => true
```

```haxe
var pattern3 = RxPattern.AtStart
               >> RxPattern.String("colo")
               >> RxPattern.Char("u").option()
               >> RxPattern.String("r")
               >> RxPattern.AtEnd;
var rx3 = pattern3.build();
rx3.match("color"); // => true
rx3.match("colour"); // => true
rx3.match("color\n"); // => false
rx3.match("\ncolour"); // => false
```

```haxe
var wordStart = GeneralCategory.Letter | RxPattern.Char("_");
var wordChar = wordStart | GeneralCategory.Number;
var word = wordStart >> wordChar.many();
var pattern4 = RxPattern.AtStart >> word >> RxPattern.AtEnd;
var rx4 = pattern4.build();
rx4.match("function"); // => true
rx4.match("int32_t"); // => true
rx4.match("\u3042"); // => true
rx4.match("24hours"); // => false
```

## Supported Target Platforms

- Neko VM (UTF-8, PCRE)
- PHP (UTF-8, PCRE)
- C++ (UTF-8, PCRE)
- Lua (UTF-8, PCRE)
- JavaScript (UTF-16, native RegExp)
- C# (UTF-16, [System.Text.RegularExpressions.Regex](https://msdn.microsoft.com/en-us/library/az24scfc%28v=vs.110%29.aspx))
- Java (UTF-16, [java.util.regex](http://docs.oracle.com/javase/8/docs/api/java/util/regex/Pattern.html))
- Python (UTF-32, [re](https://docs.python.org/3/library/re.html#re-syntax))

## Manual

This library provides the following classes:

- `rxpattern.RxPattern`
- `rxpattern.CharSet`
- `rxpattern.GeneralCategory`

### Basic Patterns

- `RxPattern.AnyCodePoint : RxPattern`
    - Matches any Unicode code point, i.e. U+0000 to U+10FFFF (may or may not excluding surrogates).
- `RxPattern.Char(c : String) : RxPattern`
    - Matches a Unicode code point represented by the string `c`.
    - `c` must consist of a single code point.
- `RxPattern.String(s : String) : RxPattern`
    - Matches a string.
	- Special characters are escaped.
- `RxPattern.LineTerminator : RxPattern`
    - Matches a line terminator.
	- The following sequence / characters are treated as a line terminator:
        - CR LF
        - CR
        - LF
        - U+2028 LINE SEPARATOR
        - U+2029 PARAGRAPH SEPARATOR
        - TODO: Also include U+0085 NEL?
- `RxPattern.Empty : RxPattern`
    - Matches an empty string.

### Binary Operators

The variables `pattern1` and `pattern2` are of type `RxPattern`.

- `pattern1 >> pattern2`
    - Matches the sequence of `pattern`s.
- `pattern1 | pattern2`
    - Matches `pattern1` or `pattern2`.
- `pattern1.then(pattern2) : RxPattern`
    - Same as `pattern1 >> pattern2`.
- `pattern1.or(pattern2) : RxPattern`
    - Same as `pattern1 | pattern2`.
- `RxPattern.sequence(patterns : Iterable<RxPattern>) : RxPattern`
    - Applies `>>` to the elements of `patterns`.
	- Returns `RxPattern.Empty` if `patterns` is empty.
- `RxPattern.choice(patterns : Iterable<RxPattern>) : RxPattern`
    - Applies `|` to the elements of `patterns`.
	- Returns `RxPattern.Never` if `patterns` is empty.

### Quantifiers

The variable `pattern` is of type `RxPattern`.

- `pattern.option() : RxPattern`
    - Matches `pattern` or an empty string.
	- Equivalent to `pattern | RxPattern.Empty`.
- `pattern.many() : RxPattern`
    - Matches zero or more repetition of `pattern`.
- `pattern.many1() : RxPattern`
    - Matches one or more repetition of `pattern`.

TODO: Add methods for the quantifiers `{m}`, `{m,}` and `{m,n}`.

### Assertions

- `RxPattern.AtStart : RxPattern`
    - Matches at the start of the string.
- `RxPattern.AtEnd : RxPattern`
    - Matches at the end of the string.
- `RxPattern.LookAhead(pattern : RxPattern) : RxPattern`
    - Positive look ahead.
- `RxPattern.NotFollowedBy(pattern : RxPattern) : RxPattern`
    - Negative look ahead.
- `RxPattern.Never : RxPattern`
    - Never matches anything.
	- Equivalent to `RxPattern.NotFollowedBy(RxPattern.Empty)`.

### Grouping

- `RxPattern.Group(pattern : RxPattern) : RxPattern`
    - Creates a capture group.

Since non-capturing groups are automatically created when necessary, there is no function to explicitly create them.

### Accessing Pattern String and EReg object

The variable `pattern` is of type `RxPattern`.

- `pattern.build(options = "u") : EReg`
    - Build an `EReg` object with `pattern`.
- `pattern.get() : String`
    - Get the pattern string.
- `RxPattern.buildEReg(pattern : RxPattern, options = "u") : EReg`
    - Same as `pattern.build(options)`
- `RxPattern.getPattern(pattern : RxPattern) : String`
    - Same as `pattern.get()`

### Character Set

The variable `charset` is of type `CharSet`.

- `RxPattern.CharSet(set : CharSet) : RxPattern`
- `RxPattern.NotInSet(set : CharSet) : RxPattern`
- `CharSet.empty() : CharSet`
    - Returns an empty character set.
- `CharSet.singleton(c : String) : CharSet`
    - Returns a character set with one element `c`.
- `CharSet.fromString(s : String) : CharSet`
    - Returns a character set with elements from the string `s`.
- `CharSet.intersection(a : CharSet, b : CharSet) : CharSet`
- `CharSet.union(a : CharSet, b : CharSet) : CharSet`
- `CharSet.difference(a : CharSet, b : CharSet) : CharSet`
- `charset.has(c : String) : Bool`
    - The string `c` must consist of a single code point.
- `charset.add(c : String) : Void`
    - The string `c` must consist of a single code point.
- `charset.remove(c : String) : Void`
    - The string `c` must consist of a single code point.
- `charset.hasCodePoint(x : Int) : Bool`
- `charset.addCodePoint(x : Int) : Void`
- `charset.removeCodePoint(x : Int) : Void`
- `charset.codePointIterator() : Iterator<Int>`
- `charset.length : Int`

### Unicode General Category

This library provides `RxPattern` values corresponding Unicode general categories.

If Unicode properties (or, `\p{}` patterns) are available, they are used.
Otherwise, patterns generated from the data of Unicode 8.0.0 are used.

- `GeneralCategory.Letter : RxPattern`
- `GeneralCategory.Uppercase_Letter : RxPattern`
- `GeneralCategory.Lowercase_Letter : RxPattern`
- `GeneralCategory.Titlecase_Letter : RxPattern`
- `GeneralCategory.Cased_Letter : RxPattern`
- `GeneralCategory.Modifier_Letter : RxPattern`
- `GeneralCategory.Other_Letter : RxPattern`
- `GeneralCategory.Mark : RxPattern`
- `GeneralCategory.Nonspacing_Mark : RxPattern`
- `GeneralCategory.Spacing_Mark : RxPattern`
- `GeneralCategory.Enclosing_Mark : RxPattern`
- `GeneralCategory.Number : RxPattern`
- `GeneralCategory.Decimal_Number : RxPattern`
- `GeneralCategory.Letter_Number : RxPattern`
- `GeneralCategory.Other_Number : RxPattern`
- `GeneralCategory.Punctuation : RxPattern`
- `GeneralCategory.Connector_Punctuation : RxPattern`
- `GeneralCategory.Dash_Punctuation : RxPattern`
- `GeneralCategory.Open_Punctuaiton : RxPattern`
- `GeneralCategory.Close_Punctuation : RxPattern`
- `GeneralCategory.Initial_Punctuation : RxPattern`
- `GeneralCategory.Final_Punctuation : RxPattern`
- `GeneralCategory.Other_Punctuation : RxPattern`
- `GeneralCategory.Symbol : RxPattern`
- `GeneralCategory.Math_Symbol : RxPattern`
- `GeneralCategory.Currency_Symbol : RxPattern`
- `GeneralCategory.Modifier_Symbol : RxPattern`
- `GeneralCategory.Other_Symbol : RxPattern`
- `GeneralCategory.Separator : RxPattern`
- `GeneralCategory.Space_Separator : RxPattern`
- `GeneralCategory.Line_Separator : RxPattern`
- `GeneralCategory.Paragraph_Separator : RxPattern`
- `GeneralCategory.Other : RxPattern`
- `GeneralCategory.Control : RxPattern`
- `GeneralCategory.Format : RxPattern`
- `GeneralCategory.Private_Use : RxPattern`

### Raw Pattern Strings

The terms "Disjunction", "Alternative", "Term" and "Atom" correspond to the rules in [Typical Regular Expression Syntax](#typical-regular-expression-syntax).

The variable `pattern` is of type `RxPattern`.

- `RxPattern.Disjunction(s : String) : RxPattern`
    - Returns a `RxPattern` value with given pattern string.
- `RxPattern.Alternative(s : String) : RxPattern`
    - Returns a `RxPattern` value with given pattern string.
	- The string `s` must be able to be used as an Alternative: that is, the pattern `s + "a"` matches `s` and the character `a`.
- `RxPattern.Term(s : String) : RxPattern`
    - Returns a `RxPattern` value with given pattern string.
	- The string `s` must be able to be used as a Term.
- `RxPattern.Atom(s : String) : RxPattern`
    - Returns a `RxPattern` value with given pattern string.
	- The string `s` must be able to be used as an Atom: that is, the pattern `s + "*"` does mean zero or more repetition of `s`.
- `pattern.toDisjunction() : String`
    - Returns a pattern string that can be used as a Disjunction. This is same as `pattern.get()`.
- `pattern.toAlternative() : String`
    - Return a pattern string that can be used as an Alternative.
    - The string is surrounded by a non-capturing group if necessary.
- `pattern.toTerm() : String`
    - Return a pattern string that can be used as a Term.
    - The string is surrounded by a non-capturing group if necessary.
- `pattern.toAtom() : String`
    - Return a pattern string that can be used as an Atom.
    - The string is surrounded by a non-capturing group if necessary.

## Appendix

### Typical Regular Expression Syntax

        Pattern ::= Disjunction
    Disjunction ::= Alternative
                  | Alternative "|" Disjunction
    Alternative ::= ""
                  | Alternative Term
           Term ::= Assertion
                  | Atom
                  | Atom Quantifier
      Assertion ::= "^" | "$"
                  | "(?=" Disjunction ")"
                  | "(?!" Disjunction ")"
     Quantifier ::= "*" | "+" | "?"
           Atom ::= PatternCharacter
                  | "\" AtomEscape
                  | CharacterClass
                  | "(" Disjunction ")"
                  | "(?:" Disjunction ")"

