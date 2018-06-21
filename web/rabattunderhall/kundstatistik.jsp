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
  //  Statement st = con.createStatement();
    ResultSet rs;
    String kundnr = request.getParameter("kundnr");
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
        <h1>Kundstatistik</h1>
    
        <%
    
    
        ps = con.prepareStatement(
"select k.nummer, k.namn, rk.kod, rk.beskrivning, kr.rab, kr.datum, greatest(k.basrab, krgrupp.rab, kr.rab) effektivrabatt, bb.inkopar1, bb.inkopar2, bb.inkopar3, bb.inkopar4, bb.inkopar5, bb.tbar1, bb.tbar2, bb.tbar3, bb.tbar4, bb.tbar5  \n" +
"from kund k \n" +
"join ( select *, rpad(coalesce(rabkod,''),5,' ') || '-' || rpad(coalesce(kod1,''),5,' ') as kod from rabkoder) rk on 1=1\n" +
"left outer join ( select *, rpad(coalesce(rabkod,''),5,' ') || '-' || rpad(coalesce(kod1,''),5,' ') as kod from kunrab) kr on kr.kundnr=k.nummer and kr.kod=rk.kod\n" +
"left outer join\n" +
"(select f1.kundnr, rpad(coalesce(rabkod,''),5,' ') || '-' || rpad(coalesce(kod1,''),5,' ') as kod\n" +
", round(sum(case when f1.datum>current_date-365 then f2.summa else 0 end)) inkopar1\n" +
", round(sum(case when f1.datum between current_date-365*2 and current_date-365 then f2.summa else 0 end)) inkopar2\n" +
", round(sum(case when f1.datum between current_date-365*3 and current_date-365*2 then f2.summa else 0 end)) inkopar3\n" +
", round(sum(case when f1.datum between current_date-365*4 and current_date-365*3 then f2.summa else 0 end)) inkopar4\n" +
", round(sum(case when f1.datum between current_date-365*5 and current_date-365*4 then f2.summa else 0 end)) inkopar5\n" +
", round("
        + " case when sum(case when f1.datum>current_date-365 then f2.summa else 0 end) <> 0 then "
        + " sum(case when f1.datum>current_date-365 then f2.summa-case when f2.netto=0 then f2.summa else (f2.netto*f2.lev) end else 0 end) / "
        + " sum(case when f1.datum>current_date-365 then f2.summa else 0 end) * 100 "
        +" else 0 end"
        + " ) as tbar1 \n" +
", round("
        + " case when sum(case when f1.datum between current_date-365*2 and current_date-365 then f2.summa else 0 end) <> 0 then "
        + " sum(case when f1.datum between current_date-365*2 and current_date-365 then f2.summa-case when f2.netto=0 then f2.summa else (f2.netto*f2.lev) end else 0 end) / "
        + " sum(case when f1.datum between current_date-365*2 and current_date-365 then f2.summa else 0 end) * 100 "
        +" else 0 end"
        + " ) as tbar2 \n" +
", round("
        + " case when sum(case when f1.datum between current_date-365*3 and current_date-365*2 then f2.summa else 0 end) <> 0 then "
        + " sum(case when f1.datum between current_date-365*3 and current_date-365*2 then f2.summa-case when f2.netto=0 then f2.summa else (f2.netto*f2.lev) end else 0 end) / "
        + " sum(case when f1.datum between current_date-365*3 and current_date-365*2 then f2.summa else 0 end) * 100 "
        +" else 0 end"
        + " ) as tbar3 \n" +
", round("
        + " case when sum(case when f1.datum between current_date-365*4 and current_date-365*3 then f2.summa else 0 end) <> 0 then "
        + " sum(case when f1.datum between current_date-365*4 and current_date-365*3 then f2.summa-case when f2.netto=0 then f2.summa else (f2.netto*f2.lev) end else 0 end) / "
        + " sum(case when f1.datum between current_date-365*4 and current_date-365*3 then f2.summa else 0 end) * 100 "
        +" else 0 end"
        + " ) as tbar4 \n" +
", round("
        + " case when sum(case when f1.datum between current_date-365*5 and current_date-365*4 then f2.summa else 0 end) <> 0 then "
        + " sum(case when f1.datum between current_date-365*5 and current_date-365*4 then f2.summa-case when f2.netto=0 then f2.summa else (f2.netto*f2.lev) end else 0 end) / "
        + " sum(case when f1.datum between current_date-365*5 and current_date-365*4 then f2.summa else 0 end) * 100 "
        +" else 0 end"
        + " ) as tbar5 \n" +
" from\n" +
"faktura1 f1 join faktura2 f2 on f1.faktnr=f2.faktnr join artikel a on a.nummer=f2.artnr\n" +
" where f1.datum>current_date-365*5 \n" +
" group by f1.kundnr, a.rabkod, a.kod1 ORDER BY RABKOD, KOD1\n" +
") bb on k.nummer=bb.kundnr and bb.kod=rk.kod\n" +
"left outer join kunrab krgrupp on krgrupp.rabkod=rk.rabkod and krgrupp.kundnr=k.nummer and krgrupp.kod1 = ''\n" +
"\n" +
"where k.nummer=? \n" +
"order by k.nummer, kod\n"
        );
        
        ps.setString(1, kundnr);
        rs = ps.executeQuery();
    
        if (rs.next()) {
        %>
        <p>Kund: <%= SXUtil.toHtml(rs.getString("nummer")) %> <%= SXUtil.toHtml(rs.getString("namn")) %></p>

            <table class="list">
                <tr><th>Rabattkod</th><th>Beskrivning</th><th>Rabatt</th><th>Datum</th><th>effektiv rabatt</th>
                    <th>Inköp år -1</th>
                    <th>tb</th>
                    <th>Inköp år -2</th>
                    <th>tb</th>
                    <th>Inköp år -3</th>
                    <th>tb</th>
                    <th>Inköp år -4</th>
                    <th>tb</th>
                    <th>Inköp år -5</th></tr>
                    <th>tb</th>
                <% do  { %>
                    <tr>
                        <td><%= SXUtil.toHtml(rs.getString("kod")) %></td>
                        <td><%= SXUtil.toHtml(rs.getString("beskrivning")) %></td>
                        <td style="text-align: right"><%= rs.getInt("rab") %></td>
                        <td style="text-align: right"><%= SXUtil.toHtml(rs.getString("datum")) %></td>
                        <td style="text-align: right"><%= rs.getInt("effektivrabatt") %></td>
                        <td style="text-align: right"><%= rs.getInt("inkopar1")!=0 ? ""+rs.getInt("inkopar1") : ""%></td>
                        <td style="text-align: right"><%= rs.getInt("tbar1")!=0 ? ""+rs.getInt("tbar1")+"%" : ""%></td>
                        <td style="text-align: right"><%= rs.getInt("inkopar2")!=0 ? ""+rs.getInt("inkopar2") : ""%></td>
                        <td style="text-align: right"><%= rs.getInt("tbar2")!=0 ? ""+rs.getInt("tbar2")+"%" : ""%></td>
                        <td style="text-align: right"><%= rs.getInt("inkopar3")!=0 ? ""+rs.getInt("inkopar3") : ""%></td>
                        <td style="text-align: right"><%= rs.getInt("tbar3")!=0 ? ""+rs.getInt("tbar3")+"%" : ""%></td>
                        <td style="text-align: right"><%= rs.getInt("inkopar4")!=0 ? ""+rs.getInt("inkopar4") : ""%></td>
                        <td style="text-align: right"><%= rs.getInt("tbar4")!=0 ? ""+rs.getInt("tbar4")+"%" : ""%></td>
                        <td style="text-align: right"><%= rs.getInt("inkopar5")!=0 ? ""+rs.getInt("inkopar5") : ""%></td>
                        <td style="text-align: right"><%= rs.getInt("tbar5")!=0 ? ""+rs.getInt("tbar5")+"%" : ""%></td>
                    </tr>
                <% } while (rs.next());  %>

            </table>
        <% } else { %>
            <form>
                Kundnr: <input name="kundnr">
                <input type="submit">
            </form>
        <% } %>
    </body>
</html>
