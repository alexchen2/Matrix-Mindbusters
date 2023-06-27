module MenuWin.HardSelect exposing (..)

-- Coded by Alex Chen

import List exposing (length, head, take, reverse)
import Tuple exposing (first, second)

-- MacCASOutreach imports
import GraphicSVG exposing (..)
import GraphicSVG.App exposing (..)

-- Local imports
import Misc.MatrixStrings exposing (mainBgImg)
import Misc.LvlImgs exposing ( hardLevel1, hardLevel2 )

{- ** Constants ** -}
-- Change below two constants (and some alg data types below) to switch menu for different difficulties
numLevels = 2
levelPrefix = "H"             -- "E" for Easy, "M" for Medium, "H" for Hard

boxWidth = 192                -- "box" just refers to the entire menu container
boxLength = 128
fadeInSpeed = 0.155           -- speed of btn fade in animation in sec, change for slower/faster fade in
btnScaleAmt = 1.1

optionalClr = (rgb 97 109 143) --(rgb 124 72 212) --(rgba 238 108 77 255)
optionalClr2 = (rgb 183 100 43)-- (rgb 183 100 43)

hoverClr = (rgb 232 245 252)  -- when mouse cursor is hovering over
clickClr = (rgb 172 218 242)  -- when clicking & holding down
btnClr = (rgb 0 126 204)       -- clr for arrow
titleClr = ((rgb 0 111 181), (rgb 0 61 110))
levelSelectGradient =
  gradient [ transparentStop black 60 0
           , transparentStop black 95 0.8
           , transparentStop black 100 0.4 ]
  
imgGradient =
  gradient [ transparentStop black 15 0.15
           , transparentStop black 25 0.01
           , transparentStop white 72.5 0
           , transparentStop black 120 0.01
           , transparentStop black 130 0.2 ]

titleFont = "Bahnschrift"  -- alternative for non-Windows: Arial
descTextFont = "Bahnschrift Light"
timeFont = "Bahnschrift Condensed"

levelImgList = [hardLevel1, hardLevel2] 

{- ** Animation Functions ** -}
btnFadeIn : Float -> Float
btnFadeIn hoverTime =
  if hoverTime > fadeInSpeed then
    1
  else 
    (1 / (fadeInSpeed ^ 2)) * hoverTime ^ 2
        
slideRight exitTime =
  let
    aniFunc =
      if exitTime > 1 then
        1000
      else
        1000 * (exitTime ^ 4)
  in
    move (aniFunc, 0)
    
btnGrow : Float -> Float
btnGrow hoverTime = 
  let 
    maxTime = 0.3
  in
    if hoverTime > maxTime then
      btnScaleAmt
    else
      -(btnScaleAmt - 1) * (((1 / maxTime) * (hoverTime - maxTime)) ^ 2) + btnScaleAmt

btnShrink : Float -> Float -> Float
btnShrink hoverTime lastHoverTime = 
  let 
    maxTime1 = 0.3
    maxTime2 = 
      ( if lastHoverTime > maxTime1 then
          maxTime1
        else 
          lastHoverTime )
  in
    if hoverTime > maxTime2 then
      1
    else 
      (btnScaleAmt - 1) * (((1 / maxTime1) * (hoverTime - maxTime2)) ^ 2) + 1    

imgRotate exitTime = 
  let 
    aniXFunc = 1 * cos (exitTime)
    aniYFunc = 0.8 * sin (exitTime)
  in
    move (aniXFunc, aniYFunc)

-- Line left-to-right wiping animation when transitioning to new level gif
imgWipe scrollTime = 
  let
    aniFunc x = 
      if (600 * x) > 120 then
        120
      else if (600 * x) < 0 then
        0
      else
        600 * x
  in
    move (aniFunc scrollTime, 0)

-- Img display opening animation
imgReveal time = 
  let
    aniFunc y = 
      if (-750 * y) > -128 then
        -128
      else
        -750 * y
  in
    move (0, aniFunc time)

-- Img display transition to gameplay animation (left/right sides expand outwards)
imgSideExpand exitTime =         -- isLeft checks for animating left line, if False, then animates right line instead
  let 
    aniFunc x =    -- moves object towards the left, multiply by -1 to reverse direction
      if (500 * (x ^ 4)) > 150 then
        150
      else
        500 * (x ^ 4)
  in
    aniFunc exitTime

imgExpand : Float -> Shape userMsg -> Shape userMsg
imgExpand exitTime shape = 
  let
    a = ((0.239 * 0.9) / 0.155) - 1  -- (0.239 / 0.155) - 0.155 - 1
    aniFuncScale x = 
      -(a / 2) * cos ((pi / 1.4) * x) + 1 + (a / 2)   -- 1.4 second interval of scaling animation
    aniFuncMoveX x =
      (51 / 2) * cos ((pi / 1.4) * x) - (51 / 2)
    aniFuncMoveY y = 
      (7.2 / 2) * cos ((pi / 1.4) * y) - (7.2 / 2)
  in
    --if exitTime <= 0.5 then
    --  scale (aniFuncScale 0.5) shape
    --    |> move (aniFuncMoveX 0.5, aniFuncMoveY 0.5)
    if exitTime >= 1.4 then
      scale (aniFuncScale 1.4) shape   
        |> move (aniFuncMoveX 1.4, aniFuncMoveY 1.4)
    else
      scale (aniFuncScale exitTime) shape    
        |> move (aniFuncMoveX exitTime, aniFuncMoveY exitTime)    


-- Scales each panel in display relative to currently-focused panel
scaleSelect model currentNum =
  let  
    aniFunc : Int -> Int -> Float -> Float
    aniFunc num prevNum x =    -- x = current panel #
      case model.winState of
        Scrolling ->
          if num > prevNum then        -- scrolling down
            if model.scrollTime < 0.5 then
              -0.13 * (((x + 1 - (2 * model.scrollTime)) - (toFloat num)) ^ 2) + 1
            else
              -0.13 * ((x - (toFloat num)) ^ 2) + 1
          else if num < prevNum then   -- scrolling up
            if model.scrollTime < 0.5 then
              -0.13 * (((x - 1 + (2 * model.scrollTime)) - (toFloat num)) ^ 2) + 1
            else
              -0.13 * ((x - (toFloat num)) ^ 2) + 1
          else                         -- no scroll, same pos.
            -0.13 * ((x - (toFloat num)) ^ 2) + 1        
        _ ->
          if (-0.13 * ( (x - (toFloat num)) ^ 2) + 1) < 0 then
            0
          else
            -0.13 * ( (x - (toFloat num)) ^ 2) + 1
  in
    case (model.levelDisplay, model.prevLevelDisplay) of
      (Hard num, Hard prevNum) ->
        scale (aniFunc num prevNum currentNum)
      _ ->
        scale 1

moveSelect model = 
  let
    aniFunc num prevNum = 
      case model.winState of
        Scrolling ->
          if num > prevNum then        -- scrolling down
            if model.scrollTime < 0.5 then
              -(15 * 16) * (model.scrollTime - 0.5) ^ 4 + (15 * ((toFloat num) - 1))
            else
              15 * ((toFloat num) - 1)
          else if num < prevNum then   -- scrolling up
            if model.scrollTime < 0.5 then
              (15 * 16) * (model.scrollTime - 0.5) ^ 4 + (15 * ((toFloat num) - 1))
            else
              15 * ((toFloat num) - 1)
          else                         -- no scroll, same pos.
            15 * ((toFloat num) - 1)
            
        _ ->
          15 * ((toFloat num) - 1)
  in
    case (model.levelDisplay, model.prevLevelDisplay) of
      (Hard num, Hard prevNum) ->
        move (0, aniFunc num prevNum)
      _ ->
        move (0, 0)

openFadeIn time = 
  let
    aniFunc =
      if time < 1.0 then
        0
      else if time > 2.0 then
        1
      else
        -1 * ((time - 2) ^ 4) + 1
  in
    makeTransparent aniFunc

closeFadeIn exitTime = 
  let
    aniFunc =
      if exitTime > 1.0 then
        1
      else
        -1 * ((exitTime - 1) ^ 4) + 1
  in
    makeTransparent aniFunc

-- Animation of level select area line borders when opening menu 
openSelectLine time = 
  let
    aniFunc1 x = -(256 * 41.5) * ((x - 0.75) ^ 4) + 41.5    
    aniFunc2 x = -22.5 * ((x - 1.9) ^ 4) + 22.5  -- -22.5 * cos((pi / 2) * x)   --11.25 * cos (pi * (x + 0.25)) + 11.25
    selectAreaGrow = 
      polygon [ (0, -7.5 + (aniFunc2 time))
              , (0, -7.5 - (aniFunc2 time))
              , (83, -7.5 - (aniFunc2 time))
              , (83, -7.5 + (aniFunc2 time)) ]
            |> ghost
  in
    ( if time <= 0.5 then
        line (0, -7.5) (0, -7.5)
          |> outlined (solid 0.2) black
      else if time <= 0.75 then
        line (41.5 - (aniFunc1 time), -7.5) (41.5 + (aniFunc1 time), -7.5)
          |> outlined (solid 0.2) black
      else if time <= 0.9 then
        line (41.5 - (41.5), -7.5) (41.5 + (41.5), -7.5)
          |> outlined (solid 0.2) black
      else if time <= 1.9 then
        [ line (0, -7.5 + (aniFunc2 time)) (83, -7.5 + (aniFunc2 time))
            |> outlined (solid 0.2) black
        , line (0, -7.5 - (aniFunc2 time)) (83, -7.5 - (aniFunc2 time))
            |> outlined (solid 0.2) black
        , selectAreaGrow ]
          |> group
      else
        [ line (0, 15) (83, 15)
            |> outlined (solid 0.2) black
        , line (0, -30) (83, -30)
            |> outlined (solid 0.2) black 
        , selectArea
            |> move ((boxWidth / 2) - 13, 10) ] 
          |> group )
      |> move (-(boxWidth / 2) + 13, -10)
  
openSelectArrows time = 
  let
    aniFunc1 x = 
      if x < (4/3) then
        0
      else if x >= 1.9 then
        28
      else
        -28 * ((1.3 * (x - 1.9)) ^ 4) + 28
    -- aniFunc2 x = 
    --   if x < 0.9 then
    --     0
    --   else if x >= 1.9 then
    --     22.5
    --   else
    --     -22.5 * ((x - 1.9) ^ 4) + 22.5
  in
    [ arrow        -- up arrow visuals
        |> rotate (degrees -90)
        |> move (42.5, -8 + (aniFunc1 time))
    , arrow        -- down arrow visuals
        |> rotate (degrees 90)
        |> move (42.5, -8 - (aniFunc1 time))
    ]
      |> group
      |> move (-(boxWidth / 2) + 13, -10)
      |> subtract selectArea

{- ** Basic Shapes ** -}
title model =  
  [ [ text "Level Select" 
        |> centered
        |> sansserif
        |> customFont titleFont
        |> filled (second titleClr)
        |> move (0.4, -0.4)
    , text "Level Select" 
        |> centered
        |> sansserif
        |> customFont titleFont
        |> filled (first titleClr)
    ]
      |> group
      |> addOutline (solid 0.3) black
  , text "Select a level to start."
      |> centered
      |> italic
      |> sansserif
      |> customFont descTextFont
      |> filled black
      |> scale (0.45)
      |> move (-6, -12.5)
      |> ( if model.winState == Opening then
             openFadeIn model.time
           else
             makeTransparent 1 )
  ]
    |> group
    |> scale 0.725
    |> move (-60, 30.5) --(-78.5625, 30.5)

backBtn model =
  [ roundedRect 18.5 7 1
      |> filled white
      |> move (5.5, 0)
  , roundedRect 18.5 7 1
      |> (if model.click == ClickExit then
            filled clickClr
          else
            filled hoverClr )
      |> ( if model.click == ClickExit then
             makeTransparent 1
           else if model.hoverExit then
             makeTransparent (btnFadeIn model.hoverTime)
           else
             makeTransparent 0 )
      |> move (5.5, 0)
  , roundedRect 4 1 1.2
      |> filled btnClr
      |> rotate (degrees 40)
      |> move (0, 1)
  , roundedRect 4 1 1.2
      |> filled btnClr
      |> rotate (degrees -40)
      |> move (0, -1)
  , text "Back"
      |> sansserif
      |> filled darkBlue
      |> scale (0.325)
      |> move (3.5, -1.25)
  ]
    |> group
    |> addOutline (solid 0.4) black
    |> scale (1.1)
    |> move (-(boxWidth / 2) + 13, (boxLength / 2) - 13.5)
    |> notifyTap ToPrevMenu
    |> notifyEnter HoverExitBtn
    |> notifyLeave LeaveExitBtn
    |> notifyMouseDown ClickExitBtn

-- Displays circular-moving gif on the right of the screen (and also handles its transition animations as well)
levelImgDisplay model = 
  let
    maybeParser value =
      case value of
        Just x -> x
        Nothing -> rect 0 0 |> ghost
        
    -- Normal img display when not transitioning or animating        
    imgNormal =      
      [ levelImgDisplayBG model   -- For white background layer
      , ( if model.winState == Scrolling then
            imgTransition 
          else
            imgChoose
              |> imgRotate model.time
              |> clip (levelImgDisplayBG model))
      , levelImgDisplayBG model   -- For gradient layer
          |> repaint (rotateGradient (pi / 2.075) imgGradient)
          |> clip border  
      , levelImgDisplayBG model   -- For black outline (note: adding outline onto a gradient-ed object DOES NOT work)
          |> makeTransparent 0
          |> addOutline (solid 0.6) black
      ]
        |> group
        |> if model.winState == Opening then
             subtract revealRect
           else
             move (0, 0)
             
    -- Choosing what img to display on screen at any moment (from list of imported imgs)
    imgChoose = 
      case model.levelDisplay of   
        Hard numDisplay ->
          if (length levelImgList) < numDisplay then
            rect 0 0 |> ghost
          else
            take numDisplay levelImgList
              |> reverse
              |> head
              |> maybeParser
        _ ->
          rect 0 0 |> ghost     
          
    -- Img display when in winState Scrolling state      
    imgTransition =
      case (model.levelDisplay, model.prevLevelDisplay) of
        (Hard num, Hard prevNum) ->
          if num == prevNum then
            imgChoose 
              |> imgRotate model.time
              |> clip (levelImgDisplayBG model)
          else
            [ imgChoose 
                |> subtract wipeRect
                |> imgRotate model.time
                |> clip (levelImgDisplayBG model)
            , wipeRect
            , imgChoose 
                |> clip wipeRect
                |> imgRotate model.time
                |> clip (levelImgDisplayBG model)
            , wipeRect
                |> addOutline (solid 0.75) black
            ] 
              |> group
        _ ->
          rect 0 0 |> ghost
          
    -- Animation that plays when winState is in ClosingNext specifically (not ClosingExit)      
    imgClosing =
      [ levelImgDisplayBG model   -- For white background layer
      , levelImgDisplayBG model   -- For gradient layer
          |> repaint (rotateGradient (pi / 2.075) imgGradient)
          |> clip border 
          |> makeTransparent 0 
      , levelImgDisplayBG model
          |> closeFadeIn model.exitTime
      , imgChoose 
--          |> imgRotate model.time
          |> imgExpand model.exitTime
          |> clip (levelImgDisplayBG model)

      , levelImgDisplayBG model   -- For black outline (note: adding outline onto a gradient-ed object DOES NOT work)
          |> makeTransparent 0
          |> addOutline (solid 0.6) black
      ]
        |> group
        
    wipeRect = 
      rect 120 140
        |> ghost
        |> move (-50, 0)
        |> imgWipe model.scrollTime
        |> clip (levelImgDisplayBG model)
        
    revealRect = 
      rect 120 140
        |> ghost
        |> move (60, 70 + 64)
        |> imgReveal model.time
  in 
    if model.winState == ClosingNext then
      imgClosing
    else
      imgNormal 
    
levelImgDisplayBG model = 
  if model.winState == ClosingNext then
    polygon [ (105 + (imgSideExpand model.exitTime), 64)
            , (35 - (imgSideExpand model.exitTime), 64)
            , (15 - (imgSideExpand model.exitTime), -64)
            , (85 + (imgSideExpand model.exitTime), -64) ]
      |> filled white    
  else
    polygon [ (105, 64)
            , (35, 64)
            , (15, -64)
            , (85, -64) ]
      |> filled white

arrow =
  [ roundedRect 9 0.75 1
      |> filled btnClr
      |> rotate (degrees 60)
      |> move (0, 3.45)
  , roundedRect 9 0.75 1
      |> filled btnClr
      |> rotate (degrees -60)
      |> move (0, -3.45) ]
    |> group
    |> addOutline (solid 0.6) (black)

collision model =
  let 
    numDisplay = 
      case model.levelDisplay of
        Hard num -> num
        _ -> -1                 -- Failsafe for no level being displayed in middle of level display
  in
    [ rect 20 7.5    -- collision box for up arrow
        |> ghost
        |> move (42.5, 20)
        |> notifyTap ScrollUp
    , selectBtn 0 "ScrollUp"    -- clicking on smaller upper level select button also scrolls up
        |> makeTransparent 0
        |> scale 0.75
        |> move (41.5, 7.5)
        |> notifyTap ScrollUp
    , rect 20 7.5    -- collision box for down arrow
        |> ghost
        |> move (42.5, -36)
        |> notifyTap ScrollDown
    , selectBtn 0 "ScrollDown"  -- clicking on smaller lower level select button also scrolls down
        |> makeTransparent 0
        |> scale 0.75
        |> move (41.5, -22.5)
        |> notifyTap ScrollDown
    , selectBtn 0 "EnterLevel"
        |> makeTransparent 0
        |> move (41.5, -7.5)
        |> notifyTap (EnterLevel numDisplay)
    ]
      |> group
      |> move (-(boxWidth / 2) + 13, -10)

-- Separated from selectOutline, as this is need for clipping other objects
selectArea = 
  polygon [ (0, 15)
          , (83, 15)
          , (83, -30) 
          , (0, -30) ]
    |> ghost
    |> move (-(boxWidth / 2) + 13, -10)

selectOutline = 
  [ line (0, 15) (83, 15)
      |> outlined (solid 0.2) black
  , line (0, -30) (83, -30)
      |> outlined (solid 0.2) black
  , arrow        -- up arrow visuals
      |> rotate (degrees -90)
      |> move (42.5, 20)
  , arrow        -- down arrow visuals
      |> rotate (degrees 90)
      |> move (42.5, -36)
  ]
    |> group
    |> move (-(boxWidth / 2) + 13, -10)

-- Creates one individual button
selectBtn num time = 
  [ polygon [ (-28, 4.5)
            , (28, 4.5)
            , (33, 0)
            , (28, -4.5)
            , (-28, -4.5)
            , (-33, 0) ]
      |> filled optionalClr
      |> addOutline (solid 0.3) black
  , text ("Level " ++ levelPrefix ++ "-" ++ (Debug.toString num))
      |> centered
      |> bold
      |> customFont titleFont
      |> filled white
      |> scale (0.33)
      |> move (-19, -1.5)
  , polygon [ (-9, 4.5)
            , (28, 4.5)
            , (33, 0)
            , (28, -4.5)
            , (-9, -4.5)
            , (-4, 0) ]
      |> filled white
      |> addOutline (solid 0.075) black
  , text ("Best Time: " ++ time)
      |> bold
      |> customFont timeFont
      |> filled black
      |> scale 0.3
      |> move (-2, -1.5)
  ]      
    |> group

-- Calls a recursive function that returns a list of buttons arranged in a column, and applies some other details to them from here
selectBtnCol : Model -> Float -> Shape userMsg
selectBtnCol model totalNum =
  [ selectBtnColAux model totalNum 0  -- col of all level select btns
      |> group
      |> move (-41.5, -17.5)
      |> moveSelect model
      |> clip selectArea
  , polygon [ (0, 4)    -- visual arrows indicating currently-displayed level
            , (0, -4)
            , (4, 0) ]
      |> filled btnClr
      |> addOutline (solid 0.3) black
      |> move (-82, -17.3)
  , polygon [ (0, 4)
            , (0, -4)
            , (4, 0) ]
      |> filled btnClr
      |> addOutline (solid 0.3) black
      |> rotate (degrees 180)
      |> move (-1, -17.3) 
  , if model.winState /= Opening then
      [ selectArea
          |> repaint (rotateGradient (pi / 2) levelSelectGradient)
      , selectArea
          |> repaint (rotateGradient (pi / 2) levelSelectGradient)
          |> rotate (degrees 180)
          |> move (-83, -35)
      ] 
        |> group
    else
      let
        aniFunc time =  
          if time <= 0.9 then
            0
          else if time <= 1.9 then
            -22.5 * ((time - 1.9) ^ 4) + 22.5
          else
            22.5
      in
        [ selectArea           -- move 22.5 up and 22.5 down respectively
            |> repaint (rotateGradient (pi / 2) levelSelectGradient)
            |> move (0, -22.5 + aniFunc model.time)             -- 15
        , selectArea 
            |> repaint (rotateGradient (pi / 2) levelSelectGradient)
            |> rotate (degrees 180)
            |> move (-83, -12.5 - aniFunc model.time)    -- -35 
        ]
          |> group
  ]
    |> group

selectBtnColAux : Model -> Float -> Float -> List (Shape userMsg)
selectBtnColAux model totalNum startNum =         -- startNum = 0 when calling function at first
  if startNum >= totalNum then
    [ rect 0 0 |> ghost ]
  else
    ( [selectBtn (startNum + 1) "00:00:00"
        |> scaleSelect model (startNum + 1)
        |> move (0, -15 * startNum) ] ) ++
    (selectBtnColAux model totalNum (startNum + 1))

border =
  rect 192 128
    |> ghost
    |> addOutline (solid 0.5) black

myShapes model =
  case model.winState of 
    Opening ->
      [ mainBgImg
      , levelImgDisplay model
      , title model
      , backBtn model
          |> openFadeIn model.time
      , openSelectArrows model.time
      , openSelectLine model.time
      , selectBtnCol model numLevels
          |> clip (openSelectLine model.time)
      , border ]
    Active ->
      [ mainBgImg
      , levelImgDisplay model 
      , title model
      , selectOutline
      , selectBtnCol model numLevels
      , [ border
        , backBtn model 
        , collision model ]
          |> group
          |> notifyMouseUp ReleaseClick
          |> notifyLeave ReleaseClick
      ]
    Scrolling -> 
      [ mainBgImg
      , levelImgDisplay model
      , title model
      , selectOutline
      , selectBtnCol model numLevels
      , [ border
        , backBtn model 
        , collision model ]
          |> group
          |> notifyMouseUp ReleaseClick
          |> notifyLeave ReleaseClick
      ]
    ClosingExit ->
      if model.isExit then
        [ rect 0 0 |> ghost ]
      else
        [ [ mainBgImg      
          , levelImgDisplay model
          , title model
          , backBtn model
          , selectOutline
          , selectBtnCol model numLevels
          , border
          , line (-97, -64) (-97, 64) 
            |> outlined (solid 0.25) black ]
            |> group
            |> slideRight model.exitTime ]
    ClosingNext ->
      if model.isExit then
        [ border ]
      else
        [ mainBgImg
              |> subtract (levelImgDisplay model)
          , levelImgDisplay model
          , [ title model
            , backBtn model
            , selectOutline
            , selectBtnCol model numLevels ]
              |> group
              |> subtract (levelImgDisplay model)
          , border
        ]
        
type Msg = Tick Float GetKeyState
         | ToPrevMenu
         | ScrollUp
         | ScrollDown
         | EnterLevel Int
         | HoverExitBtn
         | ClickExitBtn
         | LeaveExitBtn
         | ReleaseClick  

-- Originally intended to make module more dynamic and choose from Easy, Medium, or Hard, but scrapped that idea
type Level = Hard Int
           | LevelNone

-- Depreciated, possibly remove later or update
type LevelBtnState = Hovered Int
                   | Clicked Int
                   | None

-- Leftover code from exit button, too lazy to change 
type ClickState = ClickExit
                | ClickNone

type WinState = Opening 
              | Active
              | Scrolling
              | ClosingNext   -- after pressing level button
              | ClosingExit   -- after pressing back button

type alias Model = { time : Float 
                   , hoverTime : Float
                   , lastHoverTime : Float 
                   , shrinkTime : Float  
                   , scrollTime : Float
                   , hoverExit : Bool 
                   , exitTime : Float
                   , levelDisplay : Level
                   , prevLevelDisplay : Level
                   , levelChoose: Level 
                   , click : ClickState 
                   , winState : WinState 
                   , isExit : Bool }

update msg model = case msg of
                     Tick t _ -> 
                       case model.winState of
                         Opening ->
                           if model.time > 2 then
                             { model | time = t
                                     , winState = Active }
                           else
                             { model | time = t }
                         Active ->
                           { model | time = t 
                                   , hoverTime = model.hoverTime + (t - model.time)
                                   , shrinkTime = model.shrinkTime + (t - model.time) }
                         Scrolling -> 
                           if model.scrollTime >= 0.5 then
                             { model | time = t
                                     , hoverTime = model.hoverTime + (t - model.time)
                                     , scrollTime = 0
                                     , winState = Active }
                           else
                             { model | time = t 
                                     , hoverTime = model.hoverTime + (t - model.time) 
                                     , scrollTime = model.scrollTime + (t - model.time) }
                         ClosingExit ->
                           { model | time = t
                                   , hoverTime = 0
                                   , isExit = 
                                       if model.exitTime >= 1 then
                                         True
                                       else
                                         model.isExit
                                   , exitTime = model.exitTime + (t - model.time) } 
                         ClosingNext ->
                           { model | time = t
                                   , hoverTime = 0
                                   , isExit = 
                                       if model.exitTime >= 2 then
                                         True
                                       else
                                         model.isExit
                                   , exitTime = model.exitTime + (t - model.time) }                         
                     HoverExitBtn ->
                       if model.click == ClickNone then
                         { model | hoverExit = True 
                                 , hoverTime = 0 }
                       else
                         model
                     
                     ClickExitBtn ->
                       { model | click = ClickExit
                               , hoverExit = False }
                     
                     LeaveExitBtn ->
                       { model | hoverExit = False }
                     
                     ReleaseClick ->  
                       { model | click = ClickNone }
                     ToPrevMenu ->
                       { model | exitTime = 0
                               , hoverExit = False 
                               , winState = ClosingExit }
                     ScrollUp ->
                       let
                         levelSub level =
                           case level of
                             Hard num ->
                               if num > 1 then
                                 Hard (num - 1)
                               else
                                 Hard num
                             _ ->
                               identity level
                       in
                         { model | scrollTime = 0 
                                 , levelDisplay = levelSub model.levelDisplay 
                                 , prevLevelDisplay = model.levelDisplay 
                                 , winState = Scrolling }
                     ScrollDown ->
                       let
                         levelAdd level =
                           case level of
                             Hard num ->
                               if num < numLevels then
                                 Hard (num + 1)
                               else
                                 Hard num
                             _ ->
                               identity level
                       in
                         { model | scrollTime = 0 
                                 , levelDisplay = levelAdd model.levelDisplay 
                                 , prevLevelDisplay = model.levelDisplay 
                                 , winState = Scrolling }                     
                     EnterLevel _ ->   -- argument meant to be levelNum, but is now unused
                       { model | levelChoose = model.levelDisplay 
                               , exitTime = 0
                               , hoverExit = False
                               , winState = ClosingNext }
init = { time = 0 
       , hoverTime = 0
       , lastHoverTime = 0
       , shrinkTime = 100       
       , exitTime = 0
       , scrollTime = 0
       , hoverExit = False 
       , click = ClickNone
       , levelDisplay = Hard 1
       , prevLevelDisplay = Hard 1   -- LevelNone
       , levelChoose = LevelNone       
       , winState = Opening 
       , isExit = False }

main = gameApp Tick { model = init, view = view, update = update, title = "MM | Select a Hard Level" }

view model = collage 192 128 (myShapes model)



