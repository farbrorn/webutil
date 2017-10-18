/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.webutil.billigt;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import se.saljex.sxlibrary.SXUtil;

/**
 *
 * @author ulf
 */
public class ArtikelbevakningServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        boolean xml = "xml".equals(((ServletRequest)request).getParameter("export"));
        if (!xml) response.setContentType("text/html;charset=UTF-8");
        else response.setContentType("text/xml;charset=UTF-8");
        
        try (PrintWriter out = response.getWriter()) {
                
            if (xml) {
                out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
                out.println("<?xml-stylesheet type=\"text/xml\" href=\"artikelbevakning.xsl\"?>");
                //out.println("<?xml-stylesheet type=\"text/xml\" href=\"#stylesheet\"?>");
                //out.println("<!DOCTYPE data [ <!ATTLIST xsl:stylesheet  id    ID  #REQUIRED> ]>");
                out.println("<data>");
                //request.getRequestDispatcher("/WEB-INF/se.saljex.webutil.overfor/artikelbevakning.xsl").include(request, response);
            } else {
                out.println("<!DOCTYPE html>");
                out.println("<html>");
                out.println("<head>");
                out.println("<title>Artikelbevkning</title>");            
                out.println("</head>");            
                out.println("<body>");
            }
            try {
                Connection con = (Connection)((ServletRequest)request).getAttribute("sxconnection");
                String q = "select nummer, namn, round(n.pris::numeric,2) as nettopris, inpdat, coalesce(utgattdatum::varchar,'')::varchar, greatest(utgattdatum, inpdat) as andringsdatum, a.enhet " +
                "from artikel a left outer join nettopri n on n.lista='BILLIGT' and n.artnr=a.nummer " +
                " where greatest(utgattdatum, inpdat) is not null " +
                "order by greatest(utgattdatum, inpdat)  desc, artnr";
                ResultSet rs  = con.createStatement().executeQuery(q);
                if (!xml) {
                    out.print("<h1>Händelser på artikel</h1>");
                    out.print("<p>Priser avser Billigts nettopriser. Visar händelser senaste året.</p>");
                    out.print("<table>");
                    out.print("<tr>");
                    out.print("<td>Händelsedatum</td>");
                    out.print("<td>Art.nr</td>");
                    out.print("<td>Namn</td>");
                    out.print("<td>Nettopris</td>");
                    out.print("<td>Enhet</td>");
                    out.print("<td>Inprisdatum</td>");
                    out.print("<td>Utgått datum</td>");
                    out.print("</tr>");
                }
                while (rs.next()) {
                    if (!xml) {
                        out.print("<tr><td>" + rs.getDate(6) +"</td><td>" + SXUtil.toHtml(rs.getString(1)) + "</td><td>" + SXUtil.toHtml(rs.getString(2)) + "</td><td>" + rs.getDouble(3) + "</td><td>" + SXUtil.toHtml(rs.getString("enhet")) + "</td><td>" + rs.getDate(4) + "</td><td>" + SXUtil.toHtml(rs.getString(5))  + "</td></tr>");
                    } else {
                        out.print("<artikel>");
                        out.print("<handelsedatum>" + rs.getDate(6) + "</handelsedatum>");
                        out.print("<artnr>" + SXUtil.toHtml(rs.getString(1)) + "</artnr>");
                        out.print("<namn>" + XMLEscape(rs.getString(2)) + "</namn>");
                        out.print("<nettopris>" + rs.getDouble(3) + "</nettopris>");
                        out.print("<enhet>" + rs.getString("enhet") + "</enhet>");
                        out.print("<inprisdatum>" + rs.getDate(4) + "</inprisdatum>");
                        out.print("<utgattdatum>" + rs.getString(5) + "</utgattdatum>");
                        out.println("</artikel>");
                    }
                }
                if (!xml) out.print("</table>");
            } catch(SQLException e) { out.print("SQL-Fel " + e.getMessage()); }
            if (!xml) out.print("</body></html>");
            else out.print("</data>");
        } 
    }

    private String XMLEscape(String s) {
        return s==null?"":s.replaceAll("&", "&amp;").replaceAll(">", "&gt;").replaceAll("<", "&lt;").replaceAll("\"", "&quot;").replaceAll("'", "&apos;");
    }
    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
