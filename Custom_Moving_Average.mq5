// comment \
/*
ctrl + N = open navigator
press F1 to see reference
*/

#include <Trade/Trade.mqh>
 
CTrade trade; 
int OntickCounter = 0; 
input int LookBackPeriod = 4; 
int strategy_counter = 0;
int LongTicket = 0;
int ShortTicket = 0; 
double CurrentPriceArray[]; 
int ShortPosition = 0; 
int LongPosition = 0; 


int OnInit(){
   
   Print("OnTnit");
   
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason){
   
   Print(reason); 
  }

void OnTick(){
  
   static datetime timestamp;
   datetime time = iTime(_Symbol,PERIOD_CURRENT, 0);
    
   if(timestamp != time)
      {
        timestamp = time;
        string TradingSignal =  position_signal();

        OntickCounter = OntickCounter + 1 ; 
        Print("Position signal = ", TradingSignal," ", IntegerToString(OntickCounter),", Time: ", TimeToString(time)); 
        OpenPosition(TradingSignal);    
      }             
  }


   
   
void OpenPosition(string Signal)

   { 
      double Ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      int TP_Pips = 100; 
      double position = 0.01; 
      double Long_SL;
      double Long_TP;
      double Short_SL; 
      double Short_TP; 
           
      if(Signal == "Long" && PositionsTotal() < 2)
         {
             
            if(LongPosition == 0)
               {               
                  Long_SL = Ask - TP_Pips*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
                  Long_TP = Ask + TP_Pips*SymbolInfoDouble(_Symbol, SYMBOL_POINT); 
                  trade.Buy(position, _Symbol, Ask,0,0,"This is long position");
                  LongPosition =  1 ; 
               }
               
            if(LongPosition == 1 && Ask <= Long_SL || Ask >= Long_TP)        
               {                 
                  trade.PositionClose(_Symbol,ULONG_MAX ); 
                  LongPosition =  0;              
               }                          
         } 
         
      if(Signal == "Short" && PositionsTotal() < 2 )
         {
             if(ShortPosition == 0)
               {
                  Short_SL = Bid + TP_Pips*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
                  Short_TP = Bid - TP_Pips*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
                  trade.Sell(position, _Symbol,Bid, 0,0,"This is short position" );
                  ShortPosition = 1;
               }            
             if(ShortPosition == 1 && Bid <= Short_TP || Bid >= Short_SL) 
               {
                  trade.PositionClose(_Symbol, ULONG_MAX); 
                  ShortPosition = 0; 
               }          
         }
      Print("Sell position = ", IntegerToString(LongPosition), ", Long Position = ", IntegerToString(ShortPosition) );
   }
   
   
string position_signal()
      {    
         double Fast_Buffer_Array[];
         double Slow_Buffer_Array[];
         double CurrentOpenPiceArray[];
         double CurrentClosePriceArray[]; 
         
         double Ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double AskLastLow = SymbolInfoDouble(_Symbol,SYMBOL_LASTLOW);
         double Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double BidLastHigh = SymbolInfoDouble(_Symbol, SYMBOL_LASTHIGH);
         
         int Fast_MA_period = 20; 
         int Slow_MA_period = 50; 
         

         
         int Fast_MA_handler = iMA(_Symbol, PERIOD_CURRENT,Fast_MA_period, 0,MODE_EMA, PRICE_CLOSE ); 
         CopyBuffer(Fast_MA_handler, 0, 0, 20,Fast_Buffer_Array);
         ArraySetAsSeries(Fast_Buffer_Array, true);
             
             
         int Slow_MA_handler = iMA(_Symbol, PERIOD_CURRENT, Slow_MA_period, 0, MODE_EMA, PRICE_CLOSE);
         CopyBuffer(Slow_MA_handler, 0, 0, 50,Slow_Buffer_Array);
         ArraySetAsSeries(Slow_Buffer_Array, true);
         int signal; 
  
         if( Ask > Fast_Buffer_Array[0] && Ask > Fast_Buffer_Array[1])
            signal = 1; 
         if( Bid < Slow_Buffer_Array[0] && Bid < Slow_Buffer_Array[1]) 
            signal = -1;    
         else 
            signal = 0;     
         
         double AskOpenClose[];
         ArrayResize(AskOpenClose, LookBackPeriod);     
         int Concecutive = 0; 
    
         for(int x = 1 ; x < LookBackPeriod; x=x+1)
         {
            double Ask_Open = iOpen(_Symbol, PERIOD_CURRENT, x);
            double Ask_Close = iClose(_Symbol, PERIOD_CURRENT, x);
            double a = Ask_Open - Ask_Close;
            AskOpenClose[x] = a; 
                        
            if(a > 0)
               {
                  Concecutive = Concecutive + 1;            
               }
            if(a < 0)
               {
                  Concecutive = Concecutive - 1;             
               }
         }
         
         if(Ask > AskLastLow)
            Concecutive = Concecutive + 1;
         if(Bid < BidLastHigh)
            Concecutive = Concecutive - 1; 
            
         ArrayResize(CurrentOpenPiceArray, LookBackPeriod);
         ArrayResize(CurrentClosePriceArray, LookBackPeriod);
         
         CopyOpen(_Symbol, _Period, 0, LookBackPeriod, CurrentOpenPiceArray);
         CopyClose(_Symbol, _Period, 0, LookBackPeriod,CurrentClosePriceArray);   
         ArraySetAsSeries(CurrentClosePriceArray, true ); 
         ArraySetAsSeries(CurrentOpenPiceArray, true ); 
      
         double OpenCloseDifOne = fabs(CurrentOpenPiceArray[1]-CurrentClosePriceArray[1]);
         double OpenCloseDifTwo = fabs(CurrentOpenPiceArray[2]-CurrentClosePriceArray[2]);
         double OpenCloseDifThree = fabs(CurrentOpenPiceArray[3]-CurrentClosePriceArray[3]);      
         double Mean = (OpenCloseDifOne+OpenCloseDifTwo+OpenCloseDifThree)/(ArraySize(CurrentOpenPiceArray)-1);
  
         strategy_counter = strategy_counter + 1 ; 
         
         Print("OpenCloseDifOne = ", DoubleToString(OpenCloseDifOne), ", Mean = ", DoubleToString(Mean), ", Signal = ", IntegerToString(signal), " , Concecutive = ", IntegerToString(Concecutive)  );   
        
         if(OpenCloseDifOne > Mean && signal == 1 && Concecutive >=2  )
         {
            LongTicket = LongTicket + 1 ; 
            Print("Open Long position ", IntegerToString(LongTicket),"th " );
            return("Long"); 
         }
          
         if(OpenCloseDifOne > Mean && signal == -1  && Concecutive <= -2 )
         {
            ShortTicket = ShortTicket + 1; 
            Print("Open Short position ", IntegerToString(ShortTicket), "th " );
            return("Short");
         }
            
         else  
            Print("No position ");         
          
         return ("No Trade!");     
      }     
      
