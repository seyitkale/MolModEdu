mol load psf ../analysis_data/only_nucl_init.psf
#mol addfile ../analysis_data/only_nucl_init.pdb waitfor all
mol addfile ../analysis_data/md_nucl.dcd waitfor all

set chi [atomselect top "segname CHI"]	 
set chj [atomselect top "segname CHJ"]	 
# rmsd calculation loop
package require hbonds

set nframes [expr  [molinfo top get numframes] - 1 ]

set outfile [open ../analysis_data/dna_prot_contacts_md.dat w]	
#set sel1 [atomselect top "segname CHI and resid '$r1'" frame $i]

puts $outfile "Contacts between DNA and protein"
puts $outfile "Calculated using VMD cutoff 3A, noh atoms"
puts $outfile "Time, ps"
puts $outfile "Num hydrogen bonds"
puts -nonewline $outfile "Time"
for { set r1 -73 } { $r1<=73 } { incr r1 } {
puts -nonewline $outfile "\t$r1"
}
puts -nonewline $outfile "\n"
for { set i 0 } { $i<=$nframes } { incr i } {
set time [expr 0.1 * $i]
puts -nonewline $outfile [format "%.3f" "$time"]
puts  [format "Time %.3f" "$time"]
for { set r1 -73 } { $r1<=73 } { incr r1 } {
set sel1 [atomselect top "protein and noh" frame $i]
set r2 [expr $r1 * (-1)]
set sel2 [atomselect top "((segname CHI and resid '$r1') or (segname CHJ and resid '$r2')) and noh" frame $i]
set contacts [lindex [measure contacts  3.0 $sel1 $sel2] 1]

set nc [llength $contacts]
#puts "$contacts"
#puts [format "Check: %d" "$delta"]
puts -nonewline $outfile "\t$nc"

$sel2 delete
$sel1 delete
#hbonds -sel1 $sel1 -sel2 $sel2 -dist 3.0 -ang 30 -frames $i:$i -writefile yes -outfile ../analysis_data/dna_hbonds.dat
#-type unique -writefile yes -outfile ../analysis_data/dna_hbonds.dat

}
puts -nonewline $outfile "\n"
}

close $outfile 

#hbonds -sel1 $chi -sel2 $chj -dist 3.0 -ang 30 -type unique -writefile yes -outfile ../analysis_data/dna_hbonds.dat

exit


