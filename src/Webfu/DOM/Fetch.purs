module Webfu.DOM.Fetch
  ( Response
  , responseOk
  , responseStatus
  , responseStatusText
  , responseBodyAsText
  , win_fetch
  ) where

import Prelude (Unit)
import Data.Function.Uncurried (Fn1, runFn1)
import Control.Monad.Eff (kind Effect, Eff)
import Webfu.DOM.Core
import Webfu.DOM.Promise (Promise)


--------------------------------------------------------------------------------
-- Response
--------------------------------------------------------------------------------
foreign import data Response :: Type

foreign import responseOkImpl :: Fn1 Response Boolean
responseOk :: Response -> Boolean
responseOk r = runFn1 responseOkImpl r

foreign import responseStatusImpl :: Fn1 Response Int
responseStatus :: Response -> Int
responseStatus r = runFn1 responseStatusImpl r

foreign import responseStatusTextImpl :: Fn1 Response String
responseStatusText :: Response -> String
responseStatusText r = runFn1 responseStatusTextImpl r

foreign import responseBodyAsTextImpl :: Fn1 Response (Promise String Unit)
responseBodyAsText :: Response -> Promise String Unit
responseBodyAsText r = runFn1 responseBodyAsText r


--------------------------------------------------------------------------------
-- Fetch
--------------------------------------------------------------------------------
foreign import win_fetch_foreign :: forall eff. String -> Window -> Eff (dom :: DOM | eff) (Promise Response TypeError)

win_fetch :: forall eff. String -> Window -> Eff (dom :: DOM | eff) (Promise Response TypeError)
win_fetch url w = win_fetch_foreign url w


