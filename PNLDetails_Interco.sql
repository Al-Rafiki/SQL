SELECT *,
ISNULL((SELECT  SUM(PnLAmount)
FROM PNL_Details S
WHERE pnl_code LIKE 'M%' AND pnl_code <> 'M_LOGT'
AND S.PeriodYear=D.periodYear AND s.PeriodMonth=D.PeriodMonth and s.idaccount=D.idaccount and s.scenario=D.scenario and s.cy=D.cy
GROUP BY  PeriodYear, PeriodMonth, idaccount, scenario, cy),0) AS I
, [dbo].[Get_PNLDetails_Interco] (scenario, periodYear, PeriodMonth, idaccount) AS I2
FROM PNL_Details D
WHERE D.pnl_code LIKE 'M_LOGT'

BEGIN tran
UPDATE PNL_Details SET PnLAmountInterCo=[dbo].[Get_PNLDetails_Interco] (scenario, periodYear, PeriodMonth, idaccount)
--SELECT * --, [dbo].[Get_PNLDetails_Interco] (scenario, periodYear, PeriodMonth, idaccount) AS I2
FROM PNL_Details 
WHERE pnl_code LIKE 'M_LOGT'
--commit

BEGIN tran
UPDATE PNL_Details SET PnLAmountInterCo=0
--SELECT * --, [dbo].[Get_PNLDetails_Interco] (scenario, periodYear, PeriodMonth, idaccount) AS I2
FROM PNL_Details 
WHERE pnl_code LIKE 'M_LOGT' AND PnLAmountInterCo IS NULL
--commit

BEGIN tran
UPDATE PNL_Details SET PnLAmount=PnLAmountOriginal-PnLAmountInterCo
--SELECT * --, [dbo].[Get_PNLDetails_Interco] (scenario, periodYear, PeriodMonth, idaccount) AS I2
FROM PNL_Details 
WHERE pnl_code LIKE 'M_LOGT'
--commit

SELECT   PeriodYear, PeriodMonth, idaccount, scenario, cy, SUM(PnLAmount) AS D
FROM PNL_Details
WHERE pnl_code LIKE 'M%' AND pnl_code <> 'M_LOGT'
GROUP BY  PeriodYear, PeriodMonth, idaccount, scenario, cy


SELECT    SUM(PnLAmount) AS D
FROM PNL_Details
WHERE pnl_code LIKE 'M%' AND pnl_code <> 'M_LOGT'
GROUP BY  PeriodYear, PeriodMonth, idaccount, scenario, cy
