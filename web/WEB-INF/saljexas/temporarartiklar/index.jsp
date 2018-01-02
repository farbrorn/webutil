<%-- 
    Document   : index
    Created on : 2018-jan-02, 14:11:02
    Author     : ulf
--%>

        <%@page import="se.saljex.sxlibrary.SXUtil"%>
<h1>Skapa temporär artikel</h1>
        <div style="color: red; font-size: 150%; "><%= request.getAttribute("errtext")!=null ? request.getAttribute("errtext") : "" %></div>
        <div style="color: blue; font-size: 120%; "><%= request.getAttribute("infotext")!=null ? request.getAttribute("infotext") : "" %></div>
        <p>
            Skapa temporär artikel i Säljex AB & Saljex AS. Skapade artiklar är temporära och raderas efter en månads inaktivitet. (Dvs inga ordrar finns registrerade) Artiklarna kan användas vid order flera gånger.
        </p>
        <form method="post">
            <table>
                <tr><td>Benämning</td><td><input name="namn" value="<%= SXUtil.toHtml(request.getParameter("namn")) %>"></td></tr>
                <tr><td>Leverantörsnr i Säljex AB</td><td><input name="levnr" value="<%= SXUtil.toHtml(request.getParameter("levnr")) %>"></td></tr>
                <tr><td>Beställningsnummer</td><td><input name="bestnr" value="<%= SXUtil.toHtml(request.getParameter("bestnr")) %>"></td></tr>
                <tr><td>Inköpspris i Säljex AB i SEK</td><td><input name="inprisab" value="<%= SXUtil.toHtml(request.getParameter("inprisab")) %>"></td></tr>
                <tr><td>Försäljningspris i Saljex AS NOK</td><td><input name="utprisas" value="<%= SXUtil.toHtml(request.getParameter("utprisas")) %>"></td></tr>
                <tr><td>Enhet</td><td><input name="enhet" value="<%= SXUtil.toHtml(request.getParameter("enhet")) %>"></td></tr>
                <tr><td>Användare</td><td><input name="anvandare" value="<%= SXUtil.toHtml(request.getParameter("anvandaare")) %>"></td></tr>
            </table>
            <<br><input type="hidden" name="ac" value="save">
            <input type="submit" value="Skapa artikel">
        </form>
