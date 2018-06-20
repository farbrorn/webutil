<%@page import="se.saljex.webutil.Const"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Connection"%>

<%
    ResultSet xSxHeaderJsp_rsSxHeaderJsp;
    String xSxHeaderJsp_logoUrl = "https://www.saljex.se/p/s200/logo-saljex.png";
    xSxHeaderJsp_rsSxHeaderJsp = Const.getConnection(request).createStatement().executeQuery("select varde from sxreg where id = 'Hemsida-LogoUrl'");
    if (xSxHeaderJsp_rsSxHeaderJsp.next()) xSxHeaderJsp_logoUrl = xSxHeaderJsp_rsSxHeaderJsp.getString("varde");
    
%>
<div style="height: 30px;">
    <span style="width: 100px; height: 100%"><img src="<%= xSxHeaderJsp_logoUrl %>" style="max-height: 100%; mex-width: 100%"></span>
</div>