//	This script will get a front image and find a point ROI which is selected. If no point ROI is selected,
//	a new one will be created at the center of the image

	ROI GetOrCreatePointROI( Image img )
	{
		ImageDisplay imgDisp
		Try imgDisp = img.ImageGetImageDisplay(0) Catch Throw("No image found")

		ROI r

		Number ROI_count = imgDisp.ImageDisplayCountROIs()
		Number w, h, ROI_w, ROI_h, cx, cy, bRet

		Number ROI_Found = 0

		//	find a point ROI which is selected
 
		for( number i = ROI_Count-1;i>=0; i--)	// check to see there is any point ROI and if it is selected
		{
			r = imgDisp.ImageDisplayGetROI(i)

			If( r.ROIIsPoint() && imgDisp.ImageDisplayIsROISelected(r) )
			{
				ROI_Found =1
				i = -1
			}
			ELSE if( r.ROIIsPoint() )
			{
				ROI_Found = 1
				i=-1
			}
		}

		If( !ROI_Found )				// create a point ROI if there is not any ROI present
		{
			img.GetSize(w, h)
			r = CreateROI()
                        bRet = GetPersistentNumberNote("Distort:CenterX", cx);
                        if (bRet < 1)
                        {
                           cx = w/2;  // set to middle
                           SetPersistentNumberNote("Distort:CenterX", cx);
                        }

                        bRet = GetPersistentNumberNote("Distort:CenterY", cy);
                        if (bRet < 1)
                        {
                           cy = h/2;  // set to middle
                           SetPersistentNumberNote("Distort:CenterY", cy);
                        }
			
			r.ROISetPoint( cx, cy )
			imgDisp.ImageDisplayAddROI(r)
			imgDisp.ImageDisplaySetROIselected(r,1)
		}

		r.ROISetVolatile(0)				// set ROI to be non-volatile

		return r
	}

Class FindCenterHandler : UIFrame
{
	Image img, dst, dsd, lpf, bf0, bf1, bf2
	Number centerX, centerY		// center location (can be of sub-pixel values)
	Number cx, cy				// center ROI location
	Number k, shift, col_shift
	Number cycle, dst_w
	ImageDocument dsd_ImgDoc
	ImageDisplay dst_dsp, dsd_dsp, lpf_dsp

	Number origin, scale, a_scale

	ROI center_ROI

	number top, left, bottom, right

	void UpdateFitIndicator( object self )
	{
		String fit = "visual fit indicator = " + format( rms(dsd[]), "%#.2f" )
		TagGroup tg = self.LookUpElement( "fit")
		tg.DLGTitle( fit )
		return
	}

	void Unwind( object self )
	{
		dst = warp( img, irow*cos(icol*k)+centerx, irow*sin(icol*k)+centery )		// unwind image
		dsd = dst - warp( dst, mod( icol + col_shift, dst_w), irow)					// shift unwound image
																				// then calcuate the difference
		self.UpdateFitIndicator()
		return
	}

	void HexLattice( object self, number index, number &dx, number &dy)
	{
		If( index == 1 ) {; dx = -1/2; dy =  sqrt(3)/2; return; }
		If( index == 2 ) {; dx = -1/2; dy = -sqrt(3)/2; return; }
		If( index == 3 ) {; dx =    1; dy =          0; return; }
		If( index == 4 ) {; dx =  1/2; dy =  sqrt(3)/2; return; }
		If( index == 5 ) {; dx =  1/2; dy = -sqrt(3)/2; return; }
		If( index == 6 ) {; dx =   -1; dy =          0; return; }

		dx = 0; dy = 0
		return
	}

	void changed( object self)
	{
		self.LookUpElement("cx").DLGTitle("  "+ format(centerX, "%#.2f" ))
		self.LookUpElement("cy").DLGTitle("  "+ format(centerY, "%#.2f" ))
		self.Unwind()

		If( abs(centerX-cx) >= 1 || abs(centerY-cy) >= 1 ) center_ROI.ROISetPoint( centerX, centerY)
		center_ROI.ROISetLabel( "" + format(centerX, "%#.2f" ) + ", " + format(centerY, "%#.2f" ))

		return
	}

	void setup( object self, ROI CenterPt, Image &srcImg)
	{
		// If( !GetNumber( "How many cycle(s) to unwind this image ?", 1, cycle) ) exit(0)
		cycle = 1				// One cycle
		cycle = 2*Pi()*cycle	// angular range to be shown in the "unwound" image - "dst"
		shift = Pi()			// relative "shift" of the "differential" unwound image - "dsd"
		dst_w = 720				// set the height of "unwound" images "dst" and "dsd"
		
		k = cycle/dst_w			// caculated sampling frequency "k". For cycl=2*Pi() and dst_h=360,
								// the sampling frequency is 2*180/360=1 degree per pixel

		col_shift = shift/k		// calucated number of rows to be shifted

		If( !CenterPt.ROIIsPoint() ) exit(0)

			img := srcImg
			CenterPt.ROIGetPoint( cx, cy)
			CenterX = cx
			CenterY = cy

			Number xSize, ySize
			GetSize( img, xsize, ysize )
			Number halfMinor = min( xsize, ysize )/2		// determine the width of "unwound" image

			dst := CreateFloatImage( "unwound image", dst_w, halfMinor )
			dsd := CreateFloatImage( "differential image", dst_w, halfMinor )
			lpf := CreateFloatImage( "fit residules", dst_w, 1 )	// line profile display to display fit residules

			bf0 := CreateFloatImage( "buffer0", dst_w, 1 )			// buffer image 0
			bf1 := CreateFloatImage( "buffer1", dst_w, 1 )			// buffer image 1
			bf2 := CreateFloatImage( "buffer2", dst_w, 1 )			// buffer image 2

			dst.SetSurveyTechnique(2)		// use "sparse" as survey technque
			dst.SetSurvey(1)				// set auto survey to be "on"
			dst.ShowImage()
            // dst.SetSurvey(0)                // now turn it off
            // dst.UpdateImage()
			dst_dsp = dst.ImageGetImageDisplay(0)

			dsd.SetSurveyTechnique(2)		// use "sparse" as survey technque
			dsd.SetSurvey(1)				// set auto survey to be "on"
			dsd.SetSelection( halfminor*5/7, 0*dst_w/3, halfminor*6/7, dst_w*3/3)
			dsd.ShowImage()
            // dsd.SetSurvey(0)
            // dsd.UpdateImage()
			dsd_dsp = dsd.ImageGetImageDisplay(0)
			dsd_imgDoc = dsd_dsp.ComponentGetImageDocument()

			lpf_dsp = dsd_imgDoc.ImageDocumentAddImageDisplay(lpf, 3)
			dsd_dsp.ComponentAddChildAtEnd(lpf_dsp)
			lpf_dsp.LinePlotImageDisplaySetContrastLimits( -10, 10 )  
  			lpf_dsp.LinePlotImageDisplaySetDoAutoSurvey( 0, 0 )
			lpf_dsp.LinePlotImageDisplaySetGridOn(0)  								// set grid off
  			lpf_dsp.LinePlotImageDisplaySetSliceComponentColor(0, 1, 0.9, 0, 0) 	// set fill color to red
			lpf_dsp.LinePlotImageDisplaySetFrameOn(1)  								// set frame on
			lpf_dsp.LinePlotImageDisplaySetBackgroundOn(0)							// set background off
			lpf_dsp.ImageDisplaySetCaptionOn(0)										// set caption off
			lpf_dsp.ImageDisplaySetImageRect(0, 0, halfMinor/4, dst_w-1)

			// calibrated the unwound images
			dst.ImageSetDimensionCalibration(1, 0, 1, "pixel", 1) 	// set dimension 0 (x) as pixel
			dst.ImageSetDimensionCalibration(0, 0, cycle/pi()*180/dst_w, "degree", 1)	// set dimension 1 (y) as degree

			dst_dsp.ImageDisplaySetCaptionOn(1)

			dsd.ImageSetDimensionCalibration(1, 0, 1, "pixel", 1) 	// set dimension 0 (x) as pixel
			dsd.ImageSetDimensionCalibration(0, 0, cycle/pi()*180/dst_w, "degree", 1)	// set dimension 1 (y) as degree

			dsd_dsp.ImageDisplaySetCaptionOn(1)

			Center_ROI = CenterPt
			self.Changed()

		return
	}

	void GetNew( object self )								// obtain a new source image
	{
		dsd.DeleteImage()
		Image img:=GetFrontImage()
		ROI r = img.GetOrCreatePointROI()
		self.Setup(r, img)
		return
	}


	// Get a new radius-angle curve w.r.t center location shift (dx, dy) and return chi**2

	number GetChi2WithCenterShift( object self, number dx, number dy)	
	{
		If( dx!=0 || dy!=0 )
		{
			bf1 = sqrt(	( (bf0.index(icol,irow)-origin)*scale*cos(icol*a_scale/180*pi()) - dx )**2 + \
						( (bf0.index(icol,irow)-origin)*scale*sin(icol*a_scale/180*pi()) - dy )**2 )
		}
		Else bf1 = (bf0-origin)*scale

		bf2 = bf1.warp( mod(icol+col_shift, dst_w), irow)		// do a 180 degree shift

		bf1.SetSelection(0, left, 1, right)
		bf2.SetSelection(0, left, 1, right)

		return ((bf2[]-bf1[])**2/bf1[]).sum() 	// calculate chi**2 within selected area
	}

	void CenterFit( object self )
	{
		Number stp = 2.56									// search range, in pixel
		Number stp_min = 0.01								// minimum search range, also in pixel
		Number total_steps = log(stp/stp_min)/log(2) + 1	// estimate of total number of search range reductions (by 2 each time)
																

		self.LookUpElement("rng").DLGTitle("search ±"+format(stp,"%#.2f")+"px")

		Number delta_x, delta_y								// temperatory variables for center location shift
		Number count = 1									// counter for tracking progress

		// get initial chi**2
		Number chi2, best_chi2
		best_chi2 = self.GetChi2WithCenterShift(0,0)

		number new_min = 1			// flag used to track if a new best chi**2 is found
		while( new_min == 1 || stp >= stp_min )
		{ 		
			new_min = 0
    		self.dlgsetprogress("progbar", count/total_steps)

			self.DLGValue("stp", stp);
			self.LookUpElement("rng").DLGTitle("search ±"+format(stp,"%#.2f")+"px")
			self.ValidateView()

			for( number index = 1; index <= 6; index ++)
			{ // ----------------------------------------------------------------------------------------------------

				Number dx, dy
				self.HexLattice( index, dx, dy )
				delta_x = dx*stp; delta_y = dy*stp

				chi2 = self.GetChi2WithCenterShift( delta_x, delta_y )

				// result("\n center x = " + format(centerX+delta_x,"%#.2f") + ", center y = " + format(centerY+delta_Y,"%#.2f") +\
				//					   ", chi**2 = " + format(chi2,"%#.3f") )


				If( (chi2-best_chi2)<=-0.001 )	// found a better chi**2 value
				{;	best_chi2 = chi2
					bf0 = bf1
					new_min = 1

					// update center location
					centerX += delta_x			// update center location
					centerY += delta_y

					// update fit residual display
					lpf = bf2-bf1
					lpf.UpdateImage()

					index = 7; }

				// interuption point
				If( GetKey() == 32 )
				{;	self.Changed()
					Result( "\n -------****------- Auto fit interupted -------****----------- \n")
					return;}

			} // ----------------------------------------------------------------------------------------------------
		

			If( new_min == 0 )							// reduced search range when no better chi**2 can be found
			{
 				stp = stp/2
  				count ++; }

		} // end while

		return
	}

	void AutoFit( object self)
	{
		Number iteration = 0							// counter for tracking number of iterations

		// get fitting range
		dsd.GetSelection(top, left, bottom, right)
		dst.SetSelection(top, 0, bottom, dst_w)

		// do the radius-angle transform
		bf0 := dst[].ImageClone().FindVerticalMaximumPosition(0,2)
		bf0.SetName( "buffer 0")

		// Obtain proper calibration information in order to do calculate properly
		 origin = bf0.ImageGetIntensityOrigin()
		  scale = bf0.ImageGetIntensityScale()
		a_scale = bf0.ImageGetDimensionScale(0)

		// get initial chi**2
		Number chi2, best_chi2
		chi2 = self.GetChi2WithCenterShift(0,0)
		best_chi2 = chi2

		// initiallize fit residule display (line plot) attributes
		lpf.SetSelection(0, left, 1, right)
		lpf = bf2-bf1
		lpf.UpdateImage()

		// update chi**2 display
		self.LookUpElement("chi2").DLGTitle( "chi**2 = " + format(best_chi2, "%#.3f") )

		Result( "\n --------------------- Auto fit start --------------------- ")
		result("\n center x = " + format(centerX,"%#.2f") + ", center y = " + format(centerY,"%#.2f") +\
			  ", best chi**2 = " + format(best_chi2,"%#.3f") )

		Number cont = 1
		While( cont )
		{
			iteration ++
			self.LookUpElement("iteration").DLGTitle("iteration:"+iteration)
		    self.ValidateView()

			// find center by shifting center location without calculating new radius-angle curve
			self.CenterFit()
	    	self.dlgsetprogress("progbar", 0)			// reset progress bar
		
			// unwind source image (calculate new radius-angle curve) with new center position
			self.Changed()
			bf0 = dst[].FindVerticalMaximumPosition(0,2)
			chi2 = self.GetChi2WithCenterShift(0,0)

			if( chi2 < best_chi2 )
			{
				best_chi2 = chi2
				// update center point display
				self.LookUpElement("cx").DLGTitle("  "+ format(centerX, "%#.2f" ))
				self.LookUpElement("cy").DLGTitle("  "+ format(centerY, "%#.2f" ))

				// update chi**2 display
				self.LookUpElement("chi2").DLGTitle( "chi**2 = " + format(best_chi2, "%#.3f") )
		   		self.ValidateView()

				result("\n center x = " + format(centerX,"%#.2f") + ", center y = " + format(centerY,"%#.2f") +\
				  		 ", best chi**2 = " + format(best_chi2,"%#.3f") )
			}
			Else cont = 0
		}
                
                // let's save these so we can get them later
                string sLastName = GetName(img)
                SetPersistentStringNote("Distort:ImgName", sLastName);
                SetPersistentNumberNote("Distort:CenterX", centerX);
                SetPersistentNumberNote("Distort:CenterY", centerY);

		Result( "\n ---------------------- Auto fit end ---------------------- \n")
	
		dst.ShowImage()
		return
	}
		
	void cx_down( object self )
	{;If(ControlDown()) centerX-=0.1 else if(shiftDown()) centerX-=5 else centerX-=1.0; self.changed(); return;}

	void cx_up( object self )
	{;If(ControlDown()) centerX+=0.1 else if(shiftDown()) centerX+=5 else centerX+=1.0; self.changed(); return;}

	void cy_down( object self )
	{;If(ControlDown()) centerY-=0.1 else if(shiftDown()) centerY-=5 else centerY-=1.0; self.changed(); return;}

	void cy_up( object self )
	{;If(ControlDown()) centerY+=0.1 else if(shiftDown()) centerY+=5 else centerY+=1.0; self.changed(); return;}


	~FindCenterHandler( object self)		// object destructor
	{
		bf1.DeleteImage()
		bf2.DeleteImage()
		dsd.DeleteImage()
		lpf.DeleteImage()
		return
	}

}

void DiffractionRingFindCenter(image img)	// Encapsulate the main script as a function so it is in "local" scope.
											// This is to solve the memory leak problem.
{

	Number cx = img.ImageGetDimensionSize(0)/2
	Number cy = img.ImageGetDimensionSize(1)/2
	//	Construct the basic dialog tag
	TagGroup dialog_items
	TagGroup dialog = DLGCreateDialog( "fit", dialog_items )

	//	Build the positioning from application window
	TagGroup position = DLGBuildPositionFromApplication()

	//  Set width and position of floating palette
	position.TagGroupSetTagAsString( "Width",  "Medium")
	position.TagGroupSetTagAsString( "Side", "Top" )
	dialog.TagGroupSetTagAsTagGroup( "Positioning", position )

	TagGroup tgBoxItems1
	dialog_items.DLGAddElement( DLGCreateBox( "", tgBoxItems1) )
	tgBoxitems1.DLGAddElement( DLGCreateLabel( "visual fit indicator:            " ).DLGIdentifier("fit"))

	dialog_items.DLGAddElement( DLGGroupItems( \
									DLGCreateLabel( "center X").DLGSide("Left"),\
									DLGCreatePushButton( "<", "cx_down").DLGSide("Left"),\
									DLGCreateLabel( "  " + format(512, "%#.2f") + "  ").DLGIdentifier("cx").DLGSide("Left"),\
									DLGCreatePushButton( ">", "cx_up")) )

	dialog_items.DLGAddElement( DLGGroupItems( \
									DLGCreateLabel( "center Y").DLGSide("Left"),\
									DLGCreatePushButton( "<", "cy_down").DLGSide("Left"),\
									DLGCreateLabel( "  " + format(cy, "%#.2f") + "  ").DLGIdentifier("cy").DLGSide("Left"),\
									DLGCreatePushButton( ">", "cy_up")) )

	TagGroup tgBoxItems2
	dialog_items.DLGAddElement( DLGCreateBox( "", tgBoxItems2) )

	tgBoxitems2.DLGAddElement( DLGCreatePushButton( " Auto Find Center ", "AutoFit") )
	tgBoxitems2.DLGAddElement( DLGGroupItems( \
								DLGCreateLabel( "search ±3.20px,").DLGWidth(16).DLGIdentifier("rng").DLGSide("Left"), \
								DLGCreateLabel( "iteration ---").DLGWidth(16).DLGIdentifier("iteration")) )
	tgBoxitems2.DLGAddElement(DLGCreateProgressBar( "progbar").DLGFill( "X" ) )

	tgBoxItems2.DLGAddElement( DLGCreateLabel( "chi**2 = " + format(0, "%#.3f") + " pixels").DLGIdentifier("chi2"))

	dialog_items.DLGAddElement( DLGCreatePushButton( "start a new fit", "GetNew") )

	// allocate and initialize object
	object FindCenter = Alloc(FindCenterHandler)
	FindCenter.init(dialog)
    
    // Show the dialog 
    FindCenter.Display("Find Center");

	ROI r = img.GetOrCreatePointROI()
	FindCenter.SetUp(r, img)
		
	return
}

GetFrontImage().DiffractionRingFindCenter()
