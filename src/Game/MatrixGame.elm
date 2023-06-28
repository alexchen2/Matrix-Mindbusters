module Game.MatrixGame exposing (..)

-- Coded by Jacob Armstrong; level design by Lu Yan

-- MacCASOutreach imports
import GraphicSVG exposing (..)
import GraphicSVG.App exposing (..)

grey = (rgb 130 130 130)
lightgrey = (rgb 220 220 220)

--customization

------------------------------------------------------------

--complex goal
--goal = [-1,-0.5,3,-0.5,1,2] 
--editable = [True,True,True,True,True,True]

--easy movement goal
--goal = [-2,0,3,0,1,0]
--editable = [True,True,True,True,True,True]

--movement + scaling goal
--goal = [2,0,-5,0,2,-5]
--editable = [True,False,True,False,True,True]

{-
  goal = [-1,0,3,0,1,2]
  , goalRot = (1/4)
  , rotShow = True
  , editable = [True,True,True,True,True,True]
  , shape = [(-10,20), (-10,-10), (10,-10), (10,0), (0,0), (0,20)]
  , dots = [(-5,15), (-5,5), (-5,-5), (5,-5)]
  , pulseInit = False
  -}

levels =
  [
  
  --EASY LEVELS
  
  --level 1
  {
  goal = [3,0,0,0,1,0]
  , goalRot = 0
  , rotShow = False
  , editable = [True,False,False,False,False,False]
  , shape = [(-10,10), (-10,-10), (10,-10), (10,10)]
  , dots = [(-5,5), (-5,-5), (5,-5), (5,5)]
  , shapeSym = (False, False)
  , pulseInit = True
  }
  
  --level 2
  , {
  goal = [3,0,0,0,4,0]
  , goalRot = 0
  , rotShow = False
  , editable = [True,False,False,False,True,False]
  , shape = [(-10,10), (-10,-10), (10,-10), (10,10)]
  , dots = [(-5,5), (-5,-5), (5,-5), (5,5)]
  , shapeSym = (False, False)
  , pulseInit = False
  }
  
  --level 3
  , {
  goal = [1,0,3,0,1,-4]
  , goalRot = 0
  , rotShow = False
  , editable = [False,False,True,False,False,True]
  , shape = [(-10,10), (-10,-10), (10,-10), (10,10)]
  , dots = [(-5,5), (-5,-5), (5,-5), (5,5)]
  , shapeSym = (False, False)
  , pulseInit = False
  }
  
  --level 4
  , {
  goal = [2,0,-4,0,2,-4]
  , goalRot = 0
  , rotShow = False
  , editable = [True,False,True,False,True,True]
  , shape = [(-10,10), (-10,-10), (10,-10), (10,10)]
  , dots = [(-5,5), (-5,-5), (5,-5), (5,5)]
  , shapeSym = (False, False)
  , pulseInit = False
  }
  
  --level 5
  , {
  goal = [-1,0,3,0,1,3]
  , goalRot = 0
  , rotShow = False
  , editable = [True,False,True,False,True,True]
  , shape = [(-10,20), (-10,-10), (10,-10), (10,0), (0,0), (0,20)]
  , dots = [(-5,15), (-5,5), (-5,-5), (5,-5)]
  , shapeSym = (True, True)
  , pulseInit = False
  }
  
  --level 6
  , {
  goal = [-1.5,0,-3,0,-1.5,-3]
  , goalRot = 0
  , rotShow = False
  , editable = [True,False,True,False,True,True]
  , shape = [(-10,20), (-10,-10), (10,-10), (10,0), (0,0), (0,20)]
  , dots = [(-5,15), (-5,5), (-5,-5), (5,-5)]
  , shapeSym = (True, True)
  , pulseInit = False
  }
  
  --level 7
  , {
  goal = [1,1,0,0,1,0]
  , goalRot = 0
  , rotShow = False
  , editable = [False,True,False,False,False,False]
  , shape = [(-10,10), (-10,-10), (10,-10), (10,10)]
  , dots = [(-5,5), (-5,-5), (5,-5), (5,5)]
  , shapeSym = (False, False)
  , pulseInit = False
  }
  
  --level 8
  , {
  goal = [1,-1,4,0,1,4]
  , goalRot = 0
  , rotShow = False
  , editable = [False,True,True,False,False,True]
  , shape = [(-10,10), (-10,-10), (10,-10), (10,10)]
  , dots = [(-5,5), (-5,-5), (5,-5), (5,5)]
  , shapeSym = (False, False)
  , pulseInit = False
  }
  
  --level 9
  , {
  goal = [1,0,-2,-0.5,1,-4]
  , goalRot = 0
  , rotShow = False
  , editable = [False,True,True,True,False,True]
  , shape = [(-10,10), (-10,-10), (10,-10), (10,10)]
  , dots = [(-5,5), (-5,-5), (5,-5), (5,5)]
  , shapeSym = (False, False)
  , pulseInit = False
  }
  
  --level 10
  , {
  goal = [2,1,-3,0,2,2]
  , goalRot = 0
  , rotShow = False
  , editable = [True,True,True,True,True,True]
  , shape = [(-10,10), (-10,-10), (10,-10), (10,10)]
  , dots = [(-5,5), (-5,-5), (5,-5), (5,5)]
  , shapeSym = (False, False)
  , pulseInit = False
  }
  
  --level 11
  , {
  goal = [2,0,4,1,-3,3]
  , goalRot = 0
  , rotShow = False
  , editable = [True,True,True,True,True,True]
  , shape = [(-10,20), (-10,-10), (10,-10), (10,0), (0,0), (0,20)]
  , dots = [(-5,15), (-5,5), (-5,-5), (5,-5)]
  , shapeSym = (True, True)
  , pulseInit = False
  }
  
  --MEDIUM LEVELS
  
  --level 12
  , {
  goal = [1,0,4,0,1,-3]
  , goalRot = (3/4)
  , rotShow = True
  , editable = [False,False,True,False,False,True]
  , shape = [(-10,20), (-10,-10), (10,-10), (10,0), (0,0), (0,20)]
  , dots = [(-5,15), (-5,5), (-5,-5), (5,-5)]
  , shapeSym = (True, True)
  , pulseInit = False
  }
  
  --level 13
  , {
  goal = [1,0,-4,0,2,2]
  , goalRot = (7/4)
  , rotShow = True
  , editable = [True,False,True,False,True,True]
  , shape = [(-20,20), (-20,10), (-10,10), (-10,-10), (10,-10), (10,10), (20,10), (20,20)]
  , dots = [(-15,15), (15,15), (-5,15), (5,15), (5,5), (-5,5), (-5,-5), (5,-5)]
  , shapeSym = (False, True)
  , pulseInit = False
  }
  
  --level 14
  , {
  goal = [2,0,0,0,2,2]
  , goalRot = (2/4)
  , rotShow = True
  , editable = [True,False,True,False,True,True]
  , shape = [(-10,20), (-10,10), (0,10), (0,-10), (-10,-10), (-10,-20), (10,-20), (10,20)]

  , dots = [(-5,-15), (-5,15), (5,15), (5,-5), (5,5), (5,-15)]

  , shapeSym = (True, False)
  , pulseInit = False
  }
  
  --level 15
  , {
  goal = [2,0,-2,0,1,-2]
  , goalRot = (5/4)
  , rotShow = True
  , editable = [True,False,True,False,True,True]
  , shape = [(-10,20), (-10,-10), (10,-10), (10,0), (0,0), (0,20)]
  , dots = [(-5,15), (-5,5), (-5,-5), (5,-5)]
  , shapeSym = (True, True)
  , pulseInit = False
  }
  
  --HARD LEVELS
  --level 16
  , {
  goal = [2,0,2,0,3,1]
  , goalRot = (1/4)
  , rotShow = True
  , editable = [True,False,True,False,True,True]
  , shape = [(-10,20), (-10,-10), (10,-10), (10,0), (0,0), (0,20)]
  , dots = [(-5,15), (-5,5), (-5,-5), (5,-5)]
  , shapeSym = (True, True)
  , pulseInit = False
  }
  
  --level 17
  , {
  goal = [3,0,-1,0,-2,2]
  , goalRot = (7/4)
  , rotShow = True
  , editable = [True,True,True,True,True,True]
  , shape = [(-10,20), (-10,-10), (10,-10), (10,0), (0,0), (0,20)]
  , dots = [(-5,15), (-5,5), (-5,-5), (5,-5)]
  , shapeSym = (False, True)
  , pulseInit = False
  }
  
  , {
  goal = [3,0,-1,0,-2,2]
  , goalRot = (7/4)
  , rotShow = True
  , editable = [True,True,True,True,True,True]
  , shape = [(-10,20), (-10,-10), (10,-10), (10,0), (0,0), (0,20)]
  , dots = [(-5,15), (-5,5), (-5,-5), (5,-5)]
  , shapeSym = (False, True)
  , pulseInit = False
  }
  
  ]
        


rotation = 0

matrixPos = mMult (1/matrixSize) (-60,20)
matrixSize = 0.6

rotationPos = mMult (1/matrixSize) (-60,-42)
rotationSize = 0.6

gridPos = (35,0)
gridSize = 0.75
resetPos = (-60,52)
resetSize = 0.6



-----------------------------------------------------------
{-
angleFetch n = if n == 0 then
    group [text "0" |> centered |> filled grey
    |> scale 1.25
    |> move (-10, 17)]
    else if n == 1.0 then
    group [text "π" |> centered |> filled grey
    |> scale 1.25
    |> move (-10, 17)]
    else if n == 2.0 then
    group [text "2π" |> centered |> filled grey
    |> scale 1.25
    |> move (-8, 17)]
    else group [text "π" |> centered |> filled grey
    |> scale 1.1
    |> move (-10, 25)
    , polygon [(-15,23),(-5,23)] |> outlined (solid 1) grey
    , text (String.fromFloat (1/n)) |> centered |> filled grey
    |> scale 1.1
    |> move (-10, 12)]
-}

angleFetch n col = if n == 0 then
    group [text "0" |> centered |> filled col
    |> scale 1.25
    |> move (-10, 17)]
    else if n == 1.0 then
    group [text "π" |> centered |> filled col
    |> scale 1.25
    |> move (-10, 17)]
    else if n == 2.0 then
    group [text "2π" |> centered |> filled col
    |> scale 1.25
    |> move (-9, 17)]
    else if n == (1/4) then
    group [text "π" |> centered |> filled col
    |> scale 1.1
    |> move (-10, 25)
    , polygon [(-15,23),(-5,23)] |> outlined (solid 1) col
    , text "4" |> centered |> filled col
    |> scale 1.1
    |> move (-10, 12)]
    else if n == (1/2) then
    group [text "π" |> centered |> filled col
    |> scale 1.1
    |> move (-10, 25)
    , polygon [(-15,23),(-5,23)] |> outlined (solid 1) col
    , text "2" |> centered |> filled col
    |> scale 1.1
    |> move (-10, 12)]
    else if n == (3/2) then
    group [text "3π" |> centered |> filled col
    |> scale 1.1
    |> move (-10, 25)
    , polygon [(-15,23),(-5,23)] |> outlined (solid 1) col
    , text "2" |> centered |> filled col
    |> scale 1.1
    |> move (-10, 12)]
    else
    group [text (String.fromFloat (n*4)   ++  "π") |> centered |> filled col
    |> scale 1.1
    |> move (-10, 25)
    , polygon [(-15,23),(-5,23)] |> outlined (solid 1) col
    , text "4" |> centered |> filled col
    |> scale 1.1
    |> move (-10, 12)]

rotPiece t a col = group [text t |> centered |> filled col
    |> scale 1.25
    |> move (-28, 17)
    
    , angleFetch a grey]

rotateC (x,y) (mx, my) rot = (x * cos (pi*rot) - y * sin (pi*rot) + mx, x * sin (pi*rot) + y * cos (pi*rot) + my)

transformC (x,y) list rot = case list of
  [a,b,c,d,e,f] -> rotateC (a*x + b*y, d*x + e*y) (c*10, f*10) rot
  _ -> (0,0)

checkCoords (x,y) = (abs x <= 70) && (abs y <= 70)

checkShape coords matrix rot = case coords of
  [] -> True
  (x::xs) -> checkCoords (transformC x matrix rot) && checkShape xs matrix rot




myShapes model =
  [
  
    --white background
    group [
    rect 200 200 |> filled white
    
    --matrix
    , group [
    text "[      ]" |> centered |> filled grey
    |> scale 4
    |> move (0, 0)
    
    , text (String.fromFloat(index model.targetPos 0)) |> centered |> (if index model.editable 0 then filled grey else filled lightgrey)
    |> (if model.pulse then scale (1.5 * (pulseFunc model.time)) else scale 1.5)
    |> move (-25, 17)
    
    , text (String.fromFloat(index model.targetPos 1)) |> centered |> (if index model.editable 1 then filled grey else filled lightgrey)
    |> scale 1.5
    |> move (0, 17)
    
    , text (String.fromFloat(index model.targetPos 2)) |> centered |> (if index model.editable 2 then filled grey else filled lightgrey)
    |> scale 1.5
    |> move (25, 17)
    
    , text (String.fromFloat(index model.targetPos 3)) |> centered |> (if index model.editable 3 then filled grey else filled lightgrey)
    |> scale 1.5
    |> move (-25, -4)
    
    , text (String.fromFloat(index model.targetPos 4)) |> centered |> (if index model.editable 4 then filled grey else filled lightgrey)
    |> scale 1.5
    |> move (0, -4)
    
    , text (String.fromFloat(index model.targetPos 5)) |> centered |> (if index model.editable 5 then filled grey else filled lightgrey)
    |> scale 1.5
    |> move (25, -4)
    ]
    
    |> (if model.rotShow then move matrixPos else move (mAdd matrixPos (0,-40)))
    |> scale matrixSize
    
    , if model.rotShow then group [
    group [
    
    roundedRect 60 30 5 |> filled (rgb 240 240 240)
    |> move (0,55)
    , roundedRect 60 30 5 |> outlined (solid 1) grey
    |> move (0,55)
    
    , text "[      ]" |> centered |> filled grey
    |> scale 4
    |> scaleY 1.2
    |> move (0, -4)
    
    , rotPiece "cos" model.targetRot blue
    |> move (0,5)
    , rotPiece "sin" model.targetRot red
    |> move (40,5)
    , rotPiece "-sin" model.targetRot red
    |> move (0,-25)
    , rotPiece "cos" model.targetRot blue
    |> move (40,-25)
    
    
    ]
    |> move rotationPos
    |> scale rotationSize
    
    , text "θ = " |> filled (if model.levelComplete then lightgrey else grey)
    |> move (-73,-13)
    , angleFetch model.targetRot (if model.levelComplete then lightgrey else grey)
    |> move (-62,-35)
    |> scale 0.7
    
    
    ] else group []
    
    
    
    --gridlines
    , group [
    group (xlines -7 10 7),
    group (ylines -7 10 7),
    
    
    --ripple
    if model.completeTime > 0 then
    polygon (expandPoly model.shape model.dots 0 (1 + (model.time - model.completeTime)*8) (index model.goal 0) (index model.goal 4)) |> outlined (solid 1.5) grey
    |> transform ( (1, if index model.goal 4 /= 0 then index model.goal 1 / index model.goal 4 else 0, index model.goal 2 * 10 ) , (if index model.goal 0 /= 0 then index model.goal 3 / (index model.goal 0) else 0, 1 , index model.goal 5 * 10) )
    |> transform (ident |> rotateAboutT (index model.goal 2 * 10, index model.goal 5* 10) (pi*model.goalRot))
    |> makeTransparent (1 - (model.time - model.completeTime))
    else
      group []
      
    --goal
    , polygon model.shape |> filled (rgb 220 220 220)
    |> transform ( ( index model.goal 0 , index model.goal 1 , index model.goal 2 * 10 ) , ( index model.goal 3 , index model.goal 4 , index model.goal 5 * 10) )
    |> transform (ident |> rotateAboutT (index model.goal 2 * 10, index model.goal 5* 10) (pi*model.goalRot))
    , polygon (scalePoly model.shape (index model.goal 0) (index model.goal 4)) |> outlined (dashed 1) grey
    |> transform ( (1, if index model.goal 4 /= 0 then index model.goal 1 / index model.goal 4 else 0, index model.goal 2 * 10 ) , (if index model.goal 0 /= 0 then index model.goal 3 / (index model.goal 0) else 0, 1 , index model.goal 5 * 10) )
    |> transform (ident |> rotateAboutT (index model.goal 2 * 10, index model.goal 5* 10) (pi*model.goalRot))
    
    --shape
    , polygon model.shape |> filled (rgb 209 6 6)
    
    |> transform ( ( index model.matrix 0 , index model.matrix 1 , index model.matrix 2 * 10 ) , ( index model.matrix 3 , index model.matrix 4 , index model.matrix 5 * 10) )
    |> transform (ident |> rotateAboutT (index model.matrix 2 * 10, index model.matrix 5* 10) (pi*model.rotation))
    , polygon (scalePoly model.shape (index model.matrix 0) (index model.matrix 4)) |> outlined (solid 2) (rgb 184 3 3)
    
    |> transform ( (1, if index model.matrix 4 /= 0 then index model.matrix 1 / index model.matrix 4 else 0, index model.matrix 2 * 10 ) , (if index model.matrix 0 /= 0 then index model.matrix 3 / (index model.matrix 0) else 0, 1 , index model.matrix 5 * 10) ) 
    |> transform (ident |> rotateAboutT (index model.matrix 2 * 10, index model.matrix 5* 10) (pi*model.rotation))
    
    ]
    
    |> scale gridSize
    |> move gridPos
    ]
    |> notifyTap Hide
    
    
    
    --matrix buttons
    , if model.rotShow then group [
    --with rotation
    rect 20 15 |> ghost
    |> move (mAdd (-25, 22) matrixPos)
    |> notifyTap Hide
    |> notifyTap (Popup (mAdd (-25, 50) matrixPos) 0)
    |> scale matrixSize
    , rect 20 15 |> ghost
    |> move (mAdd (0, 22) matrixPos)
    |> notifyTap Hide
    |> notifyTap (Popup (mAdd (0, 50) matrixPos) 1)
    |> scale matrixSize
    , rect 20 15 |> ghost
    |> move (mAdd (25, 22) matrixPos)
    |> notifyTap Hide
    |> notifyTap (Popup (mAdd (25, 50) matrixPos) 2)
    |> scale matrixSize
    , rect 20 15 |> ghost
    |> move (mAdd (-25, 2) matrixPos)
    |> notifyTap Hide
    |> notifyTap (Popup (mAdd (-25, 30) matrixPos) 3)
    |> scale matrixSize
    , rect 20 15 |> ghost
    |> move (mAdd (0, 2) matrixPos)
    |> notifyTap Hide
    |> notifyTap (Popup (mAdd (0, 30) matrixPos) 4)
    |> scale matrixSize
    , rect 20 15 |> ghost
    |> move (mAdd (25, 2) matrixPos)
    |> notifyTap Hide
    |> notifyTap (Popup (mAdd (25, 30) matrixPos) 5)
    |> scale matrixSize
    ]
    else
    group [
    --no rotation
    rect 20 15 |> ghost
    |> move (mAdd (-25, -18) matrixPos)
    |> notifyTap Hide
    |> notifyTap (Popup (mAdd (-25, 10) matrixPos) 0)
    |> scale matrixSize
    , rect 20 15 |> ghost
    |> move (mAdd (0, -18) matrixPos)
    |> notifyTap Hide
    |> notifyTap (Popup (mAdd (0, 10) matrixPos) 1)
    |> scale matrixSize
    , rect 20 15 |> ghost
    |> move (mAdd (25, -18) matrixPos)
    |> notifyTap Hide
    |> notifyTap (Popup (mAdd (25, 10) matrixPos) 2)
    |> scale matrixSize
    , rect 20 15 |> ghost
    |> move (mAdd (-25, -38) matrixPos)
    |> notifyTap Hide
    |> notifyTap (Popup (mAdd (-25, -10) matrixPos) 3)
    |> scale matrixSize
    , rect 20 15 |> ghost
    |> move (mAdd (0, -38) matrixPos)
    |> notifyTap Hide
    |> notifyTap (Popup (mAdd (0, -10) matrixPos) 4)
    |> scale matrixSize
    , rect 20 15 |> ghost
    |> move (mAdd (25, -38) matrixPos)
    |> notifyTap Hide
    |> notifyTap (Popup (mAdd (25, -10) matrixPos) 5)
    |> scale matrixSize
    ]
    
    --reset button
    , group [
    roundedRect 20 20 3 |> (if model.reset then filled grey else filled lightgrey)
    , circle 7 |> outlined (longdash 1.25) white |> scale 1 |> move (0,0)
    , triangle 3 |> filled white |> rotate (degrees -15) |> move (-5,5)
    , triangle 3 |> filled white |> rotate (degrees 45) |> move (5,-5)
    ]
    |> scale resetSize
    |> (if model.rotShow then move resetPos else move (mAdd resetPos (0,-15)))
    |> notifyTap Reset
    |> notifyTap Hide
    
    , (if model.popup then group [
    polygon [(20,0),(50,0),(50,-20),(40,-20),(35,-25),(30,-20),(20,-20)] |> filled white
    |> addOutline (solid 1) grey
    |> move (-35,5)
    
    , (if model.t1 then triangle 6 |> filled white |> move (0,0.5) else triangle 6 |> filled white)
    |> addOutline (solid 1) grey
    |> scaleX 0.75
    |> move (5,-5)
    
    , (if model.t2 then triangle 6 |> filled white |> move (0,0.5) else triangle 6 |> filled white)
    |> addOutline (solid 1) grey
    |> scaleX -0.75
    |> move (-5,-5)
    
    , rect 11 15 |> ghost
    |> move (6.5,-5)
    |> notifyTap Add
    |> notifyMouseDown (T1 True)
    |> notifyLeave (T1 False)
    |> notifyMouseUp (T1 False)
    
    , rect 11 15 |> ghost
    |> move (-6.5,-5)
    |> notifyTap Sub
    |> notifyMouseDown (T2 True)
    |> notifyLeave (T2 False)
    |> notifyMouseUp (T2 False)
    
    ]
    |> move model.popupPos
    |> move (0, popMv model.popupTime)
    |> scale matrixSize
    else
    group [])
    
    {-
    , group [
    rect 25 10 |> filled grey
    , text "next" |> filled white
    |> move (-10.25,-3)
    ]
    |> move (80,50)
    |> notifyTap (Level (model.level + 1))
    
    , group [
    rect 43 10 |> filled grey
    , text "medium" |> filled white
    |> move (-19.5,-3)
    ]
    |> move (0,50)
    |> notifyTap (Level 11)
    -}
  
  
    {-
    , group [
    rect 10 10 |> filled grey
    , text "1" |> filled white
    |> move (-3,-4)
    ]
    |> move (-75,50)
    |> notifyTap (Level 0)
    
    , group [
    rect 10 10 |> filled grey
    , text "2" |> filled white
    |> move (-3,-4)
    ]
    |> move (-60,50)
    |> notifyTap (Level 1)
    
    , group [
    rect 10 10 |> filled grey
    , text "3" |> filled white
    |> move (-3,-4)
    ]
    |> move (-45,50)
    |> notifyTap (Level 2)
    -}
    
    
    , if model.rotShow then 
    group [
    rect 40 20 |> ghost
    |> move (-60,-7)
    |> notifyTap Hide
    |> notifyTap (Popup (-84,22) 6)
    
    , rect 50 30 |> ghost
    |> move (-60,-35)
    |> notifyTap Hide
    |> notifyTap (Popup (-84,22) 6)
    
    
    
    
    ]
    else
    group []
  ]

pulseFunc : Float -> Float
pulseFunc t = 0.25*(sin (t*3)) + 1.25
  
scalePoly list scaleX scaleY = case list of
  [] -> []
  ((x,y)::xs) -> ( [(x*scaleX,y*scaleY)] ) ++ scalePoly xs scaleX scaleY

expandPoly list1 list2 n t scaleX scaleY =
  if n >= List.length list1 then
    []
  else
    let
      item1 = index list1 (n - 1)
      item2 = index list1 n
      item3 = index list1 (n + 1)
      scaleFactor = if scaleX<0 && scaleY<0 then -1 else 1
      xd = if 2*(t1 item2) - (t1 item1) - (t1 item3) < 0 then
             -1*(scaleX / (abs scaleX))
           else
             1*(scaleX / (abs scaleX))
      yd = if 2*(t2 item2) - (t2 item1) - (t2 item3) < 0 then
             -1*(scaleY / (abs scaleY))
           else
             1*(scaleY / (abs scaleY))
      fd = if isIn list2 (mAdd item2 (xd*5,yd*5)) then
              (-xd* scaleFactor,-yd* scaleFactor)
            else
              (xd* scaleFactor,yd* scaleFactor)
    in
      ( [mAdd (t1 item2 * scaleX, t2 item2 * scaleY) (mMult t fd)] ) ++ expandPoly list1 list2 (n+1) t scaleX scaleY
             
popMv t = if t*10-2 < 0 then -((t*10-2)^2) else 0

xlines : Float -> Float -> Float -> List (Shape userMsg)
xlines n d m = if n <= m then 
             ( [line (n*d,70) (n*d,-70) |> if n == 0 then outlined (solid 1) grey else outlined (solid 0.25) grey] ) ++ xlines (n+1) d m
           else
             []

ylines : Float -> Float -> Float -> List (Shape userMsg)
ylines n d m = if n <= m then 
             ( [line (70,n*d) (-70,n*d) |> if n == 0 then outlined (solid 1) grey else outlined (solid 0.25) grey] ) ++ ylines (n+1) d m
           else
             []

type Msg = Tick Float GetKeyState
          | Popup (Float, Float) Int
          | Hide
          | Add
          | Sub
          | T1 Bool
          | T2 Bool
          | Reset
          | Level Int

type alias Model = { time : Float
                     , matrix : List (Float)
                     , popup : Bool
                     , popupPos : (Float, Float)
                     , editNum : Int
                     , popupTime : Float
                     , targetPos : List (Float)
                     , t1 : Bool
                     , t2 : Bool
                     , goal : List (Float)
                     , completeTime : Float
                     , editable : List (Bool)
                     , pulse : Bool
                     , reset : Bool
                     , shape : List (Float, Float)
                     , dots : List (Float, Float)
                     , level : Int
                     , levelComplete : Bool
                     , rotation : Float
                     , targetRot : Float
                     , goalRot : Float
                     , rotShow : Bool
                     , shapeSym : (Bool, Bool)
                     , completedLevels : List (Bool)
                     }

compare : List Float -> List Float -> Int -> List Float
compare m1 m2 n = if n > 5 then
                    []
                  else if index m1 n == index m2 n then
                    ( [index m1 n] ) ++ (compare m1 m2 (n+1))
                  else if index m1 n < index m2 n then
                    ( [(index m1 n) + 0.125] ) ++ (compare m1 m2 (n+1))
                  else
                    ( [(index m1 n) - 0.125] ) ++ (compare m1 m2 (n+1))    

compareRot r1 r2 = if r1 == r2 then
                     r1
                   else if r1 < r2 then
                     r1 + (1/32)
                   else
                     r1 - (1/32)

checkComp m1 m2 (checkx, checky) = if checkx && checky then
                                     m1 == m2
                                   else if checky then
                                     replace m1 (abs (index m1 0)) 0 == replace m2 (abs (index m2 0)) 0
                                   else if checkx then
                                     replace m1 (abs (index m1 4)) 4 == replace m2 (abs (index m2 4)) 4
                                   else
                                     replace (replace m1 (abs (index m1 0)) 0) (abs (index m1 4)) 4 == replace (replace m2 (abs (index m2 0)) 0) (abs (index m2 4)) 4

checkSolution model matrix = (checkComp matrix model.goal model.shapeSym && model.rotation == model.goalRot) || (checkComp (replace (replace matrix (-1 * index matrix 0) 0) (-1 * index matrix 4) 4) model.goal model.shapeSym && model.rotation + 1 == model.goalRot) || (checkComp (replace (replace matrix (-1 * index matrix 0) 0) (-1 * index matrix 4) 4) model.goal model.shapeSym && model.rotation - 1 == model.goalRot)

update : Msg -> Model -> Model
update msg model = case msg of
                     Tick t _ -> {
                         model |
                         time = t,
                         popupTime = model.popupTime + (t - model.time),
                         matrix = compare model.matrix model.targetPos 0,
                         rotation = compareRot model.rotation model.targetRot,
                         completedLevels = if model.levelComplete then 
                                             replace model.completedLevels True model.level
                                           else
                                             model.completedLevels
                         , completeTime = if model.levelComplete && model.completeTime == 0 then 
                                          t
                                        else
                                          model.completeTime
                         , editable = if checkSolution model model.targetPos then
                                      [False,False,False,False,False,False]
                                    else
                                      model.editable
                         , levelComplete = if checkSolution model model.matrix then
                                             True
                                           else
                                             model.levelComplete
                         , reset = if model.levelComplete then
                                      False
                                    else
                                      model.reset
                         , popup = if checkSolution model model.targetPos then
                                      False
                                    else
                                      model.popup
                       }
                     Popup (x,y) n -> if index model.editable n || n == 6 && not model.levelComplete then {
                         model |
                         popup = True,
                         popupPos = (x,y),
                         editNum = n,
                         popupTime = 0,
                         pulse = if n == 0 then False else model.pulse
                       }
                       else
                         model
                     Hide -> {model | popup = False}
                     Add -> {model | targetPos = if model.editNum == 2 || model.editNum == 5 then
                                                let
                                                  newPos = replace model.targetPos ((index model.targetPos model.editNum) + 1) model.editNum
                                                in
                                                if checkShape model.shape newPos model.targetRot then
                                                  newPos
                                                else
                                                  model.targetPos
                                                
                                                
                                              else if model.editNum < 6 then
                                                let
                                                  newPos = replace model.targetPos ((index model.targetPos model.editNum) + 0.5) model.editNum
                                                in
                                                if checkShape model.shape newPos model.targetRot then
                                                  newPos
                                                else
                                                  model.targetPos
                                              else
                                                model.targetPos
                                      , targetRot = if model.editNum == 6 then if model.targetRot < (7/4) then (if checkShape model.shape model.targetPos (model.targetRot + (1/4)) then   model.targetRot + (1/4) else model.targetRot ) else (if checkShape model.shape model.targetPos 0 then 0 else model.targetRot) else model.targetRot
                                      , rotation = if model.editNum == 6 && model.targetRot == (7/4) then (if checkShape model.shape model.targetPos 0 then (-1/4) else (7/4)) else model.rotation
                                              }
                     Sub -> {model | targetPos = if model.editNum == 2 || model.editNum == 5 then
                                                let
                                                  newPos = replace model.targetPos ((index model.targetPos model.editNum) - 1) model.editNum
                                                in
                                                if checkShape model.shape newPos model.targetRot then
                                                  newPos
                                                else
                                                  model.targetPos
                                                
                                                
                                              else if model.editNum < 6 then
                                                let
                                                  newPos = replace model.targetPos ((index model.targetPos model.editNum) - 0.5) model.editNum
                                                in
                                                if checkShape model.shape newPos model.targetRot then
                                                  newPos
                                                else
                                                  model.targetPos
                                              else
                                                model.targetPos
                                       , targetRot = if model.editNum == 6 then if model.targetRot > 0 then (if checkShape model.shape model.targetPos (model.targetRot - (1/4)) then   model.targetRot - (1/4) else model.targetRot ) else (if checkShape model.shape model.targetPos (7/4) then (7/4) else model.targetRot) else model.targetRot
                                       , rotation = if model.editNum == 6 && model.targetRot == 0 then (if checkShape model.shape model.targetPos (7/4) then 2 else 0) else model.rotation
                                                }
                     T1 b -> {model | t1 = b}
                     T2 b -> {model | t2 = b}
                     Reset -> if model.reset then
                                {model | targetPos = [1,0,0,0,1,0], targetRot = 0}
                              else
                                model
                     Level n -> {init | goal = (index levels n).goal, editable = (index levels n).editable, pulse = (index levels n).pulseInit, shape = (index levels n).shape, dots = (index levels n).dots, level = n, goalRot = (index levels n).goalRot, rotShow = (index levels n).rotShow, shapeSym = (index levels n).shapeSym}
                     
                     
                     
init = { time = 0, matrix = [1,0,0,0,1,0], popup = False, popupPos = (0,0), editNum = 0, popupTime = 0, t1 = False, t2 = False, targetPos = [1,0,0,0,1,0], goal = (index levels 0).goal, completeTime = 0, editable = (index levels 0).editable, pulse = (index levels 0).pulseInit, reset = True, shape = (index levels 0).shape, dots = (index levels 0).dots, level = 0, levelComplete = False, rotation = rotation, targetRot = rotation, goalRot = (index levels 0).goalRot, rotShow = (index levels 0).rotShow, shapeSym = (index levels 0).shapeSym, completedLevels = add False 20 []}

main = gameApp Tick { model = init, view = view, update = update, title = "Game Slot" }

view model = collage 192 128 (myShapes model)


----------------
--list functions
----------------

index : List a -> Int -> a
index list n = case n of
                0 -> head list
                _ -> if n == -1 then
                       head (List.reverse list)
                     else if n >= List.length list then
                       index list (n - List.length list)
                     else
                       index (tail list) (n - 1)

replace : List a -> a -> Int -> List a
replace list x n = case n of
                    0 -> ( [x] ) ++ (tail list)
                    _ -> ( [head list] ) ++ (replace (tail list) x (n - 1))

isIn list n = if list == [] then
                False
              else if head list == n then
                True
              else isIn (tail list) n
              
head x = headAux (List.head x)
tail x = tailAux (List.tail x)

headAux x = case x of
              Just l -> l
              Nothing -> Debug.todo "unimplemented"

tailAux x = case x of
              Just l -> l
              Nothing -> []

mAdd (x1,y1) (x2,y2) = (x1+x2,y1+y2)
mMult n (x,y) = (n*x, n*y)

t1 (x,y) = x
t2 (x,y) = y

add : a -> Int -> List a -> List a
add x num list = case num of
  0 -> list
  n -> x :: (add x (n - 1) list)
