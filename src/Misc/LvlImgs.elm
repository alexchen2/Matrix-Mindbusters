module Misc.LvlImgs exposing (..)

-- Coded by Alex Chen

{- Created this module, as I'm too freaking tired of importing and deporting 
 - MatrixInfoStrings around 12 times everytime i make a small change to that
 - program... 
 - Nonetheless, this just contains HTML images for each of the level "previews"
 - in the level select screens.
 -}

import Html exposing (img, div)
import Html.Attributes exposing (style, width, src, height)

-- MacCASOutreach imports
import GraphicSVG exposing (..)
import GraphicSVG.App exposing (..)

easyLevel1Src = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/EasyLevelBG/easyLevel1.png"

easyLevel2Src = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/EasyLevelBG/easyLevel2.png"
  
easyLevel3Src = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/EasyLevelBG/easyLevel3.png"  
  
easyLevel4Src = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/EasyLevelBG/easyLevel4.png"

easyLevel5Src = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/EasyLevelBG/easyLevel5.png"
  
easyLevel6Src = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/EasyLevelBG/easyLevel6.png"  
  
easyLevel7Src = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/EasyLevelBG/easyLevel7.png"

easyLevel8Src = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/EasyLevelBG/easyLevel8.png"
  
easyLevel9Src = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/EasyLevelBG/easyLevel9.png"  
  
easyLevel10Src = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/EasyLevelBG/easyLevel10.png"

easyLevel11Src = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/EasyLevelBG/easyLevel11.png"
  
medLevel1Src = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/MedLevelBG/medLevel1.png"    

medLevel2Src = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/MedLevelBG/medLevel2.png"  
  
medLevel3Src = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/MedLevelBG/medLevel3.png"  
  
medLevel4Src = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/MedLevelBG/medLevel4.png"  
  
hardLevel1Src = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/HardLevelBG/hardLevel1.png"    

hardLevel2Src = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/HardLevelBG/hardLevel2.png"    

easyLevel1HTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src easyLevel1Src] []]

easyLevel2HTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src easyLevel2Src] []]

easyLevel3HTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src easyLevel3Src] []]

easyLevel4HTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src easyLevel4Src] []]

easyLevel5HTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src easyLevel5Src] []]

easyLevel6HTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src easyLevel6Src] []]

easyLevel7HTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src easyLevel7Src] []]

easyLevel8HTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src easyLevel8Src] []]

easyLevel9HTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src easyLevel9Src] []]
      
easyLevel10HTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src easyLevel10Src] []]

easyLevel11HTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src easyLevel11Src] []]

medLevel1HTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src medLevel1Src] []]      

medLevel2HTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src medLevel2Src] []]  

medLevel3HTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src medLevel3Src] []]  

medLevel4HTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src medLevel4Src] []]  
      
hardLevel1HTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src hardLevel1Src] []]        
      
hardLevel2HTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src hardLevel2Src] []]       

easyLevel1 = 
  [ html 1000 1000 (easyLevel1HTML)
      |> scale (0.155)
      |> move (-(192 / 2) + 59, (128 / 2) - 17.5)
  ]
    |> group

easyLevel2 = 
  [ html 1000 1000 (easyLevel2HTML)
      |> scale (0.155)
      |> move (-(192 / 2) + 59, (128 / 2) - 17.5)
  ]
    |> group

easyLevel3 = 
  [ html 1000 1000 (easyLevel3HTML)
      |> scale (0.155)
      |> move (-(192 / 2) + 59, (128 / 2) - 17.5)
  ]
    |> group

easyLevel4 = 
  [ html 1000 1000 (easyLevel4HTML)
      |> scale (0.155)
      |> move (-(192 / 2) + 59, (128 / 2) - 17.5)
  ]
    |> group

easyLevel5 = 
  [ html 1000 1000 (easyLevel5HTML)
      |> scale (0.155)
      |> move (-(192 / 2) + 59, (128 / 2) - 17.5)
  ]
    |> group

easyLevel6 = 
  [ html 1000 1000 (easyLevel6HTML)
      |> scale (0.155)
      |> move (-(192 / 2) + 59, (128 / 2) - 17.5)
  ]
    |> group
    
easyLevel7 = 
  [ html 1000 1000 (easyLevel7HTML)
      |> scale (0.155)
      |> move (-(192 / 2) + 59, (128 / 2) - 17.5)
  ]
    |> group

easyLevel8 = 
  [ html 1000 1000 (easyLevel8HTML)
      |> scale (0.155)
      |> move (-(192 / 2) + 59, (128 / 2) - 17.5)
  ]
    |> group

easyLevel9 = 
  [ html 1000 1000 (easyLevel9HTML)
      |> scale (0.155)
      |> move (-(192 / 2) + 59, (128 / 2) - 17.5)
  ]
    |> group
    
easyLevel10 = 
  [ html 1000 1000 (easyLevel10HTML)
      |> scale (0.155)
      |> move (-(192 / 2) + 59, (128 / 2) - 17.5)
  ]
    |> group

easyLevel11 = 
  [ html 1000 1000 (easyLevel11HTML)
      |> scale (0.155)
      |> move (-(192 / 2) + 59, (128 / 2) - 17.5)
  ]
    |> group   

medLevel1 = 
  [ html 1000 1000 (medLevel1HTML)
      |> scale (0.155)
      |> move (-(192 / 2) + 59, (128 / 2) - 17.5)
  ]
    |> group

medLevel2 = 
  [ html 1000 1000 (medLevel2HTML)
      |> scale (0.155)
      |> move (-(192 / 2) + 59, (128 / 2) - 17.5)
  ]
    |> group

medLevel3 = 
  [ html 1000 1000 (medLevel3HTML)
      |> scale (0.155)
      |> move (-(192 / 2) + 59, (128 / 2) - 17.5)
  ]
    |> group

medLevel4 = 
  [ html 1000 1000 (medLevel4HTML)
      |> scale (0.155)
      |> move (-(192 / 2) + 59, (128 / 2) - 17.5)
  ]
    |> group

hardLevel1 = 
  [ html 1000 1000 (hardLevel1HTML)
      |> scale (0.155)
      |> move (-(192 / 2) + 59, (128 / 2) - 17.5)
  ]
    |> group

hardLevel2 = 
  [ html 1000 1000 (hardLevel2HTML)
      |> scale (0.155)
      |> move (-(192 / 2) + 59, (128 / 2) - 17.5)
  ]
    |> group
