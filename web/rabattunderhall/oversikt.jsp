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
    Statement st = con.createStatement();
    ResultSet rs;
    %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Översikt rabatter</title>
    </head>
        <style>
            .list {
                border-collapse: collapse;
            }
            .list td {
                border-bottom: 1px solid grey;
            }
         </style>

    <body>
        <%@include file="/WEB-INF/sxheader.jsp" %>
        <h1>Översikt rabatter</h1>
        
    
        <h2>Kunder med för hög rabatt</h2>
        <%
        rs = con.createStatement().executeQuery(
            "select \n" +
            "kr.kundnr, k.namn, k.saljare, ab.akod, mintb, kr.rab\n" +
            "from \n" +
            "\n" +
            "(\n" +
            "select akod, beskrivning, round(min((utpris-innetto)/utpris)*100) as mintb from (\n" +
            "( select *, rpad(coalesce(rabkod,''),5,' ') || '-' || rpad(coalesce(kod1,''),5,' ')  as akod, inpris*(1-rab/100)*(1+inp_fraktproc/100)+inp_frakt+inp_miljo as innetto from artikel) a left outer join\n" +
            "( select *, rpad(coalesce(rabkod,''),5,' ') || '-' || rpad(coalesce(kod1,''),5,' ')  as bkod from rabkoder) rk on bkod=akod) aa\n" +
            "where utpris<>0 and utgattdatum is null group by akod, beskrivning\n" +
            ") ab\n" +
            "join ( select *, rpad(coalesce(rabkod,''),5,' ') || '-' || rpad(coalesce(kod1,''),5,' ')  as kod from kunrab) kr on kr.kod=ab.akod\n" +
            "left outer join kund k on k.nummer=kr.kundnr\n" +
            "where rab>mintb or (akod like '%-     ' and rab > 40)\n" +
            "order by kundnr, namn, akod"        );
        %>
        <table class="list">
            <tr><th>Kundnr</th><th>Namn</th><th>Säljare</th><th>Rabattkod</th><th>Lägsta bruttomarginal</th><th>Rabatt</th></tr>
            <% while (rs.next()) { %>
                <tr>
                    <td><a href="kundstatistik.jsp?kundnr=<%= SXUtil.toHtml(rs.getString("kundnr")) %>"><%= SXUtil.toHtml(rs.getString("kundnr")) %></a></td>
                    <td><%= SXUtil.toHtml(rs.getString("namn")) %></td>
                    <td><%= SXUtil.toHtml(rs.getString("saljare")) %></td>
                    <td><%= SXUtil.toHtml(rs.getString("akod")) %></td><td><%= SXUtil.toHtml(rs.getString("mintb")) %></td><td><%= SXUtil.toHtml(rs.getString("rab")) %></td></tr>
            <% } %>
        </table>

        
        
        <h2>Artiklar med rabattkod som inte finns</h2>
        <%
        rs = st.executeQuery(
            "select nummer, namn, rabkod, kod1 from \n" +
            "artikel a where \n" +
            "rpad(coalesce(a.rabkod,''),5,' ') || '-' || rpad(coalesce(a.kod1,''),5,' ') not in (select rpad(coalesce(rabkod,''),5,' ') || '-' || rpad(coalesce(kod1,''),5,' ') from rabkoder)\n" +
            "and utgattdatum is null and a.rabkod <> 'NTO'  AND NAMN IS NOT NULL AND NAMN <>'' and coalesce(struktnr,'')='' and utpris <> 0 \n" +
            "order by a.nummer"    );
        %>
        <table class="list">
            <tr><th>Artikelnr</th><th>Namn</th><th>Rabattkod</th><th>Undergrupp</th></tr>
            <% while (rs.next()) { %>
                <tr><td><%= SXUtil.toHtml(rs.getString("nummer")) %></td><td><%= SXUtil.toHtml(rs.getString("namn")) %></td><td><%= SXUtil.toHtml(rs.getString("rabkod")) %></td><td><%= SXUtil.toHtml(rs.getString("kod1")) %></td></tr>
            <% } %>
        </table>
    
        
        
        
        
        
        
        
        
        <h2>Rabattkoder som inte används</h2>
        <%
        rs = con.createStatement().executeQuery(
"select * from \n" +
"rabkoder rk where \n" +
"rpad(coalesce(rk.rabkod,''),5,' ') || '-' || rpad(coalesce(rk.kod1,''),5,' ') not in (select rpad(coalesce(rabkod,''),5,' ') || '-' || rpad(coalesce(kod1,''),5,' ') from artikel)\n" +
"order by rk.rabkod, rk.kod1"
        );
        %>
        <table class="list">
            <tr><th>Rabattkod</th><th>Undergrupp</th><th>beskrivning</th></tr>
            <% while (rs.next()) { %>
                <tr>
                    <td><%= SXUtil.toHtml(rs.getString("rabkod")) %></td>
                    <td><%= SXUtil.toHtml(rs.getString("kod1")) %></td>
                    <td><%= SXUtil.toHtml(rs.getString("beskrivning")) %></td><
                </tr>
            <% } %>
        </table>
    
    
    
    
    </body>
</html>






