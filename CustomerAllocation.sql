select IDTurnOver, T.PnL_Code, PnL_Country, VAT_CODE, Customer_Code, PeriodYear, PeriodMonth, Activity,  TurnOverAmount, TotalPNL, TotalPNLHFM, TotalEbitda , PctjeEbitda, DirectEbitdaa, 
  TotalEbitdaDirectCountry, TotalEbitdaCountry, TotalRevenueCountry, TotalEbitdaCountryMinusDirectEbitdaaOfCountry,  PctjeCountry, IndirectEbitaCountry,
  TotalRevenueDivision, TotalEbitdaDivision, PctjeDivision, IndirectEbitaDivision, DirectEbitdaa+ IndirectEbitaCountry+IndirectEbitaDivision as TotalEbitdaNet
  from 
 (
 SELECT IDTurnOver, T.PnL_Code, pnl.PnL_Country, VAT_CODE, Customer_Code, PeriodYear, PeriodMonth, Activity, TurnOverAmount/1000 as TurnOverAmount
 -- 1 Etapa PNL
  ,[dbo].[Get_PNL_Revenue_ByPeriod] (T.PnL_Code ,PeriodYear,PeriodMonth) as TotalPNL 
  ,[dbo].Get_PNL_RevenueHFM_ByPeriod (T.PnL_Code ,PeriodYear,PeriodMonth) as TotalPNLHFM --Para Comparar Revenue entre Customer y HFM
  ,[dbo].Get_PNL_Ebitda_ByPeriod (T.PnL_Code ,PeriodYear,PeriodMonth) as TotalEbitda
  ,abs([dbo].Get_PNL_Ebitda_ByPeriod (T.PnL_Code ,PeriodYear,PeriodMonth))/[dbo].[Get_PNL_Revenue_ByPeriod] (T.PnL_Code ,PeriodYear,PeriodMonth) as PctjeEbitda
  , (TurnOverAmount/1000) * ([dbo].Get_PNL_Ebitda_ByPeriod (T.PnL_Code ,PeriodYear,PeriodMonth))/[dbo].[Get_PNL_Revenue_ByPeriod] (T.PnL_Code ,PeriodYear,PeriodMonth) as DirectEbitdaa
  --2 Etapa Contry
  , dbo.Get_Country_Central_Revenue_ByPeriod(pnl.PnL_Country, PeriodYear,PeriodMonth) as TotalRevenueCountry
  , dbo.Get_Country_Central_Ebitda_ByPeriod(pnl.PnL_Country, PeriodYear,PeriodMonth) as TotalEbitdaCountry
  , dbo.Get_Country_Central_Ebitda_ByPeriod(pnl.PnL_Country, PeriodYear,PeriodMonth)+ (TurnOverAmount/1000) * ([dbo].Get_PNL_Ebitda_ByPeriod (T.PnL_Code ,PeriodYear,PeriodMonth))/[dbo].[Get_PNL_Revenue_ByPeriod] (T.PnL_Code ,PeriodYear,PeriodMonth) as TotalEbitdaDirectCountry
  , dbo.Get_Country_Central_Ebitda_ByPeriod(pnl.PnL_Country, PeriodYear,PeriodMonth) - dbo.Get_Country_Direct_Ebitda_ByPeriod(pnl.PnL_Country, PeriodYear,PeriodMonth) as TotalEbitdaCountryMinusDirectEbitdaaOfCountry --Calculate
  ,  (TurnOverAmount/1000)/ dbo.Get_Country_Central_Revenue_ByPeriod(pnl.PnL_Country, PeriodYear,PeriodMonth) as PctjeCountry
  ,dbo.Get_Country_Central_Ebitda_ByPeriod(pnl.PnL_Country, PeriodYear,PeriodMonth)* (TurnOverAmount/1000)/ dbo.Get_Country_Central_Revenue_ByPeriod(pnl.PnL_Country, PeriodYear,PeriodMonth) as IndirectEbitaCountry
  --3 Etapa Division
  , dbo.Get_Division_Central_Revenue_ByPeriod(PeriodYear,PeriodMonth) as TotalRevenueDivision
  , dbo.Get_Division_Central_Ebitda_ByPeriod(PeriodYear,PeriodMonth) as TotalEbitdaDivision  
  , (TurnOverAmount/1000)/dbo.Get_Division_Central_Revenue_ByPeriod(PeriodYear,PeriodMonth)  as PctjeDivision
  ,(TurnOverAmount/1000)*(TurnOverAmount/1000)/dbo.Get_Division_Central_Revenue_ByPeriod(PeriodYear,PeriodMonth) as IndirectEbitaDivision
  ,cy
  FROM TurnOverByCustomer T left join PNL on T.PnL_Code=pnl.PnL_Code
  where 1=1
  and pnl.PnL_SitevsCentral<>'P&L of the sites'
  and T.PnL_Code='SN7210' 
  and PeriodYear=2017 
  and PeriodMonth=1  
  ) T
