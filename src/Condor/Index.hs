{- |
Module : Condor.Index
Copyright : Copyright (C) 2013-2014 Krzysztof Langner
License : The MIT License (MIT)

Maintainer : Krzysztof Langner <klangner@gmail.com>
Stability : alpha
Portability : portable

This module contains functions which create, update and search index. 
Default implementation uses algorithms for english language (stemming, stop words etc.)

Functions in this module (for performance reasons) are based on unicode strings Data.Text.

-}
module Condor.Index 
    ( DocName
    , Index
    , DocContent
    , addDocument
    , addDocTerms
    , emptyIndex
    , search
    , searchTerms
    , termCount
    ) where

import qualified Data.Map as Map
import qualified Data.List as List
import qualified Data.Text as T
import qualified Data.Text.Encoding as E
import Data.Binary
import Condor.Text
import Condor.Language.English.StopWords (isStopWord)
import Condor.Language.English.Porter (stem)


type DocName = T.Text
type DocContent = T.Text
type Term = T.Text

-- | Inverted index
data Index = Index { terms :: Map.Map Term [DocName]
                   }

-- An instance of Binary to encode and decode an IndexParams in binary
instance Binary Index where
     put i = do put (terms i)
     get = do i <- get
              return $ Index i                        

-- An instance of Binary to encode and decode T.Text
instance Binary T.Text where
     put i = do put (E.encodeUtf8 i)
     get = do i <- get
              return $ E.decodeUtf8 i                        


-- | Create empty index. 
-- This index will be configured for english language.
emptyIndex :: Index
emptyIndex = Index Map.empty


-- | Add document to the index.
-- This function uses algorithms for english language to split document content
-- into index terms.
addDocument :: DocName -> DocContent -> Index -> Index
addDocument d c idx = addDocTerms d (splitTerms c) idx


-- | Add document to the index.
-- This function should be used if document content should be splitted into terms
-- with custom algorithms.
addDocTerms :: DocName -> [Term] -> Index -> Index
addDocTerms d c ix = Index (foldl f (terms ix) c)
    where f i t = case Map.lookup t i of 
                    Just a -> Map.insert t (d:a) i
                    Nothing -> Map.insert t [d] i


-- | Search terms given as single string in the index
-- This function uses algorithms for english language to split query into tokens.
search :: Index -> String -> [DocName]
search ix s = searchTerms ix (splitTerms (T.pack s))


-- | Search terms given as array in the index.
-- This function should be used if query should be splitted into terms
-- with custom algorithms
searchTerms :: Index -> [Term] -> [DocName]
searchTerms ix s = List.nub $ foldl (++) [] ys
    where ys = map (findDocs ix) s


-- | Search single term in the index
findDocs :: Index -> Term -> [DocName]
findDocs ix s = case Map.lookup s (terms ix) of
                    Just a -> a
                    Nothing -> []
                 

-- | Get the number of terms in indexs
termCount :: Index -> Int
termCount ix = Map.size (terms ix)


-- | Split text into terms.
-- This function removes stop words and stems words
splitTerms :: T.Text -> [Term]
splitTerms s = map stem (filter (not . isStopWord) t)
    where t = tokenize s
        

