/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.webutil.sxas;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Date;
import java.util.logging.Logger;
import javax.annotation.Resource;
import javax.ejb.Schedule;
import javax.ejb.Stateless;
import javax.ejb.LocalBean;
import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonReader;
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
        

        
    @Schedule(dayOfWeek = "Mon-Fri", month = "*", hour = "06", dayOfMonth = "*", year = "*", minute = "0", second = "0")
    public void updateValutaNOK() throws InfoException {
        Logger.getLogger("sx-logger").info("SaljexAsTimer.updateValutaNOK startad");
        Connection con=null;
        JsonReader jsonReader=null;
        BufferedReader valutaReader = null;
        try {    
            con = sxsuperuser.getConnection();
            URL valutaURL=new URL("https://free.currencyconverterapi.com/api/v5/convert?q=NOK_SEK&compact=y");
            valutaReader = new BufferedReader(new InputStreamReader(valutaURL.openStream()));
            jsonReader = Json.createReader(valutaReader);

            JsonObject jsonObject = jsonReader.readObject();
            Double dagensValuta = jsonObject.getJsonObject("NOK_SEK").getJsonNumber("val").doubleValue();
            
            
            Statement stm = con.createStatement();
            stm.setQueryTimeout(60);
            ResultSet rs = stm.executeQuery("select kurs from sxfakt.valuta where valuta='NOK'");
            if (!rs.next()) throw new SQLException("Kan inte hitta valuta NOK i valutatabellen");
            Double sqlValuta = rs.getDouble(1);
            if (sqlValuta==null || ((Double)0.0).equals(sqlValuta)) throw new SQLException("Valuta NOK är odefinerat i valutatabellen.");
            Double faktor = sqlValuta/dagensValuta;
            if (faktor.compareTo(0.75) < 0 || faktor.compareTo(1.25) > 0 ) throw new InfoException("För stor valutadiff - sql= " + sqlValuta + " Dagens URLvaluta = " + dagensValuta );

            String q="update sxfakt.valuta set kurs=round(" + dagensValuta.toString() + ",4), datum=current_date where valuta='NOK'";
                    
            stm.executeUpdate(q);
            Logger.getLogger("sx-logger").info("SaljexAsTimer.updateValutaNOK slutförd");
        } catch (SQLException e) { Logger.getLogger("sx-logger").info("Fel i SaljexAsTimer.updateValutaNOK: " + e.toString()); throw new InfoException(e.toString());}
        catch (MalformedURLException mfe) { Logger.getLogger("sx-logger").info("Fel i SaljexAsTimer.updateValutaNOK: " + mfe.toString()); throw new InfoException(mfe.toString());}
        catch (IOException ioe) { Logger.getLogger("sx-logger").info("Fel i SaljexAsTimer.updateValutaNOK: " + ioe.toString()); throw new InfoException(ioe.toString()); }
        catch (InfoException ioe) { Logger.getLogger("sx-logger").info("Fel i SaljexAsTimer.updateValutaNOK: " + ioe.toString()); throw (ioe); }
        finally { 
            try { jsonReader.close(); } catch ( Exception e) {} 
            try { valutaReader.close(); } catch ( Exception e) {} 
            try { con.close(); } catch ( Exception e) {} 
        }
        
    }

        
        
        
        
        
        
        
        
        
        
        
        
        
        
    @Schedule(dayOfWeek = "Mon-Fri", month = "*", hour = "22", dayOfMonth = "*", year = "*", minute = "0", second = "0")
    public void updateArtiklar()  throws InfoException {
        Logger.getLogger("sx-logger").info("SaljexAsTimer.updateArtiklar startad");
        Connection con=null;
        try {
            con = sxsuperuser.getConnection();
            String q=
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
"insert into sxfakt.nettopri (select 'SXAS', nummer, ROUND(CAST((inpris*(1-rab/100)*(1+inp_fraktproc/100)+inp_frakt+inp_miljo)/0.87 as numeric),2), '', current_date from sxfakt.artikel \n" +
"where inpris>0 \n" +
");\n" +
"--uppdatera nettorpislistan till AB\n" +
"delete from sxasfakt.nettopri where lista='NETTO0';\n" +
"insert into sxasfakt.nettopri (select 'NETTO0', nummer, ROUND(CAST((inpris*(1-rab/100)*(1+inp_fraktproc/100)+inp_frakt+inp_miljo) as numeric),2), '', current_date from sxasfakt.artikel \n" +
"where inpris>0 \n" +
");\n" +
"";                    
            Statement stm = con.createStatement();
            stm.setQueryTimeout(60);
            stm.executeUpdate(q);
            Logger.getLogger("sx-logger").info("SaljexAsTimer.updateArtiklar slutförd");
        } catch (SQLException e) { Logger.getLogger("sx-logger").info("Fel i SaljexAsTimer.updateartiklar: " + e.toString()); throw new InfoException(e.toString());}
        finally { try { con.close(); } catch ( Exception e) {} }
        
    }

        
        
        
        
        
        
        
        
        
        
        
        
        

    @Schedule(dayOfWeek = "Mon-Fri", month = "*", hour = "6-18", dayOfMonth = "*", year = "*", minute = "*/15", second = "0")
    public void updateLagersaldonFrom()  throws InfoException {
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
        } catch (SQLException e) { Logger.getLogger("sx-logger").info("Fel i SaljexAsTimer.updateLagersaldon: " + e.toString()); throw new InfoException(e.toString());}
        finally { try { con.close(); } catch ( Exception e) {} }
        
    }

    
    class InfoException extends Exception {

        public InfoException(String message) {
            super(message);
        }
        
    }
    
}
