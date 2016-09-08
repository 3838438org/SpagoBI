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

<%@page import="it.eng.spagobi.commons.dao.DAOFactory"%>
<%@page import="it.eng.spagobi.analiticalmodel.document.dao.IBIObjectDAO"%>
<%@page import="it.eng.spagobi.analiticalmodel.document.bo.BIObject"%>
<%@page import="it.eng.spagobi.commons.utilities.ObjectsAccessVerifier"%>
<%@page import="it.eng.spagobi.engines.config.bo.Engine"%>
<%@page import="it.eng.spagobi.utilities.engines.rest.ExecutionSession"%>

<%@ page language="java" pageEncoding="utf-8" session="true"%>

<%@ include file="/WEB-INF/jsp/commons/angular/angularResource.jspf"%>

<%
BIObject obj = null;
/* 
Integer objId = null; 
*/
String objId = null;
String objLabel = null;

IEngUserProfile profile = null;
List<String> executionRoleNames = new ArrayList();

Engine executingEngine = null;
String engineName = null;
String isFromDocumentWidget = null;
String isForExport = null;
String cockpitSelections = null;

try{
	profile = (IEngUserProfile)permanentSession.getAttribute(IEngUserProfile.ENG_USER_PROFILE);
	
	obj = (BIObject) aServiceResponse.getAttribute(SpagoBIConstants.OBJECT);
	objId = (String)(request.getParameter(SpagoBIConstants.OBJECT_ID));
	objLabel = request.getParameter(SpagoBIConstants.OBJECT_LABEL) != null ? ((String)request.getParameter(SpagoBIConstants.OBJECT_LABEL)) : obj.getLabel();
	
	isFromDocumentWidget = (String)(request.getParameter("IS_FROM_DOCUMENT_WIDGET"));
	isForExport = (String)(request.getParameter(SpagoBIConstants.IS_FOR_EXPORT));
	if(isForExport == null) {
		isForExport = "false";
	}
	
	cockpitSelections = (String)(request.getParameter(SpagoBIConstants.COCKPIT_SELECTIONS));
	
	if(obj == null 
			&& (
					(isForExport != null 
						&& ("true").equalsIgnoreCase(isForExport))
					|| (isFromDocumentWidget != null 
						&& ("true").equalsIgnoreCase(isFromDocumentWidget))
				)
	) {
		
		IBIObjectDAO biObjectDAO = DAOFactory.getBIObjectDAO();
		
		obj = biObjectDAO.loadBIObjectByLabel(objLabel);
	}

	executingEngine = obj.getEngine();
	engineName = executingEngine.getName();
	
	
	if(objId != null && !("null".equalsIgnoreCase(objId))) {
		Integer objIdInt = new Integer(objId);
		executionRoleNames = ObjectsAccessVerifier.getCorrectRolesForExecution(objIdInt, profile);
	} else {
		executionRoleNames = ObjectsAccessVerifier.getCorrectRolesForExecution(obj.getLabel(), profile);
	}
	
}catch (Exception e) {
	e.printStackTrace();
}

/*
	These two variables are needed for checking if the "Add to workspace" should be available for the current user. This option is available when 
	the document is executed and it serves to add link to that particular document in the Organizer (Documents view) in the Workspace (for that 
	particular user). Variables are at disposal for using for other purposes as well.
	@author Danilo Ristovski (danristo, danilo.ristovski@mht.net)
*/
boolean isAdmin = UserUtilities.isAdministrator(userProfile);
boolean isSuperAdmin = (Boolean)((UserProfile)userProfile).getIsSuperadmin();

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<% 
if(executionRoleNames.size() > 0) {
%>
	<head>
		<%@include file="/WEB-INF/jsp/commons/angular/angularImport.jsp"%>
		<!-- Styles -->
		<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/themes/commons/css/customStyle.css"> 
		<script type="text/javascript" src="<%=urlBuilder.getResourceLink(request, "js/src/angular_1.4/tools/commons/component-tree/componentTree.js")%>"></script>
		<script type="text/javascript" src="<%=urlBuilder.getResourceLink(request, "js/src/angular_1.4/tools/commons/document-tree/DocumentTree.js")%>"></script>
		<script type="text/javascript" src="<%=urlBuilder.getResourceLink(request, "js/lib/angular/ngWYSIWYG/wysiwyg.min.js")%>"></script>	
		<link rel="stylesheet" type="text/css" href="<%=urlBuilder.getResourceLink(request, "js/lib/angular/ngWYSIWYG/editor.min.css")%>"> 
		
		<!-- 	breadCrumb -->
		<script type="text/javascript" src="${pageContext.request.contextPath}/js/src/angular_1.4/tools/commons/BreadCrumb.js"></script>
		<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/themes/glossary/css/bread-crumb.css">
		
		<!-- cross navigation -->
		<script type="text/javascript"  src="<%=urlBuilder.getResourceLink(request, "js/src/angular_1.4/tools/commons/cross-navigation/crossNavigationDirective.js")%>"></script>
		<!--  -->
		<style type="text/css">
			.requiredField {color: red!important; font-weight: bold;}
			.norequiredField {}
			md-select.requiredField > md-select-value{color: red!important;}
		</style>
		<style type="text/css">
			.topsidenav {min-width:100% !important; max-width:100% !important; min-height:40%;}
			.lateralsidenav {min-width:350px !important; max-width:350px !important;}
		</style>
	</head>

	<body class="kn-documentExecution" ng-app="documentExecutionModule" ng-controller="documentExecutionController" layout="row" ng-cloak >
		<div  layout-fill ng-hide="hideProgressCircular.status" style="z-index: 10000; position: absolute; background-color: rgba(0, 0, 0, 0.21);">
	   		<md-progress-circular md-mode="indeterminate" md-diameter="60" 
					style="left: 50%;top: 50%;margin-left: -30px;margin-top: -30px;"></md-progress-circular>
	    </div>
					
		<md-sidenav class="md-sidenav-right md-whiteframe-4dp lateralsidenav" 
				ng-if="'<%=obj.getParametersRegion() %>' == 'west'" md-component-id="parametersPanelSideNav" 
				layout="column" md-is-locked-open="showParametersPanel.status" 
				ng-include="'<%=urlBuilder.getResourceLink(request, "js/src/angular_1.4/tools/documentexecution/utils/sidenavTemplate/sidenavVertContent.jsp")%>'">		
		</md-sidenav>
	
		<div layout="column"  ng-init="initSelectedRole()" ng-cloak layout-fill>
		    <md-sidenav id="sidenavOri" class="md-sidenav-right md-whiteframe-4dp topsidenav" 
		    		ng-if="'<%=obj.getParametersRegion() %>' == 'north'" md-component-id="parametersPanelSideNav" 
		    		layout="column" md-is-locked-open="showParametersPanel.status" 
		    		ng-include="'${pageContext.request.contextPath}/js/src/angular_1.4/tools/documentexecution/utils/sidenavTemplate/sidenavVertContent.jsp'">
			</md-sidenav>
	<% 
	if(isFromDocumentWidget == null || ("false").equalsIgnoreCase(isFromDocumentWidget)) {
	%>
			<md-toolbar class="documentExecutionToolbar" flex="nogrow">
	            <div class="md-toolbar-tools" layout="row" layout-align="center center">
	                <i class="fa fa-file-text-o fa-2x"></i>
	                <span>&nbsp;&nbsp;</span>
	                <h2 class="md-flex" ng-hide="::crossNavigationScope.isNavigationInProgress()">
	                	{{::translate.load("sbi.generic.document")}}: {{executionInstance.OBJECT_NAME}}
	                </h2>
	                <cross-navigation cross-navigation-helper="crossNavigationScope.crossNavigationHelper" flex>
						<cross-navigation-bread-crumb id="clonedCrossBreadcrumb"> </cross-navigation-bread-crumb>
	 				</cross-navigation>
		
	                <span flex=""></span>
	                
		<% if(engineName.equalsIgnoreCase( SpagoBIConstants.COCKPIT_ENGINE_NAME)
							&& userId.equals(obj.getCreationUser())) {%>
	                <md-button ng-if="cockpitEditing.documentMode == 'EDIT'" class="md-icon-button" ng-click="::cockpitEditing.stopCockpitEditing()"
							aria-label="{{::translate.load('sbi.execution.executionpage.toolbar.viewcockpitdoc')}}"
	                		title="{{::translate.load('sbi.execution.executionpage.toolbar.viewcockpitdoc')}}">
						 <md-icon md-font-icon="fa fa-times-circle"></md-icon>
					</md-button>
	                <md-button ng-if="cockpitEditing.documentMode != 'EDIT'" class="md-icon-button" ng-click="::cockpitEditing.startCockpitEditing()"
							aria-label="{{::translate.load('sbi.execution.executionpage.toolbar.editcockpitdoc')}}"
	                		title="{{::translate.load('sbi.execution.executionpage.toolbar.editcockpitdoc')}}">
						 <md-icon md-font-icon="fa fa-pencil-square-o"></md-icon>
					</md-button>
		<%} %>
					
	                <md-button class="md-icon-button"  ng-if="checkHelpOnline()"  aria-label="{{::translate.load('sbi.generic.helpOnLine')}}" ng-click="openHelpOnLine()"
	                		title="{{::translate.load('sbi.generic.helpOnLine')}}">
						 <md-icon md-font-icon="fa fa-book"></md-icon>
					</md-button>
					
					<md-button class="md-icon-button" aria-label="{{::translate.load('sbi.scheduler.parameters')}}" ng-click="executeParameter()" 
							title="{{::translate.load('sbi.scheduler.refresh')}}">
						 <md-icon md-font-icon="fa fa-refresh"></md-icon>
					</md-button>
					<md-button class="md-icon-button" aria-label="{{::translate.load('sbi.scheduler.parameters')}}" ng-click="paramRolePanelService.toggleParametersPanel()"
							title="{{::translate.load('sbi.scheduler.parameters')}}" ng-if="!isParameterRolePanelDisabled.status">
						
						<md-icon md-font-icon="fa fa-filter"></md-icon> 
					</md-button>
					
					<md-menu-bar id="menu">
	                	<md-menu>
			                <md-button id="menuButton" class="md-icon-button" aria-label="Menu" ng-click="$mdOpenMenu()" >
			                	<md-icon md-font-icon="fa  fa-ellipsis-v"></md-icon>
						    </md-button>
						    <md-menu-content>
						    	<span class="divider">{{translate.load("sbi.ds.wizard.file")}}</span>
							    <md-menu-item class="md-indent">
				                	<md-icon class="fa fa-print "></md-icon>
					                <md-button ng-click="printDocument()">
					                	{{translate.load("sbi.execution.executionpage.toolbar.print")}}
					                </md-button>
					            </md-menu-item>
					            				     				          
								<span class="divider" >{{translate.load("sbi.execution.executionpage.toolbar.export")}}</span>
								<md-menu-item>
					                <md-menu>
						                <md-menu-item class="md-indent">
					                  		<md-icon class="fa fa-download"></md-icon>
						                  	<md-button ng-click="$mdOpenMenu()">{{translate.load("sbi.execution.executionpage.toolbar.export")}}</md-button>
						                </md-menu-item>
					                  	<md-menu-content>
						                    <md-menu-item class="md-indent" ng-repeat="exportationFormat in urlViewPointService.exportation">
						                    	<md-icon class="{{exportationFormat.iconClass}}"></md-icon>
						                    	<md-button ng-click="exportationFormat.func()">{{exportationFormat.description}}</md-button>
					                     	</md-menu-item>
					                  	</md-menu-content>
					                </md-menu>
				              	</md-menu-item>
				          
				          		<% if (userProfile.isAbleToExecuteAction(SpagoBIConstants.SEND_MAIL_FUNCTIONALITY)
				          				&&  obj.getBiObjectTypeCode().equals("REPORT")) { %>
				                <md-menu-item class="md-indent">
					            	<md-icon class="fa fa-paper-plane"></md-icon>
					            	<md-button aria-label="{{translate.load('sbi.execution.executionpage.toolbar.annotate')}}" class="toolbar-button-custom"
	                                		ng-click="sendMail()">{{translate.load('sbi.execution.executionpage.toolbar.send')}}
					                </md-button>
					            </md-menu-item>
								<%} %>
				          
				                <span class="divider">{{translate.load("sbi.generic.info")}}</span>
					            <% if (userProfile.isAbleToExecuteAction(SpagoBIConstants.SEE_METADATA_FUNCTIONALITY)) { %>
					            <md-menu-item class="md-indent">
					            	<md-icon class="fa fa-info-circle"></md-icon>
			                    	<md-button ng-click="openInfoMetadata()">{{translate.load("sbi.execution.executionpage.toolbar.metadata")}}</md-button>
					            </md-menu-item>
					            <%} %>
				                <md-menu-item class="md-indent">
					            	<md-icon class="fa fa-star"></md-icon>
					            	<md-button aria-label="{{translate.load('sbi.execution.executionpage.toolbar.rating')}}" class="toolbar-button-custom"
	                                	ng-click="rankDocument()">{{translate.load('sbi.execution.executionpage.toolbar.rating')}}
					                </md-button>
					            </md-menu-item>
								<% if (userProfile.isAbleToExecuteAction(SpagoBIConstants.SEE_NOTES_FUNCTIONALITY)) { %>
				                <md-menu-item class="md-indent">
					            	<md-icon class="fa fa-sticky-note-o"></md-icon>
					            	<md-button aria-label="{{translate.load('sbi.execution.executionpage.toolbar.annotate')}}" class="toolbar-button-custom"
	                                		ng-click="noteDocument()">{{translate.load('sbi.execution.executionpage.toolbar.annotate')}}
					                </md-button>
					            </md-menu-item>
								<%} %>
								
								<span class="divider">{{translate.load("sbi.execution.executionpage.toolbar.shortcuts")}}</span>
					     		
					     		<%
									/*
										Disable the "Add to workspace" option from the drop-down menu when the document is executed (three dots icon in the second toolbar)
										when the user is admin or superadmin, since those two roles cannot have their own workspace.
										@author Danilo Ristovski (danristo, danilo.ristovski@mht.net)
									*/
					            	if(!(isAdmin==true || isSuperAdmin==true)) {
								%>
						            <md-menu-item class="md-indent">
						                <md-icon class="fa fa-suitcase"></md-icon>
						            	<md-button ng-disabled="false" class="toolbar-button-custom" ng-click="urlViewPointService.addToWorkspace()"
						            			aria-label="{{translate.load('sbi.execution.executionpage.toolbar.saveview')}}">
					            			{{translate.load('sbi.execution.executionpage.toolbar.savemyworkspace')}}
						                </md-button>
						            </md-menu-item>
					            <% } %>
					            
					            <!--  
					            <md-menu-item class="md-indent">
					                <md-icon class="fa fa-heart"></md-icon>
					            	<md-button ng-disabled="false" class="toolbar-button-custom" ng-click="urlViewPointService.openFavoriteDefinitionForm()"
					            			aria-label="{{translate.load('sbi.execution.executionpage.toolbar.saveview')}}">
				            			{{translate.load('sbi.execution.executionpage.toolbar.addbookmark')}}
					                </md-button>
					            </md-menu-item>
					            -->
				            	
								<% if (userProfile.isAbleToExecuteAction(SpagoBIConstants.SEE_SNAPSHOTS_FUNCTIONALITY)) { %>
				                <md-menu-item class="md-indent">
					            	<md-button aria-label="{{translate.load('sbi.execution.executionpage.toolbar.showscheduled')}}"
					            			class="toolbar-button-custom" ng-click="urlViewPointService.getSchedulers()">
	                                	{{translate.load('sbi.execution.executionpage.toolbar.showscheduled')}}
					                </md-button>
					            </md-menu-item>
								<%} %>
								
								<md-menu-item class="md-indent">
					            	<md-button ng-show="urlViewPointService.showOlapMenu" aria-label="{{translate.load('sbi.execution.executionpage.toolbar.show.olap.customized')}}"
					            			class="toolbar-button-custom" ng-click="urlViewPointService.getOlapDocs()" >
					            			{{translate.load('sbi.execution.executionpage.toolbar.show.olap.customized')}}

					                </md-button>
					            </md-menu-item>
								
							</md-menu-content>
						</md-menu>
					</md-menu-bar>
                
               	   	<md-button class="md-icon-button" title="close" aria-label="Clear"  ng-if="isCloseDocumentButtonVisible()" ng-click="closeDocument()">
				   		<md-icon md-font-icon="fa fa-times"></md-icon>
					</md-button>
				</div>
	        </md-toolbar>
	<%} %>
       
            <div layout="row" flex="grow">
            	<!-- "ng-show" is used instead of "ng-if" (or "ng-switch") in order to prevent the iframe reloading -->
		 		<md-content id="documentFrameContainer" layout="row" flex="grow" ng-show="currentView.status == 'DOCUMENT'">  
		      		<div layout="row" flex layout-align="center center"
		      				ng-hide="execProperties.executionInstance.IS_FOR_EXPORT || urlViewPointService.frameLoaded">
			      		<md-progress-circular md-mode="indeterminate" md-diameter="70" ></md-progress-circular>
					</div>
					<iframe class="noBorder" id="documentFrame" name="documentFrame" ng-src="{{execProperties.documentUrl}}" iframe-onload="iframeOnload()"
							iframe-set-dimensions-onload flex="grow" ng-show="urlViewPointService.frameLoaded">
					</iframe>
				</md-content>
										
				<div flex layout ng-if="currentView.status == 'PARAMETERS'"> 
					<div ng-if="parameterView.status == 'FILTER_SAVED'" layout flex>
						<parameter-view-point-handler flex layout="column"/>
					</div>
					<div ng-if="parameterView.status == 'SCHEDULER'" layout flex>
						<document-scheduler flex layout="column"/>
					</div>
				</div>
				
				<div flex layout ng-if="currentView.status == 'OLAP'"> 
					<div ng-if="parameterView.status == 'OLAP'" layout flex>
						<document-olap flex layout="column"/>
					</div>
				</div>

	        </div>
		</div>
		
		<md-sidenav class="md-sidenav-left md-whiteframe-4dp lateralsidenav"  
				ng-if="'<%=obj.getParametersRegion() %>' == 'east'" md-component-id="parametersPanelSideNav" 
				layout="column" md-is-locked-open="showParametersPanel.status" 
				ng-include="'<%=urlBuilder.getResourceLink(request, "js/src/angular_1.4/tools/documentexecution/utils/sidenavTemplate/sidenavVertContent.jsp")%>'">
		</md-sidenav>

		<script type="text/javascript">
		///Module creation
		(function() {
			
			angular.module('documentExecutionModule', 
					['ngMaterial', 'ui.tree', 'sbiModule', 'document_tree', 'componentTreeModule', 'angular_table', 'ngSanitize', 'expander-box', 'ngAnimate', 'ngWYSIWYG','angular_list','cross_navigation','file_upload']);
			
			
			
			angular.module('documentExecutionModule').factory('execProperties', function() {
				 
				var selRole= '<%= request.getParameter("SELECTED_ROLE") %>'=='null' ? '' : '<%= request.getParameter("SELECTED_ROLE") %>';
				var crossParams= <%= request.getParameter("CROSS_PARAMETER") %>==null ? {} : <%= request.getParameter("CROSS_PARAMETER") %>;
				
				var obj = {
					roles: [<%for(Object roleObj : executionRoleNames) out.print("'" + (String)roleObj + "',");%>],
					executionInstance: {
						'OBJECT_ID' : <%= request.getParameter("OBJECT_ID") %>,
						'OBJECT_LABEL' : '<%= request.getParameter("OBJECT_LABEL") %>',
						'EDIT_MODE' : '<%= request.getParameter("EDIT_MODE") %>',
						'OBJECT_NAME' : '<%= obj.getName() %>',
						'OBJECT_TYPE_CODE' : '',
						'isFromCross' : false,
						'isPossibleToComeBackToRolePage' : false,
						'SBI_EXECUTION_ID' : '',
						'CROSS_PARAMETER' : crossParams,
						'ENGINE_LABEL' : '',
						'SidenavOri': '<%=obj.getParametersRegion() %>',
						'IS_FOR_EXPORT' : <%= isForExport %>
						<%
						if(cockpitSelections != null && !cockpitSelections.equalsIgnoreCase("")) {
						%>
						, 'COCKPIT_SELECTIONS' : '<%=cockpitSelections%>'
						<%
						}
					%>
						
					},
					parametersData: {
						documentParameters: []
					},
					documentUrl : '',
					selectedRole : {name : selRole },
	 				currentView :  {status : "DOCUMENT"},
	 				parameterView : {status : ""},
	 				isParameterRolePanelDisabled : {status : false},
	 				showParametersPanel : {status : false},
	 				hideProgressCircular : {status : true},
 					//FLAGS FOR RESET DEPENDENCIES PARAMETERS VALUE 
	 				initResetFunctionVisualDependency : {status : false},
 					returnFromVisualViewpoint : {status : false},
 					initResetFunctionDataDependency : {status : false},
 					returnFromDataDepenViewpoint : {status : false},
 					initResetFunctionLovDependency : {status : false},
 					returnFromLovDepenViewpoint : {status : false}
				<%
				if(isFromDocumentWidget != null && "true".equalsIgnoreCase(isFromDocumentWidget)) {
					out.print(", isFromDocumentWidget: true ");
				}
				%>
				};
				return obj;
			});
			
			angular.module('documentExecutionModule').service('cockpitEditing',
					function($mdToast, execProperties, sbiModule_restServices, sbiModule_config, $filter) {
	<% 
	if(engineName.equalsIgnoreCase( SpagoBIConstants.COCKPIT_ENGINE_NAME)
		&& userId.equals(obj.getCreationUser())) { 
	%>
				
				var cockpitEditingService = this;
				
				cockpitEditingService.documentMode = 'VIEW';
				
				cockpitEditingService.startCockpitEditing = function() {
					cockpitEditingService.documentMode = 'EDIT';
					//cockpitEditingService.synchronize(this.controller, this.executionInstance);
				   	
					var newUrl = cockpitEditingService.changeDocumentExecutionUrlParameter('documentMode', cockpitEditingService.documentMode);
				   	//cockpitEditingService.controller.getFrame().setSrc(newUrl);
					execProperties.documentUrl = newUrl;
				};
				
				cockpitEditingService.stopCockpitEditing = function() {
					cockpitEditingService.documentMode = 'VIEW';
					//cockpitEditingService.synchronize(this.controller, this.executionInstance);
				   	
					var newUrl = cockpitEditingService.changeDocumentExecutionUrlParameter('documentMode', cockpitEditingService.documentMode);
				   	//cockpitEditingService.controller.getFrame().setSrc(newUrl);
					execProperties.documentUrl = newUrl;
				};
				
				cockpitEditingService.changeDocumentExecutionUrlParameter = function(parameterName, parameterValue) {
				    var docurl = execProperties.documentUrl;
				    var startIndex = docurl.indexOf('?') + 1;
				    var endIndex = docurl.length;
				    var baseUrl = docurl.substring(0, startIndex);
				    var docUrlPar = docurl.substring(startIndex, endIndex);
				    
				    docUrlPar = docUrlPar.replace(/\+/g, " ");
				    
				    var parameterNameLastIndexOf = docUrlPar.lastIndexOf(parameterName);
				    
			    	
				    if(parameterNameLastIndexOf == -1) {
				    	docUrlPar = docUrlPar.replace(/&$/g, "");
				    	docUrlPar += ("&" + parameterName + "=" + parameterValue);
				    	
				    } else {
				    	var initialUrlPar = docUrlPar.substring(0, parameterNameLastIndexOf);
				    	var middleUrlPar = docUrlPar.substring(parameterNameLastIndexOf);
				    	
				    	var ampersandCharIndexOf = middleUrlPar.indexOf('&') != -1 ? middleUrlPar.indexOf('&') : middleUrlPar.length;
				    	var lastUrlPar = middleUrlPar.substring(ampersandCharIndexOf);
				    	
				    	middleUrlPar = (parameterName + "=" + parameterValue);
				    	
				    	docUrlPar = initialUrlPar + middleUrlPar + lastUrlPar;
				    }
				    
				    var endUrl = baseUrl + docUrlPar;
				    
				    return endUrl;
				};
				
	<%} %>
			});

		})();
		</script>
		<script type="text/javascript" 
				src="<%=urlBuilder.getResourceLink(request, "js/src/angular_1.4/tools/documentexecution/utils/documentExecutionServices.js")%>"></script>
		<script type="text/javascript" 
				src="<%=urlBuilder.getResourceLink(request, "js/src/angular_1.4/tools/documentexecution/utils/documentExecutionExportService.js")%>"></script>
		<script type="text/javascript" 
				src="<%=urlBuilder.getResourceLink(request, "js/src/angular_1.4/tools/documentexecution/utils/documentExecutionFactories.js")%>"></script>
		<script type="text/javascript" 
				src="<%=urlBuilder.getResourceLink(request, "js/src/angular_1.4/tools/documentexecution/parameterViewPointHandler/parameterViewPointHandlerController.js")%>"></script>
		<script type="text/javascript" 
			src="<%=urlBuilder.getResourceLink(request, "js/src/angular_1.4/tools/documentexecution/documentScheduler/documentSchedulerController.js")%>"></script>
		<script type="text/javascript" 
			src="<%=urlBuilder.getResourceLink(request, "js/src/angular_1.4/tools/documentexecution/documentOlap/documentOlapController.js")%>"></script>
		<script type="text/javascript" 
				src="<%=urlBuilder.getResourceLink(request, "js/src/angular_1.4/tools/documentexecution/documentParamenterElement/documentParamenterElementController.js")%>"></script>
		<script type="text/javascript" 
				src="<%=urlBuilder.getResourceLink(request, "js/src/angular_1.4/tools/documentexecution/menuFunctions/infoMetadataService.js")%>"></script>
		<script type="text/javascript" 
				src="<%=urlBuilder.getResourceLink(request, "js/src/angular_1.4/tools/documentexecution/documentExecution.js")%>"></script>
		
		<script type="text/javascript" 
				src="<%=urlBuilder.getResourceLink(request, "js/src/angular_1.4/tools/documentexecution/documentExecutionNote.js")%>"></script>
		<script type="text/javascript" 
				src="<%=urlBuilder.getResourceLink(request, "js/src/angular_1.4/tools/documentexecution/documentExecutionRank.js")%>"></script>
	</body>
<% 
} else {
%>
	<head>
		<%@include file="/WEB-INF/jsp/commons/angular/angularImport.jsp"%>
	</head>
	<body ng-app="cantExecuteDocumentModule" ng-controller="cantExecuteDocumentController">
		<script>
		(function() {
			angular.module('cantExecuteDocumentModule', 
					['ngMaterial', 'sbiModule']);
			
			angular.module('cantExecuteDocumentModule')
			
			.factory('$documentBrowserScope', function($window) {
				/*
				// return $window.parent.angular.element($window.frameElement).scope().$parent.$parent;
				if($window.parent.angular && $window.frameElement!=null) {
					return $window.parent.angular.element($window.frameElement).scope().$parent.$parent;
				
				} else if($window.parent.parent.angular ){ // coming from cockpit DocumentWidget
					var scope = $window.parent.parent.angular.element($window.parent.parent.frameElement).scope().$parent
					if (!scope.changeNavigationRole) {
						scope.changeNavigationRole = function(){};
					}
					return scope;
					
				} else {
					var f = function(){};
					return {
						changeNavigationRole: f,
						isCloseDocumentButtonVisible: f
					};
				}
				*/
				
				var f = function(){};
				var fakeScope = {
						changeNavigationRole: f,
						closeDocument : f,
						isCloseDocumentButtonVisible: f
					};
				
				var ng = $window.parent.angular 
					|| $window.parent.parent.angular; // coming from cockpit DocumentWidget
				
				if(ng && $window.frameElement!=null) {
					//return ng.element($window.frameElement).scope().$parent.$parent;
					var scope = ng.element($window.frameElement).scope();
					if(scope && scope.$parent && scope.$parent.$parent) {
						return scope.$parent.$parent;
					} else {
						return fakeScope;
					}
				
				} else if(ng ){ // coming from cockpit DocumentWidget
//					var scope = ng.element($window.parent.parent.frameElement).scope().$parent;
					var scope = ng.element($window.parent.parent.frameElement).scope();
					
					if(scope && scope.$parent) {
						var scopeParent = scope.$parent;
						
						if (!scopeParent.changeNavigationRole) {
							scopeParent.changeNavigationRole = function(){};
						}
						return scopeParent;
					} else {
						return fakeScope;
					}
					
				} else {
					return fakeScope
				}
			})
			
			.controller( 'cantExecuteDocumentController', 
				['$scope', '$mdDialog', 'sbiModule_translate', '$documentBrowserScope', 
				 cantExecuteDocumentController]);

			function cantExecuteDocumentController(
					$scope, $mdDialog, sbiModule_translate, $documentBrowserScope) {
				
				var errorMessage = sbiModule_translate.load('sbi.execution.error.novalidrole');
				var okMessage = sbiModule_translate.load('sbi.general.ok');
				
				$mdDialog.show(
		      		$mdDialog.alert()
						.clickOutsideToClose(false)
					    .content(errorMessage)
					    .ariaLabel(errorMessage)
					    .ok(okMessage)
				).then(function() { 
					$documentBrowserScope.closeDocument(<%= request.getParameter("OBJECT_ID") %>);
				}, function() {});
			};
		})();
		</script>
	</body>
<% }%>
</html>