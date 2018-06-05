module App.Indicators.Views.DisplayScreenPresenterM
( DisplayScreenPresenter
, State
, mkDisplayScreenPresenter
, model
, loadIndicators
) where

import Prelude
import Partial.Unsafe (unsafePartial)
import Control.Monad.Except (runExcept)
import Data.Traversable (traverse)
import Data.Either
import Data.List.Types
import Effect (Effect)
import Effect.Ref (Ref)
import Effect.Ref (new, read, write) as Ref
import Foreign (Foreign, F, ForeignError(..), readInt, readNumber, readString, readArray, unsafeFromForeign, fail)
import Foreign.Index ((!))
import Webfu.DOM (window)
import Webfu.DOM.Fetch (win_fetch, responseBodyAsJson, responseOk)
import Webfu.DOM.Promise (Promise, then_, then', catch_, mkReject, mkResolve)
import Webfu.Data.Err (Err(..))
import App.Indicators.Models (BooleanIndProperties, GuageIndProperties, Indicator(..), LabelIndProperties, Orientation(..))



-----------------------------------------------------------
-- STATE
-----------------------------------------------------------

type State = {indicators :: Array Indicator}


type DisplayScreenPresenter =
  { model :: Ref State
  }


mkDisplayScreenPresenter :: State -> Effect DisplayScreenPresenter
mkDisplayScreenPresenter initState = do
  r <- Ref.new initState
  pure { model: r }


model :: DisplayScreenPresenter -> Effect State
model p = Ref.read p.model


-- loadIndicators :: DisplayScreenPresenter -> Effect (Promise (Array Indicator) Err)
-- loadIndicators pr = do
--   w <- window
--   p <- (win_fetch "http://localhost:8080/indicators.json" w)
--        >>= (then' (\r -> if responseOk r
--                            then pure $ responseBodyAsJson r
--                            else mkReject (Err "bla bla")))
--        >>= (then' (\json -> mkResolve $ readIndicatorsAlwaysValid json))
--        -- >>= (then_ (\b -> log ("Ok: " <> (show $ toPoints b))))
--        -- >>= (catch_ (\s -> log $ "err: " <> (show s)))
--   pure p


loadIndicators :: DisplayScreenPresenter -> Effect (Promise Foreign Err)
loadIndicators pr = do
  w <- window
  p <- (win_fetch "http://localhost:8080/indicators.json" w)
       >>= (then' (\r -> if responseOk r
                           then pure $ responseBodyAsJson r
                           else mkReject (Err "bla bla")))
       >>= (then_ (\json -> Ref.write { indicators: readIndicatorsAlwaysValid json } pr.model))
       -- >>= (then_ (\b -> log ("Ok: " <> (show $ toPoints b))))
       -- >>= (catch_ (\s -> log $ "err: " <> (show s)))
  pure p


readIndicatorsAlwaysValid :: Foreign -> Array Indicator
readIndicatorsAlwaysValid v =
  unsafePartial $ fromRight $ readIndicators v


readIndicators :: Foreign -> Either (NonEmptyList ForeignError) (Array Indicator)
readIndicators fVal =
  runExcept $ traverse readIndicator =<< readArray fVal


readIndicator :: Foreign -> F Indicator
readIndicator v = do
  indType <- v ! "indType" >>= readString
  case indType of
    "label"   -> readLabelIndicator v
    "boolean" -> readBooleanIndicator v
    "guage"   -> readGuageIndicator v
    _         -> fail $ ForeignError ("indType: " <> indType <> " is unhandled!")


readOrientation :: Foreign -> F Orientation
readOrientation v = do
  orientation <- readString v
  case orientation of
    "p" -> pure Portrait
    "l" -> pure Landscape
    _ -> fail $ ForeignError ("orientation: '" <> orientation <> "' is unhandled!")


readLabelIndicator :: Foreign -> F Indicator
readLabelIndicator v = do
  indType      <- v ! "indType" >>= readString
  id           <- v ! "id" >>= readString
  x            <- v ! "x" >>= readInt
  y            <- v ! "y" >>= readInt
  width        <- v ! "width" >>= readInt
  height       <- v ! "height" >>= readInt
  rotation     <- v ! "rotation" >>= readNumber
  scale        <- v ! "scale" >>= readNumber
  orientation  <- v ! "orientation" >>= readOrientation
  values       <- v ! "values" >>= readArray >>= (traverse readNumber)

  text         <- v ! "text" >>= readString
  fontSizeInPx <- v ! "fontSizeInPx" >>= readNumber

  pure $ LabelInd
    { indType
    , id
    , x
    , y
    , width
    , height
    , rotation
    , scale
    , orientation
    , values
    , text
    , fontSizeInPx
    }


readBooleanIndicator :: Foreign -> F Indicator
readBooleanIndicator v = do
  indType      <- v ! "indType" >>= readString
  id           <- v ! "id" >>= readString
  x            <- v ! "x" >>= readInt
  y            <- v ! "y" >>= readInt
  width        <- v ! "width" >>= readInt
  height       <- v ! "height" >>= readInt
  rotation     <- v ! "rotation" >>= readNumber
  scale        <- v ! "scale" >>= readNumber
  orientation  <- v ! "orientation" >>= readOrientation
  values       <- v ! "values" >>= readArray >>= (traverse readNumber)

  onValue      <- v ! "onValue" >>= readString
  onColor      <- v ! "onColor" >>= readString
  offValue     <- v ! "offValue" >>= readString
  offColor     <- v ! "offColor" >>= readString

  pure $ BooleanInd
    { indType
    , id
    , x
    , y
    , width
    , height
    , rotation
    , scale
    , orientation
    , values
    , onValue
    , onColor
    , offValue
    , offColor
    }


readGuageIndicator :: Foreign -> F Indicator
readGuageIndicator v = do
  indType      <- v ! "indType" >>= readString
  id           <- v ! "id" >>= readString
  x            <- v ! "x" >>= readInt
  y            <- v ! "y" >>= readInt
  width        <- v ! "width" >>= readInt
  height       <- v ! "height" >>= readInt
  rotation     <- v ! "rotation" >>= readNumber
  scale        <- v ! "scale" >>= readNumber
  orientation  <- v ! "orientation" >>= readOrientation
  values       <- v ! "values" >>= readArray >>= (traverse readNumber)

  desc         <- v ! "desc" >>= readString
  maxValue     <- v ! "maxValue" >>= readNumber

  pure $ GuageInd
    { indType
    , id
    , x
    , y
    , width
    , height
    , rotation
    , scale
    , orientation
    , values
    , desc
    , maxValue
    }