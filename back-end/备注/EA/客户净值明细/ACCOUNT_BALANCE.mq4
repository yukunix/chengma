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
//string ip="47.52.199.109";string db_user="dev";string db_pass="dev123";
string ip="47.104.81.128";string db_user="hppuser";string db_pass="hpp123";



string db_name="hpp";




int OnInit()
  {
//--- create timer
   EventSetTimer(30);
      
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
      int DB = MySqlConnect(ip, db_user, db_pass, db_name, 3306, 0, 0);
      if(DB == -1) { 
      
          Print ("连接失败!错误信息: "+MySqlErrorDescription);
          
      }else { 
		  
			Print ("连接成功#",DB);
			
			Print("accountNo:=================" + AccountNumber());
			Print("balance:" + AccountBalance());
			Print("Leverage:" + AccountProfit());
			Print("Margin:" + AccountMargin());
			Print("freeMargin:" + AccountFreeMargin());
			//Print("AccountInfoString:" + AccountInfoString());
			Print("prifit" + AccountProfit());
			Print("prifit" + AccountCompany());
			Print("" + AccountServer());
			Print("Equity ===========" + AccountEquity());
			Print("TimeDay ===========" + TimeDay(TimeCurrent()));
			double balance = AccountBalance();
			double prifit = AccountProfit();
			double freeMargin = AccountFreeMargin();
			double margin = AccountMargin();
			double equity = AccountEquity();
		   
			
			
			string sql=" insert into t_hpp_strategy_bal_history(c_id, c_account, c_account_server, c_account_name, c_company, i_balance, i_free_margin, i_margin, i_equery, i_profit, d_mt4_server_time, d_db_server_time, d_create_at, c_remark)"+
			"VALUES (replace(uuid(), '-', ''),'"+AccountNumber()+"','"+AccountServer()+"','"+AccountName()+"','"+AccountCompany()+"',"+balance+","+freeMargin+","+margin
			+","+ equity+","+ prifit + ",'"+ TimeCurrent() + "', ' "+ TimeLocal() + "', '" + TimeLocal() +"', '" + "')";                      
			
			string updateSql = " update t_hpp_strategy_data SET i_balance = " + balance
			// + ", i_total_profit = " + prifit
			+ ", i_margin = " + margin 
			+ ", i_net_worth = " + equity 
			+ ", i_top_net_worth = GREATEST(i_net_worth, " + equity + ")"
			+ " where c_account = '" + AccountNumber() + "'";
			
			Print("获取数据结果 ======= " + sql);
			Print("更新策略数据结果 ======= " + updateSql);
			
			bool result=MySqlExecute(DB, sql);
			
			bool updateResult=MySqlExecute(DB, updateSql);
			 
			if(result==false){
			 
				Print ("获取数据结果:"+result); 
			}
			
			if(updateResult==false){
			 
				Print ("更新策略数据结果:"+result); 
			}
        
        
        
       }
        
       MySqlDisconnect(DB);
    


  }
//+------------------------------------------------------------------+
