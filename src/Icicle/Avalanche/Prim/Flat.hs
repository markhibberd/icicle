-- | Flat primitives - after the folds are removed
{-# LANGUAGE NoImplicitPrelude #-}
module Icicle.Avalanche.Prim.Flat (
      Prim   (..)
    , PrimProject (..)
    , PrimUnsafe    (..)
    , PrimUpdate    (..)
    , typeOfPrim
  ) where

import              Icicle.Internal.Pretty
import              Icicle.Common.Type
import qualified    Icicle.Common.Exp.Prim.Minimal as Min

import              P


-- | Primitives for flattened avalanche programs
-- Folds are converted to imperative accessors, loops and so on.
data Prim
 -- | Include a bunch of basic things common across languages
 = PrimMinimal    Min.Prim
 -- | Safe projections
 | PrimProject         PrimProject

 -- | Unsafe projections
 | PrimUnsafe          PrimUnsafe

 -- | Safe updates
 | PrimUpdate          PrimUpdate
 deriving (Eq, Ord, Show)


data PrimProject
 = PrimProjectArrayLength ValType
 | PrimProjectMapLength   ValType ValType
 | PrimProjectMapLookup   ValType ValType
 | PrimProjectOptionIsSome ValType
 deriving (Eq, Ord, Show)


data PrimUnsafe
 = PrimUnsafeArrayIndex ValType
 | PrimUnsafeMapIndex   ValType ValType
 | PrimUnsafeOptionGet  ValType
 deriving (Eq, Ord, Show)

data PrimUpdate
 = PrimUpdateMapPut  ValType ValType
 deriving (Eq, Ord, Show)




-- | A primitive always has a well-defined type
typeOfPrim :: Prim -> Type
typeOfPrim p
 = case p of
    -- All arithmetics are int to int for now
    PrimMinimal m
     -> Min.typeOfPrim m

    PrimProject (PrimProjectArrayLength a)
     -> FunT [funOfVal (ArrayT a)] IntT

    PrimProject (PrimProjectMapLength a b)
     -> FunT [funOfVal (MapT a b)] IntT

    PrimProject (PrimProjectMapLookup a b)
     -> FunT [funOfVal (MapT a b), funOfVal a] (OptionT b)


    PrimProject (PrimProjectOptionIsSome a)
     -> FunT [funOfVal (OptionT a)] BoolT


    PrimUnsafe  (PrimUnsafeArrayIndex a)
     -> FunT [funOfVal (ArrayT a), funOfVal IntT] a

    PrimUnsafe  (PrimUnsafeMapIndex a b)
     -> FunT [funOfVal (MapT a b), funOfVal IntT] (PairT a b)

    PrimUnsafe  (PrimUnsafeOptionGet a)
     -> FunT [funOfVal (OptionT a)] a

    PrimUpdate  (PrimUpdateMapPut a b)
     -> FunT [funOfVal (MapT a b), funOfVal a, funOfVal b] (MapT a b)


-- Pretty -------------

instance Pretty Prim where
 pretty (PrimMinimal m) = pretty m

 pretty (PrimProject (PrimProjectArrayLength a))
  = text "Array_length#" <+> brackets (pretty a)
 pretty (PrimProject (PrimProjectMapLength a b))
  = text "Map_length#" <+> brackets (pretty a) <+> brackets (pretty b)
 pretty (PrimProject (PrimProjectMapLookup a b))
  = text "Map_lookup#" <+> brackets (pretty a) <+> brackets (pretty b)
 pretty (PrimProject (PrimProjectOptionIsSome a))
  = text "Option_isSome#" <+> brackets (pretty a)


 pretty (PrimUnsafe (PrimUnsafeArrayIndex a))
  = text "unsafe_Array_index#" <+> brackets (pretty a)

 pretty (PrimUnsafe (PrimUnsafeMapIndex a b))
  = text "unsafe_Map_index#" <+> brackets (pretty a) <+> brackets (pretty b)

 pretty (PrimUnsafe (PrimUnsafeOptionGet a))
  = text "unsafe_Option_get#" <+> brackets (pretty a)

 pretty (PrimUpdate (PrimUpdateMapPut a b))
  = text "Map_put#" <+> brackets (pretty a) <+> brackets (pretty b)
