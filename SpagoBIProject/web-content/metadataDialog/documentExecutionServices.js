(function() {
	var documentExecutionModule = angular.module('documentExecutionModule');
	
	documentExecutionModule.service('documentExecuteServices', function($mdToast,execProperties,sbiModule_restServices,sbiModule_config,$filter,sbiModule_dateServices) {
		var documentExecuteServicesObj = {
//			decodeRequestStringToJson: function (str) {
//				var hash;
//				var parametersJson = {};
//				var hashes = str.slice(str.indexOf('?') + 1).split('&');
//				for (var i = 0; i < hashes.length; i++) {
//					hash = hashes[i].split('=');
//					parametersJson[hash[0]] = (/^\[.*\]$/).test(hash[1])?
//						JSON.parse(hash[1]) : hash[1] ;
//				}
//				return parametersJson;
//			},
			
				
			decodeRequestStringToJson: function (str) {
				var parametersJson = {};
				
				var arrParam = str.split('%26');
				for(var i=0; i<arrParam.length; i++){
					var arrJsonElement = arrParam[i].split('%3D');
					parametersJson[arrJsonElement[0]]=arrJsonElement[1];
				}
				return parametersJson;
			},
			
			showToast: function(text, time) {
				var timer = time == undefined ? 6000 : time;
				$mdToast.show($mdToast.simple().content(text).position('top').highlightAction(false).hideDelay(timer));
			},

			buildStringParameters : function (documentParameters) {
				console.log('buildStringParameters ' , documentParameters);
				
				var jsonDatum =  {};
				if(documentParameters.length > 0) {
					for(var i = 0; i < documentParameters.length; i++ ) {
						var parameter = documentParameters[i];
						var valueKey = parameter.urlName;
						var descriptionKey = parameter.urlName + "_field_visible_description";					
						var jsonDatumValue = null;
						var jsonDatumDesc = null;
						
						if(parameter.valueSelection.toLowerCase() == 'lov') {
							//TREE MODIFY (see with benedetto)
							if(parameter.selectionType.toLowerCase() == 'tree' || parameter.selectionType.toLowerCase() == 'lookup'){
//								if(parameter.multivalue) {
									var paramArrayTree = [];
									var paramStrTree = "";
									
									for(var z = 0; parameter.parameterValue && z < parameter.parameterValue.length; z++) {
										if(z > 0) {
											paramStrTree += ";";
										}
										
//										paramArrayTree[z] = parameter.parameterValue[z].value;
//										paramStrTree += parameter.parameterValue[z].value;
										paramArrayTree[z] = parameter.parameterValue[z];
										//old
										//paramStrTree += parameter.parameterValue[z];
										//modify description tree
										paramStrTree += parameter.parameterDescription[parameter.parameterValue[z]];
										
									}
									
									jsonDatumValue = paramArrayTree;
									jsonDatumDesc = paramStrTree;
//								} else {
//									jsonDatumValue = parameter.parameterValue? parameter.parameterValue.value : '';
//									jsonDatumDesc = parameter.parameterValue? parameter.parameterValue.value : '';
//								}
								
								
							} else {
//								parameter.parameterValue = parameter.parameterValue || [];
								if(			
										/*
										parameter.parameterValue 
										&& Array.isArray(parameter.parameterValue) 
										&& */
										parameter.multivalue) {
									
									parameter.parameterValue = parameter.parameterValue || [];
									
									jsonDatumValue = parameter.parameterValue;
									jsonDatumDesc = jsonDatumValue.join(";");
								} else {
//									jsonDatumValue = (typeof parameter.parameterValue === 'undefined')? '' : parameter.parameterValue;
									jsonDatumValue = parameter.parameterValue != undefined? parameter.parameterValue : '';
									jsonDatumDesc = jsonDatumValue;
								}
							}
						} else if(parameter.valueSelection.toLowerCase() == 'map_in'){
							if(parameter.parameterValue && parameter.multivalue) {
								parameter.parameterValue = parameter.parameterValue || [];
								
//								jsonDatumValue = parameter.parameterValue;
								jsonDatumValue = parameter.parameterValue.length > 0 ? 
										("'" + parameter.parameterValue.join("','") + "'") 
										: "";
								jsonDatumDesc = jsonDatumValue;
							} else {
								jsonDatumValue = (typeof parameter.parameterValue === 'undefined')? '' : parameter.parameterValue;
								jsonDatumDesc = jsonDatumValue;
							}
						} else {
							//DATE
							if(parameter.type=='DATE'){
//								dateToSubmit = $filter('date')(parameter.parameterValue, 
//										this.parseDateTemp(sbiModule_config.localizedDateFormat));
								//submit server date
								//dateToSubmit = sbiModule_dateServices.formatDate(parameter.parameterValue, t.parseDateTemp(sbiModule_config.serverDateFormat));
								var dateToSubmitFilter = $filter('date')(parameter.parameterValue, sbiModule_config.serverDateFormat);
								if( Object.prototype.toString.call( dateToSubmitFilter ) === '[object Array]' ) {
									dateToSubmit = dateToSubmitFilter[0].value;
								}else{
									dateToSubmit = dateToSubmitFilter;
								}
								console.log('date to sub ' + dateToSubmit);
								jsonDatumValue=dateToSubmit;
								jsonDatumDesc=dateToSubmit;							
							}
							//DATE RANGE
							else if(parameter.type=='DATE_RANGE'){
//								dateToSubmit = $filter('date')(parameter.parameterValue, 
//										this.parseDateTemp(sbiModule_config.localizedDateFormat));
								
								var dateToSubmitFilter = $filter('date')(parameter.parameterValue, sbiModule_config.serverDateFormat);
								if( Object.prototype.toString.call( dateToSubmitFilter ) === '[object Array]' ) {
									dateToSubmit = dateToSubmitFilter[0].value;
								}else{
									dateToSubmit = dateToSubmitFilter;
								}
								
								if(dateToSubmit!= '' && dateToSubmit!=null && parameter.datarange && parameter.datarange.opt){
									var defaultValueObj = {};
									for(var ii=0; ii<parameter.defaultValues.length; ii++){
										if(parameter.datarange && parameter.datarange.opt && parameter.defaultValues[ii].value==parameter.datarange.opt){
											defaultValueObj = parameter.defaultValues[ii];
											break;
										}
									}
									var rangeStr = defaultValueObj.quantity + this.getRangeCharacter(defaultValueObj.type);
									console.log('rangeStr ', rangeStr);
									jsonDatumValue=dateToSubmit+"_"+rangeStr;
									jsonDatumDesc=dateToSubmit+"_"+rangeStr;																
								}else{
									jsonDatumValue='';
									jsonDatumDesc='';
								}
							}
							else{
								jsonDatumValue = (typeof parameter.parameterValue === 'undefined')? '' : parameter.parameterValue;
								jsonDatumDesc = jsonDatumValue;
							}							
						}
						jsonDatum[valueKey] = jsonDatumValue;
						jsonDatum[descriptionKey] = jsonDatumDesc;
					}
				}		
				//console.log('jsonDAtum ' , jsonDatum);
				return jsonDatum;
			},
			
			parseDateTemp : function(date){
				result = "";
				if(date == "d/m/Y"){
					result = "dd/MM/yyyy";
				}
				if(date =="m/d/Y"){
					result = "MM/dd/yyyy"
				}
				return result;
			},
			
			getRangeCharacter : function(type){
				result = "";
				if(type=="days"){
					result = "D";
				}
				if(type=="years"){
					result = "Y";
				}
				if(type=="months"){
					result = "M";
				}
				if(type=="weeks"){
					result = "W";
				}
				return result;
			},
			
			
			
			recursiveChildrenChecks : function(parameterValue,parameterDescription,childrenArray) {
				childrenArray = childrenArray || [];
				for(var i = 0; i < childrenArray.length; i++) {
					var childItem = childrenArray[i];
					if(childItem.checked && childItem.checked == true) {
//						parameterValue.push(childItem);
						parameterValue.push(childItem.value);
						parameterDescription[childItem.value]=childItem.description;
					}
					
					if(!childItem.leaf) {
						documentExecuteServicesObj.recursiveChildrenChecks(parameterValue,parameterDescription,childItem.children);
					}
				}
			},
			
			resetParameterInnerLovData: function(childrenArray) { 
				childrenArray = childrenArray || [];
				
				for(var i = 0; i < childrenArray.length; i++) {
					var childItem = childrenArray[i];
					childItem.checked = false;
					
					if(!childItem.leaf) {
						documentExecuteServicesObj.resetParameterInnerLovData(childItem.children);
					}
				}
			},
			
			resetParameter: function(parameter) {
				if(parameter.valueSelection.toLowerCase() == 'lov') {
					if(parameter.selectionType.toLowerCase() == 'tree') {
						if(parameter.multivalue) {
							parameter.parameterValue = [];
							documentExecuteServicesObj.resetParameterInnerLovData(parameter.children);
						} else {
							parameter.parameterValue = '';
						}
					}else if(parameter.selectionType.toLowerCase() == 'lookup'){
						if(parameter.multivalue) {
							parameter.parameterValue = [];
						} else {
							parameter.parameterValue = '';
						}
					}
					else {
						if(parameter.multivalue) {
							parameter.parameterValue = [];
//							for(var j = 0; j < parameter.defaultValues.length; j++) {
//								var defaultValue = parameter.defaultValues[j];
//								defaultValue.isSelected = false;
//							}
						} else {
							parameter.parameterValue = '';
						}
					}
				} else {
					parameter.parameterValue = '';
					if(parameter.type=='DATE_RANGE' && parameter.datarange){
						parameter.datarange.opt='';
					}
					
				}
			},
						
//			showParameterHtml: function(parameter) {	
			setParameterValueResult: function(parameter) {	
				if(parameter.selectionType.toLowerCase() == 'tree'  ) {
					if(parameter.multivalue) {
						var toReturn = '';
						
						parameter.parameterValue =  [];
						parameter.parameterDescription =  {};
					    documentExecuteServicesObj.recursiveChildrenChecks(parameter.parameterValue,parameter.parameterDescription, parameter.children);
						for(var i = 0; i < parameter.parameterValue.length; i++) {
							var parameterValueItem = parameter.parameterValue[i];
							
							if(i > 0) {
								toReturn += ",<br/>";
							}
//							toReturn += parameterValueItem.value;
							toReturn += parameterValueItem;
						}
						
						return toReturn;
						
					} else {
						parameter.parameterValue = (parameter.parameterValue)?
								[parameter.parameterValue] : []
						parameter.parameterDescription = (parameter.parameterDescription)?
								parameter.parameterDescription : {}
								
						return (parameter.parameterValue && parameter.parameterValue.value)?
								parameter.parameterValue.value : '';
					}
				}else {
					if(parameter.multivalue) {
						parameter.parameterValue = parameter.parameterValue || [];
						var toReturn = parameter.parameterValue.join(",<br/>");
						return toReturn;
					} else {
						parameter.parameterValue = parameter.parameterValue || '';
						return parameter.parameterValue;
					}
				}
			}
		};
		
		return documentExecuteServicesObj;
	});
	
	documentExecutionModule.service('docExecute_pageviewService', function() {
			this.currentView ='DOCUMENT' ;				
			this.setCurrentView = function(currentView) {
				this.currentView = currentView;
			};
			this.getCurrentView = function() {
				return this.currentView;
			};
	});

	documentExecutionModule.service('docExecute_urlViewPointService', function(execProperties,
			sbiModule_restServices, $mdDialog, sbiModule_translate,sbiModule_config,docExecute_exportService
			,$mdSidenav,docExecute_paramRolePanelService,documentExecuteServices,documentExecuteFactories,$q,$filter,$timeout
			,docExecute_dependencyService,sbiModule_messaging, $http,sbiModule_dateServices ) {
		
		var serviceScope = this;	
		serviceScope.showOlapMenu = false;
//		serviceScope.documentUrl = '';
		serviceScope.frameLoaded = true;
		serviceScope.exportation=[];
	
		serviceScope.executionProcesRestV1 = function(role, params) {			
			params= typeof params === 'undefined' ? {} : params;

			var dataPost = {
					label: execProperties.executionInstance.OBJECT_LABEL,
					role:role,
					SBI_EXECUTION_ID:execProperties.executionInstance.SBI_EXECUTION_ID,
					parameters: params,
					EDIT_MODE:execProperties.executionInstance.EDIT_MODE
			};
			
			if (!!(execProperties.executionInstance.IS_FOR_EXPORT)) {
				dataPost.IS_FOR_EXPORT = true;
				
				if(execProperties.executionInstance.COCKPIT_SELECTIONS 
						&& execProperties.executionInstance.COCKPIT_SELECTIONS.trim() != '') {
					dataPost.COCKPIT_SELECTIONS = execProperties.executionInstance.COCKPIT_SELECTIONS;
				}
			}
			
			sbiModule_restServices.alterContextPath( sbiModule_config.contextName);
			sbiModule_restServices.promisePost("1.0/documentexecution", 'url', dataPost)
			.then(
					function(response, status, headers, config) {
						var data=response.data;
						var documentUrl = data.url+'&timereloadurl=' + new Date().getTime();
						
//						if (!!(execProperties.executionInstance.IS_FOR_EXPORT)) {
//							documentUrl += "&IS_FOR_EXPORT=true";
//							
//							if(execProperties.executionInstance.COCKPIT_SELECTIONS.trim() != '') {
//								documentUrl += "&COCKPIT_SELECTIONS=" + execProperties.executionInstance.COCKPIT_SELECTIONS;
//							}
//						}
						
						console.log("1.0/documentexecution/url -> " + documentUrl);
						
//						serviceScope.documentUrl = data.url+'&timereloadurl=' + new Date().getTime();
						execProperties.documentUrl = documentUrl;
						//SETTING EXPORT BUTTON
						serviceScope.exportation = docExecute_exportService.exportationHandlers[data['typeCode']];
						execProperties.executionInstance.ENGINE_LABEL=data['engineLabel'];
						serviceScope.showOlapMenu = serviceScope.getOlapType();
						//SETTING URL SBI EXECUTION ID
						if(data['sbiExecutionId'] && data['sbiExecutionId'].length>0){
							execProperties.executionInstance.SBI_EXECUTION_ID=data['sbiExecutionId']; 
						}
						//execProperties.currentView.status = 'DOCUMENT';
					},
					function(response, status, headers, config) {
						console.log('1.0/documentexecution ERROR: ', response.data);
//						sbiModule_restServices.errorHandler(response.data,"Error while attempt to load filters")
//						.then(function(){
//						if(response.data.errors[0].type=="missingRole" || response.data.errors[0].category=="VALIDATION_ERROR"){
//						docExecute_paramRolePanelService.toggleParametersPanel(true);
//						}
//						}); 
						if(response.data.errors[0].type=="missingRole" || response.data.errors[0].category=="VALIDATION_ERROR"){
							docExecute_paramRolePanelService.toggleParametersPanel(true);
						}else{
							sbiModule_restServices.errorHandler(response.data,response.data.errors[0].message);
						}

						serviceScope.frameLoaded = true; 
					});
		};
		
		serviceScope.getViewpoints = function() {
			execProperties.currentView.status = 'PARAMETERS';
			execProperties.parameterView.status='FILTER_SAVED';
			execProperties.isParameterRolePanelDisabled.status = true;

			sbiModule_restServices.get("1.0/documentviewpoint", "getViewpoints", 
					"label=" + execProperties.executionInstance.OBJECT_LABEL + "&role="+ execProperties.selectedRole.name)
			.success(function(data, status, headers, config) {	
				console.log('data viewpoints '  ,  data.viewpoints);
				serviceScope.gvpCtrlViewpoints = data.viewpoints;
//						execProperties.showParametersPanel.status = false;
				if($mdSidenav('parametersPanelSideNav').isOpen()) {
					docExecute_paramRolePanelService.toggleParametersPanel(false);
				}
			})
			.error(function(data, status, headers, config) {});																	
		};
		serviceScope.addToWorkspace = function() {
		
			sbiModule_restServices.promisePost('2.0/organizer/documents',execProperties.executionInstance.OBJECT_ID)
			.then(function(response) {
				console.log("[POST]: SUCCESS!");
				sbiModule_messaging.showSuccessMessage(sbiModule_translate.load("sbi.browser.document.addedToWorkspace"), sbiModule_translate.load('sbi.generic.success'));
			}, function(response) {
				if(response.data.errors[0].message=="not-enabled-to-call-service"){
					response.data.errors[0].message=sbiModule_translate.load('sbi.workspace.user.role.constraint');
				}
				
				// @modifiedBy Danilo Ristovski (danristo, danilo.ristovski@mht.net)
				sbiModule_messaging.showErrorMessage(sbiModule_translate.load(response.data.errors[0].message), sbiModule_translate.load('sbi.generic.error'));
			});
		};
			
		
		serviceScope.getSchedulers = function() {
			execProperties.currentView.status = 'PARAMETERS';
			execProperties.parameterView.status='SCHEDULER';
			sbiModule_restServices.get( "1.0/documentsnapshot", "getSnapshots", 
					"id=" + execProperties.executionInstance.OBJECT_ID)
			.success(function(data, status, headers, config) {	
				console.log('data scheduler '  ,  data.schedulers);
				serviceScope.gvpCtrlSchedulers = data.schedulers;
				console.log('url path ' + data.urlPath);
				serviceScope.snapshotUrlPath=data.urlPath;

				if($mdSidenav('parametersPanelSideNav').isOpen()) {
					docExecute_paramRolePanelService.toggleParametersPanel(false);
				}
			})
			.error(function(data, status, headers, config) {});																	
		};
		
		serviceScope.getOlapDocs = function() {
			execProperties.currentView.status = 'OLAP';
			execProperties.parameterView.status = 'OLAP';
			
			serviceScope.olapList = [];

			sbiModule_restServices.get("1.0/olapsubobjects", 'getSubObjects', 
					"idObj=" + execProperties.executionInstance.OBJECT_ID)
			.then(function(response){  
				angular.copy(response.data.results,serviceScope.olapList);
			},function(response){
				sbiModule_restServices.errorHandler(response.data,sbiModule_translate.load("sbi.alert.load.error"));
			});
		
		};
		
		serviceScope.getOlapType = function(){
			
//			if (execProperties.executionInstance.ENGINE_LABEL == "knowagewhatifengine" || execProperties.executionInstance.ENGINE_LABEL == "knowageolapengine")
			if (execProperties.executionInstance.ENGINE_LABEL == sbiModule_config.whatIfEngineContextName 
					|| execProperties.executionInstance.ENGINE_LABEL == sbiModule_config.olapEngineContextName)
				return true;
			else
				return false;
		}
		
		
		/*
		 * Fill Parameters Panel 
		 */
		serviceScope.fillParametersPanel = function(params){

			//console.log('Load filter params : ' , params);
			if(execProperties.parametersData.documentParameters.length > 0){

				//var readyParams //-> su questi parametri è stato settato il valore (o non ho nessun valore da settarvi) 
				//var dependingOnParameters //-> lista dei parametri dai quali dipendono altri parametri
				//var savedParamtersToSet //-> lista che scorro finchè non vuota, ogni volta che riesco a settarne uno, lo levo dalla lista
				//riesco a settare una valore quando tutti i paramteri (se ce ne sono) da cui dipende sono presenti in readyParams

				for(var i = 0; i < execProperties.parametersData.documentParameters.length; i++){
					var parameter = execProperties.parametersData.documentParameters[i];

					if(!params[parameter.urlName]) {
						documentExecuteServices.resetParameter(parameter);
					} else {
						//console.log('parametro ' , parameter);
//						if(parameter.valueSelection=='lov' 
////						&& parameter.multivalue==true
//						&& parameter.selectionType.toLowerCase() == "tree"
//						) {
						if(parameter.valueSelection=='lov') {
							if(parameter.selectionType.toLowerCase() == "tree" || parameter.selectionType.toLowerCase() == "lookup") {
								//TREE DESC FOR LABEL
								var ArrValue = JSON.parse(params[parameter.urlName]);
								var ArrDesc = params[parameter.urlName+'_field_visible_description'].split(';');
								if (typeof parameter.parameterDescription === 'undefined'){
									parameter.parameterDescription = {};
								}
								for(var w=0; w<ArrValue.length; w++){
									parameter.parameterDescription[ArrValue[w]] =ArrDesc[w];
								}
								parameter.parameterValue = ArrValue;
							} else {
								//FROM VIEWPOINT : the lov value saved (multivalue or single value) matched  with the parameter 
								//parameter.parameterValue = parameter.multivalue ? JSON.parse(params[parameter.urlName])	: params[parameter.urlName];
								//lookup old
//								if(parameter.selectionType.toLowerCase() == "lookup"){
//									var ArrValue = JSON.parse(params[parameter.urlName]);
//									var ArrDesc = params[parameter.urlName+'_field_visible_description'].split(';');
//									if (typeof parameter.parameterDescription === 'undefined'){
//										parameter.parameterDescription = {};
//									}
//									for(var w=0; w<ArrValue.length; w++){
//										parameter.parameterDescription[ArrValue[w]] =ArrDesc[w];
//									}
//									parameter.parameterValue = ArrValue;
//									
//								}else{
									parameter.parameterValue = parameter.multivalue ? JSON.parse(params[parameter.urlName])	: params[parameter.urlName];
								//}								
							}

						} else if(parameter.valueSelection.toLowerCase() == 'map_in') {
							var valueToBeCleanedByQuotes = params[parameter.urlName].replace(/^'(.*)'$/g, '$1');
							var valueToBeSplitted = valueToBeCleanedByQuotes.split("','");

							parameter.parameterValue = (parameter.multivalue)? valueToBeSplitted : valueToBeCleanedByQuotes;
						} else {
							if(parameter.type=='NUM'){
								parameter.parameterValue = parseFloat(params[parameter.urlName],10);
							}else if(parameter.type=='DATE'){
								
								//parameter.parameterValue= new Date(params[parameter.urlName]);
								//set parameter date server
								parameter.parameterValue= sbiModule_dateServices.getDateFromFormat(params[parameter.urlName], sbiModule_config.serverDateFormat);
								 
							}else if(parameter.type=='DATE_RANGE'){
								var dateRange = params[parameter.urlName];
								var dateRangeArr = dateRange.split('_');
								var range = dateRangeArr[1];
								dateRange = dateRangeArr[0];
								if (dateRange === parseInt(dateRange)){
									//FROM DEFAULT
									parameter.parameterValue= new Date(parseInt(dateRange)); 
								}else{
									//FROM VIEWPOINT
									parameter.parameterValue= new Date(dateRange); 
								}
								if(typeof parameter.datarange ==='undefined'){
									parameter.datarange = {};
								}
								parameter.datarange.opt=serviceScope.convertDateRange(range);
							}
							else if(parameter.type=='STRING'){
								parameter.parameterValue = params[parameter.urlName];									
								if(parameter.defaultValues && parameter.defaultValues.length > 0) {
									var parameterValues = parameter.parameterValue;
									var parArr = parameterValues.split(';');
									for(var j = 0; j < parameter.defaultValues.length; j++) {
										var defaultValue = parameter.defaultValues[j];
										for(var k = 0; k < parArr.length; k++) {
											if(defaultValue.value == parArr[k]) {
												defaultValue.isSelected = true;
												break;
											} else {
												defaultValue.isSelected = false;
											}											
										}
									}
								}
							}							
						}												
					}
					docExecute_dependencyService.visualCorrelationWatch(parameter);
					docExecute_dependencyService.dataDependenciesCorrelationWatch(parameter);
					
				}
				
				
			}
		};
		
		
		
		/*
		 * Convert the range date value format type_quantity FROM 5D To dayes_5;
		 */
		serviceScope.convertDateRange = function(range) {
			var value = "";
			if (range != null && range.length > 1) {
				var type = range.substring(range.length - 1, range.length);
				var quantity = range.substring(0, range.length - 1);
				if (type=="D") {
					type = "days";
				}
				if (type=="Y") {
					type = "years";
				}
				if (type=="W") {
					type = "weeks";
				}
				if (type=="M") {
					type = "months";
				}

				value = type + "_" + quantity;

			}
			return value;
		}
		
		
		
		
		
	
		serviceScope.getParametersForExecution = function(role, buildCorrelation,crossParameters) {
			var params = {
					label:execProperties.executionInstance.OBJECT_LABEL,
					role:role,
					parameters:crossParameters
			};
			sbiModule_restServices.promisePost("1.0/documentexecution", "filters", params)
			.then(function(response, status, headers, config) {
				console.log('getParametersForExecution response OK -> ', response);
				//check if document has parameters 
				if(response && response.data.filterStatus && response.data.filterStatus.length>0) {					

					//build documentParameters
					angular.copy(response.data.filterStatus, execProperties.parametersData.documentParameters);

					//correlation
					buildCorrelation(execProperties.parametersData.documentParameters);

					//setting default value				
					serviceScope.buildObjForFillParameterPanel(response.data.filterStatus);
					// Enable visualcorrelation
					execProperties.initResetFunctionVisualDependency.status=true;
					execProperties.initResetFunctionDataDependency.status=true;
					execProperties.initResetFunctionLovDependency.status=true;

					execProperties.isParameterRolePanelDisabled.status = docExecute_paramRolePanelService.checkParameterRolePanelDisabled();
				}else{
//					execProperties.showParametersPanel.status = false;
//					$mdSidenav('parametersPanelSideNav').close();
					docExecute_paramRolePanelService.toggleParametersPanel(false);

				} 

			},function(response, status, headers, config) {
				sbiModule_restServices.errorHandler(response.data,"error while attempt to load filters")   
			}); 
		};
		
		serviceScope.buildObjForFillParameterPanel = function(filterStatus){
			var fillObj = {};
			var hasDefVal = false;
			for(var i=0; i<filterStatus.length; i++){
				if(filterStatus[i].parameterValue && filterStatus[i].parameterValue.length>0){
					var arrDefToFill = [];
					var arrDefToFillDescription = []; //TREE
					//var fillObj = {};
					//MULTIVALUE
					hasDefVal= true;
					if(filterStatus[i].multivalue && filterStatus[i].valueSelection!='man_in' || filterStatus[i].selectionType=='TREE' || filterStatus[i].selectionType=='LOOKUP'){
						//if(filterStatus[i].defaultValues && filterStatus[i].defaultValues.length>0){
						//arrDefToFill=filterStatus[i].defaultValues;
						//}
						for(var k=0;k<filterStatus[i].parameterValue.length;k++){
							arrDefToFill.push(filterStatus[i].parameterValue[k].value);
							arrDefToFillDescription.push(filterStatus[i].parameterValue[k].description);
						}	
						fillObj[filterStatus[i].urlName] = JSON.stringify(arrDefToFill);
						//TREE - LOOKUP
						if(filterStatus[i].selectionType=='TREE' || filterStatus[i].selectionType=='LOOKUP'){
							var strDefToFillDescription ='';
							for(var z=0; z<arrDefToFillDescription.length; z++){
								strDefToFillDescription=strDefToFillDescription+arrDefToFillDescription[z];
								if(z<arrDefToFill.length-1){
									strDefToFillDescription=strDefToFillDescription+';';
								}
							}
							fillObj[filterStatus[i].urlName+'_field_visible_description'] = strDefToFillDescription;
						}else{
							fillObj[filterStatus[i].urlName+'_field_visible_description'] = JSON.stringify(arrDefToFill);
						}

					}else{
						//SINGLE VALUE
						fillObj[filterStatus[i].urlName] = filterStatus[i].parameterValue[0].value;
						fillObj[filterStatus[i].urlName+'_field_visible_description'] =filterStatus[i].parameterValue[0].value;	
					}
					//serviceScope.fillParametersPanel(fillObj);
				}
			}
			if(hasDefVal){serviceScope.fillParametersPanel(fillObj);}
		};
		
		serviceScope.createNewViewpoint = function() {
			$mdDialog.show({
				//scope : serviceScope,
				preserveScope : true,				
				templateUrl : sbiModule_config.contextName + '/js/src/angular_1.4/tools/glossary/commons/templates/dialog-new-parameters-document-execution.html',
				controllerAs : 'vpCtrl',
				controller : function($mdDialog) {
					var vpctl = this;
					vpctl.headerTitle = sbiModule_translate.load("sbi.execution.executionpage.toolbar.saveas");
					vpctl.name = sbiModule_translate.load("sbi.execution.viewpoints.name");
					vpctl.description = sbiModule_translate.load("sbi.execution.viewpoints.description");
					vpctl.visibility = sbiModule_translate.load("sbi.execution.subobjects.visibility");
					vpctl.publicOpt = sbiModule_translate.load("sbi.execution.subobjects.visibility.public");
					vpctl.privateOpt = sbiModule_translate.load("sbi.execution.subobjects.visibility.private");
					vpctl.cancelOpt = sbiModule_translate.load("sbi.ds.wizard.cancel");
					vpctl.submitOpt = sbiModule_translate.load("sbi.generic.update");					
					vpctl.submit = function() {
						vpctl.newViewpoint.OBJECT_LABEL = execProperties.executionInstance.OBJECT_LABEL;
						vpctl.newViewpoint.ROLE = execProperties.selectedRole.name;
						//vpctl.newViewpoint.VIEWPOINT = documentExecuteServices.buildStringParametersForSave(execProperties.parametersData.documentParameters);
						vpctl.newViewpoint.VIEWPOINT = documentExecuteServices.buildStringParameters(execProperties.parametersData.documentParameters);
						sbiModule_restServices.post(
								"1.0/documentviewpoint",
								"addViewpoint", vpctl.newViewpoint)
						.success(function(data, status, headers, config) {
							if(data.errors && data.errors.length > 0 ) {
								documentExecuteServices.showToast(data.errors[0].message);
							}else{
								$mdDialog.hide();
								documentExecuteServices.showToast(sbiModule_translate.load("sbi.execution.viewpoints.msg.saved"), 3000);
							}							
						})
						.error(function(data, status, headers, config) {
							documentExecuteServices.showToast(sbiModule_translate.load("sbi.execution.viewpoints.msg.error.save"),3000);	
						});
					};

					vpctl.annulla = function($event) {
						$mdDialog.hide();
						serviceScope.newViewpoint = JSON.parse(JSON.stringify(documentExecuteFactories.EmptyViewpoint));
					};
				},

				templateUrl : sbiModule_config.contextName 
					+ '/js/src/angular_1.4/tools/documentexecution/templates/dialog-new-parameters-document-execution.html'
			});
		};

		this.buildParameterForFirstExecution=function(navParam,menuParam){
			return angular.extend({},navParam,menuParam);
		};
	});
	
	documentExecutionModule.service('docExecute_paramRolePanelService', function(execProperties,$mdSidenav,$timeout) {

		this.checkParameterRolePanelDisabled = function() {
			return ((!execProperties.parametersData.documentParameters || execProperties.parametersData.documentParameters.length == 0)
					&& (execProperties.roles.length==1));		
		};

		this.returnToDocument = function() {
			execProperties.currentView.status = 'DOCUMENT';
			execProperties.parameterView.status='';
			execProperties.isParameterRolePanelDisabled.status = this.checkParameterRolePanelDisabled();
			execProperties.returnFromVisualViewpoint.status = true;
		};

		this.isExecuteParameterDisabled = function() {
			if(execProperties.parametersData.documentParameters.length > 0) {
				for(var i = 0; i < execProperties.parametersData.documentParameters.length; i++ ) {
					
//					if(execProperties.parametersData.documentParameters[i].mandatory 
//							&& (!execProperties.parametersData.documentParameters[i].parameterValue
//									|| execProperties.parametersData.documentParameters[i].parameterValue == '' )) {
//						return true;
//					}
					
					if(execProperties.parametersData.documentParameters[i].mandatory){
						if(execProperties.parametersData.documentParameters[i].type=='DATE_RANGE'){
							if(!execProperties.parametersData.documentParameters[i].parameterValue
							    || execProperties.parametersData.documentParameters[i].parameterValue == ''
								|| typeof execProperties.parametersData.documentParameters[i].datarange ==='undefined'
								|| execProperties.parametersData.documentParameters[i].datarange.opt==''
										 ){
									return true;
							}
						}else{
							if(!execProperties.parametersData.documentParameters[i].parameterValue
									|| execProperties.parametersData.documentParameters[i].parameterValue == ''){
								return true;
							}
							
						}						
					}					
				}
			}
			return false
		};

		this.toggleParametersPanel = function(open) {
			$timeout(function(){ 
				if(open==undefined){
					execProperties.showParametersPanel.status=!execProperties.showParametersPanel.status;
//					$mdSidenav('parametersPanelSideNav').toggle();
				}else if(open){
					execProperties.showParametersPanel.status=true;
//					$mdSidenav('parametersPanelSideNav').open();
				}else if(!open){
					execProperties.showParametersPanel.status=false;
//					$mdSidenav('parametersPanelSideNav').close();
				}
			},0);
		};
	});
	
	//DEPENDENCIES
	
	angular.module('documentExecutionModule').service('docExecute_dependencyService',
			function(execProperties, documentExecuteServices,sbiModule_restServices,sbiModule_dateServices,sbiModule_config) {
	
		var serviceScope = this;
		/*
		 * DATA DEPENDENCIES 
		 */
		this.buildDataDependenciesMap = function(parameters){
			//console.log('parameters ' , parameters);
			for(var i=0; i<parameters.length ; i++){
				if(parameters[i].dataDependencies && parameters[i].dataDependencies.length>0){						
					for(var k=0; k<parameters[i].dataDependencies.length; k++){ 
						var dependency = parameters[i].dataDependencies[k];						
						dependency.parameterToChangeUrlName = parameters[i].urlName;
						dependency.parameterToChangeId = this.getRowIdfromUrlName(parameters[i].urlName); 
						dependency.lovParameterMode = parameters[i].selectionType;
						//build visualCorrelationMap : Key is fatherUrlName 
						var keyMap = dependency.objParFatherUrlName;
						if (keyMap in serviceScope.dataDependenciesMap) {
							var dependenciesArr =  serviceScope.dataDependenciesMap[keyMap];
							dependenciesArr.push(dependency);
							serviceScope.dataDependenciesMap[keyMap] = dependenciesArr;
						} else {
							var dependenciesArr = new Array
							dependenciesArr.push(dependency);
							serviceScope.dataDependenciesMap[keyMap] = dependenciesArr;
						}						
					}
				}
			}
			
			for (var key in serviceScope.dataDependenciesMap) {
				//Fill Array DATA DEPENDENCIES
				var documentParamDependence = execProperties.parametersData.documentParameters[this.getRowIdfromUrlName(key)];
				serviceScope.observableDataDependenciesArray.push(documentParamDependence);	
			}
			//console.log('observableDataDependenciesArray ' , serviceScope.observableDataDependenciesArray);
		};
		
		this.dataDependenciesCorrelationWatch = function(value){
			//console.log('modify dependency : ' , value);
			//console.log('element key '+ value.urlName , serviceScope.dataDependenciesMap[value.urlName]);
			if(serviceScope.dataDependenciesMap[value.urlName]){
				for(var k=0; k<serviceScope.dataDependenciesMap[value.urlName].length; k++){
					var dataDependenciesElementMap = serviceScope.dataDependenciesMap[value.urlName][k];
					//objPost.MODE= (dataDependenciesElementMap.lovParameterMode!='TREE' ) ? 'simple' : 'complete';
					if(dataDependenciesElementMap.lovParameterMode!='TREE'){
						var objPost = {};
						objPost.OBJECT_LABEL = execProperties.executionInstance.OBJECT_LABEL;
						objPost.ROLE=execProperties.selectedRole.name;
						objPost.PARAMETER_ID=dataDependenciesElementMap.parameterToChangeUrlName;
						//console.log('mode parameter type ' + dataDependenciesElementMap.lovParameterMode);
						objPost.MODE='simple';
						objPost.PARAMETERS=documentExecuteServices.buildStringParameters(execProperties.parametersData.documentParameters);
						//objPost.PARAMETERS=JSON.parse('{"param1":"","param1_field_visible_description":"","param2":["South West"],"param2_field_visible_description":"South West"}');
						sbiModule_restServices.post("1.0/documentExeParameters", "getParameters", objPost)
						.success(function(data, status, headers, config) {  
							if(data.status=="OK"){
								//from root only visibled element !!! 
								//set to disabled all default value parameter 
								for(var z=0; z<execProperties.parametersData.documentParameters.length;z++){
									if(execProperties.parametersData.documentParameters[z].urlName==data.idParam){
										if(execProperties.parametersData.documentParameters[z].defaultValues &&
												execProperties.parametersData.documentParameters[z].defaultValues.length>0){
											for(var y=0;y<execProperties.parametersData.documentParameters[z].defaultValues.length;y++){
												//execProperties.parametersData.documentParameters[z].parameterValue = [];
												execProperties.parametersData.documentParameters[z].defaultValues[y].isEnabled=false; 
											} 
										}
										break;
									}
								}
								//Set to enabled the correct default value 
								if(data.result.root && data.result.root.length>0){
									for(var p=0; p<data.result.root.length;p++){   
										//console.log("parameter ID : " + data.idParam + " set value " + data.result.root[p].value);
										for(var z=0; z<execProperties.parametersData.documentParameters.length;z++){
											if(execProperties.parametersData.documentParameters[z].urlName==data.idParam){
												if(execProperties.parametersData.documentParameters[z].defaultValues &&
														execProperties.parametersData.documentParameters[z].defaultValues.length>0){
													for(var y=0;y<execProperties.parametersData.documentParameters[z].defaultValues.length;y++){
														if( execProperties.parametersData.documentParameters[z].defaultValues[y].value==data.result.root[p].value){
															//console.log("enabled for : " ,  execProperties.parametersData.documentParameters[z].defaultValues[y]);
															execProperties.parametersData.documentParameters[z].defaultValues[y].isEnabled=true;
															//if mandatory and if combo o list set parameter default !!!
															if(data.result.root.length ==1 && execProperties.parametersData.documentParameters[z].mandatory
																	&& (execProperties.parametersData.documentParameters[z].selectionType == 'COMBOBOX' 
																		|| execProperties.parametersData.documentParameters[z].selectionType == 'LIST')){

																execProperties.parametersData.documentParameters[z].parameterValue = execProperties.parametersData.documentParameters[z].multivalue ?
																		[data.result.root[0].value]	: data.result.root[0].value;																	
															}
														}	  
													} 
												}
												break;
											}
										}	   
									}
								}else{
									//If no element in root setting empty parameter value
									execProperties.parametersData.documentParameters[z].parameterValue = [];
								}  
							}
						})
						.error(function(data, status, headers, config) {});
						//END REST CALL
					}else{
						console.log('IS TREE .... CLEAR PARAM ID ' + dataDependenciesElementMap.parameterToChangeUrlName);
						for(var z=0; z<execProperties.parametersData.documentParameters.length;z++){
							if(execProperties.parametersData.documentParameters[z].urlName==dataDependenciesElementMap.parameterToChangeUrlName){
								if(execProperties.initResetFunctionDataDependency.status){
									console.log('Reset TREE PARAM ... ' + execProperties.parametersData.documentParameters[z].urlName);
									execProperties.parametersData.documentParameters[z].children = [];
									documentExecuteServices.resetParameter(execProperties.parametersData.documentParameters[z]);									
								}
								break;
							}
						}
						if(execProperties.returnFromDataDepenViewpoint.status){
							execProperties.initResetFunctionDataDependency.status=true;
							execProperties.returnFromDataDepenViewpoint.status = false;
						}
					}
				}	
				
			 }//check undefined		
		  };
			 
	    /*
		 * LOV DEPENDENCIES
		 */
		this.buildLovCorrelationMap = function(parameters){
			for(var i=0; i<parameters.length ; i++){
				if(parameters[i].lovDependencies && parameters[i].lovDependencies.length>0){						
					for(var k=0; k<parameters[i].lovDependencies.length; k++){
						var dependency = {};
						dependency.objParFatherUrlName = parameters[i].lovDependencies[k];
						dependency.parameterToChangeUrlName = parameters[i].urlName;
						//dependency.parameterToChangeId = this.getRowIdfromUrlName(parameters[i].urlName); 
						//build visualCorrelationMap : Key is fatherUrlName 
						var keyMap = dependency.objParFatherUrlName; // 
						if (keyMap in serviceScope.lovCorrelationMap) {
							var dependenciesArr =  serviceScope.lovCorrelationMap[keyMap];
							dependenciesArr.push(dependency);
							serviceScope.lovCorrelationMap[keyMap] = dependenciesArr;
							} else {
								var dependenciesArr = new Array
								dependenciesArr.push(dependency);
								serviceScope.lovCorrelationMap[keyMap] = dependenciesArr;
							}						
					}
				}
			}
			for (var key in serviceScope.lovCorrelationMap) {
				//Fill Array VISUAL DEPENDENCIES
				var documentParamLovDependency = execProperties.parametersData.documentParameters[this.getRowIdfromUrlName(key)];
				serviceScope.observableLovParameterArray.push(documentParamLovDependency);	
			}
		}

		this.lovCorrelationWatch = function(value){
			//console.log('LOV correlation : ' , value);
			if(serviceScope.lovCorrelationMap[value.urlName]){
				for(var k=0; k<serviceScope.lovCorrelationMap[value.urlName].length; k++){
					var dataDependenciesElementMap = serviceScope.lovCorrelationMap[value.urlName][k];
					var objPost = {};
					objPost.OBJECT_LABEL = execProperties.executionInstance.OBJECT_LABEL;
					objPost.ROLE=execProperties.selectedRole.name;
					objPost.PARAMETER_ID=dataDependenciesElementMap.parameterToChangeUrlName;
					objPost.MODE='simple';
					objPost.PARAMETERS=this.buildParameterLovDependencies();
					sbiModule_restServices.promisePost("1.0/documentExeParameters",	"getParameters", objPost)
						.then(
							function(response, status, headers, config) {
						   //console.log('execProperties parameters data : ', execProperties.parametersData.documentParameters)
						   for(var z=0; z<execProperties.parametersData.documentParameters.length;z++){
								if(execProperties.parametersData.documentParameters[z].urlName==response.data.idParam){
									execProperties.parametersData.documentParameters[z].defaultValues = [];
									//BUILD DEAFULT VALUE  
									var defaultValueArrCache = [];
									
									
										for(var k=0; k<response.data.result.root.length; k++){
											response.data.result.root[k].isEnabled = true;
											execProperties.parametersData.documentParameters[z].defaultValues.push(response.data.result.root[k]);
											defaultValueArrCache.push(response.data.result.root[k].value);											
										}
									
									
									//Remove parameter value if not present in default value (clean operation)
									//MULTIVALUE
									if( Object.prototype.toString.call( execProperties.parametersData.documentParameters[z].parameterValue ) === '[object Array]' ) {
										var paramValueArrCache= [];
										
										
										angular.copy(execProperties.parametersData.documentParameters[z].parameterValue,paramValueArrCache);
										for(var u=0; u<paramValueArrCache.length; u++){	
											var index = execProperties.parametersData.documentParameters[z].parameterValue.indexOf(paramValueArrCache[u]);
											if(defaultValueArrCache.indexOf(paramValueArrCache[u]) === -1) {
												execProperties.parametersData.documentParameters[z].parameterValue.splice(index, 1);
											}
										}
										//console.log('params Value multi after ' , execProperties.parametersData.documentParameters[z].parameterValue);
									}else{
										//SINGLEVALUE
										if(defaultValueArrCache.indexOf(execProperties.parametersData.documentParameters[z].parameterValue) === -1) {
											execProperties.parametersData.documentParameters[z].parameterValue='';
										}
										//console.log('params Value single after ' , execProperties.parametersData.documentParameters[z].parameterValue);
									}
									
									//if mandatory and is unique default value
									if(response.data.result.root.length==1 &&
											execProperties.parametersData.documentParameters[z].mandatory && 
											(execProperties.parametersData.documentParameters[z].selectionType=='LIST' ||
													execProperties.parametersData.documentParameters[z].selectionType=='COMBOBOX')){
											console.log('setting default value ', response.data.result.root[0].value);
											execProperties.parametersData.documentParameters[z].parameterValue = execProperties.parametersData.documentParameters[z].multivalue ?
													[response.data.result.root[0].value]	: response.data.result.root[0].value;
										}else{
											//don't back from viewpoint and default value 
											if(execProperties.initResetFunctionLovDependency.status){
											execProperties.parametersData.documentParameters[z].parameterValue = execProperties.parametersData.documentParameters[z].multivalue ?
													[]	: '';
											}
										}
																		
									execProperties.parametersData.documentParameters[z].lovNotDefine=false;
								}
															
						   }
						   
						   if(execProperties.returnFromLovDepenViewpoint.status){
								execProperties.initResetFunctionLovDependency.status=true;
								execProperties.returnFromLovDepenViewpoint.status = false;
							}
						   
						   
					   	},function(response, status, headers, config) {
							var lovParamName = dataDependenciesElementMap.parameterToChangeUrlName;
					   		var errorMes = '';
							if(typeof response.data!='undefined' &&  typeof response.data.errors !='undefined'){
								errorMes = response.data.errors[0].message;
							}
					   		if(typeof response.data.RemoteException !='undefined' ){
					   			errorMes = response.data.RemoteException.message;
					   		}
							//documentExecuteServices.showToast('Error LOV " '+ lovParamName +' " : ' + errorMes);
					   		var idRowParameter = serviceScope.getRowIdfromUrlName(lovParamName);
					   		execProperties.parametersData.documentParameters[idRowParameter].lovNotDefine=true;
							execProperties.parametersData.documentParameters[idRowParameter].defaultValues = [];
							execProperties.parametersData.documentParameters[idRowParameter].parameterValue = [];
						}
					   );	
				}
		}
	}				
	/*
	 * VISUAL DEPENDENCIES
	 */
	this.buildVisualCorrelationMap = function(parameters){
		for(var i=0; i<parameters.length ; i++){
			if(parameters[i].visualDependencies && parameters[i].visualDependencies.length>0){						
				for(var k=0; k<parameters[i].visualDependencies.length; k++){
					var dependency = parameters[i].visualDependencies[k];
					dependency.parameterToChangeUrlName = parameters[i].urlName;
					dependency.parameterToChangeId = this.getRowIdfromUrlName(parameters[i].urlName); 
					//build visualCorrelationMap : Key is fatherUrlName 
					var keyMap = dependency.objParFatherUrlName;
					if (keyMap in serviceScope.visualCorrelationMap) {
						var dependenciesArr =  serviceScope.visualCorrelationMap[keyMap];
						dependenciesArr.push(dependency);
						serviceScope.visualCorrelationMap[keyMap] = dependenciesArr;
					} else {
						var dependenciesArr = new Array
						dependenciesArr.push(dependency);
						serviceScope.visualCorrelationMap[keyMap] = dependenciesArr;
					}						
				}
			}
		}
		for (var key in serviceScope.visualCorrelationMap) {
			//Fill Array VISUAL DEPENDENCIES
			var documentParamVisualDependency = execProperties.parametersData.documentParameters[this.getRowIdfromUrlName(key)];
			serviceScope.observableVisualParameterArray.push(documentParamVisualDependency);	
		}
	};

	this.visualCorrelationWatch = function(value){
		//console.log('visual correlation : ' , value);
		if(serviceScope.visualCorrelationMap[value.urlName]){
			var forceExit=false;
			for(var k=0; k<serviceScope.visualCorrelationMap[value.urlName].length; k++){
				if(forceExit){
					break;
				}
				var visualDependency=serviceScope.visualCorrelationMap[value.urlName][k];
				//id document Parameter to control 
				var idDocumentParameter = visualDependency.parameterToChangeId;
				//value to compare
				var compareValueArr = visualDependency.compareValue.split(",");
				for(var z=0; z<compareValueArr.length; z++){
					var newValueStr = value.parameterValue;
					var compareValueStr=compareValueArr[z].trim();
					//conditions
					var condition = false;
					if( Object.prototype.toString.call( newValueStr ) === '[object Array]' ) {
						if(visualDependency.operation=='contains') {
							for(var l=0; l<newValueStr.length; l++){
								if(compareValueStr==newValueStr[l]){
									condition=true;
									break;
								}
							}
						}
						else { //not contains
							condition=true; 
							for(var l=0; l<newValueStr.length; l++){
								if(compareValueStr==newValueStr[l]){
									condition=false;
									break;
								}
							}
						}
					}else{
						if(value.type=="DATE" || value.type=="DATE_RANGE"){
							if(typeof newValueStr!= 'undefined' && newValueStr!=''){
								var dateToSubmit1 = sbiModule_dateServices.formatDate(newValueStr, documentExecuteServices.parseDateTemp(sbiModule_config.localizedDateFormat));
								condition = (visualDependency.operation=='contains') ? 
										(compareValueStr==dateToSubmit1) : condition=(compareValueStr!=dateToSubmit1);								
							}
						}else{
							condition = (visualDependency.operation=='contains') ? 
									(compareValueStr==newValueStr) : condition=(compareValueStr!=newValueStr);
						}						
					}

					if(condition){
						execProperties.parametersData.documentParameters[idDocumentParameter].label=visualDependency.viewLabel;
						execProperties.parametersData.documentParameters[idDocumentParameter].visible=true;
						//Exit if one conditions is verify
						/* BUG FIX LOAD DEFAULT AND VIEWPOIN PARAMS
						 No resetParameter for DEFAULT and Viewpoin  
						 */
						//console.log('reset for ' , execProperties.parametersData.documentParameters[idDocumentParameter]);
						if(execProperties.initResetFunctionVisualDependency.status){
							documentExecuteServices.resetParameter(execProperties.parametersData.documentParameters[idDocumentParameter]);
						}
						forceExit = true;
						break;
					}else{
						execProperties.parametersData.documentParameters[idDocumentParameter].visible=false;
					}								
				}
			}
		}  

		//if return to viewpoin enable visual correlation 
		if(execProperties.returnFromVisualViewpoint.status){
			execProperties.initResetFunctionVisualDependency.status=true;
			execProperties.returnFromVisualViewpoint.status = false;
		}
	};

	//GET ROW ID FROM URL NAME
	this.getRowIdfromUrlName = function(urlName){
		var row=0;
		for(var i=0; i<execProperties.parametersData.documentParameters.length; i++ ){
			if(execProperties.parametersData.documentParameters[i].urlName == urlName){
				row = i;
				break;
			}
		}
		return row;
	};		
		
	/* Lov dependencies : build the parameters to submit for getParameters service :
	 * From default and viewpoint the parameters are object array ([{'value':'Food'},{'description':'Food'}])
	 * For getParameters service parameters are array of value ['Food','Drink']
	 * 
	 */
	this.buildParameterLovDependencies = function(){
	 var obj = {};
		if(execProperties.parametersData.documentParameters && execProperties.parametersData.documentParameters.length>0
				&& execProperties.parametersData.documentParameters[0].parameterValue
				&& execProperties.parametersData.documentParameters[0].parameterValue.length>0
				&& execProperties.parametersData.documentParameters[0].parameterValue[0].value){
			
			var objToSend = execProperties.parametersData.documentParameters;
			for(var l=0; l<execProperties.parametersData.documentParameters.length; l++){
				var paramValueArr = execProperties.parametersData.documentParameters[l].parameterValue;
				var paramValueArrNew = [];
				if(execProperties.parametersData.documentParameters[l].parameterValue){
					for(var t=0; t<execProperties.parametersData.documentParameters[l].parameterValue.length; t++){
						paramValueArrNew.push(execProperties.parametersData.documentParameters[l].parameterValue[t].value);
					}
					objToSend[l].parameterValue = paramValueArrNew;										
				}
			}
			obj=documentExecuteServices.buildStringParameters(objToSend);
		}else{
			obj=documentExecuteServices.buildStringParameters(execProperties.parametersData.documentParameters);
		}
		return obj;
	};
		
		
	});
})();