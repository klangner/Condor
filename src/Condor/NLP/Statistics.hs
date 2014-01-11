{- |
Module : Condor.NLP.Statistics
Copyright : Copyright (C) 2013-2014 Krzysztof Langner
License : BSD3

Maintainer : Krzysztof Langner <klangner@gmail.com>
Stability : alpha
Portability : portable

This module counts different statistics on the text

-}
module Condor.NLP.Statistics 
    ( countWords
    , wordFreq
    ) where

import Prelude hiding(length)
import Data.Text
import Condor.NLP.Tokenizer
import qualified Data.List as List


-- | Count number of words in the text.
--
-- > countWords (T.pack "one two three") == 3
countWords :: Text -> Int    
countWords = List.length . getWords . tokenize

-- | Count word frequency
--
-- > wordFreq (T.pack "one two, three one") == [("one", 2), ("two", 1), ("three", 1)]
wordFreq :: Text -> [(Text, Int)]
wordFreq a = [(List.head xs, List.length xs) | xs <- List.group tokens]
    where tokens = List.sort $ (foldCase . getWords . tokenize) a
