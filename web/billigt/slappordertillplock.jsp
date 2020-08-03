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

if ("tillplock".equals(request.getParameter("ac"))) {
    int ordernr=0;
    try {ordernr = Integer.parseInt(request.getParameter("ordernr")); }catch (Exception e) {}
    if (ordernr!=0) {
        con.setAutoCommit(false);
        int r = con.createStatement().executeUpdate("update order1 set status = 'Sparad' where ordernr=" + ordernr + " and status='Avvakt'");
        if (r!=0) {
            con.createStatement().executeUpdate("insert into orderhand (ordernr, datum, tid, anvandare, handelse, transportor, fraktsedelnr, nyordernr, antalkolli, kollislag, totalvikt, serverdatum) values ("+ ordernr + ", current_date, current_time, '00', 'Ändrad', '', '', 0, 0, '', 0, current_timestamp);");
        }
        con.commit();
        con.setAutoCommit(true);
    }
}

String q  = "select *,\n" +
"case when ilager00-iorder00+best < best and best > 0 then 'Lagerbrist. ' else '' end " +
" || case when pris = 0 and best > 0 then 'Priset är fel. ' else '' end " +
" || case when utgattdatum is not null then 'Artikeln har utgått. ' else '' end " + 
" || case when (artlev='' or artlev is null) and artnr not like '*%' and artnr not like '' and artnr is not null then 'Leverantör saknas ' else '' end " + 
" || case when minsaljpack > 0 and best::numeric % minsaljpack::numeric <> 0  then 'Enhetsfel. Minsta försäljningsförpackning= ' || minsaljpack || ' ' || artenhet || ' ' else '' end " + 
" as varning \n" +
"from (\n" +
"select o1.ordernr, o1.datum, o1.status, o1.levadr1, o1.levadr2, o1.levadr3, o1.marke, o2.artnr, o2.namn as artnamn, o2.best, o2.pos, o2.pris, a.utgattdatum, a.lev as artlev, a.minsaljpack, a.enhet as artenhet, \n" +
"sum(case when l.lagernr=0 then iorder else case when stj.stjid > 0 then stj.antal else 0 end end) as iorder00,\n" +
"sum(case when l.lagernr=0 then l.best else case when stj.BESTDAT IS NOT NULL and stj.finnsilager = 0 then stj.antal else 0 end end) as best00,\n" +
"sum(case when l.lagernr=0 then ilager else case when stj.finnsilager > 0 then stj.antal else 0 end end) as ilager00,\n" +
"\n" +
"sum(case when l.lagernr=1 then iorder else 0 end) as iorder01,\n" +
"sum(case when l.lagernr=1 then l.best else 0 end) as best01,\n" +
"sum(case when l.lagernr=1 then ilager else 0 end) as ilager01,\n" +
"\n" +
"sum(case when l.lagernr=3 then iorder else 0 end) as iorder03,\n" +
"sum(case when l.lagernr=3 then l.best else 0 end) as best03,\n" +
"sum(case when l.lagernr=3 then ilager else 0 end) as ilager03,\n" +
"\n" +
"sum(case when l.lagernr=4 then iorder else 0 end) as iorder04,\n" +
"sum(case when l.lagernr=4 then l.best else 0 end) as best04,\n" +
"sum(case when l.lagernr=4 then ilager else 0 end) as ilager04,\n" +
"\n" +
"sum(case when l.lagernr=10 then iorder else 0 end) as iorder10,\n" +
"sum(case when l.lagernr=10 then l.best else 0 end) as best10,\n" +
"sum(case when l.lagernr=10 then ilager else 0 end) as ilager10\n" +
"\n" +
"from order1 o1 join order2 o2 on o1.ordernr=o2.ordernr left outer join artikel a on a.nummer=o2.artnr \n" +
"LEFT OUTER JOIN LAGER L on l.artnr=o2.artnr " +
" left outer join stjarnrad stj on stj.stjid = o2.stjid " +
"where o1.kundnr=? and o2.artnr <> '' and o2.artnr is not null and status in ('Avvakt','Sparad') \n" +
"group by o1.ordernr, o2.artnr, o2.namn, o2.best, o2.pos, o2.pris, a.utgattdatum, a.lev, a.minsaljpack, a.enhet " +
") o\n" +
"order by case when status = 'Sparad' then 10 else case when status='Avvakt' then 0 else case when status='Utskr' then 20 else case when status in ('Samfak','Klar') then 20 else 100 end end end end, status, ordernr, pos\n";

ps = con.prepareStatement(q);
ps.setString(1, BilligtData.getKundnr());
ResultSet rs = ps.executeQuery();
Integer oldOrdernr=null;
%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Order</title>
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
            function skickaOrderTillPlock(ordernr) {
                document.getElementById("form_ordernr").value = ""+ordernr;
                document.getElementById("form").submit();
                return false;
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
            .tillplock {
                cursor: pointer;
                color: blue;
                text-decoration: underline;
            }
        </style>           
    </head>
    <%
        String bb;
        boolean bglage = true;
        int prevOrdernr=0;
        %>
    <body>
        <p>Visar sparade och avvaktande ordrar </p>
        
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
                 <td>
                     <% if ("Avvakt".equals(rs.getString("status"))) { %>
                        <p class="tillplock"  onclick="skickaOrderTillPlock(<%= rs.getInt("ordernr") %>)" >Till plock</p> 
                     <% } %> 
                 </td>
            </tr>
            <tr class="<%= bglage ? "bgg" : "bgb" %>"  >
                <td></td>
                <td colspan="5"><table id="o<%= cn %>" >
                        <tr class="t-rubrik"><td style="width: 15em;">Artnr</td><td style="width: 44em;">Namn</td>
                            <td style="width: 10em;">Lager 01</td>
                            <td style="width: 10em;">Lager 03</td>
                            <td style="width: 10em;">Lager 04</td>
                            <td style="width: 10em;">Lager 10</td>
                            <td style="width: 10em;">Beställt 00</td>
                            <td style="width: 10em;">I order 00</td>
                            <td style="width: 10em;">Lager 00</td>
                            <td style="width: 10em;">Antal order</td>
                            <td style="">Varning</td></tr>
            <% while (true) { 
            %>
            <tr class="<%= rs.getString("varning").equals("")  ? "" : "varningsfarg" %>">
                    <td><%= SXUtil.toHtml(rs.getString("artnr")) %></td>
                    <td><%= SXUtil.toHtml(rs.getString("artnamn")) %></td>
                    <td><%= SXUtil.getFormatNumber(rs.getDouble("ilager01")) %></td>
                    <td><%= SXUtil.getFormatNumber(rs.getDouble("ilager03")) %></td>
                    <td><%= SXUtil.getFormatNumber(rs.getDouble("ilager04")) %></td>
                    <td><%= SXUtil.getFormatNumber(rs.getDouble("ilager10")) %></td>
                    <td><%= SXUtil.getFormatNumber(rs.getDouble("best00")) %></td>
                    <td><%= SXUtil.getFormatNumber(rs.getDouble("iorder00")) %></td>
                    <td><%= SXUtil.getFormatNumber(rs.getDouble("ilager00")) %></td>
                    <td><%= SXUtil.getFormatNumber(rs.getDouble("best")) %></td>
                    <td><%= SXUtil.toHtml(rs.getString("varning")) %></td>
                </tr>
                <% 
                    if(!rs.next()) { slutetNatt=true; break; }
                    if (prevOrdernr != rs.getInt("ordernr")) break; %>
            <% } %>
            
            
            </table></td>
            </tr>
       <% } %>
       </table>
       <form method="post" id="form"> 
           <input type="hidden" id="form_ac" name="ac" value="tillplock">
           <input type="hidden" id="form_ordernr" name="ordernr">
       </form>
    </body>
</html>
