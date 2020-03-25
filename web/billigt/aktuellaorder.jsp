<%-- 
    Document   : aktuellaorder
    Created on : 2020-mar-22, 07:49:07
    Author     : ulf
--%>
<%@page import="se.saljex.sxlibrary.SXUtil"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="se.saljex.webutil.billigt.BilligtData"%>
<%@page import="se.saljex.webutil.Const"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%
Connection con = Const.getConnection(request);
PreparedStatement ps;

String q  = "select * from (\n" +
"select o1.ordernr, o1.datum, o1.status, o1.levadr1, o1.levadr2, o1.levadr3, o1.marke, o2.artnr, o2.namn as artnamn, o2.best, o2.pos,\n" +
"case when o1.status in ('Samfak','Klar') then o2.best else coalesce(wp.bekraftat, po.quantityconfirmed) end as behandlat,\n" +
"coalesce(wp.crts,po.creationdate) as behandlatdatum\n" +
"from order1 o1 join order2 o2 on o1.ordernr=o2.ordernr\n" +
"left outer join (select masterordername, hostidentification, materialname, max(creationdate) as creationdate, sum(quantityconfirmed) as quantityconfirmed from ppgorderpick where motivetype in (0,2) group by masterordername, hostidentification, materialname) po on po.masterordername='AB-' || o1.ordernr and o2.artnr=po.materialname and po.hostidentification is not null and po.hostidentification <> '' and po.hostidentification::integer=o2.pos \n" +
"left outer join wmsorderplock wp on wp.wmsordernr='AB-' || o1.ordernr and o2.artnr=wp.artnr and wp.pos=o2.pos\n" +
"where o1.kundnr=?\n" +
"\n" +
"union all\n" +
"\n" +
"select u1.ordernr, u1.datum, 'Fakturerad', u1.levadr1, u1.levadr2, u1.levadr3, u1.marke, f2.artnr, f2.namn, f2.lev, f2.pos,\n" +
"f2.lev, f1.datum::timestamp\n" +
"from faktura1 f1 join faktura2 f2 on f1.faktnr=f2.faktnr join utlev1 u1 on u1.ordernr=f2.ordernr\n" +
"where f1.kundnr = ? and f1.datum >= current_date - 7\n" +
") o\n"
        + " where o.artnr is not null and o.artnr <> '' " +
"order by case when status = 'Sparad' then 0 else case when status='Direkt' then 2 else case when status='Utskr' then 10 else case when status in ('Samfak','Klar') then 20 else 100 end end end end, status, ordernr, pos";

ps = con.prepareStatement(q);
ps.setString(1, BilligtData.getKundnr());
ps.setString(2, BilligtData.getKundnr());
ResultSet rs = ps.executeQuery();
Integer oldOrdernr=null;
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Aktuella ordrar</title>
        <script>
            function toggleOrder(r) {
                var x = document.getElementById("o" + r);
                if (x.style.display === "none") {
                  x.style.display = "table";
                } else {
                  x.style.display = "none";
                }            
            }
            function visaAlla() {
                for (cn = 1; cn < 10000; cn++) {
                    var x = document.getElementById("o" + cn);
                    if (x!=null) x.style.display = "table"; else break;
                }
            }
            </script>
            
        <style>
            .right { text-align: right; }
            .bgg { background-color: lightgray; }
            .bgb { background-color: lightcyan; }
            .varningsfarg { color: red; }
            .orderhuvudinfo { font-weight: bold; }
            .t-rubrik { font-size: 50%; font-weight: bold;}
            .hide { visibility: hidden; }
            table {
                border-collapse: collapse;
                width: 100%;
            }
            
        </style>           
    </head>
    <%
        String bb;
        boolean bglage = true;
        int prevOrdernr=0;
        %>
    <body>
        <p>Visar samtliga aktuella ordrar, samt ordrar fakturerade de senaste 7 dagarna. </p>
        <p><button onclick="visaAlla()">Visa alla</button></p>
        
        
       <table>
           <tr class="t-rubrik"><td>Status</td>><td>Ordernr</td><td>Orderdat</td><td>Märke</td></tr>
        <% boolean slutetNatt = false; %>
        <% slutetNatt = !rs.next(); %>
        <% int cn=0; %>
        <% while (!slutetNatt) { %>
            <% prevOrdernr = rs.getInt("ordernr"); %>
            <% bglage = !bglage; %>
            <% cn++; %>
            <tr class="orderhuvudinfo <%= bglage ? "bgg" : "bgb" %>">
                 <td><%= SXUtil.toHtml(rs.getString("status")) %></td>
                 <td><%= rs.getInt("ordernr") %></td>
                 <td><%= rs.getString("datum") %></td>
                 <td><%= SXUtil.toHtml(rs.getString("marke")) %></td>
                 <td><button onclick="toggleOrder(<%= cn %>)">Visa</button></td>
            </tr>
            <tr class="<%= bglage ? "bgg" : "bgb" %>"  >
                <td></td>
                <td colspan="5"><table id="o<%= cn %>" style="display: none">
                        <tr class="t-rubrik"><td style="width: 15em;">Artnr</td><td style="width: 44em;">Namn</td><td style="width: 10em;">Beställt</td><td style="width: 10em;">Behandlat</td><td style="">Beh.datum</td></tr>
            <% while (true) { 
                Double best; 
                best = rs.getDouble("best");
                if (rs.wasNull()) best = null;
                Double behandlat; 
                behandlat = rs.getDouble("behandlat"); 
                if (rs.wasNull()) behandlat = null;
            %>
                <tr class="<%= (best != null && behandlat!=null && behandlat.compareTo(best) < 0  ) ? "varningsfarg" : "" %>">
                    <td><%= SXUtil.toHtml(rs.getString("artnr")) %></td>
                    <td><%= SXUtil.toHtml(rs.getString("artnamn")) %></td>
                    <td><%= best == null ? "" : SXUtil.getFormatNumber(best) %></td>
                    <td><%= behandlat == null ? "" : SXUtil.getFormatNumber(behandlat) %></td>
                    <td><%= SXUtil.toHtml(rs.getString("behandlatdatum")) %></td>
                </tr>
                <% 
                    if(!rs.next()) { slutetNatt=true; break; }
                    if (prevOrdernr != rs.getInt("ordernr")) break; %>
            <% } %>
            
            
            </table></td>
            </tr>
       <% } %>
       </table>
        
    </body>
</html>
