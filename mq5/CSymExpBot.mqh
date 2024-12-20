//+------------------------------------------------------------------+
//|                                                   CSymExpBot.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

//#include <Generic\HashMap.mqh>
#include <Arrays\ArrayString.mqh>
//#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayDouble.mqh>
//#include <Arrays\ArrayLong.mqh>
//#include <Trade\TerminalInfo.mqh>
#include <Trade\DealInfo.mqh>
//#include <Charts\Chart.mqh>
//#include <Math\Stat\Math.mqh>
#include <Trade\OrderInfo.mqh>

#include <ChartObjects\ChartObjectsFibo.mqh>

//#include "Include\DKStdLib\Common\DKStdLib.mqh"

//#include "Include\DKStdLib\Common\CDKString.mqh"
//#include "Include\DKStdLib\Logger\CDKLogger.mqh"
//#include "Include\DKStdLib\TradingManager\CDKPositionInfo.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLStep.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLStepSpread.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLBE.mqh"
//#include "Include\DKStdLib\Drawing\DKChartDraw.mqh"


#include "Include\DKStdLib\Common\CDKString.mqh"
#include "Include\DKStdLib\Common\DKDatetime.mqh"
#include "Include\DKStdLib\Arrays\CDKArrayString.mqh"
#include "Include\DKStdLib\History\DKHistory.mqh"
#include "Include\DKStdLib\Bot\CDKBaseBot.mqh"

#include "CSymExpBotInputs.mqh"


class CSymExpBot : public CDKBaseBot<CSymExpBotInputs> {
public: 

protected:
  CArrayInt                  TFIndHndl;
  CArrayInt                  TFTrend;  
  CArrayInt                  TFTrendDepth; 

public:
  // Constructor & init
  void                       CSymExpBot::CSymExpBot(void);
  void                       CSymExpBot::~CSymExpBot(void);
  void                       CSymExpBot::InitChild();
  bool                       CSymExpBot::Check(void);

  // Event Handlers
  void                       CSymExpBot::OnDeinit(const int reason);
  void                       CSymExpBot::OnTick(void);
  void                       CSymExpBot::OnTrade(void);
  void                       CSymExpBot::OnTimer(void);
  double                     CSymExpBot::OnTester(void);
  void                       CSymExpBot::OnBar(void);
  
  void                       CSymExpBot::OnOrderPlaced(ulong _order);
  void                       CSymExpBot::OnOrderModified(ulong _order);
  void                       CSymExpBot::OnOrderDeleted(ulong _order);
  void                       CSymExpBot::OnOrderExpired(ulong _order);
  void                       CSymExpBot::OnOrderTriggered(ulong _order);

  void                       CSymExpBot::OnPositionOpened(ulong _position, ulong _deal);
  void                       CSymExpBot::OnPositionStopLoss(ulong _position, ulong _deal);
  void                       CSymExpBot::OnPositionTakeProfit(ulong _position, ulong _deal);
  void                       CSymExpBot::OnPositionClosed(ulong _position, ulong _deal);
  void                       CSymExpBot::OnPositionCloseBy(ulong _position, ulong _deal);
  void                       CSymExpBot::OnPositionModified(ulong _position);  
  
  
  
  // Bot's logic
  void                       CSymExpBot::StringTFListToArr(string _str, ENUM_TIMEFRAMES& _arr[]);
  int                        CSymExpBot::FindTFInArray(ENUM_TIMEFRAMES _tf, ENUM_TIMEFRAMES& _arr[]);
  
  string                     CSymExpBot::TrendToString(const int _trend);
  bool                       CSymExpBot::UpdateTrendByTF(const int _tf_idx, const bool _show_notifications = true);
  bool                       CSymExpBot::UpdateTrendOnNewBar(const bool _show_notifications = true);
    
  void                       CSymExpBot::UpdateComment(const bool _ignore_interval = false);
  
};

//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
void CSymExpBot::CSymExpBot(void) {
}

//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
void CSymExpBot::~CSymExpBot(void){
}

//+------------------------------------------------------------------+
//| Inits bot
//+------------------------------------------------------------------+
void CSymExpBot::InitChild() {
  TFIndHndl.Clear();
  TFTrend.Clear();
  TFTrendDepth.Clear();
  for(int i=0;i<ArraySize(Inputs.TFList);i++){
    int hndl = iCustom(Sym.Name(), Inputs.TFList[i], "Market\\Structure Blocks");
    if(hndl > 0) {
      TFTrend.Add(0);
      TFTrendDepth.Add(0);
      TFIndHndl.Add(hndl);
      NewBarDetector.AddTimeFrame(Inputs.TFList[i]);
    }
    else
      Logger.Critical(StringFormat("%s/%d: Ошибка инициализации индикатора 'Structure Blocks': TF=%s",
                                   __FUNCTION__, __LINE__,
                                   TimeframeToString(Inputs.TFList[i])));
  }
  NewBarDetector.OptimizedCheckEnabled = false;
  NewBarDetector.ResetAllLastBarTime();
  
  // Alerts & Notifications
  StringTFListToArr(Inputs.ALR_TF_PUP_TF_AlarmList, Inputs.TFAlarmList);
  StringTFListToArr(Inputs.ALR_TF_MOB_TF_MobileList, Inputs.TFNotificationList);
    
  // Window pos
  string var_name = StringFormat("%s_WND_LEFT", Logger.Name);
  int left = (GlobalVariableCheck(var_name)) ? (int)GlobalVariableGet(var_name) : 80;
  
  var_name = StringFormat("%s_WND_TOP", Logger.Name);
  int top = (GlobalVariableCheck(var_name)) ? (int)GlobalVariableGet(var_name) : 80;
    
  CommentWnd.Move(left, top);
  
  UpdateTrendOnNewBar(false);
  UpdateComment(true);
}

//+------------------------------------------------------------------+
//| Check bot's params
//+------------------------------------------------------------------+
bool CSymExpBot::Check(void) {
  if(!CDKBaseBot<CSymExpBotInputs>::Check())
    return false;

  bool res = true;
  // IndStrucBlockHndl
  if(ArraySize(Inputs.TFList) != TFIndHndl.Total()) {
    Logger.Critical("Ошибка инициализации индикатора 'Structure Block' для всех ТФ", true);
    res = false;
  }  
  
  return res;
}


//+------------------------------------------------------------------+
//| OnDeinit Handler
//+------------------------------------------------------------------+
void CSymExpBot::OnDeinit(const int reason) {
  GlobalVariableSet(StringFormat("%s_WND_LEFT", Logger.Name), CommentWnd.Left());
  GlobalVariableSet(StringFormat("%s_WND_TOP", Logger.Name), CommentWnd.Top());
}

//+------------------------------------------------------------------+
//| OnTick Handler
//+------------------------------------------------------------------+
void CSymExpBot::OnTick(void) {
  //CDKBaseBot<CSymExpBotInputs>::OnTick(); // Check new bar and show comment
    
  if(UpdateTrendOnNewBar())
    UpdateComment(true);
}

//+------------------------------------------------------------------+
//| OnBar Handler
//+------------------------------------------------------------------+
void CSymExpBot::OnBar(void) {
  UpdateComment();
}

//+------------------------------------------------------------------+
//| OnTrade Handler
//+------------------------------------------------------------------+
void CSymExpBot::OnTrade(void) {
  CDKBaseBot<CSymExpBotInputs>::OnTrade(); 
}

//+------------------------------------------------------------------+
//| OnTimer Handler
//+------------------------------------------------------------------+
void CSymExpBot::OnTimer(void) {
  CDKBaseBot<CSymExpBotInputs>::OnTimer();
}

//+------------------------------------------------------------------+
//| OnTester Handler
//+------------------------------------------------------------------+
double CSymExpBot::OnTester(void) {
  return 0;
}

void CSymExpBot::OnOrderPlaced(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CSymExpBot::OnOrderModified(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CSymExpBot::OnOrderDeleted(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CSymExpBot::OnOrderExpired(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CSymExpBot::OnOrderTriggered(ulong _order){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CSymExpBot::OnPositionTakeProfit(ulong _position, ulong _deal){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CSymExpBot::OnPositionClosed(ulong _position, ulong _deal){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CSymExpBot::OnPositionCloseBy(ulong _position, ulong _deal){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

void CSymExpBot::OnPositionModified(ulong _position){
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}  
  
//+------------------------------------------------------------------+
//| OnPositionOpened
//+------------------------------------------------------------------+
void CSymExpBot::OnPositionOpened(ulong _position, ulong _deal) {
  //Logger.Info(StringFormat("%s/%d", __FUNCTION__, __LINE__));
}

//+------------------------------------------------------------------+
//| OnStopLoss Handler
//+------------------------------------------------------------------+
void CSymExpBot::OnPositionStopLoss(ulong _position, ulong _deal) {

}


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Bot's logic
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Updates comment
//+------------------------------------------------------------------+
void CSymExpBot::UpdateComment(const bool _ignore_interval = false) {
  ClearComment();
  
  for(int i=0;i<TFIndHndl.Total();i++) {
    string trend_label = StringFormat("%s%s", 
                                      TimeframeToString(Inputs.TFList[i]),
                                      (Inputs.UI_TRD_ENB_TrendDepth_Enabled && TFTrendDepth.At(i) > 1) ? "*" + IntegerToString(TFTrendDepth.At(i)) : "");

    color clr = Inputs.UI_COL_FLT_Color_Flat;
    if(TFTrend.At(i) > 0) clr = Inputs.UI_COL_UP_Color_Up;
    else if(TFTrend.At(i) < 0) clr = Inputs.UI_COL_DWN_Color_Down;
    
    AddCommentLine(trend_label, 0, clr);     
  }

  ShowComment(_ignore_interval);     
}

//+------------------------------------------------------------------+
//| Trend to Str
//+------------------------------------------------------------------+
string CSymExpBot::TrendToString(const int _trend){
  string res = "ФЛЭТ";
  if(_trend > 0) res = "ВОСХОДЯЩИЙ";
  if(_trend < 0) res = "НИЗХОДЯЩИЙ";
  
  return res;
}

//+------------------------------------------------------------------+
//| Update trend with _tf_idx
//+------------------------------------------------------------------+
bool CSymExpBot::UpdateTrendByTF(const int _tf_idx, const bool _show_notifications = true) {
  int trend_curr = TFTrend.At(_tf_idx);
  
  double trend[];
  double depth[];
  if(CopyBuffer(TFIndHndl.At(_tf_idx), 4, 0, 1, trend) < 0 ||
     CopyBuffer(TFIndHndl.At(_tf_idx), 5, 0, 1, depth) < 0)
    return false;
    
  int trend_depth = (int)depth[0];
  int trend_new = 0;
  if(trend_depth > 1) 
    trend_new = (trend[0] == 0) ? +1 : -1;

  TFTrend.Update(_tf_idx, trend_new);
  TFTrendDepth.Update(_tf_idx, trend_depth);
  
  if(DEBUG >= Logger.Level)
    Logger.Debug(StringFormat("%s/%d: Проверка тренда: SYM=%s; TF=%s; %s->%s",
                              __FUNCTION__, __LINE__,
                             Sym.Name(),
                             TimeframeToString(Inputs.TFList[_tf_idx]),
                             TrendToString(trend_curr), TrendToString(trend_new)));  
    
  if(trend_curr != trend_new) {
    string msg = StringFormat("Тренд %s на %s изменился %s->%s",
                             TimeframeToString(Inputs.TFList[_tf_idx]),
                             Sym.Name(),
                             TrendToString(trend_curr), TrendToString(trend_new));
                             
    
    if(_show_notifications && FindTFInArray(Inputs.TFList[_tf_idx], Inputs.TFNotificationList) >= 0)
      SendNotification(Logger.Name + ": " + msg);
    
    bool show_alarm = _show_notifications && FindTFInArray(Inputs.TFList[_tf_idx], Inputs.TFAlarmList) >= 0;
    Logger.Info(StringFormat("%s/%d: %s",
                             __FUNCTION__, __LINE__, msg), 
                show_alarm);  
  }
  
  return trend_curr != trend_new;
}

//+------------------------------------------------------------------+
//| Update indicator with _tf_idx
//+------------------------------------------------------------------+
bool CSymExpBot::UpdateTrendOnNewBar(const bool _show_notifications = true) {
  bool changed = false;
  for(int i=0;i<TFIndHndl.Total();i++)
    if(NewBarDetector.CheckNewBarAvaliable(Inputs.TFList[i])) 
      changed = UpdateTrendByTF(i, _show_notifications) || changed;

  return changed;
}

//+------------------------------------------------------------------+
//| Parse _str
//+------------------------------------------------------------------+
void CSymExpBot::StringTFListToArr(string _str, ENUM_TIMEFRAMES& _arr[]) {
  // Alerts & Notifications
  ArrayFree(_arr);
  
  CDKString str;
  CArrayString tfs;
  str.Assign(_str);
  str.Split(";", tfs);
  for(int i=0;i<tfs.Total();i++) {
    ENUM_TIMEFRAMES tf = StringToTimeframe(tfs.At(i));
    if(StringFind(_str, TimeframeToString(tf)) < 0) continue;
    
    ArrayResize(_arr, ArraySize(_arr)+1);
    _arr[ArraySize(_arr)-1] = tf;
  }  
}

//+------------------------------------------------------------------+
//| Find tf in _arr
//+------------------------------------------------------------------+
int CSymExpBot::FindTFInArray(ENUM_TIMEFRAMES _tf, ENUM_TIMEFRAMES& _arr[]) {
  for(int i=0;i<ArraySize(_arr);i++)
    if(_arr[i] == _tf)
      return i;
     
  return -1;
}