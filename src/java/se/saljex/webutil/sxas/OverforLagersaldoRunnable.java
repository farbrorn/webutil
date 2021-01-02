/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.webutil.sxas;

import java.sql.Connection;
import java.sql.SQLException;
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
public class OverforLagersaldoRunnable implements Runnable {
        @Override
    public void run() {
        try { doTask(); }catch (Exception e) {}
    }
    
    public void doTask() throws InfoException {
        Connection con=null;
        Logger.getLogger("sx-logger").info("sxas.OverforLagersaldoTimer Run start");
        try {
            con=Const.getSxAdmConnectionFromInitialContext();
              String q="select sxasOverforLagersaldo()";

            Statement stm = con.createStatement();
            stm.setQueryTimeout(60);
            stm.executeUpdate(q);
              
        } catch(Exception e) {
            Logger.getLogger("sx-logger").info("sxas.OverforLagersaldoTimer kan inte överföra lagerdsaldo: " + e.getMessage()); 
            e.printStackTrace();
            throw new InfoException("Fel: " + e.getMessage());
        }
        finally {
            try { con.close(); } catch (Exception e) {}
            Logger.getLogger("sx-logger").info("sxas.OverforLagersaldoTimer Run klar");
        }
    }    
    
}
