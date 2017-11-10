PRO parse_ephem

ephem = 'ephem.txt'

openr, lun, /get_lun, ephem


set = 0

WHILE ~(eof(lun)) DO BEGIN
   input = 'string'
   readf, lun, input
   IF stregex(input, 'SOE', /boolean) THEN BEGIN
      set = 1
      continue
   ENDIF
   IF stregex(input, 'EOE', /boolean) THEN BEGIN
      set = 0
      BREAK
   ENDIF
   IF set EQ 1 THEN BEGIN
      fields = strsplit(input, ' ', /extract)
      this_date = fields[0]
      this_time = fields[1]
      push, ut, this_date+'T'+this_time+':00'
      push, ra, float(fields[2])
      push, dec, float(fields[3])
   ENDIF

ENDWHILE

close, lun
free_lun, lun


nustar_time = convert_nustar_time(ut, /from_ut)
save, ut, nustar_time, ra, dec, file = 'ephem.sav'

END

