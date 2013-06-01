/*  ----------------------------------------------------------------------------------------------------
	This function generate a normalized Gaussian Kernel with specified sigma (in pixel),
	and the kernel can be of different sizes in width and length.
	---------------------------------------------------------------------------------------------------- */

	image Create2DGaussianKernel( number sigmaX, number sigmaY )
	{
		number ksizeX, ksizeY, centerX, centerY
		Image kernel

		sigmaX = abs(sigmaX)
		sigmaY = abs(sigmaY)
		
		// The kernel size is set to be two sigma (minimum kernel diemension is 3)
		ksizeX = round((sigmaX)*2*2) + 1
		If( ksizeX <=3 && ksizeX > 1 ) ksizeX = 3

		ksizeY = round((sigmaY)*2*2) + 1
		If( ksizeY <=3 && ksizeY > 1 ) ksizeY = 3

		centerX = (ksizeX-1)/2
		centerY = (ksizeY-1)/2

		Kernel:=Realimage("Gaussian kernel "+sigmaX+" x "+sigmaY+" pixels", 4, ksizeX, ksizeY)


		// generate Gaussian kernel
		If( sigmaX!=0 && sigmaY!=0 )
		{
			// generate two dimensional kernel
			kernel = exp( -0.5*(((icol-centerX)/sigmaX)**2+((irow-centerY)/sigmaY)**2) ) \
					/(2*pi()*(sigmaX**2+sigmaY**2)/2)
		}
		ELse If( sigmaX!=0 && sigmaY==0 )
		{
			// generate one dimensional kernel
			kernel =  exp( -0.5*((icol-centerX)/sigmaX)**2 ) / (2*pi()*sigmaX**2)
		}
		ELse If( sigmaX==0 && sigmaY!=0 )
		{
			// generate one dimensional kernel
			kernel =  exp( -0.5*((irow-centerY)/sigmaY)**2 ) / (2*pi()*sigmaY**2)
		}
		Else kernel = 1

		// normalize the kernel
		kernel = kernel / sum(kernel)
		return kernel
	}

/*  ----------------------------------------------------------------------------------------------------
	This function will convolute source image with a "kernel" image. There is no size limit on kernel
	but the execution time will be proportional to the kernel size (i.e. kernel width x kernel height)
	---------------------------------------------------------------------------------------------------- */

	image ConvoluteWith( image srcImg, image kernel )
	{
		// Get image size
		number w, h
		srcImg.GetSize( w, h )

		// initialize convoluted image
		Image sumImg := RealImage( srcImg.GetName() + " - convoluted", 4, w, h )
		sumImg.ImageCopyCalibrationFrom( srcImg )
		sumImg = 0

		// get kernel size and center location
		number kernel_w, kernel_h
		getsize(kernel, kernel_w, kernel_h)
		Number cx=(kernel_w-1)/2, cy=(kernel_h-1)/2

		// convolute with "offset" method
		For(Number k_col=0; k_col<kernel_w; k_col++)
		{;For(Number k_row=0; k_row<kernel_h; k_row++)
			{;sumImg += Offset(srcImg, k_col-cx, k_row-cy)*Getpixel(kernel, k_col, k_row)
		};}

		return sumImg
	}

/*  ----------------------------------------------------------------------------------------------------
	This function will copy the dimensional calibration of source image to target image as intensity
	calibration.

	It is noted that the in the following script function:
	void ImageGetDimensionCalibration(	ImageReference, Number dimension, NumberVariable origin,
										NumberVariable scale, String units, Number calFormat )
 
  
	, the 'calFormat' always reads zero, regardless how it was set to the image originally.
	This indicates that when setting the dimensional calibration to the image with varius calFormat,
	the DM automatically convert the "origin" stored in the image as if the calFormat=0.

	Here are a brief description of calFormat when set to an image provided by Douglas Hauge of Gatan
			
		The 'CalibrationFormat' is an enum specifying how the origin and scale are
		combined to provide a transformation from calibrated to uncalibrated coordinates.
		In the following, 'cal_val' is the calibrated value, 'uncal_val' is the uncalibrated value,
		and 'origin' and 'scale' are the paramters passed to or returned from the function

		enum CalibrationFormat
		{
		  e_CalibrationFormat_CO_CS = 0x0000	// calFormat = 0:    cal_val = uncal_val* scale + origin
		, e_CalibrationFormat_UO_CS = 0x0001	// calFormat = 1:    cal_val = (uncal_val - origin ) * scale
		, e_CalibrationFormat_CO_US = 0x0100	// calFormat = 255:  cal_val = uncal_val/ scale + origin
		, e_CalibrationFormat_UO_US = 0x0101	// calFormat = 256:  cal_val = (uncal_val - origin ) / scale
		};

	It is also very important to note that the "origin" value get via the 'ImageDislay ...' contextual
	dialog window is different than the "origin" obtained from the script function. This origin value
	read from dialog window conforms the calculation method of 'calFormat=1'.

	On the other hand, the intensity calibration behaves differently than the dimension. The intensity "origin"
	obtained from the ImageGetIntensityOrigin() script function conforms the "calFormat = 1" method. It is the
	same as that read from the dialog window of 'ImageDisplay ...'. Consequently, the ImageSetIntensityOrigin()
	script commands adopts the method of "calFormat=1". So when copy the dimension calibration to intensity
	calibration, the "origin" value (which conforms 'calFormat=0') needs to be converted a value that conforms
	the 'calFormat=1' method.

		(uncal_val - origin_intensity)*scale = uncal_val*scale + origin_dimension

	so  origin_intensiy = -1 * origin_dimension/scale
				
	---------------------------------------------------------------------------------------------------- */

	void CopyDimensionCalibrationAsIntensity( Image &trgImg, Image &srcImg, Number dimension )
	{
		
		Number origin, scale, calFormat
		string units

		// Get dimension calibration of  source image
		srcImg.ImageGetDimensionCalibration(dimension, origin, scale, units, calFormat )

		If( calFormat != 0 ) Throw( "Wrong Calibration Format encountered. CalFormat = "+calFormat)

		origin = -1*origin / scale

		trgImg.ImageSetIntensityOrigin( origin )
		trgImg.ImageSetIntensityUnitString(units)
		trgImg.ImageSetIntensityScale(scale)

		return
	}



/*	----------------------------------------------------------------------------------------------------
	This script will find the maximum of every column of an image. The result will be returned as a
	one-dimensional image (line profile). In this profile, the intensity value of each column represents
	the position (row number) of the pixel with maximum intensity in that column of the source image.

	An asymetrical Gaussian kernel can also be applied to the source image before finding maximum pixels
	in vertical direction. Kernel value represents pixel number of one sigma. Set kernel value to zero
	if no Gaussian smooth is needed.
	---------------------------------------------------------------------------------------------------- */
	
Image FindVerticalMaximumPosition( Image srcImg, number Gaussian_smooth_row, number Gaussian_smooth_col, Number ShowPeak )
{
	Number width, height
	srcImg.GetSize( width, height)

	Image buffer := srcImg.ImageClone()
	buffer = buffer.ConvoluteWith( Create2DGaussianKernel(Gaussian_smooth_row, Gaussian_smooth_col))
	
	Number mx
	for( number col=0; col<width; col++)					
	{												
		mx = buffer[0, col, height, col+1].max()		// Find the maximun intensity of each column

		// Find the row number in that column has the maximum intensity,
		// write the row number to that pixel and then set rest pixels
		// in that column to zero.

		buffer[0, col, height, col+1] = tert( buffer[col,irow]==mx, irow, 0)
	}																	

	// initialize result line plot
	Image rst := RealImage( "Vertical Maximum Position", 4, width, 1 )
	rst = 0

 	//
	// The following operation will do a vertical sum of image 'buffer'.
	//
		// ----------------- Adopted from an example script by Gatan ----------------
		// Copyright © 1995, Gatan Inc.
		// All rights reserved.
		// Written by Chris Meyer, 3/23/95.
		// ---------------------------------------------------------------------------
			rst.Index(icol, 0) += exprsize( width, height, buffer.index(icol, irow))
		// ---------------------------------------------------------------------------
	//

	If( ShowPeak == 1 )
	{
		Image Peak := srcImg.ImageClone()
		Peak = tert( buffer!=0, 0, peak )
		Peak.ShowImage()
	}

	// set calibration of result image
	Number origin, scale, calFormat
	string units

	// Get and set calibration of dimension '0'
	buffer.ImageGetDimensionCalibration(0, origin, scale, units, calFormat)
	rst.ImageSetDimensionCalibration   (0, origin, scale, units, calFormat)

	// Get calibration of dimension '1' of source image and set it as
	// intensity calibration of result image
	rst.CopyDimensionCalibrationAsIntensity( buffer, 1 )

	buffer.DeleteImage()			// house keeping
	return rst
}


/*	----------------------------------------------------------------------------------------------------
	Overloaded function of ImageFindVerticalMaximumPosition. The variables "Gaussian_smooth_col" and
	"Gaussian_smooth_row" are used to specify a Gaussian kernel which can have different sigmas in column
	and row directions. The values of smooth variables represents number of pixels of one sigma.	
	---------------------------------------------------------------------------------------------------- */
Image FindVerticalMaximumPosition( Image srcImg, number Gaussian_smooth_row, number Gaussian_smooth_col )
{
	return srcImg.FindVerticalMaximumPosition( Gaussian_smooth_row, Gaussian_smooth_col, 0)
}

Image FindVerticalMaximumPosition( Image srcImg )
{
	return srcImg.FindVerticalMaximumPosition(0, 0, 0)
}

// GetFrontImage()[].FindVerticalMaximumPosition(0,2,1).ShowImage()

