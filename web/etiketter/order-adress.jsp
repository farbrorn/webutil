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
    Integer kopior = null;
    try {  kopior = new Integer(request.getParameter("kopior")); }catch (Exception e) {}
    if (kopior==null || kopior<0 || kopior > 1000) kopior = 1;
    
    

    boolean saljexas=("true".equals(request.getParameter("saljexas")));
    String prefix = saljexas ? "sxasfakt." : "";
    
    String logoBild="logo-saljex-300-bw.png";
    if (saljexas) {
        logoBild="logo-saljexas-300-bw.png";
    }
    String logoUrl = "https://www.saljex.se/p/";
    

        
                    
    %>
    
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Orderetiketter</title>
<link href="https://fonts.googleapis.com/css?family=Libre+Barcode+39+Text&display=swap" rel="stylesheet">
<style>
            body {
                margin: 0; 
                font: 4mm arial;
            }
            
            td {
                padding: 0;
            }
            .input {
                margin-top: 20px;
                margin-bottom: 20px;
                
            }
            .etiketter {
                font-size: 4mm;
                margin: 0px;
                padding: 0px;
                
            }            
            .etikett {
                width: 100mm;
                height: 64mm;
                padding: 5mm;
                overflow: hidden;
                /* border: 1px solid black; */
                margin: 0px;
            }
            .logo {
                height: 8mm;
            }
            .logo img {
                max-height: 6mm;
                max-width: 60mm;
                
            }
            .streckkod {
                font-family: 'Libre Barcode 39 Text';
                font-size: 12mm;
                margin:0;
                
            }
            .underrubrik {
                font-size: 4mm;
                
            }
            
            
            
            
            .levadr1 {
                display: inline-block;
                font-size: 5mm;
                height: 10mm;
                line-height: 5mm;
                overflow: hidden;
            }
            .levadr0 {
                display: block;
                font-size: 10mm;
                height: 21mm;
                overflow: hidden;
                line-height: 11mm;
                overflow: hidden;
            }
            
            .levadr {
                padding: 0;
                height: 30mm;
                overflow: hidden;
                margin-bottom: 3mm;
            }
            
            .marke {
                border: 1px solid black; 
                padding-left: 2mm;
                
                margin-bottom: 3mm;
                height: 8mm;
                overflow: hidden;
                font-weight: bold;
                line-height: 8mm;
                font-size: 6mm;
            }
            
            .ordernr {
                
            }
            
            
            
            
            @media print {
                .input {
                    display: none !important;
                }
                .etikett {
                    page-break-after: always !important; 
                }
            }
        </style>
        
    </head>
    
    <body>
    
        <div class="input">
        
            <%@include file="/WEB-INF/sxheader.jsp" %>
            <form>
                Ordernr: <input name="ordernr" value="<%= SXUtil.noNull(ordernr) %>">
                Antal kopior: <input name="kopior" value="<%= SXUtil.noNull(kopior) %>">
                Saljex AS<input type="checkbox" name="saljexas" value="true" <%= saljexas ? "checked" : "" %>>
                <input type="submit">
            </form>
        </div>
        
        <div class="etiketter">


        <%
            String q = "select * from " + prefix + "order1 where ordernr=?";
            String adr0;
            String adr1;
            String adr2;
            String adr3;
            String namn;
            ps = con.prepareStatement(q);
            ps.setInt(1, SXUtil.noNull(ordernr));
        
            rs = ps.executeQuery();
            while (rs.next()) {
            %>                            
            <% for (int lp=0; lp<kopior; lp++) { %>
            <%
                namn = rs.getString("namn");
                adr0 = rs.getString("levadr1");
                adr1 = rs.getString("levadr2");
                adr2 = "";
                adr3 = rs.getString("levadr3");
                if (SXUtil.isEmpty(adr0) || SXUtil.isEmpty(adr1) || SXUtil.isEmpty(adr3)) {
                    adr0 = namn;
                    adr1 = rs.getString("adr1");
                    adr2 = rs.getString("adr2");
                    adr3 = rs.getString("adr3");
                }
                
                
                
            %>
            <div class="etikett">
            <div class="logo"><img src="<%= logoUrl + logoBild %>" onerror="this.style.display='none';"></div>
            <div class="levadr">
                <div class="levadr0"><%= SXUtil.toHtml(adr0) %></div>
                <div class="levadr1"><%= SXUtil.toHtml(adr1) %> <%= SXUtil.toHtml(adr2) %> <%= SXUtil.toHtml(adr3) %> </div>
            </div>
            <div class="marke"><%= SXUtil.toHtml(rs.getString("marke")) %></div>
            <div class="streckkod"><%= SXUtil.toHtml("*" + rs.getInt("ordernr") + "*") %></div>
            </div>

            <% } %>
            <% } %>    
        
    </div>
    </body>
</html>
