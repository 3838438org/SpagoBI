/* SpagoBI, the Open Source Business Intelligence suite

 * Copyright (C) 2012 Engineering Ingegneria Informatica S.p.A. - SpagoBI Competency Center
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0, without the "Incompatible With Secondary Licenses" notice. 
 * If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package it.eng.spagobi.kpi.config.metadata;

import it.eng.spagobi.commons.metadata.SbiExtRoles;
import it.eng.spagobi.commons.metadata.SbiHibernateModel;



/**
 * SbiKpiRole generated by hbm2java
 */

public class SbiKpiRole  extends SbiHibernateModel {


    // Fields    

     private Integer idKpiRole;
     private SbiExtRoles sbiExtRoles;
     private SbiKpi sbiKpi;


    // Constructors

    /** default constructor */
    public SbiKpiRole() {
    }

    
    /** full constructor */
    public SbiKpiRole(Integer idKpiRole, SbiExtRoles sbiExtRoles, SbiKpi sbiKpi) {
        this.idKpiRole = idKpiRole;
        this.sbiExtRoles = sbiExtRoles;
        this.sbiKpi = sbiKpi;
    }
    

   
    // Property accessors

    public Integer getIdKpiRole() {
        return this.idKpiRole;
    }
    
    public void setIdKpiRole(Integer idKpiRole) {
        this.idKpiRole = idKpiRole;
    }

    public SbiExtRoles getSbiExtRoles() {
        return this.sbiExtRoles;
    }
    
    public void setSbiExtRoles(SbiExtRoles sbiExtRoles) {
        this.sbiExtRoles = sbiExtRoles;
    }

    public SbiKpi getSbiKpi() {
        return this.sbiKpi;
    }
    
    public void setSbiKpi(SbiKpi sbiKpi) {
        this.sbiKpi = sbiKpi;
    }
   








}