<%-- 
    Document   : index
    Created on : 2018-jan-01, 19:28:18
    Author     : ulf
--%>

        <%@page import="se.saljex.sxlibrary.SXUtil"%>
<h1>�verf�r order fr�n Saljex AS</h1>
        <div style="color: red; font-size: 150%; "><%= request.getAttribute("errtext")!=null ? request.getAttribute("errtext") : "" %></div>
        <div style="color: blue; font-size: 120%; "><%= request.getAttribute("infotext")!=null ? request.getAttribute("infotext") : "" %></div>
        <p>
            �verf�r en lista med order fr�n Saljex AS till S�ljex AB. Ordrarna m�ste ha status <b>Samfak</b>. De �verf�rda ordrarna samlas till en offert i S�ljex AB.
        </p>
        <form method="post">
            Ange en lista med ordernr fr�n Saljex AS, separerade med kommatecken (,):<br><textarea name="orderlista" rows="10" cols="60"><%= SXUtil.toHtml(request.getParameter("orderlista")) %></textarea> 
            <br><input type="hidden" name="ac" value="overfor">
            <input type="submit" value="�verf�r">
        </form>
