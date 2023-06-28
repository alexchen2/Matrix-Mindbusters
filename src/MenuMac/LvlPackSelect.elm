module MenuMac.LvlPackSelect exposing (..)

-- Coded by Alex Chen & Loic Sinclair

import Html exposing (img, div, span)
import Html.Attributes exposing (style, width, src, height)
import Tuple exposing (first, second)
import List exposing (any, all, take, drop, head, repeat)
import String exposing (split)

-- MacCASOutreach imports
import GraphicSVG exposing (..)
import GraphicSVG.App exposing (..)

-- Local imports
import MenuMac.MainMenu as MTitle
import Misc.MatrixStrings exposing ( pnlEasy, pnlMed, pnlHard, bgImg1, mainBgImg )
import Misc.LvlImgs exposing ( easyLevel1, medLevel1, hardLevel1 )
import MenuMac.AboutCredits as AbCr
import MenuMac.EasySelect as E
import MenuMac.MedSelect as M
import MenuMac.HardSelect as H
import MenuMac.InfoMenu as Info
import Misc.TaskBar as TB
import Game.MatrixGame as Game

-- ** CONSTANTS **
panelSize = 8
panelScaleAmt = 1.05         -- How much original panel size scales by when mouse is hovering over
boxWidth = 192                -- "box" just refers to the entire menu container
boxLength = 128
fadeInSpeed = 0.155           -- speed of btn fade in animation in sec, change for slower/faster fade in

boxClr = (rgb 90 90 90)
titleClr = ((rgb 0 111 181), (rgb 0 61 110))
hoverClr = (rgb 232 245 252)  -- when mouse cursor is hovering over
clickClr = (rgb 172 218 242)  -- when clicking & holding down
disableClr = (rgb 170 170 170) -- when button is disabled (unable to interact with)
btnClr = (rgb 0 126 204)       -- clr for arrow
panelTopClr = (rgb 68 77 102) -- (rgb 97 109 143)  -- overkill on blue: (rgb 70 81 112)   -- more gray: (rgb 78 84 97)
panelGradient =
  gradient [ transparentStop white 10 0.975
           , transparentStop white 35 0.6
           , transparentStop white 50 0
           , transparentStop black 55 0
           , transparentStop black 70 0.4 ]

panelTextSize = 0.3
panelTextSpace = 3.75
panelTextFont = "Calibri Heavy"

descTextSize = 0.2
descTextSpace = 1.5
descTextFont = "Arial"

titleFont = "Arial"


-- ** Game Constants ** --
mediumStartIdx = 11
hardStartIdx = 15

{- ** Miscellanous Functions ** -}
boolMaybeParser maybe =
  case maybe of
    Just value -> value
    Nothing -> False

floatMaybeParser maybe =
  case maybe of
    Just value -> value
    Nothing -> 0
    
{- ** Animation Functions ** -}
-- Old exit button animation function
btnFadeIn : Float -> Float
btnFadeIn hoverTime =
  if hoverTime > fadeInSpeed then
    1
  else 
    (1 / (fadeInSpeed ^ 2)) * hoverTime ^ 2

panelGrow : Float -> Float
panelGrow hoverTime = 
  let 
    maxTime = 0.3
  in
    if hoverTime > maxTime then
      panelScaleAmt
    else
      -(panelScaleAmt - 1) * (((1 / maxTime) * (hoverTime - maxTime)) ^ 2) + panelScaleAmt

panelShrink : Float -> Float -> Float
panelShrink hoverTime lastHoverTime = 
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
      (panelScaleAmt - 1) * (((1 / maxTime1) * (hoverTime - maxTime2)) ^ 2) + 1

panelSlideDown exitTime = 
  let
    aniFunc = 
        -1500 * (exitTime ^ 4)
  in
    move (0, aniFunc)

panelSlideUp exitTime = 
  let
    aniFunc =
      if exitTime > 0.5 then
        750 * ((exitTime - 0.5) ^ 4)
      else
        0
  in
    move (0, aniFunc)
  
fadeOut exitTime = 
  let
    aniFunc =
      if exitTime > 0.25 then
        0
      else
        -16 * (exitTime ^ 2) + 1
  in
    makeTransparent aniFunc

slideRight exitTime =
  let
    aniFunc x =
      1000 * (x ^ 4)
  in
    move (aniFunc exitTime, 0)
  
slideLeft openTime = 
  let
    aniFunc x =
      if x > 1 then
        0
      else
        1000 * (x - 1) ^ 4
  in
    move (aniFunc openTime, 0)
    
titleMove exitTime = 
  let 
    aniXFunc x = 30 * cos(pi * (x + 0.6)) - 30        -- 28.5 works on arch linux
    aniYFunc x = 9 * cos(pi * (x + 0.6)) - 9 
  in 
    if exitTime < 1.4 then
      move (0, 0)
    else if exitTime > 2.4 then
      move (aniXFunc 2.4, aniYFunc 2.4) 
    else
      move (aniXFunc exitTime, aniYFunc exitTime)
  
titleScale exitTime = 
  let
    a = (1 / 2) * (725/600 - 1)                -- 725/600
    aniFunc x = -a * cos (pi * (x + 0.6)) + (1 + a)    -- -(a - 1) * ((x - 3) ^ 4) + a
  in
    if exitTime < 1.4 then
      scale 1
    else if exitTime > 2.4 then
      scale ((a * 2) + 1)
    else
      scale (aniFunc exitTime)
  
-- Gameplay screen smoothly fading in from individual level selection screen transition
gameFadeIn exitTime = 
  let
    aniFunc x =
      if exitTime >= 2.0 then
        1
      else if exitTime <= 1.4 then
        0
      else
        -(1 / 2) * cos ((pi / 0.6) * (x - 1.4)) + (1 / 2) 
  in
    makeTransparent (aniFunc exitTime)
  
{- ** String Parser ** -}
strParser : String -> Float -> Float -> String -> Shape userMsg
strParser string textSize textSpacing font = 
  let
    strLines = List.indexedMap Tuple.pair (split "\n" string)   -- Format: [(0, <str1>), (1, <str2>), ...]
    textSingle (index, str) = 
      text str
        |> customFont font
        |> centered
        |> filled black
        |> scale textSize
        |> move (0, -textSpacing * (toFloat index))   -- convert index to Float due to move() function type signature
  in
    (List.map textSingle strLines)
      |> group

{- ** BASIC SHAPE ELEMENTS ** -}
title model = 
  [ rect 110 20
      |> outlined (solid 0.5) black
      |> move (0, 4)
      |> if model.winState == ClosingNext then
           if model.exitTime < 1 then
             fadeOut 0
           else
             fadeOut (0.5 * (model.exitTime - 1))
         else
           makeTransparent 1      
  , [ text "Level Select" 
        -- |> underline
        |> centered
        |> sansserif
        |> customFont titleFont
        |> filled (second titleClr)
        |> move (0.4, -0.4)
    , text "Level Select" 
        -- |> underline
        |> centered
        |> sansserif
        |> customFont titleFont
        |> filled (first titleClr) 
    ]
      |> group
      |> addOutline (solid 0.25) black
        
  , if model.winState /= ClosingNext ||
       ( model.winState == ClosingNext &&
         model.exitTime < 0.25 ) then
      text "Select a level pack."
        |> centered
        |> italic
        |> customFont descTextFont
        |> filled black
        |> scale (0.5)
        |> move (0, -20)
        |> if model.winState == ClosingNext then
             fadeOut model.exitTime
           else
             makeTransparent 1
    else text "" |> ghost
  ]
    |> group
    |> scale (0.60)
    |> ( if model.winState == ClosingNext then
           titleScale model.exitTime
         else
           scale 1 )
    |> move (0, 48.5)
    |> if model.winState == ClosingNext then
         titleMove model.exitTime
       else
         move (0, 0)

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

-- ** Panel Shape Stuff **
panelShell =
  polygon [ (-2.4, 4.1)
              , (-2, 4.8)
              , (2, 4.8)
              , (2.4, 4.1)
              , (2.4, -3.8)
              , (2, -4.5)
              , (-2, -4.5)
              , (-2.4, -3.8) ]
    
panel bgImg panelType = 
  ( [ panelShell
        |> filled white
    , ( case panelType of
          1 -> easyLevel1
          2 -> medLevel1
          3 -> hardLevel1 
          _ -> bgImg1 )
        |> scale (1 / (panelSize * 1.5))
        |> move (-5, 0)
        |> clip (panelShell |> filled white)
    , rect (220 * 0.325) (220 * 0.325)
        |> filled (rotateGradient (pi / 2) panelGradient )
        |> move (0, -5)
--        |> makeTransparent (0.45)    -- Idea: maybe change transparency to be less when hovering over elem?
        |> scale (1 / panelSize)
        |> clip (panelShell |> filled white)
    , polygon [ (-2.4, 3.56)
              , (-2.4, 4.1)
              , (-2, 4.8)
              , (2, 4.8)
              , (2.4, 4.1)
              , (2.4, 3.56) ]
        |> filled panelTopClr
    ]
      |> group
      |> scale panelSize
      |> addOutline (solid (1 / panelSize)) black )
  :: [ line (2.4, 3.56) (-2.4, 3.56) 
         |> outlined (solid (0.15 / panelSize)) black
         |> scale panelSize  
     , roundedRect 3.75 0.05 1
         |> filled black
         |> scale panelSize
         |> move (0, -24)
    ]
    |> group
    |> move (0, -5)   -- just some more minute adjustments

panelEasy model = 
  [ panel easyLevel1 1
  , headerText "Easy"
  , panelText model.easyInfo
  , strParser pnlEasy descTextSize descTextSpace descTextFont
      |> move (0, -18)
  ]
    |> group
    |> ( if model.winState == ClosingNext then
           if model.packSelect == Easy then
             scale panelScaleAmt
           else
             scale 1
         else
           ( case model.easyState of
               Hovered ->
                 scale (panelGrow model.hoverTime)
               Clicked ->
                 scale (panelScaleAmt - 0.01)
               Shrunk ->
                 scale (panelShrink model.shrinkTime model.lastHoverTime) 
               None ->
                 scale 1 ) )
    |> if model.easyState == Clicked then
         move (-55, -0.05)
       else 
         move (-55, 0)    

panelMed model = 
  [ panel medLevel1 2
  , headerText "Medium"
  , panelText model.medInfo
  , strParser pnlMed descTextSize descTextSpace descTextFont
      |> move (0, -18)  
  ]
    |> group
    |> ( if model.winState == ClosingNext then
           if model.packSelect == Medium then
             scale panelScaleAmt
           else
             scale 1
         else
           ( case model.medState of
               Hovered ->
                 scale (panelGrow model.hoverTime)
               Clicked ->
                 scale (panelScaleAmt - 0.01)
               Shrunk ->
                 scale (panelShrink model.shrinkTime model.lastHoverTime) 
               None ->
                 scale 1 ) ) 
    |> if model.medState == Clicked then
         move (0, -0.05)
       else 
         move (0, 0)                 
  
panelHard model = 
  [ panel hardLevel1 3
  , headerText "Hard" 
  , panelText model.hardInfo 
  , strParser pnlHard descTextSize descTextSpace descTextFont
      |> move (0, -18)  
  ]
    |> group
    |> ( if model.winState == ClosingNext then
           if model.packSelect == Hard then
             scale panelScaleAmt
           else
             scale 1
         else
           ( case model.hardState of
               Hovered ->
                 scale (panelGrow model.hoverTime)
               Clicked ->
                 scale (panelScaleAmt - 0.01)
               Shrunk ->
                 scale (panelShrink model.shrinkTime model.lastHoverTime) 
               None ->
                 scale 1 ) )
    |> if model.hardState == Clicked then
           move (55, -0.05)
         else 
           move (55, 0)  

panelCollision model = 
  [ panelShell  -- easy panel
      |> ( if model.easyState == Clicked then
             filled lightBlue
           else 
             ghost )
      |> ( if model.easyState == Clicked then
             makeTransparent 0.4
           else 
             makeTransparent 0 )      
      |> scale panelSize
      |> notifyEnter (HoverPanel 1)
      |> notifyLeave (LeavePanel 1)
      |> notifyMouseDown (ClickPanel 1)
      |> notifyMouseUp (ReleaseClick 1)
      |> notifyTap (ToNextMenu 1)
      |> ( case model.easyState of
             Hovered ->
               scale (panelGrow model.hoverTime)
             Clicked ->
               scale panelScaleAmt
             Shrunk ->
               scale (panelShrink model.shrinkTime model.lastHoverTime) 
             None ->
               scale 1 ) 
      |> if model.easyState == Clicked then
           move (-55, -0.05)
         else 
           move (-55, 0)                  
  , panelShell  -- medium panel
      |> ( if model.medState == Clicked then
             filled lightBlue
           else 
             ghost )
      |> ( if model.medState == Clicked then
             makeTransparent 0.4
           else 
             makeTransparent 0 )    
      |> scale panelSize
      |> notifyEnter (HoverPanel 2)
      |> notifyLeave (LeavePanel 2) 
      |> notifyMouseDown (ClickPanel 2)      
      |> notifyMouseUp (ReleaseClick 2)
      |> notifyTap (ToNextMenu 2)
      |> ( case model.medState of
             Hovered ->
               scale (panelGrow model.hoverTime)
             Clicked ->
               scale panelScaleAmt
             Shrunk ->
               scale (panelShrink model.shrinkTime model.lastHoverTime) 
             None ->
               scale 1 )    
      |> if model.medState == Clicked then
           move (0, -0.05)
         else 
           move (0, 0)                   
  , panelShell  -- hard panel
      |> ( if model.hardState == Clicked then
             filled lightBlue
           else 
             ghost )
      |> ( if model.hardState == Clicked then
             makeTransparent 0.4
           else 
             makeTransparent 0 )    
      |> scale panelSize
      |> notifyEnter (HoverPanel 3)
      |> notifyLeave (LeavePanel 3)  
      |> notifyMouseDown (ClickPanel 3)  
      |> notifyMouseUp (ReleaseClick 3)
      |> notifyTap (ToNextMenu 3)
      |> ( case model.hardState of
             Hovered ->
               scale (panelGrow model.hoverTime)
             Clicked ->
               scale panelScaleAmt
             Shrunk ->
               scale (panelShrink model.shrinkTime model.lastHoverTime) 
             None ->
               scale 1 )       
      |> if model.hardState == Clicked then
           move (55, -0.05)
         else 
           move (55, 0)               
  ]
    |> group
    |> move (0, -9)
    
panelContain model = 
  if model.winState == ClosingNext then
    case model.packSelect of
      Easy ->
        [ panelEasy { model | easyState = Hovered }
            |> panelSlideUp model.exitTime        
        , panelMed model
            |> panelSlideDown model.exitTime
        , panelHard model 
            |> panelSlideDown model.exitTime ]
          |> group
          |> move (0, -4)
      Medium ->
        [ panelEasy model
            |> panelSlideDown model.exitTime        
        , panelMed { model | medState = Hovered }
            |> panelSlideUp model.exitTime        
        , panelHard model 
            |> panelSlideDown model.exitTime ]
          |> group
          |> move (0, -4)
      Hard ->
        [ panelEasy model
            |> panelSlideDown model.exitTime        
        , panelMed model
            |> panelSlideDown model.exitTime
        , panelHard { model | hardState = Hovered }
            |> panelSlideUp model.exitTime ]
          |> group
          |> move (0, -4)
      _ -> rect 0 0 |> ghost
  else
    [ panelEasy model
    , panelMed model
    , panelHard model
    ]
      |> group
      |> move (0, -4)
    
panelText info =
  [ strParser ((Debug.toString info.cleared) ++ "\nCLR") panelTextSize panelTextSpace panelTextFont
      |> move (-7, -34)
  , strParser ((Debug.toString info.total) ++ "\nALL") panelTextSize panelTextSpace panelTextFont
      |> move (7, -34)
  ]
    |> group
    
headerText str = -- additional factor needed for extra adjustment based on text contents
  text str
    |> centered
    |> customFont titleFont
    |> bold
--    |> sansserif                -- Linux only
    |> filled white
    |> scale 0.4
    |> move (0, 26)

border = 
  rect 192 128
    |> ghost
    |> addOutline (solid 0.5) black 
    
{-Menu Stuff-}

goHomeMenu model = 
  [ [ rect 192 128
        |> filled black
        |> makeTransparent 0.7
        |> notifyTap CloseGoHomeMenu
    , roundedRect 90 40 1
        |> filled white
        |> addOutline (solid 1) boxClr
    , text "Are you sure you want to return"
        |> centered
        |> customFont titleFont
        |> filled black
        |> scale 0.425
        |> move (0, 10)
    , text "to the home menu?"
        |> centered
        |> customFont titleFont
        |> filled black
        |> scale 0.425
        |> move (0, 4) ]
      |> group
      |> notifyMouseUp (ReleaseClick 5)
  , goHomeBtn model True
      |> move (18, -7.5)
      |> notifyTap GoHome
      |> notifyEnter (HoverGoHomeBtn 2)
      |> notifyLeave LeaveGoHomeBtn
      |> notifyMouseDown (ClickGoHomeBtn 2)
  , goHomeBtn model False
      |> move (-18, -7.5)
      |> notifyTap CloseGoHomeMenu
      |> notifyEnter (HoverGoHomeBtn 1)
      |> notifyLeave LeaveGoHomeBtn
      |> notifyMouseDown (ClickGoHomeBtn 1)
  ]
    |> group

goHomeBtn model isExitBtn =
  let
    promptText = 
      if isExitBtn then
        "Exit"
      else
        "Back"
  in
    [ roundedRect 22.5 8 1
        |> filled white
    , ( case isExitBtn of
          True ->
            roundedRect 22.5 8 1
              |> (if model.click == ClickGoHomeExit then
                    filled clickClr
                  else
                    filled hoverClr )
              |> ( if model.click == ClickGoHomeExit then
                     makeTransparent 1
                   else if model.hoverGoHomeExit then
                     makeTransparent (btnFadeIn model.hoverTime)
                   else
                     makeTransparent 0 )
          False ->
            roundedRect 22.5 8 1
              |> (if model.click == ClickGoHomeBack then
                    filled clickClr
                  else
                    filled hoverClr )
              |> ( if model.click == ClickGoHomeBack then
                     makeTransparent 1
                   else if model.hoverGoHomeBack then
                     makeTransparent (btnFadeIn model.hoverTime)
                   else
                     makeTransparent 0 )
      )
    , text promptText
        |> sansserif
        |> centered
        |> filled darkBlue
        |> scale (0.325)
        |> move (0, -1.25)
    ]
      |> group
      |> addOutline (solid 0.4) black
      |> scale (1.1)

goStageMenu model = 
  [ [ rect 192 128
        |> filled black
        |> makeTransparent 0.7
    , roundedRect 90 40 1
        |> filled white
        |> addOutline (solid 1) boxClr
    , text "Level Complete!"
        |> centered
        |> customFont titleFont
        |> filled (second titleClr)
        |> scale 0.475
        |> move (0 + 0.25, 10 - 0.25)                
    , text "Level Complete!"
        |> centered
        |> customFont titleFont
        |> filled (first titleClr)
        |> scale 0.475
        |> move (0, 10)
    , text ("Clear " ++ (timerFormat model.gameTime))
        |> centered
        |> customFont titleFont
        |> filled black
        |> scale 0.4
        |> move (0, 3) ]
      |> group
      |> notifyMouseUp (ReleaseClick 5)
  , if any (\x -> x == model.gameModel.level) [mediumStartIdx - 1, hardStartIdx - 1, 16] then
      goStageBtn model True
        |> move (0, -7.5)
        |> notifyTap CloseGoStageMenu
        |> notifyEnter (HoverGoStageBtn 1)
        |> notifyLeave LeaveGoStageBtn
        |> notifyMouseDown (ClickGoStageBtn 1)
    else
      [ goStageBtn model False
          |> move (18, -7.5)
          |> notifyTap ProceedGoStageMenu
          |> notifyEnter (HoverGoStageBtn 2)
          |> notifyLeave LeaveGoStageBtn
          |> notifyMouseDown (ClickGoStageBtn 2)
      , goStageBtn model True
          |> move (-18, -7.5)
          |> notifyTap CloseGoStageMenu
          |> notifyEnter (HoverGoStageBtn 1)
          |> notifyLeave LeaveGoStageBtn
          |> notifyMouseDown (ClickGoStageBtn 1) ]
        |> group
  ]
    |> group

goStageBtn model isExitBtn =     -- isExitBtn: False = Next Stage btn, True = Level Select btn
  let
    promptText = 
      if isExitBtn then
        "Level Select"
      else
        "Next Stage"
  in
    [ roundedRect 22.5 8 1
        |> filled white
    , ( case isExitBtn of
          True ->
            roundedRect 24 9 1
              |> (if model.click == ClickGoStageNext then
                    filled clickClr
                  else
                    filled hoverClr )
              |> ( if model.click == ClickGoStageNext then
                     makeTransparent 1
                   else if model.hoverGoStageBack then
                     makeTransparent (btnFadeIn model.hoverTime)
                   else
                     makeTransparent 0 )
          False ->
            roundedRect 24 9 1
              |> (if model.click == ClickGoStageBack then
                    filled clickClr
                  else
                    filled hoverClr )
              |> ( if model.click == ClickGoStageBack then
                     makeTransparent 1
                   else if model.hoverGoStageNext then
                     makeTransparent (btnFadeIn model.hoverTime)
                   else
                     makeTransparent 0 )
      )
    , text promptText
        |> sansserif
        |> centered
        |> filled darkBlue
        |> scale (0.3)
        |> move (0, -1.25)
    ]
      |> group
      |> addOutline (solid 0.4) black
      |> scale (1.1)

taskbar model =      -- NEW: 04/10/2023 (Copy the entire new taskbar code)
  let
    openingAniCheck = 
      (model.easyModel.winState == E.Opening && model.winState == ShowingEasy) ||
      (model.medModel.winState == M.Opening && model.winState == ShowingMed) ||
      (model.hardModel.winState == H.Opening && model.winState == ShowingHard) ||
      model.winState == ClosingNext ||
      model.winState == ClosingExit ||
      model.winState == Opening
    openGameAniCheck = 
      (model.easyModel.winState == E.ClosingNext && model.winState == ShowingEasy) ||
      (model.medModel.winState == M.ClosingNext && model.winState == ShowingMed) ||
      (model.hardModel.winState == H.ClosingNext && model.winState == ShowingHard)
  in
    group
      [ TB.barBase
      , if openingAniCheck || openGameAniCheck then
          if model.winState == ClosingExit && model.exitTime > 1 then
            [ if model.homeBtnHovered then
                TB.homeButton clickClr
                |> move (7.5,-58)
                |> ( if model.winState == PlayingGame then
                       notifyTap OpenGoHomeMenu
                     else
                       notifyTap GoHome )
                |> notifyEnter HoverHomeBtn
                |> notifyLeave UnhoverHomeBtn
              else
               TB.homeButton white
                |> move (7.5,-58)
                |> ( if model.winState == PlayingGame then
                       notifyTap OpenGoHomeMenu
                     else
                       notifyTap GoHome )
                |> notifyEnter HoverHomeBtn
                |> notifyLeave UnhoverHomeBtn
            , if model.infoBtnHovered then
                TB.infoButton clickClr
                |> move (-7.5, -58)
                |> notifyTap ShowInfo
                |> notifyEnter HoverInfoBtn
                |> notifyLeave UnhoverInfoBtn
              else
                TB.infoButton white
                |> move (-7.5, -58)
                |> notifyTap ShowInfo
                |> notifyEnter HoverInfoBtn
                |> notifyLeave UnhoverInfoBtn
            ]
              |> group
          else
            [ TB.homeButton disableClr
                |> move (7.5,-58)
            , TB.infoButton disableClr
                |> move (-7.5, -58) 
            ]
              |> group
        else
          [ if model.homeBtnHovered then
              TB.homeButton clickClr
              |> move (7.5,-58)
              |> ( if model.winState == PlayingGame then
                     notifyTap OpenGoHomeMenu
                   else
                     notifyTap GoHome )
              |> notifyEnter HoverHomeBtn
              |> notifyLeave UnhoverHomeBtn
            else
             TB.homeButton white
              |> move (7.5,-58)
              |> ( if model.winState == PlayingGame then
                     notifyTap OpenGoHomeMenu
                   else
                     notifyTap GoHome )
              |> notifyEnter HoverHomeBtn
              |> notifyLeave UnhoverHomeBtn
          , if model.infoBtnHovered then
              TB.infoButton clickClr
              |> move (-7.5, -58)
              |> notifyTap ShowInfo
              |> notifyEnter HoverInfoBtn
              |> notifyLeave UnhoverInfoBtn
            else
              TB.infoButton white
              |> move (-7.5, -58)
              |> notifyTap ShowInfo
              |> notifyEnter HoverInfoBtn
              |> notifyLeave UnhoverInfoBtn
          ]
            |> group
       , rect 192 128
       |> outlined (solid 0.7) panelTopClr
    ]

infoWindow model =
  if model.showingInfo then
    Info.myShapes model.infoModel
    |> group
    |> GraphicSVG.map InfoMsg
  else
    [] |> group

timerFormat gameTime =
  let
    ms = 
      if modBy 100 (round (gameTime * 100)) < 10 then
        "0" ++ Debug.toString (modBy 100 (round (gameTime * 100)))
      else
         Debug.toString (modBy 100 (round (gameTime * 100)))    
    sec = 
      if modBy 60 (floor gameTime) < 10 then
        "0" ++ Debug.toString (modBy 60 (floor gameTime))
      else
         Debug.toString (modBy 60 (floor gameTime))
    min =
      if modBy 60 (floor (gameTime / 60)) < 10 then
        "0" ++ Debug.toString (modBy 60 (floor (gameTime / 60)))
      else
         Debug.toString (modBy 60 (floor (gameTime / 60)))    
  in
    "Time:  " ++ min ++ ":" ++ sec ++ ":" ++ ms

timer timerText leftAlign =
  [ text timerText
      |> customFont titleFont
      |> ( if leftAlign then
             alignLeft
           else
             alignRight )
      |> filled white
      |> scale 0.38
  ]
      |> group

infoBar model =
  let 
    bestTime =
      case model.packSelect of
        Easy -> 
          floatMaybeParser (head (drop (model.gameModel.level) model.easyInfo.bestTimes))
        Medium ->
          floatMaybeParser (head (drop (model.gameModel.level - mediumStartIdx) model.medInfo.bestTimes))
        Hard ->
          floatMaybeParser (head (drop (model.gameModel.level - hardStartIdx) model.hardInfo.bestTimes))
        _ -> 0
    levelNum = 
      case model.packSelect of
        Easy ->
          "Level E-" ++ (Debug.toString (model.gameModel.level + 1))
        Medium ->
          "Level M-" ++ (Debug.toString (model.gameModel.level + 1 - mediumStartIdx))
        Hard ->
          "Level H-" ++ (Debug.toString (model.gameModel.level + 1 - hardStartIdx)) 
        _ -> "Level NULL"
  in
    [ roundedRect 195 17 10
        |> filled panelTopClr
        |> addOutline (solid 0.5) black
        |> move (0, 61)
    , timer (timerFormat model.gameTime) True
        |> move (-90, 56)
    , timer ("Best " ++ (timerFormat bestTime)) False
        |> scale (0.9)
        |> move (90, 56)  
    , text levelNum
        |> centered
        |> bold
        |> customFont titleFont
        |> filled white        
        |> scale (0.43)
        |> move (0, 55.5)
        
    ]
      |> group
      |> move (0, 0.5)

myShapes model =
  case model.winState of 
    Opening ->    
      [ MTitle.myShapes model.mTitleModel
          |> group
          |> GraphicSVG.map MTitleScreen
      , [ mainBgImg 
        , border
        , panelContain model
        , backBtn model
        , title model
        , line (-97, -64) (-97, 64)
            |> outlined (solid 0.25) black
        ]
          |> group
          |> slideLeft model.openTime
      , taskbar model 
      , infoWindow model 
      ]
    Active ->
      [ mainBgImg
      , title model
      , panelContain model
      , [ border
        , backBtn model
            |> notifyMouseUp (ReleaseClick 4)
        ]
          |> group
          |> notifyMouseUp (ReleaseClick 4)
          |> notifyLeave (ReleaseClick 5)
      , panelCollision model 
      , taskbar model 
      , infoWindow model 
      ]
    ClosingNext ->
      [ mainBgImg
      , panelContain model
          |> subtract (title model)
      , backBtn model
          |> fadeOut model.exitTime
      , title model 
      , border  
      , taskbar model 
      , infoWindow model 
      ]
    ClosingExit ->
      [ MTitle.myShapes model.mTitleModel
          |> group
          |> GraphicSVG.map MTitleScreen
      , [ mainBgImg        
        , border
        , panelContain model
        , backBtn model
        , title model
        , line (-97, -64) (-97, 64)
            |> outlined (solid 0.25) black
        ]
          |> group
          |> slideRight model.exitTime
      , taskbar model
      , infoWindow model
      ]
    ShowingEasy ->         
      if model.easyModel.exitTime <= 2 then
        if model.easyModel.winState == E.ClosingNext then
          [ E.myShapes model.easyModel 
                |> group
                |> GraphicSVG.map EasyLevels 
          , Game.myShapes model.gameModel 
                |> group
                |> scale 0.9
                |> gameFadeIn model.easyModel.exitTime
                |> GraphicSVG.map GameMsg               
          , infoBar model                     -- NEW: 04/11
              |> gameFadeIn model.easyModel.exitTime      
          , taskbar model
          , infoWindow model ]      
        else
          [ if model.goingHome then
              myShapes { model | winState = ShowingMTitle }
                |> group
            else
              myShapes { model | winState = Active }
                |> group
          , E.myShapes model.easyModel 
              |> group
              |> GraphicSVG.map EasyLevels 
          , taskbar model
          , infoWindow model ]
      else
        if model.easyModel.winState == E.ClosingNext then   -- required here for smooth transitions, since screen flickers to this state briefly
          [ Game.myShapes model.gameModel 
                |> group
                |> scale 0.9
                |> GraphicSVG.map GameMsg 
          , infoBar model                     -- NEW: 04/11                
          , taskbar model
          , infoWindow model ]
        else --if model.easyModel.winState == ClosingExit then
          myShapes { model | winState = Active }

    ShowingMed ->        
      if model.medModel.exitTime <= 2 then
        if model.medModel.winState == M.ClosingNext then
          [ M.myShapes model.medModel 
                |> group
                |> GraphicSVG.map MedLevels 
          , Game.myShapes model.gameModel 
                |> group
                |> scale 0.9
                |> gameFadeIn model.medModel.exitTime
                |> GraphicSVG.map GameMsg            
          , infoBar model                     -- NEW: 04/11
              |> gameFadeIn model.medModel.exitTime      
          , taskbar model
          , infoWindow model ]
        else
          [ if model.goingHome then
              myShapes { model | winState = ShowingMTitle }
                |> group
            else
              myShapes { model | winState = Active }
                |> group
          , M.myShapes model.medModel 
              |> group
              |> GraphicSVG.map MedLevels 
          , taskbar model
          , infoWindow model ]
      else
        if model.medModel.winState == M.ClosingNext then   -- required here for smooth transitions, since screen flickers to this state briefly
          [ Game.myShapes model.gameModel 
                |> group
                |> scale 0.9
                |> GraphicSVG.map GameMsg
          , infoBar model                     -- NEW: 04/11                
          , taskbar model
          , infoWindow model ]
        else --if model.medModel.winState == ClosingExit then
          myShapes { model | winState = Active }
    ShowingHard ->    
      if model.hardModel.exitTime <= 2 then
        if model.hardModel.winState == H.ClosingNext then
          [ H.myShapes model.hardModel 
                |> group
                |> GraphicSVG.map HardLevels 
          , Game.myShapes model.gameModel 
                |> group
                |> scale 0.9
                |> gameFadeIn model.hardModel.exitTime
                |> GraphicSVG.map GameMsg        
          , infoBar model                     -- NEW: 04/11
              |> gameFadeIn model.hardModel.exitTime
          , taskbar model
          , infoWindow model ]
        else
          [ if model.goingHome then
              myShapes { model | winState = ShowingMTitle }
                |> group
            else
              myShapes { model | winState = Active }
                |> group
          , H.myShapes model.hardModel 
              |> group
              |> GraphicSVG.map HardLevels 
          , taskbar model
          , infoWindow model ]
      else
        if model.hardModel.winState == H.ClosingNext then   -- required here for smooth transitions, since screen flickers to this state briefly
          [ Game.myShapes model.gameModel 
                |> group
                |> scale 0.9
                |> GraphicSVG.map GameMsg 
          , infoBar model                     -- NEW: 04/11                
          , taskbar model
          , infoWindow model ]
        else --if model.hardModel.winState == ClosingExit then
          myShapes { model | winState = Active }
    PlayingGame ->               -- NEW CONTENT: 04/11
      case model.packSelect of
        Easy ->
          if model.easyModel.exitTime > 2 then
            [ Game.myShapes model.gameModel 
                |> group
                |> scale 0.9
                |> GraphicSVG.map GameMsg 
            , taskbar model
            , infoWindow model
            , ( if model.showingGoStage then    -- NEW: 04/11   
                  goStageMenu model
                else 
                  rect 0 0 |> ghost )
            , infoBar model                     -- NEW: 04/11       
            , if model.showingGoHome then
                goHomeMenu model
              else
                rect 0 0 |> ghost     
            ]                  
          else
            myShapes { model | winState = ShowingEasy }
        Medium ->
          if model.medModel.exitTime > 2 then
            [ Game.myShapes model.gameModel 
                |> group
                |> scale 0.9
                |> GraphicSVG.map GameMsg 
            , taskbar model
            , infoWindow model
            , ( if model.showingGoStage then    -- NEW: 04/11   
                  goStageMenu model
                else 
                  rect 0 0 |> ghost )
            , infoBar model                     -- NEW: 04/11                
            , if model.showingGoHome then
                goHomeMenu model
              else
                rect 0 0 |> ghost            
            ]                   
          else
            myShapes { model | winState = ShowingMed }
        Hard ->
          if model.hardModel.exitTime > 2 then
            [ Game.myShapes model.gameModel 
                |> group
                |> scale 0.9
                |> GraphicSVG.map GameMsg 
            , taskbar model
            , infoWindow model
            , ( if model.showingGoStage then    -- NEW: 04/11   
                  goStageMenu model
                else 
                  rect 0 0 |> ghost )
            , infoBar model                     -- NEW: 04/11                
            , if model.showingGoHome then
                goHomeMenu model
              else
                rect 0 0 |> ghost            
            ]      
          else
            myShapes { model | winState = ShowingHard }
        _ ->
          myShapes { model | winState = Active }
    ShowingMTitle ->
      if model.mTitleModel.winState == MTitle.Credits then
        [ MTitle.myShapes model.mTitleModel
            |> group
            |> GraphicSVG.map MTitleScreen
        , taskbar model
        , infoWindow model 
        , TB.barBase      -- quick bandaid fix
            |> repaint black
            |> if model.mTitleModel.abCrModel.winState == AbCr.Opening then
                 makeTransparent (AbCr.bgFadeIn model.mTitleModel.abCrModel.time)
               else if model.mTitleModel.abCrModel.winState == AbCr.Closing then
                 makeTransparent (AbCr.bgFadeOut model.mTitleModel.abCrModel.exitTime) 
               else
                 makeTransparent 0.6 ]
      else
        [ MTitle.myShapes model.mTitleModel
            |> group
            |> GraphicSVG.map MTitleScreen
        , taskbar model
        , infoWindow model ]

type Msg = Tick Float GetKeyState
         | HoverPanel Int
         | ClickPanel Int
         | LeavePanel Int
         | ToNextMenu Int
         | ToPrevMenu
         | HoverExitBtn
         | ClickExitBtn
         | LeaveExitBtn
         | ReleaseClick Int  
         | EasyLevels E.Msg
         | MedLevels M.Msg
         | HardLevels H.Msg
         | MTitleScreen MTitle.Msg
         | ShowInfo
         | GoHome
         | InfoMsg Info.Msg
         | HoverInfoBtn
         | UnhoverInfoBtn
         | HoverHomeBtn
         | UnhoverHomeBtn
         | GameMsg Game.Msg
         | OpenGoHomeMenu
         | CloseGoHomeMenu
         | HoverGoHomeBtn Int
         | ClickGoHomeBtn Int
         | LeaveGoHomeBtn
         -- NEW: 04/11
         | ProceedGoStageMenu
         | CloseGoStageMenu
         | HoverGoStageBtn Int
         | ClickGoStageBtn Int
         | LeaveGoStageBtn


-- Leftover code from exit button, too lazy to change 
type ClickState = ClickExit
                | ClickGoHomeExit 
                | ClickGoHomeBack
                -- NEW: 04/11
                | ClickGoStageNext 
                | ClickGoStageBack                
                | ClickNone

type WinState = Opening 
              | Active
              | ClosingNext   -- after pressing panel button
              | ClosingExit   -- after pressing back button
              | ShowingMTitle
              | ShowingEasy
              | ShowingMed
              | ShowingHard
              | PlayingGame

type PanelState = Hovered
                | Clicked
                | Shrunk
                | None  

type PackSelect = Easy
                | Medium
                | Hard
                | Exit
                | PackNone

type alias Model = { time : Float 
                   , openTime : Float
                   , hoverTime : Float
                   , hoverExit : Bool 
                   , shrinkTime : Float
                   , exitTime : Float
                   , easyState : PanelState
                   , medState : PanelState
                   , hardState : PanelState
                   , easyInfo : PanelInfo
                   , medInfo : PanelInfo
                   , hardInfo : PanelInfo
                   , easyModel : E.Model
                   , easyTime : Float
                   , medModel : M.Model
                   , medTime : Float
                   , hardModel : H.Model
                   , hardTime : Float
                   , click : ClickState 
                   , packSelect : PackSelect
                   , winState : WinState 
                   , mTitleModel : MTitle.Model
                   , infoModel : Info.Model
                   , showingInfo : Bool
                   , goingHome : Bool
                   , infoBtnHovered : Bool
                   , homeBtnHovered : Bool
                   , gameModel : Game.Model    
                   , showingGoHome : Bool 
                   , hoverGoHomeExit : Bool
                   , hoverGoHomeBack : Bool 
                   , gameTime : Float
                   , lvlProgress : Bool 
                   -- NEW: 04/11
                   , showingGoStage : Bool       
                   , hoverGoStageNext : Bool
                   , hoverGoStageBack : Bool 
                   , goStageTime : Float }                    

type alias PanelInfo = { cleared : Int 
                       , total : Int }

update msg model = case msg of
                     Tick t k -> 
                       case model.winState of
                         Opening ->
                           { model | time = t
                                   , openTime = model.openTime + (t - model.time)
                                   , winState =
                                       if model.openTime >= 1 then
                                         Active
                                       else
                                         model.winState
                                   , mTitleModel = MTitle.update (MTitle.Tick t k) model.mTitleModel                                          
                                   }
                         Active ->
                           { model | time = t 
                                   , goingHome = False
                                   , hoverTime = model.hoverTime + (t - model.time)
                                   , shrinkTime = model.shrinkTime + (t - model.time) 
                                   , easyState = 
                                       if model.shrinkTime >= 0.3 && model.easyState == Shrunk then
                                         None
                                       else 
                                         model.easyState
                                   , medState = 
                                       if model.shrinkTime >= 0.3 && model.medState == Shrunk then
                                         None
                                       else 
                                         model.medState
                                   , hardState = 
                                       if model.shrinkTime >= 0.3 && model.hardState == Shrunk then
                                         None
                                       else 
                                         model.hardState 
                                    , infoModel =
                                        if model.showingInfo then
                                          Info.update (Info.Tick t k) model.infoModel
                                        else
                                          model.infoModel }
                         ShowingEasy ->
                           if model.easyModel.isExit && model.easyModel.winState == E.ClosingExit then
                             if model.goingHome then
                               { model | time = t
                                       , exitTime = 0
                                       , goingHome = False
                                       , winState = ShowingMTitle
                                       , mTitleModel = MTitle.init }
                             else
                               { model | time = t
                                       , exitTime = 0
                                       , winState = Active
                                       , mTitleModel = MTitle.init }
                           else if model.easyModel.isExit && model.easyModel.winState == E.ClosingNext then
                             case model.easyModel.levelChoose of
                               (E.Easy lvl) ->
                                 { model | time = t
                                         , winState = PlayingGame
                                         , gameModel = Game.update (Game.Level (lvl-1)) model.gameModel } --levels are 0 indexed in Matrix and 1 indexed in Easy}
                               _ ->
                                 { model | time = t
                                         , winState = PlayingGame
                                         , gameModel = Game.update (Game.Level 0) model.gameModel }
                           else
                             { model | time = t 
                                     , easyModel = E.update (E.Tick model.easyTime k) model.easyModel 
                                     , easyTime = model.easyTime + (t - model.time)
                                     , infoModel =
                                       if model.showingInfo then
                                         Info.update (Info.Tick t k) model.infoModel
                                       else
                                         model.infoModel }
                         ShowingMed ->
                           if model.medModel.isExit && model.medModel.winState == M.ClosingExit then
                             if model.goingHome then
                               { model | time = t
                                       , exitTime = 0
                                       , goingHome = False
                                       , winState = ShowingMTitle
                                       , mTitleModel = MTitle.init }
                             else
                               { model | time = t
                                       , exitTime = 0
                                       , winState = Active
                                       , mTitleModel = MTitle.init }
                           else if model.medModel.isExit && model.medModel.winState == M.ClosingNext then
                             case model.medModel.levelChoose of
                               (M.Medium lvl) ->
                                 { model | time = t
                                         , winState = PlayingGame
                                         , gameModel = Game.update (Game.Level (mediumStartIdx + lvl - 1)) model.gameModel } --levels are 0 indexed in Matrix and 1 indexed in Easy}
                               _ ->
                                 { model | time = t
                                         , winState = PlayingGame
                                         , gameModel = Game.update (Game.Level 0) model.gameModel }          
                           else
                             { model | time = t 
                                     , medModel = M.update (M.Tick model.medTime k) model.medModel 
                                     , medTime = model.medTime + (t - model.time) 
                                     , infoModel =
                                       if model.showingInfo then
                                         Info.update (Info.Tick t k) model.infoModel
                                       else
                                         model.infoModel }
                         ShowingHard ->
                           if model.hardModel.isExit && model.hardModel.winState == H.ClosingExit then
                             if model.goingHome then
                               { model | time = t
                                       , exitTime = 0
                                       , goingHome = False
                                       , winState = ShowingMTitle
                                       , mTitleModel = MTitle.init }
                             else
                               { model | time = t
                                       , exitTime = 0
                                       , winState = Active
                                       , mTitleModel = MTitle.init }
                           else if model.hardModel.isExit && model.hardModel.winState == H.ClosingNext then
                             case model.hardModel.levelChoose of
                               (H.Hard lvl) ->
                                 { model | time = t
                                         , winState = PlayingGame
                                         , gameModel = Game.update (Game.Level (hardStartIdx + lvl - 1)) model.gameModel } --levels are 0 indexed in Matrix and 1 indexed in Easy}
                               _ ->
                                 { model | time = t
                                         , winState = PlayingGame
                                         , gameModel = Game.update (Game.Level 0) model.gameModel }           
                           else
                             { model | time = t 
                                     , hardModel = H.update (H.Tick model.hardTime k) model.hardModel 
                                     , hardTime = model.hardTime + (t - model.time) 
                                     , infoModel =
                                       if model.showingInfo then
                                         Info.update (Info.Tick t k) model.infoModel
                                       else
                                         model.infoModel }
                         ClosingNext ->
                           { model | time = t
                                   , hoverTime = 0
                                   , shrinkTime = 0
                                   , winState = 
                                       if model.exitTime >= 2.5 then
                                         case model.packSelect of
                                           Easy -> ShowingEasy
                                           Medium -> ShowingMed
                                           Hard -> ShowingHard
                                           _ -> Active
                                       else 
                                         model.winState
                                   , exitTime = model.exitTime + (t - model.time) }                    
                         PlayingGame ->    -- NEW: 04/10/2023 (Replace entire PlayingGame Msg here in Mac ver.)
                           { model | time = t
                                   , hoverTime = model.hoverTime + (t - model.time)  -- NEW: 04/10/2023
                                   , shrinkTime = 0
                                   , exitTime = model.exitTime + (t - model.time)
                                   , gameModel = Game.update (Game.Tick t k) model.gameModel 
                                   , goStageTime = 
                                       if model.gameModel.levelComplete then
                                         model.goStageTime + (t - model.time)
                                       else
                                         0
                                   , showingGoStage = 
                                       if model.gameModel.levelComplete && (model.goStageTime > 1) then 
                                         True
                                       else 
                                         False
                                   , infoModel =
                                      if model.showingInfo then
                                        Info.update (Info.Tick t k) model.infoModel
                                      else
                                        model.infoModel
                                   , gameTime = 
                                       if model.gameModel.levelComplete then
                                         model.gameTime
                                       else
                                         model.gameTime + (t - model.time)
                                   , easyInfo =                 -- NEW CONTENT 04/11
                                       if model.gameModel.levelComplete && model.packSelect == Easy then
                                         if model.lvlProgress then
                                           { cleared = model.easyInfo.cleared
                                           , total = model.easyInfo.total 
                                           , bestTimes = 
                                               if (floatMaybeParser (head (drop (model.gameModel.level) model.easyInfo.bestTimes))) == 0 then
                                                 (take model.gameModel.level model.easyInfo.bestTimes) ++ [model.gameTime] ++ (drop (model.gameModel.level + 1) model.easyInfo.bestTimes)
                                               else if model.gameTime < (floatMaybeParser (head (drop (model.gameModel.level) model.easyInfo.bestTimes))) then
                                                 (take model.gameModel.level model.easyInfo.bestTimes) ++ [model.gameTime] ++ (drop (model.gameModel.level + 1) model.easyInfo.bestTimes)
                                               else
                                                 model.easyInfo.bestTimes
                                           }
                                         else
                                           { cleared = model.easyInfo.cleared + 1
                                           , total = model.easyInfo.total 
                                           , bestTimes = 
                                               if (floatMaybeParser (head (drop (model.gameModel.level) model.easyInfo.bestTimes))) == 0 then
                                                 (take model.gameModel.level model.easyInfo.bestTimes) ++ [model.gameTime] ++ (drop (model.gameModel.level + 1) model.easyInfo.bestTimes)
                                               else if model.gameTime < (floatMaybeParser (head (drop (model.gameModel.level) model.easyInfo.bestTimes))) then
                                                 (take model.gameModel.level model.easyInfo.bestTimes) ++ [model.gameTime] ++ (drop (model.gameModel.level + 1) model.easyInfo.bestTimes)
                                               else
                                                 model.easyInfo.bestTimes
                                           }
                                       else
                                         model.easyInfo
                                   , medInfo =                 -- NEW CONTENT 04/11
                                       if model.gameModel.levelComplete && model.packSelect == Medium then
                                         if model.lvlProgress then
                                           { cleared = model.medInfo.cleared  
                                           , total = model.medInfo.total 
                                           , bestTimes = 
                                               if (floatMaybeParser (head (drop (model.gameModel.level - mediumStartIdx) model.medInfo.bestTimes))) == 0 then
                                                 (take (model.gameModel.level - mediumStartIdx) model.medInfo.bestTimes) ++ [model.gameTime] ++ (drop (model.gameModel.level - mediumStartIdx + 1) model.medInfo.bestTimes)
                                               else if model.gameTime < (floatMaybeParser (head (drop (model.gameModel.level - mediumStartIdx) model.medInfo.bestTimes))) then
                                                 (take (model.gameModel.level - mediumStartIdx) model.medInfo.bestTimes) ++ [model.gameTime] ++ (drop (model.gameModel.level - mediumStartIdx + 1) model.medInfo.bestTimes)
                                               else
                                                 model.medInfo.bestTimes
                                           }
                                         else
                                           { cleared = model.medInfo.cleared + 1
                                           , total = model.medInfo.total 
                                           , bestTimes = 
                                               if (floatMaybeParser (head (drop (model.gameModel.level - mediumStartIdx) model.medInfo.bestTimes))) == 0 then
                                                 (take (model.gameModel.level - mediumStartIdx) model.medInfo.bestTimes) ++ [model.gameTime] ++ (drop (model.gameModel.level - mediumStartIdx + 1) model.medInfo.bestTimes)
                                               else if model.gameTime < (floatMaybeParser (head (drop (model.gameModel.level - mediumStartIdx) model.medInfo.bestTimes))) then
                                                 (take (model.gameModel.level - mediumStartIdx) model.medInfo.bestTimes) ++ [model.gameTime] ++ (drop (model.gameModel.level - mediumStartIdx + 1) model.medInfo.bestTimes)
                                               else
                                                 model.medInfo.bestTimes
                                           }
                                       else
                                         model.medInfo
                                   , hardInfo =                 -- NEW CONTENT 04/11
                                       if model.gameModel.levelComplete && model.packSelect == Hard then
                                         if model.lvlProgress then
                                           { cleared = model.hardInfo.cleared
                                           , total = model.hardInfo.total 
                                           , bestTimes = 
                                               if (floatMaybeParser (head (drop (model.gameModel.level - hardStartIdx) model.hardInfo.bestTimes))) == 0 then
                                                 (take (model.gameModel.level - hardStartIdx) model.hardInfo.bestTimes) ++ [model.gameTime] ++ (drop (model.gameModel.level - hardStartIdx + 1) model.hardInfo.bestTimes)
                                               else if model.gameTime < (floatMaybeParser (head (drop (model.gameModel.level - hardStartIdx) model.hardInfo.bestTimes))) then
                                                 (take (model.gameModel.level - hardStartIdx) model.hardInfo.bestTimes) ++ [model.gameTime] ++ (drop (model.gameModel.level - hardStartIdx + 1) model.hardInfo.bestTimes)
                                               else
                                                 model.hardInfo.bestTimes
                                           }
                                         else
                                           { cleared = model.hardInfo.cleared + 1
                                           , total = model.hardInfo.total 
                                           , bestTimes = 
                                               if (floatMaybeParser (head (drop (model.gameModel.level - hardStartIdx) model.hardInfo.bestTimes))) == 0 then
                                                 (take (model.gameModel.level - hardStartIdx) model.hardInfo.bestTimes) ++ [model.gameTime] ++ (drop (model.gameModel.level - hardStartIdx + 1) model.hardInfo.bestTimes)
                                               else if model.gameTime < (floatMaybeParser (head (drop (model.gameModel.level - hardStartIdx) model.hardInfo.bestTimes))) then
                                                 (take (model.gameModel.level - hardStartIdx) model.hardInfo.bestTimes) ++ [model.gameTime] ++ (drop (model.gameModel.level - hardStartIdx + 1) model.hardInfo.bestTimes)
                                               else
                                                 model.hardInfo.bestTimes
                                           }
                                       else
                                         model.hardInfo
                                   , lvlProgress = 
                                       if model.gameModel.levelComplete && model.lvlProgress == False then
                                         True
                                       else
                                         model.lvlProgress
                                   }
                         
                         ClosingExit ->
                           { model | time = t
                                   , hoverTime = 0
                                   , shrinkTime = 0
                                   , winState = 
                                       if model.exitTime >= 1 then
                                         ShowingMTitle
                                       else
                                         model.winState
                                   , exitTime = model.exitTime + (t - model.time)
                                   , mTitleModel = MTitle.update (MTitle.Tick t k) model.mTitleModel 
                                   }     
                                   
                         ShowingMTitle ->
                           if model.mTitleModel.isExit && model.mTitleModel.winState == MTitle.ClosingNext then
                             { model | time = t
                                     , openTime = 0
                                     , winState = Opening }
                           else
                             { model | time = t 
                                     , goingHome = False
                                     , infoModel =
                                        if model.showingInfo then
                                          Info.update (Info.Tick t k) model.infoModel
                                        else
                                          model.infoModel                    
                                     , mTitleModel = MTitle.update (MTitle.Tick t k) model.mTitleModel 
                                     }
                         
                     HoverPanel panelNum -> 
                       if model.click /= ClickExit && (all (\x -> x /= Clicked) [model.easyState, model.medState, model.hardState]) then
                         case panelNum of  -- 1 for Easy, 2 for Medium, 3 for Hard
                           1 ->           
                             { model | hoverTime = 0
                                     , easyState = Hovered
                                     , medState = if model.medState == Shrunk then model.medState else None
                                     , hardState = if model.hardState == Shrunk then model.hardState else None
                                     , hoverExit = False }
                           2 ->
                             { model | hoverTime = 0
                                     , easyState = if model.easyState == Shrunk then model.easyState else None
                                     , medState = Hovered
                                     , hardState = if model.hardState == Shrunk then model.hardState else None
                                     , hoverExit = False }
                           3 ->
                             { model | hoverTime = 0
                                     , easyState = if model.easyState == Shrunk then model.easyState else None
                                     , medState = if model.medState == Shrunk then model.medState else None
                                     , hardState = Hovered 
                                     , hoverExit = False }
                           _ -> model
                       else
                         model
                     
                     ClickPanel panelNum ->
                       case panelNum of
                         1 ->           
                           { model | easyState = Clicked
                                   , medState = if model.medState == Shrunk then model.medState else None
                                   , hardState = if model.hardState == Shrunk then model.hardState else None 
                                   , hoverExit = False }
                         2 ->
                           { model | easyState = if model.easyState == Shrunk then model.easyState else None
                                   , medState = Clicked
                                   , hardState = if model.hardState == Shrunk then model.hardState else None
                                   , hoverExit = False }
                         3 ->
                           { model | easyState = if model.easyState == Shrunk then model.easyState else None
                                   , medState = if model.medState == Shrunk then model.medState else None
                                   , hardState = Clicked 
                                   , hoverExit = False }
                         _ -> model
                     
                     LeavePanel panelNum ->
                       case panelNum of
                         1 ->           
                           { model | shrinkTime = 0
                                   , lastHoverTime = model.hoverTime
                                   , easyState = Shrunk }
                         2 ->
                           { model | shrinkTime = 0
                                   , lastHoverTime = model.hoverTime
                                   , medState = Shrunk }
                         3 ->
                           { model | shrinkTime = 0
                                   , lastHoverTime = model.hoverTime
                                   , hardState = Shrunk }
                         _ -> model
                     HoverExitBtn ->
                       if model.click == ClickNone then
                         { model | hoverExit = True 
                                 , easyState = if model.easyState == Shrunk then model.easyState else None
                                 , medState = if model.medState == Shrunk then model.medState else None
                                 , hardState = if model.hardState == Shrunk then model.hardState else None
                                 , hoverTime = 0 }
                       else
                         model
                     
                     ClickExitBtn ->
                       { model | click = ClickExit
                               , easyState = if model.easyState == Shrunk then model.easyState else None
                               , medState = if model.medState == Shrunk then model.medState else None
                               , hardState = if model.hardState == Shrunk then model.hardState else None                    
                               , hoverExit = False }
                     
                     LeaveExitBtn ->
                       { model | hoverExit = False }
                     
                     ReleaseClick elemNum ->   -- elemNum: 1 = easyPanel, 2 = medPanel, 3 = hardPanel, 4 = exitBtn, 5 = anything else
                       { model | click = ClickNone
                               , easyState = 
                                   if (any (\x -> model.easyState == x) [Clicked, Hovered, Shrunk]) then
                                     if elemNum /= 1 then Shrunk
                                     else Hovered
                                   else None
                               , medState = 
                                   if (any (\x -> model.medState == x) [Clicked, Hovered, Shrunk]) then
                                     if elemNum /= 2 then Shrunk
                                     else Hovered
                                   else None
                               , hardState = 
                                   if (any (\x -> model.hardState == x) [Clicked, Hovered, Shrunk]) then
                                     if elemNum /= 3 then Shrunk
                                     else Hovered
                                   else None
                               , shrinkTime = if (any (\x -> x == Clicked) [model.easyState, model.medState, model.hardState]) then
                                                0
                                              else 
                                                model.shrinkTime }
                     ToPrevMenu ->
                       { model | exitTime = 0
                               , hoverExit = False 
                               , easyState = None
                               , medState = None 
                               , hardState = None 
                               , packSelect = Exit
                               , mTitleModel = MTitle.init
                               , winState = ClosingExit }
                     ToNextMenu panelNum ->
                       case panelNum of
                         1 ->
                           { model | exitTime = 0
                                   , hoverExit = False 
                                   , easyState = Hovered 
                                   , medState = None 
                                   , hardState = None 
                                   , packSelect = Easy 
                                   , winState = ClosingNext 
                                   , easyTime = 0
                                   , easyModel = E.init }
                         2 ->
                           { model | exitTime = 0
                                   , hoverExit = False 
                                   , easyState = None 
                                   , medState = Hovered
                                   , hardState = None 
                                   , packSelect = Medium
                                   , winState = ClosingNext 
                                   , medModel = M.init
                                   , medTime = 0 }   -- change later !
                         3 ->
                           { model | exitTime = 0
                                   , hoverExit = False 
                                   , easyState = None 
                                   , medState = None 
                                   , hardState = Hovered
                                   , packSelect = Hard
                                   , winState = ClosingNext 
                                   , hardModel = H.init
                                   , hardTime = 0}   -- change later !
                         _ -> model
                     MTitleScreen mTitleMsg ->
                       { model | mTitleModel = MTitle.update mTitleMsg model.mTitleModel }
                         
                     EasyLevels easyMsg ->
                       case easyMsg of
                         (E.EnterLevel lvl) ->
                           { model | easyModel = E.update easyMsg model.easyModel
                                   , gameModel = Game.update (Game.Level (lvl-1)) model.gameModel  --levels are 0 indexed in Matrix and 1 indexed in Easy
                                   , lvlProgress = boolMaybeParser (head (drop (lvl - 1) model.gameModel.completedLevels))
                                   , gameTime = 0 }
                         _ ->
                           { model | easyModel = E.update easyMsg model.easyModel }
                     MedLevels medMsg ->
                       case medMsg of
                         (M.EnterLevel lvl) ->
                           { model | medModel = M.update medMsg model.medModel
                                   , gameModel = Game.update (Game.Level (mediumStartIdx + lvl - 1)) model.gameModel 
                                   , lvlProgress = boolMaybeParser (head (drop (mediumStartIdx + lvl - 1) model.gameModel.completedLevels))
                                   , gameTime = 0 }
                         _ ->
                           { model | medModel = M.update medMsg model.medModel }
                     HardLevels hardMsg ->
                       case hardMsg of 
                         (H.EnterLevel lvl) ->
                           { model | hardModel = H.update hardMsg model.hardModel
                                   , gameModel = Game.update (Game.Level (hardStartIdx + lvl - 1)) model.gameModel
                                   , lvlProgress = boolMaybeParser (head (drop (hardStartIdx + lvl - 1) model.gameModel.completedLevels))
                                   , gameTime = 0 }
                         _ ->
                           { model | hardModel = H.update hardMsg model.hardModel }
                     ShowInfo ->
                       { model | showingInfo = True, infoModel = Info.init }
                     HoverInfoBtn ->
                       { model | infoBtnHovered = True }
                     UnhoverInfoBtn ->
                       { model | infoBtnHovered = False }
                     GoHome ->
                       case model.winState of
                         ShowingEasy ->
                           if model.easyModel.winState /= E.ClosingExit then
                             { model | easyModel = E.update E.ToPrevMenu model.easyModel 
                                     , goingHome = True }
                           else
                             model
                         ShowingMed ->
                           if model.medModel.winState /= M.ClosingExit then
                             { model | medModel = M.update M.ToPrevMenu model.medModel 
                                     , goingHome = True }
                           else
                             model
                         ShowingHard ->
                           if model.hardModel.winState /= H.ClosingExit then
                             { model | hardModel = H.update H.ToPrevMenu model.hardModel 
                                     , goingHome = True }
                           else
                             model
                         Active ->         -- Add future specific model updates here for smoother animation in other modules
                           { model | winState = ClosingExit
                                   , exitTime = 0
                                   , openTime = 0
                                   , mTitleModel = MTitle.init 
                                   , goingHome = True }
                         ShowingMTitle ->
                           model
                         _ ->
                           { model | winState = ShowingMTitle
                                   , mTitleModel = MTitle.init 
                                   , goingHome = True 
                                   , showingGoHome = False    
                                   , click = ClickNone }      
                     HoverHomeBtn ->
                       { model | homeBtnHovered = True }
                     UnhoverHomeBtn ->
                       { model | homeBtnHovered = False }
                     InfoMsg infoMsg -> 
                       case infoMsg of
                         Info.ClickExitBtn ->
                           { model | infoModel = Info.update infoMsg model.infoModel
                                   , showingInfo = False }
                         _ ->
                           { model | infoModel = Info.update infoMsg model.infoModel }
                     GameMsg gameMsg -> 
                       { model | gameModel = Game.update gameMsg model.gameModel }
                     OpenGoHomeMenu ->
                       { model | showingGoHome = True 
                               , click = ClickNone }
                     CloseGoHomeMenu ->
                       { model | showingGoHome = False 
                               , click = ClickNone }
                     HoverGoHomeBtn btnNum ->
                       if model.click == ClickNone then
                         case btnNum of
                           1 ->
                             { model | hoverGoHomeBack = True
                                     , hoverGoHomeExit = False
                                     , hoverTime = 0 }
                           2 ->
                             { model | hoverGoHomeExit = True 
                                     , hoverGoHomeBack = False
                                     , hoverTime = 0 }
                           _ ->
                             model
                       else
                         model
                     
                     ClickGoHomeBtn btnNum ->
                       case btnNum of 
                         1 ->
                           { model | click = ClickGoHomeBack
                                   , hoverGoHomeBack = False
                                   , hoverGoHomeExit = False }                         
                         2 ->
                           { model | click = ClickGoHomeExit
                                   , hoverGoHomeBack = False
                                   , hoverGoHomeExit = False }    
                         _ ->
                           model           
                     LeaveGoHomeBtn ->
                       { model | hoverGoHomeBack = False 
                               , hoverGoHomeExit = False }
                     -- NEW: 04/11
                     ProceedGoStageMenu ->                 -- Not super clear from name, but this is the msg for when you click Next Level
                       { model | showingGoStage = False
                               , gameModel = 
                                   if any (\x -> x == model.gameModel.level) [mediumStartIdx - 1, hardStartIdx - 1] then
                                     model.gameModel
                                   else
                                     Game.update (Game.Level (model.gameModel.level + 1)) model.gameModel                                     
                               , goStageTime = 0 
                               , gameTime = 0 
                               , click = ClickNone }
                     CloseGoStageMenu ->
                       let
                         eInit = E.init
                         mInit = M.init
                         hInit = H.init
                       in
                       { model | showingGoStage = False
                               , winState = -- Active
                                   case model.packSelect of
                                     Easy -> ShowingEasy
                                     Medium -> ShowingMed
                                     Hard -> ShowingHard
                                     _ -> Active         -- Just in case something wrong happens, for debugging purposes
                               , easyModel = 
                                   if model.packSelect == Easy then
                                     { eInit | levelDisplay = E.Easy (model.gameModel.level + 1)}
                                   else
                                     model.easyModel
                               , medModel = 
                                   if model.packSelect == Medium then
                                     { mInit | levelDisplay = M.Medium (model.gameModel.level + 1 - mediumStartIdx)}
                                   else
                                     model.medModel                               
                               , hardModel = 
                                   if model.packSelect == Hard then
                                     { hInit | levelDisplay = H.Hard (model.gameModel.level + 1 - hardStartIdx)}
                                   else
                                     model.hardModel                               
                               , click = ClickNone }
                     HoverGoStageBtn btnNum ->
                       if model.click == ClickNone then
                         case btnNum of
                           1 ->        -- Back to Level Select btn
                             { model | hoverGoStageBack = True
                                     , hoverGoStageNext = False
                                     , hoverTime = 0 }
                           2 ->        -- Next Level btn
                             { model | hoverGoStageNext = True 
                                     , hoverGoStageBack = False
                                     , hoverTime = 0 }
                           _ ->
                             model
                       else
                         model
                     
                     ClickGoStageBtn btnNum ->
                       case btnNum of 
                         1 ->
                           { model | click = ClickGoStageNext
                                   , hoverGoStageBack = False
                                   , hoverGoStageNext = False }                         
                         2 ->
                           { model | click = ClickGoStageBack
                                   , hoverGoStageBack = False
                                   , hoverGoStageNext = False }    
                         _ ->
                           model           
                     LeaveGoStageBtn ->
                       { model | hoverGoStageBack = False
                               , hoverGoStageNext = False }                               
                  
                       
init = { time = 0     
       , k = ((\x -> Up), (0, 0), (0, 0))  -- Not really needed currently, just here in case
       , openTime = 0        -- For opening animation
       , hoverTime = 0
       , lastHoverTime = 0
       , shrinkTime = 100
       , exitTime = 0        -- For exiting animation 
       , hoverExit = False 
       , easyState = None
       , medState = None
       , hardState = None
       , easyInfo = { cleared = 0 
                    , total = 11 
                    , bestTimes = repeat E.numLevels 0 }
       , medInfo = { cleared = 0 
                   , total = 4 
                   , bestTimes = repeat M.numLevels 0 }
       , hardInfo = { cleared = 0 
                    , total = 2 
                    , bestTimes = repeat H.numLevels 0 }
       , easyModel = E.init
       , easyTime = 0
       , medModel = M.init
       , medTime = 0
       , hardModel = H.init
       , hardTime = 0
       , click = ClickNone
       , packSelect = PackNone
       , winState = ShowingMTitle
       , mTitleModel = MTitle.init
       , infoModel = Info.init
       , showingInfo = False
       , goingHome = False
       , infoBtnHovered = False
       , homeBtnHovered = False 
       , gameModel = Game.init     
       , showingGoHome = False 
       , hoverGoHomeExit = False 
       , hoverGoHomeBack = False 
       , gameTime = 0             -- Actual timerFormat running during gameplay
       , lvlProgress = False     -- For checking if current level has already been completed yet 
       -- NEW: 04/11
       , showingGoStage = False 
       , hoverGoStageNext = False 
       , hoverGoStageBack = False 
       , goStageTime = 0 }

main = gameApp Tick { model = init, view = view, update = update, title = "Matrix Mindbusters (Mac)" }

view model = collage 192 128 (myShapes model)
