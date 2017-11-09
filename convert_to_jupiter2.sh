#!/bin/sh

source $NUSTARSETUP

export convert_to_jupiter_file=$1

idl -quiet convert_to_jupiter2.bat

