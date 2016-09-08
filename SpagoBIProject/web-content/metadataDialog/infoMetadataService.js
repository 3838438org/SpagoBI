(function() {
	angular.module('documentExecutionModule')
	.service('infoMetadataService', function(execProperties, sbiModule_translate, $mdDialog, documentExecuteServices, sbiModule_restServices, sbiModule_config,multipartForm,sbiModule_download) {
		/* static variables*/
		var lblTitle = sbiModule_translate.load('sbi.execution.executionpage.toolbar.metadata');
		var lblCancel = sbiModule_translate.load('sbi.general.cancel');
		var lblClose = sbiModule_translate.load('sbi.general.close');
		var lblSave = sbiModule_translate.load('sbi.generic.update');
		var lblGeneralMeta = sbiModule_translate.load('sbi.execution.metadata.generalmetadata');
		var lblShortMeta = sbiModule_translate.load('sbi.execution.metadata.shorttextmetadata');
		var lblLongMeta = sbiModule_translate.load('sbi.execution.metadata.longtextmetadata');
		var lblAttachments = sbiModule_translate.load('sbi.execution.metadata.attachments');
		
		console.log("Enter in infoMetadataService!");
		

		function getDate() {
			
			function addZero(i) {
			    if (i < 10) {
			        i = "0" + i;
			    }
			    return i;
			}
			
		    var d = new Date();
		    var h = addZero(d.getHours());
		    var m = addZero(d.getMinutes());
		    var hourMinute= h + ":" + m ;
		    
		    
		    var dd = addZero(d.getDate());
		    var mm = addZero(d.getMonth()+1); //January is 0!
		    var yyyy =d.getFullYear();

		    var today = mm+'/'+dd+'/'+yyyy;
		    
		    return today+" "+ hourMinute;
		}
		

		
		return {
		openInfoMetadata : function(){
		    $mdDialog.show({
				preserveScope : true,
		    	templateUrl: sbiModule_config.contextName + '/js/src/angular_1.4/tools/documentexecution/templates/documentMetadata.jsp',
		    	locals : {
					sbiModule_translate: sbiModule_translate,
					sbiModule_config: sbiModule_config,
					executionInstance: execProperties.executionInstance
				},
		    	parent: angular.element(document.body),
		    	clickOutsideToClose:false,
		    	controllerAs: "metadataDlgCtrl",
		    	controller : function($mdDialog, sbiModule_translate, sbiModule_config, executionInstance) {
		    		var metadataDlgCtrl = this;
		    		metadataDlgCtrl.selectedTab={'tab':0};
		    		metadataDlgCtrl.lblTitle = lblTitle;
		    		metadataDlgCtrl.lblCancel = lblCancel;
		    		metadataDlgCtrl.lblClose = lblClose;
		    		metadataDlgCtrl.lblSave = lblSave;
		    		metadataDlgCtrl.lblGeneralMeta = lblGeneralMeta;
		    		metadataDlgCtrl.lblShortMeta = lblShortMeta;
		    		metadataDlgCtrl.lblLongMeta = lblLongMeta;
		    		metadataDlgCtrl.lblAttachments = lblAttachments;
		    		
		    		metadataDlgCtrl.longExpanderOpened = true;
		    		metadataDlgCtrl.shortExpanderOpened = false;
		    		metadataDlgCtrl.fileExpanderOpened = false;

		    		
		    		
		    		
		    		metadataDlgCtrl.generalMetadata = [];
		    		metadataDlgCtrl.shortText = [];
		    		metadataDlgCtrl.longText = [];
		    		metadataDlgCtrl.file = [];
		    		metadataDlgCtrl.importedFile={}; 
		    		
		    		metadataDlgCtrl.linkToHiddenInputTypeFile=function () {		    			
			  			  const input   = document.getElementById('fileInput')
			  			  const button = document.getElementById('uploadButton');
			  			  button.click(input.click()); 	  
		    		}
		    		 
		    		metadataDlgCtrl.uploadFile=function (fileToSave) {		  
		    			if(fileToSave.file!=undefined && fileToSave.file!="" && fileToSave.file!=null)
		    			{	
		    			
							//Upload file to local directory
							//multipartForm.post("2.0/metadata/"+"upload",fileToSave).success(   
		    				multipartForm.post("1.0/documentexecution/"+"upload",fileToSave).success( 		
									function(data,status,headers,config){
										if(data.hasOwnProperty("errors")){						
											console.log("[UPLOAD]: DATA HAS ERRORS PROPERTY!");	
						    				documentExecuteServices.showToast("Upload error", 3);  
	
										}else{
						    				documentExecuteServices.showToast("Upload successfull", 3);  
											console.log("[UPLOAD]: SUCCESS!");
										}
	
									}).error(function(data, status, headers, config) {
										console.log("[UPLOAD]: FAIL!"+status);
					    				documentExecuteServices.showToast("Upload error", 3);  
									});
		    			}
		    			else
		    			{
		    				documentExecuteServices.showToast("Select a file to Upload!", 3);  
							console.log("[UPLOAD]: SELECT A FILE TO UPLOAD!");
		    			}	
		    			
		    		}
		    		
		    		var params = null;
		    		
		    		metadataDlgCtrl.setTab = function(Tab){
		    			metadataDlgCtrl.selectedTab.tab = Tab;
		    		}
		    		metadataDlgCtrl.isSelectedTab = function(Tab){
		    			return (Tab == metadataDlgCtrl.selectedTab.tab) ;
		    		}
		    		
		    		if(executionInstance.SUBOBJECT_ID){
		    			params = {subobjectId: executionInstance.SUBOBJECT_ID};
		    		}
		    		
		    		metadataDlgCtrl.getDocumentMetadataFunction=function(){	
			    		sbiModule_restServices.promiseGet('1.0/documentexecution/' + executionInstance.OBJECT_ID, 'documentMetadata', params)
			    		.then(function(response){
			    			metadataDlgCtrl.generalMetadata = response.data.GENERAL_META;
			    			metadataDlgCtrl.shortText = response.data.SHORT_TEXT;
				    		metadataDlgCtrl.longText = response.data.LONG_TEXT;
				    		metadataDlgCtrl.file = response.data.FILE;
				    		console.log("RECEIVED FILES: ",metadataDlgCtrl.file)
				    		for(var i=0;i<metadataDlgCtrl.file.length;i++) 
				    		{
				    			if(metadataDlgCtrl.file[i].fileToSave==undefined || metadataDlgCtrl.file[i].fileToSave==null||metadataDlgCtrl.file[i].fileToSave=='')
				    			{	
				    				metadataDlgCtrl.file[i].fileToSave={};	// fileToUpload instead of uploadedFile
				    			}
				    			//When there are saved files make its fileNames, saveDates and fileLabel visible for user
				    			if(metadataDlgCtrl.file[i].savedFile!=undefined && metadataDlgCtrl.file[i].savedFile!=null && metadataDlgCtrl.file[i].savedFile!='')
				    			{	
					    			var fileItem=JSON.parse(metadataDlgCtrl.file[i].savedFile);
					    			metadataDlgCtrl.file[i].fileName=fileItem.fileName;
					    			metadataDlgCtrl.file[i].saveDate=fileItem.saveDate;
					    			metadataDlgCtrl.file[i].fileLabel=fileItem.fileLabel;
				    			} else{	metadataDlgCtrl.file[i].fileLabel=""; }
				    		}
				    		
				    		if(metadataDlgCtrl.shortText.length>0)
				    		{
				    			for(var j=0;j<metadataDlgCtrl.shortText.length;j++)
				    			{
				    				if(metadataDlgCtrl.shortText[j].value!="" && metadataDlgCtrl.shortText[j].value!=null && metadataDlgCtrl.shortText[j].value!=undefined)
				    				{
				    		    		metadataDlgCtrl.shortExpanderOpened = true;
				    				}	
				    			}	
				    		}
				    		if(metadataDlgCtrl.longText.length>0)
				    		{
				    			for(var j=0;j<metadataDlgCtrl.longText.length;j++)
				    			{
				    				if(metadataDlgCtrl.longText[j].value!="" && metadataDlgCtrl.longText[j].value!=null && metadataDlgCtrl.longText[j].value!=undefined)
				    				{
				    		    		metadataDlgCtrl.longExpanderOpened = true;
				    				}	
				    			}
				    		}	
				    		if(metadataDlgCtrl.file.length>0)
				    		{	
				    			for(var j=0;j<metadataDlgCtrl.file.length;j++)
				    			{
				    				if(metadataDlgCtrl.file[j].value!="" && metadataDlgCtrl.file[j].value!=null && metadataDlgCtrl.file[j].value!=undefined)
				    				{
				    		    		metadataDlgCtrl.fileExpanderOpened = true;
				    				}	
				    			}
				    			
				    		}	
				    		
			    		},function(response){
			    			documentExecuteServices.showToast(response.data.errors[0].message, 5000);
			    		});
		    		};	
		    		
		    		metadataDlgCtrl.getDocumentMetadataFunction(); 
		    		
		    		metadataDlgCtrl.close = function(){
		    			$mdDialog.hide();
		    		}
		    		metadataDlgCtrl.save = function(){
		    			if(metadataDlgCtrl.shortText==null || metadataDlgCtrl.shortText==undefined || metadataDlgCtrl.shortText=='')
		    			{ 
		    				metadataDlgCtrl.shortText=[];
		    			}	
		    			if(metadataDlgCtrl.longText==null || metadataDlgCtrl.longText==undefined || metadataDlgCtrl.longText=='')
		    			{ 
		    				metadataDlgCtrl.longText=[];
		    			}	
		    			var saveObj = {
		    				id: executionInstance.OBJECT_ID,
		    				subobjectId: executionInstance.SUBOBJECT_ID, 
		    				jsonMeta: metadataDlgCtrl.shortText.concat(metadataDlgCtrl.longText).concat(metadataDlgCtrl.file) //added last concat
		    			};
		    			sbiModule_restServices.promisePost('1.0/documentexecution', 'saveDocumentMetadata', saveObj)
		    			.then(function(response){
		    				//documentExecuteServices.showToast(sbiModule_translate.load("sbi.execution.viewpoints.msg.saved"), 3000);
		    				documentExecuteServices.showToast("Salvataggio OK", 3);
		    				metadataDlgCtrl.getDocumentMetadataFunction(); 
		    				
		    				
		    			},function(response){
		    				documentExecuteServices.showToast(response.data.errors[0].message, 5);
		    			});
		    		}
		    		
		    		metadataDlgCtrl.cleanFile= function(metadataId){
		    			//remove file from temp directory (if present) and from db
		    			
		    			objId=executionInstance.OBJECT_ID;
		    			var subobjId="null";
			    		if(executionInstance.SUBOBJECT_ID){
			    			subobjId=executionInstance.SUBOBJECT_ID;
			    		}

			    				    		
			    		sbiModule_restServices.promiseGet('1.0/documentexecution/'+objId+"/"+metadataId, 'deletefilemetadata').then(function(response){
		    				//documentExecuteServices.showToast(sbiModule_translate.load("sbi.execution.viewpoints.msg.saved"), 3000);
		    				documentExecuteServices.showToast("Rimozione effettuata", 3);
		    				metadataDlgCtrl.getDocumentMetadataFunction(); 
		    					
		    			},function(response){
		    				documentExecuteServices.showToast(response.data.errors[0].message, 5);
		    			});
			    		
			    		
		    		}
		    		
		    		metadataDlgCtrl.download = function(metadataId,savedFile){
		    			if(savedFile!="" && savedFile!=null && savedFile!=undefined)
		    			{	
			    			objId=executionInstance.OBJECT_ID;
			    			var subobjId="null";
				    		if(executionInstance.SUBOBJECT_ID){
				    			subobjId=executionInstance.SUBOBJECT_ID;
				    		}
	
				    				    		
				    		sbiModule_download.getLink('/restful-services/1.0/documentexecution/'+objId+"/"+metadataId+"/"+"documentfilemetadata"); 	
		    			}
		    			else
		    			{
		    				documentExecuteServices.showToast("No saved file to download!", 3);  
							console.log("[DOWNLOAD]: NO FILE TO DOWNLOAD!");
		    			}	
		    		}
		    		
		    		
		    		
		    		
		    		
		    		
		    		
		    	}
		    })
	        .then(function(answer) {
	        	
	        }, function() {
	        	
	        });
		}}
	});
})();



angular.module('documentExecutionModule').service('multipartForm',['$http',function($http){
	
	this.post = function(uploadUrl,data){
		
		var formData = new FormData();
		
		formData.append("file",data.file);

		return	$http.post(uploadUrl,formData,{
				transformRequest:angular.identity,
				headers:{'Content-Type': undefined}
			})
	}
	
}]);