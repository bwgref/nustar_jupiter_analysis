PRO adjust_det1


shift_file = 'jupiter_drift.txt'
IF keyword_set(shift_file) THEN BEGIN
   openr, lun2, shift_file, /get_lun
   WHILE ~(eof(lun2)) DO BEGIN
      input = 'string'
      readf, lun2, input
;      print, input


      fields = strsplit(input, ' ', /extract)
      push, shift_time, float(fields[0])
      push, shift_x ,  float(fields[1])
      push, shift_y, float(fields[2])
   ENDWHILE
ENDIF
close, lun2
free_lun, lun2

datpath = '/home/nustar1/bwgref/science/nustar/jupiter/data/20013036_Jupiter_2015_030_032/20013036002/event_cl'
det1_files = file_search(datpath+'/*det1.fits')


FOR i = 0, n_elements(det1_files) -1 DO BEGIN
   null = mrdfits(det1_files[i], 0, nullh)
   det1 = mrdfits(det1_files[i], 1, det1h)
   x_drift = interpol(shift_x, shift_time, det1.time)
   y_drift = interpol(shift_y, shift_time, det1.time) 
   det1.x_det1 -= x_drift
   det1.y_det1 -= y_drift
   outdir = file_dirname(det1_files[i])
   outfile = outdir+'/'+file_basename(det1_files[i], '.fits')+'_jovpos2.fits'

   mwrfits, null, outfile, nullh, /create
   mwrfits, det1, outfile, det1h
ENDFOR


END
