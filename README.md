高潜用户购买意向预测
----

本次大赛以京东商城真实的用户、商品和行为数据（脱敏后）为基础，参赛队伍需要通过数据挖掘的技术和机器学习的算法，构建用户购买商品的预测模型，输出高潜用户和目标商品的匹配结果，为精准营销提供高质量的目标群体。
对每一个用户的预测结果包括两方面：该用户2016-04-16到2016-04-20是否下单P中的商品；如果下单，下单的sku_id。

----
R
---
1. Explore.r  数据探索
2. Feature.r  特征提取
3. Evaluate.R 评测函数
4. 特征分析.md  
5. Feature_all.R  特征提取
6. Feature.r  特征提取

python
---
Evaluate.py  评测函数
Model_Pre.py  训练
Model.py      训练

scala
---
1. JDDateFormat.scala Spark进行数据预处理(时间转换)
2. JDDataSQL.scala  SparkSQL进行统计





