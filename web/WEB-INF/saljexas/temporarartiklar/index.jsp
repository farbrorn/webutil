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
                <tr><td>Tullkod</td>
                    <td>
                        <select name="cn8">
                            <option value="">V�lj n�got...</option> 
                            <option value="39172110">39172110 Styva r�r i PE</option> 
                            <option value="39172210">39172210 Styva r�r i PP</option> 
                            <option value="39172310">39172310 Styva r�r i PVC</option> 
                            <option value="39172900">39172900 Styva r�r i andra plaster</option> 
                            <option value="39173200">39173200 B�jliga r�r i plast</option> 
                            <option value="39174000">39174000 R�rdelar i plast (markdel, r�rkoppling i plast)</option> 
                            <option value="40094200">40094200 Slangar, f�rst�rkta, i gummi</option> 
                            <option value="69101000">69101000 Porslin - WC, TV�TTST�LL</option> 
                            <option value="73030010">73030010 R�r av gjutj�rn</option> 
                            <option value="73079980">73079980 R�rdelar av st�l</option> 
                            <option value="73101000">73101000 Tankar minst 50l i st�l</option> 
                            <option value="73102990">73102990 Tankar under 50l i st�l</option> 
                            <option value="73181210">73181210 Tr�skruv Rostfria</option> 
                            <option value="73181290">73181290 Tr�skruv Ej rostfritt</option> 
                            <option value="73181595">73181595 G�ngade skruvar, bultar</option> 
                            <option value="73259910">73259910 Gjutj�rnsgaller</option> 
                            <option value="74121000">74121000 R�rdelar av koppar</option> 
                            <option value="74122000">74122000 R�rdelar av kopparlegering (t.ex.m�ssing)</option> 
                            <option value="84186100">84186100 V�rmepumpar</option> 
                            <option value="84818081">84818081 Kulventiler</option> 
                            <option value="84813099">84813099 Backventiler</option> 
                            <option value="84814090">84814090 S�kerhetsventiler</option> 
                            <option value="84818011">84818011 Blandningsventiler</option> 
                            <option value="84818031">84818031 Termostatventiler</option> 
                            <option value="84818019">84818019 Blandare</option> 
                            <option value="3917">3917xxxx Andra r�r och delar i plast</option> 
                            <option value="3922">3922xxxx Andra sanitetsprodukter i plast</option> 
                            <option value="7306">7306xxxx Andra R�r av j�rn, st�l</option> 
                            <option value="8467">8467xxxx Andra handdverktyg med motor</option> 
                            <option value="x">Inget passar....</option> 
                        </select>
                    </td>
                </tr>
            </table>
            <br><input type="hidden" name="ac" value="save">
            <input type="submit" value="Skapa artikel">
        </form>
