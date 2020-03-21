/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.webutil.sxas;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.logging.Logger;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

/**
 *
 * @author ulf
 */
public class UpdateArtiklarRunnable implements Runnable {
        @Override
    public void run() {
        Connection con=null;
        Logger.getLogger("sx-logger").info("sxas.UpdateArtiklarRunnable Run start");
        try {
            Context initContext = new InitialContext();
            DataSource sxadm = (DataSource) initContext.lookup("sxadm");
            con=sxadm.getConnection();
            Statement stm = con.createStatement();
            stm.setQueryTimeout(60);
            stm.execute("select updatesxasartiklar()");
        } catch(Exception e) {
            Logger.getLogger("sx-logger").info("sxas.UpdateArtiklarRunnable kan inte överföra lagerdsaldo: " + e.getMessage()); 
            e.printStackTrace();
        }
        finally {
            try { con.close(); } catch (Exception e) {}
            Logger.getLogger("sx-logger").info("sxas.UpdateArtiklarRunnable Run klar");
        }
    }
    
    
}
/*
                    "create temporary table tempart on commit drop as select * from sxfakt.artikel a where  a.nummer not in (select nummer from sxasfakt.artikel);\n" +
"insert into sxasfakt.artikel select * from tempart;\n" +
"update sxasfakt.artikel set lev = 'SX', utrab = case when utrab = 40 then 45 else utrab end , rsk=''  where nummer in (select nummer from tempart);\n" +
"\n" +
"create temporary table tempvaluta on commit drop as select coalesce(kurs,0) as nok from sxfakt.valuta where valuta='NOK';\n" +
"\n" +
"\n" +
"update sxasfakt.artikel a set \n" +
"utpris = (select round((utpris*case when utrab <=5 then (select 1/nok*1.1 from tempvaluta) else 1.1 end)::numeric,case when utpris > 60 then 0 else case when utpris > 20 then 1 else 2 end end) from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"inpris = (select round((inpris/0.95/(select nok from tempvaluta))::numeric,2) from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"staf_pris1 = (select round((staf_pris1*case when utrab <=5 then (select 1/nok*1.1 from tempvaluta) else 1.1 end)::numeric,case when staf_pris1 > 60 then 0 else case when staf_pris1 > 20 then 1 else 2 end end) from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"staf_pris2 = (select round((staf_pris2*case when utrab <=5 then (select 1/nok*1.1 from tempvaluta) else 1.1 end)::numeric,case when staf_pris2 > 60 then 0 else case when staf_pris2 > 20 then 1 else 2 end end) from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"staf_antal1 = (select staf_antal1 from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"staf_antal2 = (select staf_antal2 from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"utgattdatum = (select utgattdatum from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"inpdat = (select inpdat from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"prisdatum = (select prisdatum from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"inp_frakt = (select inp_frakt from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"inp_fraktproc = (select inp_fraktproc from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"inp_miljo = (select inp_miljo from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"enhet = (select enhet from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"rab = (select rab from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"utrab = (select case when utrab=40 then 45 else utrab end from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"rabkod = (select rabkod from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"kod1 = (select kod1 from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"vikt = (select vikt from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"volym = (select volym from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"struktnr = (select struktnr from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"forpack = (select forpack from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"kop_pack = (select kop_pack from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"cn8 = (select cn8 from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"fraktvillkor = (select fraktvillkor from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"dagspris = (select dagspris from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"hindraexport = (select hindraexport from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"minsaljpack = (select minsaljpack from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"storpack = (select storpack from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"prisgiltighetstid = (select prisgiltighetstid from sxfakt.artikel aa where aa.nummer=a.nummer),\n" +
"bildartnr = (select bildartnr from sxfakt.artikel aa where aa.nummer=a.nummer)\n" +
"where a.nummer in (select nummer from sxfakt.artikel) and a.lev='SX' ;\n" +
"\n" +
"\n" +
"\n" +
"\n" +
"\n" +
"\n" +
"\n" +
"\n" +
"delete from sxfakt.nettopri where lista='SXAS';\n" +
"insert into sxfakt.nettopri (select 'SXAS', nummer, ROUND(CAST((inpris*(1-rab/100)*(1+inp_fraktproc/100)+inp_frakt+inp_miljo)/case when nummer like 'XN*%' then 0.95 else 0.84 end as numeric),2), '', current_date from sxfakt.artikel \n" +
"where inpris>0 \n" +
");\n" +
"--uppdatera nettorpislistan till AB\n" +
"delete from sxasfakt.nettopri where lista='NETTO0';\n" +
"insert into sxasfakt.nettopri (select 'NETTO0', nummer, ROUND(CAST((inpris*(1-rab/100)*(1+inp_fraktproc/100)+inp_frakt+inp_miljo) as numeric),2), '', current_date from sxasfakt.artikel \n" +
"where inpris>0 \n" +
");\n" +
""; 
                    */                    
