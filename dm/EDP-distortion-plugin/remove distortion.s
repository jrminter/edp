/***********************************************************************
  3456789012345678901234567890123456789012345678901234567890123456789012   

UndistortEDP.s

Script to undistort the EDP in the front image.

Uses the approach suggested by Capitani et al. in Ultramicroscopy 106
(2006) on p. 72:
   Finally, once the distortions have been quantitatively determined, they should
   be compensated for. We did this in the following way. Each image is first rotated
   in order to bring the distortion axis of maximal elongation on the horizontal
   x-axis. Then the image or ED pattern is stretched along the vertical direction
   by the calculated maximal distortion value (or compressed by the same value along
   the horizontal direction). Finally, the scale factor for the stretched image must
   be multiplied by the amplitude of maximal distortion before performing further
   calculations with the image
   
This implementation shrinks the x-axis by (1-dR/R) and stretches the Y axis by
a factor of (1-dR/R). This seems to match what Labar did in ProcessDiffraction.

Created JRM 15-Dec-2012

Modifcation History:

Date        Who   What...
-----------   ---   ----------------------------------------------------------
15-Dec-2012   JRM   Initial Version

This script is released under the Gnu Public License v.2
http://www.gnu.org/licenses/old-licenses/gpl-2.0.html

***********************************************************************/

TagGroup UDEDP_Dlg, UDEDP_DlgItems

Taggroup UDEDP_Label1 = DLGCreateLabel( "     Undistort EDP                ")
Taggroup UDEDP_Label2 = DLGCreateLabel( " V1.0 (c) J. Minter under GPL 2.0 ")

Taggroup UDEDP_MaxRadius, UDEDP_MaxRadiusField

Taggroup UDEDP_VerboseBox;

Taggroup UDEDP_UndistortButton
Object   UndistortWindow

// global variables for persistent values
number g_nMaxRadius, g_bVerbose

// This bit of code is where buttons and pulldowns generate responses.
class PrepUndistort : uiframe
{
   void undistort_edp(object self)
   {
      // get values from DLG and save
      g_nMaxRadius = UDEDP_MaxRadius.DLGGetValue()
      SetPersistentNumberNote("Distort:MaxRad", g_nMaxRadius)
      
      g_bVerbose = UDEDP_VerboseBox.DLGGetValue()
      SetPersistentNumberNote("Distort:Verbose", g_bVerbose)

      
      // local variables
        
      component imgDisp
      image frontImg, cropImg, rotImg, warpImg, dstImg, lineProj
      number bRet, cX, cY, Rad, dRad, rotDeg
      number sizeX, sizeY, t, b, l, r, nRoi, i
      number warpFacX, warpFacY, warpImgSizeX, warpImgSizeY
      number samples, xscale, yscale, halfMinor, k
      ROI theROI
      string imgName, strOutFile
      
      // recall the results from the last run of undistort...
      bRet = GetPersistentNumberNote("Distort:CenterX", cX)
      bRet = GetPersistentNumberNote("Distort:CenterY", cY)
      bRet = GetPersistentNumberNote("Distort:MeanRad", Rad);
      bRet = GetPersistentNumberNote("Distort:DeltRad", dRad);
      bRet = GetPersistentNumberNote("Distort:AnglDeg", rotDeg);  
      
      // do the work
      
      frontImg := GetFrontImage()
      imgDisp=imagegetimagedisplay(frontImg, 0)
      
      // ROIs cause a problem later, delete them now...
      nRoi = imgdisp.ImageDisplayCountROIs()
      if(g_bVerbose > 0 )
      {
         Result("Removing " + nRoi + " ROIs from the image...\n")
      }
      for(i=0; i<nRoi; i++)
      {
         theROI= imgDisp.ImageDisplayGetROI(i)
         imgDisp.ImageDisplayDeleteROI(theROI) 
      }
      imgName = frontImg.GetName()
      ConvertToFloat(frontImg)
      frontImg.ShowImage()
      
      // define the ROI
      t=cY-g_nMaxRadius
      b=cY+g_nMaxRadius
      l=cX-g_nMaxRadius
      r=cX+g_nMaxRadius
        
      setselection(frontImg, t,l,b,r)
      cropImg=frontImg[]
      SetName(cropImg, "crop")
      cropImg.ShowImage()
        
      // Rotate( BasicImage source, Number radians )
      rotImg = rotate(cropImg, rotDeg*pi()/180)
      SetName(rotImg, "rot")
      rotImg.ShowImage()
      cropImg.DeleteImage()
        
      GetSize(rotImg, sizeX, sizeY)
      warpFacX = (1-dRad/Rad)
      warpFacY = (1+dRad/Rad)
      
      warpImgSizeX = sizeX*warpFacX
      warpImgSizeY = sizeY*warpFacY
      
      if(g_bVerbose > 0 )
      {
         Result("Warp image is " + warpImgSizeX + "x" +  warpImgSizeY + "\n")
      }
      
      warpImg:= CreateFloatImage("warp", warpImgSizeX, warpImgSizeY)
      warpImg.ShowImage()
      warpImg = warp(rotImg, icol/warpFacX, irow/warpFacY)
      SetName(warpImg, "warp")
      warpImg.ShowImage()
      rotImg.DeleteImage()
      
      GetSize(warpImg, sizeX, sizeY)
      // define the ROI
      cX = sizeX/2
      cY = sizeY/2
      t=cY-g_nMaxRadius
      b=cY+g_nMaxRadius
      l=cX-g_nMaxRadius
      r=cX+g_nMaxRadius
      setselection(warpImg, t,l,b,r)
      cropImg=warpImg[]
      SetName(cropImg, imgName+"-dc")
      cropImg.ShowImage()
      warpImg.DeleteImage()
      
      // now do a rotational average
      samples = 360
      GetSize(cropImg, sizeX, sizeY)
      cX = sizeX/2
      cY = sizeY/2
      halfMinor = min(sizeX, sizeY)/2
      dstImg := CreateFloatImage( "dst", halfMinor, samples)
      k = 2 * pi() / samples
      dstImg = warp( cropImg, icol*sin(irow*k) + cX, icol*cos(irow*k) + cY)
      lineProj := CreateFloatImage(imgName+"-dc-ra", halfMinor, 1)
      lineProj = 0
      lineProj[icol,0] += dstImg
      lineProj /= samples
      
      strOutFile = imgName + "-dc-ra.csv"
      if(SaveAsDialog( "Save Profile", strOutFile, strOutFile ))
      {
         number nFile = CreateFileForWriting(strOutFile )
         number i, dInt
         WriteFile( nFile, 0, "r.px, i\n" );
         for( i = 0; i < halfMinor; ++i )
         {
            dInt = GetPixel(lineProj,i,0);
            WriteFile( nFile, 0, i + "," + dInt + "\n" );
         }
         CloseFile( nFile )
        }
        // clean up
        dstImg.DeleteImage()
        lineProj.ShowImage()       
   } 
}

// Get desired defaults and store in global variables
number bRet
bRet = GetPersistentNumberNote("Distort:MaxRad", g_nMaxRadius)
if (bRet < 1)
{
   g_nMaxRadius = 900
   SetPersistentNumberNote("Distort:MaxRad", g_nMaxRadius)
}
bRet = GetPersistentNumberNote("Distort:Verbose", g_bVerbose);
if (bRet < 1)
{
   g_bVerbose = 1;
   SetPersistentNumberNote("Distort:Verbose", g_bVerbose);
}

// be sure we have a results window open...
OpenResultsWindow()


// Create Dialog
UDEDP_Dlg = DLGCreateDialog( "EdpUndistort",  UDEDP_DlgItems )

// create fields
UDEDP_MaxRadiusField   = DLGCreateIntegerField("Max radius: ", UDEDP_MaxRadius, g_nMaxRadius, 10)

// create boxes
UDEDP_VerboseBox       = DLGCreateCheckBox("Verbose", g_bVerbose);

// create button
UDEDP_UndistortButton = DLGCreatePushButton("Undistort Front EDP  ", "undistort_edp")

// Add items to dialog & define the layout (1 column, 5 rows)
UDEDP_Dlg.DLGAddElement(UDEDP_Label1)
UDEDP_Dlg.DLGAddElement(UDEDP_Label2)
UDEDP_Dlg.DLGAddElement(UDEDP_MaxRadiusField)
UDEDP_Dlg.DLGAddElement(UDEDP_UndistortButton)
UDEDP_Dlg.DLGAddElement(UDEDP_VerboseBox);

UDEDP_Dlg.DLGTableLayout(1,5,0)

UndistortWindow = alloc(PrepUndistort).Init(UDEDP_Dlg)
UndistortWindow.Display("Undistort EDP Tool")

