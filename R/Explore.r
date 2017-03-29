##数据探索
options(stringsAsFactors=F,scipen=99)
rm(list=ls());gc()
setwd("/Users/yuyin/Downloads/笔记学习/天池比赛/JD高潜用户购买意向预测/data/")
require(data.table)
# da<- fread("JData_User.csv",header = FALSE)
# S：提供的商品全集；
# P：候选的商品子集，P是S的子集；
# U：用户集合；
# A：用户对S的行为数据集合；
# C：S的评价数据。
##用户集合
u<- read.csv("JData_User.csv",fileEncoding='gbk',header = TRUE)
hist(u$sex)
table(u$sex)
#10W个用户男0.43-4.5w 女0.48-5w 未知0.07-7k
hist(u$user_lv_cd)
table(u$user_lv_cd)
##每个用户级别比重
tmp=as.integer(table(u$user_lv_cd))
rate={}
for(i in 1:length(tmp)){
  rate=c(rate,round(tmp[i]/sum(tmp),2))
}
rate
##注册会员(仅注册)、铜牌会员(注册购买过)、银牌会员(2000)、金牌会员(10000)、钻石会员(30000) 成长值约等于价格
##用户级别1     2     3     4     5
#        0.02  0.07  0.21  0.31  0.38
##候选的商品子集2.4W件商品  大类别全为8
p<- read.csv("JData_Product.csv",fileEncoding='gbk',header = TRUE)
ck=p$attr1
hist(ck)
table(ck)
tmp=as.integer(table(ck))
rate={}
for(i in 1:length(tmp)){
  rate=c(rate,round(tmp[i]/sum(tmp),2))
}
rate
##-1未知     1     2     3  属性attr1
#  0.07    0.20  0.15 0.58
##-1     1     2   属性attr2
# 0.17  0.56  0.27
##-1     1     2    属性attr3
# 0.16  0.35 0.50
##102种品牌brand  214、489特别多分别占0.27 0.27 6k median 18 mean 237
ck=p$brand
x=sort(unique(ck))
val=tmp=as.integer(table(ck))
library(recharts)
echartr(data.frame(x,val),x,val,type = 'hist')

##评价数据55.8w
c<- read.csv("JData_Comment(修正版).csv",fileEncoding='gbk',header = TRUE)
##累计评论数分段comment_num
0:无评论    1:1条评论      2:2-10条      3:11-50条      4:大于50条
0.04       0.15          0.30          0.21           0.30
##是否有差评has_bad_comment
0无     1有
0.52   0.48
##差评率bad_comment_rate  大部分在0.35以下差评率 均值0.04999276 中位数0
0.52无差评 0.01全差评
分位数：quantile(ck)  自定义分位数 quantile(ck,  probs = c(0.85,0.95))
    0%    25%    50%    75%   85%    95%    100%
0.0000 0.0000 0.0000 0.0465  0.0789 0.2000  1.0000

##用户对商品全集S的行为数据集合 4月行为表 8.5w用户 2.1w商品
a<- read.csv("JData_Action_201604.csv",fileEncoding='gbk',header = TRUE)
write.table (a, file ="JData_Action_201604_utf.csv",sep =",",row.names = F,col.names=TRUE,quote =F)
a=fread("JData_Action_201604_utf.csv",header = TRUE)
length(unique(a$user_id))
##点击模块编号 216 217  0.18 0.17  NA  0.42
ck=a$model_id
hist(ck)
table(ck)
##type 1.浏览 2.加入购物车；3.购物车删除；4.下单；5.关注；6.点击
      # 0.36   0.0107      0.005     0.0006  0.0017    0.63
ck=a$type
hist(ck)
tmp=as.integer(table(ck))
rate={}
for(i in 1:length(tmp)){
  rate=c(rate,round(tmp[i]/sum(tmp),2))
}
rate
##品类ID  cate
4    5    6    7    8    9    10   11
0.22 0.10 0.11 0.07 0.43 0.06 0.01 0.00
##品牌ID  brand
options(stringsAsFactors=F,scipen=99)
rm(list=ls());gc()
setwd("/Users/yuyin/Downloads/笔记学习/天池比赛/JD高潜用户购买意向预测/data/")
require(data.table)
a=fread("./Action201604/part-00000",header = FALSE)
names(a)=c('user_id','sku_id','time','model_id','type','cate','brand','week')
##统计下每天购买的次数 人数 商品数
library(sqldf)
re=sqldf("select count(user_id) as c0,count(distinct user_id) as c1,count(distinct sku_id) as c2,time from a where type=4 group by time")
library(recharts)
echartr(re,c(1:length(re$c0)),c0,type = 'line')
##该类商品前两天加入购物车
re1=sqldf('select user_id,sku_id from a where type=2 and cate=8 and time>=20160414')
##该类商品最后两天购买了的白名单
re2=sqldf('select user_id,sku_id from a where type=4 and cate=8 and time>=20160414')
re3=sqldf('select user_id,sku_id from a where type=3 and cate=8 and time>=20160414')
re4=rbind(re2,re3)

r5=sqldf("select a.*,b.user_id as t1 from re1 a left join re4 b on a.user_id=b.user_id and a.sku_id=b.sku_id")
tt=r5[which(is.na(r5$t1)),]
tt=tt[,c(1,2)]
tt=unique(tt)
user_id=unique(tt$user_id)
t6={}
for(i in 1:length(user_id)){
    x=tt[which(tt$user_id==user_id[i]),]$sku_id
    t6=c(t6,x[1])
}
r7=data.frame(user_id,t6)
names(r7)=c('user_id','sku_id')
write.table (r7, file ="out/twoday_325_1.csv",sep =",",row.names = F,col.names=TRUE,quote =F)


##最后两天取差评率低的
options(stringsAsFactors=F,scipen=99)
rm(list=ls());gc()
setwd("/Users/yuyin/Downloads/笔记学习/天池比赛/JD高潜用户购买意向预测/data/")
require(data.table)
library(sqldf)
a=fread("./Action201604/part-00000",header = FALSE)
names(a)=c('user_id','sku_id','time','model_id','type','cate','brand','week')
##该类商品前两天加入购物车
re1=sqldf('select user_id,sku_id from a where type=2 and cate=8 and time>=20160414')
##该类商品最后两天购买了的白名单
re2=sqldf('select user_id,sku_id from a where type=4 and cate=8 and time>=20160414')
re3=sqldf('select user_id,sku_id from a where type=3 and cate=8 and time>=20160414')
re4=rbind(re2,re3)

r5=sqldf("select a.*,b.user_id as t1 from re1 a left join re4 b on a.user_id=b.user_id and a.sku_id=b.sku_id")
tt=r5[which(is.na(r5$t1)),]
tt=tt[,c(1,2)]
tt=unique(tt)
user_id=unique(tt$user_id)
c<- read.csv("JData_Comment(修正版).csv",fileEncoding='gbk',header = TRUE)
cp=sqldf('select sku_id,bad_comment_rate from c where dt="2016-04-15"')
tt=sqldf('select a.*,b.bad_comment_rate from tt a left join cp b on  a.sku_id=b.sku_id')
#按差评率选取差评低的
sku_id={}
for(i in 1:length(user_id)){
    x=tt[which(tt$user_id==user_id[i]),]
    if(length(x$sku_id)>1){
    x=x[order(x$bad_comment_rate,decreasing=F),]
    sku_id=c(sku_id,x$sku_id[1])
    }else{
    sku_id=c(sku_id,x$sku_id[1])
    }
}
r7=data.frame(user_id,sku_id)
# names(r7)=c('user_id','sku_id')
write.table (r7, file ="out/twoday_325_3.csv",sep =",",row.names = F,col.names=TRUE,quote =F)


##最后一天取差评率低的
options(stringsAsFactors=F,scipen=99)
rm(list=ls());gc()
setwd("/Users/yuyin/Downloads/笔记学习/天池比赛/JD高潜用户购买意向预测/data/")
require(data.table)

a=fread("./Action201604/part-00000",header = FALSE)
names(a)=c('user_id','sku_id','time','model_id','type','cate','brand','week')
##该类商品前两天加入购物车
re1=sqldf('select user_id,sku_id from a where type=2 and cate=8 and time>=20160415')
##该类商品最后两天购买了的白名单
re2=sqldf('select user_id,sku_id from a where type=4 and cate=8 and time>=20160415')
re3=sqldf('select user_id,sku_id from a where type=3 and cate=8 and time>=20160415')
re4=rbind(re2,re3)

r5=sqldf("select a.*,b.user_id as t1 from re1 a left join re4 b on a.user_id=b.user_id and a.sku_id=b.sku_id")
tt=r5[which(is.na(r5$t1)),]
tt=tt[,c(1,2)]
tt=unique(tt)
user_id=unique(tt$user_id)
c<- read.csv("JData_Comment(修正版).csv",fileEncoding='gbk',header = TRUE)
cp=sqldf('select sku_id,bad_comment_rate from c where dt="2016-04-15"')
tt=sqldf('select a.*,b.bad_comment_rate from tt a left join cp b on  a.sku_id=b.sku_id')
#按差评率选取差评低的
sku_id={}
for(i in 1:length(user_id)){
    x=tt[which(tt$user_id==user_id[i]),]
    if(length(x$sku_id)>1){
    x=x[order(x$bad_comment_rate,decreasing=F),]
    sku_id=c(sku_id,x$sku_id[1])
    }else{
    sku_id=c(sku_id,x$sku_id[1])
    }
}
r7=data.frame(user_id,sku_id)
# names(r7)=c('user_id','sku_id')
write.table (r7, file ="out/1day_325_1.csv",sep =",",row.names = F,col.names=TRUE,quote =F)


##library(dplyr)代替sqldf
options(stringsAsFactors=F,scipen=99)
rm(list=ls());gc()
setwd("/Users/yuyin/Downloads/笔记学习/天池比赛/JD高潜用户购买意向预测/data/")
require(data.table)
library(dplyr)
a=fread("./Action201604/part-00000",header = FALSE)
names(a)=c('user_id','sku_id','time','model_id','type','cate','brand','week')
a <- tbl_df(a)
re1=select(filter(a,type == 2,cate ==8,time>=20160415),user_id,sku_id)
re2=select(filter(a,type == 4,cate ==8,time>=20160415),user_id,sku_id)
re3=select(filter(a,type == 3,cate ==8,time>=20160415),user_id,sku_id)
re4=rbind(re2,re3)
r5=anti_join(re1, re4, by=c("user_id","sku_id")) ##在re1不在re4
tt=unique(r5)
user_id=unique(tt$user_id)
c<- read.csv("JData_Comment(修正版).csv",fileEncoding='gbk',header = TRUE)
cp=select(filter(c,dt == "2016-04-15"),sku_id,bad_comment_rate)
tt=left_join(tt, cp, by="sku_id")
#按差评率选取差评低的
sku_id={}
for(i in 1:length(user_id)){
    x=filter(tt,user_id == user_id[i])
    if(length(x$sku_id)>1){
    x=arrange(x, bad_comment_rate)
    sku_id=c(sku_id,x$sku_id[1])
    }else{
    sku_id=c(sku_id,x$sku_id[1])
    }
}
r7=data.frame(user_id,sku_id)
# names(r7)=c('user_id','sku_id')
write.table (r7, file ="out/1day_325_1_1.csv",sep =",",row.names = F,col.names=TRUE,quote =F)



options(stringsAsFactors=F,scipen=99)
rm(list=ls());gc()
setwd("/Users/yuyin/Downloads/笔记学习/天池比赛/JD高潜用户购买意向预测/data/")
require(data.table)
library(dplyr)
t1=fread("./out/1day_325_1.csv",header = TRUE)
t2=fread("./out/twoday_325_3.csv",header = TRUE)
t3=fread("./out/twoday_325_3.csv",header = TRUE)
t=rbind(t1,t2,t3)
t=unique(t)
write.table (t, file ="out/uidsid.csv",sep =",",row.names = F,col.names=TRUE,quote =F)


options(stringsAsFactors=F,scipen=99)
rm(list=ls());gc()
setwd("/Users/yuyin/Downloads/笔记学习/天池比赛/JD高潜用户购买意向预测/data/")
require(data.table)
library(sqldf)
library(dplyr)
t1=fread("./out/2.csv",header = FALSE)
t2=fread("./out/3.csv",header = FALSE)
t3=sqldf("select t1.*,t2.V2 as V3 from t1 left join t2 on t1.V1=t2.V1")
for(i in 1:length(t3$V3)){
  if(!is.na(t3$V3[i])){
      t3$V2[i]=t3$V3[i]
    }
}
t3=t3[,c(1,2)]
names(t3)=c('user_id','sku_id')
write.table (t3, file ="out/2left3_326_1.csv",sep =",",row.names = F,col.names=TRUE,quote =F)


c<- read.csv("JData_Comment(修正版).csv",fileEncoding='gbk',header = TRUE)
cp=select(filter(c,dt == "2016-04-15"),sku_id,bad_comment_rate)
tt=left_join(tt, cp, by="sku_id")

##数据合并
options(stringsAsFactors=F,scipen=99)
rm(list=ls());gc()
setwd("/Users/yuyin/Downloads/笔记学习/天池比赛/JD高潜用户购买意向预测/data/")
require(data.table)
library(sqldf)
library(dplyr)
t1=fread("./02/part-00000",header = FALSE)
t2=fread("./031/part-00000",header = FALSE)
t3=fread("./032/part-00000",header = FALSE)
t4=fread("./04/part-00000",header = FALSE)
t=rbind(t1,t2,t3,t4)
names(t)=c('user_id','sku_id','time','model_id','type','cate','brand','h','week')
write.table (t, file ="Action_all.csv",sep =",",row.names = F,col.names=TRUE,quote =F)


options(stringsAsFactors=F,scipen=99)
rm(list=ls());gc()
setwd("/Users/yuyin/Downloads/笔记学习/天池比赛/JD高潜用户购买意向预测/data/out/")
require(data.table)
library(dplyr)
tt=fread("predictAll.csv",header = FALSE)
names(tt)=c('user_id','sku_id','pro')
tt=unique(tt)
c<- read.csv("../JData_Comment(修正版).csv",fileEncoding='gbk',header = TRUE)
cp=select(filter(c,dt == "2016-04-15"),sku_id,bad_comment_rate,comment_num,has_bad_comment)
tt=left_join(tt, cp, by="sku_id")
tt=arrange(tt, desc(pro))
##去掉cate=8没有的样本
tt=tt[-which(is.na(tt$bad_comment_rate)),]
user_id=unique(tt$user_id)
#按差评率选取差评低的
r6={}
for(i in 1:1500){
    x=filter(tt,user_id == user_id[i])
    if(length(x$sku_id)>1){
        if(x$pro[1]/x$pro[2]<3){
          x=arrange(x[1:2,], bad_comment_rate)
          r6=rbind(r6,x[1,c(1,2)])
        }else{
          r6=rbind(r6,x[1,c(1,2)])
        }
    }else{
      r6=rbind(r6,x[1,c(1,2)])
    }
}
r7=data.frame(r6)
names(r7)=c('user_id','sku_id')
r7=unique(r7)
out=r7[1:1214,]
write.table (out, file ="top1000.csv",sep =",",row.names = F,col.names=TRUE,quote =F)

t1=fread("0.09512.csv",header = FALSE)
names(t1)=c('user_id','sku_id')
tmp=semi_join(t1,out, by=c("user_id","sku_id"))
t1=left_join(t1, out, by="user_id")
names(t1)=c("V1","V2","V3")
n3=sqldf("select * from t1 where V2 != V3")
n3=n3[,c(1,3)]
names(n3)=c('user_id','sku_id')
write.table (n3, file ="89改.csv",sep =",",row.names = F,col.names=TRUE,quote =F)
r7=arrange(r7,user_id)
t1=arrange(t1,user_id)

##评测函数
library(dplyr)
evaluate<-function(p_pre,p_true){
all=length(p_pre$user_id)
all_z=length(p_true$user_id)
tmp=semi_join(p_true,p_pre, by=c("user_id"))
z=length(tmp$user_id)
Recall=z/all_z
Precise=z/all
f11=6*Recall*Precise/(5*Recall+Precise)
tmp=semi_join(p_true,p_pre, by=c("user_id","sku_id"))
z=length(tmp$sku_id)
Recall=z/all_z
Precise=z/all
f12=5*Recall*Precise/(2*Recall+3*Precise)
f=0.4*f11+0.6*f12
f_out=data.frame(c("F:","f11:","f12:"),c(f,f11,f12))
names(f_out)=c("F","Val")
return(f_out)
}
##随机5次取均值
evaluate_A_B_random<-function(p_pre,p_true){
all_f11={}
all_f12={}
all_f={}
for(i in 1:5){
p_true=sample_n(tbl_df(p_true),  floor(nrow(p_true)/2))
all=length(p_pre$user_id)
all_z=length(p_true$user_id)
tmp=semi_join(p_true,p_pre, by=c("user_id"))
z=length(tmp$user_id)
Recall=z/all_z
Precise=z/all
f11=6*Recall*Precise/(5*Recall+Precise)
all_f11=c(all_f11,f11)
tmp=semi_join(p_true,p_pre, by=c("user_id","sku_id"))
z=length(tmp$sku_id)
Recall=z/all_z
Precise=z/all
f12=5*Recall*Precise/(2*Recall+3*Precise)
all_f12=c(all_f12,f12)
f=0.4*f11+0.6*f12
all_f=c(all_f,f)
}
all_f[which(is.na(all_f))]=0
all_f11[which(is.na(all_f11))]=0
all_f12[which(is.na(all_f12))]=0
f_out=data.frame(c("F:","f11:","f12:"),c(mean(all_f),mean(all_f11),mean(all_f12)))
names(f_out)=c("F","avg_Val")
return(f_out)
}


options(stringsAsFactors=F,scipen=99)
rm(list=ls());gc()
setwd("/Users/yuyin/Downloads/笔记学习/天池比赛/JD高潜用户购买意向预测/data/线下评测表/")
require(data.table)
library(dplyr)
# tt=fread("predictAll.csv",header = FALSE)
# names(tt)=c('user_id','sku_id')
pre=fread("我的预测集",header = FALSE)
ptrue=fread("真实集",header = FALSE)
names(pre)=c('user_id','sku_id')
names(ptrue)=c('user_id','sku_id')
evaluate(pre,ptrue)
evaluate_A_B_random(pre,ptrue)


write.table (t1, file ="t1.csv",sep =",",row.names = F,col.names=TRUE,quote =F)



##查看预测比例
options(stringsAsFactors=F,scipen=99)
rm(list=ls());gc()
setwd("/Users/yuyin/Downloads/笔记学习/天池比赛/JD高潜用户购买意向预测/data/")
require(data.table)
library(sqldf)
library(dplyr)
t=fread("Action_all.csv",header = TRUE)
t=tbl_df(t)
time_end="2016/4/09"
time1=as.integer(format(as.Date(time_end,format="%Y/%m/%d"),"%Y%m%d"))
#最近7天的用户id
d=seq(as.Date("2016/2/1"),as.Date(time_end), by="day")
c1={}
c2={}
for(i in 1:20){
tmp_diff=i
start_time=as.integer(format(as.Date(d[length(d)-tmp_diff],format="%Y-%m-%d"),"%Y%m%d"))
us=filter(t,time>=start_time,time<time1,cate==8) %>% select(user_id,sku_id)
us=unique(us)

d2=seq(as.Date(time_end),as.Date("2016/4/30"), by="day")
end_time=as.integer(format(as.Date(d2[5],format="%Y-%m-%d"),"%Y%m%d"))
mai_us=filter(t,time>=time1,time<=end_time,cate==8,type==4) %>% select(user_id,sku_id)
mai_us=unique(mai_us)

us=mutate(us,label=1)
tmp=left_join(mai_us,us,by=c("user_id","sku_id"))
tmp$label[is.na(tmp$label)]=0
# as.integer(table(tmp$label))[2]/(as.integer(table(tmp$label))[1]+as.integer(table(tmp$label))[2])
c1=c(c1,as.integer(table(tmp$label))[2]/(as.integer(table(tmp$label))[1]+as.integer(table(tmp$label))[2]))
us2=unique(select(us,user_id,label))
tmp2=left_join(mai_us,us2,by=c("user_id"))
tmp2$label[is.na(tmp2$label)]=0
# as.integer(table(tmp2$label))[2]/(as.integer(table(tmp2$label))[1]+as.integer(table(tmp2$label))[2])
c2=c(c2,as.integer(table(tmp2$label))[2]/(as.integer(table(tmp2$label))[1]+as.integer(table(tmp2$label))[2]))
}

plot(c(1:length(c1)),c1,type = "l")
plot(c(1:length(c1)),c2,type = "l")



#前两天所有2 + 25 - 50 购买过的 截取合适的分段
tmp_diff=2
start_time=as.integer(format(as.Date(d[length(d)-tmp_diff],format="%Y-%m-%d"),"%Y%m%d"))
# us=filter(t,time>=start_time,time<time1,cate==8,type==1) %>% select(user_id,sku_id)
us=filter(t,time>=start_time,time<time1,cate==8) %>% select(user_id,sku_id)
us=unique(us)

tmp_diff=25
start_time=as.integer(format(as.Date(d[length(d)-tmp_diff],format="%Y-%m-%d"),"%Y%m%d"))
# usx2=filter(t,time>=start_time,time<time1,cate==8,type==2 | type==3| type==4| type==5) %>% select(user_id,sku_id)

usx2=filter(t,time>=start_time,time<time1,cate==8,type==2 | type==3|  type==5) %>% select(user_id,sku_id)
usx2=unique(usx2)
tmp_diff=50
start_time=as.integer(format(as.Date(d[length(d)-tmp_diff],format="%Y-%m-%d"),"%Y%m%d"))
usx3=filter(t,time>=start_time,time<time1,cate==8,type==4 | type==3) %>% select(user_id,sku_id)
usx3=unique(usx3)
usx2=setdiff(usx2,usx3) ##（在x中不在y中）
us=rbind(us,usx2)
us=unique(us)

d2=seq(as.Date(time_end),as.Date("2016/4/30"), by="day")
end_time=as.integer(format(as.Date(d2[5],format="%Y-%m-%d"),"%Y%m%d"))
mai_us=filter(t,time>=time1,time<=end_time,cate==8,type==4) %>% select(user_id,sku_id)
mai_us=unique(mai_us)
mai_us=mutate(mai_us,label=1)
us=left_join(us,mai_us,by=c("user_id","sku_id"))
us[is.na(us)] <- 0
table(us$label)

1 25  50
120199    253  475
2 25  50
173995    320  543  412
3
138667    274  506
137023    274  500
4
193102    317  609
5
233657    345  677
7
310924    375  829.1307
