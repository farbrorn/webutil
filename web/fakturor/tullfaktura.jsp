<%-- 
    Document   : kvarvarande-h-nummer
    Created on : 2012-dec-19, 08:11:27
    Author     : Ulf
--%>

<%@page import="se.saljex.sxlibrary.SXUtil"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="se.saljex.loginservice.LoginServiceConstants"%>
<%@page import="java.sql.Connection"%>
<%@page import="se.saljex.loginservice.User"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>


<%
		User user=null;
		Connection conSuper=null;
		Connection con=null;
		try { user  = (User)request.getSession().getAttribute(LoginServiceConstants.REQUEST_PARAMETER_SESSION_USER); } catch (Exception e) {}
		try { conSuper = (Connection)request.getAttribute("sxsuperuserconnection"); } catch (Exception e) {}
		try { con = (Connection)request.getAttribute("sxconnection"); } catch (Exception e) {}

		SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
		SimpleDateFormat timeFormatter = new SimpleDateFormat("HH:mm:ss");

                Integer faktnr=0;
                try { faktnr=Integer.parseInt(request.getParameter("faktnr")); } catch (Exception e) {}
                Integer totalVikt=0;
                try { totalVikt=Integer.parseInt(request.getParameter("vikt")); } catch (Exception e) {}
                Integer antalKolli=0;
                try { antalKolli=Integer.parseInt(request.getParameter("kolli")); } catch (Exception e) {}
                
                String ankomst = request.getParameter("ankomst");
                String bilregnr = request.getParameter("bilregnr");
                String meddelande = request.getParameter("meddelande");
                String gransort = request.getParameter("gransort");
                
                
                boolean saljexas=("true".equals(request.getParameter("saljexas")));
                boolean skrivInteEUUrsprung=("true".equals(request.getParameter("skrivinteeuursprung")));
                
                String prefix = saljexas ? "sxasfakt." : "sxfakt.";
                
                String levAdr1 = request.getParameter("levadr1");
                String levAdr2 = request.getParameter("levadr2");
                String levAdr3 = request.getParameter("levadr3");
                
                
                String valuta="Value";
%>			

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Tulldeklaration från faktura</title>
<style type="text/css">

table {
	table-layout: fixed;
	border-collapse: collapse;
}

table tr {
    vertical-align: top;
}

table th {
    text-align: left;
}




h2 {
    font-size: 150%;
    font-weight: bold;
    display: inline;
}


.sel {
    background-color: #ccffff;
}

.right {
    text-align: right;
}

</style>	
	</head>
	<body>
		
<%

    Statement stm;
    Statement stmF1;
    stm = con.createStatement();
    stmF1 = con.createStatement();
    ResultSet rsF1 = stmF1.executeQuery("select f1.*, k.regnr, FU.NAMN AS fu_namn, FU.ADR1 as fu_adr1, FU.ADR2 as fu_adr2, FU.ADR3 as fu_adr3 , fu.regnr as fu_regnr from " +
         prefix + "faktura1 f1 left outer join " + prefix + "kund k on k.nummer=f1.kundnr join " + prefix + "fuppg fu on 1=1 where f1.faktnr=" + faktnr);
    if (rsF1.next()) {
        if (rsF1.getString("fu_regnr")!=null && rsF1.getString("fu_regnr").startsWith("SE")) valuta = "SEK";
        else if (rsF1.getString("fu_regnr")!=null && rsF1.getString("fu_regnr").startsWith("NO")) valuta = "NOK";
%>
<div id="invoice" style="width: 54em; padding: 1em; margin:0.5em; border: 1px solid grey; font-size: 12px">                
<div id="invoice-header" style="width: 100%">
    <span style="font-size: 150%; font-weight:bold">Invoice</span>
    <table style="width: 100%">
        <tr>
            <td style="width: 50%">
               
            </td>
            <td style="width: 50%">
                Invoice #: <%= rsF1.getInt("faktnr") %><br>
                Date: <%= SXUtil.getFormatDate(rsF1.getDate("datum")) %><br>
                <br>
            </td>
        </tr>
        <tr>
            <td style="width: 50%">
                <b>Seller</b><br>
                <%= SXUtil.toHtml(rsF1.getString("fu_namn")) %><br>
                <%= SXUtil.toHtml(rsF1.getString("fu_adr1")) %><br>
                <%= SXUtil.toHtml(rsF1.getString("fu_adr2")) %><br>
                <%= SXUtil.toHtml(rsF1.getString("fu_adr3")) %><br>
                VAT: <%= SXUtil.toHtml(rsF1.getString("fu_regnr")) %><br>
            </td>
            <td style="width: 50%">
                <b>Buyer</b><br>
                <%= SXUtil.toHtml(rsF1.getString("namn")) %><br>
                <%= SXUtil.toHtml(rsF1.getString("adr1")) %><br>
                <%= SXUtil.toHtml(rsF1.getString("adr2")) %><br>
                <%= SXUtil.toHtml(rsF1.getString("adr3")) %><br>
                VAT: <%= SXUtil.toHtml(rsF1.getString("regnr")) %><br>
            </td>
        </tr>
        <tr>
            <td style="width: 50%"></td>
            <td style="width: 50%">
                <br><b>Delivery address</b><br>
                <%= SXUtil.toHtml(SXUtil.isEmpty(levAdr1) ? rsF1.getString("levadr1") : levAdr1) %><br>
                <%= SXUtil.toHtml(SXUtil.isEmpty(levAdr1) ? rsF1.getString("levadr2") : levAdr2) %><br>
                <%= SXUtil.toHtml(SXUtil.isEmpty(levAdr1) ? rsF1.getString("levadr3") : levAdr3) %><br>
            </td>
            
        </tr>
    </table>


</div>

<%

String q = "select f2.artnr, f2.namn, f2.summa, coalesce(case when cn8='' then null else cn8 end, 'x') as cn8, a.vikt*f2.lev as vikt, f2.lev, f2.enh "
+ " from " + prefix + "faktura2 f2 left outer join " + prefix + "artikel a on a.nummer=f2.artnr "
+" where f2.faktnr= " + faktnr + " and f2.lev <> 0 order by cn8, artnr ";

String q2 = "select cn8, sum(summa) as summa, sum(vikt) as vikt  from ( " + q + " ) f group by cn8 order by cn8";

%>

<%         ResultSet rs = stm.executeQuery(q); %>
<table style="margin-top: 2em; width: 100%">
    <tr><th style="width: 9em">Itemcode</th><th style="width: 23em">Item</th><th style="width: 6em">CN8</th>
        <th style="width: 4em;"></th>
        <th  style="width: 3em; text-align: right;">Qty</th>
        <th  style="text-align: right;"><%= valuta %></th>
    </tr>

<%        
    while (rs.next()) {
%>
<tr>
    <td><%= rs.getString("artnr") %></td>
    <td><%= rs.getString("namn") %></td>
    <td style=""><%= rs.getString("cn8") %></td>
    <td  style="text-align: right"><%= SXUtil.getFormatNumber(rs.getDouble("lev"),1) %></td>
    <td  style="text-align: right"><%= SXUtil.toHtml(rs.getString("enh")) %></td>
    <td  style="text-align: right"><%= SXUtil.getFormatNumber(rs.getDouble("summa"),2) %></td>
</tr>
<%        
    }
%>
</table>





<% if (!skrivInteEUUrsprung) { %>
<div>
    <br>
    <b>Goods are of European origin unless otherwise specified.</b>
</div>
<% } %>





<%
    rs = stm.executeQuery(q2);
%>
<table style="margin-top: 2em">
    <tr><th>CN8</th><th style="text-align: right;"><%= valuta %></th></tr>
    
<%        
    while (rs.next()) {
%>
    <tr><td style=""><%= rs.getString("cn8") %></td><td  style="width: 7em; text-align: right"><%= SXUtil.getFormatNumber(rs.getDouble("summa")) %></td></tr>
<%        
    }
%>
    <tr><td> </td></tr>
    <tr><td>Number of packages:</td><td><%= antalKolli %></td></tr>
    <tr><td>Total weight (kg):</td><td><%= totalVikt %></td></tr>
</table>



<br>
<div id="invoice-footer" style="width: 100%">
    <table style="width: 100%">
        <tr>
            <td style="width: 50%"></td>
            <td style="width: 50%;">
        <table style="margin-left: auto; margin-right:0px">
            <tr><td></td><td style="text-align: right"><%= valuta %></td></tr>
            <tr>
                <td>Total net:</td><td style="text-align: right"><%= SXUtil.getFormatNumber(rsF1.getDouble("t_netto")) %></td>
            </tr><tr>
                <td>Total VAT:</td><td style="text-align: right"><%= SXUtil.getFormatNumber(rsF1.getDouble("t_moms")) %></td>
            </tr><tr>
                <td>Rounding:</td><td style="text-align: right"><%= SXUtil.getFormatNumber(rsF1.getDouble("t_orut")) %></td>
            </tr><tr>
                <td>Total incl. VAT:</td><td style="text-align: right"><%= SXUtil.getFormatNumber(rsF1.getDouble("t_attbetala")) %></td>
            </tr>
        </table>
            </td>
    </tr>
    </table>
</div>

            <% if (!SXUtil.isEmpty(ankomst) || !SXUtil.isEmpty(gransort)) { %>
                <div><b>Arrival: <%= SXUtil.toHtml(ankomst) %> at <%= SXUtil.toHtml(gransort) %></b></div><br>
            <% } %>
            <% if (!SXUtil.isEmpty(bilregnr)) { %>
                <div><b>Car registration number: <%= SXUtil.toHtml(bilregnr) %></b></div><br>
            <% } %>
            <% if (!SXUtil.isEmpty(meddelande)) { %>
                <div><b>Message: <%= SXUtil.toHtml(meddelande) %></b></div><br>
            <% } %>


</div>
<%        
    } else {
%>

            <%  if (SXUtil.noNull(faktnr) == 0) {
                 ResultSet rs = stm.executeQuery("select max(faktnr) from " + prefix + "faktura1");   
                 if (rs.next()) faktnr = rs.getInt(1);
            }
      
%>        
                <%@include file="/WEB-INF/sxheader.jsp" %>

<h2>Tulldeklaration</h2>
		<h1 style="visibility: hidden"><sx-rubrik>Tullfaktura från faktura</sx-rubrik></h1>

                <form>
                    <table>
                        <tr><td>Fakturanr:</td><td><input name="faktnr" value="<%= SXUtil.noNull(faktnr) %>"></td></tr>
                    <tr><td>Antal kolli: </td><td><input name="kolli" value="<%= SXUtil.noNull(antalKolli) %>"></td></tr>
                    <tr><td>Total vikt: </td><td><input name="vikt" value="<%= SXUtil.noNull(totalVikt) %>"></td></tr>
                    <tr><td>Ankomst datum & tid: </td><td><input name="ankomst" value="<%= SXUtil.toHtml(ankomst) %>"></td></tr>
                    <tr><td>Gränsort: </td><td>
                            <input list="gransorter" name="gransort" value="<%= SXUtil.toHtml(gransort) %>">
                            <datalist id="gransorter">
                                <option value="Eda">
                                <option value="Hån">
                            </datalist>
                        </td></tr>
                    <tr><td>Bilnr</td><td>
                            <input list="bilar" name="bilregnr" value="<%= SXUtil.toHtml(bilregnr) %>">
                            <datalist id="bilar">
                                <option value="ENC005 - Buss">
                                <option value="NZN970 - Scania">
                                <option value="XXP556 - Iveco">
                            </datalist>
                        
                        </td></tr>
                    <tr><td>Meddelande: </td><td><input name="meddelande" value="<%= SXUtil.toHtml(meddelande) %>"></td></tr>

                    
                    
                    <tr><td colspan="2">Faktura från Saljex AS<input type="checkbox" name="saljexas" value="true" <%= saljexas ? "checked" : "" %>></td></tr>
                    <tr><td colspan="2">Skriv INTE intyg om EU-ursprung <input type="checkbox" name="skrivinteeuursprung" value="true" <%= skrivInteEUUrsprung ? "checked" : "" %>></td></tr>
                    <tr><td colspan="2">Leveransadress (om annan än på fakturan):<br>
                    <input  name="levadr1" value="<%= SXUtil.toHtml(levAdr1) %>"><br>
                    <input  name="levadr2" value="<%= SXUtil.toHtml(levAdr2) %>"><br>
                    <input  name="levadr3" value="<%= SXUtil.toHtml(levAdr3) %>"><br>
                        </td></tr>
                    <tr><td colspan="2"><input type="submit"></td></tr>
                    </TABLE>
                </form>




<% } %>

	</body>
</html>

