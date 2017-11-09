# nustar_jupiter_analysis

Repo for tracking the code to analyze NuSTAR data for Jupiter.

convert_to_jupiter2.* files conver the events to be relative to the position of Jupiter
at the **start** (?? needs to be checked) of the observation. The result is an event file
with shifted X/Y positions.

TBD: Fix the RA/DEC_PNT header keywords to get the projection in ds9 correct.

adjust_det1.pro is there so that you can run nuproducts / nuskybgd on the shfited event 
files to extra spectrum and make simulated backgrounds on these data.

