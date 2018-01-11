/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.webutil.orderscanner;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Date;
import javax.json.Json;
import javax.json.JsonArray;
import javax.json.JsonObject;
import javax.json.JsonReader;
import javax.json.JsonValue;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import se.saljex.webutil.Const;
import se.saljex.webutil.sxas.SxasData;

/**
 *
 * @author ulf
 */
public class sendOrder extends HttpServlet {

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
        Connection con = Const.getSuperUserConnection(request);
        
        String marke = request.getParameter("marke");
        String kundnr = request.getParameter("kundnr");
        String anvandare = request.getParameter("anvandare");
        String jsonOrderString = request.getParameter("order");
        Integer ordernr=null;
        StringBuilder sb = new StringBuilder();
        
        try (PrintWriter out = response.getWriter()) {
            try {
//                JsonReader jsonReader = Json.createReader(new ByteArrayInputStream(jsonOrderString.getBytes(StandardCharsets.UTF_8.name())));
                JsonReader jsonReader = Json.createReader(new ByteArrayInputStream(jsonOrderString.getBytes(StandardCharsets.ISO_8859_1.name())));
                JsonArray jsonArray = jsonReader.readArray();
                jsonReader.close();
                int size = jsonArray.size();
                try {
                    if (size>0) {
                        con.setAutoCommit(false);
                        Statement statement = con.createStatement();
                        statement.setQueryTimeout(60);
                        statement.executeUpdate("create temporary table orderrader (artnr varchar, lev real, pos serial) on commit drop");

                        PreparedStatement orderraderStatement = con.prepareStatement("insert into orderrader (artnr, lev) values (?,?)");
                        orderraderStatement.setQueryTimeout(60);

                        PreparedStatement ps; 
                        PreparedStatement psArtikel = con.prepareStatement("select nummer from sxasfakt.artikel where nummer=?"); 
                        for (int cn=0; cn<size; cn++) {
                            JsonObject jsonObject = jsonArray.getJsonObject(cn);
                            String artnr = jsonObject.getJsonString("artnr").getString();
                            orderraderStatement.setString(1, artnr);
                            Double antal = 0.0;
                            try { antal = Double.parseDouble(jsonObject.getJsonString("antal").getString()); } catch (Exception e) {} 
                            orderraderStatement.setDouble(2, antal);
                            if (orderraderStatement.executeUpdate()<1) throw new SQLException("Kan inte lägga till rader i temorär tabell orderrader");
                            psArtikel.setString(1, artnr);
                            ResultSet rsArtikel = psArtikel.executeQuery();
                            if (!rsArtikel.next()) throw new SQLException("Artikel " + artnr + " saknas. Kan inte spara order.");
                            sb.append(jsonObject.getJsonString("artnr").getString() +" "+ jsonObject.getJsonString("namn").getString() + "<br>");
                        }
                        ResultSet rs;
                        rs = statement.executeQuery("select ordernr from sxasfakt.fdordernr");
                        if (!rs.next()) throw new SQLException("Kan inte läsa sxasfakt.fdordernr");

                        ordernr = rs.getInt(1);
                        if (ordernr==null) throw new SQLException("null-värde för ordernummer från sxasfakt.fdordernr");
                        if (statement.executeUpdate("update sxasfakt.fdordernr set ordernr = ordernr+1")<1) throw new SQLException("Kan inte uppdatera sxasfakt.fdordernr. ");

                        ps = con.prepareStatement("select nummer from sxasfakt.kund where nummer=?");
                        ps.setString(1, kundnr);
                        if (!ps.executeQuery().next()) throw new SQLException("Felaktigt kundnummer: " + kundnr);   
                        
                        ps = con.prepareStatement("select forkortning from sxasfakt.saljare where forkortning=?");
                        ps.setString(1, anvandare);
                        if (!ps.executeQuery().next() || anvandare == null || anvandare.length()<1) throw new SQLException("Felaktigt användare: " + anvandare);   

                        ps = con.prepareStatement("create temporary table kon on commit drop as select ?::varchar as kundnr, ? as ordernr, ?::varchar as marke, ?::varchar as anvandare;");
                        ps.setString(1, kundnr);
                        ps.setInt(2, ordernr);
                        ps.setString(3, marke);
                        ps.setString(4, anvandare);
                        ps.executeUpdate();
                        
/*
                        if (statement.executeUpdate(
                                "insert into sxasfakt.offert1 (offertnr, namn, adr1, adr2, adr3, levadr1, levadr2, levadr3, saljare, referens, kundnr, marke, datum, moms, ktid, bonus, faktor, mottagarfrakt,  fraktfrigrans, skrivejpris, lagernr) " +
                                " select kon.offertnr, k.namn, k.adr1, k.adr2, k.adr3, k.lnamn, k.ladr2, k.ladr3, k.saljare, k.ref, k.nummer, kon.marke, current_date, 0, k.ktid, k.bonus, k.faktor, k.mottagarfrakt, k.fraktfrigrans, 0, 0 " +
                                " from sxasfakt.kund k join kon on kon.kundnr=k.nummer; " 
                        ) <1) throw new SQLException("Kan inte skapa sxasfakt.offert1 (offertnr " + offertnr + ")");
                        if (statement.executeUpdate(
                                "insert into sxasfakt.offert2 (offertnr, pos, prisnr, artnr, namn, levnr, best, rab, lev, text, pris, summa, konto, netto, enh) " +
                                " select kon.offertnr, orad.pos, 1, v.artnr, v.artnamn, v.lev, orad.lev, 0, orad.lev, '', " +
                                " round(least(utpris, case when rabkod='NTO' then utpris else utpris*(1-greatest(basrab, gruppbasrab, undergrupprab)/100) end, case when nettopris=0 then utpris else nettopris end )::numeric,2), " +
                                " 0,'' , round((v.inpris*(1-v.rab/100)*(1+v.inp_fraktproc/100)+v.inp_frakt+v.inp_miljo)::numeric,2), v.enhet " +
                                " from (select artnr, sum(lev) as lev, min(pos) as pos from orderrader group by artnr order by artnr) orad "
                                + " join kon on 1=1 "
                                + "left outer join sxasfakt.vartkundorder v on orad.artnr=v.artnr and lagernr=0 and kon.kundnr=v.kundnr " +
                                " ;"
                        ) <1) throw new SQLException("Kan inte skapa sxasfakt.offert2 (offertnr " + offertnr + ")");
*/

                        if (statement.executeUpdate(
                                "insert into sxasfakt.order1 (ordernr, dellev, status, namn, adr1, adr2, adr3, levadr1, levadr2, levadr3, saljare, referens, kundnr, marke, datum, moms, ktid, bonus, faktor, mottagarfrakt,  fraktfrigrans, lagernr) " +
                                " select kon.ordernr,1, 'Avvakt', k.namn, k.adr1, k.adr2, k.adr3, k.lnamn, k.ladr2, k.ladr3, k.saljare, k.ref, k.nummer, kon.marke, current_date, 0, k.ktid, k.bonus, k.faktor, k.mottagarfrakt, k.fraktfrigrans, 0 " +
                                " from sxasfakt.kund k join kon on kon.kundnr=k.nummer; " 
                        ) <1) throw new SQLException("Kan inte skapa sxasfakt.order1 (ordernr " + ordernr + ")");
                        if (statement.executeUpdate(
                                "insert into sxasfakt.order2 (ordernr, pos, prisnr, artnr, namn, levnr, best, rab, lev, text, pris, summa, konto, netto, enh) " +
                                " select kon.ordernr, orad.pos, 1, v.artnr, v.artnamn, v.lev, orad.lev, "
                                + " case when rabkod='NTO' then 0 else case when nettopris > 0 then 0 else greatest(basrab, gruppbasrab, undergrupprab) end end, "
                                + "orad.lev, '', " +
                                " round((case when nettopris > 0 then nettopris else utpris end)::numeric,2), " + 
                                " 0,'' , round((v.inpris*(1-v.rab/100)*(1+v.inp_fraktproc/100)+v.inp_frakt+v.inp_miljo)::numeric,2), v.enhet " +
                                 " from (select artnr, sum(lev) as lev, min(pos) as pos from orderrader group by artnr order by artnr) orad "
                                + " join kon on 1=1 "
                                + " join sxasfakt.vartkundorder v on orad.artnr=v.artnr and lagernr=0 and v.kundnr=(select kundnr from kon) " +
                                " ;"
                        ) <1) throw new SQLException("Kan inte skapa sxasfakt.order2 (offertnr " + ordernr + ")");

                        if (statement.executeUpdate(
                                "update sxasfakt.order2 set summa=round((pris*lev*(1-rab/100))::numeric,2) where ordernr=(select kon.ordernr from kon);"
                        ) <1) throw new SQLException("Kan inte uppdatera radsummor för sxasfakt.order2 (ordernr " + ordernr + ")");

                        if (statement.executeUpdate(
                                "insert into sxasfakt.orderhand (ordernr, datum, tid, anvandare, handelse) "
                                + "select kon.ordernr, current_date, current_time, kon.anvandare, 'Skapad' from kon;"                                                                
                        ) <1) throw new SQLException("Fel vid skapande av OrderHand");

// Gör inte detta i sxas eftersom lagertabellen inte finns där
//                        if (statement.executeUpdate(
//                                "update sxfakt.lager set iorder = iorder+orderrader.antal from orderrader where orderrader.artnr=lager.artnr and lager.lagernr=0;"
//                        ) <1) throw new SQLException("Kan inte uppdatera radsummor för sxasfakt.order2 (ordernr " + ordernr + ")");
                        
                        con.commit();
                        con.setAutoCommit(true);
                    }
                } catch (Exception e) {
                        try {con.rollback(); } catch (SQLException se) {}
                        throw e;
                } finally {
                    try { con.setAutoCommit(true); }catch (SQLException se) {}
                }
                out.println("<h1>Order sparad!</h1><p>Denna order är nu sparad i systemet med ordernr " + ordernr + "</p>");
                out.print("<p>" + sb.toString() + "</p>");
            } catch (Exception e) { out.println("<h1>Sorry... Vi har ett problem. </h1>" + e.getMessage() + " " + e.toString());}
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
