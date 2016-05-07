import Control.Applicative
import Numeric
import Control.Arrow
import Data.Char (ord,chr,toUpper)
import Data.List
import System.Environment
import System.Exit
import System.IO
import Data.Word
import qualified RxPattern as Rx

leftPad :: Char -> Int -> String -> String
leftPad pad n s | length s < n = leftPad pad n (pad:s)
                | otherwise = s

showHEX :: (Integral a, Show a) => a -> ShowS
showHEX = (map toUpper .) . showHex

data UnicodeEscape a = UnicodeEscape { escapeAtom :: a -> String, escapeSetElement :: a -> String }

escapeStyleES5 :: UnicodeEscape Word16
escapeStyleES5 = UnicodeEscape (f Rx.escapeChar) (f Rx.escapeCharInSet)
  where f :: (Char -> String) -> Word16 -> String
        f a c | 0x20 <= c && c < 0x7f = a (chr $ fromIntegral c)
              | otherwise = "\\u" ++ leftPad '0' 4 (showHEX c "")

escapeStyleES6 :: UnicodeEscape Word32
escapeStyleES6 = UnicodeEscape (f Rx.escapeChar) (f Rx.escapeCharInSet)
  where f a c | 0x20 <= c && c < 0x7f = a (chr $ fromIntegral c)
              | 0xD800 <= c && c <= 0xDFFF = error "unexpected surrogate pair"
              | c < 0x10000 = "\\u" ++ leftPad '0' 4 (showHEX c "")
              | otherwise = "\\u{" ++ showHEX c "}"

escapeStylePerl :: UnicodeEscape Word32
escapeStylePerl = UnicodeEscape (f Rx.escapeChar) (f Rx.escapeCharInSet)
  where f a c | 0x20 <= c && c < 0x7f = a (chr $ fromIntegral c)
              | 0xD800 <= c && c <= 0xDFFF = error "unexpected surrogate pair"
              | otherwise = "\\x{" ++ showHEX c "}"

escapeStylePython :: UnicodeEscape Word32
escapeStylePython = UnicodeEscape (f Rx.escapeChar) (f Rx.escapeCharInSet)
  where f a c | 0x20 <= c && c < 0x7f = a (chr $ fromIntegral c)
              | 0xD800 <= c && c <= 0xDFFF = error "unexpected surrogate pair"
              | c < 0x10000 = "\\u" ++ leftPad '0' 4 (showHEX c "")
              | otherwise = "\\U" ++ leftPad '0' 8 (showHEX c "")

showRange :: Integral a => UnicodeEscape a -> a -> a -> String
showRange style x y | x == y = escapeSetElement style x
                    | x + 1 == y = escapeSetElement style x ++ escapeSetElement style y
                    | otherwise = escapeSetElement style x ++ "-" ++ escapeSetElement style y

buildRangeRx :: (Integral a, Show a) => UnicodeEscape a -> [(a,a)] -> Rx.Pattern
buildRangeRx _ [] = Rx.makeAlternative ""
buildRangeRx style [(x,y)] | x == y = Rx.makeAtom $ escapeAtom style x
buildRangeRx style xs = Rx.makeAtom $ "[" ++ concatMap (uncurry $ showRange style) xs ++ "]"

setToRanges :: (Enum a, Eq a) => [a] -> [(a,a)]
setToRanges [] = []
setToRanges [c] = [(c,c)]
setToRanges (x:xs) = loop x x xs
  where loop x y [] = [(x,y)]
        loop x y (z:zs) | z == succ y = loop x z zs
                        | otherwise = (x,y) : loop z z zs

parseUnicodeDataLine :: String -> Maybe (Word32,String,String)
parseUnicodeDataLine s
  | (codepoint_s,';':xs) <- span (/= ';') s
  , (description,';':ys) <- span (/= ';') xs
  , (cat,';':_) <- span (/= ';') ys
  , [(codepoint,"")] <- readHex codepoint_s = Just (codepoint,description,cat)
  | otherwise = Nothing

parseUnicodeData :: [String] -> [(Word32,String)]
parseUnicodeData [] = []
parseUnicodeData (x:xs) | Just (xp,xd,xc) <- parseUnicodeDataLine x
                        , isSuffixOf ", First>" xd
                        , y:ys <- xs
                        , Just (yp,yd,yc) <- parseUnicodeDataLine y
                        , isSuffixOf ", Last>" yd
                        = if xc /= yc
                          then error "General Category mismatch"
                          else [(cp,xc) | cp <- [xp..yp]]++parseUnicodeData ys
                        | Just (xp,xd,xc) <- parseUnicodeDataLine x
                        = (xp,xc):parseUnicodeData xs
                        | otherwise = error "failed to parse"

encodeUtf16 :: Word32 -> Either Word16 (Word16,Word16)
encodeUtf16 x | x < 0x10000 = Left $ fromIntegral x
              | otherwise = let xm = x - 0x10000
                                (hi',lo') = xm `divMod` 0x400
                            in Right (fromIntegral (0xD800 + hi'), fromIntegral (0xDC00 + lo'))

partitionEither :: [Either a b] -> ([a],[b])
partitionEither = foldr (either (first . (:)) (second . (:))) ([],[])

eqFst :: Eq a => (a,b) -> (a,b) -> Bool
eqFst x y = fst x == fst y

eqSnd :: Eq b => (a,b) -> (a,b) -> Bool
eqSnd x y = snd x == snd y

-- groupByFst [(1,2),(1,3),(1,5),(2,3),(3,1),(3,7)]
-- ->[(1,[2,3,5]),(2,[3]),(3,[1,7])]
groupByFst :: Eq a => [(a,b)] -> [(a,[b])]
groupByFst [] = []
groupByFst ((s,t):xs) | (s',t'):_ <- xs
                      , s == s' = let (u,v):ys = groupByFst xs
                                  in (u,t:v):ys
                      | otherwise = (s,[t]):groupByFst xs

groupBySnd :: Eq b => [(a,b)] -> [([a],b)]
groupBySnd = map swap . groupByFst . map swap
  where swap (x,y) = (y,x)

isLetter = (== 'L') . head

compareByFst :: (Ord a, Ord b) => (a,b) -> (a,b) -> Ordering
compareByFst (x,y) (x',y') = case compare x x' of
  EQ -> compare y y'
  c -> c

compareBySnd :: (Ord a, Ord b) => (a,b) -> (a,b) -> Ordering
compareBySnd (x,y) (x',y') = case compare y y' of
  EQ -> compare x x'
  c -> c


showHxStringS :: String -> ShowS
showHxStringS xs r = '"' : loop xs ('"' : r)
   where loop [] s = s
         loop ('\\':xs) s = '\\' : '\\' : loop xs s
         loop ('"':xs) s = '\\' : '"' : loop xs s
         loop (c:xs) s = c : loop xs s

showRxPattern :: Rx.Pattern -> String
showRxPattern (Rx.Pattern Rx.Atom pat) = "RxPattern.Atom(" ++ showHxStringS pat ")"
showRxPattern (Rx.Pattern Rx.Term pat) = "RxPattern.Term(" ++ showHxStringS pat ")"
showRxPattern (Rx.Pattern Rx.Alternative pat) = "RxPattern.Alternative(" ++ showHxStringS pat ")"
showRxPattern (Rx.Pattern Rx.Disjunction pat) = "RxPattern.Disjunction(" ++ showHxStringS pat ")"

bmpToPattern :: UnicodeEscape Word16 -> [Word16] -> Rx.Pattern
bmpToPattern style codePoints = buildRangeRx style $ setToRanges codePoints

surrogatesToPattern :: UnicodeEscape Word16 -> [(Word16,Word16)] -> Rx.Pattern
surrogatesToPattern style surrogates = foldl' (Rx.<|>) Rx.never $ map (uncurry (Rx.<&>) . (buildRangeRx style *** buildRangeRx style)) surrogateGroups
  where surrogateGroupsByHigh :: [(Word16,[(Word16,Word16)])]
        surrogateGroupsByHigh = map (second setToRanges) $ groupByFst surrogates
        surrogateGroups :: [([(Word16,Word16)],[(Word16,Word16)])]
        surrogateGroups = sortBy compareByFst $ map (first setToRanges) $ groupBySnd $ sortBy compareBySnd surrogateGroupsByHigh

codePointsToPattern :: UnicodeEscape Word32 -> [Word32] -> Rx.Pattern
codePointsToPattern style codePoints = buildRangeRx style $ setToRanges codePoints

codePointsToPatternWithSurrogates :: UnicodeEscape Word16 -> [Word32] -> Rx.Pattern
codePointsToPatternWithSurrogates style codePoints
  = buildRangeRx style (setToRanges bmp) Rx.<|> surrogatesToPattern style surrogates
  where (bmp,surrogates) = partitionEither $ map encodeUtf16 codePoints

codePointsToHxCode :: String -> Rx.Pattern -> [Word32] -> String
codePointsToHxCode name byPropAtom codePoints
  | all (< 0x10000) codePoints = "    #if (js || cs || python)\n" ++
                                 "        public static var " ++ name ++ "(default, null) = " ++
                                 showRxPattern (codePointsToPatternWithSurrogates escapeStyleES5 codePoints) ++ ";\n" ++
                                 "    #elseif cpp\n" ++
                                 "        public static var " ++ name ++ "(default, null) = " ++
                                 showRxPattern (codePointsToPattern escapeStylePerl codePoints) ++ ";\n" ++
                                 "    #else\n" ++
                                 "        public static var " ++ name ++ "(default, null) = " ++ showRxPattern byPropAtom ++ ";\n" ++
                                 "    #end\n"
  | otherwise                  = "    #if (js || cs)\n" ++
                                 "        public static var " ++ name ++ "(default, null) = " ++
                                 showRxPattern (codePointsToPatternWithSurrogates escapeStyleES5 codePoints) ++ ";\n" ++
                                 "    #elseif python\n" ++
                                 "        public static var " ++ name ++ "(default, null) = " ++
                                 showRxPattern (codePointsToPattern escapeStylePython codePoints) ++ ";\n" ++
                                 "    #elseif cpp\n" ++
                                 "        public static var " ++ name ++ "(default, null) = " ++
                                 showRxPattern (codePointsToPattern escapeStylePerl codePoints) ++ ";\n" ++
                                 "    #else\n" ++
                                 "        public static var " ++ name ++ "(default, null) = " ++ showRxPattern byPropAtom ++ ";\n" ++
                                 "    #end\n"

main = do args <- getArgs
          let unicodeDataFile | file:_ <- args = file
                              | otherwise = "UnicodeData.txt"
          codePoints <- parseUnicodeData <$> lines <$> readFile unicodeDataFile
          let cat name abbr d = codePointsToHxCode name (Rx.makeAtom $ "\\p{" ++ abbr ++ "}") (map fst $ filter (d . snd) codePoints)
              major name abbr = cat name abbr (isPrefixOf abbr)
              minor name abbr = cat name abbr (== abbr)
          let def = concat [major "Letter"           "L"
                           ,minor "Uppercase_Letter" "Lu"
                           ,minor "Lowercase_Letter" "Ll"
                           ,minor "Titlecase_Letter" "Lt"
                           ,cat   "Cased_Letter"     "LC" (\c -> c == "Lu" || c == "Ll" || c == "Lt")
                           ,minor "Modifier_Letter"  "Lm"
                           ,minor "Other_Letter"     "Lo"

                           ,major "Mark"            "M"
                           ,minor "Nonspacing_Mark" "Mn"
                           ,minor "Spacing_Mark"    "Ms"
                           ,minor "Enclosing_Mark"  "Me"

                           ,major "Number"         "N"
                           ,minor "Decimal_Number" "Nd"
                           ,minor "Letter_Number"  "Nl"
                           ,minor "Other_Number"   "No"

                           ,major "Punctuation"           "P"
                           ,minor "Connector_Punctuation" "Pc"
                           ,minor "Dash_Punctuation"      "Pd"
                           ,minor "Open_Punctuation"      "Ps"
                           ,minor "Close_Punctuation"     "Pe"
                           ,minor "Initial_Punctuation"   "Pi"
                           ,minor "Final_Punctuation"     "Pf"
                           ,minor "Other_Punctuation"     "Po"

                           ,major "Symbol"          "S"
                           ,minor "Math_Symbol"     "Sm"
                           ,minor "Currency_Symbol" "Sc"
                           ,minor "Modifier_Symbol" "Sk"
                           ,minor "Other_Symbol"    "So"

                           ,major "Separator"           "Z"
                           ,minor "Space_Separator"     "Zs"
                           ,minor "Line_Separator"      "Zl"
                           ,minor "Paragraph_Separator" "Zp"

                           ,cat   "Other"       "C" (\c -> isPrefixOf "C" c && c /= "Cs")
                           ,minor "Control"     "Cc"
                           ,minor "Format"      "Cf"
                           -- ,minor "Surrogate" "Cs"
                           ,minor "Private_Use" "Co"
                           -- ,minor "Unassigned"  "Cn"
                           ]

          putStr (
            "// This file was generated by GenGeneralCategory.hs\n" ++
            "package rxpattern;\n" ++
            "import rxpattern.RxPattern;\n" ++
            "class GeneralCategory\n" ++
            "{\n" ++
            def ++
            "}\n"
            )
