<%--
Knowage, Open Source Business Intelligence suite
Copyright (C) 2016 Engineering Ingegneria Informatica S.p.A.

Knowage is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

Knowage is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
--%>


<%@ include file="/WEB-INF/jsp/commons/portlet_base.jsp"%>

<%@ page import="it.eng.spago.error.EMFUserError,
				 it.eng.spago.navigation.LightNavigationManager,
				 it.eng.spagobi.analiticalmodel.document.bo.BIObject,
                 it.eng.spagobi.analiticalmodel.document.dao.IBIObjectDAO,
				 it.eng.spagobi.behaviouralmodel.analyticaldriver.bo.Parameter,
				 it.eng.spagobi.behaviouralmodel.analyticaldriver.bo.ParameterUse,
				 it.eng.spagobi.behaviouralmodel.analyticaldriver.dao.IParameterUseDAO,
				 it.eng.spagobi.behaviouralmodel.check.bo.Check,
       			 it.eng.spagobi.behaviouralmodel.check.dao.ICheckDAO,
				 it.eng.spagobi.behaviouralmodel.lov.bo.ModalitiesValue,
                 it.eng.spagobi.behaviouralmodel.lov.dao.IModalitiesValueDAO,
				 it.eng.spagobi.commons.bo.Domain,
				 it.eng.spagobi.commons.bo.Role,
                 it.eng.spagobi.commons.constants.AdmintoolsConstants,
                 it.eng.spagobi.commons.constants.ObjectsTreeConstants,
				 it.eng.spagobi.commons.dao.DAOFactory,
                 it.eng.spagobi.commons.dao.IDomainDAO,
       			 it.eng.spagobi.commons.dao.IRoleDAO,
				 it.eng.spagobi.commons.utilities.ObjectsAccessVerifier,
       			 it.eng.spagobi.mapcatalogue.bo.GeoLayer,
       			 it.eng.spagobi.mapcatalogue.dao.ISbiGeoLayersDAO,
                 it.eng.spagobi.utilities.exceptions.SpagoBIRuntimeException,
                 java.util.ArrayList,
                 java.util.HashMap,
                 java.util.Iterator,
                 java.util.List,
                 java.util.Map"
%>


<%
	SourceBean moduleResponse = (SourceBean) aServiceResponse.getAttribute("DetailParameterModule"); 
	Parameter parameter = (Parameter) moduleResponse.getAttribute("parametersObj");
	String modality = (String) moduleResponse.getAttribute("modality");
	ArrayList list = (ArrayList) moduleResponse.getAttribute("listObj");
	ArrayList selTypeList = (ArrayList) moduleResponse.getAttribute("listSelType");

	Map formUrlPars = new HashMap();
	formUrlPars.put("PAGE", "detailParameterPage");
	formUrlPars.put("MESSAGEDET", modality);
	formUrlPars.put(LightNavigationManager.LIGHT_NAVIGATOR_DISABLED, "true");
    String formUrl = urlBuilder.getUrl(request, formUrlPars);
    
    Map backUrlPars = new HashMap();
    backUrlPars.put("PAGE", "detailParameterPage");
    backUrlPars.put(LightNavigationManager.LIGHT_NAVIGATOR_BACK_TO, "1");
    backUrlPars.put("MESSAGEDET", "EXIT_FROM_DETAIL");
    String backUrl = urlBuilder.getUrl(request, backUrlPars);
    String readonly = "readonly" ;
    String disabled = "disabled" ;
    boolean isreadonly = true;
    
    if (userProfile.isAbleToExecuteAction(SpagoBIConstants.PARAMETER_MANAGEMENT)){
    	isreadonly = false;
    	readonly = "";
    	disabled = "";
    }
       

    /* ISbiGeoLayersDAO dao = DAOFactory.getSbiGeoLayerDao();
	List<GeoLayer> layers = null;
	try {
		layers = dao.loadAllLayers(null, UserUtilities.getUserProfile());
	} catch (EMFUserError e) {
		throw new SpagoBIRuntimeException("Error loading the layers", e);
	} */
%>



<form method='POST' action='<%=formUrl%>' id ='parametersForm' name='parametersForm'>

	<table class='header-table-portlet-section'>
		<tr class='header-row-portlet-section'>
			<td class='header-title-column-portlet-section' style='vertical-align:middle;padding-left:5px;'>
				<spagobi:message key = "SBIDev.param.title" />
			</td>
			<td class='header-empty-column-portlet-section'>&nbsp;</td>
			
			<%  if (!isreadonly){%>
			<td class='header-button-column-portlet-section'>
				<a href="javascript:document.getElementById('parametersForm').submit()" style="line-height: 13px;"> 
	      			<img class='header-button-image-portlet-section mozillaSetup' 
	      			     title='<spagobi:message key = "SBIDev.param.saveButt" />' 
	      			     src='<%=urlBuilder.getResourceLinkByTheme(request, "/img/save.png", currTheme)%>' 
	      			     alt='<spagobi:message key = "SBIDev.param.saveButt" />' /> 
				</a>
			</td>
			<td class='header-button-column-portlet-section'>
				<input type='image' name='saveAndGoBack' id='saveAndGoBack' value='true' class='header-button-image-portlet-section'
					src='<%=urlBuilder.getResourceLinkByTheme(request, "/img/saveAndGoBack.png", currTheme) %>'
	      				title='<spagobi:message key = "SBIDev.param.saveAndGoBackButt" />' alt='<spagobi:message key = "SBIDev.param.saveAndGoBackButt" />'
				/> 
			</td>
			<%}%>
			
			<td class='header-button-column-portlet-section'>
				<% if(modality.equalsIgnoreCase(ObjectsTreeConstants.DETAIL_MOD)) {%>
					<a href='javascript:saveAndGoBackConfirm("<spagobi:message key = "SBIDev.param.saveConfirm" />","<%=backUrl%>")'> 
				<% } else { %>
					<a href='<%=backUrl%>'>
				<% } %>
	      				<img class='header-button-image-portlet-section' 
								title='<spagobi:message key="SBIDev.param.backButt" />'
								src='<%=urlBuilder.getResourceLinkByTheme(request, "/img/back.png", currTheme)%>' 
								alt='<spagobi:message key="SBIDev.param.backButt"/>' />
					</a>
				</td>
			</tr>
		</table>
	
	<div class='div_background_no_img' >
		<input type='hidden' value='<%= parameter.getId() %>' name='id' />
		
		<div class="div_detail_area_forms">
			<div class='div_detail_label'>
				<span class='portlet-form-field-label'>
					<spagobi:message key = "SBIDev.param.labelField"/>
				</span>
			</div>
			<div class='div_detail_form'>
				<input class='portlet-form-input-field' type="text" 
		               id="label" name="label" size="50" 
		               value="<%=StringEscapeUtils.escapeHtml(parameter.getLabel())%>" maxlength="20" <%=readonly%> />
		        &nbsp;*
			</div>
			<div class='div_detail_label'>
				<span class='portlet-form-field-label'>
					<spagobi:message key = "SBIDev.param.nameField"/>
				</span>
			</div>
			<div class='div_detail_form'>
				<input class='portlet-form-input-field' type="text"  <%=readonly%>
					   id="name" name="name" size="50" value="<%=StringEscapeUtils.escapeHtml(parameter.getName())%>" maxlength="40" />
		        &nbsp;*
			</div>
			<div class='div_detail_label'>
				<span class='portlet-form-field-label'>
					<spagobi:message key = "SBIDev.param.descriptionField"/>
				</span>
			</div>
			<div class='div_detail_form'>
				<input class='portlet-form-input-field' type="text" <%=readonly%>
					   id="description" name="description" size="50" 
		 			   value="<%=(parameter.getDescription() != null ? StringEscapeUtils.escapeHtml(parameter.getDescription()) : "")%>" 
		               maxlength="160" />
			</div>
		    <% String curr_value = parameter.getTypeId().toString();%>  
		 
			<div class='div_detail_label'>
				<span class='portlet-form-field-label'>
					<spagobi:message key = "SBIDev.param.modalityField"/>
				</span>
			</div>
			<div class='div_detail_form'>
				<% for (int i=0	; i<list.size(); i++){
		      	       Domain domain = new Domain();
		      	       domain = (Domain)list.get(i);
				//if(!(domain.getValueName().equalsIgnoreCase("number"))){
				%>
		      	<input type="radio" id="modality" name="modality" <%=disabled%>
		      	<% 
		      		if(modality.equalsIgnoreCase(ObjectsTreeConstants.DETAIL_MOD)) {%>
					 onclick="radioButtonClicked(this.value)" 
				<% } %>			   
		           	 value="<%=(String)domain.getValueCd() + "," + (domain.getValueId()).toString()%>" 
	           	 	<% 
           	 		if(curr_value.equals(domain.getValueId().toString())) { out.println(" checked='checked' "); } 
	           	 	%> >
	           		<%= domain.getTranslatedValueName(locale)%></input>
		   	    <% } %>
			</div>
			<div class='div_detail_label'>
				<span class='portlet-form-field-label'>
					<spagobi:message key = "SBIDev.param.isFunctional"/>
				</span>
			</div>
			<div class='div_detail_form'>
				<input class='portlet-form-input-field' type="checkbox" name="isFunctional" id="isFunctional" <%=disabled%>
					   value="true" <%=(parameter.isFunctional() ? "checked='checked'" : "")%>/>
			</div>
			<div class='div_detail_label'>
				<span class='portlet-form-field-label'>
					<spagobi:message key = "SBIDev.param.isTemporal"/>
				</span>
			</div>
			<div class='div_detail_form'>
				<input class='portlet-form-input-field' type="checkbox" name="isTemporal" id="isTemporal" <%=disabled%>
					   value="true" <%=(parameter.isTemporal() ? "checked='checked'" : "")%>/>
			</div>
			<div class='div_detail_label' style='display:none;'>
				<span class='portlet-form-field-label'>
					<spagobi:message key = "SBIDev.param.lengthField"/>
				</span>
			</div>
			<div class='div_detail_form' style='display:none;'>
				<input class='portlet-form-input-field' type="text" 
					   id="length" name="length" size="5" value="<%=parameter.getLength()%>" maxlength="2" <%=readonly%> />
			</div>
			<div class='div_detail_label' style='display:none;'>
				<span class='portlet-form-field-label'>
					<spagobi:message key = "SBIDev.param.maskField"/>
				</span>
			</div>
			<div class='div_detail_form' style='display:none;'>
				<input class='portlet-form-input-field' type="text" <%=readonly%>
					   id="mask" name="mask" size="50" 
					   value="<%=(parameter.getMask() != null ? StringEscapeUtils.escapeHtml(parameter.getMask()) : "")%>" maxlength="20" />
			</div>
		</div>
		<spagobi:error/>
	
<% 

if (modality.equalsIgnoreCase(ObjectsTreeConstants.DETAIL_INS)) { %>
	</div>
</form>
<% } else if (modality.equalsIgnoreCase(ObjectsTreeConstants.DETAIL_MOD)) { 

   ParameterUse paruse = (ParameterUse) moduleResponse.getAttribute("modalitiesObj");

   IRoleDAO rDao = DAOFactory.getRoleDAO();
   
   List roles = null;
   if (paruse.getUseID().intValue() != -1) 
	   roles = rDao.loadAllFreeRolesForDetail(paruse.getUseID());
   else roles = rDao.loadAllFreeRolesForInsert(parameter.getId());

   String[][] sysRoles = new String[roles.size()][3];
   for(int i=0; i<roles.size(); i++) {
    	Role role = (Role)roles.get(i);
    	sysRoles[i][0] = role.getId().toString();
    	sysRoles[i][1] = role.getName();
    	sysRoles[i][2] = role.getDescription();
    }    
   
   // get all possible roles
   List allRoles = null;
   allRoles = rDao.loadAllRoles();
   String[][] allSysRoles = new String[allRoles.size()][3];
   for(int i=0; i<allRoles.size(); i++) {
    	Role role = (Role)allRoles.get(i);
    	allSysRoles[i][0] = role.getId().toString();
    	allSysRoles[i][1] = role.getName();
    	allSysRoles[i][2] = role.getDescription();
   } 
   
   boolean hasRolesFreeForInsert = true;
   List freeRolesForInsert = rDao.loadAllFreeRolesForInsert(parameter.getId());
   if (freeRolesForInsert.size() == 0) hasRolesFreeForInsert = false;
   
   
   // get system checks
   ICheckDAO checkdao = DAOFactory.getChecksDAO();
   List checks = checkdao.loadAllChecks();
   String[][] sysChecks = new String[checks.size()][3];
   for(int i=0; i<checks.size(); i++) {
    	Check check = (Check)checks.get(i);
    	sysChecks[i][0]= check.getCheckId().toString();
    	sysChecks[i][1] = check.getName();
    	sysChecks[i][2] = check.getDescription();
    } 
    
   // list of modalityValues
   IModalitiesValueDAO aModalitiesValueDAO = DAOFactory.getModalitiesValueDAO();
   List allModalitiesValues = aModalitiesValueDAO.loadAllModalitiesValueOrderByCode();  
   
   //IDomainDAO domaindao = DAOFactory.getDomainDAO() ;
   //List typeLov = domaindao.loadListDomainsByType("INPUT_TYPE");

%>
		<input type='hidden' id='saveParameterUse' value='' name='' />
		<input type='hidden' id='selected_paruse_id' name='' value=''/>
		<input type='hidden' id='deleteParameterUse' name='' value=''/>
		<input type='hidden' value='<%= (paruse != null ? String.valueOf(paruse.getUseID()) : "") %>' name='useId' />


		<div style='width:100%;visibility:visible;' class='UITabs' 
		     	id='tabPanelWithJavascript' name='tabPanelWithJavascript'>
			<div class="first-tab-level" style="background-color:#f8f8f8">
				<div style="overflow: hidden; width:  100%">					

<%
	List paruses = (List) moduleResponse.getAttribute("parusesList");
	String paruse_idStr = (String) moduleResponse.getAttribute("selected_paruse_id");
	Integer paruse_idInt = new Integer(paruse_idStr);
	int paruse_id = Integer.parseInt(paruse_idStr);
	String linkClass = "tab";
	boolean foundSelectedParuseId = false;
	for (int i = 0; i < paruses.size(); i++){
		ParameterUse aParameterUse = (ParameterUse) paruses.get(i);
		if (aParameterUse.getUseID().equals(paruse_idInt)) {
			linkClass = "tab selected";
			foundSelectedParuseId = true;
		}
		else linkClass = "tab";
%>

					<div class='<%= linkClass%>'>
						<a href='javascript:changeParameterUse("<%= aParameterUse.getUseID().toString() %>", "<spagobi:message key = "SBIDev.param.saveAndChangeParameterUseConfirm" />")' 
							style="color:black;"> 
								<%= StringEscapeUtils.escapeHtml(aParameterUse.getLabel())%>
						</a>
					</div>

<%	}
	if(paruse_id < 0 || !foundSelectedParuseId)
		linkClass = "tab selected";
	else 
		linkClass = "tab";
	
	if (hasRolesFreeForInsert && !isreadonly) {
%>
					<div class='<%= linkClass%>'>
						<a href='javascript:changeParameterUse("-1", "<spagobi:message key = "SBIDev.param.saveAndChangeParameterUseConfirm" />")' 
						   		style="color:black;"> 
							<spagobi:message key = "SBIDec.param.newParameterUse" />
						</a>
					</div>
<% 	}%>

				</div>
			</div>
		</div>

		<table class='header-sub-table-portlet-section'>		
			<tr class='header-sub-row-portlet-section'>
				<% if (paruse_id != -1) { %>
				<td class='header-sub-title-column-portlet-section'>
					<spagobi:message key = "SBIDev.paramUse.title" />
				</td>
				<td class='header-empty-column-portlet-section'>&nbsp;</td>
				<%  	if (!isreadonly){%>
				<td class='header-button-column-portlet-section'>
					<a href='javascript:deleteParameterUseConfirm("<spagobi:message key="SBIDev.param.deleteParameterUseConfirm"/>")'>
						<img src= '<%=urlBuilder.getResourceLinkByTheme(request, "/img/erase.gif", currTheme) %>'
							title='<spagobi:message key = "SBIDev.param.eraseParameterUseButt" />' alt='<spagobi:message key = "SBIDev.param.eraseParameterUseButt" />'
						/>
					</a>
				</td>
				<% 		}%>
				<% } else { %>
					<td class='header-sub-title-column-portlet-section-no-buttons'>
						<spagobi:message key = "SBIDev.paramUse.title" />
					</td>
				<% } %>
			</tr>
		</table>

		<div class="div_detail_area_sub_forms">
			<div class='div_detail_label'>
				<span class='portlet-form-field-label'>
					<spagobi:message key = "SBIDev.paramUse.labelField" />
				</span>
			</div>
			<div class='div_detail_form'>
				<input class='portlet-form-input-field' type="text" <%=readonly%>
					   id="paruseLabel" name="paruseLabel" size="50" value="<%=StringEscapeUtils.escapeHtml(paruse.getLabel())%>" maxlength="20">
				&nbsp;*
			</div>
			<div class='div_detail_label'>
				<span class='portlet-form-field-label'>
					<spagobi:message key = "SBIDev.paramUse.nameField" />
				</span>
			</div>
			<div class='div_detail_form'>
				<input class='portlet-form-input-field' type="text" <%=readonly%>
					   id="paruseName" name="paruseName" size="50" value="<%=StringEscapeUtils.escapeHtml(paruse.getName())%>" maxlength="40">
		        &nbsp;*
			</div>
			<div class='div_detail_label'>
				<span class='portlet-form-field-label'>
					<spagobi:message key = "SBIDev.paramUse.descriptionField" />
				</span>
			</div>
			<div class='div_detail_form'>
				<input class='portlet-form-input-field' type="text" <%=readonly%>
					   id="paruseDescription" name="paruseDescription" size="50" 
					   value="<%=paruse.getDescription() == null ? "" : StringEscapeUtils.escapeHtml(paruse.getDescription())%>" maxlength="160">
			</div>
			
			
			
			
			
			
			
			
			
			
			
			
			
			<%if (!parameter.getType().equals(SpagoBIConstants.DATE_RANGE_TYPE)) { %>
	<div class='div_detail_label'>
		<span class='portlet-form-field-label'>
	  		<%if(parameter.getType().equals("DATE")){ %>
				<spagobi:message key = "SBIDev.ListParamUse.parInfo.Default"/>
			<%} else{ %>
				<spagobi:message key = "SBIDev.ListParamUse.parInfo.Name"/>
			<%} %>

		</span>
	</div>
<% }  %>

<%if (!parameter.getType().equals(SpagoBIConstants.DATE_RANGE_TYPE)) { %>
	<div class='div_detail_form' id = 'divForm' >
<% }   

  String lovName = null;
  Integer idLov = null;
  idLov = paruse.getIdLov();
  Integer idLovInit = new Integer(-1);
  if(idLov!= null){
  if(!idLov.toString().equals(idLovInit.toString())) {
   	ModalitiesValue modVal  = DAOFactory.getModalitiesValueDAO().loadModalitiesValueByID(idLov);
	lovName = modVal.getName();
  }
  }
  
	boolean isManualInput = false;
	boolean maximizerEnabled = false;
	String maximizerDisabled = disabled;
	boolean isLov = false;
	
	String valueSelection = "man_in";
	String selectedLayer = null;
	String selectedLayerProp = null;
	
	if(paruse.getValueSelection() != null) {
    	valueSelection = paruse.getValueSelection();
	}
	
	int manual = 0;
	if (paruse.getManualInput()!= null) {
		manual = paruse.getManualInput().intValue();
	}
	
	if(manual > 0 && valueSelection.equals("man_in")) { 
		isManualInput = true;
		maximizerEnabled = paruse.isMaximizerEnabled();
	} else if( valueSelection.equals("map_in")){
		isLov = false;
		maximizerEnabled = false;
		maximizerDisabled = "disabled";
		
		//selectedLayer = paruse.getSelectedLayer();
		//selectedLayerProp = paruse.getSelectedLayerProp();
	} else {
		isLov = true;
		maximizerEnabled = false;
		maximizerDisabled = "disabled";
	}
%> 
    
<%if (!parameter.getType().equals(SpagoBIConstants.DATE_RANGE_TYPE)) { %>
  		
  		<input type="radio" name="valueSelection" id ="valueSelection" value="lov" <%=disabled%> <% if(valueSelection.equals("lov")) { out.println(" checked='checked' "); } %> onClick = "lovControl(this.value);" />
	  	
  	
		<input 	class='portlet-form-input-field' type="text" id="paruseLovName" <%=disabled%>
		   		name="paruseLovName" size="40" 
				value="<%= lovName != null ? StringEscapeUtils.escapeHtml(lovName) : "" %>" maxlength="100" readonly <%if(!isLov) {out.println("disabled = 'disabled'");} %>>
  		
  		<input 	type='hidden' id='paruseLovId' value='<%=(idLov != null?(idLov.intValue() != -1 ? idLov.toString() : ""):"") %>' <%=disabled%>
           		name='paruseLovId' />
  		&nbsp;*&nbsp;
    	<input 	type='image' name="loadLovLookup" <%=readonly%> id="loadLovLookup" value="LovLookup" style='<%if(isLov) {out.println("display:inline;");} else {out.println("display:none;");} %>'
		   		src='<%=urlBuilder.getResourceLinkByTheme(request, "/img/detail.gif", currTheme)%>' 
		   		title='Lov Lookup' alt='Lov Lookup'/>
			 
	</div>
<% }  %>
		 
		 
<%if(!parameter.getType().equals("DATE") && !parameter.getType().equals(SpagoBIConstants.DATE_RANGE_TYPE)){ %>
	<div class='div_detail_label'>
		<span class='portlet-form-field-label'>
			&nbsp;
		</span>
	</div>	
	<div class='div_detail_form' id = 'divForm' >
		<select class='portlet-form-input-field' NAME="selectionType" id="paruseSelType" <% if (isManualInput) { out.print("disabled='disabled'"); } %>>
		<% 
		 String curr_seltype_val = paruse.getSelectionType();
		 if(curr_seltype_val == null) curr_seltype_val = "none";
		 for (int i=0	; i<selTypeList.size(); i++){
    	       Domain domain = new Domain();
    	       domain = (Domain)selTypeList.get(i);		
		%>		
        	<option <%=disabled%> VALUE="<%=(String)domain.getValueCd()%>" <%if(curr_seltype_val.equals(domain.getValueCd().toString())) { out.println(" selected='selected' "); } %> >
        	<%=domain.getTranslatedValueName(locale)%>
       <%} %>
       </select>  
    </div>	     
<% } else { %>
	<input type="hidden" NAME="selectionType" id="paruseSelType" value="COMBOBOX" />
<%}%>









		</div>	     

<%-- 		<div class='div_detail_label'>
			<span class='portlet-form-field-label'>
				<spagobi:message key="SBIDev.paramUse.mapInputCheck" />
			</span>
		</div>
 		<div class='div_detail_form'>
			
			<input type="radio" name="valueSelection" <%=disabled%> id ="valueSelection" value="map_in" 
					<% if(valueSelection.equals("map_in")) { out.println(" checked='checked' "); } %> onClick = "lovControl(this.value);" ></input>

			<select class='portlet-form-input-field' <%=disabled%> name=mapInputSelectedLayer id="mapInputSelectedLayer">
	       		<option value=""><spagobi:message key="SBIDev.paramUse.mapInputSelectLayer" /></option>
	       		<% for(GeoLayer layer : layers) { %>
	       		<option value="<%=layer.getLabel()%>"
	       				<%if(selectedLayer != null && selectedLayer.equals(layer.getLabel())) out.println(" selected='selected' "); %> >
       				<%=layer.getName()%></option>
	       		<% } %>
	       	</select>
	       	
	       	<input class='portlet-form-input-field' type="text" id="mapInputSelectedLayerProp"
					name="mapInputSelectedLayerProp" placeholder="<spagobi:message key="SBIDev.paramUse.mapInputSelectLayerProperty" />" 
					value="<%=selectedLayerProp != null ? selectedLayerProp : "" %>" maxlength="40" <%=readonly%> />
		</div> --%>
	
		<div class='div_detail_label'>
			<span class='portlet-form-field-label'>
				<spagobi:message key="SBIDev.paramUse.manInputCheck" />
			</span>
		</div>
		<div class='div_detail_form'>
			
			<input type="radio"  name="valueSelection" <%=disabled%> id ="valueSelection" value="man_in" <% if(valueSelection.equals("man_in")) { out.println(" checked='checked' "); } %> onClick = "lovControl(this.value);" ></input>
		</div>
	
		<div class='div_detail_label'>
			<span class='portlet-form-field-label'>
				<spagobi:message key = "SBIDev.paramUse.maximizerEnabled" />
			</span>
		</div>
		<div class='div_detail_form'>
			<input type="checkbox" name="maximizerEnabled" <%=maximizerDisabled%> id ="maximizerEnabled" value="true" <% if(maximizerEnabled) { out.println(" checked='checked' "); } %>></input>
		</div>
	
		<% 
		String defaultLovName = null;
	    Integer idLovForDefault = paruse.getIdLovForDefault() != null ? paruse.getIdLovForDefault() : -1;
	    Integer idLovInitForDefault = new Integer(-1);
	    if (!idLovForDefault.equals(idLovInitForDefault)) {
	         ModalitiesValue lovForDefault  = DAOFactory.getModalitiesValueDAO().loadModalitiesValueByID(idLovForDefault);
	         defaultLovName = lovForDefault.getName();
	    }
	    String defaultFormula = paruse.getDefaultFormula() != null ? paruse.getDefaultFormula().trim() : "";
	    %>
	
	    <div class='div_detail_label'>
        <span class='portlet-form-field-label'>
<% if (!parameter.getType().equals(SpagoBIConstants.DATE_RANGE_TYPE)) { %>
            <spagobi:message key = "SBIDev.paramUse.defaultValue" />
<% } else {%>
			<spagobi:message key = "SBIDev.paramUse.defaultValueStartDate" />
<% } %>
        </span>
    </div>
	        <div class='div_detail_form'>
	        <input type="radio" name="defaultMethod" id="defaultMethod" value="none" <%= (idLovForDefault == -1 && defaultFormula.equals("")) ? "checked='checked'" : "" %> />
	        <spagobi:message key="SBIDev.paramUse.noDefault" />
	    </div>
	    <div class='div_detail_label'>
	        <span class='portlet-form-field-label'>
	            &nbsp;
	        </span>
	    </div>
	    <div class='div_detail_form'>
	        <input type="radio" name="defaultMethod" id="defaultMethod" value="lov" <%= idLovForDefault != -1 ? "checked='checked'" : "" %> />
	        <spagobi:message key="SBIDev.paramUse.useLovForDefault" />
	        <input  class='portlet-form-input-field' type="text" id="paruseLovForDefaultName"
	                name="paruseLovForDefaultName" size="40" 
	                value="<%= defaultLovName != null ? StringEscapeUtils.escapeHtml(defaultLovName) : "" %>" maxlength="100" readonly>
	        
	        <input  type='hidden' id='paruseLovForDefaultId' value='<%=(idLovForDefault != null ? (idLovForDefault.intValue() != -1 ? idLovForDefault.toString() : ""):"") %>' <%=disabled%>
	                name='paruseLovForDefaultId' />
	
	        <input  type='image' name="loadLovForDefaultLookup" id="loadLovForDefaultLookup" value="LovForDefaultLookup"
	                src='<%=urlBuilder.getResourceLinkByTheme(request, "/img/detail.gif", currTheme)%>' 
	                title='Lov for default Lookup' alt='Lov for default Lookup'/>
	    
	    </div>
	    <div class='div_detail_label'>
	        <span class='portlet-form-field-label'>
	            &nbsp;
	        </span>
	    </div>
	    <div class='div_detail_form'>
	        <input type="radio" name="defaultMethod" id="defaultMethod" value="formula" <%= !defaultFormula.equals("") ? "checked='checked'" : "" %> <%= isManualInput ? "disabled='disabled'" : "" %> />
	        <spagobi:message key="SBIDev.paramUse.useFormulaForDefault" />
	        <select class='portlet-form-input-field' NAME=formulaForDefault id="formulaForDefault">
	            <option value="FIRST" <%= defaultFormula.equals("FIRST") ? "selected='selected'" : "" %> ><spagobi:message key="SBIDev.paramUse.useFormulaForDefault.FIRST" /></option>
	            <option value="LAST" <%= defaultFormula.equals("LAST") ? "selected='selected'" : "" %> ><spagobi:message key="SBIDev.paramUse.useFormulaForDefault.LAST" /></option>
	       </select>
	    </div>
	
<% if (parameter.getType().equals(SpagoBIConstants.DATE_RANGE_TYPE)) { %>

  
  <!-- Date Range management -->
	<div class='div_detail_label'>
		<span class='portlet-form-field-label'>Options</span>
	</div>

	<div class='div_detail_form' style="height: auto;">
		<table id='dateRangeTableOptions'>
			<tr class='portlet-form-field-label'>
				<th ></th>
				<th >Period</th>
				<th>Quantity</th>
				<!-- add button: in the header -->
				<th>
					<a alt='Add option' title='Add option' href='javascript:addDateRangeTableOption()'><img src='/knowage/themes/sbi_default/img/new.png'></a>
				</th>
			</tr>
		</table>
	</div>


	<script type="text/javascript">
		var currentDateRangeOptionId=0;
		//[[value, description]]
		var dateRangeOptions = [["years","<spagobi:message key = "SBIDev.paramUse.years" />"],["months","<spagobi:message key = "SBIDev.paramUse.months" />"],["weeks","<spagobi:message key = "SBIDev.paramUse.weeks" />"],["days","<spagobi:message key = "SBIDev.paramUse.days" />"]];
		
		var optionsToLoad = '<%=paruse.getOptions()==null?"":paruse.getOptions() %>';
		if (optionsToLoad.length != 0) {
			addDateRangeTableOptions(JSON.parse(optionsToLoad).options);
		} else {
			//at least 1 option, with 1 years (0 options not allowed)
			addDateRangeTableOptions([{type:dateRangeOptions[0][0],quantity:1}]);
		}

		/**
		* Add the existing saved options
		*/
		function addDateRangeTableOptions(options) {
			for (var i=0;i<options.length;i++) {
				var opt=options[i]; //{type:,quantity:}
				addDateRangeTableOption(opt);
			}
		}

		/** 
		* Add a saved or new option to table: opt = {type:,quantity:} , can be null (new option added)
		*/
		function addDateRangeTableOption(opt) {
			var table=document.getElementById('dateRangeTableOptions');
			var row=table.insertRow(-1);
			var remove=row.insertCell(-1);
			remove.innerHTML="<a alt='Remove option' title='Remove option' onclick='removeRow(this)'><img src='/knowage/themes/sbi_default/img/erase.gif'></a>"
			
			var type=row.insertCell(-1);
			type.innerHTML=getTypeCombo(currentDateRangeOptionId,opt?opt.type:null);
			
			var quantity=row.insertCell(-1);
			quantity.innerHTML="<input type='number' required='true' name='dateRangeOptionQuantity_"+currentDateRangeOptionId+"' value='"+(opt?opt.quantity:"1")+"' ></input>"
			
			row.insertCell(-1); //add
			currentDateRangeOptionId+=1;
		}

		//return the HTML of combobox of type of period (years,months and days)
		function getTypeCombo(optionId,type) {
			var res = "<select name='dateRangeOptionType_"+optionId+"'>";
			for (var i=0;i<dateRangeOptions.length;i++) {
				res+="<option value='"+dateRangeOptions[i][0]+"' "+(type===dateRangeOptions[i][0]?"selected":"")+">"+dateRangeOptions[i][1]+"</option>";
			}
			res+="</select>";
			return res;
		}

		//remove a row of table
		function removeRow(removeButton) {
			var cell=removeButton.parentNode;
			var row=cell.parentNode;
			var table=row.parentNode;
			table.removeChild(row);
		}
	</script>
	
<% } %>


</div>


	<table style="margin-bottom:5px;width:100%;">
		<tr>
			<td colspan="3" align="left">
				<table style="margin:0px;width:100%;">
					<tr>
						<td align="left" class='portlet-section-header'>
	  	   					<spagobi:message key = "SBIDev.paramUse.valTab3" />
	  	   				</td>
	  	   				<%  if (!isreadonly){%>
	  	   				<td width="50px" class='portlet-section-header'>
				  	   		<a onclick = "checkAllFreeRoles()" title='<spagobi:message 
				  	   		key = "SBIDev.paramUse.checkAllFreeRoles" />' 
				  	   		alt='<spagobi:message key = "SBIDev.paramUse.checkAllFreeRoles" />'>
								<img  src='<%=urlBuilder.getResourceLinkByTheme(request, "/img/expertok.gif", currTheme)%>'/>
							</a>
							<a onclick = "uncheckAllFreeRoles()" 
							title='<spagobi:message key = "SBIDev.paramUse.uncheckAllFreeRoles" />' 
							alt='<spagobi:message key = "SBIDev.paramUse.uncheckAllFreeRoles" />'>
								<img src='<%= urlBuilder.getResourceLinkByTheme(request, "/img/erase.png", currTheme)%>'/>
							</a>
						</td>
						<%  }%>
					</tr>
				</table>
	  	   	</td>
	  	</tr>
  	<% 
  		List roleAssociated = paruse.getAssociatedRoles();
  	    int count = 1;
  	    // checkableRolesStr contains the number of the roles that are checkable, separated by ','
  	    String checkableRolesStr = "";
  	    for(int i=0; i<allSysRoles.length; i++) { 
           	if(count==1) out.print("<tr class='portlet-font'>");
            boolean isRole = false;
            boolean isFree = false;
            String roleId = allSysRoles[i][0].toString();
            if (roleAssociated != null){
              	Role tmpRoleAssociated = null;
              	for (int j=0; j<roleAssociated.size(); j++) {
               		tmpRoleAssociated = (Role)roleAssociated.get(j);
               		if(roleId.equals(tmpRoleAssociated.getId().toString())) 
               		isRole = true; 
            	}
            }		    
  	    	for (int k=0; k<sysRoles.length;k++){
  	    		String id = sysRoles[k][0].toString();
  	    		if (id.equals(roleId)){
  	    			isFree = true;
  	    		}
  	    	}
  	    	out.print("<td class='portlet-section-body'>");
  	    	out.print("   <input type='checkbox' name='paruseExtRoleId' "+disabled+" id='extRole_" + i + "' value='"+roleId+"' ");
  	    	if(isRole) {
  	    		out.print(" checked='checked' ");
  	    	}
  	    	if(!isFree && !isRole) {
  	    		out.print(" disabled='disabled' ");
  	    	} else checkableRolesStr += i + ",";
  	    	out.print("></input>" + allSysRoles[i][1]);
  	    	out.print("</td>");
  	    	if((count < 3) && (i==(allSysRoles.length-1))){
  	    		int numcol = 3-count;
  	    		int num;
  	    		for (num = 0; num <numcol; num++){
  	    		  	out.print("<td class='portlet-section-body'>");
  	    	    	out.print("</td>");
  	    		}
				out.print("</tr>");
  	    	} 
  	    	if( (count==3) || (i==(allSysRoles.length-1)) ) {
  	    		out.print("</tr>");
  	    		count = 1;
  	    	} else {
  	    		count ++;
  	    	}
  	 	}
  	  %>
 	</table> 

	<table style="width:100%;">
		<tr>
	  		<td colspan="3" align="left" class='portlet-section-header'>
	  	    	<spagobi:message key = "SBIDev.paramUse.valTab2" />
	  	    </td>
	  	</tr>
	  	<% 
   		    List listChecks = paruse.getAssociatedChecks();
   		    Check tmpCheck = null;
   		    int counter = 1;
   		    for(int i=0; i<sysChecks.length; i++) { 
                    if(counter==1) {
                      out.print("<tr class='portlet-font'>");
                    }
                    boolean isCheck = false;
                    String checkId = sysChecks[i][0].toString();
                     //the list checks is not loaded at the moment
                    if (listChecks != null){
                    	for(int j=0; j<listChecks.size(); j++) {
                      		tmpCheck = (Check)listChecks.get(j);
               		  		if(checkId.equals(tmpCheck.getCheckId().toString())) 
               					isCheck = true; 
               			}
               		}	    
   		 		out.print("<td class='portlet-section-body'>");
   		 		out.print("   <input type='checkbox' name='paruseCheckId' "+disabled+" value='"+checkId+"' ");
   		 		if(isCheck) {
   		 			out.print(" checked='checked' ");
   		 		}
   		 		out.print(">" + sysChecks[i][1] + "</input>" );
   		 		out.print("</td>");
   		 		if((counter < 3) && (i==(sysChecks.length-1))){
   		 		  int numcol = 3-counter;
   		 		  int num;
   		 		  for (num = 0; num <numcol; num++){
   		 		  out.print("<td class='portlet-section-body'>");
   		 		  out.print("</td>");  
   		 		  }out.print("</tr>");
   		 		  } 
   		 		
   		 		if( (counter==3) || (i==(sysChecks.length-1)) ) {
   		 		 	out.print("</tr>");
   		 		 	counter = 1;
   		 		} else {
   		 		 	counter ++;
   		 		 }
   		  }
		%>
	</table>
	  	
	<script>
	 <%
		Parameter initialParameter = (Parameter) aSessionContainer.getAttribute("initial_Parameter");
		if (initialParameter == null) initialParameter = parameter;
		ParameterUse initialParuse = (ParameterUse) aSessionContainer.getAttribute("initial_ParameterUse");
		if (initialParuse == null) initialParuse = paruse;
		%>
	    var modality = '<%=StringEscapeUtils.escapeJavaScript(StringEscapeUtils.escapeHtml(initialParameter.getType())) + "," + initialParameter.getTypeId()%>';
	
		function radioButtonClicked(mod) {
			modality = mod;
		}
		

	var manualInputSelection = '<%=valueSelection != null ? valueSelection : "man_in" %>';
	
	function lovControl(newManualInputSelectionValue) {
		manualInputSelection = newManualInputSelectionValue;
		
		console.log('lovControl function: newManualInputSelectionValue = "' + newManualInputSelectionValue + '"');
		
		
		var loadLovLookup = document.getElementById('loadLovLookup'); //lov lookup detail button
		var paruseLovName = document.getElementById('paruseLovName'); //lov input text
		var paruseSelType = document.getElementById('paruseSelType'); //lov combobox
		var maximizerEnabledInput = document.getElementById('maximizerEnabled'); //"Expandable" checkbox

		if (manualInputSelection.toLowerCase() == 'lov') {
			loadLovLookup.style.display = 'inline';
			paruseLovName.disabled = false;
			paruseSelType.disabled = false;
			maximizerEnabledInput.disabled = true;
		} else {
			
			if(loadLovLookup) loadLovLookup.style.display = 'none';
			if(paruseLovName) paruseLovName.disabled = true;
			if(paruseSelType) paruseSelType.disabled = true;
			if(maximizerEnabledInput) maximizerEnabledInput.disabled = false;
		}
		
		var isMapInput = false && !!(manualInputSelection.toLowerCase() == 'map_in'); // true or false
		
		var maximizerEnabled = document.getElementById('maximizerEnabled');
		maximizerEnabled.disabled = isMapInput;

		var defaultMethodFields = document.getElementsByName('defaultMethod');
		for(var i = 0; i < defaultMethodFields.length; i++) {
			var element = defaultMethodFields[i];
			if( element.value == 'formula') {
				element.disabled = isMapInput;
				
				if(isMapInput && element.checked == true) {
					element.checked = false;
					
					for(var j = 0; j < defaultMethodFields.length; j++) {
						var elementToCheck = defaultMethodFields[j];
						if(elementToCheck.value == 'none')
							elementToCheck.checked = true;
					}
				}
			}
		}
		
		
		var formulaForDefault = document.getElementsByName('formulaForDefault');
		for(var i = 0; i < formulaForDefault.length; i++) {
			var element = formulaForDefault[i];
			element.disabled = isMapInput;
		}
/*
		var mapInputSelectedLayer = document.getElementById('mapInputSelectedLayer');
		mapInputSelectedLayer.disabled = !isMapInput;
		
		var mapInputSelectedLayerProp = document.getElementById('mapInputSelectedLayerProp');
		mapInputSelectedLayerProp.disabled = !isMapInput;
		*/
	};
	lovControl(manualInputSelection);
	
	function isParuseformModified () {
		var paruseLabel = document.getElementById('paruseLabel').value;
		var paruseName = document.getElementById('paruseName').value;
		var paruseDescription = document.getElementById('paruseDescription').value;
		var paruseLovId = document.getElementById('paruseLovId')?document.getElementById('paruseLovId').value:'';
		var manIn;
		if (manualInputSelection == 'lov') {
			manIn = 0;
		} else {
			manIn = 1;
		}
		
		var initialRoles = new Array();
			
		<%
			List initialRoles = initialParuse.getAssociatedRoles();
			Iterator initialRolesIt = initialRoles.iterator();
			int c = 0;
			while (initialRolesIt.hasNext()) {				
				Role aRole = (Role) initialRolesIt.next();
				out.print("initialRoles["+c+"]="+aRole.getId().toString()+";\n");
				c++;
			}
		%>
			
		paruseExtRoleId=document.forms[0].paruseExtRoleId;
		var roles = new Array();
		var count = 0;
		for (i=0 ; i < paruseExtRoleId.length; i++) {
			if (paruseExtRoleId[i].checked) {
				roles[count] = paruseExtRoleId[i].value;
				count++;
			}
		}
			
		var rolesChanged = arraysChanged(roles, initialRoles);
			
		var initialChecks = new Array();
			
		<%
			List initialChecks = initialParuse.getAssociatedChecks();
			Iterator initialChecksIt = initialChecks.iterator();
			c = 0;
			while (initialChecksIt.hasNext()) {
				Check aCheck = (Check) initialChecksIt.next();
				out.print("initialChecks["+c+"]="+aCheck.getCheckId().toString()+";\n");
				c++;
			}
		%>
			
		paruseCheckId=document.forms[0].paruseCheckId;
		var checks = new Array();
		count = 0;
		for (i = 0 ; i < paruseCheckId.length; i++) {
			if (paruseCheckId[i].checked) {
				checks[count] = paruseCheckId[i].value;
				count++;
			}
		}
			
		var checksChanged = arraysChanged(checks, initialChecks);
		
		if ((paruseLabel != '<%=StringEscapeUtils.escapeJavaScript(StringEscapeUtils.escapeHtml(initialParuse.getLabel()))%>')
			|| (paruseName != '<%=StringEscapeUtils.escapeJavaScript(StringEscapeUtils.escapeHtml(initialParuse.getName()))%>')
			|| (paruseDescription != '<%=StringEscapeUtils.escapeJavaScript(StringEscapeUtils.escapeHtml(initialParuse.getDescription())) != null ? StringEscapeUtils.escapeJavaScript(StringEscapeUtils.escapeHtml(initialParuse.getDescription())) : ""%>') 
			|| (paruseLovId != '<%= initialParuse.getIdLov().intValue() != -1 ? initialParuse.getIdLov().toString() : "" %>')
			|| (manualInputSelection != '<%=valueSelection%>')
			|| rolesChanged
			|| checksChanged) {
				return 'true';
		}
		else {
			return 'false';
		}
		
	}
	
	function changeParameterUse (paruseId, message) {
		var parameterUseFormModified = 'false';
		
		document.getElementById('selected_paruse_id').name = 'selected_paruse_id';
		document.getElementById('selected_paruse_id').value = paruseId;
		
		parameterUseFormModified = isParuseformModified();
		
		if (parameterUseFormModified == 'true') 
		{
			if (confirm(message)) {
				document.getElementById('saveParameterUse').name = 'saveParameterUse';
				document.getElementById('saveParameterUse').value= 'yes';
			} else {
				document.getElementById('saveParameterUse').name = 'saveParameterUse';
				document.getElementById('saveParameterUse').value= 'no';
			}
		}
		
		document.getElementById('parametersForm').submit();
	};
	
	function saveAndGoBackConfirm(message, url){
		var label = document.getElementById('label').value;
		var name = document.getElementById('name').value;
		var description = document.getElementById('description').value;

		if ((label != '<%=StringEscapeUtils.escapeJavaScript(StringEscapeUtils.escapeHtml(initialParameter.getLabel()))%>')
			|| (name != '<%=StringEscapeUtils.escapeJavaScript(StringEscapeUtils.escapeHtml(initialParameter.getName()))%>')
			|| (description != '<%=StringEscapeUtils.escapeJavaScript(StringEscapeUtils.escapeHtml(initialParameter.getDescription()))%>')
			|| (modality != '<%=StringEscapeUtils.escapeJavaScript(StringEscapeUtils.escapeHtml(initialParameter.getType())) + "," + initialParameter.getTypeId()%>')) {
			
			if (confirm(message)) {
				document.getElementById('saveAndGoBack').click();
			} else {
				location.href = url;
			}
			return;
		}
	
		var parameterUseFormModified = isParuseformModified();
	
		if (parameterUseFormModified == 'true') {
			
			if (confirm(message)) {
				document.getElementById('saveAndGoBack').click();
			} else {
				location.href = url;
			}
			return;
		}

		location.href = url;
	}
	
	function arraysChanged(array1, array2) {
		if (array1.length != array2.length) return true;
		array1.sort();
		array2.sort();
		for (x in array1) {
			if (array1[x] != array2[x]) return true;
		}
		return false;
	};
	
	function deleteParameterUseConfirm (message) {
		if (confirm(message)) {
			document.getElementById('deleteParameterUse').name = 'deleteParameterUse';
			document.getElementById('deleteParameterUse').value = '<%= paruse.getUseID() %>';
	        	document.getElementById('parametersForm').submit();
	    	}
	};

	var checkableRoles = new Array();
	<%
  	if (checkableRolesStr.endsWith(",")) 
  		checkableRolesStr = checkableRolesStr.substring(0, checkableRolesStr.length() - 1);
  	
	String[] checkableRoles = checkableRolesStr.split(",");
  	if (checkableRoles != null && checkableRoles.length > 0) {
  		for (int k = 0; k < checkableRoles.length; k++) {
  	%>
			checkableRoles[<%=k%>] = '<%=checkableRoles[k]%>';
  	<%
	  	}
  	}
	%>
	
	function checkAllFreeRoles() {
		for (x = 0;x<checkableRoles.length;x = x+1)  {
			aFreeCheckId = checkableRoles[x];
			aFreeCheck = document.getElementById('extRole_' + aFreeCheckId);
			aFreeCheck.checked = true;
		}
	};
	
	function uncheckAllFreeRoles() {
		for (x = 0;x<checkableRoles.length;x = x+1) {
			aFreeCheckId = checkableRoles[x];
			aFreeCheck = document.getElementById('extRole_' + aFreeCheckId);
			aFreeCheck.checked = false;
		}
	};
	
	
	</script>
</div>
</form>

<% } %>
