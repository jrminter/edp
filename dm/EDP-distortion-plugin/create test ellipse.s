// Script to make a test ellipse
//
// Created JRM 2013-05-30
// Based on V. Hou precursor
//
// Modifcation History:
//
//   Date        Who   What...
// -----------   ---   ----------------------------------------------------------
// 
//
// This script is released under the Gnu Public License v.2
// http://www.gnu.org/licenses/old-licenses/gpl-2.0.html

// global variables for persistent values

number g_nImgSize     // image size for the computed image
number g_dCentX       // center location x
number g_dCentY       // center location Y
number g_dRadius      // mean radius of the ellipse
number g_dDelta       // delta radius, major radius = mean + delta, minor radius = mean - delta
number g_dTheta       // C.C.W. rotation of major axis (in degrees) w.r.t. horizontal
number g_dNoise       // noise level ( from 0 to 1.0)
number g_dLineWidth   // ring width as a fraction of image size.
                      // Typically between 0.02 and 0.05

// these are for the dialog box...
number g_nFieldWidth  = 8
number g_nFieldDigits = 2


TagGroup CTE_Dlg, CTE_DlgItems

Taggroup CTE_Label1 = DLGCreateLabel("  Create a test ellipse for distortion analysis  ")

Taggroup CTE_CenterX, CTE_CenterXField
Taggroup CTE_CenterY, CTE_CenterYField
Taggroup CTE_ImgSize, CTE_ImgSizeField
Taggroup CTE_Radius,  CTE_RadiusField
Taggroup CTE_Delta,   CTE_DeltaField
Taggroup CTE_Theta,   CTE_ThetaField
Taggroup CTE_Noise,   CTE_NoiseField
Taggroup CTE_LineWid, CTE_LineWidField

Taggroup CTE_ComputeImageButton

Object   objCalcEllipseWindow

// This bit of code is where buttons and pulldowns generate responses.
class CompEllipTool : uiframe
{
   Image img
   
   void compute_ellipse(object self)
   {
      //this function does the work
      number dMinor      // minor axis length
      number dMajor      // major axis lenth
      number dTheta      // angle in radians
      
      // get values from DLG and save
      g_dCentX = CTE_CenterX.DLGGetValue()
      SetPersistentNumberNote("Ellipse:CenterX", g_dCentX)

      g_dCentY = CTE_CenterY.DLGGetValue()
      SetPersistentNumberNote("Ellipse:CenterY", g_dCentY)
      
      g_nImgSize = CTE_ImgSize.DLGGetValue()
      SetPersistentNumberNote("Ellipse:ImgSize", g_nImgSize)

      g_dRadius = CTE_Radius.DLGGetValue()
      SetPersistentNumberNote("Ellipse:Radius", g_dRadius)

      g_dDelta = CTE_Delta.DLGGetValue()
      SetPersistentNumberNote("Ellipse:Delta", g_dDelta)

      g_dTheta = CTE_Theta.DLGGetValue()
      SetPersistentNumberNote("Ellipse:Theta", g_dTheta)

      g_dNoise = CTE_Noise.DLGGetValue()
      SetPersistentNumberNote("Ellipse:Noise", g_dNoise)

      g_dLineWidth = CTE_LineWid.DLGGetValue()
      SetPersistentNumberNote("Ellipse:LineWidth", g_dLineWidth)
      // do the work
      dMajor = g_dRadius + g_dDelta
      dMinor = g_dRadius - g_dDelta
      
      dTheta = (g_dTheta-90)/180*Pi()
      number cx = cos(dTheta)*g_dCentX + sin(dTheta)*g_dCentY
      number cy = cos(dTheta)*g_dCentY - sin(dTheta)*g_dCentX
      
      img := CreateFloatImage( "ellipse " + dMajor + "-" + dMinor + "-" + g_dTheta, g_nImgSize, g_nImgSize )
      img.ShowImage()
      img.SetSurvey(1)

      img = tert( abs( (( cos(dTheta)*icol + sin(dTheta)*irow - cx)/dMinor)**2 + \
                          ((cos(dTheta)*irow - sin(dTheta)*icol - cy )/dMajor)**2 - 1 ) < g_dLineWidth, \
                          1 - abs( (( cos(dTheta)*icol + sin(dTheta)*irow - cx)/dMinor)**2 + \
                         ((cos(dTheta)*irow - sin(dTheta)*icol - cy )/dMajor)**2 - 1)/g_dLineWidth, \
                          0 ) * 1000

      img += GaussianRandom()*g_dNoise/g_dLineWidth

      /* mark center location
      img[center_y-1, center_x-1, center_y+2, center_x+2] = 100
      img[center_x, center_y] = 0
      */

      img.UpdateImage()
      
      return
   }
}

// Get desired defaults and store in global variables
number bRet

bRet = GetPersistentNumberNote("Ellipse:ImgSize", g_nImgSize)
if (bRet < 1)
{
   g_nImgSize = 1024
   SetPersistentNumberNote("Ellipse:ImgSize", g_nImgSize)
}

bRet = GetPersistentNumberNote("Ellipse:CenterX", g_dCentX)
if (bRet < 1)
{
   g_dCentX = g_nImgSize/2
   SetPersistentNumberNote("Ellipse:CenterX", g_dCentX)
}

bRet = GetPersistentNumberNote("Ellipse:CenterY", g_dCentY)
if (bRet < 1)
{
   g_dCentY = g_nImgSize/2
   SetPersistentNumberNote("Ellipse:CenterY", g_dCentY)
}

bRet = GetPersistentNumberNote("Ellipse:Radius", g_dRadius)
if (bRet < 1)
{
   g_dRadius = 300.0
   SetPersistentNumberNote("Ellipse:Radius", g_dRadius)
}

bRet = GetPersistentNumberNote("Ellipse:Delta", g_dDelta)
if (bRet < 1)
{
   g_dDelta = 30.0
   SetPersistentNumberNote("Ellipse:Delta", g_dDelta)
}

bRet = GetPersistentNumberNote("Ellipse:Theta", g_dTheta)
if (bRet < 1)
{
   g_dTheta = 65.0
   SetPersistentNumberNote("Ellipse:Theta", g_dTheta)
}

bRet = GetPersistentNumberNote("Ellipse:Noise", g_dNoise)
if (bRet < 1)
{
   g_dNoise = 1.0
   SetPersistentNumberNote("Ellipse:Noise", g_dNoise)
}

bRet = GetPersistentNumberNote("Ellipse:LineWidth", g_dLineWidth)
if (bRet < 1)
{
   g_dLineWidth = 0.02
   SetPersistentNumberNote("Ellipse:LineWidth", g_dLineWidth)
}


// be sure we have a results window open...
OpenResultsWindow()


// Create Dialog
CTE_Dlg = DLGCreateDialog( "CompEllipTool",  CTE_DlgItems )

// create fields
CTE_ImgSizeField  = DLGCreateIntegerField("    Image Size: ", CTE_ImgSize, g_nImgSize, \
                                          g_nFieldWidth)
CTE_CenterXField  = DLGCreateRealField   ("      Center X: ", CTE_CenterX, g_dCentX, \
                                          g_nFieldWidth, g_nFieldDigits)
CTE_CenterYField  = DLGCreateRealField   ("      Center X: ", CTE_CenterY, g_dCentY, \
                                          g_nFieldWidth, g_nFieldDigits)
CTE_RadiusField   = DLGCreateRealField   ("Ellipse Radius: ", CTE_Radius,  g_dRadius, \
                                           g_nFieldWidth, g_nFieldDigits)
CTE_DeltaField    = DLGCreateRealField   ("  Delta Radius: ", CTE_Delta,   g_dDelta, \
                                          g_nFieldWidth, g_nFieldDigits)
CTE_ThetaField    = DLGCreateRealField   ("   Theta [deg]: ", CTE_Theta,   g_dTheta, \
                                           g_nFieldWidth, g_nFieldDigits)
CTE_NoiseField    = DLGCreateRealField   ("         Noise: ", CTE_Noise,   g_dNoise, \
                                          g_nFieldWidth, g_nFieldDigits)
CTE_LineWidField  = DLGCreateRealField   ("    Line Width: ", CTE_LineWid, g_dLineWidth, \
                                          g_nFieldWidth,g_nFieldDigits)

// create button
CTE_ComputeImageButton = DLGCreatePushButton("  Compute ellipse ", "compute_ellipse")

// Add items to dialog & define the layout (1 column, 14 rows)
CTE_Dlg.DLGAddElement(CTE_Label1)
CTE_Dlg.DLGAddElement(CTE_ImgSizeField)
CTE_Dlg.DLGAddElement(CTE_CenterXField)
CTE_Dlg.DLGAddElement(CTE_CenterYField)
CTE_Dlg.DLGAddElement(CTE_RadiusField)
CTE_Dlg.DLGAddElement(CTE_DeltaField)
CTE_Dlg.DLGAddElement(CTE_ThetaField)
CTE_Dlg.DLGAddElement(CTE_NoiseField)
CTE_Dlg.DLGAddElement(CTE_LineWidField)
CTE_Dlg.DLGAddElement(CTE_ComputeImageButton)

CTE_Dlg.DLGTableLayout(1, 10, 0)

objCalcEllipseWindow = alloc( CompEllipTool).Init(CTE_Dlg)
objCalcEllipseWindow.Display("Compute Test Ellipse")
