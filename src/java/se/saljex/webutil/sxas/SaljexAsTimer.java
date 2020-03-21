/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.webutil.sxas;

/**
 *
 * @author ulf
 */
public class SaljexAsTimer {
        

        
    public void updateValutaNOK()  {
        // Kvar för bakåtkompabilitet efter timerservice blev bytt
        Runnable r = new UpdateValutaNOKRunnable();
        r.run();
    }
        
    public void updateArtiklar()  {
        // Kvar för bakåtkompabilitet efter timerservice blev bytt
        Runnable r = new UpdateArtiklarRunnable();
        r.run();
    }


    public void updateLagersaldonFrom()   {
        // Kvar för bakåtkompabilitet efter timerservice blev bytt
        Runnable r = new OverforLagersaldoRunnable();
        r.run();
    }
    
}
