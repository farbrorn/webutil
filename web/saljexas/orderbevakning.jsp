<%-- 
    Document   : orderbevakning
    Created on : 2020-apr-15, 12:46:14
    Author     : Ulf Berg
--%>

<%@page import="java.text.SimpleDateFormat"%>
<%@page import="se.saljex.sxlibrary.SXUtil"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%
    SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    Connection con=null;
    try { con = (Connection)request.getAttribute("sxconnection"); } catch (Exception e) {}
    Statement stm;
    stm = con.createStatement();
    ResultSet rs = stm.executeQuery("SELECT o1.ordernr, o1.datum, o1.status, o1.kundnr, o1.namn as kundnamn, o1.levadr1, o1.levadr2, o1.levadr3, o1.marke, oh.wmsdatum as wmsdatum, oh.wmsplockdatum as wmsplockdatum, oh.skapaddatum, \n" +
"o2.artnr, o2.namn as artnamn, o2.lev, o2.enh, wop.ilager, wop.best, wop.bekraftat, wop.best-wop.bekraftat as avvikelse, wop.crts as radplockaddatum,\n" +
"case when wop.best > 0 and wop.bekraftat < wop.best then case when ilager > bekraftat then '* * * Varning: Restnoterat men fanns i lager vid plocktillfälle. * * *' else 'Varning: Restnoterat' end else null end as varning\n" +
"FROM SXASFAKT.ORDER1 o1 left outer join sxasfakt.order2 o2 on o1.ordernr=o2.ordernr\n" +
"LEFT OUTER JOIN WMSORDERPLOCK WOP  on wmsordernr2int(wmsordernr) = o1.ordernr and wop.wmsordernr like 'AS-%' and wop.pos=o2.pos and wop.artnr=o2.artnr\n" +
"left outer join (\n" +
"	select ordernr, \n" +
"	max( case when handelse = 'WMS' then serverdatum else null end) as wmsdatum,\n" +
"	max(case when handelse = 'WMS Plockad' then serverdatum else null end) as wmsplockdatum, \n" +
"	min(case when handelse = 'Skapad' then serverdatum else null end) as skapaddatum\n" +
"	from sxasfakt.orderhand where handelse in ('WMS', 'WMS Plockad','Skapad') group by ordernr \n" +
") oh on oh.ordernr=o1.ordernr\n" +
"order by case when status = 'Sparad' then 30 else case when status = 'Utskr' then 20 else case when status = 'Plckad' then 10 else 1000 end end end, o1.ordernr desc, o2.pos"
);
    
%>
    
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Orderbevakning</title>
        <style>
            table {
                border-collapse: collapse;
            }
            table th {
                font-size: 70%;
                text-align: left;
            }
            .trodd {
                background-color: lightblue;
            }
            .treven {
                background-color: lightgray;
            }
            .right {
                text-align: right;
            }
        </style>
        <script>
function tv(id) {
    var x = document.getElementById(id);
  if (x.style.display === "none") {
    x.style.display = "table-row";
  } else {
    x.style.display = "none";
  }
}            
            </script>
    </head>
    <body>
<% int cn=0; %>
<% int currOrdernr = 0; %>
<% String currStatus = null; %>
<% boolean odd=false; %>
<table  style="width: 100%">
    <tr><th style="width: 8em">Ordernr</th><th style="width: 8em">Datum</th><th style="width: 24em">Kund</th><th style="width: 24em">Lev.adr</th><th style="width: 24em">Märke</th><th></th></tr>
<% while (rs.next()) { %>
    <% cn++; %>
    <% if (currOrdernr != rs.getInt("ordernr")) { %>
        <% odd=!odd; %>
        <% if (currOrdernr != 0) { %>
                </table>    
            </td></tr>
        <% } %>
        <% if (currStatus==null || !currStatus.equals(rs.getString("status") )) { 
            currStatus=rs.getString("status");
        %>
            <tr><td colspan="6"><p style="font-size: 130%; font-weight: bold;"><%= SXUtil.toHtml(rs.getString("status")) %></p></td></tr>
        <%  } %>
        <% currOrdernr = rs.getInt("ordernr"); %>
        <tr class="<%= odd ? "trodd" : "treven" %>" style="font-weight: bold;">
            <td><a onclick="tv('tr<%= cn %>')"><%= rs.getInt("ordernr") %></a></td>
            <td><%= rs.getString("datum") %></td>
            <td><%= SXUtil.toHtml(rs.getString("kundnamn")) %></td>
            <td><%= SXUtil.toHtml(rs.getString("levadr3")) %></td>
            <td><%= SXUtil.toHtml(rs.getString("marke")) %></td>
            <td style="font-weight: normal;">
                <table>
                    <tr><td>Skapad</td><td><%= rs.getTimestamp("skapaddatum")==null ? "" : SXUtil.toHtml(df.format(rs.getTimestamp("skapaddatum"))) %></td></tr>
                    <tr><td>Till WMS-plock</td><td><%= rs.getTimestamp("wmsdatum")==null ? "" : SXUtil.toHtml(df.format(rs.getTimestamp("wmsdatum"))) %></td></tr>
                    <tr><td>Plockad</td><td><%= rs.getTimestamp("wmsplockdatum")==null ? "" : SXUtil.toHtml(df.format(rs.getTimestamp("wmsplockdatum"))) %></td></tr>
                </table>
            </td>
        </tr>
        <tr id="tr<%= cn %>" class="<%= odd ? "trodd" : "treven" %>"><td></td><td colspan="7">
                <table>
                    <tr><th style="width: 10em">Artnr</th><th  style="width: 30em">Benämning</th><th class="right" style="width: 8em">I lager vid plock</th><th class="right" style="width: 8em">Önskat antal</th><th class="right" style="width: 8em">Plockat antal</th><th style="width: 24em"></th><th>Plocktid</th></tr>
    <% }%>
                    <tr style="<%= rs.getString("varning") != null ? "color: red" : "" %>">
                        <td><%= SXUtil.toHtml(rs.getString("artnr")) %></td>
                        <td><%= SXUtil.toHtml(rs.getString("artnamn")) %></td>
                        <% Double antal; %>
                        <% antal = rs.getDouble("ilager"); %>
                        <% if (rs.wasNull()) antal = null; %>
                        <td class="right"><%= antal==null ? "" : SXUtil.getFormatNumber(antal) %></td>
                        <% antal = rs.getDouble("best"); %>
                        <% if (rs.wasNull()) antal = rs.getDouble("lev"); %>
                        <td class="right"><%= SXUtil.getFormatNumber(antal) %></td>
                        <% antal = rs.getDouble("bekraftat"); %>
                        <% if (rs.wasNull()) antal = null; %>
                        <td class="right"><%= antal==null ? "" : SXUtil.getFormatNumber(rs.getDouble("bekraftat")) %></td>
                        <td><%= SXUtil.toHtml(rs.getString("varning")) %></td>
                        <td><%= rs.getTimestamp("radplockaddatum") == null ? "" : SXUtil.toHtml(df.format(rs.getTimestamp("radplockaddatum"))) %></td>
                    </tr>
<% }%>
</table>
    </body>
</html>
