module MenuWin.MainMenu exposing (..)

-- Coded by Alex Chen & Loic Sinclair

import List exposing (drop, head, take, repeat, any, all)
import Html exposing (img, div)
import Html.Attributes exposing (style, width, src, height)
import Tuple exposing (first, second)
import String exposing (split)

-- MacCASOutreach imports
import GraphicSVG exposing (..)
import GraphicSVG.App exposing (..)

-- Local imports
import Misc.MatrixStrings exposing (mainBgImg)
import MenuWin.InfoMenu as Info
import MenuWin.AboutCredits as AbCr
import Misc.TaskBar as TB

-- ** CONSTANTS **
panelSize = 8
panelScaleAmt = 1.05         -- How much original panel size scales by when mouse is hovering over
boxWidth = 192                -- "box" just refers to the entire menu container
boxLength = 128
fadeInSpeed = 0.155           -- speed of btn fade in animation in sec, change for slower/faster fade in

titleClr = ((rgb 0 127 207), (rgb 0 61 110))
hoverClr = (rgb 232 245 252)  -- when mouse cursor is hovering over
clickClr = (rgb 172 218 242)  -- when clicking & holding down
disableClr = (rgb 170 170 170) -- when button is disabled (unable to interact with)
btnClr = (rgb 0 126 204)       -- clr for arrow
optionClr = (rgb 87 102 143) -- (rgb 68 77 102) -- (rgb 97 109 143)  -- overkill on blue: (rgb 70 81 112)   -- more gray: (rgb 78 84 97)
panelGradient =
  gradient [ transparentStop white 10 0.975
           , transparentStop white 35 0.6
           , transparentStop white 50 0
           , transparentStop black 55 0
           , transparentStop black 70 0.4 ]

panelTextSize = 0.3
panelTextSpace = 3.75
panelTextFont = "Bahnschrift Condensed"

descTextSize = 0.2
descTextSpace = 1.5
descTextFont = "Bahnschrift Light"

titleFont = "Bahnschrift"

{- ** HTML Stuff ** -}
gearSrc = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/MainMenuIcons/Setting.png"  
  
gearHTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src gearSrc] []]

gear = 
  html 2000 2000 gearHTML
    |> rotate (degrees 270)
    |> scale (0.04)
    |> move (65, 7)
  
boardSrc = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/MainMenuIcons/clipboard2B.png"  
  
boardHTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src boardSrc] []]

board = 
  html 2000 2000 boardHTML  
    |> scale (0.04)
    |> move (21.5, 7.5)

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
    aniFunc =
      1000 * (exitTime ^ 4)
  in
    move (aniFunc, 0)
  
imgFlunctuate time = 
  let
    aniFunc x = 
      -1.75 * cos (pi * x) + 1.75
  in
    move (0, aniFunc time)
  
shadeHover time = 
  let
    aniFunc x = 
      -1 * cos (pi * x) + 1
  in
    move (0, aniFunc time)  
  
optionHover : Float -> Shape userMsg -> Shape userMsg
optionHover hoverTime shape = 
  let
    aniFunc1 x = 
      if x > 0.5 then
        1.05
      else
        -(16 * 0.05) * (x - 0.5) ^ 4 + 1.05
    aniFunc2 x = 
      if x > 0.5 then
        5
      else
        -(16 * 5) * (x - 0.5) ^ 4 + 5
  in
    (scale (aniFunc1 hoverTime) shape)
      |> move (aniFunc2 hoverTime, 0)

optionShrink : Float -> Shape userMsg -> Shape userMsg
optionShrink shrinkTime shape = 
  let
    aniFunc1 x = 
      if x > 0.5 then
        1
      else
        (16 * 0.05) * (x - 0.5) ^ 4 + 1
    aniFunc2 x = 
      if x > 0.5 then
        0
      else
        (16 * 5) * (x - 0.5) ^ 4
  in
    (scale (aniFunc1 shrinkTime) shape)
      |> move (aniFunc2 shrinkTime, 0)
  
{- ** String parser without parser module ** -}
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
border = 
  rect 192 128
    |> ghost
    |> addOutline (solid 0.5) black 
    
title = 
  [ text "Matrix Mindbusters"
      |> centered
      |> bold
      |> customFont titleFont
      |> filled (second titleClr)
      |> move (0.5, 37)
  , text "Matrix Mindbusters"
      |> centered
      |> bold
      |> customFont titleFont
      |> filled (first titleClr)
      |> move (0, 37.5)
   ]
     |> group
     |> addOutline (solid 0.4) black
    
subtitle model =
  ( case model.lastHover of
     1 ->
       text "Start the game and go to level select."        
     2 -> 
       text "View the credits."
     _ ->
       text "Start the game and go to level select." )
    |> centered
    |> customFont descTextFont
    |> italic
    |> filled black
    |> scale 0.325
    |> move (0, -45)  
    
optionShell =
  polygon [ (0, 0)
          , (69, 0)
          , (76, -11.5)
          , (0, -11.5)
          ]
    |> filled optionClr
    |> addOutline (solid 0.7) black

-- Ideal coordinates when extended/hovering
--  polygon [ (0, 0)
--          , (69, 0)
--          , (76, -11.5)
--          , (0, -11.5)]

-- redundant to have in separate constant, maybe combine with optionShell
option optionText = 
  [ optionShell
  , text optionText
      |> customFont titleFont
      |> bold
      |> filled white
      |> scale (0.55)
      |> move (12.5, -8.5)
  ]
    |> group
    |> scale (0.9)
    |> move (-96, 0)
    
optionCol model =
  [ [ option ""
        |> repaint (rgb 40 40 40)
        |> move (2, -1)
    , option ""
        |> repaint (rgb 40 40 40)
        |> move (0, -1)
    , option "Start" 
    , if model.startState == Clicked then
        option ""
          |> repaint clickClr
          |> makeTransparent 0.5
      else
        rect 0 0 |> ghost
    ]
      |> group
      |> notifyEnter (HoverOption 1)
      |> notifyLeave (LeaveOption 1)
      |> notifyMouseDown (ClickOption 1)
      |> notifyMouseUp (ReleaseClick 1)
      |> notifyTap ToNextMenu
      |> case model.startState of
           Hovered ->
             optionHover model.hoverTime
           Shrunk ->
             optionShrink model.shrinkTime
           Clicked ->
             optionHover 0.15
           _ ->
             optionHover 0
      
  , [ option ""
        |> repaint (rgb 60 60 60)
        |> move (2, -21)
        |> subtract (option "About & Credits" |> move (0, -20) )
    , option ""
        |> repaint (rgb 60 60 60)
        |> move (0, -21)
        |> subtract (option "About & Credits" |> move (0, -20) )
    , option "About & Credits" 
        |> move (0, -20) 
    , if model.creditsState == Clicked then
        option ""
          |> repaint clickClr
          |> makeTransparent 0.5
          |> move (0, -20)
      else
        rect 0 0 |> ghost
    ]
      |> group
      |> notifyEnter (HoverOption 2)
      |> notifyLeave (LeaveOption 2)
      |> notifyMouseDown (ClickOption 2)
      |> notifyMouseUp (ReleaseClick 2)
      |> notifyTap ToCredits     
      |> case model.creditsState of
           Hovered ->
             optionHover model.hoverTime
           Shrunk ->
             optionShrink model.shrinkTime
           Clicked ->
             optionHover 0.15
           _ ->
             optionHover 0
  ]
    |> group
    |> scale 1.06
    |> move (6, 5)
    
{- ** Menu Stuff ** -}

taskbar model = 
  let
    animatedBtns = 
      [ TB.homeButton disableClr
          |> move (7.5,-58)
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
    disabledBtns = 
      [ TB.homeButton disableClr
          |> move (7.5,-58)
      , TB.infoButton disableClr
          |> move (-7.5, -58)
      ]
        |> group
  in
    group
      [ TB.barBase
      , if model.winState == ClosingNext then 
          disabledBtns
        else
          animatedBtns
      , rect 192 128
          |> outlined (solid 0.7) optionClr
      ]

infoWindow model =
  if model.showingInfo then
    Info.myShapes model.infoModel
    |> group
    |> GraphicSVG.map InfoMsg
  else
    [] |> group

shading = 
  oval 35 5
    |> filled black
    |> makeTransparent 0.7
    |> move (40, -37.5)

imgDisplay model =
  let
    checkFunc x = 
      x == Hovered || x == Clicked
  in
    case (checkFunc model.startState, checkFunc model.creditsState) of
      (True, False) ->
        [ shading
            |> scaleY 1.45
            |> move (0, 17)
            |> shadeHover ((model.time * 0.4) - 0.175)
        , block 
            |> imgFlunctuate (model.time * 0.4) ]
          |> group
          |> scale 1.2
          |> move (-2.5, 12.5)
      (False, True) ->
        [ shading
            |> scaleX 1.2
            |> move (-7.75, 0)
            |> shadeHover ((model.time * 0.4) - 0.175)
        , board 
            |> imgFlunctuate (model.time * 0.4)]
          |> group
          |> scale 1.2
          |> move (-5, 10)
      _ ->
        case model.lastHover of
          1 ->
            imgDisplay { model | startState = Hovered, creditsState = None }
          2 ->
            imgDisplay { model | startState = None, creditsState = Hovered }
          _ ->
            imgDisplay { model | startState = Hovered, creditsState = None }
      
block =
  [ polygon [ (0, 0)
            , (25, 0)
            , (25, -37.5)
            , (12.5, -37.5)
            , (12.5, -12.5)
            , (0, -12.5)
            ]
      |> filled red
      |> addOutline (solid 1) black 
   , polygon [ (25.8, -37)
             , (30, -32)
             , (30, 5.5)
             , (5, 5.5)
             , (0.3, 0.7)
             , (25.8, 0.7)
             ]      
      |> filled darkRed
      |> addOutline (solid 0.75) black
   , line (25, 0) (30, 5.5)
      |> outlined (solid 1.1) black
   ]
     |> group
     |> scale 0.8
     |> move (27, -7)

myShapes model =
  case model.winState of 
    Opening ->    -- Will work on opening animation later
      [ myShapes { model | winState = Active }
        |> group
      , rect 192 128
        |> ghost
      ]      
    Active ->
      [ [ mainBgImg
        , border 
        , title
        , text "A simple game to help with learning matrix transformations."
            |> centered
            |> customFont descTextFont
            |> filled black
            |> scale (0.375)
            |> move (0, 29)
        , subtitle model
        , optionCol model
        , imgDisplay model ]
          |> group
          |> notifyMouseUp (ReleaseClick 3)
--      , taskbar model
--      , infoWindow model
      ]
    ClosingNext ->
      [ myShapes { model | winState = Active }
        |> group
      , rect 192 128
        |> ghost
      ]
--      [ mainBgImg
--      , border
--      , taskbar model
--      , infoWindow model ]
    Credits ->
      [ myShapes {model | winState = Active}
          |> group
      , AbCr.myShapes model.abCrModel
          |> group
          |> GraphicSVG.map AbCrMsg 
      ]
--    _ -> 
--      [ mainBgImg
--      , border ]

type Msg = Tick Float GetKeyState
         | HoverOption Int
         | ClickOption Int
         | LeaveOption Int
         | ToNextMenu
         | ToCredits
         | ReleaseClick Int  
         | ShowInfo
--         | GoHome
         | InfoMsg Info.Msg
         | AbCrMsg AbCr.Msg
         | HoverInfoBtn
         | UnhoverInfoBtn
--         | HoverHomeBtn
--         | UnhoverHomeBtn


-- Leftover code from exit button, too lazy to change 
-- type ClickState = ClickExit
--                | ClickNone

type WinState = Opening 
              | Active
              | ClosingNext   -- after pressing panel button
              | Credits

type OptionState = Hovered
                 | Clicked
                 | Shrunk
                 | None  

type alias Model = { time : Float 
                   , k : GetKeyState
                   , hoverTime : Float
                   , lastHoverTime : Float
                   , lastHover : Float            -- 1 is Start, 2 is Credits
                   , hoverExit : Bool 
                   , shrinkTime : Float
                   , exitTime : Float
                   , isExit : Bool
                   , winState : WinState 
                   , startState : OptionState
                   , creditsState : OptionState
                   , infoModel : Info.Model
                   , abCrModel : AbCr.Model
                   , showingInfo : Bool
                   , infoBtnHovered : Bool }                   

update msg model = case msg of
                     Tick t k -> 
                       case model.winState of
                         Opening ->
                           { model | time = t
                                   , winState = Active }
                         Active ->
                           { model | time = t 
                                   , hoverTime = model.hoverTime + (t - model.time)
                                   , shrinkTime = model.shrinkTime + (t - model.time) 
                                   , startState = 
                                       if model.shrinkTime >= 0.5 && model.startState == Shrunk then
                                         None
                                       else
                                         model.startState
                                   , creditsState = 
                                       if model.shrinkTime >= 0.5 && model.creditsState == Shrunk then
                                         None
                                       else
                                         model.creditsState      
                                   , infoModel =
                                       if model.showingInfo then
                                         Info.update (Info.Tick t k) model.infoModel
                                       else
                                         model.infoModel }
                         ClosingNext ->
                           { model | time = t
                                   , hoverTime = 0
                                   , shrinkTime = 0
                                   , isExit = True
                                   , exitTime = model.exitTime + (t - model.time) }                    
                         Credits ->
                           if model.abCrModel.isExit then
                             { model | time = t 
                                     , winState = Active }
                           else
                             { model | time = t 
                                     , abCrModel = AbCr.update (AbCr.Tick t k) model.abCrModel }

--                         _ ->
--                           { model | time = t }               
                     HoverOption optionNum -> 
                       --if (all (\x -> x /= Clicked) [model.startState, model.creditsState, model.hardState]) then
                         case optionNum of  -- 1 for Start btn, 2 for Credits btn
                           1 ->           
                             { model | hoverTime = 0
                                     , lastHover = 1
                                     , startState = Hovered
                                     , creditsState = if model.creditsState == Shrunk then model.creditsState else None
                                     }
                           2 ->
                             { model | hoverTime = 0
                                     , lastHover = 2
                                     , startState = if model.startState == Shrunk then model.startState else None
                                     , creditsState = Hovered
                                     }
                           _ -> model
                       --else
                       --  model
                     ClickOption optionNum ->
                       case optionNum of
                         1 ->           
                           { model | startState = Clicked
                                   , creditsState = if model.creditsState == Shrunk then model.creditsState else None
                                   }
                         2 ->
                           { model | startState = if model.startState == Shrunk then model.startState else None
                                   , creditsState = Clicked
                                   }
                         _ -> model
                     
                     LeaveOption optionNum ->
                       case optionNum of
                         1 ->           
                           { model | shrinkTime = 0
                                   , lastHover = 1
                                   , lastHoverTime = model.hoverTime
                                   , startState = Shrunk }
                         2 ->
                           { model | shrinkTime = 0
                                   , lastHover = 2
                                   , lastHoverTime = model.hoverTime
                                   , creditsState = Shrunk }
                         _ -> model                     
                     ReleaseClick optionNum ->   -- optionNum: 1 = start btn, 2 = credits btn, any other number = anything else
                       { model | startState = 
                                   if (any (\x -> model.startState == x) [Clicked, Hovered, Shrunk]) then
                                     if optionNum /= 1 then Shrunk
                                     else Hovered
                                   else None
                               , creditsState = 
                                   if (any (\x -> model.creditsState == x) [Clicked, Hovered, Shrunk]) then
                                     if optionNum /= 2 then Shrunk
                                     else Hovered
                                   else None
                               , shrinkTime = 
                                   if (any (\x -> x == Clicked) [model.startState, model.creditsState]) then
                                     0
                                   else 
                                     model.shrinkTime 
                               , lastHover = 
                                   if optionNum == 1 then 1
                                   else if optionNum == 2 then 2
                                   else model.lastHover
                               }
                     ToNextMenu ->
                       { model | exitTime = 0
                               , winState = ClosingNext }
                     ToCredits ->
                       { model | winState = Credits 
                               , abCrModel = AbCr.init }
                     ShowInfo ->
                       { model | showingInfo = True, infoModel = Info.init }
                     HoverInfoBtn ->
                       { model | infoBtnHovered = True }
                     UnhoverInfoBtn ->
                       { model | infoBtnHovered = False }
--                     GoHome ->
--                       case model.winState of
--                         Opening -> model
--                         Active -> model
--                         _ ->         -- Add future specific model updates here for smoother animation in other modules
--                           { model | winState = Active }
--                     HoverHomeBtn ->
--                       { model | homeBtnHovered = True }
--                     UnhoverHomeBtn ->
--                       { model | homeBtnHovered = False }
                     InfoMsg infoMsg ->
                       { model | infoModel = Info.update infoMsg model.infoModel }
                     AbCrMsg abCrMsg ->
                       { model | abCrModel = AbCr.update abCrMsg model.abCrModel }
                  
                       
init = { time = 0    
       , hoverTime = 0
       , lastHoverTime = 0
       , lastHover = 1
       , shrinkTime = 100
       , exitTime = 0
       , hoverExit = False 
       , isExit = False
       , winState = Opening
       , startState = None
       , creditsState = None     
       , infoModel = Info.init
       , abCrModel = AbCr.init
       , showingInfo = False
       , infoBtnHovered = False }
--       , click = ClickNone       
--       , homeBtnHovered = False }

main = gameApp Tick { model = init, view = view, update = update, title = "Matrix Mindbusters" }

view model = collage 192 128 (myShapes model)



