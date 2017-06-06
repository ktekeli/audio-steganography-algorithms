/*
 * popenr.c
 *
 * Attempt to provide popen for matlab, to allow reading from a process.
 * 
 * 2004-09-28 dpwe@ee.columbia.edu  after PlayOn
 * 
 * ToDo:
    - handle multidimensional reads i.e. 2nd arg = [2 1000]
    - at EOF, return matrix sized according to what was actually read
 *
 * $Header: /homes/drspeech/src/matlabpopen/RCS/popenr.c,v 1.2 2007/01/14 04:03:48 dpwe Exp dpwe $
 */
 
#include    <stdio.h>
#include    <math.h>
#include    <ctype.h>

#include    "mex.h"

#ifndef BIG_ENDIAN
#define BIG_ENDIAN 4321
#endif

#ifndef LITTLE_ENDIAN
#define LITTLE_ENDIAN 1234
#endif

#ifndef BYTE_ORDER
#ifdef  __DARWIN_UNIX03
#define BYTE_ORDER LITTLE_ENDIAN
#else
#define BYTE_ORDER BIG_ENDIAN
#endif
#endif

/* check if flags are working
#if BYTE_ORDER == BIG_ENDIAN
#error "byte order big endian"
#endif

#if BYTE_ORDER == LITTLE_ENDIAN
#error "byte order little endian"
#endif
*/


enum {
    MXPO_INT16BE,
    MXPO_INT16LE,
    MXPO_INT16N,
    MXPO_INT16R,
    MXPO_FLOAT,
    MXPO_DOUBLE,
    MXPO_UINT8,
    MXPO_CHAR,
};

#define FILETABSZ 16
static FILE *filetab[FILETABSZ];
static int filetabix = 0;

/* table to buffer first chr from each stream */
static char firstchr[FILETABSZ];
static int firstchrvalid[FILETABSZ];

int findfreetab() {
    /* find an open slot in the file table */
    int i;
    for (i = 0; i < filetabix; ++i) {
	if ( filetab[i] == NULL ) {
	    /* NULL entries are currently unused */
	    return i;
	}
    }
    if (filetabix < FILETABSZ) {
	i = filetabix;
	/* initialize it */
	filetab[i] = NULL;
	++filetabix;
	return i;
    }
    /* out of space */
    return -1;
}

void
mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int 	i, err, len;
    long   	pvl, pvb[16];
	int pregot = 0;
	char *cptr;


    if (nrhs < 1){
		mexPrintf("popenr     Y=popenr(X[,N[,F]])  Open and read an external process\n");
		mexPrintf("           When X is a string, that string is executed as a new process\n");
		mexPrintf("           and Y is returned as a handle (integer) to that stream.\n");
		mexPrintf("           Subsequent calls to popenr(Y,N) with that handle return\n");
		mexPrintf("           the next N values read from the standard ouptut of\n");
		mexPrintf("           converted to Matlab values according to the format\n");
		mexPrintf("           string F (default: int16).  A call with N set to -1\n");
		mexPrintf("           means to close the stream.\n");
		return;
    }
    /* look at the data */
    /* Check to be sure input argument is a string. */
	if ((mxIsChar(prhs[0]))){
		/* first argument is string - opening a new command */
		FILE *f;
		char *cmd;
		int tabix = findfreetab();
		int nr;
		
		if (tabix < 0) {
			mexErrMsgTxt("Out of file table slots.");
		} else {
			cmd = mxArrayToString(prhs[0]);
			/* fprintf(stderr, "cmd=%s\n", cmd); */
			f = popen(cmd, "r");
			mxFree(cmd);
			if ( f == NULL ) {
				mexErrMsgTxt("Error running external command.");
				return;
			}
	/*	    if (feof(f)) {
				mexPrintf("feof set\n");
			} else {
				mexPrintf("feof not set\n");
			}	    
	 */
			/* try it with no buffering */
			/* setvbuf(f, NULL, _IONBF, 0); */
			/* makes no difference...*/
	 
			/* test stream by reading one char */
			nr = fread(firstchr+tabix, 1, 1, f);
			if (nr == 1) {
				firstchrvalid[tabix] = 1;
			} else {
				firstchrvalid[tabix] = 0;
				pclose(f);
				mexErrMsgTxt("External command returned NULL output.");
				return;
			}
			/* else have a new command path - save the handle */
			filetab[tabix] = f;
			/* return the index */
			if (nlhs > 0) {
				double *pd;
				mxArray *rslt = mxCreateDoubleMatrix(1,1, mxREAL);
				plhs[0] = rslt;
				pd = mxGetPr(rslt);
				*pd = (double)tabix;
			}
		}
		return;
	}	

    if (nrhs < 2) {
		mexErrMsgTxt("apparently accessing handle, but no N argument");
		return;
    }
    
    /* get the handle */
	{
		int ix, rows, cols, npts, ngot; 
		int fmt = MXPO_INT16N;
		int sz = 2;
		FILE *f = NULL;
		double *pd;
		mxArray *rslt;
	
		if (mxGetN(prhs[0]) == 0) {
			mexErrMsgTxt("handle argument is empty");
			return;
		}
	
		pd = mxGetPr(prhs[0]);
		ix = (int)*pd;
		if (ix < filetabix) {
			f = filetab[ix];
		}
		if (f == NULL) {
			mexErrMsgTxt("invalid handle");
			return;
		}
		/* how many items required? */
		if (mxGetN(prhs[1]) == 0) {
			mexErrMsgTxt("length argument is empty");
			return;
		} else if (mxGetN(prhs[1]) == 1) {
			rows = (int)*mxGetPr(prhs[1]);
			cols = 1;
		} else {
			double *pd = mxGetPr(prhs[1]);
			rows = (int)pd[0];
			cols = (int)pd[1];
		}
		
		/* maybe close */
		if (rows < 0) {
			int nempty = 16384;
			int buf;
			while (nempty > 0 && !feof(f)) {
				/* try emptying the buffer */
				fread(&buf,1,1,f);
				--nempty;
			}
			/* or kill the process? */
			pclose(f);
			filetab[ix] = NULL;
			return;
		}
	
		/* what is the format? */
		if ( nrhs > 2 ) {
			char *fmtstr;
	
			if (!mxIsChar(prhs[2])) {
				mexErrMsgTxt("format arg must be a string");
				return;
			}
			fmtstr = mxArrayToString(prhs[2]);
			if (strcmp(fmtstr, "int16n")==0 || strcmp(fmtstr, "int16") == 0) {
				fmt = MXPO_INT16N;
			} else if (strcmp(fmtstr, "int16r")==0) {
				fmt = MXPO_INT16R;
			} else if (strcmp(fmtstr, "int16be")==0) {
	#if BYTE_ORDER == BIG_ENDIAN
				fmt = MXPO_INT16N;
	#else
				fmt = MXPO_INT16R;
	#endif
			} else if (strcmp(fmtstr, "int16le")==0) {
	#if BYTE_ORDER == BIG_ENDIAN
				fmt = MXPO_INT16R;
	#else
				fmt = MXPO_INT16N;
	#endif
			} else if (strcmp(fmtstr, "float")==0) {
				fmt = MXPO_FLOAT;
				sz = 4;
			} else if (strcmp(fmtstr, "double")==0) {
				fmt = MXPO_DOUBLE;
				sz = 8;
			} else if (strcmp(fmtstr, "uint8")==0) {
				fmt = MXPO_UINT8;
				sz = 1;
			} else if (strcmp(fmtstr, "char")==0) {
				fmt = MXPO_CHAR;
				sz = 1;
			} else {
				mexErrMsgTxt("unrecognized format");
			}
		}
	
		/* do the read */
		rslt = mxCreateDoubleMatrix(rows, cols, mxREAL);
		npts = rows*cols;
		cptr = (char *)mxGetPr(rslt);
		if (firstchrvalid[ix] == 1) {
			cptr[0] = firstchr[ix];
			firstchrvalid[ix] = 0;
			if (sz > 1) {
				fread(cptr+1,1,sz-1,f);
			}
			cptr = cptr + sz;
			pregot = 1;
		}
		ngot = pregot + fread(cptr, sz, npts-pregot, f);
	
	/*	    if (feof(f)) {
				mexPrintf("feof set\n");
			} else {
				mexPrintf("feof not set\n");
			}	    
	 */
	/*	UNTESTED!!!  */
		/* format conversion */
		if (sz == 4) {
			int i;
			double *pd = mxGetPr(rslt);
			float *pf = (float *)pd;
			pd = pd + npts - 1;
			pf = pf + npts - 1;
			for(i = npts-1; i >= 0; --i) {
				*pd-- = (double)*pf--;
			}
		}
		if (sz == 1) {
			int i;
			double *pd = mxGetPr(rslt);
			char *pc = (char *)pd;
			pd = pd + npts - 1;
			pc = pc + npts - 1;
			for(i = npts-1; i >= 0; --i) {
				*pd-- = (double)*pc--;
			}
		}
		if (sz == 2) {
			int i;
			double *pd = mxGetPr(rslt);
			short *ps = (short *)pd;
			pd = pd + npts - 1;
			ps = ps + npts - 1;
			if (fmt == MXPO_INT16N) {
				for(i = npts-1; i >= 0; --i) {
					*pd-- = (double)*ps--;
				}
			} else { /* MXPO_INT16R */
				short v;
				for(i = npts-1; i >= 0; --i) {
					v = (short)*pd--;
					*ps -- = (0xFF & (v >> 8)) + (0xFF00 & (v << 8));
				}
			}
		}
		
		/* did we get all the points we asked for */
		if (ngot < npts) {
			/* allocate a smaller array and copy to that */
			/* but only chop down by whole columns */
			int gotcols,gotrows;
			int i;
			double *pd, *ps;
			mxArray *newarr;
			if (cols == 1) {
				gotrows = ngot;
				gotcols = 1;
			} else {
				gotrows = rows;
				gotcols = (ngot+rows-1)/rows;
			}
			newarr = mxCreateDoubleMatrix(gotrows, gotcols, mxREAL);
			pd = mxGetPr(newarr);
			ps = mxGetPr(rslt);
			for (i = 0; i < ngot; ++i) {
				*pd++ = *ps++;
			}
			for (i = ngot; i < gotrows*gotcols; ++i) {
				*pd++ = 0;
			}
			mxDestroyArray(rslt);
			rslt = newarr;
		}
	
		if (nlhs > 0) {
			plhs[0] = rslt;
		} else {
			mxDestroyArray(rslt);
		}
		return;
	}
}
