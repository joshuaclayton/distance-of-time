module Data.Time.DistanceSpec
    ( main
    , spec
    ) where

import qualified Data.Time as T
import           Data.Time.Distance
import           Test.Hspec
import           Test.Hspec.QuickCheck
import           Test.QuickCheck

instance Arbitrary T.Day where
    arbitrary =
        T.fromGregorian
        <$> choose (1600, 2400)
        <*> choose (1, 12)
        <*> choose (1, 31)

main :: IO ()
main = hspec spec

spec :: Spec
spec =
    context "Data.Time.Distance" $ parallel $ modifyMaxSuccess (* 1000) $ do
        describe "distanceOfTimeInWords" $ do
            it "handles milliseconds" $ property $ \d -> do
                distanceOfTimeInWords (addMilliseconds d (-30)) (dayToTime d) `shouldBe` "30 milliseconds ago"
                distanceOfTimeInWords (addMilliseconds d (900)) (dayToTime d) `shouldBe` "900 milliseconds from now"

            it "handles seconds" $ property $ \d -> do
                distanceOfTimeInWords (addMilliseconds d (-30000)) (dayToTime d) `shouldBe` "30 seconds ago"
                distanceOfTimeInWords (addMilliseconds d (45000)) (dayToTime d) `shouldBe` "45 seconds from now"

            it "handles hours" $ property $ \d -> do
                distanceOfTimeInWords (addHours d (-2)) (dayToTime d) `shouldBe` "2 hours ago"
                distanceOfTimeInWords (addHours d 2) (dayToTime d) `shouldBe` "2 hours from now"

            it "handles days" $ property $ \d -> do
                distanceOfTimeInWords (addDays d (-2)) (dayToTime d) `shouldBe` "2 days ago"
                distanceOfTimeInWords (addDays d 2) (dayToTime d) `shouldBe` "2 days from now"

            it "handles weeks" $ property $ \d -> do
                distanceOfTimeInWords (addDays d (-21)) (dayToTime d) `shouldBe` "3 weeks ago"
                distanceOfTimeInWords (addDays d 21) (dayToTime d) `shouldBe` "3 weeks from now"

            it "handles months" $ property $ \d -> do
                distanceOfTimeInWords (addDays d (-182)) (dayToTime d) `shouldBe` "6 months ago"
                distanceOfTimeInWords (addDays d 40) (dayToTime d) `shouldBe` "1 month from now"

            it "handles years ago" $ property $ \d -> do
                distanceOfTimeInWords (addDays d (-365)) (dayToTime d) `shouldBe` "12 months ago"
                distanceOfTimeInWords (addDays d (-366)) (dayToTime d) `shouldBe` "2 years ago"
                distanceOfTimeInWords (addDays d 365) (dayToTime d) `shouldBe` "12 months from now"
                distanceOfTimeInWords (addDays d 400) (dayToTime d) `shouldBe` "1 year from now"
                distanceOfTimeInWords (addDays d 710) (dayToTime d) `shouldBe` "1 year from now"
                distanceOfTimeInWords (addDays d 730) (dayToTime d) `shouldBe` "2 years from now"

            it "handles types for DiffableTime" $ property $ \d -> do
                distanceOfTimeInWords (addDays d (-365)) d `shouldBe` "12 months ago"
                distanceOfTimeInWords (addDays d (-366)) d `shouldBe` "2 years ago"
                distanceOfTimeInWords (addDays d 365) d `shouldBe` "12 months from now"
                distanceOfTimeInWords (addDays d 400) d `shouldBe` "1 year from now"
                distanceOfTimeInWords (addDays d 710) d `shouldBe` "1 year from now"
                distanceOfTimeInWords (addDays d 730) d `shouldBe` "2 years from now"

addHours :: T.Day -> Integer -> T.UTCTime
addHours d i = T.UTCTime d (fromInteger $ i * 60 * 60)

addMilliseconds :: T.Day -> Rational -> T.UTCTime
addMilliseconds d i = T.UTCTime d (fromRational $ i / 1000)

addDays :: T.Day -> Integer -> T.UTCTime
addDays d i = T.UTCTime (T.addDays i d) 0

dayToTime :: T.Day -> T.UTCTime
dayToTime = flip T.UTCTime 0

instance DiffableTime T.Day where
    toTime = dayToTime
