module App.Indicators.Views.DisplayScreenView (
  mkView
) where

import Prelude
import Effect (Effect)
import Effect.Console (log)
import Effect.Ref (Ref)
import Data.Array (find, findIndex, updateAt)
import Data.Number as Number
import Data.Maybe (Maybe(..), maybe)
import Webfu.DOM
import Webfu.DOM.Promise
import Webfu.Mithril (VNode, Component, mkComponent, raise, redraw)
import Webfu.Mithril.HTML
import App.Indicators.Views.DisplayScreenPresenterM
import App.Indicators.Views.Indicators (indRender)

-----------------------------------------------------------
-- STATE
-----------------------------------------------------------

-- type State = {indicators :: Array IndicatorCtl}
--
-- state :: State
-- state = {indicators: getIndicators unit}


-----------------------------------------------------------
-- UPDATE
-----------------------------------------------------------
data Msg
  = LoadIndicators
  | IncrementValues
  -- = IncrementValues
  -- | AlertDomValues
  -- | SetIndicatorValue
  -- | IncreaseZoom
  -- | DecreaseZoom

update :: Msg -> DisplayScreenPresenter -> Effect DisplayScreenPresenter
update IncrementValues p = do
  incrementIndicatorValues p
  pure p


update LoadIndicators p =
  loadIndicators p
  >>= (then_ (\_ -> redraw))
  >>= (\_ -> pure p)


  -- maybeFirstIndicator <- doc_querySelector $ "#" <> "C02Buffer" <> " .innerBox"
  -- let msg = maybe (Just "ERROR: could not find first indicator.") (elem_attr "height") maybeFirstIndicator
  -- window >>= win_alert (maybe "blah" identity msg)
  -- pure st
--
-- update SetIndicatorValue st = do
--   maybeIndName  <- doc_getElementById "indicatorName" >>= \elem -> pure $ maybe Nothing (el_prop_value) elem
--   maybeNewValue <- doc_getElementById "newIndicatorValue" >>= \elem -> pure $ (maybe Nothing (Number.fromString) (maybe Nothing (el_prop_value) elem))
--   let maybeIndicator = maybeIndName >>= findIndicator st
--
--   let maybeUpdatedInd :: Maybe IndicatorCtl
--       maybeUpdatedInd = updateIndicator <$> maybeIndicator <*> maybeNewValue
--
--   pure $ (maybe st (\ind -> st { indicators = updateIndicatorIn st.indicators ind }) maybeUpdatedInd)
--   where
--     updateIndicator :: IndicatorCtl -> Number -> IndicatorCtl
--     updateIndicator ind newVal = indSetValues [newVal] ind
--
--     updateIndicatorIn :: Array IndicatorCtl -> IndicatorCtl -> Array IndicatorCtl
--     updateIndicatorIn arr ind =
--       let maybeUpdatedArr = (findIndex (\ i -> (indId i) == (indId ind)) arr) >>= (\idx -> updateAt idx ind arr)
--       in maybe arr identity maybeUpdatedArr
--
-- update IncreaseZoom st = do
--   pure $ st { indicators = map (indIncScale 0.1) st.indicators }
--
-- update DecreaseZoom st = do
--   pure $ st { indicators = map (indDecScale 0.1) st.indicators }



-- findIndicator :: State -> String -> Maybe IndicatorCtl
-- findIndicator st name = st.indicators # find (\ind -> (indId ind) == name)

-----------------------------------------------------------
-- VIEW
-----------------------------------------------------------

raiseEvent :: Ref DisplayScreenPresenter -> Msg -> Unit
raiseEvent refSt = raise update refSt


-- mkView :: forall eff. Unit -> Eff eff Component
mkView :: DisplayScreenPresenter -> Component
mkView presenter =
  mkComponent presenter (\stRef st _ -> do
    m <- model st
    pure $ main [] [
      h1' ["style":="color:red;"] "Bukela",
      --mcomp (HWComponent.mkView { name: "RvD" }),
      button' ["onclick":= \_ -> raiseEvent stRef IncrementValues] "++",
      button' ["onclick":= \_ -> raiseEvent stRef LoadIndicators] "??",
      -- select ["id":="indicatorName"] (map (\ind -> option ["value":= indId ind] (indId ind)) st.indicators),
      -- input ["type":= "text", "id":= "newIndicatorValue", "style":="width:450px"],
      -- button' ["onclick":= \_ -> raiseEvent stRef SetIndicatorValue] "!!",
      -- button' ["onclick":= \_ -> raiseEvent stRef IncreaseZoom] "Z+",
      -- button' ["onclick":= \_ -> raiseEvent stRef DecreaseZoom] "Z-",
      --br [],
      svg ["id":="svg", "viewBox":="0 0 300 150"] (map indRender m.indicators)
      ])
