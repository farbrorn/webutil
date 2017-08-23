/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.webutil.billigt;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
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
public class Utleveranser extends HttpServlet {

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
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Utleveranser</title>");            
            out.println("</head>");
            out.println("<body>");
            out.print("<h1>Billigt order</h1><p>Visar alla order som är plockade och ligger för fakturering, samt samtliga fakturerade order de senaste 30 dagarna.</p>");
            try {
            Connection con = (Connection)((ServletRequest)request).getAttribute("sxconnection");
String q = "select * from\n" +
"(\n" +
"select o1.ordernr as ordernr, o1.datum as datum, o1.levadr1 as levadr1, o1.levadr2 as levadr2, o1.levadr3 as levadr3, o1.marke as marke, 'Order' as typ\n" +
", o2.pos as pos, o2.artnr as artnr, o2.namn as namn, o2.lev as lev, o2.best as best, o2.enh as enhet \n" +
"from order1 o1\n" +
"join order2 o2 on o1.ordernr=o2.ordernr\n" +
"where status='Samfak' and o1.kundnr=?\n" +
"\n" +
"union all\n" +
"\n" +
"select u1.ordernr as ordernr, f1.datum as datum, u1.levadr1 as levadr1, u1.levadr2 as levadr2, u1.levadr3 as levadr3, u1.marke as marke, 'Faktura' as typ\n" +
", f2.pos as pos, f2.artnr as artnr, f2.namn as namn, f2.lev as lev, null as best, f2.enh as enhet \n" +
"from utlev1 u1\n" +
"join faktura2 f2 on f2.ordernr=u1.ordernr\n" +
"join faktura1 f1 on f1.faktnr=f2.faktnr\n" +
"where f1.datum > current_date-30 and f1.kundnr=? ) a\n" +
"where artnr is not null and length(artnr)>0\n" +
"order by typ desc, datum desc, ordernr, pos ";
                PreparedStatement ps = con.prepareStatement(q);
                ps.setString(1, BilligtData.getKundnr());
                ps.setString(2, BilligtData.getKundnr());
                ResultSet rs  = ps.executeQuery();

                out.print("<table>");
                out.print("");
                Integer tempOrdernr=0;
                while (rs.next()) {
                   if (!tempOrdernr.equals(rs.getInt("ordernr"))) {
                       tempOrdernr = rs.getInt("ordernr");
                       out.print("<tr><td colspan=\"4\"><table><tr>");
                        out.print("<td>");
                        out.print(rs.getInt("ordernr"));
                        out.print("</td>");
                        out.print("<td>");
                        out.print(rs.getDate("datum"));
                        out.print("</td>");
                        out.print("<td>");
                        out.print(SXUtil.toHtml(rs.getString("marke")));
                        out.print("</td>");
                        out.print("<td>");
                        out.print(SXUtil.toHtml(rs.getString("levadr1")));
                        out.print("</td>");
                        out.print("<td>");
                        out.print(rs.getString("typ"));
                        out.print("</td>");
                        out.print("</tr></table></td></tr>");
                   }
                   out.print("<tr>");
                   out.print("<td>");
                   out.print("&nbsp;&nbsp;");
                   out.print("</td>");
                   out.print("<td>");
                   out.print(SXUtil.toHtml(rs.getString("artnr")));
                   out.print("</td>");
                   out.print("<td>");
                   out.print(SXUtil.toHtml(rs.getString("namn")));
                   out.print("</td>");
                   out.print("<td>");
                   out.print(rs.getDouble("lev"));
                   out.print("</td>");
                   out.print("<td>");
                   out.print(SXUtil.toHtml(rs.getString("enhet")));
                   out.print("</td>");
                   out.print("</tr>");
                    
                }
                out.print("</table>");

            } catch (SQLException e) { out.print("SQL-Fel " + e.getMessage()); }
            out.println("</body>");
            out.println("</html>");
        }
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
