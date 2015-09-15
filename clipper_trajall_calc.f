c     clipper_trajall_calc.f :
c     Reads Europa Clipper proposed trajectory data from SPICE files, extracts
c     data at +/-30min from closest approach of each of the 45 flybys, and saves
c     into binary format that's readable in Matlab.  Creates binary data files
c     clipper_traj_data/clipper.orbNN.traj.dat for each orbit NN to be read
c     into Matlab for further analysis.
c
c     Andrew A. Ganse, APL-UW (Applied Physics Lab, Univ of Washington), 2008-2014
c     aganse@apl.washington.edu
c     Written with technical assistance from Chuck Acton, NASA NAIF, 2008.
c
c     Uses NASA NAIF spice toolkit available at:
c     http://naif.jpl.nasa.gov/naif/toolkit.html  (last access 1 Dec 2014)
c
c     Uses publicly available proposed Europa Clipper trajectory data available at:
c     https://solarsystem.nasa.gov/europa/iceedocs.cfm  (last access 1 Dec 2014)
c
c     Simply run as:
c     > clipper_trajall_calc
c     Run time < 4sec on late 2011 MacBook Pro, 2.4GHz Intel Core i5, 8GB RAM.
c
c     Code requires -ffixed-line-length-0 compile option, ie no line length limit.
c     I.e. compile via:
c     g77 -ffixed-line-length-0 -o clipper_trajall_calc clipper_trajall_calc.f  \
c                                                     $(toolkitdir)/spicelib.a
c
c     Covers data of proposed Clipper mission (from ICEE_Spice_readme.txt file) :
c        Object:  -650000
c          Interval Begin ET        Interval End ET          AV
c          ------------------------ ------------------------ ---
c          2029-MAR-25 16:44:49.401 2031-OCT-31 03:48:41.184 Y


      program clippertrajall
      implicit none
      integer i, l, N
      parameter (N=8.2033431e6)  ! N=num trajectory pts (at 1pt per 10secs)
      double precision tdbstart,tdbCA,tdb,LT
      character orbstring*2, datadir*18  ! datadir dim must match string set below
      character*20 timestamps(45)
      double precision moon2spcrftxyz(3), moon2spcrftsph(N,3)
      double precision dt
      parameter (dt=2.0)   ! seconds : time increment in trajectory
      
c     Load spice kernel files for geometry & ephemeris calculations:  
      call furnsh ('SPICE_ephem/Clipper.mk')


c     Get TDB time of data start in TDB units (sec):
c     note timestamp = "interval begin" of Clipper mission, see above...
      call str2et ('2029-03-25T16:44:49.401', tdbstart)
c        str2et(): "This routine computes the ephemeris epoch corresponding
c        to an input string.  The ephemeris epoch is represented as seconds
c        past the J2000 epoch in the time system known as Barycentric
c        Dynamical Time (TDB).  This time system is also referred to as
c        Ephemeris Time (ET) throughout the SPICE Toolkit."  (str2et.html)

      
      do i=1,N   ! increment times from tdbstart

         tdb=tdbstart+dble(i)*10.0  ! only taking every 10th second yet still a
                                    ! ton of data in result - change with care!
                                    ! note if 10.0 is changed, must also change N.

c        Retrieve moon to spacecraft position vector, in the moon's IAU-defined
c        body-fixed frame.  (Note instead of 'NONE' may want 'LT+S' to use light
c        time & stellar abberation.  See doc for SPKPOS subroutine.)
         call spkpos ('Clipper', tdb, 'IAU_EUROPA', 'NONE', 'EUROPA', moon2spcrftxyz, LT )         
         moon2spcrftxyz(1)=moon2spcrftxyz(1)*1000.0;  ! convert km to m
         moon2spcrftxyz(2)=moon2spcrftxyz(2)*1000.0;  ! convert km to m
         moon2spcrftxyz(3)=moon2spcrftxyz(3)*1000.0;  ! convert km to m      
         call reclat ( moon2spcrftxyz, moon2spcrftsph(i,3), moon2spcrftsph(i,1), moon2spcrftsph(i,2) )
         call convrt ( moon2spcrftsph(i,1), 'RADIANS', 'DEGREES', moon2spcrftsph(i,1) )  ! lon
         call convrt ( moon2spcrftsph(i,2), 'RADIANS', 'DEGREES', moon2spcrftsph(i,2) )  ! lat

c        Print progress info at ~10% intervals in loop:
         if (mod(i,nint(N/10.0)).lt.1) then
            print '(F4.0,A)', dble(i)/dble(N)*100.0, '%'
         endif

      enddo  ! end of i loop over time points within an orbit/flyby


c     Write data to binary files:  file will have a 4-byte header before number
c     of bytes as 8*size(matrix) :  that header is a 4-byte integer containing
c     number of bytes to read.  (And actually there's a similar 4-byte block at
c     end of file as well.)
      datadir='clipper_traj_data/'
      open(11, file=datadir//'clipper.trajall.dat', form='unformatted')
      write (11) moon2spcrftsph  ! Nx3, where N=#times and 3 is long/lat/radius


      END    ! end of program
