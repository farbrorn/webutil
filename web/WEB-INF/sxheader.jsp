<%@page import="se.saljex.webutil.Const"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Connection"%>

<%
    Connection con = Const.getConnection(request);
    ResultSet rs;
    
    String logoUrl = "https://www.saljex.se/p/s200/logo-saljex.png";
    rs = con.createStatement().executeQuery("select varde from sxreg where id = 'Hemsida-LogoUrl'");
    if (rs.next()) logoUrl = rs.getString("varde");
    
%>
<div style="height: 30px;">
    <span style="width: 100px; height: 100%"><img src="<%= logoUrl %>" style="max-height: 100%; mex-width: 100%"></span>
</div>