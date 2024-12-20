//+------------------------------------------------------------------+
//|                                             CSymExpBotInputs.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

struct CSymExpBotInputs {
  // USER INPUTS
  bool                     UI_TRD_ENB_TrendDepth_Enabled;                   // UI_TRD_ENB: Показать грубину тренда  

  color                    UI_COL_FLT_Color_Flat;                           // UI_COL_FLT: Цвет флета
  color                    UI_COL_UP_Color_Up;                              // UI_COL_UP: Цвет бычего тренда
  color                    UI_COL_DWN_Color_Down;                           // UI_COL_DWN: Цвет медвежьего тренда  
  
  string                   ALR_TF_PUP_TF_AlarmList;                         // ALR_TF_PUP: Таймфремы с оповещенями в терминал (';' раздлеитель)
  string                   ALR_TF_MOB_TF_MobileList;                        // ALR_TF_MOB: Таймфремы с оповещенями на телефон (';' раздлеитель)

  
  // GLOBAL VARS
  ENUM_TIMEFRAMES          TFList[];
  ENUM_TIMEFRAMES          TFAlarmList[];
  ENUM_TIMEFRAMES          TFNotificationList[];

  // CONSTRUCTOR  
  void                     CSymExpBotInputs() {
    ENUM_TIMEFRAMES src[] = {PERIOD_D1, PERIOD_H4, PERIOD_H1, PERIOD_M15, PERIOD_M5, PERIOD_M3, PERIOD_M1};
    ArrayInsert(TFList, src, 0);                                
  };
};
