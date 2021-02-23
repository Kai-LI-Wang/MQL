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
    
   if(timestamp != time){
      timestamp = time;
      string TradingSignal =  position_signal();
      
      OntickCounter = OntickCounter + 1 ; 
      Print("Position signal = ", TradingSignal," ", IntegerToString(OntickCounter),", Time: ", TimeToString(time)); 
      OpenPosition(TradingSignal); 
      
      }      
       
  }

/*
void MA()
   {

     double SlowMArray[]; 
     static int SlowHandler = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_EMA, PRICE_CLOSE);
     CopyBuffer(SlowHandler, 0,1, 2, SlowMArray);
     ArraySetAsSeries(SlowMArray,true);
     
     double FastMArray[]; 
     static int FastHandler = iMA(_Symbol, PERIOD_CURRENT, 10, 0, MODE_EMA, PRICE_CLOSE);
   // copybuffer copy specified numbers in original array and assign the numbers in new specified array  
     CopyBuffer(FastHandler, 0,1, 2, FastMArray);
   // give the time index to the array  
     ArraySetAsSeries(FastMArray,true);
     
     
     if(FastMArray[0]>SlowMArray[0] && FastMArray[1]< SlowMArray[1] ){
         
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         // symbol_point is the smallest value of the quote price
         double SL1 = ask - 100*SymbolInfoDouble(_Symbol,SYMBOL_POINT);
         double TP1 = ask + 100*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         trade.Buy(0.01,_Symbol,ask, SL1,TP1, "This is long position."  );

     }
     
     if(FastMArray[0]<SlowMArray[0] && FastMArray[1]>SlowMArray[1] ){
         double Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         // symbol_point is the smallest value of the quote price
         double TP2 = Bid - 100*SymbolInfoDouble(_Symbol,SYMBOL_POINT);
         double SL2 = Bid + 100*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         trade.Sell(0.01,_Symbol,Bid, SL2 ,TP2, "This is short position.");         

     }
 
     Comment("\nSlowMArray1: ", SlowMArray[0], 
            "\nSlowMArray2: ",  SlowMArray[1],
            "\nFastMArray1: ", FastMArray[0],
            "\nFastMArray2: ",  FastMArray[1]);
   }
   
 */  
   
   
void OpenPosition(string Signal)

   { 
      //Print("Open Position start"); 
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
         
         //ArrayResize(Fast_Buffer_Array,Fast_MA_period);
         //ArrayResize(Slow_Buffer_Array,Fast_MA_period); 
         
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
            
            
            //Print("Day ", IntegerToString(x)," Ask_Open: ", DoubleToString(Ask_Open), " Ask_Close: ", DoubleToString(Ask_Close));
            double a = Ask_Open - Ask_Close; 
            //Print("Ask High-Low Price difference: ", DoubleToString(a));
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
         //int k = ArraySize(CurrentOpenPiceArray);
         //Print("Array size of CurrentOpenPiceArray = ", DoubleToString(k)); 
         
         
         double OpenCloseDifOne = fabs(CurrentOpenPiceArray[1]-CurrentClosePriceArray[1]);
         double OpenCloseDifTwo = fabs(CurrentOpenPiceArray[2]-CurrentClosePriceArray[2]);
         double OpenCloseDifThree = fabs(CurrentOpenPiceArray[3]-CurrentClosePriceArray[3]);
         
         
         double Mean = (OpenCloseDifOne+OpenCloseDifTwo+OpenCloseDifThree)/(ArraySize(CurrentOpenPiceArray)-1);
         
         
         //Print("Ticker: ",_Symbol, " Ask price: ", Ask, " Previous close day1: ", CurrentClosePriceArray[1], " Previous close day2: ", CurrentClosePriceArray[2]);
         //Print("Mean Price: ", DoubleToString(Mean));
         //Print("The signal in positon_signal is ", IntegerToString(signal));
         
         strategy_counter = strategy_counter + 1 ; 
         
         Print("OpenCloseDifOne = ", DoubleToString(OpenCloseDifOne), ", Mean = ", DoubleToString(Mean), ", Signal = ", IntegerToString(signal), " , Concecutive = ", IntegerToString(Concecutive)  );   
         //Print("OpenCloseDifOne = ", DoubleToString(OpenCloseDifOne), ", OpenCloseDifTwo = ", DoubleToString(OpenCloseDifTwo), ", OpenCloseDifThree = ", DoubleToString(OpenCloseDifThree), ", Mean = ", DoubleToString(Mean));
         
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
      
int VolatilityScreener()
   {
     
     double PriceArray[];  
     int TimePeriodSTD = 20;
     
     int NumOfPeriodPrice = CopyClose(_Symbol, PERIOD_CURRENT,0, TimePeriodSTD, PriceArray);      
     ArraySetAsSeries(PriceArray, true); 
     double LogReturn = 0;  
     double AverageReturn = 0;  
     int LogCounter = 0; 
     double PowSumUp = 0; 
     double Vol; 
     double RetArray[]; 
     
     for(int i = ArraySize(PriceArray)-1;i>=0; i = i-1)
      {
         LogCounter = LogCounter + 1; 
         double temp = MathLog(PriceArray[i]/PriceArray[i+1]);
         LogReturn = temp  + LogReturn; 
         RetArray[i] = temp; 
      } 
      
      AverageReturn = LogReturn/(ArraySize(PriceArray)-1); 
      
      for(int i = ArraySize(PriceArray)-1;i>=0; i = i-1)
         {
            PowSumUp = MathPow(RetArray[i] - AverageReturn, 2) + PowSumUp;  
         }
      
      
      Vol = PowSumUp/(ArraySize(RetArray)-1); 
      
      Print("Volatility", Vol);  
      
       
      
   }      