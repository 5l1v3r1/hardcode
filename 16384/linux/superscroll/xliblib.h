#include <math.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xos.h>
#include <X11/Xatom.h>
#include <X11/keysym.h>
Display *dis;
Window win;
XEvent report;
GC green_gc;
XColor green_col;
Colormap colormap;