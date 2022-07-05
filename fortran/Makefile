build:
	gfortran -O2 -shared -fPIC -o librsgen.so random_sphere_gen.f90

install:
	mv librsgen.so ../shared

all: build install

clean:
	rm -f *.mod *.so
