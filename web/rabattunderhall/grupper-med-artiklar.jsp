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
        <title>Rabattgrupper med artiklar</title>
        <script>
            function tgl(id) {
                var a = document.getElementById("g"+id);
                if (a.style.display === "none") a.style.display = "table"; else a.style.display = "none";
            }
            
        </script>
        <style>
            .list {
                border-collapse: collapse;
            }
            th {
                font-size: 60%;
            }
            .td-kod {
                font-weight: bold;
            }
            .t-a {
                width: 100%;
            }
            .t-a td {
                border-bottom: 1px solid grey;
            }
        </style>
    </head>
    
    <body>
        <%@include file="/WEB-INF/sxheader.jsp" %>
        <h1>Rabattgrupper</h1>
    
        <%
        rs = con.createStatement().executeQuery(
"select a.kod, rk.beskrivning, a.nummer, a.namn, round((utpris-innetto)/utpris*100)::integer as tb, round(f.summa)::integer as omsattning\n" +
"from \n" +
"( select *, rpad(coalesce(rabkod,''),5,' ') || '-' || rpad(coalesce(kod1,''),5,' ')  as kod, inpris*(1-rab/100)*(1+inp_fraktproc/100)+inp_frakt+inp_miljo as innetto from artikel) a join\n" +
"( select *, rpad(coalesce(rabkod,''),5,' ') || '-' || rpad(coalesce(kod1,''),5,' ')  as kod from rabkoder) rk on rk.kod=a.kod\n" +
"left outer join (select artnr, coalesce(sum(f2.LEV),0) as antal, sum(coalesce(f2.summa,0)) as summa from faktura1 f1 join faktura2 f2 on f1.faktnr=f2.faktnr and f1.datum > current_date-365 group by f2.artnr) f on f.artnr=a.nummer\n" +
"where utpris <> 0 and utgattdatum is null \n" +
"order by a.kod, a.nummer"
                
        );
        %>
        <table class="list">
            <tr><th>Rabattkod</th><th>Beskrivning</th></tr>
            <% String tempKod=null;
            int gruppCn=0;
            String kod;
            while (rs.next()) {
                kod = rs.getString("kod");
                if (tempKod==null || !tempKod.equals(kod))  {
                    if (tempKod!=null) { %> </table></td></tr> <%    }
                  tempKod=kod;
                  gruppCn++;
            %>
                <tr>
                    <td class="td-kod"><%= SXUtil.toHtml(rs.getString("kod")) %></td>
                    <td class="td-kod"><%= SXUtil.toHtml(rs.getString("beskrivning")) %></td>
                    <td><a onclick="tgl(<%= gruppCn %>)">Visa/Dölj</a></td>
                </tr>
                <tr>
                    <td></td><td colspan="3"><table class="t-a" id="g<%= gruppCn %>" style="display: none;">
                            <tr><th>Art.nr</th><th>Benämning</th><th>Bruttomarginal</th><th>Omsättning år -1</th></tr>
            <% } %>
                <tr>
                    <td><%= SXUtil.toHtml(rs.getString("nummer")) %></td>
                    <td><%= SXUtil.toHtml(rs.getString("namn")) %></td>
                    <td style="text-align: right"><%= rs.getInt("tb") %></td>
                    <td style="text-align: right"><%= rs.getInt("omsattning") %></td>
                </tr>
            <% } %>
        </table>
    
    
    
    
    </body>
</html>
