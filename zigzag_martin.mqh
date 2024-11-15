//+------------------------------------------------------------------+
//|                                                zigzag_martin.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <m5/交易类.mqh>
#include <m5/指标类.mqh>
class zigzag_martin
  {
private:
   交易类         交易;
   指标类         指标;
   int               zigzag_h;
   double            zigzag_z[][4];

public:
   string            symbol;
   long              magic_number;
   double            lot;
   double             sl_profits;
   double             close_point;//均价平点值
   double            point;//加单点值
   double            lot_percent;//手数比例
   double            doubles;//手数倍数
   int               orders_lit;//单数限制
   //---获取zigzag到数组值
   void              get_zigzag_z();
   //---平单条件
   bool              close_long();
   bool              close_short();
   //---开单条件
   bool              open_long_first();
   bool              open_long_next();
   bool              open_short_first();
   bool              open_short_next();

   //---工作函数
   void              working();

                     zigzag_martin();
                    ~zigzag_martin();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
zigzag_martin::zigzag_martin()
  {
   symbol = Symbol();
   magic_number = 12365;
   lot=0.01;
   point=100;
   lot_percent=1.1;
   doubles=0;
   orders_lit=20;
   close_point=300;//均价平点值
   sl_profits=0;//盈亏平单
   zigzag_h = 指标.插入ZigZag(symbol,PERIOD_CURRENT,12, 26,9);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
zigzag_martin::~zigzag_martin()
  {
  }
//+------------------------------------------------------------------+
//---获取zigzag值
//+------------------------------------------------------------------+
void zigzag_martin::get_zigzag_z()
  {
   指标.句柄取值重新排序(zigzag_h,symbol,PERIOD_CURRENT,5, zigzag_z);
  }
//+------------------------------------------------------------------+
void zigzag_martin::working()
  {
   get_zigzag_z();
//---做多
   bool open_long_first = open_long_first();
   bool open_long_next = open_long_next();
   bool close_long = close_long();
   bool close_short = close_short();
   /*
      if(close_long)
         交易.平多(symbol,magic_number);
      if(close_short)
         交易.平空(symbol,magic_number);*/

   if(open_long_first)
      交易.做多(symbol,lot,0,0,magic_number,"buy_first");
   if(open_long_next)
     {
      double lots = 交易.尾单马丁手数(symbol,magic_number,POSITION_TYPE_BUY,lot,lot_percent,doubles);
      交易.做多(symbol,lots,0,0,magic_number,"buy_next");
     }

//---做空

   bool open_short_first = open_short_first();
   bool open_short_next = open_short_next();

   if(open_short_first)
      交易.做空(symbol,lot,0,0,magic_number,"sell_first");
   if(open_short_next)
     {
      double lots = 交易.尾单马丁手数(symbol,magic_number,POSITION_TYPE_SELL,lot,lot_percent,doubles);
      交易.做空(symbol,lots,0,0,magic_number,"sell_next");
     }
  }
//+------------------------------------------------------------------+
bool      zigzag_martin::      close_long()
  {
   交易.总亏损平多(symbol,magic_number,sl_profits);
   交易.持仓均价平单(symbol,magic_number,POSITION_TYPE_BUY,close_point);

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool     zigzag_martin::   close_short()
  {
   交易.总亏损平空(symbol,magic_number,sl_profits);
   交易.持仓均价平单(symbol,magic_number,POSITION_TYPE_SELL,close_point);
   return false;
  }
//----------------------------
bool         zigzag_martin::     open_long_first()
  {
   int long_orders = 交易.持仓单数统计(symbol,magic_number,POSITION_TYPE_BUY);
   bool chk = long_orders==0&&zigzag_z[0][0]>0&&zigzag_z[0][3]==1.0
              &&(long)zigzag_z[0][2]==(long)iTime(symbol,PERIOD_CURRENT,0)
              &&TimeCurrent()>iTime(symbol,PERIOD_CURRENT,0)+PeriodSeconds(PERIOD_CURRENT)-2;
   return chk;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool          zigzag_martin::    open_long_next()
  {
   int long_orders = 交易.持仓单数统计(symbol,magic_number,POSITION_TYPE_BUY);
   bool chk = long_orders>0&&long_orders<orders_lit&&zigzag_z[0][0]>0&&zigzag_z[0][3]==1.0
              &&(long)zigzag_z[0][2]==(long)iTime(symbol,PERIOD_CURRENT,0)
              &&TimeCurrent()>iTime(symbol,PERIOD_CURRENT,0)+PeriodSeconds(PERIOD_CURRENT)-2
              &&交易.优势多加单点值(symbol,magic_number,point);
   return chk;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool         zigzag_martin::     open_short_first()
  {
   int short_orders = 交易.持仓单数统计(symbol,magic_number,POSITION_TYPE_SELL);
   bool chk = short_orders==0&&zigzag_z[0][0]>0&&zigzag_z[0][3]==2.0
              &&(long)zigzag_z[0][2]==(long)iTime(symbol,PERIOD_CURRENT,0)
              &&TimeCurrent()>iTime(symbol,PERIOD_CURRENT,0)+PeriodSeconds(PERIOD_CURRENT)-2;
   return chk;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool        zigzag_martin::      open_short_next()
  {
   int short_orders = 交易.持仓单数统计(symbol,magic_number,POSITION_TYPE_SELL);
   bool chk = short_orders>0&&short_orders<orders_lit&&zigzag_z[0][0]>0&&zigzag_z[0][3]==2.0
              &&(long)zigzag_z[0][2]==(long)iTime(symbol,PERIOD_CURRENT,0)
              &&TimeCurrent()>iTime(symbol,PERIOD_CURRENT,0)+PeriodSeconds(PERIOD_CURRENT)-2
              &&交易.优势空加单点值(symbol,magic_number,point);
   return chk;
  }
//+------------------------------------------------------------------+
