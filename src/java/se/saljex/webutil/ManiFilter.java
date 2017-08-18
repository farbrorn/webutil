package se.saljex.webutil;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

import java.io.IOException;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;

/**
 *
 * @author ulf
 */
@WebFilter(filterName = "ManiFilter", urlPatterns = {"/*"})
public class ManiFilter extends se.saljex.loginservice.LoginServiceFilter {
    
    
    public ManiFilter() {
        super();
    }    
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
            FilterChain chain)
            throws IOException, ServletException {
        super.doFilter(request,response,chain);
    }


    
}
