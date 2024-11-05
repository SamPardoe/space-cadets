#!/bin/bash
gnuplot -e 'set parametric;x(t)=(R-r)*cos(t) + p*cos((R-r)*t/r);y(t)=(R-r)*sin(t) - p*sin((R-r)*t/r);R=20;r=2;p=15;set output "spiro.png";set term png; plot [t=0:2*pi] x(t),y(t);exit'
w3m result.png
