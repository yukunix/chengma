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
   EventSetTimer(1);
   
   
      int DB = MySqlConnect(ip, db_user, db_pass, db_name, 3306, 0, "");
     if (DB == -1) { 
      
          Print ("连接失败!错误信息: "+MySqlErrorDescription);
          
     } else { 
      
        Print ("连接成功#",DB);
        
        //Print("K线数量:",iBars(NULL,PERIOD_H1)); 
        
        string symbol=Symbol();
        
        //int size=iBars(NULL,PERIOD_H1);
        
        //int cycle=Period();     
        
        double buy =Ask;                                 
        double sell=Bid;                                 
        
        double high30 = iHigh(NULL, 30, 0);
        double high60 = iHigh(NULL, 60, 0);
        double high1440 = iHigh(NULL, 1440, 0);
        
        double low30 = iLow(NULL, 30, 0);
        double low60 = iLow(NULL, 60, 0);
        double low1440 = iLow(NULL, 1440, 0);
        
        double open30 = iOpen(NULL, 30, 0);
        double open60 = iOpen(NULL, 60, 0);
        double open1440 = iOpen(NULL, 1440, 0);
        double spread = MathRound((Ask - Bid) * 系数(Symbol()));
        
        //Print("点差 ==============" + MathRound((Ask - Bid) * 系数(Symbol())));
        
        
        string insertSqlHistory = "INSERT INTO `t_tlb_mt_price_history` VALUES"
                   + "( replace(uuid(), '-', '')," + sell + "," + buy + ",'" + TimeLocal() + "','" + symbol + "'," + high1440 + "," + high30 + "," + high60 + "," + low1440 + "," + low30 + "," + low60 + "," + open1440 + "," + open30 + "," + open60 + "," + spread + ")";
                   
        string resultHistory=MySqlExecute(DB, insertSqlHistory);
        Print("insert resultHistory:"+resultHistory);
        
        string sql="select c_id, c_symbol from t_tlb_mt_price where c_symbol = '" + symbol +  "'";
        int cursor = MySqlCursorOpen(DB, sql);
        Print ("sql ==========" + sql);
        Print("cursor =======" + cursor);
        if (cursor >= 0){
           int rows = MySqlCursorRows(cursor);
           if(rows > 0){
              for (int i=0; i<rows; i++){
                  if (MySqlCursorFetchRow(cursor)){
                     string id = MySqlGetFieldAsString(cursor, 0);
                 
                     string updateSql = "UPDATE `t_tlb_mt_price` SET" 
                      + " `i_sell`= " + sell + ", "
                      + " `i_buy`= " + buy + ", "
                      + " `c_time`= '" + TimeLocal() + "', "
                      + " `c_symbol`= '" + symbol + "', "
                      + " `i_high1440`= " + high1440 + ", "
                      + " `i_high30`= '" + high30 + "', "
                      + " `i_high60`= " + high60 + ", "
                      + " `i_low1440`= " + low1440 + ", "
                      + " `i_low30`= '" + low30 + "', "
                      + " `i_low60`= " + low60 + ", "
                      + " `i_open1440`= " + open1440 + ", "
                      + " `i_open30`= '" + open30 + "', "
                      + " `i_open60`= " + open60 + " where c_id = '" +id + "'";
                     //Print(" timeLocal ======== " + TimeLocal());    
                     //Print( "updateSql ====================" + updateSql);    
                     string result=MySqlExecute(DB, updateSql);
                     Print(" update result:"+result);
                  }
              }
           }else{
               string insertSql = "INSERT INTO `t_tlb_mt_price` VALUES"
               //"INSERT INTO `t_tlb_mt_price` (`c_id`, `i_sell`, `i_buy`, `c_time`, `c_symbol`, `i_high1440`, `i_high30`, `i_high60`, `i_low1440`, `i_low30`, `i_low60`, `i_open1440`, `i_open30`, `i_open60`) VALUES"
                   + "( replace(uuid(), '-', '')," + sell + "," + buy + ",'" + TimeLocal() + "','" + symbol + "'," + high1440 + "," + high30 + "," + high60 + "," + low1440 + "," + low30 + "," + low60 + "," + open1440 + "," + open30 + "," + open60 + ")";
                   
               //Print( "sql ====================" + insertSql);    
               string result=MySqlExecute(DB, insertSql);
               Print("insert result:"+result);
           } 
           MySqlCursorClose(cursor);  
        }
        
        MySqlDisconnect(DB);
       }
   
   
   
   
   
      
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
        
        //Print("K线数量:",iBars(NULL,PERIOD_H1)); 
        
        string symbol=Symbol();
        
        //int size=iBars(NULL,PERIOD_H1);
        
        //int cycle=Period();     
        
        double buy =Ask;                                 
        double sell=Bid;                                 
        
        double high30 = iHigh(NULL, 30, 0);
        double high60 = iHigh(NULL, 60, 0);
        double high1440 = iHigh(NULL, 1440, 0);
        
        double low30 = iLow(NULL, 30, 0);
        double low60 = iLow(NULL, 60, 0);
        double low1440 = iLow(NULL, 1440, 0);
        
        double open30 = iOpen(NULL, 30, 0);
        double open60 = iOpen(NULL, 60, 0);
        double open1440 = iOpen(NULL, 1440, 0);
        double spread = MathRound((Ask - Bid) * 系数(Symbol()));
        
        //Print("点差 ==============" + MathRound((Ask - Bid) * 系数(Symbol())));
        
        string insertSqlHistory = "INSERT INTO `t_tlb_mt_price_history` VALUES"
                   + "( replace(uuid(), '-', '')," + sell + "," + buy + ",'" + TimeLocal() + "','" + symbol + "'," + high1440 + "," + high30 + "," + high60 + "," + low1440 + "," + low30 + "," + low60 + "," + open1440 + "," + open30 + "," + open60 + "," + spread + ")";
                   
        string resultHistory=MySqlExecute(DB, insertSqlHistory);
        Print("insert resultHistory:"+resultHistory);
        
        
        string sql="select c_id, c_symbol from t_tlb_mt_price where c_symbol = '" + symbol +  "'";
        //Print ("sql ==========" + sql);
        
        int cursor = MySqlCursorOpen(DB, sql);
        Print("cursor =======" + cursor);
        if (cursor >= 0){
           int rows = MySqlCursorRows(cursor);
           Print("rows =======" + rows);
           if(rows > 0){
              for (int i=0; i<rows; i++){
                  if (MySqlCursorFetchRow(cursor)){
                     string id = MySqlGetFieldAsString(cursor, 0);
                 
                     string updateSql = "UPDATE `t_tlb_mt_price` SET" 
                      + " `i_sell`= " + sell + ", "
                      + " `i_buy`= " + buy + ", "
                      + " `c_time`= '" + TimeLocal() + "', "
                      + " `c_symbol`= '" + symbol + "', "
                      + " `i_high1440`= " + high1440 + ", "
                      + " `i_high30`= '" + high30 + "', "
                      + " `i_high60`= " + high60 + ", "
                      + " `i_low1440`= " + low1440 + ", "
                      + " `i_low30`= '" + low30 + "', "
                      + " `i_low60`= " + low60 + ", "
                      + " `i_open1440`= " + open1440 + ", "
                      + " `i_open30`= '" + open30 + "', "
                      + " `i_open60`= " + open60 + " where c_id = '" +id + "'";
                     //Print(" timeLocal ======== " + TimeLocal());    
                     //Print( "updateSql ====================" + updateSql);    
                     string result=MySqlExecute(DB, updateSql);
                     Print(" update result:"+result);
                  }
              }
           }else{
               string insertSql = "INSERT INTO `t_tlb_mt_price` VALUES"
               //"INSERT INTO `t_tlb_mt_price` (`c_id`, `i_sell`, `i_buy`, `c_time`, `c_symbol`, `i_high1440`, `i_high30`, `i_high60`, `i_low1440`, `i_low30`, `i_low60`, `i_open1440`, `i_open30`, `i_open60`) VALUES"
                   + "( replace(uuid(), '-', '')," + sell + "," + buy + ",'" + TimeLocal() + "','" + symbol + "'," + high1440 + "," + high30 + "," + high60 + "," + low1440 + "," + low30 + "," + low60 + "," + open1440 + "," + open30 + "," + open60 + ")";
                   
               //Print( "sql ====================" + insertSql);    
               string result=MySqlExecute(DB, insertSql);
               Print("insert result:"+result);
           } 
           MySqlCursorClose(cursor);
        }
        MySqlDisconnect(DB);
       
     }
    
   




  }
//+------------------------------------------------------------------+
double 系数(string symbol)
  {
   int 系数=1;
   /*
   if(
      MarketInfo(symbol,MODE_DIGITS)==3
      || MarketInfo(symbol,MODE_DIGITS)==5
      || (StringFind(symbol,"XAU",0)==0 && MarketInfo(symbol,MODE_DIGITS)==2)
      ||(StringFind(symbol,"GOLD",0)==0&&MarketInfo(symbol,MODE_DIGITS)==2)
      ||(StringFind(symbol,"Gold",0)==0&&MarketInfo(symbol,MODE_DIGITS)==2)
      || (StringFind(symbol,"USD_GLD",0)==0 && MarketInfo(symbol,MODE_DIGITS)==2)
      )系数=10;

   if(StringFind(symbol,"XAU",0)==0 && MarketInfo(symbol,MODE_DIGITS)==3)系数=100;
   */
   if(StringFind(symbol,"XAUUSD",0)==0){
      系数=100;
   }else if(StringFind(symbol,"EURUSD",0)==0){
      系数=100000;
   }
   

   return(系数);
  }

