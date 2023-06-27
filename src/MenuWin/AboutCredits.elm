module MenuWin.AboutCredits exposing (..)

-- Coded by Alex Chen

import Tuple exposing (first, second)
import String exposing (split)

-- MacCASOutreach imports
import GraphicSVG exposing (..)
import GraphicSVG.App exposing (..)

-- Local imports
import Misc.MatrixStrings exposing (..)

-- Constants
boxWidth = 170                    -- NOTE: "box" just refers to the external menu container 
boxLength = 100
boxClr = (rgb 90 90 90)
titleClr = ((rgb 0 111 181), (rgb 0 61 110))
divClr = (rgb 90 90 90)           -- Redundant, remove and just use boxClr later
btnClr = (rgb 0 126 204)
shadeClr = (rgb 242 244 245)      -- Colour of unselected & unhovered tabs    
shadeClr2 = (rgb 249 249 249)     -- Shading for body text animation
hoverClr = (rgb 232 245 252)   -- or less blue colour: (rgb 235 243 247)
clickClr = (rgb 172 218 242)

-- Tab coordinate-related constants (tab#X = x coordinates of left and right lines of a tab, relative to menu width)
space = boxWidth / 2
tab1X = ( (-(boxWidth / 2) + 1, 0), (0, 0) )
tab2X = ( (0, 0), ((boxWidth / 2) - 1, 0) )
-- tab3X = ( (-(boxWidth / 2) + (space * 2) + (1/5), 0), ((boxWidth / 2) - (space * 2) - (1/10), 0) )
-- tab4X = ( ((boxWidth / 2) - (space * 2) - (1/5), 0), ((boxWidth / 2) - space - (3/5), 0) )
-- tab5X = ( ((boxWidth / 2) - space - (3/5), 0), ((boxWidth / 2) - 1, 0) )
tabSpeed = 0.155      -- speed of tab open animation in sec.

-- Tab Labels (from left to right)
lbl1 = "About"
lbl2 = "Credits"
lblSize = 0.4

-- Body text settings
textSizeAbout = 0.29
textSizeCredits = 0.4
textSpacingAbout = 2.7
textSpacingCredits = 5
bodySpeed = 0.3       -- speed of body text changing animation in sec.

-- ~~ To make things easier in the long run when inputting info ~~

strAboutPt1 =
  """
   You may have learned about Transformation Matrices in your linear algebra class. To\n
refresh your memory, a transformation matrix is the matrix A such that:
  """
  
strAboutPt2 = 
  """
T(x) = Ax
  """

strAboutPt3 =
  """
   ...where T is a linear transformation, and x is a matrix.\n\n
   Essentially, it's a matrix that you can right-multiply with a given matrix or vector to apply\n
some transformation to it. In this game, you’ll be shown a shape—which is really just a bunch\n
of points stored as a coordinate vector. You’ll learn to associate changes in the transformation\n
matrix with actual visual transformations as you edit the transformation matrix to match our\n
shape with the gray outline. Have fun!

  """

strCredits =
  """
Menu UI Design & Implementation: Loic Sinclair, Alex Chen\n\n
Gameplay Implementation: Jacob Armstrong\n\n
Text Content & Level Design: Lu Yan, Norah Muqbel\n\n
  """

textAbout = 
  [ strParser strAboutPt1 textSizeAbout textSpacingAbout False
      |> move (-(boxWidth / 2) + 10, 15)
  , strParser strAboutPt2 (textSizeAbout + 0.225) textSpacingAbout True
      |> move (0, 0)
  , strParser strAboutPt3 textSizeAbout textSpacingAbout False
      |> move (-(boxWidth / 2) + 10, -8)
  ]
    |> group
      
textCredits = 
  strParser strCredits textSizeCredits textSpacingCredits False
    |> move (-(boxWidth / 2) + 10, 8)
    
{- Takes a block of string with every new line separated by \n and converts it
 - into a list of GraphicSVG text lines, just for convenience
 - (also saves a LOT of time and code space from having to manually search and 
 -  edit each line throughout a program bloated with repeated text functions;
 -  instead, keep all text strings in a separate module and import them into here,
 -  then run this function for easy conversion)
 -}
strParser : String -> Float -> Float -> Bool -> Shape userMsg
strParser string textSize textSpacing isEqnFont = 
  let
    strLines = List.indexedMap Tuple.pair (split "\n" string)   -- Format: [(0, <str1>), (1, <str2>), ...]
    textSingle (index, str) = 
      if isEqnFont then
        text str
          |> centered
          |> italic
          |> bold
          |> filled black
          |> scale textSize
          |> move (0, -textSpacing * (toFloat index))   -- convert index to Float due to move() function type signature      
      else
        text str
          |> sansserif
          |> customFont "Bahnschrift Light"
          |> filled black
          |> scale textSize
          |> move (0, -textSpacing * (toFloat index))   -- convert index to Float due to move() function type signature
  in
    (List.map textSingle strLines)
      |> group

-- Main body text and elements
body model = 
  case model.tabState of
    Tab1 -> textAbout
    Tab2 -> textCredits
    _ -> text "" |> ghost

-- ~~ Functions Involving Animations ~~
winFadeIn time =
  if time > 0.1 then
    1
  else 
    (1 / (0.1 ^ 2)) * time ^ 2
    
winFadeOut exitTime = 
  if exitTime > 1 then
    0
  else
    (exitTime - 1) ^ 2
    
winSlideIn time = 
  if time > 0.2 then
    0
  else
    -1 * ((10 * time) - 2) ^ 2
    
winSlideOut time = 
  if time > 0.2 then
    -4
  else
    -1 * (10 * time) ^ 2    
    
bgFadeIn time = 
  if time > 0.1 then
    0.6
  else 
    (0.6 / (0.1 ^ 2)) * (time ^ 2)

bgFadeOut exitTime =
  if exitTime > 1 then
    0
  else
    -0.6 * (exitTime) ^ 2 + 0.6
    
tabFadeIn hoverTime =
  if hoverTime > tabSpeed then
    1
  else 
    (1 / (tabSpeed ^ 2)) * hoverTime ^ 2

tabOpen openTime coords =
  let
    openFunc y = -(10 / (tabSpeed ^ 2)) * (y - tabSpeed) ^ 2 + 10  
    textPosX oldCoords = ((first (first oldCoords)) + (first (second oldCoords))) / 2
    newCoords oldCoords = 
      if openTime < tabSpeed then
        ( (first (first oldCoords), openFunc openTime)
        , (first (second oldCoords), openFunc openTime) )
      else
        ( (first (first oldCoords), 10)
        , (first (second oldCoords), 10) )
  in
    [ polygon [ (first (first coords), 10)
              , (first coords)
              , (second coords)
              , (first (second coords), 10) ] 
      |> filled shadeClr
    , text (tabOpenLbl coords)
        |> centered
        |> sansserif
        |> customFont "Bahnschrift"
        |> filled black
        |> scale (lblSize)
        |> move (textPosX coords, 3)
        |> subtract (tabOpenAux coords newCoords openTime)
    , tabOpenAux coords newCoords openTime
    , text (tabOpenLbl coords)
        |> centered
        |> sansserif
        |> customFont "Bahnschrift"        
        |> filled (first titleClr)
        |> scale (lblSize)
        |> move (textPosX coords, 3)
        |> clip (tabOpenAux coords newCoords openTime)]
      |> group

-- Actual moving elements in tabOpen function; put in separate function
-- so as for ease of using clip functions and adding back/foreground elements
tabOpenAux coords newCoords openTime =
  [ polygon [ (first (newCoords coords))
            , (first coords)
            , (second coords)
            , (second (newCoords coords)) ] 
      |> filled white
  , tabVertLines (newCoords coords)
  , line (first coords) (second coords)        -- thin bottom line of open tab
      |> outlined (solid 0.05) divClr
  , if openTime <= 0 then
      line (first (newCoords coords)) (second (newCoords coords))  -- shaded extra top line of open tab
        |> outlined (solid 0.25) divClr
    else
      line (first (newCoords coords)) (second (newCoords coords))  -- shaded extra top line of open tab
        |> outlined (solid 0.5) divClr
        |> move (0, -0.25) ]
    |> group

bodyOpen model =
    [ ( if model.winState == Opening then
          text "" |> ghost
        else
          body { model | tabState = model.prevTab } )
    , polygon [ (-(boxWidth / 2) + 1.5, 22)
              , ((boxWidth / 2) - 1.5, 22)
              , ((boxWidth / 2) + 1.5, -49)
              , (-(boxWidth / 2) + 1.5, -49) ]
          |> filled shadeClr2
          |> makeTransparent 0.7
    , bodyOpenAux model
    , body model
        |> clip (bodyOpenAux model)
    ]
      |> group

bodyOpenAux model =
  let
    openTime = model.openTime  -- since i'm a lazy bastard & i already wrote code using openTime, so eh
    openFunc y = 
      if y >= bodySpeed then        -- change this y value (& appear. in else) to adjust animation time
        -48.5
      else
        (71 / (bodySpeed ^ 2)) * (y - bodySpeed) ^ 2 - 48.5
    changeY1 = (-(boxWidth / 2) + 1.5, openFunc openTime)
    changeY2 = ((boxWidth / 2) - 1.5, openFunc openTime)
  in
    [ polygon [ (-(boxWidth / 2) + 1.5, 22.5)
                , ((boxWidth / 2) - 1.5, 22.5)
                , changeY2
                , changeY1 ]
          |> filled white
      , line changeY1 changeY2
          |> (if openTime <= 0 then ghost
             else outlined (solid 0.5) divClr)
  --        |> clip (innerFill model)
    ]
      |> group

-- ~~ Shapes ~~
innerFill =
  roundedRect (boxWidth - 2) (boxLength - 2) 1
    |> filled white

outline = 
  roundedRect (boxWidth - 2.5) (boxLength - 2.5) 1
    |> outlined (solid 1) boxClr

title = 
  [ text "About & Credits"
    |> sansserif   -- change based on final font decision
    |> centered
    |> filled (second titleClr) 
    |> move (0.4, -0.4)
  , text "About & Credits"
    |> sansserif   -- change based on final font decision
    |> centered
    |> filled (first titleClr) 
  ]
    |> group
    |> scale (0.65)
    |> move (0, 37)

divider =
  line (-(boxWidth / 2) + 1, 0) (boxWidth / 2 - 1, 0)
    |> outlined (solid 0.5) divClr
    |> move (0, 32.5)

tabs model = 
  let
    coords = 
      case model.tabState of
        Tab1 -> tab1X
        Tab2 -> tab2X
        _ -> tab1X
  in
    [ tabSpaces coords 
    , tabCollision model
    , line (-(boxWidth / 2) + 1, 0) (first coords)
          |> outlined (solid 0.25) divClr
    , line (second coords) ((boxWidth / 2) - 1, 0)
          |> outlined (solid 0.25) divClr
    , tabOpen model.openTime coords
    ]
      |> group
      |> move (0, 22.5)
      
tabOpenLbl coords =
  if coords == tab1X then 
    lbl1
  else if coords == tab2X then 
    lbl2
  else 
    ""
    
tabLbls = 
  let
    lbl lblInfo = 
      text (first lblInfo)
        |> centered
        |> sansserif
        |> customFont "Bahnschrift"
        |> filled black
        |> scale (lblSize)
        |> move ((second lblInfo), 3)
    lblList = [ (lbl1, ((first (first tab1X)) + (first (second tab1X))) / 2)
              , (lbl2, ((first (first tab2X)) + (first (second tab2X))) / 2) ]
  in
    List.map lbl lblList
      |> group
      
tabSpaces openCoords =  
  [ polygon [ (-(boxWidth / 2) + 1, 10) 
            , (-(boxWidth / 2) + 1, 0) 
            , (first openCoords)
            , (first (first openCoords), 10) ]
      |> filled shadeClr
  , polygon [ (second openCoords)
            , (first (second openCoords), 10)
            , ((boxWidth / 2) - 1, 10) 
            , ((boxWidth / 2) - 1, 0) ] 
      |> filled shadeClr  
  ]
    |> group
    |> notifyLeaveAt LeaveTab
      
tabVertLines openCoords = 
  let
    openLine x1 (x2, y2) = line (x1, 0) (x2, y2) |> outlined (solid 0.3) black
    closeLine x = line (x, 1) (x, 9) |> outlined (solid 0.1) black
    xCoords = [ 0 ]
  in
    ( List.map closeLine xCoords
      ++ [ openLine (first (first openCoords)) (first openCoords)
         , openLine (first (second openCoords)) (second openCoords)]
    )
      |> group

tabCollision model =
   ( [ polygon [ (-(boxWidth / 2) + 1, 10)
               , (-(boxWidth / 2) + 1, 0)
               , (0, 0)
               , (0, 10) ]
       |> (if model.click == ClickTab1 && model.tabState /= Tab1 then
            filled clickClr
          else
            filled hoverClr )
       |> if model.click == ClickTab1 then
            makeTransparent 1
          else if model.hoverTab == HoverTab1 && model.tabState /= Tab1 then 
            makeTransparent (tabFadeIn model.hoverTime)
          else makeTransparent 0
   , polygon [ (0, 10)
             , (0, 0)
             , (-(boxWidth / 2) + (space * 2) + (1/5), 0)
             , (-(boxWidth / 2) + (space * 2) + (1/5), 10) ]
       |> (if model.click == ClickTab2 && model.tabState /= Tab2 then
            filled clickClr
          else
            filled hoverClr )
       |> if model.click == ClickTab2 then
            makeTransparent 1
          else if model.hoverTab == HoverTab2 && model.tabState /= Tab2 then 
            makeTransparent (tabFadeIn model.hoverTime)
          else makeTransparent 0
   , tabLbls
   ] ++   -- had to duplicate in order to fix hover bug (would reset hoverClr when hovering over text)
   [ [ polygon [ (-(boxWidth / 2) + 1, 10)
               , (-(boxWidth / 2) + 1, 0)
               , (0, 0)
               , (0, 10) ]
         |> ghost
     , polygon [ (0, 10)
               , (0, 0)
               , (-(boxWidth / 2) + (space * 2) + (1/5), 0)
               , (-(boxWidth / 2) + (space * 2) + (1/5), 10) ]
         |> ghost
     ]
     |> group
     |> notifyTapAt OpenTab        -- all three msgs also take in hidden current mouseX mouseY coordinates
     |> notifyEnterAt OverTab    
     |> notifyLeaveAt LeaveTab
     |> notifyMouseDownAt ClickTab
     |> notifyMouseUp ReleaseClick
   ] )
     |> group

backBtn model = 
  [ roundedRect 18.5 7 0.3
      |> (if model.click == ClickExit then
            filled clickClr
          else 
            filled hoverClr )
      |> ( if model.click == ClickExit then
             makeTransparent 1
           else if model.hoverExit then
             makeTransparent (tabFadeIn model.hoverTime)
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
    |> addOutline (solid 0.1) black
    |> move (-(boxWidth / 2) + 9, (boxLength / 2) - 10)
    |> notifyTap ExitMenu
    |> notifyEnter OverExitBtn    
    |> notifyLeave LeaveExitBtn
    |> notifyMouseDown ClickExitBtn
    |> notifyMouseUp ReleaseClick
  
fadeIn model =
  rect 500 500    -- arbitrarily large bg, in case if screen dimensions are ever changed in the future
    |> filled black
    |> ( if model.winState == Opening then
         makeTransparent (bgFadeIn model.time)
       else if model.winState == Closing then
         makeTransparent (bgFadeOut model.exitTime)
       else
         makeTransparent 0.6
       )
    |> notifyTap ExitMenu
    
infoBox model = 
  [ [ innerFill
    , title 
    , divider
    , tabs model 
    , backBtn model
    ]
      |> group
  , bodyOpen model
  , outline
  ]
    |> group
    |> (if model.winState == Opening then
         makeTransparent (winFadeIn model.time)
       else if model.winState == Closing then
         makeTransparent (winFadeOut model.exitTime)
       else
         makeTransparent 1)
    |> clip (outline)
    |> move model.winPos

myShapes model =
  if model.winState == Closing && model.exitTime > 1 then
    []
  else
    [ [ fadeIn model
          |> notifyMouseUp ReleaseClick
      , infoBox model 
          |> notifyMouseUp ReleaseClick ]
        |> group
        |> notifyLeave ReleaseClick
    ]
  
  -- , text (Debug.toString model.hoverTab) |> filled black ]

type Msg = Tick Float GetKeyState
         | ExitMenu
         | OpenTab (Float, Float)
         | OverTab (Float, Float)
         | ClickTab (Float, Float)
         | LeaveTab (Float, Float)
         | OverExitBtn
         | ClickExitBtn
         | LeaveExitBtn
         | ReleaseClick         

type TabState = Tab1 
              | Tab2
              | None
              
type HoverTabState = HoverTab1
                   | HoverTab2
                   | HoverNone           

type ClickState = ClickTab1 
                | ClickTab2
                | ClickExit
                | ClickNone

type WinState = Opening
              | Active
              | Closing

type alias Model = { time : Float
                   , exitTime : Float
                   , isExit : Bool
                   , hoverTime : Float
                   , winPos : (Float, Float)
                   , tabState : TabState
                   , prevTab : TabState
                   , hoverTab : HoverTabState -- redundant to have own dedicated hover states, but too lazy to change
                   , click : ClickState
                   , hoverExit : Bool
                   , winState : WinState }

update msg model = case msg of
                     Tick t _ -> 
                       case model.winState of
                         Opening ->
                           if model.time > 0.1 then
                             { model | time = t
                                     , winState = Active 
                                     , winPos = (0, 0 + winSlideIn model.time) }
                           else
                             { model | time = t 
                                     , isExit = False
                                     , winPos = (0, 0 + winSlideIn model.time) }
                         Active ->
                           { model | time = t 
                                   , winPos = (0, 0 + winSlideIn model.time)
                                   , hoverTime = model.hoverTime + (t - model.time)
                                   , openTime = model.openTime + (t - model.time) }
                         Closing -> 
                           if model.exitTime < 1 then
                             { model | time = model.time
                                     , exitTime = model.exitTime + (t - model.time)
                                     , winState = Closing
                                     , prevTab = None
                                     , winPos = (0, 0 + winSlideOut model.exitTime) 
                                     , hoverTime = 0
                                     , openTime = 0
                                     , click = ClickNone
                                     , hoverTab = HoverNone }
                           else 
                             { model | isExit = True
                                     , click = ClickNone
                                     , hoverTab = HoverNone }
                     ExitMenu ->
                       { model | exitTime = 0
                               , winState = Closing }
                     OverTab (mouseX, mouseY) ->
                       if ((mouseY >= 22.5 && mouseY <= 32.5) &&
                           (model.click == ClickNone)) then
                         if ( mouseX >= (first (first tab1X)) &&
                              mouseX <= (first (second tab1X)) &&
                              model.tabState /= Tab1 ) then
                           { model | hoverTab = HoverTab1 
                                   , hoverExit = False
                                   , hoverTime = 0 }
                         else if ( mouseX >= (first (first tab2X)) &&
                                   mouseX <= (first (second tab2X)) &&
                                   model.tabState /= Tab2 ) then
                           { model | hoverTab = HoverTab2 
                                   , hoverExit = False
                                   , hoverTime = 0 }
                         else
                           { model | hoverTab = HoverNone }
                       else
                         { model | hoverTab = HoverNone }
                     OpenTab (mouseX, mouseY) ->
                       if (mouseY >= 22.5 && mouseY <= 32.5) then
                         if ( mouseX >= (first (first tab1X)) &&
                              mouseX <= (first (second tab1X)) &&
                              model.tabState /= Tab1 ) then
                           { model | tabState = Tab1 
                                   , prevTab = model.tabState
                                   , openTime = 0 
                                   , click = ClickNone
                                   , hoverTab = HoverNone }
                         else if ( mouseX >= (first (first tab2X)) &&
                                   mouseX <= (first (second tab2X)) &&
                                   model.tabState /= Tab2 ) then
                           { model | tabState = Tab2 
                                   , prevTab = model.tabState
                                   , openTime = 0
                                   , click = ClickNone
                                   , hoverTab = HoverNone }   
                         else 
                           model
                       else 
                         model
                     ClickTab (mouseX, mouseY) ->
                       if (mouseY >= 22.5 && mouseY <= 32.5) then
                         if ( mouseX >= (first (first tab1X)) &&
                              mouseX <= (first (second tab1X)) &&
                              model.tabState /= Tab1 ) then
                           { model | click = ClickTab1
                                   , hoverTab = HoverNone
                                   , hoverExit = False }
                         else if ( mouseX >= (first (first tab2X)) &&
                                   mouseX <= (first (second tab2X)) &&
                                   model.tabState /= Tab2 ) then
                           { model | click = ClickTab2
                                   , hoverTab = HoverNone
                                   , hoverExit = False }
                         else if model.click == ClickExit then
                           model
                         else
                           { model | click = ClickNone
                                   , hoverTab = HoverNone }
                       else
                         { model | click = ClickNone
                                 , hoverTab = HoverNone }
                     LeaveTab (mouseX, mouseY) ->
                       if (mouseY < 22.5 || mouseY > 32.5) || 
                          (mouseX > (boxWidth / 2) - 1 || mouseX < -(boxWidth / 2) + 1) then
                         { model | hoverTab = HoverNone }
                       else if ( mouseX >= (first (first tab1X)) &&
                                 mouseX <= (first (second tab1X)) &&
                                 model.tabState == Tab1 ) then
                         { model | hoverTab = HoverNone }
                       else if ( mouseX >= (first (first tab2X)) &&
                                 mouseX <= (first (second tab2X)) &&
                                 model.tabState == Tab2 ) then
                         { model | hoverTab = HoverNone }
                       else 
                         model
                     OverExitBtn ->
                       if model.click == ClickNone then
                         { model | hoverExit = True 
                                 , hoverTab = HoverNone
                                 , hoverTime = 0 }
                       else
                         model
                     ClickExitBtn ->
                       { model | click = ClickExit
                               , hoverExit = False
                               , hoverTab = HoverNone }
                     LeaveExitBtn ->
                       { model | hoverExit = False
                               , hoverTab = HoverNone }
                     ReleaseClick ->
                       { model | click = ClickNone }
                               
init = { time = 0 
       , exitTime = 0
       , isExit = False
       , hoverTime = 0     -- time for keeping track of tab hovering animation
       , openTime = 0      -- time for keeping track of tab opening animation
       , winPos = (0, 0)
       , tabState = Tab1
       , prevTab = None
       , hoverTab = HoverNone
       , click = ClickNone
       , hoverExit = False
       , winState = Opening
       }

main = gameApp Tick { model = init, view = view, update = update, title = "MM | About & Credits" }

view model = collage 192 128 (myShapes model)