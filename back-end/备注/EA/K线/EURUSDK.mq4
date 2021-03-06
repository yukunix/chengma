//+------------------------------------------------------------------+
//|                                                           gj.mq4 |
//|                                                           郭毕烈 |
//|                                         https://www.gzrunyin.com |
//+------------------------------------------------------------------+
#include <stdlib.mqh>
#include <MQLMySQL.mqh>
#property copyright "郭毕烈"
#property link      "https://www.gzrunyin.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//string ip="127.0.0.1";string db_user="root";string db_pass="123";
string ip="47.52.199.109";string db_user="dev";string db_pass="dev123";



string db_name="crm";




int OnInit()
  {
//--- create timer
   EventSetTimer(300);
      
//---
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer(){
      int DB = MySqlConnect(ip, db_user, db_pass, db_name, 3306, 0, "");
      if (DB == -1) { 
      
          Print ("连接失败!错误信息: "+MySqlErrorDescription);
          
      } else { 
      
        Print ("连接成功#",DB);
        
        Print("K线数量:",iBars(NULL,PERIOD_H1)); 
        
        int size=iBars(NULL,PERIOD_H1);
        
        for(int i=1;i<120;i++){
        
          // Print ("k线#"+i);
          int cycle=Period();
          
          string symbol=Symbol();
          
          double macd=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,i);
          
          double dif =iMA(NULL,0,12,8,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,26,8,MODE_EMA,PRICE_CLOSE,i);
                                         
                                         
         string sql=" insert into t_tlb_history_k(c_id,c_cycle,i_open,i_close,i_low ,i_high,c_macd,c_dif,d_time,c_symbol)"+
         "VALUES (replace(uuid(), '-', ''),'"+cycle+"','"+iOpen(NULL,cycle,i)+"','"+iClose(NULL,cycle,i)+"','"+iLow(NULL,cycle,i)+"','"+iHigh(NULL,cycle,i)+"','"+macd+"','"+dif+"','"+iTime(NULL,cycle,i)+"','"+symbol+"')";                      
        
         bool result=MySqlExecute(DB, sql);
         
         if(result==false){
         
            string sql="update t_tlb_history_k set i_open = "+iOpen(NULL,cycle,i)+", i_close = "+iClose(NULL,cycle,i)+",i_low = "+iLow(NULL,cycle,i)+",i_high = "+iHigh(NULL,cycle,i)+" where d_time= '"+iTime(NULL,cycle,i)+"' and c_symbol='"+symbol+"'" + " and c_cycle='"+cycle+"'";
            
            Print("update sql =============" + sql);
            bool results=MySqlExecute(DB, sql);
           
            Print ("更新:"+results);
         
         }
        
        
        
       }
        
   
        
        
        MySqlDisconnect(DB);
    
    }
    
   




  }
//+------------------------------------------------------------------+
