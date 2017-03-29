# -*- coding: utf-8 -*-
import pandas as pd
import numpy as np
from xgboost.sklearn import XGBClassifier
from sklearn import metrics
import xgboost as xgb

def f_score(pre,pture):
    tmp=pd.merge(pture,pre,how='left',on=['user_id'])
    tmp=tmp[-pd.isnull(tmp.iloc[:,2])].reset_index()
    z=tmp.shape[0]
    all=pre.shape[0]
    all_z=pture.shape[0]
    print("预测出: %s 总共: %s"%(z,all_z))
    p1=float(z)/all
    r1=float(z)/all_z
    f11=6*r1*p1/(5*r1+p1)
    tmp2=tmp[(tmp["sku_id_x"]==tmp["sku_id_y"])]
    z=tmp2.shape[0]
    all=pre.shape[0]
    all_z=pture.shape[0]
    print("预测出: %s 总共: %s"%(z,all_z))
    p2=float(z)/all
    r2=float(z)/all_z
    f12=5*r2*p2/(2*r2+3*p2)
    fscore=0.4*f11+0.6*f12
    strp=("%s(F11:%s/F12:%s)" %(round(fscore,5),round(f11,5),round(f12,5)))
    print(strp)
    # print fscore,"(F11:",f11,"/F12:",f12,")"
    return strp

#随机5次模拟AB榜单成绩
def f_score_avgAB(pre,pture):
    Fscore=[]
    F11=[]
    F12=[]
    p_all=pture
    for x in xrange(1,5):
        pture=p_all.sample(int(p_all.shape[0]/2))
        tmp=pd.merge(pture,pre,how='left',on=['user_id'])
        tmp=tmp[-pd.isnull(tmp.iloc[:,2])].reset_index()
        z=tmp.shape[0]
        all=pre.shape[0]
        all_z=pture.shape[0]
        p1=float(z)/all
        r1=float(z)/all_z
        f11=6*r1*p1/(5*r1+p1)
        tmp2=tmp[(tmp["sku_id_x"]==tmp["sku_id_y"])]
        z=tmp2.shape[0]
        all=pre.shape[0]
        all_z=pture.shape[0]
        p2=float(z)/all
        r2=float(z)/all_z
        f12=5*r2*p2/(2*r2+3*p2)
        fscore=0.4*f11+0.6*f12
        print("%s(F11:%s/F12:%s)" %(round(fscore,5),round(f11,5),round(f12,5)))
        Fscore.append(fscore)
        F11.append(f11)
        F12.append(f12)
    # print fscore,"(F11:",f11,"/F12:",f12,")"
    strp=("avg: %s(F11:%s/F12:%s)" %(round(np.array(Fscore).mean(),5),round(np.array(F11).mean(),5),round(np.array(F12).mean(),5)))
    print(strp)
    return strp


path="/Users/yuyin/Downloads/笔记学习/天池比赛/JD高潜用户购买意向预测/data/"
train = pd.read_csv(path+"train.csv")
val = pd.read_csv(path+"val.csv")

X_train,y_train= train.iloc[:,2:(train.shape[1]-1)],train.iloc[:,-1]
X_val,y_val= val.iloc[:,2:(val.shape[1]-1)],val.iloc[:,-1]
# val['label']

##自定义评价函数(训练慢,特征多数据量大不推荐)
def f1_score(preds, dtrain):
    label = dtrain.get_label()
    preds=1.0/(1.0+np.exp(-preds))
    pred=[int(i>=0.5) for i in preds]
    tp=sum([int(i==1 and j==1) for i,j in zip(pred,label)])
    precision = float(tp)/sum(pred)
    recall=float(tp)/sum(label)
    return 'f1_score', (2*precision*recall)/(precision+recall)


clf = XGBClassifier(
 learning_rate =0.1, #默认0.3
 n_estimators=1000, #树的个数
 max_depth=3,
 # max_delta_step=0,
 min_child_weight=1,
 gamma=0.3,  #0.1-0.2
 subsample=0.6,
 colsample_bytree=0.6, #0.5-0.9
 # colsample_bylevel=1,
 objective= 'binary:logistic', #逻辑回归损失函数
 nthread=6,  #cpu线程数
 scale_pos_weight=1, #十分不平衡取较大正值
 #scale_pos_weight=1, #如果取值大于0的话，在类别样本不平衡的情况下有助于快速收敛。平衡正负权重
 #reg_alpha=1e-05, #L1正则项
 reg_lambda=1, #L2正则项
#missing=None,
#silent=True,
#base_score=0.5
seed=1)  #随机种子
# clf.fit(X_train, y_train)
# fit(X, y, sample_weight=None, eval_set=None, eval_metric=None,
#             early_stopping_rounds=None, verbose=True)
clf.fit(X_train, y_train,eval_set=[(X_train, y_train), (X_val, y_val)],eval_metric='auc',verbose=False)

# clf.fit(X_train, y_train,eval_set=[(X_train, y_train), (X_val, y_val)],eval_metric=f1_score,verbose=False)
evals_result = clf.evals_result()

y_pro= clf.predict_proba(X_val)[:,1]
# predict(data, output_margin=False, ntree_limit=0):
print "AUC Score : %f" % metrics.roc_auc_score(y_val, y_pro)

pre=pd.concat([val[['user_id','sku_id']],pd.DataFrame({'pro':y_pro})],axis=1)
pre=pre.sort(["pro"],ascending=False)
re=pre.iloc[0:1200,]
re=re[['user_id','sku_id']]
# re.to_csv("val_1200.csv",header=False,index=False)
true=val[(val["label"]==1)]
true=true[['user_id','sku_id']]
# true.to_csv("val_true.csv",header=False,index=False)
f_score(re,true)
f_score_avgAB(re,true)



