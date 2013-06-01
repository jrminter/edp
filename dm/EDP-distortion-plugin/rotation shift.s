class shift_handler : UIFrame
{
	Number shift, angle, a_scale, a_origin, a_calformat
	String a_units
	Number width, height
	Image srcImg, buffer

	void changed( object self, tagGroup tgs )
	{
		self.DLGGetValue("angle", angle)
		angle = mod( angle, width*a_scale)
		self.DLGValue("angle", angle)

		srcImg.ImageSetDimensionOrigin( 0, angle+a_origin)		// reset origin of source image
		
		shift = angle/a_scale
		If( shift < 0 ) shift = width - abs( mod(shift, width) )
		srcImg = warp( buffer, mod( icol+shift, width ), irow)
		return
	}

	void setup( object self, image &img )
	{
		srcImg := img
		buffer := img.ImageClone()
		srcimg.GetSize(width, height)

		// Get spatial/angular (dimension 0) calibration of source image
		srcImg.ImageGetDimensionCalibration(0, a_origin, a_scale, a_units, a_calFormat )

		TagGroup tgs = self.LookUpElement("angle")
		self.changed(tgs)

		return
	}

	void GetNew( object self )
	{
		buffer.DeleteImage()

		Image img := GetFrontImage()
		self.SetUp( img )
		return
	}

	void s_down( object self )
	{
		self.DLGGetValue("shift", shift)
		If (ShiftDown()) angle-= 10
		else angle -=1
		self.DLGValue("angle", angle)
		return
	}

	void s_up( object self )
	{
		If (ShiftDown()) angle += 10
		else angle += 1
		self.DLGValue("angle", angle)
		return
	}
}

	//	Construct the basic dialog tag
	TagGroup dialog_items
	TagGroup dialog = DLGCreateDialog( "rotation shift", dialog_items )

	//	Build the positioning from application window
	TagGroup position = DLGBuildPositionFromApplication()

	//  Set width and position of floating palette
	position.TagGroupSetTagAsString( "Width",  "Medium")
	position.TagGroupSetTagAsString( "Side", "Top" )
	dialog.TagGroupSetTagAsTagGroup( "Positioning", position )

	TagGroup tgBoxItems1
	dialog_items.DLGAddElement( DLGGroupItems( \
									DLGCreateLabel( "shift angle = " ).DLGSide("Left"),\
									DLGCreatePushButton( "<", "s_down").DLGSide("Left"),\
									DLGCreateRealField( 0, 7, 5, "changed").DLGIdentifier("angle").DLGSide("Left"),\
									DLGCreatePushButton( ">", "s_up")) )

	dialog_items.DLGAddElement( DLGCreatePushButton( "work on a new image", "GetNew") )

	Object DLG_Obj = alloc(shift_handler)
	DLG_Obj.init(dialog)

	String panelName = "shift rotation"
    // Show the dialog 
    DLG_Obj.Display(panelName);

	// run this last, after the UIFrame has been initialized (i.e. displayed), otherwise
	// the DLGGetValue() won't work!

	Image img := GetFrontImage()
	DLG_Obj.SetUp(img)