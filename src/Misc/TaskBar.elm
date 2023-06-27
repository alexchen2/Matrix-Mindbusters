module Misc.TaskBar exposing (..)

{-A module containing graphic elements of the task bar
  Coded by Loic Sinclair-}
--Includes templates for adding new task bar buttons

-- MacCASOutreach modules
import GraphicSVG exposing (..)
import GraphicSVG.App exposing (..)

myShapes model =
  [ barBase
   , toggleButton
   |> move (0,-58)
   , infoButton white
   |> move (15,-58)
   , homeButton white
   |> move (30,-58)
   
  ]

type Msg = Tick Float GetKeyState

type alias Model = { time : Float }

update msg model = case msg of
                     Tick t _ -> { time = t }

init = { time = 0 }

main = gameApp Tick { model = init, view = view, update = update, title = "Game Slot" }

view model = collage 192 128 (myShapes model)

bttnClr1 = white
bttnClr2 = black
bttnClr3 = grey
clr1 = (rgb 232 245 252)

barBase = group
  [
  rect 300 12
  |> filled (rgb 232 245 252)
  |> move (0,-58)
  , rect 300 0.5
  |> filled (rgb 0 111 181)
 -- |> filled (rgb 68 77 102)
  |> move (0,-52)
  , rect 300 1
  |> filled (rgb 68 77 102)
  |> move (0,-64)
  , rect 1 12
  |> filled (rgb 68 77 102)
  |> move (96,-58)
  , rect 1 12
  |> filled (rgb 68 77 102)
  |> move (-96,-58)
  ]
  
blankBttn = group
  [
  roundedRect 20 20 1
  |> filled bttnClr1
  |> addOutline (solid 1) bttnClr2
  ]

homeButton colour = group
  [
  roundedRect 20 20 1
  |> filled colour
  |> addOutline (solid 1) bttnClr2
  , polygon [(0,0),(30,0),(30,18),(38,18),(15,45),(-8,18),(0,18)]
  |> filled colour
  |> scale 0.3
  |> move (-4.5,-6.5)
  |> addOutline (solid 3) bttnClr2
  ] |> scale 0.45
  
  
infoButton colour = group
  [
  roundedRect 20 20 1
  |> filled colour
  |> addOutline (solid 1) bttnClr2
  , roundedRect 4 8 1
  |> filled colour
  |> addOutline (solid 1) bttnClr2
  |> move (0, -3)
  , roundedRect 4 4 1
  |> filled colour
  |> addOutline (solid 1) bttnClr2
  |> move (0,5)
  ] |> scale 0.45
  
settingsButton = group
  [
  blankBttn
  , circle 5
  |> filled bttnClr3
  |> addOutline (solid 1) bttnClr2
  , circle 2
  |> filled bttnClr1
  |> addOutline (solid 1) bttnClr2
  ]
  
toggleButton = group
  [
  blankBttn
  , line (4,-7) (4,7)
  |> outlined (solid 1) black
  , line (-4,-7) (-4,7)
  |> outlined (solid 1) black
  , line (-7, 4) (7, 4)
  |> outlined (solid 1) black
  , line (-7, -4) (7, -4)
  |> outlined (solid 1) black
  ] |> scale 0.45