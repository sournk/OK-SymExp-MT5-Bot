//+------------------------------------------------------------------+
//|                                            OK-SymExp-MT5-Bot.mq5 |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#property script_show_inputs


#include "Include\DKStdLib\Logger\CDKLogger.mqh"
#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"


#include "CSymExpBot.mqh"


input  group                    "1. ИНТЕРФЕЙС (UI)"
input  bool                     Inp_UI_TRD_ENB_TrendDepth_Enabled                       = true;                              // UI_TRD_ENB: Показать грубину тренда
input  color                    Inp_UI_COL_FLT_Color_Flat                               = clrLightGray;                      // UI_COL_FLT: Цвет флэта
input  color                    Inp_UI_COL_UP_Color_Up                                  = clrLightGreen;                     // UI_COL_UP: Цвет бычьего тренда
input  color                    Inp_UI_COL_DWN_Color_Down                               = clrPink;                           // UI_COL_DWN: Цвет медвежьего тренда

input  group                    "2. ОПОВЕЩЕНИЯ (ALR)"
input  string                   Inp_ALR_TF_PUP_TF_AlarmList                             = "D1;H4;H1";                        // ALR_TF_PUP: ТФ с оповещениями в терминал (';' разд.)
input  string                   Inp_ALR_TF_MOB_TF_MobileList                            = "D1;H4;H1";                        // ALR_TF_MOB: ТФ с оповещениями на телефон (';' разд.)
       
input  group                    "3. MISCELLANEOUS (MSC)"
input  ulong                    Inp_MS_MGC                                              = 20241122;                          // MSC_MGC: Expert Adviser ID - Magic
sinput string                   Inp_MS_EGP                                              = "OKSE";                            // MSC_EGP: Expert Adviser Global Prefix
sinput LogLevel                 Inp_MS_LOG_LL                                           = LogLevel(INFO);                    // MSC_LOG_LL: Log Level
       string                   Inp_MS_LOG_FI                                           = "";                                // MSC_LOG_FI: Log Filter IN String (use ';' as sep)
       string                   Inp_MS_LOG_FO                                           = "";                                // MSC_LOG_FO: Log Filter OUT String (use ';' as sep)
       bool                     Inp_MS_COM_EN                                           = false;                             // MSC_COM_EN: Comment Enable (turn off for fast testing)
       uint                     Inp_MS_COM_IS                                           = 5;                                 // MSC_COM_IS: Comment Interval, Sec
       bool                     Inp_MS_COM_CW                                           = true;                              // MSC_COM_EW: Comment Custom Window
       
       long                     Inp_PublishDate                                         = 20241123;                           // Date of publish
       int                      Inp_DurationBeforeExpireSec                             = 5*24*60*60;                         // Duration before expire, sec
       

CSymExpBot                      bot;
CDKTrade                        trade;
CDKLogger                       logger;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){  
  logger.Init(Inp_MS_EGP, Inp_MS_LOG_LL);
  logger.FilterInFromStringWithSep(Inp_MS_LOG_FI, ";");
  logger.FilterOutFromStringWithSep(Inp_MS_LOG_FO, ";");
  
  //if (TimeCurrent() > StringToTime((string)Inp_PublishDate) + Inp_DurationBeforeExpireSec) {
  //  logger.Critical("Test version is expired", true);
  //  return(INIT_FAILED);
  //}  
  
  trade.Init(Symbol(), Inp_MS_MGC, 0, GetPointer(logger));

  CSymExpBotInputs inputs;
  inputs.UI_TRD_ENB_TrendDepth_Enabled = Inp_UI_TRD_ENB_TrendDepth_Enabled;
  
  inputs.UI_COL_FLT_Color_Flat         = Inp_UI_COL_FLT_Color_Flat;
  inputs.UI_COL_UP_Color_Up            = Inp_UI_COL_UP_Color_Up;
  inputs.UI_COL_DWN_Color_Down         = Inp_UI_COL_DWN_Color_Down;
  
  inputs.ALR_TF_PUP_TF_AlarmList       = Inp_ALR_TF_PUP_TF_AlarmList;
  inputs.ALR_TF_MOB_TF_MobileList      = Inp_ALR_TF_MOB_TF_MobileList;
  
  bot.CommentEnable      = Inp_MS_COM_EN;
  bot.CommentIntervalSec = Inp_MS_COM_IS;
  
  bot.Init(Symbol(), Period(), Inp_MS_MGC, trade, Inp_MS_COM_CW, inputs, GetPointer(logger));
  bot.SetFont("Courier New");
  bot.SetHighlightSelection(false);

  if (!bot.Check()) 
    return(INIT_PARAMETERS_INCORRECT);

  //EventSetTimer(Inp_MS_COM_IS);
  
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)  {
  EventKillTimer();
  bot.OnDeinit(reason);
}
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()  {
  bot.OnTick();
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()  {
  bot.OnTimer();
}

//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()  {
  bot.OnTrade();
}

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result) {
  bot.OnTradeTransaction(trans, request, result);
}

double OnTester() {
  return bot.OnTester();
}

void OnChartEvent(const int id,
                  const long& lparam,
                  const double& dparam,
                  const string& sparam) {
  bot.OnChartEvent(id, lparam, dparam, sparam);                                    
}