c     clipper_trajorbs_calc.f :
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
c     Also uses other generic SPICE kernels 
c     http://naif.jpl.nasa.gov/naif/data_generic.html
c
c     Simply run as:
c     > clipper_trajorbs_calc
c     Run time < 4sec on late 2011 MacBook Pro, 2.4GHz Intel Core i5, 8GB RAM.
c
c     Code requires -ffixed-line-length-0 compile option, ie no line length limit.
c     I.e. compile via:
c     g77 -ffixed-line-length-0 -o clipper_trajorbs_calc clipper_trajorbs_calc.f  \
c                                                     $(toolkitdir)/spicelib.a
c
c     Covers data of proposed Clipper mission (from ICEE_Spice_readme.txt file) :
c        Object:  -650000
c          Interval Begin ET        Interval End ET          AV
c          ------------------------ ------------------------ ---
c          2029-MAR-25 16:44:49.401 2031-OCT-31 03:48:41.184 Y


      program clippertrajorbs
      implicit none
      integer i, l, N
      parameter (N=1801)  ! N=num trajectory pts
      double precision tdbCA,tdb,LT
      character orbstring*2, datadir*18  ! datadir dim must match string set below
      character*20 timestamps(45)
      double precision moon2spcrftxyz(3), moon2spcrftsph(N,3)
      double precision dt
      parameter (dt=2.0)   ! seconds : time increment in trajectory
      
c     Load spice kernel files for geometry & ephemeris calculations:  
      call furnsh ('SPICE_ephem/Clipper.mk')

c     Populate list of times of closet approach for 45 proposed Clipper flybys
      call populateTimestampArray(timestamps)
      
      print *, 'Starting loop over orbits...'

      do l=1,45  ! list in timestampCA contains times for 45 orbits/flybys
      print *, ' orbit ',l,':  ',timestamps(l)

c     Get TDB time of data start in TDB units (sec):
      call str2et (timestamps(l), tdbCA)
c        str2et(): "This routine computes the ephemeris epoch corresponding
c        to an input string.  The ephemeris epoch is represented as seconds
c        past the J2000 epoch in the time system known as Barycentric
c        Dynamical Time (TDB).  This time system is also referred to as
c        Ephemeris Time (ET) throughout the SPICE Toolkit."  (str2et.html)

      
      print *, '  Starting subloop over UTCtime points within this orbit...'
      do i=1,N   ! increment times across tdbCA

         tdb=tdbCA-1800.0+dble(i)*dt ! increment time from tdbCA-30min to
                                     ! tdbCA+30min (well, 30min when dt=2.0
                                     ! and N=1801...)

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

      enddo  ! end of i loop over time points within an orbit/flyby


c     Write data to binary files:  file will have a 4-byte header before number
c     of bytes as 8*size(matrix) :  that header is a 4-byte integer containing
c     number of bytes to read.  (And actually there's a similar 4-byte block at
c     end of file as well.)
      write(unit=orbstring, fmt='(I0.2)') l
      datadir='clipper_traj_data/'
      open(11, file=datadir//'clipper.orb'//orbstring//'.traj.dat',
     +                                                form='unformatted')
      write (11) moon2spcrftsph  ! Nx3, where N=#times and 3 is long/lat/radius


      enddo  ! end of l loop over 45 orbits/flybys
      
      
      END    ! end of program



      subroutine populateTimestampArray(timestamps)
c     Timestamp strings for times of closest approach (rounded to neartest
c     sec) in Clipper's 45 orbits (calculated via clipper_trajall_calc.f and
c     clipper_trajall_read.m and finding altitude minima, then manually
c     translated the timestamp format from Matlab's datestr format to SPICE's
c     format.  See clipper_trajall_plot.pdf for verification.)
      character*20 timestamps(45)
      timestamps(01)='2029-03-25T22:25:30'
      timestamps(02)='2029-04-09T02:39:00'
      timestamps(03)='2029-04-23T07:41:40'
      timestamps(04)='2029-05-07T12:41:20'
      timestamps(05)='2029-05-21T17:41:00'
      timestamps(06)='2029-06-04T22:41:00'
      timestamps(07)='2029-06-19T03:43:10'
      timestamps(08)='2029-07-03T15:14:50'
      timestamps(09)='2029-07-17T20:13:10'
      timestamps(10)='2029-08-01T01:14:00'
      timestamps(11)='2029-08-15T06:10:20'
      timestamps(12)='2029-08-29T11:06:30'
      timestamps(13)='2029-09-12T15:59:40'
      timestamps(14)='2029-09-26T21:14:10'
      timestamps(15)='2029-10-11T09:11:40'
      timestamps(16)='2029-11-12T01:38:10'
      timestamps(17)='2029-11-26T14:56:20'
      timestamps(18)='2029-12-14T04:39:10'
      timestamps(19)='2029-12-28T17:38:40'
      timestamps(20)='2030-01-15T07:05:50'
      timestamps(21)='2030-01-29T19:58:40'
      timestamps(22)='2030-02-16T09:38:50'
      timestamps(23)='2030-03-02T22:47:50'
      timestamps(24)='2030-03-20T12:04:20'
      timestamps(25)='2030-04-04T01:16:00'
      timestamps(26)='2030-04-18T06:12:20'
      timestamps(27)='2030-05-02T11:02:00'
      timestamps(28)='2030-05-27T07:35:30'
      timestamps(29)='2030-12-09T22:14:50'
      timestamps(30)='2031-01-14T21:02:40'
      timestamps(31)='2031-01-28T18:05:00'
      timestamps(32)='2031-02-11T23:07:00'
      timestamps(33)='2031-02-26T04:10:50'
      timestamps(34)='2031-03-12T09:12:30'
      timestamps(35)='2031-03-26T14:14:40'
      timestamps(36)='2031-04-09T18:28:30'
      timestamps(37)='2031-05-04T06:20:50'
      timestamps(38)='2031-05-29T03:36:10'
      timestamps(39)='2031-06-12T07:35:50'
      timestamps(40)='2031-07-07T04:31:00'
      timestamps(41)='2031-07-21T08:15:00'
      timestamps(42)='2031-08-15T05:16:30'
      timestamps(43)='2031-08-29T08:55:10'
      timestamps(44)='2031-09-23T05:36:20'
      timestamps(45)='2031-10-07T08:46:40'
      return
      end
