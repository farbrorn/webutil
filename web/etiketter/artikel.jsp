<%-- 
    Document   : oversikt
    Created on : 2018-jun-14, 15:24:41
    Author     : Ulf Berg
--%>

<%@page import="se.saljex.sxlibrary.SXUtil"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page import="se.saljex.webutil.Const"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>

<%
    Connection con = Const.getConnection(request);
    PreparedStatement ps;
    //Statement st = con.createStatement();
    ResultSet rs;
    Integer ordernr = null;
    try {  ordernr = new Integer(request.getParameter("ordernr")); }catch (Exception e) {}
    Integer offertnr = null;
    try {  offertnr = new Integer(request.getParameter("offertnr")); }catch (Exception e) {}
    Integer kopior = null;
    try {  kopior = new Integer(request.getParameter("kopior")); }catch (Exception e) {}
    if (kopior==null || kopior<0 || kopior > 1000) kopior = 1;
    
    String typ = request.getParameter("typ");
    

    boolean saljexas=("true".equals(request.getParameter("saljexas")));
    String prefix = saljexas ? "sxasfakt." : "";
    
    String frartnr = request.getParameter("frartnr");
    String tiartnr = request.getParameter("tiartnr");
    
    
    String logoBild="logo-saljex-300-bw.png";
    String logoBildSmall="logo-saljex-vriden-300-bw.png";
    if (saljexas) {
        logoBild="logo-saljexas-300-bw.png";
        logoBildSmall="logo-saljexas-vriden-300-bw.png";
    }
    String logoUrl = "https://www.saljex.se/p/";
    

        
    String bildUrl = "https://www.saljex.se/p/";
    rs = con.createStatement().executeQuery("select varde from " + prefix + "sxreg where id = 'Hemsida-BildURL'");
    if (rs.next()) bildUrl = rs.getString("varde");
    if (!bildUrl.endsWith("/")) bildUrl = bildUrl + "/";
    bildUrl = bildUrl+"s100/";

                    
    %>
    
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Artikeletiketter</title>
<link href="https://fonts.googleapis.com/css?family=Libre+Barcode+39+Extended&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css?family=Libre+Barcode+128+Text&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css?family=Libre+Barcode+39+Text&display=swap" rel="stylesheet">
<style>
            body {
                margin: 0; 
                font: 4mm arial;
            }

            .abs {
              position: absolute;
              top: 0;
              left: 0;
            }
            td {
                padding: 0;
            }
            .input {
                margin-top: 20px;
                margin-bottom: 20px;
                
            }
            .etiketter {
                font-size: 6mm;
                margin: 0px;
                padding: 0px;
                
            }            
            .etikett {
                width: 110mm;
                height: 64mm;
                padding: 5mm;
                overflow: hidden;
                /* border: 1px solid black; */
                margin: 0px;
            }
            .logo {
                height: 10mm;
            }
            .logo img {
                max-height: 10mm;
                max-width: 40mm;
                
            }
            .mid-content {
                height: 40mm;
            }
            .bild {
                width: 25mm;
                height: 25mm;
                margin-right: 5mm;
            }
            .bild img {
                max-width: 100%;
                max-height: 100%;
            }
            .artnr {
                font-size: 11mm;
                font-weight: bold;
                marign-top: 5mm;
            }
            .namn {
                font-size: 6mm;
                marign-top: 5mm;
            }
            .refnr {
                display: inline;
                margin-right: 10mm;
                font-size: 4mm;
                
            }
            .rsk {
                display: inline;
                margin-right: 10mm;
                font-size: 4mm;
                
            }
            .enhet {
                
            }
            .streckkod {
                font-family: 'Libre Barcode 39 Extended';
                font-size: 22px;
                font-size: 16mm;
                margin:0;
                
            }
            .underrubrik {
                font-size: 4mm;
                
            }
            
            
            
            
            
            
            
            
            .etikett-s {
                font-size: 3mm;
                width: 70mm;
                height: 29mm;
                overflow: hidden;
                position:relative;
            }
            .logo-s {
                height: 25mm;
                width: 10mm;
                //float: left;
                left: 2mm;
                top: 1mm;
                position: absolute;
            }
            .logo-s img {
                max-height: 25mm;
                max-width: 10mm;
            }
            .bild-s {
                width: 10mm;
                height: 10mm;
                display: none;
            }
            .bild-s img {
                max-width: 100%;
                max-height: 100%;
            }
            .artnr-s {
                font-size: 5mm;
                font-weight: bold;
                marign-top: 5mm;
                top: 1mm;
                left: 10mm;
                position: absolute;
            }
            .namn-s-antalruta {
                display: inline-block;
                width: 46mm;
                top: 6mm;
                left: 10mm;
                position: absolute;
            }
            .namn-s {
                font-size: 4mm;
                marign-top: 2mm;
                height: 9mm;
                overflow: hidden;
                position: absolute;
                top: 6mm;
                left: 10mm;
            }
            .antalruta-s {
                width: 12mm;
                height: 6mm;
                border: 1px solid black;
                display: inline-block;
                position: absolute;
                top: 6mm;
                left: 55mm;
            }
            .refnr-s {
                font-size: 3mm;
                position: absolute;
                top: 15mm;
                left: 10mm;
                
            }
            .rsk-s {
                font-size: 3mm;
                position: absolute;
                top: 15mm;
                left: 30mm;
                
            }
            .enhet-s {
                display: none;
            }
            .streckkod-s {
/*                font-family: 'Libre Barcode 39 Extended'; */
                font-family: 'Libre Barcode 39 Text', cursive;
                font-size: 10mm;
                position: absolute;
                top: 19mm;
                left: 10mm;
                
            }
            .underrubrik-s {
                font-size: 2mm;
                
            }
            
            
            
            
            @media print {
                .input {
                    display: none !important;
                }
                .etikett {
                    page-break-after: always !important; 
                }
                .etikett-s {
                    page-break-after: always !important; 
                }
            }
        </style>
        
    </head>
    
    <body>
    
        <div class="input">
        
            <%@include file="/WEB-INF/sxheader.jsp" %>
            <form>
                Offertnr: <input name="offertnr" value="<%= offertnr==null ? "": SXUtil.noNull(offertnr) %>">
                Ordernr: <input name="ordernr" value="<%= ordernr==null ? "" : SXUtil.noNull(ordernr) %>">
                <select name="typ">
                    <option value="n" <%= (typ == null || "n".equals(typ)) ? "selected" : "" %> >100x64</option>
                    <option value="s" <%= "s".equals(typ) ? "selected" : "" %> >70x30</option>
                    <option value="s-antalruta" <%= "s-antalruta".equals(typ) ? "selected" : "" %> >70x30 med antalruta</option>
                </select>
                <P>
                    Artikelnummer från: <input name="frartnr" value="<%= SXUtil.toStr(frartnr) %>">
                till: <input name="tiartnr" value="<%= SXUtil.toStr(tiartnr) %>">
                </P>
                Antal kopior: <input name="kopior" value="<%= SXUtil.noNull(kopior) %>">
                Saljex AS<input type="checkbox" name="saljexas" value="true" <%= saljexas ? "checked" : "" %>>
                <input type="submit">
            </form>
        </div>
        
        <div class="etiketter">


        <%
            String q = "select a.nummer, a.namn, a.refnr, a.rsk, a.enhet, a.forpack ";
            if (offertnr!=null || ordernr!=null) q=q+", o2.best"; else q=q+", null as best";
            q=q+" from  " + prefix + "artikel a ";
            if (!SXUtil.isEmpty(frartnr) && !SXUtil.isEmpty(tiartnr)) {
                q = q + " where nummer between ? and ? order by a.nummer";
                ps = con.prepareStatement(q);
                ps.setString(1, frartnr);
                ps.setString(2, tiartnr);
            } else if (offertnr!=null) {
                q = q + " join " + prefix + "offert2 o2 on o2.artnr=a.nummer and o2.offertnr=? order by a.nummer";
                ps = con.prepareStatement(q);
                ps.setInt(1, offertnr);
            } else if (ordernr!=null) {
                q = q + " join " + prefix + "order2 o2 on o2.artnr=a.nummer and o2.ordernr=? order by a.nummer";
                ps = con.prepareStatement(q);
                ps.setInt(1, ordernr);
            } 
            else { 
                q=q+" where 0=1";
                ps = con.prepareStatement(q);
            }

        
            rs = ps.executeQuery();
            while (rs.next()) {
            %>                            
            <% for (int lp=0; lp<kopior; lp++) { %>
            
            
            <% if ("s".equals(typ) || "s-antalruta".equals(typ)) { %>
                <div class="etikett-s">
                    <div class="logo-s"><img src="<%= logoUrl + logoBildSmall %>" onerror="this.style.display='none';"></div>
                        <div class="artnr-s"><%= SXUtil.toHtml(rs.getString("nummer")) %></div>
                        <div class="namn-s <%= "s-antalruta".equals(typ) ? "namn-s-antalruta" : "" %>" ><%= SXUtil.toHtml(rs.getString("namn")) %></div>
                         <% if ("s-antalruta".equals(typ)) { %>
                         <div class="antalruta-s"><div style="position: absolute; top: 0; left: 1mm; font-size: 6px;">Antal</div>
                             <div style="position: absolute; top: 2mm; left: 0; width: 100%; text-align: center">
                             <%= rs.getDouble("best") != 0.0 ? SXUtil.getFormatNumber(rs.getDouble("best"),0) : "" %>
                             </div>
                             </div>
                         <% } %>
                        <div class="refnr-s"><span class="underrubrik-s">Ref: </span><%= SXUtil.toHtml(rs.getString("refnr")) %></div>
                        <div class="rsk-s"><span class="underrubrik-s"><%= saljexas ? "NRF:" : "RSK:" %> </span><%= SXUtil.toHtml(rs.getString("rsk")) %></div>
                        <div class="enhet-s"><span class="underrubrik-s">Enhet: </span><%= SXUtil.toHtml(rs.getString("enhet")) %></div>
                        <div class="streckkod-s">*<%= SXUtil.toHtml(rs.getString("nummer")) %>*</div>
                </div>
            <% } else { %>
                <div class="etikett">
                    <div class="logo"><img src="<%= logoUrl + logoBild %>" onerror="this.style.display='none';"></div>
                    <table>
                        <tr>
                            <td>
                                <div class="bild"><img src="<%= bildUrl + rs.getString("nummer") %>" onerror="this.style.display='none';"></div>
                            </td>
                            <td>
                                <div class="mid-content">
                                    <div class="artnr"><%= SXUtil.toHtml(rs.getString("nummer")) %></div>
                                    <div class="namn"><%= SXUtil.toHtml(rs.getString("namn")) %></div>
                                    <div class="refnr"><span class="underrubrik">Ref: </span><%= SXUtil.toHtml(rs.getString("refnr")) %></div>
                                    <div class="rsk"><span class="underrubrik"><%= saljexas ? "NRF:" : "RSK:" %> </span><%= SXUtil.toHtml(rs.getString("rsk")) %></div>
                                    <div class="enhet"><span class="underrubrik">Enhet: </span><%= SXUtil.toHtml(rs.getString("enhet")) %></div>
                                </div>
                            </td>
                        </tr>
                    </table>
                    <div class="streckkod-s"><%= SXUtil.toHtml(rs.getString("nummer")) %></div>
                    

                </div>

            <% } %>
            <% } %>    
            <% } %>
        
    </div>
    </body>
</html>
