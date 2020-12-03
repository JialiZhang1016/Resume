project<-data.frame(a=numeric(0),
                    b=numeric(0),
                    控制价=numeric(0),
                    正常出价区间的下界=numeric(0),
                    正常出价区间的上界=numeric(0))
project<-edit(project)

## 已知条件
company<-10000                ##假设有10000家公司参与竞争
close<-company*0.02           ##the mount of comany closed to X
h1<-round(0.2*company)        ##抬高价公司数目
h2<-round(0.2*company)        ##掌握的公司数目
h3<-company-h1-h2             ##其余的公司数目
a<-project$a*1000
b<-project$b*1000
low<-project$正常出价区间的下界*1000
up<-project$正常出价区间的上界*1000
cat("抬高价公司比重:",h1/company,"\n",
    "掌握的公司比重",h2/company,"\n",
    "其余的公司比重",h3/company)

set.seed(123)
n<-(up-low)*0.02;n            ##每次循环递增的长度(精度)，可取0.01，0.02
a1<-runif(h1,0.97*b,0.99*b)   ##高价区间
a3<-runif(h3,low,up)          ##其他公司出价区间


x<-list(p=numeric(0),
        ball_low=numeric(0),
        ball_up=numeric(0),
        price_low=numeric(0),
        price_up=numeric(0),
        中标价格=numeric(0))
x$ball_low[1]<-low;x$ball_low[1]
x$ball_up[1]<-low+n;x$ball_up[1]

for (i in 1:100){
  a2<-runif(h2,x$ball_low[i],x$ball_up[i])      ##需要预测的区间
  x$ball_low[i+1]<-x$ball_low[i]+n
  x$ball_up[i+1]<-x$ball_up[i]+n
  aaa<-c(a1,a2,a3)
  me_1<-mean(aaa)                               ##第一次平均
  me<-mean(aaa[aaa<me_1])                       ##第二次平均
  x$中标价格[i]<-me*project$控制价*0.00001      ##计算两次平均后的中标价格
  x$price_low<-x$ball_low*project$控制价*0.00001
  x$price_up<-x$ball_up*project$控制价*0.00001
  
  c1<-cbind(abs(a2-me),1)
  c2<-cbind(abs(a3-me),2)
  c<-rbind(c1,c2)
  C<-c[order(c[,1]),][1:close,]
  p1<-sum(C[1:close,2])-close
  x$p[i]<-(close-p1)/close
  x$p[i+1]<-0
}
结果<-do.call(cbind,x)
最终计算结果<-结果[order(结果[,1],decreasing=T),][1:20,]
View(最终计算结果)

