package se.saljex.webutil;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Logger;
import javax.annotation.Resource;
import javax.ejb.EJB;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;
import se.saljex.loginservice.LoginServiceBeanRemote;
import se.saljex.loginservice.LoginServiceConstants;
import se.saljex.loginservice.Util;

/**
 *
 * @author ulf
 */
@WebFilter(filterName = "ManiFilter", urlPatterns = {"/*"})
public class ManiFilter extends se.saljex.loginservice.LoginServiceFilter {
    
	@Resource(mappedName = "sxadm")
	private DataSource sxadm;
	@Resource(mappedName = "sxsuperuser")
	private DataSource sxsuperuser;
	@Resource(mappedName = "webse")
	private DataSource webse;
	@Resource(mappedName = "webno")
	private DataSource webno;
        @EJB
        private LoginServiceBeanRemote loginServiceBeanRemote;
    
    public ManiFilter() {
        super();
    }    
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
            FilterChain chain)
            throws IOException, ServletException {
		Connection con=null;
		Connection con2=null;
		Connection con3=null;
		Connection con4=null;
		try {
			con = sxadm.getConnection();
			request.setAttribute("sxconnection", con); 
			con2 = sxsuperuser.getConnection();
			request.setAttribute("sxsuperuserconnection", con2);                       
			con3 = webse.getConnection();
			request.setAttribute("webseconnection", con2);                       
			con4 = webno.getConnection();
			request.setAttribute("webnoconnection", con2);                       
 			super.doFilter(request,response,chain);
		} catch (SQLException e) {
			Logger.getLogger("sx-logger").severe("SQL-Fel:" + e.getMessage()); e.printStackTrace();
		} finally { try {con.close(); con2.close(); con3.close(); con4.close();} catch (Exception eee) {}}		
    }


    
}
