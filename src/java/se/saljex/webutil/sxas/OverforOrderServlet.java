/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.webutil.sxas;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.ConnectException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import se.saljex.webutil.Const;

/**
 *
 * @author ulf
 */
public class OverforOrderServlet extends HttpServlet {

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
        String ac=request.getParameter("ac");
        String orderlistParameter = request.getParameter("orderlista");
        ArrayList<Integer> orderLista = new ArrayList<>();
        boolean splitError = false;
        boolean acIsOverfor = "overfor".equals(ac);
        Connection con = Const.getSuperUserConnection(request);
        
        if (orderlistParameter!=null) {
            try {
                String[] orderListaStr = orderlistParameter.trim().split(",");
                for (String s : orderListaStr) {
                    orderLista.add(Integer.parseInt(s.trim()));
                }
            } catch (Exception e) { 
                splitError = true;
                orderLista = null;
                request.setAttribute("errtext", "Formatfel i orderlistan.");
            }
        }
        StringBuilder sb = new StringBuilder();
        boolean overforError=false;
            if (acIsOverfor && orderLista!=null && orderLista.size() > 0) {
                try {
                    con.setAutoCommit(false);
//                    con.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);
//                    System.out.print("Isol: " + con.getTransactionIsolation()); 
                    Statement statement = con.createStatement();
                    statement.setQueryTimeout(60);
                    statement.executeUpdate("create temporary table orderrader (artnr varchar, lev real) on commit drop");
                    PreparedStatement orderraderStatement = con.prepareStatement("insert into orderrader (artnr, lev) values (?,?)");
                    orderraderStatement.setQueryTimeout(60);
                    PreparedStatement ps = con.prepareStatement("select o1.ordernr, o1.namn as kundnamn, o2.artnr, o2.namn as artnamn, o2.lev, o2.netto, o2.enh, a.nummer as a_nummer  from sxasfakt.order1 o1 join sxasfakt.order2 o2 on o1.ordernr=o2.ordernr left outer join sxfakt.artikel a on a.nummer=o2.artnr where o2.artnr is not null and o2.artnr <> '' and o2.lev<>0 and status='Samfak' and o1.ordernr=?");
                    ps.setQueryTimeout(60);
                    for (Integer o : orderLista) {
                        ps.setInt(1, o);
                        ResultSet rs = ps.executeQuery();
                        boolean isOnOrdernr=false;
                        boolean isErrorOnOrder = false;
                        
                        while(rs.next()) {
                            isOnOrdernr=true;
                            orderraderStatement.setString(1, rs.getString("artnr"));
                            orderraderStatement.setDouble(2, rs.getDouble("lev"));
                            if (orderraderStatement.executeUpdate()<1) throw new SQLException("Kan inte lägga till rader i temorär tabell orderrader");
                            
                            if (rs.getString("artnr").startsWith("*") ) {
                                sb.append("Ordernr " + o + " - *-rad är inte tillåtet. (" + rs.getString("artnr") + " " + rs.getString("artnamn") + ")<br>");
                                isErrorOnOrder = true;
                            } else if (rs.getString("a_nummer")==null) {
                                sb.append("Ordernr " + o + " - Artikel " + rs.getString("artnr") + " " + rs.getString("artnamn") + " saknas i artikelregistret.<br>");
                                isErrorOnOrder = true;
                            }
                            if (rs.getDouble("lev") < 0) {
                                sb.append("Ordernr " + o + " - Kredit är inte tillåten. Artnr " + rs.getString("artnr") + " " + rs.getString("artnamn")+"<br>");
                                isErrorOnOrder = true;                                
                            }
                        }
                        if (isErrorOnOrder) overforError = true;
                        if (isOnOrdernr && !isErrorOnOrder) {
                            sb.append("Ordernr " + o + " - ok<br>");
                        } else {
                            if(!isOnOrdernr) sb.append("Ordernr " + o + " <b>saknas eller ligger inte på samfakt.</b><br>");                            
                            overforError = true;
                        }
                    }
                    
                    if (!overforError) {
                        ResultSet rs;
                        rs = statement.executeQuery("select offertnr from sxfakt.faktdat");
                        Integer offertnr;
                        if (rs.next()) {
                            offertnr = rs.getInt(1);
                            if (offertnr==null) throw new SQLException("null-värde för offertnummer från sxfakt.fakttdat");
                            if (statement.executeUpdate("update sxfakt.faktdat set offertnr = offertnr+1")<1) throw new SQLException("Kan inte uppdatera sxfakt.faktdat");
                            statement.executeUpdate("create temporary sequence pos;");
                            
                            ps = con.prepareStatement("create temporary table kon on commit drop as select ?::varchar as kundnr, ? as offertnr;");
                            ps.setString(1, SxasData.getKundnr());
                            ps.setInt(2, offertnr);
                            ps.executeUpdate();
                            
                            if (statement.executeUpdate(
                                    "insert into sxfakt.offert1 (offertnr, namn, adr1, adr2, adr3, levadr1, levadr2, levadr3, saljare, referens, kundnr, marke, datum, moms, ktid, bonus, faktor, mottagarfrakt,  fraktfrigrans, skrivejpris, lagernr) " +
                                    " select kon.offertnr, k.namn, k.adr1, k.adr2, k.adr3, k.lnamn, k.ladr2, k.ladr3, k.saljare, k.ref, k.nummer, '', current_date, 0, k.ktid, k.bonus, k.faktor, k.mottagarfrakt, k.fraktfrigrans, 0, 0 " +
                                    " from sxfakt.kund k join kon on kon.kundnr=k.nummer; " 
                            ) <1) throw new SQLException("Kan inte skapa sxfakt.offert1 (offertnr " + offertnr + ")");
                            if (statement.executeUpdate(
                                    "insert into sxfakt.offert2 (offertnr, pos, prisnr, artnr, namn, levnr, best, rab, lev, text, pris, summa, konto, netto, enh) " +
                                    " select kon.offertnr, (select nextval('pos')), 1, v.artnr, v.artnamn, v.lev, orad.lev, 0, orad.lev, '', " +
//                                    " select kon.offertnr, (select count(*)+1 from sxfakt.offert2 where offertnr=kon.offertnr), 1, v.artnr, v.artnamn, v.lev, orad.lev, 0, orad.lev, '', " +
                                    " round(least(utpris, case when rabkod='NTO' then utpris else utpris*(1-greatest(basrab, gruppbasrab, undergrupprab)/100) end, case when nettopris=0 then utpris else nettopris end )::numeric,2), " +
                                    " 0,'' , round((v.inpris*(1-v.rab/100)*(1+v.inp_fraktproc/100)+v.inp_frakt+v.inp_miljo)::numeric,2), v.enhet " +
                                    " from (select artnr, sum(lev) as lev from orderrader group by artnr order by artnr) orad "
                                    + " join kon on 1=1 "
                                    + "left outer join sxfakt.vartkundorder v on orad.artnr=v.artnr and lagernr=0 and kon.kundnr=v.kundnr " +
                                    " ;"
                            ) <1) throw new SQLException("Kan inte skapa sxfakt.offert2 (offertnr " + offertnr + ")");
                            if (statement.executeUpdate(
                                    "update sxfakt.offert2 set summa=round((pris*lev)::numeric,2) where offertnr=(select kon.offertnr from kon);"
                            ) <1) throw new SQLException("Kan inte uppdatera radsummor för sxfakt.offert2 (offertnr " + offertnr + ")");
                            
                            
                        } else throw new SQLException("Kan inte läsa sxfakt.fuppg");
                        
                        con.commit();
                        sb.append("Offert " + offertnr + " sparad ok!<br>");
                    } else {
                        sb.append("<b>Inget sparat.</b><br>");
                        con.rollback();
                    }
                } catch (SQLException e) {
                    try {con.rollback(); } catch (SQLException se) {}
                    request.setAttribute("errtext", "SQL-Fel: " + e.toString() + e.getMessage());
                    sb = new StringBuilder(); //Töm så inte delar av processen visas som ok
                } finally {
                   try { con.setAutoCommit(true); }catch (SQLException se) {}
                   
                }
            }
        request.setAttribute("infotext", sb.toString());
        
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Överför order</title>");            
            out.println("</head>");
            out.println("<body>");

            request.getRequestDispatcher("/WEB-INF/saljexas/overfor/index.jsp").include(request, response);				
 
            
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
