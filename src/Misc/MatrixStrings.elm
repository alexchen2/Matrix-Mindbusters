module Misc.MatrixStrings exposing (..)

-- Coded by Alex Chen; text by Norah Muqbel

import Html exposing (img, div)
import Html.Attributes exposing (style, width, src, height)

import GraphicSVG exposing (..)

{- ** Info Menu Elements ** -}
demoGifSkewSrc : String
demoGifSkewSrc = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/demoGif1.gif"

demoGifStretchSrc : String
demoGifStretchSrc = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/demoGif2B.gif"

demoGifScaleSrc : String
demoGifScaleSrc = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/demoGif3A.gif"
  
demoGifTransSrc : String
demoGifTransSrc = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/demoGif4A.gif"
  
demoGifRotSrc : String
demoGifRotSrc = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/demoGif5A.gif"  


demoGifSkewHTML : Html.Html msg
demoGifSkewHTML =
  div [width 1, height 1, style "user-select" "none"] [img [src demoGifSkewSrc] []]
  -- for later idea attribute with popup on clicking on gif: style "cursor" "pointer"
  
demoGifStretchHTML : Html.Html msg
demoGifStretchHTML =
  div [width 1, height 1, style "user-select" "none"] [img [src demoGifStretchSrc] []]

demoGifScaleHTML : Html.Html msg
demoGifScaleHTML =
  div [width 1, height 1, style "user-select" "none"] [img [src demoGifScaleSrc] []]

demoGifTransHTML : Html.Html msg
demoGifTransHTML =
  div [width 1, height 1, style "user-select" "none"] [img [src demoGifTransSrc] []]
  
demoGifRotHTML : Html.Html msg
demoGifRotHTML =
  div [width 1, height 1, style "user-select" "none"] [img [src demoGifRotSrc] []]  


demoGifSkew : Shape userMsg
demoGifSkew = 
  html 1000 1000 (demoGifSkewHTML)
    |> scale (0.15)

demoGifStretch : Shape userMsg
demoGifStretch = 
  html 1000 1000 (demoGifStretchHTML)
    |> scale (0.15)

demoGifScale : Shape userMsg
demoGifScale = 
  html 1000 1000 (demoGifScaleHTML)
    |> scale (0.15)

demoGifTrans : Shape userMsg
demoGifTrans = 
  html 1000 1000 (demoGifTransHTML)
    |> scale (0.15)

demoGifRot : Shape userMsg
demoGifRot = 
  html 1000 1000 (demoGifRotHTML)
    |> scale (0.15)

strTrans : String
strTrans = 
  """ 
A type of transformation that occurs when a\n
figure is moved from one location to another\n
on the coordinate plane without changing its\n
size, shape, or orientation.\n
This can be obtained by:\n
   ➤ x-direction: changing the value of a₁₃\n
   ➤ y-direction: changing the value of a₂₃\n
\n
Note: aᵢⱼ indicates the value at the\n
          iᵗʰ row and jᵗʰ column of the matrix.\n
  """

strScale : String
strScale = 
  """
A type of transformation that changes the\n
size of a shape to be proportionally larger\n
or smaller.\n
This can be obtained by:\n
   ➤ changing the values of a₁₁ and a₂₂\n
        simultaneously such that a₁₁ = a₂₂\n
\n
Note: aᵢⱼ indicates the value at the\n
          iᵗʰ row and jᵗʰ column of the matrix.\n
  """
  
strStretch : String
strStretch = 
  """
A type of transformation which enlarges all\n
distances in a particular direction by a\n 
constant factor, but does not affect\n
distances in the perpendicular direction.\n
This can be obtained by:\n
   ➤ x-direction: changing the value of a₁₁\n
   ➤ y-direction: changing the value of a₂₂\n
\n
Note: aᵢⱼ indicates the value at the\n
          iᵗʰ row and jᵗʰ column of the matrix.\n
  """

strSkew : String
strSkew = 
  """
A type of transformation which distorts a\n
figure by a specified angle from the x-axis,\n
the y-axis, or both axes.\n
This can be obtained by:\n
   ➤ horizontal skew: changing the value of a₁₂\n
   ➤ vertical skew: changing the value of a₂₁\n
\n
Note: aᵢⱼ indicates the value at the\n
          iᵗʰ row and jᵗʰ column of the matrix.\n 
  """

strRot : String
strRot =
  """
The rotation matrix rotates points\n 
in the xy-plane in a counter-\n
clockwise direction through θ with\n 
respect to the positive x-axis.\n
This can be obtained by:\n
   ➤ changing the value of θ.\n
  """

{- ** Level Pack Select Menu Elements ** -}
mainBgImgSrc : String
mainBgImgSrc = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/192x128_whiteShadedBG.jpg"

bgImg1Src : String
bgImg1Src = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/demoGif2.gif"
  
mainBgImgHTML : Html.Html msg
mainBgImgHTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src mainBgImgSrc] []]

bgImg1HTML : Html.Html msg
bgImg1HTML =
  div [width 1, height 1, style "user-select" "none", style "cursor" "pointer"] 
      [img [src bgImg1Src] []]

mainBgImg : Shape userMsg
mainBgImg = 
  [ html 1000 1000 (mainBgImgHTML)
      |> move (-(192 / 2), 128 / 2)
  , rect 192 128
      |> filled white
      |> makeTransparent 0.55
  ]
    |> group

bgImg1 : Shape userMsg
bgImg1 = 
  html 1000 1000 (bgImg1HTML)
    |> scale (0.325)
    |> move (-(220 / 2) * 0.325, (220 / 2) * 0.325)
    |> move (0, -5)

pnlEasy : String
pnlEasy = 
  """
Get familiar with playing the\n
game with shears, stretches,\n 
skews, and translations.
  """

pnlMed : String
pnlMed = 
  """
More intermediate levels,\n
involving rotations around a\n
vertex of an image.
  """

pnlHard : String
pnlHard = 
  """
Test your knowledge through\n
these advanced levels, with\n
multiple transformations.

  """

{- ** Individual Level Select Menu Elements ** -}

egLevel1Src : String
egLevel1Src = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/ExampleLevelBG/ExampleLevel1.png"

egLevel2Src : String
egLevel2Src = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/ExampleLevelBG/ExampleLevel2.png"
  
egLevel3Src : String
egLevel3Src = 
  "https://alexchen2.github.io/COMPSCI-1XD3/DTProject/ExampleLevelBG/ExampleLevel3.png"  
  
egLevel1HTML : Html.Html msg
egLevel1HTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src egLevel1Src] []]

egLevel2HTML : Html.Html msg
egLevel2HTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src egLevel2Src] []]

egLevel3HTML : Html.Html msg
egLevel3HTML =
  div [width 1, height 1, style "user-select" "none"] 
      [img [src egLevel3Src] []]

egLevel1 : Shape userMsg
egLevel1 = 
  [ html 1000 1000 (egLevel1HTML)
      |> scale (0.155)
      |> move (-(192 / 2) + 59, (128 / 2) - 17.5)
  ]
    |> group

egLevel2 : Shape userMsg
egLevel2 = 
  [ html 1000 1000 (egLevel2HTML)
      |> scale (0.155)
      |> move (-(192 / 2) + 59, (128 / 2) - 17.5)
  ]
    |> group

egLevel3 : Shape userMsg
egLevel3 = 
  [ html 1000 1000 (egLevel3HTML)
      |> scale (0.155)
      |> move (-(192 / 2) + 59, (128 / 2) - 17.5)
  ]
    |> group