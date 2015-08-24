-- | Fusing programs together
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE PatternGuards #-}
module Icicle.Core.Program.Fusion (
    fusePrograms
  , fuseMultiple
  ) where

import Icicle.Common.Base
import Icicle.Common.Type
import Icicle.Core.Program.Program
import qualified Icicle.Common.Exp.Exp as X

import              P

data FusionError n
 = FusionErrorNotSameType ValType ValType
 | FusionErrorNothingToFuse
 deriving (Show)


-- | Fuse programs together, prefixing each with its name to ensure that the
-- generated program has no name clashes.
-- The two names must be distinct.
fusePrograms :: Ord n => n -> Program n -> n -> Program n -> Either (FusionError n) (Program n)
fusePrograms ln lp rn rp
 = fuseProgramsDistinctNames (prefix ln lp) (prefix rn rp)
 where
  prefix n = renameProgram (NameMod n)


-- | Fuse programs together, assuming they already have no name clashes.
fuseProgramsDistinctNames :: Ord n => Program n -> Program n -> Either (FusionError n) (Program n)
fuseProgramsDistinctNames lp rp
 | input lp /= input rp
 = Left
 $ FusionErrorNotSameType (input lp) (input rp)
 | otherwise
 = return
 $ Program
 { input     = input lp
 , precomps  = precomps  lp <> precomps  rp
 , streams   = streams   lp <> streams   rp
 , reduces   = reduces   lp <> reduces   rp
 , postdate  = postdate'
 , postcomps = postdate'bind <> postcomps lp <> postcomps rp
 , returns   = returns   lp <> returns   rp
 }
 where
  -- Get new date binding for use in postcomputation.
  (postdate', postdate'bind)
  -- If both use the date, we need to bind both values
   | Just ld <- postdate lp
   , Just rd <- postdate rp
   = (Just ld, [(rd, X.XVar ld)])

   -- Only one uses the date
   | Just ld <- postdate lp
   = (Just ld, [])

   | Just rd <- postdate rp
   = (Just rd, [])

   -- Neither use the date
   | otherwise
   = (Nothing, [])


-- | Fuse a list of programs together, prefixing each with its name
fuseMultiple :: Ord n => [(n, Program n)] -> Either (FusionError n) (Program n)
fuseMultiple ps
 = let ps' = fmap (\(n,p) -> renameProgram (NameMod n) p) ps
   in  case ps' of
        [] -> Left FusionErrorNothingToFuse
        (f:fs) -> foldM fuseProgramsDistinctNames f fs
