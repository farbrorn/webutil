<%-- 
    Document   : kvarvarande-h-nummer
    Created on : 2012-dec-19, 08:11:27
    Author     : Ulf
--%>

<%@page import="java.text.DecimalFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="java.text.NumberFormat"%>
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
                Statement stm;
                stm = con.createStatement();
                

		SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
		SimpleDateFormat timeFormatter = new SimpleDateFormat("HH:mm:ss");
                
                
                DecimalFormat nf0 = (DecimalFormat)NumberFormat.getInstance(new Locale("sv", "SE"));
                nf0.applyPattern("0");
                DecimalFormat nf2 = (DecimalFormat)NumberFormat.getInstance(new Locale("sv", "SE"));
                nf2.applyPattern("###,##0.00");
                
//                nf2.setMaximumFractionDigits(2);
//                nf2.setMaximumFractionDigits(2);
              
                

                Integer offertnr=0;
                try { offertnr=Integer.parseInt(request.getParameter("offertnr")); } catch (Exception e) {}
                
                Double momsproc = 0.0;
                ResultSet rsFU = stm.executeQuery("select moms1 from fuppg");
                if (rsFU.next()) momsproc = rsFU.getDouble("moms1");
                
%>			

<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Offert <%= offertnr!=null ? offertnr : "" %></title>
                
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

    double total = 0.0;

    ResultSet rsO1 = stm.executeQuery("select o1.*, s.tel, s.epost from offert1 o1 left outer join saljare s on s.namn=o1.saljare where offertnr=" + offertnr);
    if (rsO1.next()) {
%>
<div id="offer" style="width: 54em; padding: 1em; margin:0.5em; border: 1px solid grey; font-size: 12px">                
<div id="offer-header" style="width: 100%">

    <table style="width: 100%">
        <tr style="height: 80px;">
            <td style="width: 50%">
                <img src="/p/s200/logo-saljex.png">
            </td>
            <td style="width: 50%">
                <span style="font-size: 200%; font-weight:bold">Offert <%= rsO1.getInt("offertnr") %></span><br>
                Datum: <%= SXUtil.getFormatDate(rsO1.getDate("datum")) %>
            </td>
        </tr>
        <tr>
            <td style="width: 50%">
                <b>Vår kontaktperson</b><br>
                <%= SXUtil.toHtml(rsO1.getString("saljare")) %>
                <%= SXUtil.isEmpty(rsO1.getString("epost")) ? "" : "<br>E-post: " + rsO1.getString("epost") %>
                <%= SXUtil.isEmpty(rsO1.getString("tel")) ? "" : "<br>Tel: " + rsO1.getString("tel") %>
            </td>
            <td style="width: 50%">
                <b>Kund</b><br>
                <%= SXUtil.toHtml(rsO1.getString("namn")) %><br>
                <%= SXUtil.toHtml(rsO1.getString("adr1")) %><br>
                <%= SXUtil.toHtml(rsO1.getString("adr2")) %><br>
                <%= SXUtil.toHtml(rsO1.getString("adr3")) %><br>
            </td>
        </tr>
        <tr>
            <td>
                <b>Märke</b><br>
                <%= SXUtil.toHtml(rsO1.getString("marke")) %><br>
            </td>
            
        </tr>
    </table>


</div>

                
                
<div id="offer-rows">
<%

         ResultSet rsO2 = stm.executeQuery("select o2.*, case when coalesce(a.bildartnr,'')='' then a.nummer else bildartnr end as bildnr  from offert2 o2 left outer join artikel a on a.nummer=o2.artnr where offertnr=" + offertnr + " order by pos"); %>

<table style="margin-top: 2em; width: 100%; border-top: 1px solid black; border-bottom: 1px solid black; padding-top: 2px; padding-bottom: 2px;">
    <tr><th style="width: 60px;"></th><th style="width: 8em">Artikelnr</th><th style="width: 18em">Benämning</th><th style="width: 7em; text-align: right;">Antal</th><th></th><th style="text-align: right;">Pris</th><th>%</th><th style="text-align: right;">Summa</th></tr>

<%        
    while (rsO2.next()) {
        total += rsO2.getDouble("summa");
%>
    <% if (SXUtil.isEmpty(rsO2.getString("artnr")) && !SXUtil.isEmpty(rsO2.getString("text"))) { %>
        <tr style="vertical-align: middle;">
            <td></td><td colspan="7"><%= SXUtil.toHtml(rsO2.getString("text")) %></td>
        </tr>
    <% }else { %>
        <tr style="vertical-align: middle; height: 40px;">
            <td><img onerror="this.style.display='none'" style="max-height: 40px;" src="https://www.saljex.se/p/s50/<%= rsO2.getString("bildnr") %>.png"></td>
            <td><%= SXUtil.toHtml(rsO2.getString("artnr")) %></td>
            <td><%= SXUtil.toHtml(rsO2.getString("namn")) %></td>
            <td style="text-align: right; width: 7em"><%= rsO2.getDouble("best") % 1 == 0 ? nf0.format(rsO2.getDouble("best")) : nf2.format(rsO2.getDouble("best")) %></td>
            <td><%= SXUtil.toHtml(rsO2.getString("enh")) %></td>
            <td style="text-align: right"><%= nf2.format(rsO2.getDouble("pris")) %></td>
            <td style=""><%= rsO2.getDouble("rab") == 0 ? "" : nf0.format(rsO2.getDouble("rab")) %></td>
            <td  style="text-align: right"><%= nf2.format(rsO2.getDouble("summa")) %></td>
        </tr>
    <% } %>
<%        
    }
%>
</table>
</div>








<div id="offer-footer" style="width: 100%">
    <table style="width: 100%">
        <tr>
            <td style="width: 50%"></td>
            <td style="width: 50%;">
                <table style="margin-left: auto; margin-right:0px">
                    <tr>
                        <td style="font-weight: bold">Totalt exkl. moms:</td><td style="text-align: right"><%= nf2.format(total) %></td>
                    </tr>
                    <tr>
                        <td style="font-weight: bold">Totalt inkl. <%= momsproc %>% moms:</td><td style="text-align: right"><%= nf2.format(total*(1+momsproc/100)) %></td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</div>
                
</div>
<%        
    } else {
%>

                <%@include file="/WEB-INF/sxheader.jsp" %>

<h2>Skriv offert</h2>
		<h1 style="visibility: hidden"><sx-rubrik>Offertnr</sx-rubrik></h1>

                <form>
                    <table>
                        <tr><td>Offertnr:</td><td><input name="offertnr" value="<%= SXUtil.noNull(offertnr) %>"></td></tr>
                    <tr><td colspan="2"><input type="submit"></td></tr>
                    </TABLE>
                </form>

<% } %>

	</body>
</html>

