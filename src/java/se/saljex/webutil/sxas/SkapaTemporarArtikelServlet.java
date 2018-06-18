/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.webutil.sxas;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.json.Json;
import javax.json.JsonArray;
import javax.json.JsonObject;
import javax.json.JsonReader;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import se.saljex.loginservice.LoginServiceConstants;
import se.saljex.webutil.Const;

/**
 *
 * @author ulf
 */
public class SkapaTemporarArtikelServlet extends HttpServlet {

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
        response.setContentType("text/html;charset=ISO-8859-1");
        String ac=request.getParameter("ac");
        boolean acIsSave = "save".equals(ac);
        Connection con = Const.getSuperUserConnection(request);
        String namn = request.getParameter("namn");
        String levnr = request.getParameter("levnr");
        String bestnr = request.getParameter("bestnr");
        String enhet = request.getParameter("enhet");
        String anvandare = request.getParameter("anvandare");
        String cn8 = request.getParameter("cn8");
        Double inprisAS = null;
        Double utprisAS = null;
        Double inprisAB = null;
        Double utprisAB = null;
        Double valutaKurs = null;
        try { inprisAB = Double.parseDouble(request.getParameter("inprisab")); } catch (Exception e) {}
        try { utprisAS = Double.parseDouble(request.getParameter("utprisas")); } catch (Exception e) {}
        
        StringBuilder sb = new StringBuilder();

      
        
        boolean isError = false;
        PreparedStatement ps;
        ResultSet rs;
        try {
            if (acIsSave) {
                if (namn==null || namn.length()<2) {
                    isError = true;
                    sb.append("Benämningen är felaktig.<br>");
                } 
                if (bestnr==null || bestnr.length()<2) {
                    isError = true;
                    sb.append("Beställningnsumret är för kort.<br>");
                } 
                if (enhet==null || enhet.length()<1) {
                    isError = true;
                    sb.append("Enheten är felaktig.<br>");
                } 
                if (cn8==null || cn8.length()<1 || cn8.length() > 8) {
                    isError = true;
                    sb.append("Tullkoden är felaktig.<br>");
                } 
                ps = con.prepareStatement("select namn from sxfakt.lev where nummer=?");
                ps.setQueryTimeout(60);
                ps.setString(1, levnr);
                rs = ps.executeQuery();
                if (!rs.next()) {
                    isError=true;
                    sb.append("Leverantören finns inte registrerad i Säljex AB.<br>");
                }
                
                ps = con.prepareStatement("select forkortning from sxfakt.saljare where forkortning = ?");
                ps.setQueryTimeout(60);
                ps.setString(1, anvandare);
                rs = ps.executeQuery();
                if (!rs.next() || anvandare==null || anvandare.length()<1) {
                    isError=true;
                    sb.append("Felaktig användare<br>");
                }
                
                ps = con.prepareStatement("select kurs from sxfakt.valuta where valuta = 'NOK'");
                ps.setQueryTimeout(60);
                rs = ps.executeQuery();
                if (!rs.next()) {
                    isError=true;
                    sb.append("Felaktig användare<br>");
                } else {
                    valutaKurs = rs.getDouble(1);
                }

                
                
                if (inprisAB==null) {
                    isError=true;
                    sb.append("Felaktigt inköpspris.<br>");
                }
                if (utprisAS==null) {
                    isError=true;
                    sb.append("Felaktigt försäljningsspris.<br>");
                }
               
                if (!isError) {
                    inprisAS = new BigDecimal(inprisAB/0.95/valutaKurs).setScale(2, RoundingMode.HALF_UP).doubleValue();
                    utprisAB = new BigDecimal(utprisAS*valutaKurs).setScale(2, RoundingMode.HALF_UP).doubleValue();

                    con.setAutoCommit(false);
                    ps = con.prepareStatement("select 'XN*'||nextval('sxfakt.tempartnr')");
                    ps.setQueryTimeout(60);
                    rs = ps.executeQuery();
                    if (!rs.next()) throw new SQLException("Det gick inte att ta fram ett nytt artikelnummer.");

                    String tArtnr = rs.getString(1);

                    //Säljex AB
                    ps = con.prepareStatement("insert into sxfakt.artikel (nummer, namn, lev, bestnr, refnr, enhet, utpris, inpris, utrab, rabkod, inpdat, prisdatum, tbidrag, forpack, hindraexport, cn8) values " +
                                                " (?, ?, ?, ?, ?, ?, ?, ?, 0, 'NTO', current_date, current_date, 0, 1, 1, ?)");
                    ps.setQueryTimeout(60);
                    ps.setString(1, tArtnr);
                    ps.setString(2, namn);
                    ps.setString(3, levnr);
                    ps.setString(4, bestnr);
                    ps.setString(5, bestnr);
                    ps.setString(6, enhet);
                    ps.setDouble(7,utprisAB );
                    ps.setDouble(8,inprisAB );
                    ps.setString(9,cn8 );
                    if (ps.executeUpdate()<1) throw new SQLException("Kunde inte skapa artikel " + tArtnr + " i säljex AB");

                    //Saljex AS
                    ps = con.prepareStatement("insert into sxasfakt.artikel (nummer, namn, lev, bestnr, refnr, enhet, utpris, inpris, utrab, rabkod, inpdat, prisdatum, tbidrag, forpack, hindraexport, cn8) values " +
                                                " (?, ?, ?, ?, ?, ?, ?, ?, 0, 'NTO', current_date, current_date, 0, 1, 1, ?)");
                    ps.setQueryTimeout(60);
                    ps.setString(1, tArtnr);
                    ps.setString(2, namn);
                    ps.setString(3, "SX");
                    ps.setString(4, bestnr);
                    ps.setString(5, bestnr);
                    ps.setString(6, enhet);
                    ps.setDouble(7,utprisAS );
                    ps.setDouble(8,inprisAS );
                    ps.setString(9,cn8 );
                    if (ps.executeUpdate()<1) throw new SQLException("Kunde inte skapa artikel " + tArtnr + " i Saljex SB");
                    

                    ps = con.prepareStatement("insert into sxfakt.arthand (artnr, datum, tid, anvandare, handelse, anteckning) values (?,current_date, current_time, ?, 'Skapad', '')");
                    ps.setQueryTimeout(60);
                    ps.setString(1, tArtnr);
                    ps.setString(2, anvandare);
                    if (ps.executeUpdate()<1) throw new SQLException("Kunde inte skapa artikelhändelse.");

                    ps = con.prepareStatement("insert into sxfakt.nettopri (lista, artnr, pris, datum) values ((select nettolst from sxfakt.kund where nummer=?) , ?, round(?::numeric,2), current_date)");
                    ps.setQueryTimeout(60);
                    ps.setString(1, SxasData.getKundnr());
                    ps.setString(2, tArtnr);
                    ps.setDouble(3, inprisAB/0.95);
                    if (ps.executeUpdate()<1) throw new SQLException("Kunde inte spara i nettoprislistan.");
                    
                    con.commit();
                    con.setAutoCommit(true);
                    sb.append("Artikel " + tArtnr + " " + namn + " är skapad OK!<br>");
                }
            }
        }catch (SQLException se) {
            isError = true;
            try { con.rollback(); } catch (SQLException sse) {}
            try { con.setAutoCommit(true); } catch (SQLException sse) {}
            request.setAttribute("errtext", "SQL-Fel: " + se.toString() + se.getMessage());
        }
        
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Skapa temporär artikel</title>");  
            out.println("<meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\">");
            out.println("</head>");
            out.println("<body>");


            request.setAttribute("infotext", sb.toString());
            request.getRequestDispatcher("/WEB-INF/saljexas/temporarartiklar/index.jsp").include(request, response);				


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
