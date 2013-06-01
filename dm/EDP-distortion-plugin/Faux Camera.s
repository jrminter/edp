// Install this script as a library in order to built script
// packages on an off-line PC (i.e. without Multi-scan camera)

image sscgainnormalizedbinnedacquire( number i, number bin, number t, number l, number b, number r )
{
	image new := IntegerImage( "faux camera image", 2, 1, (r-l)/bin, (b-t)/bin )
	new = GaussianRandom()
	return new
}