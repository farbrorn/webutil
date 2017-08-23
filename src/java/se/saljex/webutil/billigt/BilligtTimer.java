/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.webutil.billigt;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.Date;
import java.util.logging.Logger;
import javax.annotation.Resource;
import javax.ejb.Schedule;
import javax.ejb.Stateless;
import javax.ejb.LocalBean;
import javax.sql.DataSource;

/**
 *
 * @author ulf
 */
@Stateless
@LocalBean
public class BilligtTimer {
	@Resource(mappedName = "sxsuperuser")
	private DataSource sxsuperuser;

    @Schedule(dayOfWeek = "Mon-Fri", month = "*", hour = "21", dayOfMonth = "*", year = "*", minute = "0", second = "0")    
    public void uppdateraPriser() {
        //Logger.getLogger("sx-logger").severe("SQL-Fel:" + e.getMessage()); e.printStackTrace();
        Logger.getLogger("sx-logger").info("BilligtTimer - Uppdatera Priser - Startad");
        Connection con=null;
        try {
            con = sxsuperuser.getConnection();
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
"); " +
"update bvfakt.artikel ba set inpdat=current_date, inpris = round(case when ba.inp_enhetsfaktor=0 then 1 else ba.inp_enhetsfaktor end * " +
"(select si.pris from sxfakt.nettopri si where lista='BILLIGT' and si.artnr=ba.bestnr)*100)/100 " +
"where ba.bestnr  in (select si2.artnr from sxfakt.nettopri si2 where si2.lista='BILLIGT'); ";

        con.createStatement().executeUpdate(q);
        } catch (SQLException e) {
            Logger.getLogger("sx-logger").severe("SQL-Fel: vid uppdatera priser - " + e.getMessage()); e.printStackTrace();
        } finally { try {con.close();} catch (Exception eee) {}}		
        
    }

}
