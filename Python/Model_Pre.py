# -*- coding: utf-8 -*-
import pandas as pd
import numpy as np
from xgboost.sklearn import XGBClassifier
from sklearn import metrics
import xgboost as xgb
path="/Users/yuyin/Downloads/笔记学习/天池比赛/JD高潜用户购买意向预测/data/"
train = pd.read_csv(path+"train.csv")
val = pd.read_csv(path+"val.csv")
test= pd.read_csv(path+"test.csv")
train_all=pd.concat([train,val])
X_train_all,y_train_all=train_all.iloc[:,2:(train_all.shape[1]-1)],train_all.iloc[:,-1]
X_test=test.iloc[:,2:(test.shape[1])]
clf = XGBClassifier(
learning_rate =0.1, #默认0.3
n_estimators=1000, #树的个数
max_depth=6,
# max_delta_step=0,
min_child_weight=1,
gamma=0,  #0.1-0.2
subsample=0.8,
colsample_bytree=0.8, #0.5-0.9
# colsample_bylevel=1,
objective= 'binary:logistic', #逻辑回归损失函数
nthread=-1,  #cpu线程数
scale_pos_weight=1, #十分不平衡取较大正值,在类别样本不平衡的情况下有助于快速收敛
#reg_alpha=1e-05, #L1正则项
reg_lambda=1, #L2正则项
#missing=None,
#silent=True,
#base_score=0.5
seed=1)  #随机种子
clf.fit(X_train_all, y_train_all,eval_metric='auc',verbose=False)
y_pro= clf.predict_proba(X_test)[:,1]
pre=pd.concat([test[['user_id','sku_id']],pd.DataFrame({'pro':y_pro})],axis=1)
pre=pre.sort(["pro"],ascending=False)
re=pre.iloc[0:1500,]
re=re[['user_id','sku_id']]
re.to_csv("top1500.csv",header=False,index=False)

#R
options(stringsAsFactors=F,scipen=99)
rm(list=ls());gc()
setwd("/Users/yuyin/Downloads/笔记学习/天池比赛/JD高潜用户购买意向预测/data/out/")
require(data.table)
library(dplyr)
c<- read.csv("../JData_Comment(修正版).csv",fileEncoding='gbk',header = TRUE)
cp=select(filter(c,dt == "2016-04-15"),sku_id,bad_comment_rate,comment_num,has_bad_comment)
tt=fread("../../jupyter/top1500.csv",header = FALSE)
names(tt)=c('user_id','sku_id')
tt=left_join(tt, cp, by="sku_id")
user_id=unique(tt$user_id)
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
names(r7)=c('user_id','sku_id')
r7=unique(r7)
r7=r7[1:1300,]
write.table (r7, file ="model2_1300.csv",sep =",",row.names = F,col.names=TRUE,quote =F)

