/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.webutil;

import java.sql.Connection;
import java.sql.SQLException;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;

/**
 *
 * @author ulf
 */
public class Const {
    public static Connection getConnection(HttpServletRequest request) {
        return (Connection)request.getAttribute("sxconnection");
    }
    public static Connection getSuperUserConnection(HttpServletRequest request) {
        return (Connection)request.getAttribute("sxsuperuserconnection");
    }
    
    public static Connection getSxAdmConnectionFromInitialContext() throws NamingException, SQLException{
        return getConnectionFromInitialContext("sxadm");
    }
    
    public static Connection getConnectionFromInitialContext(String name) throws NamingException, SQLException{
        Context initContext = new InitialContext();
        return ((DataSource) initContext.lookup(name)).getConnection();
    }
}
