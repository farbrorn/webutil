/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.webutil.sxas;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

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
        Executors.newSingleThreadScheduledExecutor().scheduleAtFixedRate(new UpdateArtiklarRunnable(), 0, 6, TimeUnit.HOURS);
        Executors.newSingleThreadScheduledExecutor().scheduleAtFixedRate(new OverforLagersaldoRunnable(), 1, 15, TimeUnit.MINUTES);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
    }
    
}
