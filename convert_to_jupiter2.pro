pro convert_to_jupiter2

forward_function read_ephem

evtfile = getenv('convert_to_jupiter_file')

f = file_info(evtfile)
if ~f.exists then message, 'File not found!'

outpath = file_dirname(evtfile)
outfile = outpath+'/'+file_basename(evtfile, '.evt')+'_jovpos2.evt'

null = mrdfits(evtfile, 0, nullh)
evt=mrdfits(evtfile,1,evth)
gti=mrdfits(evtfile,2,gtih)

   ; Find the vals associated with X and Y
ttype = where(stregex(evth, "TTYPE", /boolean))
xt = where(stregex(evth[ttype], 'X', /boolean))
yt = where(stregex(evth[ttype], 'Y', /boolean))

   ; Converted X/Y is always last in the header:
   ; Parse out the position:
xpos = (strsplit( (strsplit(evth[ttype[max(xt)]], ' ', /extract))[0], 'E', /extract))[1]
ypos = (strsplit( (strsplit(evth[ttype[max(yt)]], ' ', /extract))[0], 'E', /extract))[1]

 ; Grab astrometry header keywords:
ra0 = sxpar(evth,'TCRVL'+xpos)     ; should match TCRVL13 which has lower precision
dec0 = sxpar(evth,'TCRVL'+ypos)    ; should match TCRVL14 which has lower precision
x0 = sxpar(evth,'TCRPX'+xpos)      ; x ref pixel in same axes as x, y
y0 = sxpar(evth,'TCRPX'+ypos)      ; y ref pixel
delx = sxpar(evth,'TCDLT'+xpos)    ; pixel size in degree
dely = sxpar(evth,'TCDLT'+ypos)    ; pixel size in degree

; Convert to RA/DEC
yd = dec0 + (evt.y - y0)*dely
xr = ra0 + (evt.x - x0)*delx/cos(dec0/180.0d0*!dpi) ; imperfect correction for cos(dec) for quick work


; Convert event files to MJD:
;   tt = evt.time mod 86400.0d0  ; seconds of current day
;   tmjd = 55197.0d0 + evt.time/86400.0d0
;tmjd = convert_nustar_time(evt.time, /mjd)


; Jupiter ephemeris
;save, ut, nustar_time, ra, dec, file = 'ephem.sav'
restore, 'ephem.sav'
xs = interpol(ra, nustar_time, evt.time)
ys = interpol(dec, nustar_time, evt.time)

mean_xs = mean(ra)
mean_ys = mean(dec)
mean_nustar_time = mean(nustar_time)
print, mean_xs, mean_ys, mean_nustar_time, format = '(3d20.6)'

; Compute shift in RA/Dec vs time (note, this is done in the time units of the
; ephemeris run).
drift_xs = ra - mean_xs
drift_ys = dec - mean_ys



; For later use, convert this to a change in pixel locations:
drift_xpix = drift_xs * cos(dec0/180.d*!dpi) / delX
drift_ypix = drift_ys / delY

openw, lun, 'jupiter_drift.txt', /get_lun
FOR i = 0, n_elements(drift_xs) -1 DO BEGIN
   printf, lun, nustar_time[i], drift_xpix[i], drift_ypix[i], format = '(3d25.8)'
ENDFOR
close, lun
free_lun, lun
 

;; Below is the old way, doing this in RA/Dec space. Let's use the drift_[x/y]pix values
;; that we've already converted to pixel coordinates above. This also matches what we do
;; to the DET1 file in adjust_det1.pro

;Interpolate these drifts onto the event times:
;x_drift = interpol(drift_xs, nustar_time, evt.time)
;y_drift = interpol(drift_ys, nustar_time, evt.time)
;
;Add this value onto the old values:
;new_x = (xr - x_drift)
;new_y = (yd - y_drift)

;; Interpolate the pixel drifts onto the event times:
drift_xpix_interp = interpol(drift_xpix, nustar_time, evt.time)
drift_ypix_interp = interpol(drift_ypix, nustar_time, evt.time)



;; Apply this correction to the events and round to the nearest sky pixel
evt.y = round( (evt.y - drift_y_pix_interp))
evt.x = round( (evt.x - drift_xpix_interp))



; Convert to back to sky pixels:
;; evt.y = round( (new_y - dec0) / delY + y0 )
;; evt.x = round ((new_x - ra0) * cos(dec0/180.0d0*!dpi) / delX + x0)

;yd = dec0 + (evt.y - y0)*dely
;xr = ra0 + (evt.x - x0)*delx/cos(dec0/180.0d0*!dpi) ; imperfect correction for cos(dec) for quick work
;evt.x = (dxs / delx) + x0 
;evt.y = (dys / dely) + y0

; Adjust astrometry headers
;; fxaddpar, evth, 'TCRVL'+xpos, '0.0'
;; fxaddpar, evth, 'TCRVL'+ypos, '0.0'
;; fxaddpar, evth, 'TCDLT'+xpos, delx
;; fxaddpar, evth, 'TCDLT'+ypos, dely
;; fxaddpar, evth, 'TLMAX'+xpos, maxX
;; fxaddpar, evth, 'TLMAX'+ypos, maxY
;; fxaddpar, evth, 'TCRPX'+xpos, x0
;; fxaddpar, evth, 'TCRPX'+ypos, y0
mwrfits, null, outfile, nullh, /create
mwrfits, evt, outfile, evth
mwrfits, gti, outfile, gtih

   

end



