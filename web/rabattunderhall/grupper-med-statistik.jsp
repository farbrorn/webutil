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
        <title>Rabattgrupper</title>
        <style>
            .list {
                border-collapse: collapse;
            }
            .list td {
                border-bottom: 1px solid grey;
            }
        </style>
    </head>
    
    <body>
        <%@include file="/WEB-INF/sxheader.jsp" %>
        <h1>Rabattgrupper</h1>
        
    
        <h2>Rabattgrupper med statistik</h2>
        <table>
            <tr><td>Antal aritklar</td><td>Antal artiklar i artikelgruppen</td></tr>
            <tr><td>Omsättning</td><td>Fakturerad omsättning netto under senaste året.</td></tr>
            <tr><td>Lägsta bruttomarginal</td><td>Bruttomarginalen (marginal mot bruttopriset) på den artikel med sämst marginal.</td></tr>
            <tr><td>Medel bruttomarginal</td><td>Bruttomarginalen (marginal mot bruttopriset) på snittet av artiklar i grupper.</td></tr>
            <tr><td>Viktad bruttomarginal</td><td>Bruttomarginalen (marginal mot bruttopriset) viktad efter försäljningen under senaste året.</td></tr>
        </table>
        <%
        rs = con.createStatement().executeQuery(
"select a.kod, rk.beskrivning, count(*) as antalartiklar,round(min((utpris-innetto)/utpris)*100) as mintb, round(avg((utpris-innetto)/utpris)*100) as medeltb \n" +
", round(min((utpris-innetto)/utpris)*100) - round(avg((utpris-innetto)/utpris)*100) as difftb\n" +
"--, case when sum(f.antal)<>0 then sum(f.antal*(a.utpris-a.innetto))/sum(f.antal) else 0 end\n" +
",ROUND(sum(f.summa)) as omsattning\n" +
",round(case when sum((f.antal*a.utpris)) <> 0 then sum(case when f.antal <> 0 then f.antal*(a.utpris-a.innetto) else 0 end)/sum(case when f.antal <> 0 then (f.antal*a.utpris) else 0 end) else 0 end*100) as viktadtb\n" +
"from \n" +
"( select *, rpad(coalesce(rabkod,''),5,' ') || '-' || rpad(coalesce(kod1,''),5,' ')  as kod, inpris*(1-rab/100)*(1+inp_fraktproc/100)+inp_frakt+inp_miljo as innetto from artikel) a left outer join\n" +
"( select *, rpad(coalesce(rabkod,''),5,' ') || '-' || rpad(coalesce(kod1,''),5,' ')  as kod from rabkoder) rk on rk.kod=a.kod\n" +
"left outer join (select artnr, coalesce(sum(f2.LEV),0) as antal, sum(coalesce(f2.summa,0)) as summa from faktura1 f1 join faktura2 f2 on f1.faktnr=f2.faktnr and f1.datum > current_date-365 group by f2.artnr) f on f.artnr=a.nummer\n" +
"where utpris <> 0 and utgattdatum is null group by a.kod, rk.beskrivning\n" +
"order by a.kod, round(min((utpris-innetto)/utpris)*100) - round(avg((utpris-innetto)/utpris)*100), a.kod"
        );
        %>
        <table class="list">
            <tr><th>Rabattkod</th><th>Beskrivning</th><th>Antal artiklar</th><th>Omsättning (tkr)</th><th>Lägsta bruttomarginal</th><th>Medel bruttomarginal</th><th>Viktad bruttomarginal</th></tr>
            <% while (rs.next()) { %>
                <tr>
                    <td><%= SXUtil.toHtml(rs.getString("kod")) %></td>
                    <td><%= SXUtil.toHtml(rs.getString("beskrivning")) %></td>
                    <td style="text-align: right"><%= rs.getInt("antalartiklar") %></td>
                    <td style="text-align: right"><%= rs.getInt("omsattning")/1000 %></td>
                    <td style="text-align: right"><%= rs.getInt("mintb") %></td>
                    <td style="text-align: right"><%= rs.getInt("medeltb") %></td>
                    <td style="text-align: right"><%= rs.getInt("viktadtb") %></td>
                </tr>
            <% } %>
        </table>
    
    
    
    
    </body>
</html>
