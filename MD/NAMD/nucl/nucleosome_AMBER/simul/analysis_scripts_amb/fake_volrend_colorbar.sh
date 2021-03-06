#!/bin/bash
######        USAGE
#
# ./fake_voldend psffile pdbfile dxfile isosurfacesteps startisovalue stopisovalue vmdcolorscale
#
# colorscale RWB BWR BGR RGB e.t.c.
##list of keys:

mkdir -p dat

psfname=$1
pdbname=$2
dxname=$3
numofsteps=$4
startvalue=$5
stopvalue=$6

colorid=$7

step=`echo "scale=4; ("$stopvalue - $startvalue")/"$numofsteps".0" | bc`

#CONFIGURATION***************************************************
opacitystart=0.05
opacitystop=0.25
firstheader="Water distribution in nucleosome"
secondheader="Volume distribution"

#CONFIGURATION***************************************************

opacitystep=`echo "scale=4; ("$opacitystop - $opacitystart")/"$numofsteps".0" | bc`



echo "#"$step
##### CHANGE PATH !!!!!
echo "
package require colorscalebar
source add_text_layer.tcl
source input_param.tcl
set scale 1.8
set viewplist {}
set fixedlist {}

color scale method "$colorid"
color Display Background white

# Display settings
display eyesep       0.065000
display focallength  2.000000
display height       6.000000
display distance     -2.000000
display projection   Orthographic
display nearclip set 0.500000
display farclip  set 10.000000
display depthcue   off
display cuestart   0.500000
display cueend     10.000000
display cuedensity 0.320000

#### MATERIAL SETTINGS ####
material change ambient Transparent 0.300000
material change diffuse Transparent 0.800000
material change specular Transparent 0.250000
material change shininess Transparent 0.534020
material change opacity Transparent 0.300000
material change outline Transparent 0.000000
material change outlinewidth Transparent 0.000000
material change transmode Transparent 0.000000

label textsize 1.0
axes location off
display rendermode GLSL
##
##
##  If you need PSF add it there
##
mol new "$psfname" type psf first 0 last -1 step 1 filebonds 1 autobonds 1 waitfor all
mol addfile "$pdbname" type pdb first 0 last -1 step 1 filebonds 1 autobonds 1 waitfor all
mol addfile "$dxname" type dx first 0 last -1 step 1 filebonds 1 autobonds 1 waitfor all
mol delrep 0 top
mol representation NewCartoon 0.840000 20.000000 2.630000 0
#mol color Chain
mol color SegName
mol selection {protein}
mol material AOShiny
mol addrep top

mol representation NewCartoon 1.090000 10.000000 2.070000 1
mol color ColorID 6
mol selection {nucleic and backbone}
mol material AOShiny
mol addrep top

# Dna nucleobases representation
mol representation Licorice 0.300000 10.000000 10.000000
mol color ColorID 17
mol selection {nucleic and noh and not name P O1P O2P O3' O5' C5' and resname GUA CYT}
mol material AOEdgy
mol addrep top

mol representation Licorice 0.300000 10.000000 10.000000
mol color ColorID 25
mol selection {nucleic and noh and not name P O1P O2P O3' O5' C5' and resname THY ADE}
mol material AOEdgy
mol addrep top
" > dummy.tcl
######### NUMBER OF NON VOLUME REPRESENTATIONS
numofrepr=4
##############
for((i=0; i<=$numofsteps; i++))
do
echo "
material add copy Transparent
material change opacity Material"`echo $i "+ 22" | bc`" "`echo $i "*" $opacitystep "+" $opacitystart | bc`"
mol representation Isosurface "`echo $i "*" $step "+" $startvalue | bc`" 0 0 0 1 1
mol color Volume 0
mol selection {all}
mol material Material"`echo $i "+ 22" | bc`"
mol addrep top
mol scaleminmax top "`echo $i "+" $numofrepr | bc`" "$startvalue" "$stopvalue"
" >> dummy.tcl
done

echo "
# {{length 0.5} {width 0.05} {auto_scale 1} {fixed 1} {min 0} {max 100} {label_num 5} {text 16} {fp_format 0} {x_pos -1.0} {y_pos -1.0} {replacebar 1} {molid top} {repid 0} {showlegend 0} {legend \"Color Scale:\"}} {
 ::ColorScaleBar::color_scale_bar 1.5 0.1 0 1 $startvalue $stopvalue 5 16 1 -1.0 -1.0 1 top 0 1 \"Number density, 1/A^3\" 
 mol fix 0
mol free 1

translate by -0.9 0.3 0

mol free 0
mol fix 1

#color Chain A orange2
#color Chain B yellow3
#color Chain C mauve
#color Chain D cyan3
#color Chain E orange2
#color Chain F yellow3
#color Chain G mauve
#color Chain H cyan3
color Segname CHA orange2
color Segname CHB yellow3
color Segname CHC mauve
color Segname CHD cyan3
color Segname CHE orange2
color Segname CHF yellow3
color Segname CHG mauve
color Segname CHH cyan3
color Highlight Nonback 6
color Highlight Nucback 2


# ================= movie starts ==================== 

# sets a variable for knowing were real molecules ends if there are more than one
 set molnum [expr [molinfo num]]

# #--------set start txt position in px-----
 set txtx [expr -(\$dispw/2) + 20 ]
 set txty [expr (\$disph/2) - 20 ]

 # set step of txt lines
 set txtstep  [expr \$disph/20 ]

# # set counter for lines
 set txtlncount 0

 scale by \$scale
 translate by \$transx \$transy \$transz
 axes location off
 display update ui


# #add some text on new layer
 add_text_layer HEADNAME
 draw text \" \$txtx [expr \$txty-(\$txtlncount*\$txtstep)] 0 \" \"$firstheader\" size 1.5 thickness 3
 incr txtlncount 1
draw text \" \$txtx [expr \$txty-(\$txtlncount*\$txtstep)] 0 \" \"$secondheader\" size 1.5 thickness 3
 incr txtlncount 2


 add_text_layer HISTONES

set text(0) \"Histones H3\"
set text(1) \"Histones H4\"
set text(2) \"Histones H2A\"
set text(3) \"Histones H2B\"
set color_text(0) 31
set color_text(1) 18
set color_text(2) 13
set color_text(3) 22

 for {set r 0} {\$r < 4} {incr r 1} {
 	#text
 	draw color \$color_text(\$r)
 	draw text \" \$txtx [expr \$txty-(\$txtlncount*\$txtstep)] 0 \" \"\$text(\$r)\" size 1.5 thickness 3
 	incr txtlncount 1
 }
add_text_layer DNA
draw color 6
draw text \" \$txtx [expr \$txty-(\$txtlncount*\$txtstep)] 0 \" \"DNA\" size 1.5 thickness 3
incr txtlncount 1
mol fix 1



####################RENDERING########################

#render snapshot ../analysis_data/nucl_iso_ions.tga

for {set i 0} {\$i <= 360} {incr i 1} {

rotate y by 1
display update
render snapshot dat/\$i.tga

}
exit

" >> dummy.tcl
vmd -e dummy.tcl
rm dummy.tcl
rm -f nucl_iso_water.mov
ffmpeg -i dat/%d.tga -sameq  nucl_iso_water.mov
rm -rf dat
