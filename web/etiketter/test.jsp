<%-- 
    Document   : test
    Created on : 2019-maj-22, 20:38:36
    Author     : ulf
--%>

<%@page import="java.io.PrintWriter"%>
<%@page import="java.net.Socket"%>
<%@page import="se.saljex.sxlibrary.SXUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
  
String str = request.getParameter("str");

if (str!=null) {
    Socket socket = new Socket("192.168.0.192",9100);
    PrintWriter o = new PrintWriter(socket.getOutputStream(),true);
    o.print(str);
    o.close();
    socket.close();
    
}
    %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        
        <p>skicka text till printer</p>
        <form>
            <textarea rows="10" cols="80" name="str">
                <%= SXUtil.toHtml(str) %>
            </textarea>
                <input type="submit">
            
        </form>
    </body>
</html>
