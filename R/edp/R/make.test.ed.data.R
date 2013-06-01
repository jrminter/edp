make.test.ed.data <-
function(dir='./'){
  data(al.lines)
  data(al.edp)
  str.edp   <- paste(dir,'Al-dc-ra.csv',sep='')
  write.csv(al.edp, file=str.edp,
  	        row.names=FALSE, quote=FALSE )
  str.lines <-  paste(dir,'04-0787-Al-Fm3m.csv',sep='')
  write.csv(al.lines, file=str.lines,
  	        row.names=FALSE, quote=FALSE )
}
