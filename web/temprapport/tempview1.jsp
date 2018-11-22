
<%@page import="se.saljex.webutil.Const"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%
    ResultSet rs = Const.getConnection(request).createStatement().executeQuery("select * from view_temprapport_1");
    while (rs.next()) { %> <%= rs.getString(1) %> <% }    
%>
