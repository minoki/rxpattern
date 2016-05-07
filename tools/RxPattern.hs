module RxPattern where

infixl 6 <&>
infixl 5 <|>

data PatternPrec = Atom
                 | Term
                 | Alternative
                 | Disjunction
                 deriving (Eq,Ord,Read,Show,Enum,Bounded)

data Pattern = Pattern { patternPrec :: PatternPrec
                       , getPatternString :: String
                       }
             deriving (Eq,Show)

makeAtom = Pattern Atom
makeTerm = Pattern Term
makeAlternative = Pattern Alternative
makeDisjunction = Pattern Disjunction
empty = makeAlternative ""
never = makeAtom "[]"

patternAs :: PatternPrec -> Pattern -> String
patternAs prec (Pattern prec' s) | prec >= prec' = s
                                 | otherwise = "(?:" ++ s ++ ")"

asAtom = patternAs Atom
asTerm = patternAs Term
asAlternative = patternAs Alternative
asDisjunction = patternAs Disjunction

(<&>) :: Pattern -> Pattern -> Pattern
p1 <&> p2 | p1 == never || p2 == never = never
          | otherwise = Pattern Alternative (asAlternative p1 ++ asAlternative p2)

(<|>) :: Pattern -> Pattern -> Pattern
p1 <|> p2 | p1 == never = p2
          | p2 == never = p1
          | otherwise = Pattern Disjunction (asDisjunction p1 ++ "|" ++ asDisjunction p2)

option,any,some :: Pattern -> Pattern
option p | p == never = empty
         | otherwise = Pattern Term (asAtom p ++ "?")
any p | p == never = empty
      | otherwise = Pattern Term (asAtom p ++ "*")
some p | p == never = p
       | otherwise = Pattern Term (asAtom p ++ "+")

escapeChar :: Char -> String
escapeChar c | c `elem` "^$\\.*+?()[]{}|-" = ['\\', c]
             | c == '\n' = "\\n"
             | c == '\r' = "\\r"
             | c == '\t' = "\\t"
             | otherwise = [c]

escapeCharInSet :: Char -> String
escapeCharInSet '-' = "\\-"
escapeCharInSet c = escapeChar c
