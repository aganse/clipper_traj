# Makefile for programs in this directory

# note you'll need to change this path to your own location of JPL spice toolkit...
toolkitdir=/Users/aganse/Work-School/src/fortran/jpl_spice_toolkit/lib

all: clipper_trajorbs_calc
	
clipper_trajorbs_calc: clipper_trajorbs_calc.f
	gfortran -ffixed-line-length-0 -o clipper_trajorbs_calc clipper_trajorbs_calc.f $(toolkitdir)/spicelib.a
	
clipper_trajall_calc: clipper_trajall_calc.f
	gfortran -ffixed-line-length-0 -o clipper_trajall_calc  clipper_trajall_calc.f $(toolkitdir)/spicelib.a

