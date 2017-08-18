/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.webutil.overforbilligt;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import javax.annotation.security.RunAs;
import javax.ejb.EJB;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import se.saljex.loginservice.LoginServiceConstants;
import se.saljex.loginservice.User;
import se.saljex.sxlibrary.OrderImport;
import se.saljex.sxlibrary.SxServerMainRemote;

/**
 *
 * @author ulf
 */
@RunAs("admin")
public class OverforBilligtServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    
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
            //https://billigtvvs.se/wp-content/uploads/wpallexport/exports/0668442170e378ee2285ccfc14a67a39/current-Ordrar-Export-2017-June-15-0922-4.xml
            if ("import".equals(ac)) {
                try {
                    ArrayList<OrderImport> orderList = XMLParser.parseXMLFromURL(url);

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

                } catch (Exception e) { out.print("<red>Fel vid import </red>" + 
                        e.toString() + " " + e.getMessage());

                }
                
                
                
                
            } else {        //Default 
                
                if (url==null) url="";
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
