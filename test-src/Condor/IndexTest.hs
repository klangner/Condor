module Condor.IndexTest (testCases) where

import Condor.Index
import Test.HUnit


testCases :: [(String, Test)]
testCases = [("Index", t) | t <- tests]

tests :: [Test]
tests = [ TestCase $ prop_empty
        , TestCase $ prop_size ("doc1", "one two three") 3
        --, TestCase $ prop_search ("doc1", "one two three") "two" ["doc1"]
        ]
         
prop_empty :: Assertion         
prop_empty = assertEqual "Empty index has 0 size" 0 (size empty)          
         
prop_search :: (DocName, Text) -> String -> [DocName] -> Assertion         
prop_search (d, c) s e = assertEqual ("Search " ++ s) e (search idx s)
    where idx = add d c empty          
         
prop_size :: (DocName, Text) -> Int -> Assertion
prop_size (d, c) n = assertEqual "Index size" n (size $ add d c empty)         
    