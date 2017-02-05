module Data.Time.Distance
    ( TimeUnit(..)
    , TimeDirection(..)
    , distanceOfTime
    , distanceOfTimeInWords
    ) where

import qualified Data.Maybe as M
import qualified Data.Time as T

data TimeDirection
    = Past
    | Present
    | Future

data TimeUnit
    = Millisecond
    | Second
    | Minute
    | Hour
    | Day
    | Week
    | Month
    | Year

data TimeDifference = TimeDifference TimeDistance TimeDirection
data TimeDistance = TimeDistance Integer TimeUnit

instance Show TimeDirection where
    show Past = "ago"
    show Present = ""
    show Future = "from now"

instance Show TimeUnit where
    show Millisecond = "millisecond"
    show Second = "second"
    show Minute = "minute"
    show Hour = "hour"
    show Day = "day"
    show Week = "week"
    show Month = "month"
    show Year = "year"

instance Show TimeDistance where
    show (TimeDistance amount unit) = show amount ++ " " ++ pluralizeUnit
      where
        pluralizeUnit
            | amount > 1 = show unit ++ "s"
            | otherwise = show unit

instance Show TimeDifference where
    show (TimeDifference _ Present) = "now"
    show (TimeDifference distance direction) =
        show distance ++ " " ++ show direction

distanceOfTimeInWords :: T.UTCTime -> T.UTCTime -> String
distanceOfTimeInWords a = show . distanceOfTime a

distanceOfTime :: T.UTCTime -> T.UTCTime -> TimeDifference
distanceOfTime a b = TimeDifference (TimeDistance amount unit) (directionFromDiff diff)
  where
    diff = T.diffUTCTime a b
    (TimeDistance i unit) = M.fromMaybe years $ bestTimeDistance diff
    amount
        | c == 0 = abs $ floor $ diff * 1000
        | otherwise = abs $ floor diff `div` c
    c = i `div` 1000

bestTimeDistance :: T.NominalDiffTime -> Maybe TimeDistance
bestTimeDistance v = safeLast $ filter timeValuesUnderBounds timeValues
  where
    timeValues = [milliseconds, seconds, minutes, hours, days, weeks, months, years]
    timeValuesUnderBounds (TimeDistance i _) = toNominalDifftime (i `div` 1000) < abs v
    toNominalDifftime = fromInteger . toInteger

milliseconds, seconds, minutes, hours, days, weeks, months, years :: TimeDistance
milliseconds = TimeDistance 1 Millisecond
seconds      = buildTime 1000 milliseconds Second
minutes      = buildTime 60   seconds      Minute
hours        = buildTime 60   minutes      Hour
days         = buildTime 24   hours        Day
weeks        = buildTime 7    days         Week
months       = buildTime 730  hours        Month
years        = buildTime 365  days         Year

buildTime :: Integer -> TimeDistance -> TimeUnit -> TimeDistance
buildTime multiplier (TimeDistance i _) = TimeDistance (multiplier * i)

directionFromDiff :: T.NominalDiffTime -> TimeDirection
directionFromDiff t
    | t < 0 = Past
    | t == 0 = Present
    | t > 0 = Future
    | otherwise = Present

safeLast :: [a] -> Maybe a
safeLast [] = Nothing
safeLast xs = Just $ last xs
