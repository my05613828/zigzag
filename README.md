//+------------------------------------------------------------------+
//|                                                     zigzag马丁.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include "zigzag_martin.mqh"
zigzag_martin cy;

input  long              _magic_number=66888;
input double _sl_profits = -1000;//总亏损平单
input double _close_point = 300;//均价平单点值
input   double            _lot=0.01;//手数

input  double            _point=100;//加单点值
input  double            _lot_percent=1.1;//手数比例
input  double            _doubles=0;//手数倍数
input  int               _orders_lit=20;//单数限制
//+------------------------------------------------------------------+
int OnInit()
  {

//--- create timer
   EventSetMillisecondTimer(500);
   cy.             magic_number=_magic_number;
   cy.sl_profits = _sl_profits;
   cy.close_point  =_close_point;
   cy.           lot=_lot;
   cy.           point=_point;//加单点值
   cy.           lot_percent=_lot_percent;//手数比例
   cy.           doubles=_doubles;//手数倍数
   cy.           orders_lit=_orders_lit;//单数限制
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
   cy.working();
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   OnTick();
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

  
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
