Number CCD_Size = 1024
Number mask_Size = 128
Number time = 0.5

If( !GetNumber( "center mask size = ? \n (even number only)", mask_size, mask_size ) ) exit(0)
If( !GetNumber( "acquisition time = ? sec.",time, time) ) exit(0)

Number t, l, b, r
Number buffer_Size = (CCD_Size - mask_size)/2 // Calculate buffer size

// initialize final image and buffer image
Image img1 := IntegerImage( "Acquired", 2, 1, CCD_Size, CCD_Size)
Image img2 := IntegerImage( "difference", 2, 1, CCD_Size, CCD_Size)
img1 = 0; img2 = 0
SetZoom(img1, 0.5); SetZoom(img2, 0.5)
ShowImage(img1)

// SetContrastmode(Img1,5)


void MSC_Acquire_Rectangle( Image &img1, number time, number t, number l, number b, number r )
{
	Image buffer := SSCGainNormalizedBinnedAcquire(time, 1, t, l, b, r)
	img1[t, l, b, r] = buffer
	DeleteImage( buffer )
	UpdateImage(img1)
	return
}

// Acquire top buffer
t = 0; l = 0; b = buffer_size; r = CCD_Size
MSC_Acquire_Rectangle( img1, time, t, l, b, r)

// Acquire bottom buffer
t = CCD_Size-buffer_size; l = 0; b = CCD_size; b = CCD_Size;
MSC_Acquire_Rectangle( img1, time, t, l, b, r)

// prepare for difference image
img2 = img1

// Acquire left buffer
t = 0; l = 0; b = CCD_size; r = buffer_Size;
MSC_Acquire_Rectangle( img1, time, t, l, b, r)

// Acquire right buffer
t = 0; l = CCD_Size-buffer_size; b = CCD_size; r = CCD_Size;
MSC_Acquire_Rectangle( img1, time, t, l, b, r)

// process difference image
img2 = img2 - img1
img2[ buffer_size, 0, CCD_Size-buffer_size, CCD_Size] = 0 

// display images
ShowImage(img2)
SetSurvey(img2, 0)
Number limit = RMS(Img2)
SetLimits(img2, -1*limit, limit)
ShowImage(img1)
