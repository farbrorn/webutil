/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.webutil.sxas;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import se.saljex.webutil.Const;

/**
 *
 * @author ulf
 */
public class FaktureraOffert extends HttpServlet {

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

        int offertnr = 0;
        long totalsumma=0;
        int antalkolli=0;
        int viktkg = 0;
        Double fraktkostnad = null;
        
        try { offertnr = Integer.parseInt(request.getParameter("offertnr")); } catch (Exception e) {} 
        try { totalsumma = Long.parseLong(request.getParameter("totalsumma")); } catch (Exception e) {} 
        try { antalkolli = Integer.parseInt(request.getParameter("antalkolli")); } catch (Exception e) {} 
        try { viktkg = Integer.parseInt(request.getParameter("viktkg")); } catch (Exception e) {} 
        try { fraktkostnad = Double.parseDouble(request.getParameter("fraktkostnad")); } catch (Exception e) {} 
        PreparedStatement ps;
        ResultSet rs;
        Connection con = Const.getConnection(request);
        
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet FaktureraOffert</title>");            
            out.println("</head>");
            out.println("<body>");
            try {
                ps = con.prepareStatement("select true  from offert1 o1 join offert2 o2 on o1.offertnr=o2.offertnr where o1.offertnr=? and o1.kundnr=? and o1.offertnr<>0 group by o1.offertnr  having abs(sum(round(summa::numeric,2))-?::numeric) < 1");
                ps.setInt(1, offertnr);
                ps.setString(2, SxasData.getKundnr());
                ps.setLong(3, totalsumma);
                rs = ps.executeQuery();
                if (rs.next()) {
                    ps = con.prepareStatement("select sxasfaktureraoffert('00', ?, ?" );
                    ps.setInt(1, offertnr);
                    ps.setDouble(2, fraktkostnad);
                    rs = ps.executeQuery();
                    if (rs.next()) {
                        int faktnr = rs.getInt(1);
                        out.print("<b>Faktura " + faktnr + " skapad! </b><br>");
                        out.print("<form>");
                        out.print("input type=\"hidden\" name=\"faktnr\" value=\"" + faktnr + "\"");
                        out.print("input type=\"hidden\" name=\"kolli\" value=\"" + antalkolli + "\"");
                        out.print("input type=\"hidden\" name=\"vikt\" value=\"" + viktkg + "\"");
                        out.print("input type=\"submit\" name=\"submit\" value=\"Skriv ut faktura\"");
                        out.print("</form>");
                    }
                    
                } else {
                    out.print("Hittar inte offert med följande paramatrera: <br> Offertnr: " + offertnr + "<br>Kundnr: " + SxasData.getKundnr() + "<br>Totalsumma avrundat: " + totalsumma + "<br>");
                }
            
            } catch (SQLException e) {
                out.print("<br>sql-fel: " + e.toString());
                e.printStackTrace();
            }
           
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
