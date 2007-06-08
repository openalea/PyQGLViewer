# PyQt4 NSIS installer script.
#
# Copyright (c) 2006
# 	Riverbank Computing Limited <info@riverbankcomputing.co.uk>
# 
# This file is part of PyQt.
# 
# This copy of PyQt is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2, or (at your option) any later
# version.
# 
# PyQt is supplied in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
# 
# You should have received a copy of the GNU General Public License along with
# PyQt; see the file LICENSE.  If not, write to the Free Software Foundation,
# Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.


# These will change with different releases.
!define PYQGLVIEWER_VERSION        "0.1.0"
!define PYQGLVIEWER_LICENSE        "GPL"
!define PYQGLVIEWER_LICENSE_LC     "gpl"
!define PYQGLVIEWER_PYTHON_MINOR   "4"
!define PYQGLVIEWER_QT_VERS        "4.2.2"
!define PYQGLVIEWER_QGLVIEWER_VERS "2.5.1-c"
!define PYQGLVIEWER_COMPILER       "MinGW"

# These are all derived from the above.
!define PYQGLVIEWER_NAME           "PyQGLViewer ${PYQGLVIEWER_LICENSE} v${PYQGLVIEWER_VERSION}"
!define PYQGLVIEWER_INSTALLDIR     "C:\Python2${PYQGLVIEWER_PYTHON_MINOR}\"
!define PYQGLVIEWER_PYTHON_VERS    "2.${PYQGLVIEWER_PYTHON_MINOR}"
!define PYQGLVIEWER_PYTHON_HKLM    "Software\Python\PythonCore\${PYQGLVIEWER_PYTHON_VERS}\InstallPath"
!define PYQGLVIEWER_QT_HKLM        "Software\OpenAlea\Versions\${PYQGLVIEWER_QT_VERS}"


# Tweak some of the standard pages.
!define MUI_WELCOMEPAGE_TEXT \
"This wizard will guide you through the installation of ${PYQGLVIEWER_NAME}.\r\n\
\r\n\
This copy of PyQGLViewer has been built with the ${PYQGLVIEWER_COMPILER} compiler against \
Python v${PYQGLVIEWER_PYTHON_VERS}.x, Qt v${PYQGLVIEWER_QT_VERS} and libQGLViewer v${PYQGLVIEWER_QGLVIEWER_VERS}.\r\n\
\r\n\
Any code you write must be released under a license that is compatible with \
the GPL.\r\n\
\r\n\
Click Next to continue."

!define MUI_FINISHPAGE_LINK "Get the latest news of PyQGLViewer here"
!define MUI_FINISHPAGE_LINK_LOCATION "http://pyqglviewer.gforge.inria.fr/"


# Include the tools we use.
!include MUI.nsh
!include LogicLib.nsh


# Define the product name and installer executable.
Name "PyQGLViewer"
Caption "${PYQGLVIEWER_NAME} Setup"
OutFile "PyQGLViewer-${PYQGLVIEWER_VERSION}-Py2.${PYQGLVIEWER_PYTHON_MINOR}-Qt${PYQGLVIEWER_QT_VERS}-QGL${PYQGLVIEWER_QGLVIEWER_VERS}.exe"


# Set the install directory, from the registry if possible.
InstallDir "${PYQGLVIEWER_INSTALLDIR}"
InstallDirRegKey HKLM "${PYQGLVIEWER_PYTHON_HKLM}" ""


# The different installation types.  "Full" is everything.  "Minimal" is the
# runtime environment.
InstType "Full"
InstType "Minimal"


# Maximum compression.
SetCompressor /SOLID lzma


# We want the user to confirm they want to cancel.
!define MUI_ABORTWARNING


Function .onInit
    # Check the right version of Python has been installed.
    ReadRegStr $0 HKLM "${PYQGLVIEWER_PYTHON_HKLM}" ""

    ${If} $0 == ""
        MessageBox MB_YESNO|MB_ICONQUESTION \
"This copy of PyQGLViewer has been built against Python v${PYQGLVIEWER_PYTHON_VERS}.x which \
doesn't seem to be installed.$\r$\n\
$\r$\n\
Do you with to continue with the installation?" IDYES GotPython
            Abort
GotPython:
    ${Endif}
FunctionEnd


# Define the different pages.
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
  
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

  
# Other settings.
!insertmacro MUI_LANGUAGE "English"


# Installer sections.

Section "Extension modules" SecModules
    SectionIn 1 2 RO

    # Make sure this is clean and tidy.
    RMDir /r $PROGRAMFILES\PyQGLViewer
    CreateDirectory $PROGRAMFILES\PyQGLViewer

    SetOverwrite on

    # We have to take the SIP files from where they should have been installed.
    SetOutPath $INSTDIR\Lib\site-packages
    File .\build\PyQGLViewer.pyd
    File .\QGLViewer2.dll
SectionEnd

Section "Developer tools" SecTools
    SectionIn 1

    SetOverwrite on

    SetOutPath $INSTDIR\sip\QGLViewer
    File .\src\sip\vec.sip
    File .\src\sip\quaternion.sip
    File .\src\sip\frame.sip
    File .\src\sip\constraint.sip
    File .\src\sip\keyFrameInterpolator.sip
    File .\src\sip\mouseGrabber.sip
    File .\src\sip\manipulatedFrame.sip
    File .\src\sip\manipulatedCameraFrame.sip
    File .\src\sip\camera.sip
    File .\src\sip\qglviewer.sip
    File .\src\sip\domUtils.sip

SectionEnd

Section "Documentation" SecDocumentation
    SectionIn 1

    SetOverwrite on

    SetOutPath $PROGRAMFILES\PyQGLViewer
    File /r .\doc
SectionEnd

Section "Examples and tutorial" SecExamples
    SectionIn 1

    SetOverwrite on

    SetOutPath $PROGRAMFILES\PyQGLViewer
    File /r .\examples
SectionEnd

Section "Start Menu shortcuts" SecShortcuts
    SectionIn 1

    # Make sure this is clean and tidy.
    RMDir /r "$SMPROGRAMS\${PYQGLVIEWER_NAME}"
    CreateDirectory "$SMPROGRAMS\${PYQGLVIEWER_NAME}"

    IfFileExists "$PROGRAMFILES\PyQGLViewer\doc" 0 +3
        CreateShortCut "$SMPROGRAMS\${PYQGLVIEWER_NAME}\Web Site.lnk" "http://pyqglviewer.gforge.inria.fr/"

    IfFileExists "$PROGRAMFILES\PyQGLViewer\examples" 0 +5
	SetOutPath $PROGRAMFILES\PyQt4\examples
        CreateShortCut "$SMPROGRAMS\${PYQGLVIEWER_NAME}\Examples Source.lnk" "$PROGRAMFILES\PyQGLViewer\examples"

    CreateShortCut "$SMPROGRAMS\${PYQGLVIEWER_NAME}\Uninstall PyQGLViewer.lnk" "$PROGRAMFILES\PyQtGLViewer\Uninstall.exe"
SectionEnd

Section -post
    # Tell Windows about the package.
    WriteRegExpandStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PyQtGLViewer" "UninstallString" '"$PROGRAMFILES\PyQGLViewer\Uninstall.exe"'
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PyQtGLViewer" "DisplayName" "${PYQGLVIEWER_NAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PyQtGLViewer" "DisplayVersion" "${PYQGLVIEWER_VERSION}"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PyQtGLViewer" "NoModify" "1"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PyQtGLViewer" "NoRepair" "1"

    # Save the installation directory for the uninstaller.
    WriteRegStr HKLM "Software\PyQtGLViewer" "" $INSTDIR

    # Create the uninstaller.
    WriteUninstaller "$PROGRAMFILES\PyQtGLViewer\Uninstall.exe"
SectionEnd


# Section description text.
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${SecDocumentation} \
"The PyQGLViewer documentation."
!insertmacro MUI_DESCRIPTION_TEXT ${SecExamples} \
"Ports to Python of the standard QGLViewer examples and tutorial."
!insertmacro MUI_DESCRIPTION_TEXT ${SecShortcuts} \
"This adds shortcuts to your Start Menu."
!insertmacro MUI_FUNCTION_DESCRIPTION_END


Section "Uninstall"
    # Get the install directory.
    ReadRegStr $INSTDIR HKLM "Software\PyQGLViewer" ""

    # The modules section.
    Delete $INSTDIR\Lib\site-packages\sip.pyd
    Delete  $INSTDIR\Lib\site-packages\PyQGLViewer.pyd

    # The shortcuts section.
    RMDir /r "$SMPROGRAMS\${PYQGLVIEWER_NAME}"


    # The examples section and the installer itself.
    RMDir /r "$PROGRAMFILES\PyQGLViewer"

    # Clean the registry.
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PyQGLViewer"
    DeleteRegKey HKLM "Software\PyQGLViewer"
SectionEnd