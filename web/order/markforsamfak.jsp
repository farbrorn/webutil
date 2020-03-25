<%-- 
    Document   : markforsamfak
    Created on : 2020-mar-24, 08:19:34
    Author     : ulf
--%>

<%@page import="se.saljex.sxlibrary.SXUtil"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="se.saljex.webutil.Const"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%
    int lagernr=0;
    try { lagernr=Integer.parseInt(request.getParameter("lagernr")); } catch(Exception e) {}
Connection con = Const.getConnection(request);
PreparedStatement ps;

String q  = "select *, "
        + "sum(case when radvarning <> '' then 1 else 0 end) over (partition by wmsordernr) as radvarningfinns "
        + " from ( " +
        "select o1.wmsordernr, o1.datum, O1.TIDIGASTFAKTDATUM, O1.ORDERMEDDELANDE, o1.status, o1.namn, o1.marke, o1.fraktbolag, o1.fraktfrigrans, o2.pos, o2.artnr, o2.namn as artnamn, o2.best, o2.enh, o2.pris, o2.rab, o2.text, o2.netto, o2.stjid,\n" +
"case when o2.best > 0 and coalesce(o2.pris,0)=0 and o2.artnr not like '*UD%' and o2.artnr is not null and trim(o2.artnr) <> '' then 'Priset är 0:-. ' else '' end ||\n" +
"case when o2.best>0 and o2.artnr is not null and o2.artnr not like '*UD%' and trim(o2.artnr) <> '' and o2.pris * (1-o2.rab/100) < o2.netto then 'Försäljningspriset är mindre än inköpspriset. ' else '' end as radvarning,\n" +
"CASE when upper(o1.fraktbolag) not in ('TURBIL', 'HÄMTAS', 'HOT PICK')  then\n" +
"    case when sum(o2.summa) over (partition by o2.wmsordernr) < o1.fraktfrigrans and sum(case when upper(o2.namn) like 'FRAKT%' then o2.summa else 0 end) over (partition by o2.wmsordernr) <= 0   then\n" +
"        'Ordern når inte upp till fraktfritt. '\n" +
"    else\n" +
"        case when sum(case when a.fraktvillkor > 0 then 1 else 0 end) over (partition by o2.wmsordernr) > 0 and sum(case when upper(o2.namn) like 'FRAKT%' then o2.summa else 0 end) over (partition by o2.wmsordernr) <= 0 then\n" +
"            'Ordern innehåller skrymmegods, men fraktkostnad saknas. '\n" +
"        else \n" +
"            ''\n" +
"        end\n" +
"    end\n" +
"else '' \n" +
"end\n" +
" || case when current_date < TIDIGASTFAKTDATUM then ' Order skall faktureras efter ' || TIDIGASTFAKTDATUM || ' ' else '' end "+
"as ordervarning\n" +
"\n" +
"from wmsorder1 o1 join wmsorder2 o2 on o1.wmsordernr=o1.wmsordernr and o1.orgordernr=o2.orgordernr\n" +
"join \n" +
"(\n" +
"select 'AB' as wmsprefix, * from sxfakt.kund\n" +
"union all\n" +
"select 'AS' as wmsprefix, * from sxasfakt.kund\n" +
") k on wmsprefix=substring(o1.wmsordernr,1,2) and k.nummer=o1.kundnr\n" +
"left outer join sxfakt.artikel a on a.nummer=o2.artnr\n" +
"left outer join lager l on l.lagernr=o1.lagernr and l.artnr=o2.artnr\n" +
"left outer join (\n" +
"select 'AB' as wmsprefix, ordernr, max(case when handelse = 'WMS' then serverdatum else null end) as wmsdatum, max(case when handelse = 'WMS Plockad' then serverdatum else null end) as wmsplockaddatum, max(case when handelse = 'WMS Lastad' then serverdatum else null end) as wmslastaddatum \n" +
"from sxfakt.orderhand group by ordernr\n" +
"union all\n" +
"select 'AS' as wmsprefix, ordernr, max(case when handelse = 'WMS' then serverdatum else null end) as wmsdatum, max(case when handelse = 'WMS Plockad' then serverdatum else null end) as wmsplockaddatum, max(case when handelse = 'WMS Lastad' then serverdatum else null end) as wmslastaddatum \n" +
"from sxasfakt.orderhand group by ordernr\n" +
") hh on hh.wmsprefix=substring(o1.wmsordernr, 1,2) and hh.ordernr=o1.orgordernr\n" +
"where o1.status in ('Klar', 'Samfak') and o1.lagernr=" + lagernr + " ) o order by wmsordernr" ;

ps = con.prepareStatement(q);
ResultSet rs = ps.executeQuery();
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Markera för samfakt</title>
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
            function markUtanVarning() {
                for (cn = 1; cn < 10000; cn++) {
                    
                    var x = document.getElementById("varning-" + cn);
                    if (x!=null) {
                        if (x.innerHTML.trim()=='') {
                            document.getElementById("marksamfakt-" + cn).checked = true;
                        }
                    } else break;
                }
            }
            function inteKlart() {
                alert("Funktionen är inte klar");
            }
            </script>
            
        <style>
            .right { text-align: right; }
            .bgg { background-color: lightblue; }
            .bgb { background-color: lightcyan; }
            .varningsfarg { color: red; }
            .orderhuvudinfo { font-weight: bold; height: 1.8em;}
            .t-rubrik { font-size: 50%; font-weight: bold;}
            .t-o2 { margin-bottom: 1em;}
            .hide { visibility: hidden; }
            .checkbox { width: 18px; height: 18px; }
            table {
                border-collapse: collapse;
                width: 100%;
            }
           
            td { padding-right: 8px; }
            th { padding-right: 8px; text-align: left;}
        </style>           
    </head>
    <%
        String bb;
        boolean bglage = true;
        String prevOrdernr="";
    %>
    <body>
        <div style="position: fixed; top: 0; width: 100%; background: white;height: 110px; overflow-y:  hidden">
        <p>Visar klara ordrar för lager <%= lagernr %></p>
        <p>
            <button onclick="visaAlla()">Visa alla</button>
            <button onclick="markUtanVarning()">Markera alla utan varning</button>
            <button onclick="inteKlart()">Skicka till samfakt</button>
        </p>
       <table>
           <colgroup>
               <col style="width: 70px;">
               <col style="width: 90px;">
               <col style="width: 90px;">
               <col style="width: 290px;">
               <col style="width: 180px;">
               <col style="width: 40px;">
            </colgroup>
           <tr>
               <th>Status</th>
               <th>Ordernr</th>
               <th>Orderdat</th>
               <th>Kund</th>
               <th>Varning</th>
               <th>OK</th>
               <th></th>
           </tr>
       </table>
        </div>
        <div style="padding-top: 110px;">
       <table>
           <colgroup>
               <col style="width: 70px;">
               <col style="width: 90px;">
               <col style="width: 90px;">
               <col style="width: 290px;">
               <col style="width: 180px;">
               <col style="width: 40px;">
            </colgroup>
        <% boolean slutetNatt = false; %>
        <% slutetNatt = !rs.next(); %>
        <% int cn=0; %>
        <% while (!slutetNatt) { %>
            <% prevOrdernr = rs.getString("wmsordernr"); %>
            <% bglage = !bglage; %>
            <% cn++; %>
            <tr class="orderhuvudinfo <%= bglage ? "bgg" : "bgb" %> <%= !"".equals(rs.getString("ordervarning")) || rs.getInt("radvarningfinns") > 0 ? "varningsfarg" : "" %>">
                <td><%= SXUtil.toHtml(rs.getString("status")) %></td>
                 <td><%= rs.getString("wmsordernr") %></td>
                 <td><%= rs.getString("datum") %></td>
                 <td><%= SXUtil.toHtml(rs.getString("namn")) %></td>
                 <td id="varning-<%= cn %>"><%= SXUtil.toHtml(rs.getString("ordervarning") + " " + (rs.getInt("radvarningfinns") > 0 ? "Radfel" : "")) %></td>
                 
                 <td><input class="checkbox" id="marksamfakt-<%= cn %>" name="marksamfakt" value="<%= rs.getString("wmsordernr") %>" type="checkbox" ></td>
                 <td><button onclick="toggleOrder(<%= cn %>)">Visa</button></td>
            </tr>
            <tr>
                <% if (!"".equals(SXUtil.toStr(rs.getString("ordermeddelande")))) { %>
                <td colspan="6">
                        <%= SXUtil.toHtml(rs.getString("ordermeddelande")) %>
                </td>
                <% } %>
            </tr>
            <tr class="<%= bglage ? "bgg" : "bgb" %>"  >
                <td></td>
                <td colspan="6"><table id="o<%= cn %>" class="t-o2" style="display: none">
                        <tr class="t-rubrik"><td style="width: 15em;">Artnr</td><td style="width: 44em;">Namn</td><td class="right" style="width: 9em;">Antal</td><td class="right" style="width: 10em;">Pris</td><td class="right" style="width: 4em;">%</td><td class="right" style="width: 10em;">Innetto</td><td>Not</td></tr>
            <% while (true) { 
            %>
            <tr class="<%= !"".equals(rs.getString("radvarning")) ? "varningsfarg" : "" %>">
                <% if (!"".equals(SXUtil.toStr(rs.getString("artnr")))) {%>
                    <td><%= SXUtil.toHtml(rs.getString("artnr")) %></td>
                    <td><%= SXUtil.toHtml(rs.getString("artnamn")) %></td>
                    <td class="right"><%= SXUtil.getFormatNumber(rs.getDouble("best")) %></td>
                    <td class="right"><%= SXUtil.getFormatNumber(rs.getDouble("pris")) %></td>
                    <td class="right"><%= SXUtil.getFormatNumber(rs.getDouble("rab"),0) %></td>
                    <td class="right"><%= SXUtil.getFormatNumber(rs.getDouble("netto")) %></td>
                    <td><%= SXUtil.toHtml(rs.getString("radvarning")) %></td>
                <% } else { %>
                    <td colspan="6"><%= SXUtil.toHtml(rs.getString("text")) %></td>
                <%  } %>
                </tr>
                <% 
                    if(!rs.next()) { slutetNatt=true; break; }
                    if (!prevOrdernr.equals(rs.getString("wmsordernr"))) break; %>
            <% } %>
            
            
            </table></td>
            </tr>
       <% } %>
       </table>
        </div>
    </body>
</html>
