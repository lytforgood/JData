package jd

import org.apache.spark.{SparkConf, SparkContext}

/**
  * Created by yuyin
  *    user_id sku_id   time     model_id type cate brand  week
       100259 159398 20160401       NA    6    4   752     5
  * 进行SQL处理
  */
object JDDataSQL {
  def main(args: Array[String]): Unit = {
    val conf = new SparkConf().setAppName("SparkWordCount").setMaster("local[2]")
    val sc = new SparkContext(conf)
    val sqlContext = new org.apache.spark.sql.SQLContext(sc)

    val path = "/Users/yuyin/Downloads/笔记学习/天池比赛/JD高潜用户购买意向预测/data/Action201604/part-00000"
    case class u_action(user_id:String,sku_id:String,time:Int,model_id:String,Type:Int,cate:Int,brand:Int,week:Int)
    val data = sc.textFile(path).map(x => (x.split(",")(0), x.split(",")(1), x.split(",")(2), x.split(",")(3), x.split(",")(4), x.split(",")(5), x.split(",")(6), x.split(",")(7)))

//    val df=data.map(x=>u_action(x._1.toString,x._2.toString,x._3.toInt,x._4.toString,x._5.toInt,x._6.toInt,x._7.toInt,x._8.toInt)).toDF()
    //    df.show(2)
    //将DataFrame注册成表commitlog
//    df.registerTempTable("u_action")
    //显示前2行数据
    val re=sqlContext.sql("SELECT * FROM u_action ")
    //去掉多余括号
    val re2=re.map(x=>x.toString().replaceAll("\\[","").replaceAll("\\]",""))
    re2.coalesce(1).saveAsTextFile("/Users/yuyin/Downloads/笔记学习/天池比赛/JD高潜用户购买意向预测/data/Action201604/sql1")

  }

}
