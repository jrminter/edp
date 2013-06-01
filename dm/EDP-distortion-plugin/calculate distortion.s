class fit_handler : UIFrame
{
   Image rst, profile, linePlot, curve
   Number kernel_x, kernel_y
   Number width, height
   ImageDocument imgDoc_LP
   ImageDisplay imgDsp_LP
   Number radius, shift, delta

   number origin, scale, calFormat
   String units

   number a_origin, a_scale, a_calFormat
   String a_units

   Number best_chi2, distortion

   Number fit_range_a, fit_step_a
   Number fit_Range_dR, fit_step_dR
   Number fit_Range_R, fit_step_R

   void GetParameters( object self )
   {
      // read parameters
      If( !self.DLGGetValue( "delta", delta) ) Throw( "Cannot get delta radius!" )
      If( !self.DLGGetValue( "shift", shift) ) Throw( "Cannot get rotation!" )
      If( !self.DLGGetValue( "radius", radius) ) Throw( "Cannot get mean readius!" )

      shift = (shift - a_origin)/a_scale			// change shift back to be unit of uncalibrated
      delta = delta/scale
      radius =  radius/scale + origin

      LinePlot[3, 0, 4, width] = radius			// draw a line represent the raius in line plot

      return
   }

   void CreateLinePlot( object self )
   {
      // create image document for the line plot 
        imgDoc_LP = CreateImageDocument( "New ImageDocument" )

      // add LinePlotImageDisplay to ImageDocument  
        imgdsp_LP = imgDoc_LP.ImageDocumentAddImageDisplay( LinePlot, 3 )
      imgdsp_LP.LinePlotImageDisplaySetDoAutoSurvey( 0, 0 )		// auto survey both low and high
      imgdsp_LP.LinePlotImageDisplaySetGridOn(0)

      // draw fill for slice 0
      imgdsp_LP.LinePlotImageDisplaySetSliceDrawingStyle(0, 2)	// for data to be fitted

      // draw line for slice 1 to 3
      imgdsp_LP.LinePlotImageDisplaySetSliceDrawingStyle(1, 1)	// calculated curve ( ellipse )
      imgdsp_LP.LinePlotImageDisplaySetSliceComponentColor(1, 0, 0, 0, 1)	// set color to blue

      imgdsp_LP.LinePlotImageDisplaySetSliceDrawingStyle(2, 1)	// goodness of fit
      imgdsp_LP.LinePlotImageDisplaySetSliceComponentColor(2, 0, 1, 0, 0)	// set color to red

      imgdsp_LP.LinePlotImageDisplaySetSliceDrawingStyle(3, 1)	// calculated radius, a straight line
      imgdsp_LP.LinePlotImageDisplaySetSliceComponentColor(3, 0, 0.0, 0.5, 0.5)	// set color to green

      // display and set legend
      imgDoc_LP.ImageDocumentShow()
      
      return
   }
      
   void SetUpLinePlot( object self )
   {
      LinePlot[0, 0, 1, width] = profile
      // set line plot display
      Number stdev = sqrt(profile.rms()**2-profile.mean()**2)
      Number  low = profile.mean()-3*stdev
      Number high = profile.mean()+3*stdev

      imgdsp_LP.LinePlotImageDisplaySetContrastLimits( low, high )
      imgdsp_LP.LinePlotImageDisplaySetLegendshown(1)		// set line plot to display legend

      imgdsp_LP.ImageDisplaySetSliceLabelByID(imgdsp_LP.ImageDisplayGetSliceIdByIndex(0), "source data")
      imgdsp_LP.ImageDisplaySetSliceLabelByID(imgdsp_LP.ImageDisplayGetSliceIdByIndex(1), "fitted ellipse")
      imgdsp_LP.ImageDisplaySetSliceLabelByID(imgdsp_LP.ImageDisplayGetSliceIdByIndex(2), "difference")
      imgdsp_LP.ImageDisplaySetSliceLabelByID(imgdsp_LP.ImageDisplayGetSliceIdByIndex(3), "mean radius")

      // set initial dR value
      self.DLGValue( "delta", round(10*stdev)/10)

      return
   }


   void UpdateLinePlot( object self )
   {
      LinePlot[0, 0, 1, width] = profile
      LinePlot[1, 0, 2, width] = curve
      LinePlot[2, 0, 3, width] = curve - profile + radius
      LinePlot[3, 0, 4, width] = radius			// draw a line represent the raius in line plot

      LinePlot.UpdateImage()
      return
   }

   void CalculateRadius( object self )
   {
      Number shift = 90/a_scale
      Image img_radius := (profile + warp(profile, mod(icol+shift, width), irow) )/2		// estimated radius variation with angle
      // LinePlot[1, 0, 2, width] = img_radius											// put result to line plot

      radius = img_radius.mean()					// calculate average radius
      LinePlot[2, 0, 3, width] = radius			// draw a line represent the raius in line plot

      // self.CheckCenter( img_radius )

      // set the radius label and radius field of dialog window

      string mean_radius = format( (radius-origin)*scale, "%#.2f")
      self.LookUpElement("mean_radius").DLGTitle( mean_radius)
      self.DLGValue("radius", (radius-origin)*scale)

      return
   }

   number FitCurve( object self, number shift, number delta, number radius )
   {
      // calculations here needs to be performed in the proper coordinate space
      number factor = 180/a_scale	
      Number  R = (radius-origin)*scale
      Number dR = delta*scale
      Number chi_sqr

      // calculate distortion
      distortion = (R-dR)/(R+dR)*100

      // calculate the expected radius curve
      curve = (R**2 - dR**2)/sqrt( \
            R**2 + dR**2 - 2*dR*R*cos(2*(icol-shift)/factor*pi()) )

      // calculate chi square 
      chi_sqr = sum( ((profile-origin)*scale-curve)**2/curve )

      // transform the calculated curve back
      curve = curve/scale + origin

      return chi_sqr
   }

   object setup( object self, image img )
   {
      fit_range_a = 5.0; fit_step_a = 50		// set the default range and steps for auto fitting "shift" (rotation of ellipse)
      fit_Range_dR = 2.0; fit_step_dR = 20	// same for the delta radius 
      fit_Range_R = 2.0; fit_step_R = 20		// same for the mean radius 

      rst := img[].ImageClone()
      rst.GetSize(width, height)

      Number row_smooth=0, col_smooth=1, show_peak = 0
      If( OptionDown() )
      {
         GetNumber("Horizontal Gaussiona smooth sigma ?", row_smooth, row_smooth)		
         GetNumber("Vertical Gaussiona smooth sigma ?", col_smooth, col_smooth)		
         GetNumber("show peak search result ?", show_peak, show_peak)		
      }

       profile := rst.FindVerticalMaximumPosition(row_smooth,col_smooth,show_peak)	// buffer image for storing radius of source image

      curve := RealImage( "fitted", 4, width, 1)			// buffer image for calculated radius
      curve =0

      LinePlot := RealImage( "Profile and fitted results", 4, width, 4)	// line plot for displaying results
      LinePlot = 0

      // Get and set spatial/angular (dimension 0) and calibration of line plot
      rst.ImageGetDimensionCalibration(0, a_origin, a_scale, a_units, a_calFormat )
      LinePlot.ImageSetDimensionCalibration(0, a_origin, a_scale, a_units, a_calFormat)

      // Get and set intensity calibration of line plot
      origin = Profile.ImageGetIntensityOrigin()
      units = Profile.ImageGetIntensityUnitString()
      scale = Profile.ImageGetIntensityScale()

      LinePlot.ImageSetIntensityOrigin( origin )
      LinePlot.ImageSetIntensityUnitString(units)
      LinePlot.ImageSetIntensityScale(scale)

      // display line plot
      self.CreateLinePlot()
      self.SetUpLinePlot()
      self.CalculateRadius()

      self.GetParameters()
      best_chi2 = self.FitCurve(shift, delta, radius) // set initial chi**2 to be infinite

      return self
   }

   void GetNew( object self ) // starting a new fit. Source image is the front image
   {
      self.Setup( GetFrontImage()[] )
      return
   }
   
   void changed( object self, tagGroup tgs)
   {
      self.GetParameters()
      Number chi2 = self.FitCurve(shift, delta, radius)
      If( chi2 < best_chi2) best_chi2 = chi2

      self.UpdateLinePlot()

      // Update dialog window
      self.LookUpElement( "dR").DLGTitle(""+format(delta*scale, "%#.2f") )
      self.LookUpElement( "rotation").DLGTitle(""+format( shift*a_scale + a_origin, "%#.2f"))
      self.LookUpElement("mean_radius").DLGTitle(""+format( (radius-origin)*scale, "%#.2f"))
      self.LookUpElement("chi2").DLGTitle( "current=" + format(chi2, "%#.4f") + ", (best=" + format(best_chi2, "%#.4f") + ")" )
      self.LookUpElement("distortion").DLGTitle( "distortion = " + format(distortion, "%#.2f") + " %" )

      return
   }

   Number Fit_shift( object self )
   {
      Number chi2, new_min_found = 0
      If( OptionDown() )
      {
         If( !GetNumber( "Current fit range is ±" + fit_range_a + "°, change it to:", fit_range_a, fit_range_a) ) return new_min_found
         self.LookUpElement("fit_shift").DLGTitle( "auto fit ( ± "+ fit_range_a +", 50 pts )" )
      }

      // convert angle to pixel
      Number shift_range = fit_range_a/a_scale

      best_chi2=self.FitCurve(shift, delta, radius)
      Number current_shift = shift

      for( Number i = current_shift-shift_range ; i <= current_Shift+shift_range; i+= shift_range/fit_step_a )
      {
         chi2 = self.FitCurve(i, delta, radius)
         If( chi2 < best_chi2 )
         {
            new_min_found = 1
            self.UpdateLinePlot()
            shift = i
            best_chi2 = chi2
            self.DLGValue("shift", shift*a_scale + a_origin)
         }
      }
      return new_min_found		
   }

   Number Fit_delta( object self )
   {
      Number chi2, new_min_found = 0
      If( OptionDown() )
      {
         If( !GetNumber( "Current fit range is ±" + fit_range_dR + "pixels, change it to:", fit_range_dR, fit_range_dR) ) return new_min_found
         self.LookUpElement("fit_delta").DLGTitle( "auto fit ( ± "+ fit_range_dR +", 20 pts )" )
      }

      // convert angle to pixel
      Number dR_range = fit_range_dR/scale

      best_chi2=self.FitCurve(shift, delta, radius)
      Number current_dR = delta
      for( Number i = current_dR-dR_range ; i <= current_dR+dR_range; i+= dR_range/fit_step_dR )
      {
         // result("\ndelta = " + i*scale + ", chi2 = " + chi2 + ", best chi2 = " + best_chi2)
         chi2 = self.FitCurve(shift, i, radius)
         If( chi2 < best_chi2 )
         {
            new_min_found = 1
            delta = i
            self.UpdateLinePlot()
            best_chi2 = chi2
            self.DLGValue("delta", delta*scale)
         }
      }
      return	new_min_found	
   }

   Number Fit_Radius( object self )
   {
      Number chi2, new_min_found = 0
      If( OptionDown() )
      {
         If( !GetNumber( "Current fit range is ±" + fit_range_R + "pixels, change it to:", fit_range_R, fit_range_R) ) return new_min_found
         self.LookUpElement("fit_radius").DLGTitle( "auto fit ( ± "+ fit_range_R +", 20 pts )" )
      }

      // convert angle to pixel
      Number R_range = fit_range_R/scale

      best_chi2=self.FitCurve(shift, delta, radius)
      Number current_R = radius
      for( Number i = current_R-R_range ; i <= current_R+R_range; i+= R_range/fit_step_R )
      {
         chi2 = self.FitCurve(shift, delta, i)
         If( chi2 < best_chi2 )
         {
            new_min_found = 1
            self.UpdateLinePlot()
            best_chi2 = chi2
            radius = i
            self.DLGValue("radius", (radius-origin)*scale)
         }
      }
      return new_min_found	
   }

   void AutoFitAll( object self )
   {
      // run first time fit with current fit range
      while( self.Fit_shift() || self.Fit_delta() || self.Fit_Radius()  )
      {
         self.LookUpElement("AutoFit").DLGTitle( " please wait ..." )
         self.ValidateView()
      }

      // run second time with current fit ranges reduced by 10
      fit_range_a  /= 10
      fit_Range_dR /= 10 
      fit_Range_R  /= 10 
      
      while( self.Fit_shift() || self.Fit_delta() || self.Fit_Radius()  )
      {
         self.ValidateView()
      }

      // Added by JRM 2008-06-03
      
      number nValMean  = (radius-origin)*scale
      number nValDelta = delta*scale
      number nValA     = nValMean + nValDelta
      number nValB     = nValMean - nValDelta
      number nEccent   = sqrt(nValA*nValA - nValB*nValB)/ nValA
      number nAngle    = shift*a_scale+a_origin
      // Added by JRM 2012-12-15
                
      SetPersistentNumberNote("Distort:MeanRad", nValMean);
      SetPersistentNumberNote("Distort:DeltRad", nValDelta);
      SetPersistentNumberNote("Distort:AnglDeg", nAngle);

        
      
      if (nAngle < 0) nAngle = 180.0 + nAngle

      result("\nellipse radius = " + format( (radius-origin)*scale, "%#.2f")+ "±" + format( delta*scale, "%#.2f") + " " + units + \
             "\nellipse inclination angle = " + format( shift*a_scale+a_origin, "%#.2f") + " " + a_units +\
             "\ndistortion = " + format(distortion, "%#.2f") + "(" + format(10000/distortion, "%#.2f") + ") %" + \
             "\nchi**2 = " + best_chi2 + "\n")

      
      // Added by JRM 2008-06-03
      number bRet, nCenterX, nCenterY
      string sImgName
      bRet = GetPersistentStringNote("Distort:ImgName", sImgName);
      bRet = GetPersistentNumberNote("Distort:CenterX", nCenterX);
      bRet = GetPersistentNumberNote("Distort:CenterY", nCenterY);

      result("\n\nInput for Janos Labar's Process Diffraction Program..." + \
             "\n       Image: " + sImgName + \
             "\n     CenterX: " + format(nCenterX, "%#.3f") + \
             "\n     CenterY: " + format(nCenterY, "%#.3f") + \
             "\n Mean Radius: " + format( (radius-origin)*scale, "%#.3f") + \
             "\nEccentricity: " + format( nEccent, "%#.4f") + \
             "\n       Angle: " + format( nAngle, "%#.2f") + " " + a_units + "\n")

      // restore fit ranges
      fit_range_a  *= 10
      fit_Range_dR *= 10 
      fit_Range_R  *= 10 
      
      self.LookUpElement("AutoFit").DLGTitle( "   Auto fit all   " )
      return
   }


   void s_down( object self )
   {
      If  (ShiftDown()) shift-=10 \
      else If(ControlDown()) shift-=0.1 \
      else If( OptionDown()) shift-=0.01 \
      else  shift-=1
      self.DLGValue("shift", shift*a_scale + a_origin)
   return
   }

   void s_up( object self )
   {
      If (ShiftDown()) shift+=10  \
      else If(ControlDown()) shift+=0.1  \
      else If( OptionDown()) shift+=0.01  \
      else shift+=1
      self.DLGValue("shift", shift*a_scale + a_origin)
      return
   }


   void d_down( object self )
   {
      If (ShiftDown()) delta-=10 \
      else If(ControlDown()) delta-=0.1 \
      else If( OptionDown()) delta-=0.01 \
      else delta-=1
      self.DLGValue("delta", delta*scale)
   return
   }

   void d_up( object self )
   {
      If (ShiftDown()) delta+=10 \
      else If(ControlDown()) delta+=0.1 \
      else If( OptionDown()) delta+=0.01 \
      else delta+=1
      self.DLGValue("delta", delta*scale)
      return
   }

   void r_down( object self )
   {
      If  (ShiftDown()) radius-=10	\
      else If(ControlDown()) radius-=0.1	\
      else If( OptionDown()) radius-=0.01	\
      else 				   radius-=1
      self.DLGValue("radius", (radius-origin)*scale)
      return
   }

   void r_up( object self )
   {
      If (ShiftDown()) radius+=10 \
      else If(ControlDown()) radius+=0.1 \
      else If( OptionDown()) radius+=0.01 \
      else radius+=1
      self.DLGValue("radius", (radius-origin)*scale)
      return
   }

}

void CalculateDistortion( image img )			// encapsulate to avoid memory leak
{

   // check if the image is the proper type and get calibration units
   String name
   img.GetName(name)

   String unit_0 = img.ImageGetDimensionUnitString(0)
   String unit_1 = img.ImageGetDimensionUnitString(1)

   If( unit_0 != "deg" && unit_0 != "degree" )
   {
       If( !ContinueCancelDialog( "The front image doesn't appear to be a proper image for this operation, continue?" ) ) exit(0)
   }

   // Setup initial parameters
   Number w, h
   img.GetSize( w, h)

   Number tp, lf, bt, rt
   img.GetSelection(tp, lf, bt, rt)

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
   dialog_items.DLGAddElement( DLGCreateBox( "rotation  (" + unit_0 + ")", tgBoxItems1) )
   tgBoxItems1.DLGAddElement(  DLGGroupItems( \
                               DLGCreateLabel( "", 8).DLGSide("Left").DLGIdentifier("rotation"),\
                               DLGCreatePushButton( "<", "s_down").DLGSide("Left"),\
                               DLGCreateRealField( 0, 7, 5, "changed").DLGIdentifier("shift").DLGSide("Left"),\
                               DLGCreatePushButton( ">", "s_up")).DLGAnchor("East") )
   tgBoxItems1.DLGAddElement(  DLGCreatePushButton( "auto fit ( ± 5.0, 50 pts )", "fit_shift").DLGIdentifier("fit_shift").DLGAnchor("North") )

   dialog_items.DLGAddElement( DLGCreatePushButton( "   Auto fit all   ", "AutoFitAll").DLGIdentifier("AutoFit").DLGAnchor("North") )

   TagGroup tgBoxItems2
   dialog_items.DLGAddElement( DLGCreateBox( "delta R (" + unit_1 + ")", tgBoxItems2) )
   tgBoxItems2.DLGAddElement(  DLGGroupItems( \
                               DLGCreateLabel( "", 8 ).DLGIdentifier("dR").DLGSide("Left"), \
                               DLGCreatePushButton( "<", "d_down").DLGSide("Left"),\
                               DLGCreateRealField( 0, 7, 5, "changed").DLGIdentifier("delta").DLGSide("Left"),\
                               DLGCreatePushButton( ">", "d_up").DLGAnchor("East")) )
   tgBoxItems2.DLGAddElement(  DLGCreatePushButton( "auto fit ( ± 2.0, 20 pts )", "fit_delta").DLGIdentifier("fit_delta").DLGAnchor("North") )

   TagGroup tgBoxItems3
   dialog_items.DLGAddElement( DLGCreateBox( "mean radius (" + unit_1 + ")", tgBoxItems3) )
   tgBoxItems3.DLGAddElement(  DLGGroupItems( \
                               DLGCreateLabel( "", 8 ).DLGIdentifier("mean_radius").DLGSide("Left"), \
                               DLGCreatePushButton( "<", "r_down").DLGSide("Left"),\
                               DLGCreateRealField( 0, 7, 5, "changed").DLGIdentifier("radius").DLGSide("Left"),\
                               DLGCreatePushButton( ">", "r_up").DLGAnchor("East")) )
   tgBoxItems3.DLGAddElement(  DLGCreatePushButton( "auto fit ( ± 2.0, 20 pts )", "fit_radius").DLGIdentifier("fit_radius").DLGAnchor("North") )


   dialog_items.DLGAddElement( DLGCreateLabel( " calculating distortion .... ").DLGIdentifier("distortion"))

   TagGroup tgBoxItems4
   dialog_items.DLGAddElement( DLGCreateBox( "chi**2", tgBoxItems4) )
   tgBoxItems4.DLGAddElement(  DLGCreateLabel( "",35 ).DLGIdentifier("chi2").DLGAnchor("North"))

   dialog_items.DLGAddElement( DLGCreatePushButton( "start a new fit", "GetNew") )

    // allocate and initialize object
   Object DLG_Obj = alloc(fit_handler)
   DLG_Obj.init(dialog)
    // Show the dialog 
    String panelName = "Get distortion & rotation"
    DLG_Obj.Display(panelName);
    
   // run this last, after the UIFrame has been initialized (i.e. displayed), otherwise
   // the DLGGetValue() won't work!

   DLG_Obj.SetUp(img)
}

GetFrontImage()[].CalculateDistortion()

