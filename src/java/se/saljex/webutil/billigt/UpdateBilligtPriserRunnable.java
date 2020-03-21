/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.webutil.billigt;

import java.sql.Connection;
import java.sql.Statement;
import java.util.logging.Logger;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;
import se.saljex.webutil.Const;
import se.saljex.webutil.InfoException;

/**
 *
 * @author ulf
 */
public class UpdateBilligtPriserRunnable implements Runnable {
        @Override
    public void run() {
        try { doTask(); }catch (Exception e) {}
    }

    public void doTask() throws InfoException {
        Connection con=null;
        Logger.getLogger("sx-logger").info("main.UpdateBilligtPriserRunnable start");
        try {
            con=Const.getSxAdmConnectionFromInitialContext();
            Statement stm = con.createStatement();
            stm.setQueryTimeout(60);
            String q = "delete from sxfakt.nettopri where lista='BILLIGT'; " +
"insert into sxfakt.nettopri (select 'BILLIGT', nummer,  " +
"ROUND	(CAST(( " +
"		(inpris*(1-rab/100)*(1+inp_fraktproc/100)+inp_frakt+case when kod1 like 'WG%' then 0 else inp_miljo end) " +
"		+ ( ( ( " +
"			case when rabkod <> 'NTO' and rabkod <> '' and rabkod is not null then " +
"				utpris * 0.6 " +
"			else " +
"				case when rabkod = 'NTO' and nummer like 'H%' then " +
"					utpris*0.7 " +
"				else " +
"					case when rabkod = 'NTO' then " +
"						utpris*0.95 " +
"					else " +
"						utpris " +
"					end " +
"				end " +
"			" +
"			end " +
"		- (inpris*(1-rab/100)*(1+inp_fraktproc/100)+inp_frakt+case when kod1 like 'WG%' then 0 else inp_miljo end))) * 0.45 ) ) " +
"	as numeric),2), '',  " +
"current_date from sxfakt.artikel  a " +
"where inpris>0 and utpris > 0 and case when rabkod <> 'NTO' then utpris*0.6 else utpris end > (inpris*(1-rab/100)*(1+inp_fraktproc/100)+inp_frakt+inp_miljo) " +
"and nummer not like '+%' " +
"); "+ 
"update sxfakt.nettopri n \n" +
"set datum=current_date, pris = coalesce((\n" +
"select  (a.inpris*(1-a.rab/100)*(1+a.inp_fraktproc/100)+a.inp_frakt+a.inp_miljo)/(1-b.marginal/100) pris\n" +
"from sxfakt.artikel a join sxfakt.bevisab_marginaler b on b.kod = rpad(a.rabkod,4) || rpad(coalesce(a.kod1,''),4) where a.inpris <> 0 and a.nummer=n.artnr), pris)\n" +
"where n.lista='BILLIGT' ";
            stm.execute(q);
        } catch(Exception e) {
            Logger.getLogger("sx-logger").info("main.UpdateBilligtPriserRunnable Fel:: " + e.getMessage()); 
            e.printStackTrace();
            throw new InfoException("Fel: " + e.getMessage());
        }
        finally {
            try { con.close(); } catch (Exception e) {}
            Logger.getLogger("sx-logger").info("main.UpdateBilligtPriserRunnable klar");
        }
    }
    
}
