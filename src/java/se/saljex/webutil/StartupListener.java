/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.webutil;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import se.saljex.webutil.sxas.OverforLagersaldoRunnable;
import se.saljex.webutil.sxas.UpdateArtiklarRunnable;
import se.saljex.webutil.sxas.UpdateValutaNOKRunnable;

/**
 *
 * @author ulf
 */
@WebListener
public class StartupListener implements ServletContextListener {
     private ScheduledExecutorService scheduler;
        
    @Override
    public void contextInitialized(ServletContextEvent servletContextEvent) {
        Logger.getLogger("sx-logger").info("sxas.StartupListener startar timers");
        Executors.newSingleThreadScheduledExecutor().scheduleAtFixedRate(new OverforLagersaldoRunnable(), 0, 15, TimeUnit.MINUTES);
        Executors.newSingleThreadScheduledExecutor().scheduleAtFixedRate(new UpdateArtiklarRunnable(), 1, 6*60, TimeUnit.MINUTES);
        Executors.newSingleThreadScheduledExecutor().scheduleAtFixedRate(new UpdateValutaNOKRunnable(), 2, 12*60, TimeUnit.MINUTES);

        Executors.newSingleThreadScheduledExecutor().scheduleAtFixedRate(new se.saljex.webutil.sxas.UpdateAutonettoRunnable(), 3, 24*60, TimeUnit.MINUTES);
        Executors.newSingleThreadScheduledExecutor().scheduleAtFixedRate(new se.saljex.webutil.UpdateAutonettoRunnable(), 4, 24*60, TimeUnit.MINUTES);

        Executors.newSingleThreadScheduledExecutor().scheduleAtFixedRate(new se.saljex.webutil.billigt.UpdateBilligtPriserRunnable(), 5, 24*60, TimeUnit.MINUTES);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
    }
    
}
