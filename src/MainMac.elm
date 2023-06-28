module MainMac exposing (..)

-- MacCASOutreach imports
import GraphicSVG exposing (..)
import GraphicSVG.App exposing (..)

-- Local imports
import MenuMac.LvlPackSelect as MMMac

myShapes model =
  [ MMMac.myShapes model.game
      |> group
      |> GraphicSVG.map RunGame
  ]

type Msg = Tick Float GetKeyState
         | RunGame MMMac.Msg

type alias Model = { time : Float 
                   , game : MMMac.Model }

update msg model = 
  case msg of
    Tick t k -> 
      { model | time = t 
              , game = MMMac.update (MMMac.Tick t k) model.game }
    RunGame gameMsg ->
      { model | game = MMMac.update gameMsg model.game }

init = { time = 0 
       , game = MMMac.init }

main = gameApp Tick { model = init, view = view, update = update, title = "Game Slot" }

view model = collage 192 128 (myShapes model)