module MainWin exposing (..)

-- MacCASOutreach imports
import GraphicSVG exposing (..)
import GraphicSVG.App exposing (..)

-- Local imports
import MenuWin.LvlPackSelect as MMWin
myShapes model =
  [ MMWin.myShapes model.game
      |> group
      |> GraphicSVG.map RunGame
  ]

type Msg = Tick Float GetKeyState
         | RunGame MMWin.Msg

type alias Model = { time : Float 
                   , game : MMWin.Model }

update msg model = 
  case msg of
    Tick t k -> 
      { model | time = t 
              , game = MMWin.update (MMWin.Tick t k) model.game }
    RunGame gameMsg ->
      { model | game = MMWin.update gameMsg model.game }

init = { time = 0 
       , game = MMWin.init }

main = gameApp Tick { model = init, view = view, update = update, title = "Game Slot" }

view model = collage 192 128 (myShapes model)