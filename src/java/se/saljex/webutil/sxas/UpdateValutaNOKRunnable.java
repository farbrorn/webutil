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
import java.util.logging.Logger;
import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonReader;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;
import se.saljex.webutil.Const;
import se.saljex.webutil.InfoException;

/**
 *
 * @author ulf
 */
public class UpdateValutaNOKRunnable  implements Runnable {
        @Override
    public void run() {
        try { doTask(); } catch (Exception e) {}
    }
    
    public void doTask() throws InfoException {
        Connection con=null;
        Logger.getLogger("sx-logger").info("sxas.UpdateValutaNOKRunnable Run start");
        JsonReader jsonReader=null;
        BufferedReader valutaReader = null;
        
        try {
            con=Const.getSxAdmConnectionFromInitialContext();
            Statement stm = con.createStatement();
            stm.setQueryTimeout(60);
            URL valutaURL=new URL("https://free.currencyconverterapi.com/api/v5/convert?q=NOK_SEK&compact=y&apiKey=651acd318db35d2790b9");
            valutaReader = new BufferedReader(new InputStreamReader(valutaURL.openStream()));
            jsonReader = Json.createReader(valutaReader);

            JsonObject jsonObject = jsonReader.readObject();
            Double dagensValuta = jsonObject.getJsonObject("NOK_SEK").getJsonNumber("val").doubleValue();
            
            
            ResultSet rs = stm.executeQuery("select kurs from sxfakt.valuta where valuta='NOK'");
            if (!rs.next()) throw new SQLException("Kan inte hitta valuta NOK i valutatabellen");
            Double sqlValuta = rs.getDouble(1);
            if (sqlValuta==null || ((Double)0.0).equals(sqlValuta)) throw new SQLException("Valuta NOK är odefinerat i valutatabellen.");
            Double faktor = sqlValuta/dagensValuta;
            if (faktor.compareTo(0.75) < 0 || faktor.compareTo(1.25) > 0 ) throw new SQLException("För stor valutadiff - sql= " + sqlValuta + " Dagens URLvaluta = " + dagensValuta );

            String q="update sxfakt.valuta set kurs=round(" + dagensValuta.toString() + ",4), datum=current_date where valuta='NOK'";
                    
            stm.executeUpdate(q);
        } catch(Exception e) {
            Logger.getLogger("sx-logger").info("sxas.UpdateValutaNOKRunnable kan intt uppdatera: " + e.getMessage()); 
            e.printStackTrace();
            throw new InfoException("Fel: " + e.getMessage());
        }
        finally { 
            try { jsonReader.close(); } catch ( Exception e) {} 
            try { valutaReader.close(); } catch ( Exception e) {} 
            try { con.close(); } catch ( Exception e) {} 
            Logger.getLogger("sx-logger").info("sxas.UpdateValutaNOKRunnable Run klar");
        }
    }    
}