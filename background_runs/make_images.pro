pro make_images

dir='/Users/bwgref/science/casA/data/40001019_Cas_A'
obsid='40001019002'

dir='/home/nustar1/bwgref/science/nustar/jupiter/data/20013036_Jupiter_2015_030_032'
obsid='20013036002'


;eranges = [['65', '68'], ['65', '70'], ['68', '70'], ['65', '79'], ['75', '79'], $
          ; ['4', '6'], ['8', '10'], ['10', '15'], ['15', '20'], ['20', '25'], $
          ; ['25', '35'], ['35', '45'], ['45', '55'], ['55', '65'], ['70', '80']]


eranges= [['3', '10'], ['3', '5'], ['5', '10'], ['10', '20']]


npairs = n_elements(eranges[0, *])
ab = ['A', 'B']
;for i = 0, npairs - 1 do $
;   for iab = 0, 1 do $
;      print, './mkimgs.py '+file_basename(dir)+' '+obsid+' '+eranges[0, i]+' '+eranges[1, i]

for i = 0, npairs - 1 do $
   for iab = 0, 1 do $
      nuskybgd_image, dir, obsid, 'im'+ab[iab]+eranges[0, i]+'to'+eranges[1, i]+'keV.fits', fix(eranges[0, i]), fix(eranges[1, i]), $
                      ab[iab], 'bgd', 'bgdspec'



end

