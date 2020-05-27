{-# LANGUAGE ApplicativeDo        #-}
{-# LANGUAGE DataKinds            #-}
{-# LANGUAGE FlexibleContexts     #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE OverloadedLabels     #-}
{-# LANGUAGE TypeOperators        #-}
{-# LANGUAGE UndecidableInstances #-}

{- |
Copyright: (c) 2020 Kowainik
SPDX-License-Identifier: MPL-2.0
Maintainer: Kowainik <xrom.xkov@gmail.com>

@stan@ configurations.
-}

module Stan.Config
    ( -- * Data types
      ConfigP (..)
    , Config
    , PartialConfig
    , Check (..)
    , CheckType (..)
    , CheckFilter (..)
    , CheckScope (..)

      -- * Default
    , defaultConfig

      -- * Final stage
    , finaliseConfig
    ) where

import Trial ((::-), Phase (..), Trial, withTag)

import Stan.Category (Category (..))
import Stan.Core.Id (Id (..))
import Stan.Core.ModuleName (ModuleName (..))
import Stan.Inspection (Inspection (..))
import Stan.Observation (Observation (..))
import Stan.Severity (Severity (..))


data ConfigP (p :: Phase Text) = ConfigP
    { configChecks :: !(p ::- [Check])
    -- , configGroupBy :: !GroupBy
    }

deriving stock instance
    ( Show (p ::- [Check])
    ) => Show (ConfigP p)

deriving stock instance
    ( Eq (p ::- [Check])
    ) => Eq (ConfigP p)

type Config = ConfigP 'Final
type PartialConfig = ConfigP 'Partial

instance Semigroup PartialConfig where
    (<>) :: PartialConfig -> PartialConfig -> PartialConfig
    x <> y = ConfigP
        { configChecks = configChecks x <> configChecks y
        }

data CheckType
    = Include
    | Ignore
    deriving stock (Show, Eq, Enum, Bounded)

data Check = Check
    { checkType   :: !CheckType
    , checkFilter :: !(Maybe CheckFilter)
    , checkScope  :: !(Maybe CheckScope)
    } deriving stock (Show, Eq)

data CheckFilter
    = CheckInspection (Id Inspection)
    | CheckObservation (Id Observation)
    | CheckSeverity Severity
    | CheckCategory Category
    deriving stock (Show, Eq)

data CheckScope
    = CheckScopeFile FilePath
    | CheckScopeDirectory FilePath
    | CheckScopeModule ModuleName
    deriving stock (Show, Eq)

defaultConfig :: PartialConfig
defaultConfig = ConfigP
    { configChecks = withTag "Default" $ pure []
    }

finaliseConfig :: PartialConfig -> Trial Text Config
finaliseConfig config = do
    configChecks <- #configChecks config
    pure ConfigP {..}