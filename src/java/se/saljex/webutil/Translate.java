/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.webutil;

import java.util.HashMap;

/**
 *
 * @author Ulf Berg
 */
public class Translate {

    private String sprak;
    private static HashMap<String, String> ordlistaNo = new HashMap<>();
    {        
        ordlistaNo.put("Datum", "Dato");
        ordlistaNo.put("Offert", "Tilbud");
        ordlistaNo.put("Kund", "Kunde");
        ordlistaNo.put("Märke", "Merke");
        ordlistaNo.put("Artikelnr", "Varenr");
        ordlistaNo.put("Benämning", "Beskrivelse");
        ordlistaNo.put("Antal", "Antall");
        ordlistaNo.put("Pris", "Pris");
        ordlistaNo.put("Summa", "Belop");
        ordlistaNo.put("Totalt exkl. moms", "Totalt ekskl. Mva");
        ordlistaNo.put("Totalt inkl.", "Totalt inkl.");
        ordlistaNo.put("moms", "Mva");
        ordlistaNo.put("Ordererkännande", "Ordrebekreftelse");
        ordlistaNo.put("Orderbekräftelse", "Ordrebekreftelse");
        ordlistaNo.put("Order", "Ordre");
        ordlistaNo.put("Ordernr", "Ordrenr");
        ordlistaNo.put("Vår kontaktperson", "Vår kontaktperson");
        ordlistaNo.put("Leveransadress", "Leveringsadresse");
        ordlistaNo.put("Lev.dat", "Lev.dat");
        //ordlistaNo.put("", "");
    }

    public Translate() {
        this("se");
    }
    
    
    public Translate(String sprak) {
        this.sprak=sprak;
    }
    
    public String getSprak() {
        return sprak;
    }
    
    public String t(String ord) {
       if("se".equals(sprak)) return ord;
       String r = ordlistaNo.get(ord);
       if (r==null) return ord; else return r;
    }
    
}
