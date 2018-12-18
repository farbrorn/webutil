<%-- 
    Document   : oversikt
    Created on : 2018-jun-14, 15:24:41
    Author     : Ulf Berg
--%>

<%@page import="se.saljex.sxlibrary.SXUtil"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="se.saljex.webutil.Const"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>

<%
    Connection con = Const.getConnection(request);
    PreparedStatement ps;
    //Statement st = con.createStatement();
    ResultSet rs;
    Integer ordernr = null;
    try {  ordernr = new Integer(request.getParameter("ordernr")); }catch (Exception e) {}
    Integer antalKolli = null;
    try {  antalKolli = new Integer(request.getParameter("antalkolli")); }catch (Exception e) {} 
    
    String logoUrl = "https://www.saljex.se/p/s200/logo-saljex.png";
    rs = con.createStatement().executeQuery("select varde from sxreg where id = 'Hemsida-LogoUrl'");
    if (rs.next()) logoUrl = rs.getString("varde");
                    
            
    Fie
    
    %>
    
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Adressetikett</title>
        <style>
            td {
                padding: 0px;
            }
            h2 { 
                font-size: 60%;
                font-weight: bold;
                margin: 8px 0px 4px 0px;
            }
            
            .levadr {
                font-weight: bold;
                
            }
            .kund {
                font-weight: lighter;
                font-size: 80%;
            }
            @page {
                size: a4 portrait;
                margin: 75mm 5mm 40mm 5mm; /* change the margins as you want them to be. */
            }
            
            .sidbryt {
                page-break-after: always;
            }
            .etikettpar {                
            }
            .etikett {
                padding-left: 10mm;
            }
        </style>
    </head>
    
    <body>
    
        <%
        if (ordernr!=null) {

            ps = con.prepareStatement(
                    "select o1.*, k.tel, k.biltel from order1 o1 left outer join kund k on k.nummer=o1.kundnr where ordernr=?"
            );

            ps.setInt(1, ordernr);
            rs = ps.executeQuery();

            if (rs.next()) {
                String namn = rs.getString("namn");
                String adr1 = rs.getString("adr1");
                String adr2 = rs.getString("adr2");
                String adr3 = rs.getString("adr3");
                String levadr1 = rs.getString("levadr1");
                String levadr2 = rs.getString("levadr2");
                String levadr3 = rs.getString("levadr3");
                String marke = rs.getString("marke");
                String linjenr1 = rs.getString("linjenr1");
                String linjenr2 = rs.getString("linjenr2");
                String linjenr3 = rs.getString("linjenr3");
                String fraktbolag = rs.getString("fraktbolag");
                String tel = rs.getString("tel");
                String biltel = rs.getString("biltel");
                
                if (SXUtil.isEmpty(levadr1) && SXUtil.isEmpty(levadr2) && SXUtil.isEmpty(levadr3) ) {
                    levadr1 = namn;
                    levadr2 = adr1 + " " + adr2;
                    levadr3 = adr3;
                }
            %>
        
        <%
            int sidor = antalKolli / 2 + ((antalKolli % 2 == 0) ? 0 : 1); //runda upp divisionen
            int utskrivnaEtiketter = 0;
            for (int cn=0 ; cn<sidor; cn++) {
                if (cn>0) { %><div class="sidbryt"></div> <% }
        %>
        <div class="etikettpar">
            <table style="width: 100%">
                <tr>
                    <% for (int cn2=0; cn2<2; cn2++) {  %>
                    <td style="width: 50%"><div class="etikett">
                    <%
                        if (utskrivnaEtiketter < antalKolli) {
                            utskrivnaEtiketter++;
                    %>
                    <div style="width: 100%; max-height: 10mm;"><img src="<%= logoUrl %>" style="max-height: 100%; mex-width: 100%"></div>
                            
                            <h2>Kund</h2>
                            <span class="kund">
                            <%= SXUtil.toHtml(namn) %><br>
                            <%= SXUtil.toHtml(adr1) %><br>
                            <%= SXUtil.toHtml(adr2) %><br>
                            <%= SXUtil.toHtml(adr3) %><br>
                            </span>
                            
                            <h2>Leveransadress</h2>
                            <span class="levadr">
                            <%= SXUtil.toHtml(levadr1) %><br>
                            <%= SXUtil.toHtml(levadr2) %><br>
                            <%= SXUtil.toHtml(levadr3) %><br>
                            </span>
                            <h2>Tel</h2>
                            <%= SXUtil.toHtml(tel) %><br>
                            <%= SXUtil.toHtml(biltel) %><br>
                            
                            <h2>Godsmärke</h2>
                            <%= SXUtil.toHtml(marke) %><br>
                            <table style="width: 100%">
                                <tr><td style="width: 50%"><h2>Linjenr</h2></td><td style="width: 50%"><h2>Ordernr</h2></td></tr>
                                <tr><td><%= SXUtil.toHtml(linjenr1) + " " + SXUtil.toHtml(linjenr2) + " " + SXUtil.toHtml(linjenr3) %></td><td><%= ordernr %></td></tr>
                            </table>
                        <% } %>
                    </div></td>
                    <% } %>
                </tr>
            </table>
        </div>  
        <% }%>
        <% } else { %>
        
        fel ordernr                    
        
        <% } } else { %>
        
            <%@include file="/WEB-INF/sxheader.jsp" %>
            <form>
                Ordernr: <input name="ordernr">
                Antal kolli: <input name="antalkolli">
                <input type="submit">
            </form>
        <% } %>
    </body>
</html>
