{-# LANGUAGE NoImplicitPrelude #-}
module Icicle.Source.Query (
    QueryTop  (..)
  , Query     (..)
  , Context   (..)
  , Fold      (..)
  , Agg       (..)
  , Exp       (..)
  , Op        (..)
  , Sort      (..)
  ) where

-- import                  Icicle.Internal.Pretty

import                  P


data QueryTop n
 = QueryTop
 { feature  :: n
 , query    :: Query n }
 deriving (Show, Eq, Ord)

data Query n
 = Query
 { contexts :: [Context n] 
 , final    :: Exp n }
 deriving (Show, Eq, Ord)

data Context n
 = Windowed
 | Latest Int
 | GroupBy  (Exp n)
 | Distinct (Exp n)
 | Filter   (Exp n)
 | LetFold  (Fold n)
 | Let  (Maybe Sort) n   (Exp n)
 deriving (Show, Eq, Ord)

data Fold n
 = Fold
 { foldBind :: n
 , foldInit :: Exp n
 , foldWork :: Exp n
 , foldType :: FoldType }
 deriving (Show, Eq, Ord)

data FoldType
 = FoldTypeFoldl1
 -- | FoldTypeFoldl
 deriving (Show, Eq, Ord)

data Sort = Stream | Aggregate
 deriving (Show, Eq, Ord)


data Agg n
 = Count
 -- | Max (Exp n)
 -- | Average (Exp n)
 -- | Sum (Exp n)
 | Newest (Exp n)
 | Oldest (Exp n)
 deriving (Show, Eq, Ord)

data Exp n
 = Var n
 | Agg (Agg n)
 | Nested (Query n)
 | Op Op [Exp n]
 deriving (Show, Eq, Ord)

data Op
 = Div
 deriving (Show, Eq, Ord)

