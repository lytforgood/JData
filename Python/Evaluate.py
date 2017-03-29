# -*- coding: utf-8 -*-
import pandas as pd
import numpy as np

def f_score(pre,pture):
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
