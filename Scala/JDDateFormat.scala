package jd

import java.text.SimpleDateFormat
import java.util.{Calendar, Date, Locale}

import org.apache.spark.{SparkConf, SparkContext}

/**
  * Created by yuyin on 17/3/25.
  * user_id sku_id   time               model_id type cate brand
    100259 159398 2016-04-01 19:33:47       NA    6    4   752
  * 100259 159398 20160401                  NA    6    4   752
  */
object JDDateFormat {

  def main(args: Array[String]) {
    //    //传入的参数为 输入目录 输出目录
    //    if (args.length != 2) {
    //      System.err.println("Usage: input  output")
    //      System.exit(1)
    //    }
    //  }

    val conf = new SparkConf().setAppName("SparkWordCount").setMaster("local[2]")
    val sc = new SparkContext(conf)
    //  val line=sc.textFile(args(0)).flatMap(_.split(","))
    val path = "/Users/yuyin/Downloads/笔记学习/天池比赛/JD高潜用户购买意向预测/data/JData_Action_201602.csv"


    //  val line = sc.textFile(path).flatMap(_.split(","))
    //时间转换
    def change01(x: String): String = {
      try {
      val loc = new Locale("en")
      val fm = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", loc)
      val fm2 = new SimpleDateFormat("yyyyMMdd", loc)
      val dt2 = fm.parse(x)
      fm2.format(dt2)
      }catch{case _: Exception => "0"}
    }
    def change02(x: String): String = {
      try {
      val loc = new Locale("en")
      val fm = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", loc)
      val fm2 = new SimpleDateFormat("HHmm", loc)
      val dt2 = fm.parse(x)
      fm2.format(dt2)
      }catch{case _: Exception => "0"}
    }

    //判断周几
    def getWeeks(date_string:String)={
      val df:SimpleDateFormat=new SimpleDateFormat("yyyyMMdd")
      val tmp:Date=df.parse(date_string)
      val cal:Calendar = Calendar.getInstance()
      cal.setTime(tmp)
      var w:Int = cal.get(Calendar.DAY_OF_WEEK) - 1
      if (w == 0) {
        w = 7
      }
      w
    }


      val line = sc.textFile(path).map(x => {(x.split(",")(0),
        x.split(",")(1),
        change01(x.split(",")(2)),
        x.split(",")(3),
        x.split(",")(4),
        x.split(",")(5),
        x.split(",")(6),
        change02(x.split(",")(2)))
      })

    val re = line.filter(x=> !x._3.equals("0")).map(x => {
//      println(x)
      (x._1, x._2, x._3, x._4,x._5,x._6,x._7,x._8,getWeeks(x._3))
    })


//    val re = line.map(x => (x._1, x._2, x._3, x._4,x._5,x._6,x._7,x._8,getWeeks(x._3)))
      //    re.take(2)
      //re2去掉括号  coalesce(1)生成单文件
      val re2=re.map(x=>x.toString().replaceAll("\\(","").replaceAll("\\)",""))
      re2.coalesce(1).saveAsTextFile("/Users/yuyin/Downloads/笔记学习/天池比赛/JD高潜用户购买意向预测/data/02")

      //    re2.coalesce(1).saveAsTextFile("/Users/yuyin/Downloads/笔记学习/天池比赛/IJCAI-17口碑商家客流量预测/data/dataset/user_pay_re")
//    }catch{
//      case _: Exception => println("error")
//    }

    sc.stop()

  }
}
