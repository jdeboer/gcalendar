#' Return a "flat" data.frame where colums that are of class data.frame are integrated into the parent data.frame
#'
#' @param x  a data.frame
#' @return a data.frame
#' @examples
#' a<-data.frame(v1=seq(1:10),v2=letters[1:10])
#' a$complex<-a
#' flatDataframe(a)
#' @export
flatDataframe <-function(x){
  while(any(sapply(x,function(y){inherits(y,"data.frame")}))){
    newdf<-data.frame(matrix(vector(),nrow(x),0))
    newnames<-vector()
    for (i in names(x)) {
      if (inherits(x[,i],"data.frame")) {
        for(j in names(x[,i])) {
          newdf[,paste(i,j,sep=".")]<-x[,i][,j]
        }
      } 
      else { 
        newdf[,i]<-x[,i]
      }
    }
    x<-newdf
  }
  x
}
