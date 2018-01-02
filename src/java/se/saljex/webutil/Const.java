/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.webutil;

import java.sql.Connection;
import javax.servlet.http.HttpServletRequest;

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
}
