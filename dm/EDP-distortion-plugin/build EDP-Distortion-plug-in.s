/***********************************************************************
  3456789012345678901234567890123456789012345678901234567890123456789012
  
  Original package by Vincent Hou. Revised and extended for GMS 2 by
  J. R. Minter. Renamed from Diffraction ring Distortion Analysis to
  to EDP-Distortion and put in its own EDP menu for easier use.
  
  Created JRM 2012-12-15

  Modifcation History:

    Date        Who   What...
  -----------   ---   --------------------------------------------------
  2012-12-15    JRM   Initial port to GMS 2 and added a remove distortion
                      component.
  2013-05-29    JRM   Some cleanup prior to github
  
  2013-05-30    JRM   refactored the create test ellipse script to 
                      get the dialog to work properly under GMS 2.1.
                      Not pretty, but it works... 
 
  This script is released under the Gnu Public License v.2
  http://www.gnu.org/licenses/old-licenses/gpl-2.0.html
  
  
***********************************************************************/

void InstallationLog( String Package, String ScriptFile )
{
   Result( "\n" + "Package [" + package + "], script file [" + scriptfile + "] installed" )
   return
}

String scriptFile, pkgName, cmd, menu, submenu
Number level, IsLibrary
Number key
pkgName   = "EDP-Distortion"

// Get the directory of scripts to be installed

String ParentPath, Path
If( !SaveAsDialog("", "Go in the directory and click save", ParentPath) )
{
   ParentPath = ParentPath.PathExtractDirectory(0)
}
else
{
   ParentPath = GetSpecialDirectory(2)
}


// Install functions

Path        = ParentPath  // sub-directory-name + chr(92)
level       = 3
IsLibrary   = 1
menu        = ""
submenu     = ""
scriptFile  = "Distortion_Analysis_Lib.s"   
cmd         = "Distortion_Analysis_Lib"

AddScriptFileToPackage( path+ScriptFile, pkgName, level, cmd, menu, submenu, IsLibrary)
InstallationLog( pkgName, scriptFile )


// Install scripts

Path      = ParentPath                      // sub-directory-name + chr(92)
level     = 3
IsLibrary = 0
menu      = "EDP"
submenu   = ""

scriptFile = "find center.s"   
cmd        = "find center ... "
AddScriptFileToPackage( path+ScriptFile, pkgName, level, cmd, menu, submenu, IsLibrary)
InstallationLog( pkgName, scriptFile )

scriptFile = "calculate distortion.s"   
cmd        = "calculate distortion ... "
AddScriptFileToPackage( path+ScriptFile, pkgName, level, cmd, menu, submenu, IsLibrary)
InstallationLog( pkgName, scriptFile )

scriptFile = "remove distortion.s"   
cmd        = "remove distortion .... "
AddScriptFileToPackage( path+ScriptFile, pkgName, level, cmd, menu, submenu, IsLibrary)
InstallationLog( pkgName, scriptFile )

AddScriptToPackage("Beep()",pkgName,level, "-", menu, submenu, IsLibrary)      // --------- divider

scriptFile = "rotation shift.s"   
cmd        = "rotation shift ..."
AddScriptFileToPackage( path+ScriptFile, pkgName, level, cmd, menu, submenu, IsLibrary)
InstallationLog( pkgName, scriptFile )

scriptFile = "create test ellipse.s"   
cmd        = "create test ellipse ... "
AddScriptFileToPackage( path+ScriptFile, pkgName, level, cmd, menu, submenu, IsLibrary)
InstallationLog( pkgName, scriptFile )

scriptFile = "Diff Pattern Acqusition.s"   
cmd        = "diffraction pattern acqusition"
AddScriptFileToPackage( path+ScriptFile, pkgName, level, cmd, menu, submenu, IsLibrary)
InstallationLog( pkgName, scriptFile )

//      AddScriptToPackage("Beep()",pkgName,level, "--", menu, "", IsLibrary)      // --------- divider

