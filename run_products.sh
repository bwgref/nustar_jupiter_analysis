#!/bin/bash

# usage: run_products.sh OBSID A/B source.reg
# e.g.:
# run_products.sh 60001043006 A source.reg
# Dumps data products into a new ./OBSID/source directory


# Set up your local NuSTAR science environment here:
if [ -z "$NUSTARSETUP" ]; then 
    echo "Need to set the NUSTARSETUP environment variable!"
    exit
fi
source $NUSTARSETUP


function headas_locpfiles { export PFILES="$1;$HEADAS/syspfiles"; }



OBSID=data/20013036_Jupiter_2015_030_032/20013036002
REGNAME=jupiter.reg
BGDREG=bgd.reg

SRCREGIONFILE=$REGNAME
BKGREGIONFILE=bgd.reg

REGSTEM=`basename $REGNAME .reg`
STEM=nu`basename $OBSID`

OUTDIR=/users/bwgref/science/nustar/jupiter/spec
if [ ! -d $OUTDIR ]; then
    mkdir $OUTDIR
fi
LOCPFILES=${OUTDIR}/$$_pfiles
if [ ! -d $LOCPFILES ]; then
    mkdir $LOCPFILES
fi
headas_locpfiles $LOCPFILES


for MOD in A B
do

    STEM=nu`basename $OBSID`

    STEMOUT=${STEM}_${REGSTEM}${MOD}

    INSTRUMENT=FPM${MOD}
    DATPATH=${OBSID}/event_cl

    infile=${DATPATH}/${STEM}${MOD}01_cl_jovpos2.evt
    DET1REFFILE=${DATPATH}/${STEM}${MOD}_det1_jovpos2.fits

    outname=${OUTDIR}/${STEMOUT}_sr.pha
    LOGFILE=$OUTDIR/${STEMOUT}.log


    runmkarf=yes
    runmkrmf=yes
    clobber=yes
    bkgextract=yes


    echo $LOCPFILES > $LOGFILE
    echo nuproducts \
        indir=$DATPATH \
        infile=$infile \
        instrument=$INSTRUMENT \
        steminputs=$STEM \
        stemout=$STEMOUT \
        srcregionfile=$SRCREGIONFILE \
        bkgextract=$bkgextract \
        bkgregionfile=$BKGREGIONFILE \
        outdir=$OUTDIR \
        runmkarf=$runmkarf runmkrmf=$runmkrmf \
        clobber=$clobber \
        det1reffile=$DET1REFFILE \
        offaxishisto=DEFAULT \
        lcfile=NONE \
        correctlc=no \
        bkglcfile=NONE \
        imagefile=NONE \
        runbackscale=no >> $LOGFILE

    nuproducts \
        indir=$DATPATH \
        infile=$infile \
        instrument=$INSTRUMENT \
        steminputs=$STEM \
        stemout=$STEMOUT \
        srcregionfile=$SRCREGIONFILE \
        bkgextract=$bkgextract \
        bkgregionfile=$BKGREGIONFILE \
        outdir=$OUTDIR \
        runmkarf=$runmkarf runmkrmf=$runmkrmf \
        clobber=$clobber \
        det1reffile=$DET1REFFILE \
        offaxishisto=DEFAULT \
        lcfile=NONE \
        correctlc=no \
        bkglcfile=NONE \
        imagefile=NONE \
        runbackscale=no >> $LOGFILE 2>&1
    
done
