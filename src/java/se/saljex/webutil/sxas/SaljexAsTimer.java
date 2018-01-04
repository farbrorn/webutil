/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.webutil.sxas;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Date;
import java.util.logging.Logger;
import javax.annotation.Resource;
import javax.ejb.Schedule;
import javax.ejb.Stateless;
import javax.ejb.LocalBean;
import javax.sql.DataSource;
import se.saljex.sxlibrary.SXUtil;

/**
 *
 * @author ulf
 */
@Stateless
@LocalBean
public class SaljexAsTimer {
	@Resource(mappedName = "sxsuperuser")
	private DataSource sxsuperuser;

    @Schedule(dayOfWeek = "Mon-Fri", month = "*", hour = "6-18", dayOfMonth = "*", year = "*", minute = "*/15", second = "0")
    
    public void updateLagersaldonFrom() {
        Logger.getLogger("sx-logger").info("SaljexAsTimer.updateLagersaldon startad");
        Connection con=null;
        try {
            con = sxsuperuser.getConnection();
            String q=
"delete from sxfakt.rorder where kundnr='Y0001';\n" +
"insert into sxfakt.rorder (kundnr, artnr, id, namn, pris, rab, rest, enh, konto, netto, marke, levnr, levdat, levbestdat, lagernr, stjid)\n" +
"select 'Y0001', a.nummer, 1, a.namn, 0, 0, sum(o2.best), a.enhet, '', 0, '', a.lev, null, null, 0, 0\n" +
"from sxasfakt.order1 o1 join sxasfakt.order2 o2 on o1.ordernr=o2.ordernr join sxasfakt.artikel a on a.nummer=o2.artnr --join sxasfakt.kund k on k.nummer=o1.kundnr\n" +
"where o1.status in ('Sparad','Utskr') and o1.kundnr <> '055561610'\n" +
"group by a.nummer;\n" +
                    
"create temporary table o on commit drop as \n" +
"select lagernr, artnr, sum(iorder) as iorder, sum(ibest) as ibest from (\n" +
"select o1.lagernr as lagernr, o2.artnr as artnr, sum(o2.best) as iorder, 0 as ibest from sxfakt.order1 o1 join sxfakt.order2 o2 on o1.ordernr=o2.ordernr where o1.lagernr=0 group by o1.lagernr, o2.artnr\n" +
"union \n" +
"select lagernr, artnr, sum(rest) as iorder, 0 as ibest from sxfakt.rorder where lagernr=0 group by lagernr, artnr\n" +
"union\n" +
"select b1.lagernr, b2.artnr, 0 as iorder, sum(b2.best) as ibest  from sxfakt.best1 b1 join sxfakt.best2 b2 on b1.bestnr=b2.bestnr group by b1.lagernr, b2.artnr\n" +
") bbb join sxfakt.artikel a on a.nummer=bbb.artnr where lagernr=0 group by lagernr, artnr;\n" +
"\n" +
"\n" +
"insert into sxfakt.lager (artnr, lagernr, ilager, bestpunkt, maxlager, best, iorder, lagerplats, hindrafilialbest) \n" +
"select o.artnr, o.lagernr, 0, 0, 0, o.ibest, o.iorder, '', 0  from o where not exists (select * from sxfakt.lager l where l.lagernr=o.lagernr and l.artnr=o.artnr); \n" +
"\n" +
"update sxfakt.lager set iorder=0, best=0 where lagernr=0;\n" +
"\n" +
"update sxfakt.lager l set\n" +
"iorder=o.iorder, best=o.ibest\n" +
"from o where l.lagernr=o.lagernr  and l.artnr = o.artnr;\n" +
"";                    
            Statement stm = con.createStatement();
            stm.setQueryTimeout(60);
            stm.executeUpdate(q);
            Logger.getLogger("sx-logger").info("SaljexAsTimer.updateLagersaldon slutförd");
        } catch (SQLException e) { Logger.getLogger("sx-logger").info("Fel i SaljexAsTimer.updateLagersaldon: " + e.toString()); }
        finally { try { con.close(); } catch ( Exception e) {} }
        
    }

    // Add business logic below. (Right-click in editor and choose
    // "Insert Code > Add Business Method")
}
