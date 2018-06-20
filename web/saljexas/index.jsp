<%-- 
    Document   : index
    Created on : 2018-jan-02, 20:31:13
    Author     : ulf
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Saljex AS</title>
    </head>
    <body>
        <%@include file="/WEB-INF/sxheader.jsp" %>
        <h1>Saljex AS</h1>
        <p><a href="OverforOrder">Överför order</a></p>
        <p><a href="SkapaTemporarArtikel">Skapa temporär artikel</a></p>
        <p><a href="admin?a=lager">Överför lagersaldon till AB</a></p>
        <p><a href="admin?a=valuta">Hämta dagens NOK valutakurs</a></p>
        <p><a href="admin?a=artiklar">Uppdatera artiklar i AS</a></p>
    </body>
</html>
