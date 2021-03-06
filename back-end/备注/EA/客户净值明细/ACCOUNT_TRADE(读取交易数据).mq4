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
      if(DB == -1) { 
      
          Print ("连接失败!错误信息: "+MySqlErrorDescription);
          
      }else { 
      
         
		  
			Print ("连接成功#",DB);
			
			double balance = AccountBalance();
			double margin = AccountMargin();
			double equity = AccountEquity();
			
			string updateSql = " update t_hpp_strategy_data SET i_balance = " + balance
			+ ", i_margin = " + margin 
			+ ", i_net_worth = " + equity 
			+ ", i_top_net_worth = GREATEST(i_net_worth, " + equity + ")"
			+ " where c_account = '" + AccountNumber() + "'";
			
			// Print(equity);
			
			bool updateResult=MySqlExecute(DB, updateSql);
			
			
			int i,hstTotal=OrdersHistoryTotal();
         for(i=0;i<hstTotal;i++)
         {
            //---- 检查选择结果
             if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
             {
               Print("访问历史表失败，错误信息：",GetLastError());
               break;
             }else{
                  string orderType = "";
                  string symbol = OrderSymbol();
                  string orderNo = OrderTicket();
                  string lots = OrderLots();
                  string profit = OrderProfit();
                  string sl = OrderStopLoss();
                  string tp = OrderTakeProfit();
                  string commission = OrderCommission();
                  string comment = OrderComment();
                  string stock_amount = OrderSwap();
                  string isProfit = OrderProfit() > 0 ? "Y" : "N";
                  string amount = OrderType() == 6 ? OrderProfit():(OrderCommission()+ OrderProfit()+ OrderSwap());
                  if(OrderType() == OP_BUY ){                  
                        orderType = "BUY";
                  }else if(OrderType() == OP_SELL ){                  
                        orderType = "SELL";
                  }else if(OrderType() == 6 && profit > 0){
                        orderType = "IN";
                  }else if(OrderType() == 6 && profit < 0){
                        orderType = "OUT";
                  }
                  
                  // Print("orderNo == " + orderNo+" orderType == "+orderType+" symbol == "+symbol+" lots == "+lots+" profit == "+profit);
                  string sql=" insert into t_hpp_strategy_trade(c_id, i_order_no, c_order_type, c_ordered, c_symbol, i_lots, i_sl, i_tp, i_open_price, d_open_time, i_close_price, d_close_time, c_closed, c_gain, c_gain_amount, c_calc_sum, c_account, d_create_at, i_change_amount, i_profit_amount, i_stock_amount,c_comment )"+
         			" select replace(uuid(), '-', ''),"+orderNo+",'"+orderType+"','Y','"+symbol+"',"+lots+","+sl+","+tp+","+OrderOpenPrice()+", '"+ OrderOpenTime()+"', "+OrderClosePrice()+", '" + OrderCloseTime()+"','Y','" + isProfit +"'," + amount +",'N','"+ AccountNumber()+"', '"+OrderOpenTime()+"', " + commission + "," + profit + "," + stock_amount + ",'" + comment + "'"
         			+ " from DUAL where not exists(select null from t_hpp_strategy_trade where i_order_no = " + orderNo + ")";
         			// Print( " select replace(uuid(), '-', ''),"+orderNo+",'"+orderType+"','Y','"+symbol+"',"+lots+","+sl+","+tp+","+OrderOpenPrice()+", '"+ OrderOpenTime()+"', "+OrderClosePrice()+", '" + OrderCloseTime()+"','Y','" + isProfit +"'," + (profit+commission) +",'N','"+ AccountNumber()+"', '"+OrderOpenTime()+"', " + commission + "," + profit + ",'" + comment + "'" );
         			bool result=MySqlExecute(DB, sql);
         			if(result==false){
         				Print ("获取数据结果:"+result); 
         			}
             }
             
             
         }			
         
        
       }
        
       MySqlDisconnect(DB);
    


  }
//+------------------------------------------------------------------+
