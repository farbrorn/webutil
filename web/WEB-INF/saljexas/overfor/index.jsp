<%-- 
    Document   : index
    Created on : 2018-jan-01, 19:28:18
    Author     : ulf
--%>

        <%@page import="se.saljex.sxlibrary.SXUtil"%>
<h1>Överför order från Saljex AS</h1>
        <div style="color: red; font-size: 150%; "><%= request.getAttribute("errtext")!=null ? request.getAttribute("errtext") : "" %></div>
        <div style="color: blue; font-size: 120%; "><%= request.getAttribute("infotext")!=null ? request.getAttribute("infotext") : "" %></div>
        <p>
            Äverför en lista med order från Saljex AS till Säljex AB. Ordrarna måste ha status <b>Samfak</b>. De överförda ordrarna samlas till en offert i Säljex AB.
        </p>
        <form method="post">
            Ange en lista med ordernr från Saljex AS, separerade med kommatecken (,):<br><textarea name="orderlista" rows="10" cols="60"><%= SXUtil.toHtml(request.getParameter("orderlista")) %></textarea> 
            <br><input type="hidden" name="ac" value="overfor">
            <input type="submit" value="Överför">
        </form>
