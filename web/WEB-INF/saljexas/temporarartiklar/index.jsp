<%-- 
    Document   : index
    Created on : 2018-jan-02, 14:11:02
    Author     : ulf
--%>

        <%@page import="se.saljex.sxlibrary.SXUtil"%>
<h1>Skapa tempor�r artikel</h1>
        <div style="color: red; font-size: 150%; "><%= request.getAttribute("errtext")!=null ? request.getAttribute("errtext") : "" %></div>
        <div style="color: blue; font-size: 120%; "><%= request.getAttribute("infotext")!=null ? request.getAttribute("infotext") : "" %></div>
        <p>
            Skapa tempor�r artikel i S�ljex AB & Saljex AS. Skapade artiklar �r tempor�ra och raderas efter en m�nads inaktivitet. (Dvs inga ordrar finns registrerade) Artiklarna kan anv�ndas vid order flera g�nger.
        </p>
        <form method="post">
            <table>
                <tr><td>Ben�mning</td><td><input name="namn" value="<%= SXUtil.toHtml(request.getParameter("namn")) %>"></td></tr>
                <tr><td>Leverant�rsnr i S�ljex AB</td><td><input name="levnr" value="<%= SXUtil.toHtml(request.getParameter("levnr")) %>"></td></tr>
                <tr><td>Best�llningsnummer</td><td><input name="bestnr" value="<%= SXUtil.toHtml(request.getParameter("bestnr")) %>"></td></tr>
                <tr><td>Ink�pspris i S�ljex AB i SEK</td><td><input name="inprisab" value="<%= SXUtil.toHtml(request.getParameter("inprisab")) %>"></td></tr>
                <tr><td>F�rs�ljningspris i Saljex AS NOK</td><td><input name="utprisas" value="<%= SXUtil.toHtml(request.getParameter("utprisas")) %>"></td></tr>
                <tr><td>Enhet</td><td><input name="enhet" value="<%= SXUtil.toHtml(request.getParameter("enhet")) %>"></td></tr>
                <tr><td>Anv�ndare</td><td><input name="anvandare" value="<%= SXUtil.toHtml(request.getParameter("anvandaare")) %>"></td></tr>
            </table>
            <<br><input type="hidden" name="ac" value="save">
            <input type="submit" value="Skapa artikel">
        </form>
