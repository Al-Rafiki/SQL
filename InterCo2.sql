 --Vinculados
 insert into HFMReport (PnL_Code, PeriodYear, PeriodMonth, IDConcept, Scenario, Cy, HFMAmount, FileName, FileTab, FileCell, LMU, LMD)

 Select 'M_LOGT' as PNL_code, PeriodYear, PeriodMonth, 31 AS IDConcept, Scenario, 'EUR' AS  Cy,  sum(InterCoAmount) as InterCoAmount 
 , 'Interco' FileName , 'Interco' as FileTab, null as  FileCell, 1 as LMU, getdate() as LMD
  from 
 (
    select I.PNL_code, I.PeriodYear, I.PeriodMonth, 3 AS IDConcept, I.Scenario, 'EUR' AS  Cy, 
   convert(money, HFMAmount) as HFMAmount, convert(money,Revenue) as InterCoAmount , convert(money, HFMAmount-Revenue) as Resta,
   'Interco' FileName , 'Interco' as FileTab, null as  FileCell, 1 as LMU, getdate() as LMD 
   -- I.PNL_code + convert(varchar(10),Year) + convert(varchar(10),Month) + convert(varchar(10),33) + I.Scenario
  from 
  (SELECT H.PNL_code, P.PnL_BU, H.PeriodYear, H.PeriodMonth, H.SCENARIO, Revenue 
	FROM HMReportINTERCO AS H
	left join PnL P on H.PnL_Code=P.PnL_Code --where Scenario <>'Actual2'
	) I
	left join  
  (
  SELECT  PeriodYear, PeriodMonth,   PnL_BU ,  H.Scenario, Sum(HFMAmount) as HFMAmount
  FROM HFMReport H
  left join PnL P on h.PnL_Code=p.PnL_Code 
  where IDConcept=31  and PeriodYear=2017 and PeriodMonth=6 and Scenario='BUSINESS'
  Group by  PeriodYear, PeriodMonth,  PnL_BU, H.Scenario) T 
  on T.PnL_BU=I.PnL_BU and T.PeriodYear=I.PeriodYear and T.PeriodMonth=I.Periodmonth and T.Scenario=I.SCENARIO 
  where 1=1 

  and I.PeriodYear=2017 and I.PeriodMonth=6 
  and i.PnL_Code<>'M_LOGT' 
  and I.Scenario='BUSINESS'

 --No vinculados
 Union
 
 select T.PnL_BU, T.PeriodYear, T.PeriodMonth, 31 AS IDConcept, T.Scenario, 'EUR' AS  Cy, 
   convert(money, HFMAmount) as InterCoAmount, convert(money,Revenue) as Revenue , convert(money, HFMAmount-Revenue) as Resta,
   'Interco' FileName , 'Interco' as FileTab, null as  FileCell, 1 as LMU, getdate() as LMD 
   -- I.PNL_code + convert(varchar(10),Year) + convert(varchar(10),Month) + convert(varchar(10),33) + I.Scenario
  from 

  (
  SELECT  PeriodYear, PeriodMonth,   PnL_BU ,  H.Scenario, Sum(HFMAmount) as HFMAmount
  FROM HFMReport H
  left join PnL P on h.PnL_Code=p.PnL_Code 
  where IDConcept=31  and PeriodYear=2017 and PeriodMonth=6 and Scenario='BUSINESS'
  Group by  PeriodYear, PeriodMonth,  PnL_BU, H.Scenario) T 

  left join

  (SELECT H.PNL_code, P.PnL_BU, H.PeriodYear, H.PeriodMonth, H.SCENARIO, Revenue
	FROM HMReportINTERCO AS H
	left join PnL P on H.PnL_Code=P.PnL_Code where  PeriodYear=2017 and PeriodMonth=6 and Scenario='BUSINESS'
	) I

  on T.PnL_BU=I.PnL_BU and T.PeriodYear=I.PeriodYear and T.PeriodMonth=I.Periodmonth and T.Scenario=I.SCENARIO 
  where 1=1 
  and i.PnL_BU is null
  ) T
  Group by  PeriodYear, PeriodMonth, Scenario
