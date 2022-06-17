turtles-own [
  flockmates         ;; agentset of nearby turtles
  nearest-neighbor   ;; closest one of our flockmates

  separation-xy
  align-xy
  cohere-xy
  formation-xy
  prev-xy

  goal-xy
]

globals [leader]

to setup
  clear-all
  create-turtles population
    [
      set color yellow - 2 + random 7  ;; random shades look nice
      set size 1.5  ;; easier to see
      setxy random-xcor random-ycor
      set flockmates no-turtles
      set goal-xy (list 0 0)
     ]
  reset-ticks
end

to go
  set leader min-one-of turtles [who]
  ask turtles [ flock ]
  tick
end

to flock

  ifelse self != leader
  [
    ; followers
    find-flockmates
    if any? flockmates
    [
      find-nearest-neighbor

      update-separation-vector
      update-align-vector
      update-cohere-vector
      update-formation-vector [self] of leader
      update-prev-vector

      move
    ]
  ]
  [
    ;leader
    rt leader-rotation
    forward leader-speed
  ]

  if ticks mod ticks-to-scan = 0 and scanning [ take-a-pic ]
end

;;; NEW

to update-separation-vector
  ; Consigue el vector closest->self
  let vx xcor - [xcor] of nearest-neighbor
  let vy ycor - [ycor] of nearest-neighbor
  let v list vx vy
  ; Si el módulo del vector es mayor que la dist minima
  let vlength (magnitude v)
  ifelse vlength > min-distance
  [
    ; Devuelve vector zero
    set separation-xy list 0 0
  ]
  [
    ; Así ya tienes el vector que seguir para mantener 'separation'
    ifelse r1-normalized = true
    [ set separation-xy (normalize-vector v) ]
    [ set separation-xy v ]
  ]
end

to update-align-vector
  ; Consigue el heading medio de los vecinos
  let avg-heading average-flockmate-heading
  let avg-dir heading-to-vector avg-heading
  ; Así ya tienes el vector que seguir para mantener 'align'
  ifelse r2-normalized = true
  [ set align-xy avg-dir ]
  [
    let scale ((subtract-headings avg-heading heading) / rotation-factor)
    set align-xy (scale-vector avg-dir scale)
  ]
end

to update-cohere-vector
  ; Consigue la lista de coordenadas de los vecinos
  let fm-pos (list )
  let fm-list ([self] of flockmates)
  foreach fm-list [fm ->
    set fm-pos (insert-item 0 fm-pos (list ([xcor] of fm) ([ycor] of fm)))
  ]
  ; Consigue la posicion media global de los vecinos
  let avg-pos (avg-vector fm-pos)
  ; Convierte a referencia local
  let local-avg-pos global-to-local avg-pos (list xcor ycor)
  ; Así ya tienes el vector que seguir para mantener 'cohere'
  ifelse r3-normalized = true
  [ set cohere-xy (normalize-vector local-avg-pos) ]
  [ set cohere-xy local-avg-pos ]

end

to update-formation-vector [leader-agent]
  ; Consigue los extremos de la linea que cruza al lider
  let leader-pos list ([xcor] of leader-agent) ([ycor] of leader-agent)
  let leader-heading [heading] of leader
  let r90 (leader-heading + 90) mod 360
  let l90 (leader-heading - 90) mod 360
  let u local-to-global (heading-to-vector r90) leader-pos
  let v local-to-global (heading-to-vector l90) leader-pos
  ; Encuentra la proyección de tu posicion a la linea
  let my-pos list xcor ycor
  let prj point-on-line-projection my-pos u v
  ; Convierte a referencia local
  let prj-local global-to-local prj my-pos
  ; Así ya tienes el vector que seguir para mantener 'formation'
  ifelse r4-normalized = true
  [ set formation-xy (normalize-vector prj-local) ]
  [ set formation-xy prj-local ]
end

to update-prev-vector
  ; Salva el goal antiguo
  set prev-xy goal-xy
end

to move
  ; Calcula la media ponerada de las coordenadas xy de cda regla
  set goal-xy weighted-avg-vector (list separation-xy align-xy cohere-xy formation-xy prev-xy) (list separation-w align-w cohere-w formation-w prev-w)
  ; Obtén las coordenadas globales del global
  let goalx (xcor + item 0 goal-xy)
  let goaly (ycor + item 1 goal-xy)
  if xcor != goalx and ycor != goaly
  [
    let new-heading towardsxy goalx goaly
    set new-heading clamp-turn (subtract-headings new-heading heading) max-turn
    rt new-heading
  ]
  let speed min-speed + (distance-w * distancexy goalx goaly)
  forward (clamp-value speed 0 max-speed)
end

to take-a-pic
  ask patches in-radius 3 [
    if pcolor < 6 [ set pcolor pcolor + 0.5 ]
  ]
end

to clear-scan
  ask patches [ set pcolor 0 ]
end

to kill-one
  ask one-of turtles [die ]
end

to kill-leader
  ask leader [die ]
end

;; NEW-HELPERS

to-report heading-to-vector [degrees]
  ; Normalizado y en espacio local
  report list (sin degrees) (cos degrees)
end

; Local pos relative to global origin -> Global pos
to-report local-to-global [local-xy origin-xy]
  let local-x item 0 local-xy
  let local-y item 1 local-xy
  let origin-x item 0 origin-xy
  let origin-y item 1 origin-xy
  report list (origin-x + local-x) (origin-y + local-y)
end

; Global pos -> Local pos relative to global origin
to-report global-to-local [global-xy origin-xy]
  let global-x item 0 global-xy
  let global-y item 1 global-xy
  let origin-x item 0 origin-xy
  let origin-y item 1 origin-xy
  report list (global-x - origin-x) (global-y - origin-y)
end

to-report normalize-vector [vector]
  let vx item 0 vector
  let vy item 1 vector
  let vlength (magnitude vector)
  report list (vx / vlength) (vy / vlength)
end

to-report scale-vector [vector scale]
  let vx item 0 vector
  let vy item 1 vector
  report list (vx * scale) (vy * scale)
end

to-report avg-vector [vectorlist]
  let vx 0
  let vy 0
  foreach vectorlist
  [ vector ->
    set vx (vx + item 0 vector)
    set vy (vy + item 1 vector)
  ]
  set vx (vx / length vectorlist)
  set vy (vy / length vectorlist)
  report list vx vy
end

to-report weighted-avg-vector [vectorlist weightlist]
  let wsum 0
  foreach weightlist
  [ w ->
    set wsum (wsum + w)
  ]
  let vx 0
  let vy 0
  foreach range length vectorlist
  [ i ->
    let v item i vectorlist
    let w item i weightlist
    set vx (vx + ((item 0 v) * (w / wsum)))
    set vy (vy + ((item 1 v) * (w / wsum)))
  ]
  set vx (vx / length vectorlist)
  set vy (vy / length vectorlist)
  report list vx vy
end

to-report clamp-turn [degrees max-degrees]  ;; turtle procedure
  ifelse abs degrees > max-turn
  [
    ifelse degrees > 0 [ report max-degrees ]
    [ report -1 * max-degrees ]
  ]
  [ report degrees ]
end

to-report clamp-value [value min-lim max-lim]
  ifelse value < min-lim
  [ report min-lim ]
  [ ifelse value > max-lim
    [ report max-lim ]
    [ report value ]
  ]
end

to-report magnitude [v]
  let vx item 0 v
  let vy item 1 v
  report sqrt (vx * vx + vy * vy)
end

to-report dot-product [u v]
  let ux item 0 u
  let uy item 1 u
  let vx item 0 v
  let vy item 1 v
  report (ux * vx) + (uy * vy)
end

to-report point-on-line-projection [p-xy u-xy v-xy]
  let px item 0 p-xy
  let py item 1 p-xy

  let ux item 0 u-xy
  let uy item 1 u-xy

  let vx item 0 v-xy
  let vy item 1 v-xy

  let uvx vx - ux
  let uvy vy - uy

  let sqr-length-uv uvx * uvx + uvy * uvy

  let up-vector list (px - ux) (py - uy)
  let uv-vector list (vx - ux) (vy - uy)
  let t (dot-product up-vector uv-vector) / sqr-length-uv

  let prjx (ux + t * (vx - ux))
  let prjy (uy + t * (vy - uy))

  report list prjx prjy
end

;;; BACKUP

;to update-separation-vector
;  ; Consigue el vector closest->self
;  let vx xcor - [xcor] of nearest-neighbor
;  let vy ycor - [ycor] of nearest-neighbor
;  let v list vx vy
;  ; Normalizas el vector
;  let norm-v normalize-vector v
;  ; Lo escalas a la distancia mínima
;  let scaled-v scale-vector norm-v min-distance
;  ; Así ya tienes las coorenadas locales xy a las que dirigirte para mantener 'separation'
;  let scaled-vx item 0 scaled-v
;  let scaled-vy item 1 scaled-v
;  set separation-xy list scaled-vx scaled-vy
;end

;;; ORIGINAL

to find-flockmates  ;; turtle procedure
  set flockmates other turtles in-radius vision
end

to find-nearest-neighbor ;; turtle procedure
  set nearest-neighbor min-one-of flockmates [distance myself]
end

to-report average-flockmate-heading  ;; turtle procedure
  ;; We can't just average the heading variables here.
  ;; For example, the average of 1 and 359 should be 0,
  ;; not 180.  So we have to use trigonometry.
  let x-component sum [dx] of flockmates
  let y-component sum [dy] of flockmates
  ifelse x-component = 0 and y-component = 0
    [ report heading ]
    [ report atan x-component y-component ]
end
@#$#@#$#@
GRAPHICS-WINDOW
265
18
770
524
-1
-1
7.0
1
10
1
1
1
0
1
1
1
-35
35
-35
35
1
1
1
ticks
30.0

BUTTON
20
16
97
49
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
112
16
193
49
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
20
104
193
137
population
population
1.0
100.0
10.0
1.0
1
NIL
HORIZONTAL

SLIDER
20
143
191
176
vision
vision
0.0
50.0
50.0
1
1
patches
HORIZONTAL

SLIDER
837
51
1009
84
distance-w
distance-w
0
5
1.5
0.1
1
NIL
HORIZONTAL

SLIDER
1159
278
1331
311
min-distance
min-distance
0
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
838
365
1010
398
cohere-w
cohere-w
0
1
0.1
0.1
1
NIL
HORIZONTAL

SLIDER
838
321
1010
354
align-w
align-w
0
1
0.0
0.1
1
NIL
HORIZONTAL

SLIDER
837
279
1009
312
separation-w
separation-w
0
1
0.9
0.1
1
NIL
HORIZONTAL

SLIDER
838
448
1008
481
prev-w
prev-w
0
1
0.0
0.1
1
NIL
HORIZONTAL

SLIDER
836
92
1008
125
min-speed
min-speed
0
1
0.0
0.1
1
NIL
HORIZONTAL

SLIDER
837
203
1009
236
max-turn
max-turn
0
45
5.0
1
1
NIL
HORIZONTAL

SLIDER
837
407
1009
440
formation-w
formation-w
0
1
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
19
273
191
306
leader-speed
leader-speed
0
1
0.1
0.1
1
NIL
HORIZONTAL

SLIDER
18
316
190
349
leader-rotation
leader-rotation
-2
2
0.0
0.1
1
NIL
HORIZONTAL

BUTTON
124
226
187
259
->
ask turtle 0 [set heading 90]
NIL
1
T
OBSERVER
NIL
D
NIL
NIL
1

BUTTON
20
226
83
259
<-
ask turtle 0 [set heading 270]
NIL
1
T
OBSERVER
NIL
A
NIL
NIL
1

TEXTBOX
84
195
234
213
Leader
14
0.0
1

TEXTBOX
842
250
992
268
Weights
14
0.0
1

TEXTBOX
841
19
991
37
Speed
14
0.0
1

TEXTBOX
842
178
992
196
Rotation
14
0.0
1

BUTTON
72
60
142
93
Kill any
kill-one
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
99
369
182
402
Kill leader
kill-leader
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
32
364
89
409
Leader
[who] of leader
17
1
11

TEXTBOX
24
423
174
441
Scan
14
0.0
1

SWITCH
21
452
125
485
scanning
scanning
0
1
-1000

BUTTON
131
452
194
485
Clear
clear-scan
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
21
495
193
528
ticks-to-scan
ticks-to-scan
1
20
12.0
1
1
NIL
HORIZONTAL

SLIDER
835
133
1007
166
max-speed
max-speed
0
10
3.0
1
1
NIL
HORIZONTAL

SWITCH
1017
278
1148
311
r1-normalized
r1-normalized
0
1
-1000

SWITCH
1017
321
1148
354
r2-normalized
r2-normalized
0
1
-1000

SWITCH
1016
364
1147
397
r3-normalized
r3-normalized
0
1
-1000

SWITCH
1016
406
1147
439
r4-normalized
r4-normalized
1
1
-1000

SLIDER
1160
321
1332
354
rotation-factor
rotation-factor
90
360
360.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This model is an attempt to mimic the flocking of birds.  (The resulting motion also resembles schools of fish.)  The flocks that appear in this model are not created or led in any way by special leader birds.  Rather, each bird is following exactly the same set of rules, from which flocks emerge.

## HOW IT WORKS

The birds follow three rules: "alignment", "separation", and "cohesion".

"Alignment" means that a bird tends to turn so that it is moving in the same direction that nearby birds are moving.

"Separation" means that a bird will turn to avoid another bird which gets too close.

"Cohesion" means that a bird will move towards other nearby birds (unless another bird is too close).

When two birds are too close, the "separation" rule overrides the other two, which are deactivated until the minimum separation is achieved.

The three rules affect only the bird's heading.  Each bird always moves forward at the same constant speed.

## HOW TO USE IT

First, determine the number of birds you want in the simulation and set the POPULATION slider to that value.  Press SETUP to create the birds, and press GO to have them start flying around.

The default settings for the sliders will produce reasonably good flocking behavior.  However, you can play with them to get variations:

Three TURN-ANGLE sliders control the maximum angle a bird can turn as a result of each rule.

VISION is the distance that each bird can see 360 degrees around it.

## THINGS TO NOTICE

Central to the model is the observation that flocks form without a leader.

There are no random numbers used in this model, except to position the birds initially.  The fluid, lifelike behavior of the birds is produced entirely by deterministic rules.

Also, notice that each flock is dynamic.  A flock, once together, is not guaranteed to keep all of its members.  Why do you think this is?

After running the model for a while, all of the birds have approximately the same heading.  Why?

Sometimes a bird breaks away from its flock.  How does this happen?  You may need to slow down the model or run it step by step in order to observe this phenomenon.

## THINGS TO TRY

Play with the sliders to see if you can get tighter flocks, looser flocks, fewer flocks, more flocks, more or less splitting and joining of flocks, more or less rearranging of birds within flocks, etc.

You can turn off a rule entirely by setting that rule's angle slider to zero.  Is one rule by itself enough to produce at least some flocking?  What about two rules?  What's missing from the resulting behavior when you leave out each rule?

Will running the model for a long time produce a static flock?  Or will the birds never settle down to an unchanging formation?  Remember, there are no random numbers used in this model.

## EXTENDING THE MODEL

Currently the birds can "see" all around them.  What happens if birds can only see in front of them?  The `in-cone` primitive can be used for this.

Is there some way to get V-shaped flocks, like migrating geese?

What happens if you put walls around the edges of the world that the birds can't fly into?

Can you get the birds to fly around obstacles in the middle of the world?

What would happen if you gave the birds different velocities?  For example, you could make birds that are not near other birds fly faster to catch up to the flock.  Or, you could simulate the diminished air resistance that birds experience when flying together by making them fly faster when in a group.

Are there other interesting ways you can make the birds different from each other?  There could be random variation in the population, or you could have distinct "species" of bird.

## NETLOGO FEATURES

Notice the need for the `subtract-headings` primitive and special procedure for averaging groups of headings.  Just subtracting the numbers, or averaging the numbers, doesn't give you the results you'd expect, because of the discontinuity where headings wrap back to 0 once they reach 360.

## RELATED MODELS

* Moths
* Flocking Vee Formation
* Flocking - Alternative Visualizations

## CREDITS AND REFERENCES

This model is inspired by the Boids simulation invented by Craig Reynolds.  The algorithm we use here is roughly similar to the original Boids algorithm, but it is not the same.  The exact details of the algorithm tend not to matter very much -- as long as you have alignment, separation, and cohesion, you will usually get flocking behavior resembling that produced by Reynolds' original model.  Information on Boids is available at https://web.archive.org/web/20210818090425/http://www.red3d.com/cwr/boids/.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. (1998).  NetLogo Flocking model.  http://ccl.northwestern.edu/netlogo/models/Flocking.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1998 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2002.

<!-- 1998 2002 -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
