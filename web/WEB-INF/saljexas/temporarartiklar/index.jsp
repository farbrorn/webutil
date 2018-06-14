<%-- 
    Document   : index
    Created on : 2018-jan-02, 14:11:02
    Author     : ulf
--%>

        <%@page import="se.saljex.sxlibrary.SXUtil"%>
        
        <%
            Double dagensValuta = (Double)request.getAttribute("dagensvaluta");
            if (dagensValuta==null) dagensValuta = 1.0;
            String tempValuta = request.getParameter("valutakurs");
            String valutaStr;
            if (tempValuta == null) valutaStr = SXUtil.getFormatNumber(dagensValuta,4); else valutaStr = tempValuta;
        %>
            
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
                <tr><td>Tullkod</td>
                    <td>
                        <select name="cn8">
                            <option value="">Välj något...</option> 
                            <option value="39172110">39172110 Styva rör i PE</option> 
                            <option value="39172210">39172210 Styva rör i PP</option> 
                            <option value="39172310">39172310 Styva rör i PVC</option> 
                            <option value="39172900">39172900 Styva rör i andra plaster</option> 
                            <option value="39173200">39173200 Böjliga rör i plast</option> 
                            <option value="39174000">39174000 Rördelar i plast (markdel, rörkoppling i plast)</option> 
                            <option value="40094200">40094200 Slangar, förstärkta, i gummi</option> 
                            <option value="69101000">69101000 Porslin - WC, TVÄTTSTÄLL</option> 
                            <option value="73030010">73030010 Rör av gjutjärn</option> 
                            <option value="73079980">73079980 Rördelar av stål</option> 
                            <option value="73101000">73101000 Tankar minst 50l i stål</option> 
                            <option value="73102990">73102990 Tankar under 50l i stål</option> 
                            <option value="73181210">73181210 Träskruv Rostfria</option> 
                            <option value="73181290">73181290 Träskruv Ej rostfritt</option> 
                            <option value="73181595">73181595 Gängade skruvar, bultar</option> 
                            <option value="73259910">73259910 Gjutjärnsgaller</option> 
                            <option value="74121000">74121000 Rördelar av koppar</option> 
                            <option value="74122000">74122000 Rördelar av kopparlegering (t.ex.mässing)</option> 
                            <option value="84186100">84186100 Värmepumpar</option> 
                            <option value="84818081">84818081 Kulventiler</option> 
                            <option value="84813099">84813099 Backventiler</option> 
                            <option value="84814090">84814090 Säkerhetsventiler</option> 
                            <option value="84818011">84818011 Blandningsventiler</option> 
                            <option value="84818031">84818031 Termostatventiler</option> 
                            <option value="84818019">84818019 Blandare</option> 
                            <option value="3917">3917xxxx Andra rör och delar i plast</option> 
                            <option value="3922">3922xxxx Andra sanitetsprodukter i plast</option> 
                            <option value="7306">7306xxxx Andra Rör av järn, stål</option> 
                            <option value="8467">8467xxxx Andra handdverktyg med motor</option> 
                            <option value="x">Inget passar....</option> 
                        </select>
                    </td>
                </tr>
            </table>
            <br><input type="hidden" name="ac" value="save">
            <input type="submit" value="Skapa artikel">
        </form>
