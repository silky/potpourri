{-# OPTIONS  -Wall               #-}
{-# LANGUAGE GADTs               #-}
{-# LANGUAGE RankNTypes          #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Context where

import Data.Void

data Context a where
  None :: Context Void
  Bind :: Context a -> Context (Maybe a)

isEmpty :: Context a -> Bool
isEmpty None = True
isEmpty _    = False


class ValidContext a where
  witness :: Context a

instance ValidContext Void where
  witness = None

instance ValidContext a => ValidContext (Maybe a) where
  witness = Bind witness

diag :: forall f a. (ValidContext a, Functor f) =>
        (forall b. f (Maybe b)) -> (a -> f a)
diag emb = go witness
  where
    go :: forall b. Context b -> b -> f b
    go None     = absurd
    go (Bind c) = maybe emb $ fmap Just . go c

freshNames :: Context a -> [String] -> ([String], a -> String)
freshNames None     xs       = (xs, absurd)
freshNames (Bind c) (x : xs) = (ns, maybe x vars)
  where (ns, vars) = freshNames c xs
