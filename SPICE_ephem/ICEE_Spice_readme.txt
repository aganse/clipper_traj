Jan. 17, 2014
Steven Wissler

This tar file was created to hold the NAIF/Spice files made for use by the
Instrument Concepts for Europa Exploration (ICEE) solicitation activity.  The files include

Trajectory kernel, from Brent Buffington

13-F7_extension_scpse.bsp

Summary for: 13-F7_extension_scpse.bsp
 
Bodies: -650                    NEPTUNE BARYCENTER (8)  EUROPA (502)
        MERCURY BARYCENTER (1)  PLUTO BARYCENTER (9)    GANYMEDE (503)
        VENUS BARYCENTER (2)    SUN (10)                CALLISTO (504)
        EARTH BARYCENTER (3)    MERCURY (199)           AMALTHEA (505)
        MARS BARYCENTER (4)     VENUS (299)             THEBE (514)
        JUPITER BARYCENTER (5)  MOON (301)              JUPITER (599)
        SATURN BARYCENTER (6)   EARTH (399)
        URANUS BARYCENTER (7)   IO (501)
        Start of Interval (ET)              End of Interval (ET)
        -----------------------------       -----------------------------
        2028 MAR 15 13:35:00.000            2031 NOV 01 12:00:00.000

Attitude kernel:

europa_pred_EuropaOPSModel_Science_C.bc

Contains Nadir pointed flybys of Europa, All OTM's with proper directions for deterministic delta-v's, and targeted calibrations. Optical instruments use the Pleiades ( M45 ) J2000 RA = 3h 47m 24s, Dec = +24d 7m. To see events in C-Kernel, use the spice utility program commnt. 

Summary for: europa_pred_EuropaOPSModel_Science_C.bc
 
Object:  -650000
  Interval Begin ET        Interval End ET          AV
  ------------------------ ------------------------ ---
  2029-MAR-25 16:44:49.401 2031-OCT-31 03:48:41.184 Y

Supporting kernels:

Clipper.mk : meta-kernel, can be used to load the kernels as a package
Clipper.tf : frame kernel 
ClipperBODYKernel.txt : text kernel tying the spacecraft id ( -650 ) to the name "Clipper"
Clipper_SCLKSCET.00001.tsc : spacecraft clock kernel used to translate the time system in the c-kernel to ET
naif0010.tls : Leap-secomd kernel
pck00010.tpc : planetary constants kernel

