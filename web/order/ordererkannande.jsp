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
    
    String logoUrl = "https://www.saljex.se/p/s200/logo-saljex.png";
    rs = con.createStatement().executeQuery("select varde from sxreg where id = 'Hemsida-LogoUrl'");
    if (rs.next()) logoUrl = rs.getString("varde");
    
    boolean saljexas=("true".equals(request.getParameter("saljexas")));
    String prefix = saljexas ? "sxasfakt." : "";
                    
    %>
    
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Ordererkännande</title>
        <style>
            td {
                padding: 0px;
            }
            h2 { 
                font-size: 60%;
                font-weight: bold;
                margin: 8px 0px 4px 0px;
            }
            
        </style>
    </head>
    
    <body>
    
        <%
        if (ordernr!=null) {

            ps = con.prepareStatement(
                    "select * from  " + prefix + "order1 o1 where ordernr=?"
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
                
                if (SXUtil.isEmpty(levadr1) && SXUtil.isEmpty(levadr2) && SXUtil.isEmpty(levadr3) ) {
                    levadr1 = namn;
                    levadr2 = adr1 + " " + adr2;
                    levadr3 = adr3;
                }
            %>
        
            <table style="width: 100%">
                <tr>
                    <td style="width: 50%">
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
                            
                            <h2>Godsmärke</h2>
                            <%= SXUtil.toHtml(marke) %><br>
                            <table style="width: 100%">
                                <tr><td style="width: 50%"><h2>Linjenr</h2></td><td style="width: 50%"><h2>Ordernr</h2></td></tr>
                                <tr><td><%= SXUtil.toHtml(linjenr1) + " " + SXUtil.toHtml(linjenr2) + " " + SXUtil.toHtml(linjenr3) %></td><td><%= ordernr %></td></tr>
                            </table>
                    </td>
                </tr>
            </table>

                            
           
    <table>
        <tr><th>Art.nr</th><th>Benämning</th><th>Antal</th><th>Enhet</th><th>Pris</th><th>%</th><th>Lev.datum</th></tr>
        <%
            ps = con.prepareStatement(
                    "select * from  " + prefix + "order2 o2 where ordernr=? order by pos"
            );

            ps.setInt(1, ordernr);
            rs = ps.executeQuery();
            while (rs.next()) {
            %>                            
            <tr>
                <td><%= SXUtil.toHtml(rs.getString("artnr")) %></td>
                <td><%= SXUtil.toHtml(rs.getString("namn")) %></td>
                <td><%= SXUtil.getFormatNumber(rs.getDouble("best")) %></td>
                <td><%= SXUtil.toHtml(rs.getString("enh")) %></td>
                <td><%= SXUtil.getFormatNumber(rs.getDouble("pris")) %></td>
                <td><%= SXUtil.getFormatNumber(rs.getDouble("rab")) %></td>
                <td><%= SXUtil.getFormatDate(rs.getDate("levdat")) %></td>
            </TR>
            
            <% } %>
    </tabl>
        
        <% } else { %>
        
        fel ordernr                    
        
        <% } } else { %>
        
            <%@include file="/WEB-INF/sxheader.jsp" %>
            <form>
                Ordernr: <input name="ordernr">
                Order från Saljex AS<input type="checkbox" name="saljexas" value="true" <%= saljexas ? "checked" : "" %>>
                <input type="submit">
            </form>
        <% } %>
    </body>
</html>
