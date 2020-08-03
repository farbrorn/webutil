/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.webutil.billigt;

import com.sun.tools.ws.wsdl.document.http.HTTPUrlEncoded;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.List;
import javax.annotation.security.RunAs;
import javax.ejb.EJB;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import se.saljex.loginservice.LoginServiceConstants;
import se.saljex.loginservice.User;
import se.saljex.sxlibrary.OrderImport;
import se.saljex.sxlibrary.SXUtil;
import se.saljex.sxlibrary.SxServerMainRemote;

/**
 *
 * @author ulf
 */
@RunAs("admin")
public class OverforServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    
public static final String importURL = "https://billigtvvs.se/butikadmin/ordersXML.php?action=import";
public static final String importOkURL = "https://billigtvvs.se/butikadmin/ordersXML.php?action=importOK";
//public static final String importOkURL = "https://WWW.SALJEX.SE";
    
    
	@EJB	
	private SxServerMainRemote sxServerMainBean;

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Orderimport</title>");            
            out.println("</head>");            
            out.println("<body>");
            
            String ac = request.getParameter("ac");
            String url = request.getParameter("url");
            String gateway = request.getParameter("gateway");
            //https://billigtvvs.se/wp-content/uploads/wpallexport/exports/0668442170e378ee2285ccfc14a67a39/current-Ordrar-Export-2017-June-15-0922-4.xml
            
            if ("import".equals(ac)) {
                try {
                    
                    ArrayList<OrderImport> orderList = OverforXMLParser.parseXMLFromURL(url);

                    List<Integer> ol = sxServerMainBean.importOrder("00", orderList);
                    out.print("<b>Importen klar.</b> Totalt " + ol.size() + " ordrar importerade.</br>");
                    for (OrderImport o : orderList) {
                        out.print("Ordernr: " + o.getMarke());
                        out.print(", " + o.getLevAdr1()); 
                        out.print(", " + o.getLevAdr2()); 
                        out.print(", " + o.getLevAdr3()); 

                        out.print("<table>");
                        for (OrderImport.OrderRad or : o.getOrderRader()) {
                            if (or.getArtnr()!=null) { 
                                out.print("<tr><td>");
                                out.print("Artnr" + or.getArtnr() + "<br>"); 
                                out.print("</td><td>");
                                out.print("Namn:" + or.getNamn()+ "<br>"); 
                                out.print("</td><td>");
                                out.print("Antal" + or.getAntal() + "<br>"); 
                                out.print("</td></tr>");
                            } 
                        }
                        out.print("</table><br><br>");
                   } 
                    out.print("<div><h2>Svar från fjärrserver<h2>");
                    URL okURL = new URL(importOkURL);
                    
                    SSLContext ssl = SSLContext.getInstance("TLSv1.2");             
                    ssl.init(null, null, new SecureRandom());
                    HttpsURLConnection connection = (HttpsURLConnection) okURL.openConnection();
                    connection.setSSLSocketFactory(ssl.getSocketFactory());
                    
                    BufferedReader okIn = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                    String okInput;
                    while ((okInput = okIn.readLine()) != null) out.print(okInput);
                    okIn.close();
                    out.print("</div>");

                } catch (Exception e) { out.print("<red>Fel vid import </red>" + 
                        e.toString() + " " + e.getMessage()); e.printStackTrace(out);

                }
                
                
                
                
            } else {        //Default 
                
                if (url==null) url=importURL;
                out.print("<form>Ange fullständig URL: <input name=\"url\" value=\"" + url + "\">" );
                out.print("<input type=\"submit\" name=\"ac\" value=\"import\">");
                out.print("</form>");
                
                
            }
            
            
            out.println("</body>");
            out.println("</html>");
        }
    }

    
    
    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>
    
}
