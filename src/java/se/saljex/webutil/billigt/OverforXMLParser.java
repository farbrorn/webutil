/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.webutil.billigt;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;
import se.saljex.sxlibrary.OrderImport;

/**
 *
 * @author ulf
 */
public class OverforXMLParser {

    public static String getValue(Element element, String name ) {
        try {
            return element.getElementsByTagName(name).item(0).getTextContent();
        } catch (Exception e) {return "";}
    }
    
    public static ArrayList<OrderImport> parseXMLFromURL(String urlString) throws MalformedURLException, IOException, SAXException, ParserConfigurationException {
            OverforXMLParser.litaPaAllaSSLCertifikat();
            URL url = new URL(urlString);
            
            ArrayList<OrderImport> orderList = new ArrayList<>();
            
            DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
            Document doc = dBuilder.parse(url.openStream());
            doc.getDocumentElement().normalize();

            // Hämta lista på alla order och loopa igenom
            NodeList eList = doc.getElementsByTagName("post");
            for (int temp = 0; temp < eList.getLength(); temp++) {
                OrderImport order = new OrderImport();

                Node eNode = eList.item(temp);
                Element eElement = (Element) eNode;
                order.setMarke(getValue(eElement, "OrderID"));
                order.setLevAdr1((getValue(eElement, "ShippingCompany") + " " + getValue(eElement, "ShippingFirstName") + " " + getValue(eElement, "ShippingLastName")).trim());
                order.setLevAdr2(getValue(eElement, "ShippingAddress1"));
                order.setLevAdr3(getValue(eElement, "ShippingPostcode") + " " + getValue(eElement, "ShippingCity"));
                order.setMarke(getValue(eElement, "OrderID") + " " + order.getLevAdr1());
                order.setLagernr(BilligtData.getLagernr());
                order.setKundnr(BilligtData.getKundnr());

                String t;
                t = getValue(eElement, "CustomerAccountEmailAddress");
                if ( !t.isEmpty() ) order.addOrderTextRad(t);
                t = getValue(eElement, "BillingPhone");
                if ( !t.isEmpty() )order.addOrderTextRad(t);


                // Hämta lista på artiklar och loopa
                Node tempNode = eElement.getElementsByTagName("OrderItems").item(0);
                NodeList oList = ((Element)tempNode).getElementsByTagName("Item"); 
                for (int cn = 0; cn < oList.getLength(); cn++) {
                    Node oNode = oList.item(cn);
                    Element oElement = (Element) oNode;
                    order.addOrderRad(getValue(oElement, "_variation_ean"), getValue(oElement, "ProductName"), getValue(oElement, "Quantity"));
                }
                
                if (order.getOrderRader().size()>0) orderList.add(order); //Hoppa över om det inte är några artikelrader

            }
       return orderList;         
    }







    
public static void litaPaAllaSSLCertifikat() {
    //Manager för att lita på alla SSL-certifikat. Om inte den aanvänds så kan vi inte läsa från själcertifierade SSL certifikat
    TrustManager[] trustAllCerts = new TrustManager[]{
    new X509TrustManager() {
        public java.security.cert.X509Certificate[] getAcceptedIssuers() {
            return null;
        }
        public void checkClientTrusted(
            java.security.cert.X509Certificate[] certs, String authType) {
        }
        public void checkServerTrusted(
            java.security.cert.X509Certificate[] certs, String authType) {
        }
    }
}
            ;
try {
    SSLContext sc = SSLContext.getInstance("SSL");
    sc.init(null, trustAllCerts, new java.security.SecureRandom());
    HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
} catch (Exception e) {
}

}
}
