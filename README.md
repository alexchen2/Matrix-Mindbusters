# Matrix Mindbusters
Matrix Mindbusters is an educational game aimed to help undergraduate Math & Engineering students learn matrix transformations. Written in Elm, the program was created in 2023 for a summative assignment in McMaster's computer science undergraduate course COMPSCI 1XD3, and it utilizes MacCAS Outreach's GraphicSVG library to render images and vector shapes (created by McMaster students and Dr. Christopher Anand). During gameplay, a two-by-two/-three matrix is visually represented on a Cartesian grid system through a two dimensional diagram, and the user is tasked with altering the matrix's values to manipulate the shape into taking on a specific formation.

Test out the program live here: \
&emsp;[Windows version](https://cs1xd3.online/ShowModulePublish?modulePublishId=14cdfd44-cf3c-4449-a001-38996b7c9f74) \
&emsp;[Mac/Linux version](https://cs1xd3.online/ShowModulePublish?modulePublishId=406a7990-87bc-4e22-9168-83a9a135ee39)
  
Created by [Alex Chen](https://github.com/alexchen2), Loic Sinclair, Jacob Armstrong, Norah Muqbel, and Lu Yan.
<!--  Note to other collaborators - feel free to link in your Github profiles here if you'd like or edit anything here if I accidentally mispelled your name -->

## Features
- Contains three level packs of varying difficulties—Easy, Medium, and Hard—each either focused on introducing the player to a new matrix transformation or testing their knowledge through a combination of concepts
- Includes Info and About submenus to refresh the player's knowledge on necessary linear algebra knowledge while acquainting them with the controls and purpose behind the program
- Contains a rudimentary timer score system to allow the user to note how long they take to complete each level, while encouraging them to return to prior cleared stages to improve their time and review past concepts

## Current Bugs:
- Best time scores are not displayed properly on the individual level select screens. The score values, however, are still registered and appear on the top taskbar during gameplay when in a level.
- Generated HTML files from the source code lag slightly when navigating through the level select menus.

## Required Dependencies:
- Elm (get it [here](https://guide.elm-lang.org/install/elm.html)!)
- MacCASOutreach's GraphicSVG v7.2.0 \
  (run `elm install MacCASOutreach/graphicsvg` within terminal)

## Clone Repo:
```
git clone https://github.com/alexchen2/Matrix-Mindbusters.git
```

## Compile Instructions:
```bash
elm make .\src\MainWin.elm
```
or:
```bash
elm make .\src\MainMac.elm
```
depending on your OS.
