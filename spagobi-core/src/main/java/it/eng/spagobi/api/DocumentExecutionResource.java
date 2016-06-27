/*
 * Knowage, Open Source Business Intelligence suite
 * Copyright (C) 2016 Engineering Ingegneria Informatica S.p.A.
 *
 * Knowage is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Knowage is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package it.eng.spagobi.api;

import static it.eng.spagobi.commons.constants.SpagoBIConstants.DATE_RANGE_OPTIONS_KEY;
import static it.eng.spagobi.commons.constants.SpagoBIConstants.DATE_RANGE_QUANTITY_JSON;
import static it.eng.spagobi.commons.constants.SpagoBIConstants.DATE_RANGE_TYPE_JSON;
import it.eng.spago.base.RequestContainer;
import it.eng.spago.base.RequestContainerAccess;
import it.eng.spago.base.SessionContainer;
import it.eng.spago.error.EMFInternalError;
import it.eng.spago.error.EMFUserError;
import it.eng.spagobi.analiticalmodel.document.AnalyticalModelDocumentManagementAPI;
import it.eng.spagobi.analiticalmodel.document.DocumentExecutionUtils;
import it.eng.spagobi.analiticalmodel.document.bo.BIObject;
import it.eng.spagobi.analiticalmodel.document.bo.SubObject;
import it.eng.spagobi.analiticalmodel.document.dao.IBIObjectDAO;
import it.eng.spagobi.analiticalmodel.document.handlers.DocumentParameters;
import it.eng.spagobi.analiticalmodel.document.handlers.DocumentParameters.DataDependency;
import it.eng.spagobi.analiticalmodel.document.handlers.DocumentUrlManager;
import it.eng.spagobi.analiticalmodel.execution.bo.defaultvalues.DefaultValue;
import it.eng.spagobi.analiticalmodel.execution.bo.defaultvalues.DefaultValuesList;
import it.eng.spagobi.behaviouralmodel.analyticaldriver.bo.BIObjectParameter;
import it.eng.spagobi.behaviouralmodel.analyticaldriver.bo.ObjParuse;
import it.eng.spagobi.behaviouralmodel.analyticaldriver.bo.ObjParview;
import it.eng.spagobi.behaviouralmodel.analyticaldriver.bo.ParameterUse;
import it.eng.spagobi.behaviouralmodel.analyticaldriver.dao.IParameterUseDAO;
import it.eng.spagobi.commons.SingletonConfig;
import it.eng.spagobi.commons.bo.UserProfile;
import it.eng.spagobi.commons.dao.DAOFactory;
import it.eng.spagobi.commons.serializer.SerializationException;
import it.eng.spagobi.commons.utilities.DateRangeDAOUtilities;
import it.eng.spagobi.commons.utilities.GeneralUtilities;
import it.eng.spagobi.commons.utilities.indexing.LuceneIndexer;
import it.eng.spagobi.commons.utilities.messages.IMessageBuilder;
import it.eng.spagobi.commons.utilities.messages.MessageBuilder;
import it.eng.spagobi.commons.utilities.messages.MessageBuilderFactory;
import it.eng.spagobi.services.rest.annotations.ManageAuthorization;
import it.eng.spagobi.services.serialization.JsonConverter;
import it.eng.spagobi.tools.objmetadata.bo.ObjMetacontent;
import it.eng.spagobi.tools.objmetadata.bo.ObjMetadata;
import it.eng.spagobi.tools.objmetadata.dao.IObjMetacontentDAO;
import it.eng.spagobi.utilities.assertion.Assert;
import it.eng.spagobi.utilities.engines.AbstractEngineStartAction;
import it.eng.spagobi.utilities.exceptions.SpagoBIRuntimeException;
import it.eng.spagobi.utilities.exceptions.SpagoBIServiceException;
import it.eng.spagobi.utilities.rest.RestUtilities;

import java.io.IOException;
import java.text.Format;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import org.apache.log4j.Logger;
import org.apache.poi.hssf.record.formula.functions.T;
import org.apache.soap.providers.com.Log;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.safehaus.uuid.UUID;
import org.safehaus.uuid.UUIDGenerator;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.JsonMappingException;


@Path("/1.0/documentexecution")
public class DocumentExecutionResource extends AbstractSpagoBIResource {

	// GENERAL METADATA NAMES
	public static final String LABEL = "metadata.docLabel";
	public static final String NAME = "metadata.docName";
	public static final String DESCR = "metadata.docDescr";
	public static final String TYPE = "metadata.docType";
	public static final String ENG_NAME = "metadata.docEngine";
	public static final String RATING = "metadata.docRating";
	public static final String SUBOBJ_NAME = "metadata.subobjName";
	public static final String METADATA = "METADATA";
	public static final String NODE_ID_SEPARATOR = "___SEPA__";

	public static String MODE_SIMPLE = "simple";
	// public static String MODE_COMPLETE = "complete";
	// public static String START = "start";
	// public static String LIMIT = "limit";

	public static final String SERVICE_NAME = "DOCUMENT_EXECUTION_RESOURCE";
	private static final String DESCRIPTION_FIELD = "description";

	private static final String VALUE_FIELD = "value";

	private static final String LABEL_FIELD = "label";

	private static IMessageBuilder message = MessageBuilderFactory.getMessageBuilder();

	private static final String[] VISIBLE_COLUMNS = new String[] { VALUE_FIELD, LABEL_FIELD, DESCRIPTION_FIELD };

	private class DocumentExecutionException extends Exception {
		private static final long serialVersionUID = -1882998632783944575L;

		DocumentExecutionException(String message) {
			super(message);
		}
	}

	static protected Logger logger = Logger.getLogger(DocumentExecutionResource.class);
	protected AnalyticalModelDocumentManagementAPI documentManager = new AnalyticalModelDocumentManagementAPI(getUserProfile());

	/**
	 * @return { executionURL: 'http:...', errors: 1 - 'role missing' 2 -'Missing paramters' [list of missing mandatory filters ] 3 -'operation not allowed' [if
	 *         the request role is not owned by the requesting user] }
	 * @throws JSONException
	 * @throws IOException
	 * @throws EMFInternalError
	 */
	@POST
	@Path("/url")
	@Produces(MediaType.APPLICATION_JSON + "; charset=UTF-8")
	public Response getDocumentExecutionURL(@Context HttpServletRequest req) throws IOException, JSONException {

		logger.debug("IN");
		JSONObject requestVal = RestUtilities.readBodyAsJSONObject(req);
		String label = requestVal.getString("label");
		String role = requestVal.getString("role");
		String modality = requestVal.optString("modality");
		String displayToolbar = requestVal.optString("displayToolbar");
		String snapshotId = requestVal.optString("snapshotId");
		String subObjectID = requestVal.optString("subObjectID");

		String olapParam = "";

		String sbiExecutionId = requestVal.optString("SBI_EXECUTION_ID");
		JSONObject jsonParameters = requestVal.optJSONObject("parameters");
		JSONObject menuParameters = requestVal.optJSONObject("menuParameters"); // parameters setted when open document from menu

		RequestContainer aRequestContainer = RequestContainerAccess.getRequestContainer(req);
		SessionContainer aSessionContainer = aRequestContainer.getSessionContainer();
		SessionContainer permanentSession = aSessionContainer.getPermanentContainer();

		JSONObject jsonResp = new JSONObject();
		List errorList = new ArrayList<>();
		Locale locale = GeneralUtilities.getCurrentLocale(aRequestContainer);
		JSONObject err = new JSONObject();
		JSONArray arrerr = new JSONArray();
		if (sbiExecutionId == null || sbiExecutionId.isEmpty()) {
			// CREATE EXECUTION ID
			UUIDGenerator uuidGen = UUIDGenerator.getInstance();
			UUID uuidObj = uuidGen.generateTimeBasedUUID();
			sbiExecutionId = uuidObj.toString();
			sbiExecutionId = sbiExecutionId.replaceAll("-", "");
		}
		jsonResp.put("sbiExecutionId", sbiExecutionId);
		try {
			String executingRole = getExecutionRole(role);
			// displayToolbar
			// modality
			BIObject obj = DAOFactory.getBIObjectDAO().loadBIObjectForExecutionByLabelAndRole(label, executingRole);
			IParameterUseDAO parameterUseDAO = DAOFactory.getParameterUseDAO();
			// BUILD THE PARAMETERS
			JSONObject jsonParametersToSend = buildJsonParameters(jsonParameters, req, role, permanentSession, parameterUseDAO, obj);
			// BUILD URL
			String url = DocumentExecutionUtils.handleNormalExecutionUrl(this.getUserProfileSession(), obj, req, this.getAttributeAsString("SBI_ENVIRONMENT"),
					executingRole, modality, jsonParametersToSend, locale);
			errorList = DocumentExecutionUtils.handleNormalExecutionError(this.getUserProfileSession(), obj, req, this.getAttributeAsString("SBI_ENVIRONMENT"),
					executingRole, modality, jsonParametersToSend, locale);

			if (obj.getBiObjectTypeCode().equals("OLAP"))
				olapParam = BuildOlapUrlString(requestVal);

			jsonResp.put("url", url + "&SBI_EXECUTION_ID=" + sbiExecutionId + olapParam);
			if (errorList != null && !errorList.isEmpty()) {
				jsonResp.put("errors", errorList);
			}
			// ADD TYPE CODE
			// TODO return EXPORT FORMAT MAP
			jsonResp.put("typeCode", obj.getBiObjectTypeCode());
			jsonResp.put("engineLabel", obj.getEngine().getLabel());
		} catch (DocumentExecutionException e) {
			err.put("message", e.getMessage());
			err.put("type", "missingRole");
			arrerr.put(err);
			JSONObject toRet = new JSONObject();
			toRet.put("errors", arrerr);
			return Response.ok(toRet.toString()).build();
		} catch (Exception e) {
			logger.error("Error while getting the document execution url", e);
			err.put("message", e.getMessage());
			arrerr.put(err);
			JSONObject toRet = new JSONObject();
			toRet.put("errors", arrerr);
			return Response.ok(toRet.toString()).build();
		}
		logger.debug("OUT");
		return Response.ok(jsonResp.toString()).build();
	}

	public String BuildOlapUrlString(JSONObject reqVal) throws JSONException {
		String ret = "";
		if (reqVal.getJSONObject("parameters").length() > 0) {
			String subViewObjectID = reqVal.getJSONObject("parameters").getString("subobj_id");
			String subViewObjectName = reqVal.getJSONObject("parameters").getString("subobj_name");
			String subViewObjectDescription = reqVal.getJSONObject("parameters").getString("subobj_description");
			String subViewObjectVisibility = reqVal.getJSONObject("parameters").getString("subobj_visibility");

			ret = ret + "&"+AbstractEngineStartAction.SUBOBJ_ID+"=" + subViewObjectID +  "&"+AbstractEngineStartAction.SUBOBJ_NAME+"=" + subViewObjectName;

			if (!subViewObjectDescription.isEmpty())
				ret = ret + "&"+AbstractEngineStartAction.SUBOBJ_DESCRIPTION+"=" + subViewObjectDescription;

			ret = ret + "&"+AbstractEngineStartAction.SUBOBJ_VISIBILITY+"=" + subViewObjectVisibility;
		}

		return ret;
	}

	private JSONObject buildJsonParameters(JSONObject jsonParameters, HttpServletRequest req, String role, SessionContainer permanentSession,
			IParameterUseDAO parameterUseDAO, BIObject obj) throws JSONException, EMFUserError {

		List<DocumentParameters> parameters = DocumentExecutionUtils.getParameters(obj, role, req.getLocale(), null,req);
		for (DocumentParameters objParameter : parameters) {
			// SETTING DEFAULT VALUE IF NO PRESENT IN JSON SUBMIT PARAMETER
			if (jsonParameters.isNull(objParameter.getId())) {
				if (objParameter.getDefaultValues() != null && objParameter.getDefaultValues().size() > 0) {
					if (objParameter.getDefaultValues().size() == 1) {
						// SINGLE
						Object value;
						// DEFAULT DATE FIELD : {date#format}

						if (objParameter.getParType().equals("DATE") && objParameter.getDefaultValues().get(0).getValue().toString().contains("#")) {
							// CONVERT DATE FORMAT FROM DEFAULT TO SERVER
							value = convertDate(objParameter.getDefaultValues().get(0).getValue().toString().split("#")[1],
							// GeneralUtilities.getLocaleDateFormat(permanentSession),
									SingletonConfig.getInstance().getConfigValue("SPAGOBI.DATE-FORMAT-SERVER.format"), objParameter.getDefaultValues().get(0)
											.getValue().toString().split("#")[0]);
						}

						// DEFAULT DATE RANGE FIELD : {date_2W#format}
						else if (objParameter.getParType().equals("DATE_RANGE") && objParameter.getDefaultValues().get(0).getValue().toString().contains("#")) {
							String dateRange = objParameter.getDefaultValues().get(0).getValue().toString().split("#")[0];
							String[] dateRangeArr = dateRange.split("_");
							String range = "_" + dateRangeArr[dateRangeArr.length - 1];
							dateRange = dateRange.replace(range, "");
							// CONVERT DATE FORMAT FROM DEFAULT TO Server
							value = convertDate(objParameter.getDefaultValues().get(0).getValue().toString().split("#")[1],
							// GeneralUtilities.getLocaleDateFormat(permanentSession)
									SingletonConfig.getInstance().getConfigValue("SPAGOBI.DATE-FORMAT-SERVER.format"), dateRange);
							value = value + range;
						} else {
							value = objParameter.getDefaultValues().get(0).getValue();
						}
						jsonParameters.put(objParameter.getId(), value);
						jsonParameters.put(objParameter.getId() + "_field_visible_description", value);
					} else {
						// MULTIPLE
						ArrayList<String> paramValArr = new ArrayList<String>();
						String paramDescStr = "";
						for (int i = 0; i < objParameter.getDefaultValues().size(); i++) {
							paramValArr.add(objParameter.getDefaultValues().get(i).getValue().toString());
							paramDescStr = paramDescStr + objParameter.getDefaultValues().get(i).getValue().toString();
							if (i < objParameter.getDefaultValues().size() - 1) {
								paramDescStr = paramDescStr + ";";
							}
						}
						jsonParameters.put(objParameter.getId(), paramValArr);
						jsonParameters.put(objParameter.getId() + "_field_visible_description", paramDescStr);
					}
				}

			}
			// SUBMIT LOV SINGLE MANDATORY PARAMETER
			if (objParameter.isMandatory()) {
				Integer paruseId = objParameter.getParameterUseId();
				ParameterUse parameterUse = parameterUseDAO.loadByUseID(paruseId);
				if ("lov".equalsIgnoreCase(parameterUse.getValueSelection())
						&& !objParameter.getSelectionType().equalsIgnoreCase(DocumentExecutionUtils.SELECTION_TYPE_TREE)
						&& (objParameter.getLovDependencies() == null || objParameter.getLovDependencies().size() == 0)) {
					HashMap<String, Object> defaultValuesData = DocumentExecutionUtils.getLovDefaultValues(role, obj,
							objParameter.getAnalyticalDocumentParameter(), req);

					ArrayList<HashMap<String, Object>> defaultValues = (ArrayList<HashMap<String, Object>>) defaultValuesData
							.get(DocumentExecutionUtils.DEFAULT_VALUES);

					if (defaultValues != null && defaultValues.size() == 1 && !defaultValues.get(0).containsKey("error")) {
						jsonParameters.put(objParameter.getId(), defaultValues.get(0).get("value"));
						jsonParameters.put(objParameter.getId() + "_field_visible_description", defaultValues.get(0).get("value"));
					}
				}
			}

			// CROSS NAV : INPUT PARAM PARAMETER TARGET DOC IS STRING
			if (!jsonParameters.isNull(objParameter.getId())) {
				Integer paruseId = objParameter.getParameterUseId();
				ParameterUse parameterUse = parameterUseDAO.loadByUseID(paruseId);
				if (jsonParameters.getString(objParameter.getId()).startsWith("[") && jsonParameters.getString(objParameter.getId()).endsWith("]")
						&& parameterUse.getValueSelection().equals("man_in")) {
					int strLength = jsonParameters.getString(objParameter.getId()).toString().length();
					String jsonParamRet = jsonParameters.getString(objParameter.getId()).toString().substring(1, strLength - 1);
					if (objParameter.isMultivalue()) {
						jsonParamRet.replaceAll("\"", "'");
					}
					jsonParameters.put(objParameter.getId(), jsonParamRet);
				}

			}

		}

		return jsonParameters;
	}

	/**
	 * @return { filterStatus: [{ title: 'Provincia', urlName: 'provincia', type: 'list', lista:[[k,v],[k,v], [k,v]] }, { title: 'Comune', urlName: 'comune',
	 *         type: 'list', lista:[], dependsOn: 'provincia' }, { title: 'Free Search', type: 'manual', urlName: 'freesearch' }],
	 *
	 *         errors: [ 'role missing', 'operation not allowed' ] }
	 * @throws EMFUserError
	 * @throws JSONException
	 * @throws IOException
	 */
	@POST
	@Path("/filters")
	@Produces(MediaType.APPLICATION_JSON + "; charset=UTF-8")
	public Response getDocumentExecutionFilters(@Context HttpServletRequest req) throws DocumentExecutionException, EMFUserError, IOException, JSONException {

		logger.debug("IN");

		RequestContainer aRequestContainer = RequestContainerAccess.getRequestContainer(req);
		SessionContainer aSessionContainer = aRequestContainer.getSessionContainer();
		SessionContainer permanentSession = aSessionContainer.getPermanentContainer();
		JSONObject requestVal = RestUtilities.readBodyAsJSONObject(req);
		String label = requestVal.getString("label");
		String role = requestVal.getString("role");
		JSONObject jsonParameters = requestVal.getJSONObject("parameters");

		JSONObject resultAsMap = new JSONObject();

		IBIObjectDAO dao = DAOFactory.getBIObjectDAO();
		IParameterUseDAO parameterUseDAO = DAOFactory.getParameterUseDAO();
		BIObject biObject = dao.loadBIObjectForExecutionByLabelAndRole(label, role);

		Locale locale = GeneralUtilities.getCurrentLocale(aRequestContainer);
		DocumentUrlManager documentUrlManager = new DocumentUrlManager(this.getUserProfile(), locale);

		ArrayList<HashMap<String, Object>> parametersArrayList = new ArrayList<>();

		List<DocumentParameters> parameters = DocumentExecutionUtils.getParameters(biObject, role, req.getLocale(), null, req);
		for (DocumentParameters objParameter : parameters) {
			Integer paruseId = objParameter.getParameterUseId();
			ParameterUse parameterUse = parameterUseDAO.loadByUseID(paruseId);

			HashMap<String, Object> parameterAsMap = new HashMap<String, Object>();
			parameterAsMap.put("id", objParameter.getBiObjectId());
			parameterAsMap.put("label", objParameter.getLabel());
			parameterAsMap.put("urlName", objParameter.getId());
			parameterAsMap.put("type", objParameter.getParType());
			parameterAsMap.put("typeCode", objParameter.getTypeCode());
			parameterAsMap.put("selectionType", objParameter.getSelectionType());
			parameterAsMap.put("valueSelection", parameterUse.getValueSelection());
			parameterAsMap.put("selectedLayer", objParameter.getSelectedLayer());
			parameterAsMap.put("selectedLayerProp", objParameter.getSelectedLayerProp());
			parameterAsMap.put("visible", ((objParameter.isVisible())));
			parameterAsMap.put("mandatory", ((objParameter.isMandatory())));
			parameterAsMap.put("multivalue", objParameter.isMultivalue());

			parameterAsMap.put("allowInternalNodeSelection",
					objParameter.getPar().getModalityValue().getLovProvider().contains("<LOVTYPE>treeinner</LOVTYPE>"));

			if (jsonParameters.has(objParameter.getId())) {
				documentUrlManager.refreshParameterForFilters(objParameter.getAnalyticalDocumentParameter(), jsonParameters);
				parameterAsMap.put("parameterValue", objParameter.getAnalyticalDocumentParameter().getParameterValues());
			}

			boolean showParameterLov = true;

			// Parameters NO TREE
			if ("lov".equalsIgnoreCase(parameterUse.getValueSelection())
					&& !objParameter.getSelectionType().equalsIgnoreCase(DocumentExecutionUtils.SELECTION_TYPE_TREE)
					&& (objParameter.getLovDependencies() == null || objParameter.getLovDependencies().size() == 0)) {

				HashMap<String, Object> defaultValuesData = DocumentExecutionUtils.getLovDefaultValues(role, biObject,
						objParameter.getAnalyticalDocumentParameter(), req);

				ArrayList<HashMap<String, Object>> defaultValues = (ArrayList<HashMap<String, Object>>) defaultValuesData
						.get(DocumentExecutionUtils.DEFAULT_VALUES);

				List defaultValuesMetadata = (List) defaultValuesData.get(DocumentExecutionUtils.DEFAULT_VALUES_METADATA);

				if (!objParameter.getSelectionType().equalsIgnoreCase(DocumentExecutionUtils.SELECTION_TYPE_LOOKUP)) {
					parameterAsMap.put("defaultValues", defaultValues);
				} else {
					parameterAsMap.put("defaultValues", new ArrayList<>());
				}
				parameterAsMap.put("defaultValuesMeta", defaultValuesMetadata);
				parameterAsMap.put(DocumentExecutionUtils.VALUE_COLUMN_NAME_METADATA, defaultValuesData.get(DocumentExecutionUtils.VALUE_COLUMN_NAME_METADATA));
				parameterAsMap.put(DocumentExecutionUtils.DESCRIPTION_COLUMN_NAME_METADATA,
						defaultValuesData.get(DocumentExecutionUtils.DESCRIPTION_COLUMN_NAME_METADATA));

				// hide the parameter if is mandatory and have one value in lov (no error parameter)
				if (defaultValues != null && defaultValues.size() == 1 && objParameter.isMandatory() && !defaultValues.get(0).containsKey("error")) {
					showParameterLov = false;
				}
				// if parameterValue is not null and is array, check if all element are present in lov
				Object o = parameterAsMap.get("parameterValue");
				if (o != null) {
					if (o instanceof List) {
						List<String> valList = (ArrayList) o;
						for (int k = 0; k < valList.size(); k++) {
							String itemVal = valList.get(k);
							boolean found = false;
							for (HashMap<String, Object> parHashVal : defaultValues) {
								if (parHashVal.containsKey("value") && parHashVal.get("value").equals(itemVal)) {
									found = true;
									break;
								}
							}
							if (!found) {
								valList.remove(k);
								k--;
							}
						}
					}
				}
			}

			// DATE RANGE DEFAULT VALUE
			if (objParameter.getParType().equals("DATE_RANGE")) {
				try {
					ArrayList<HashMap<String, Object>> defaultValues = manageDataRange(biObject, role, objParameter.getId());
					parameterAsMap.put("defaultValues", defaultValues);
				} catch (SerializationException e) {
					logger.debug("Filters DATE RANGE ERRORS ", e);
				}

			}

			// convert the parameterValue from array of string in array of object
			DefaultValuesList parameterValueList = new DefaultValuesList();
			Object o = parameterAsMap.get("parameterValue");
			if (o != null) {
				if (o instanceof List) {
					// CROSS NAV : INPUT PARAM PARAMETER TARGET DOC IS STRING
					if (o.toString().startsWith("[") && o.toString().endsWith("]") && parameterUse.getValueSelection().equals("man_in")) {
						List<String> valList = (ArrayList) o;
						String stringResult = "";
						for (int k = 0; k < valList.size(); k++) {
							String itemVal = valList.get(k);
							if (objParameter.getParType().equals("STRING") && objParameter.isMultivalue()) {
								stringResult += "'" + itemVal + "'";
							} else {
								stringResult += itemVal;
							}
							if (k != valList.size() - 1) {
								stringResult += ",";
							}
						}
						DefaultValue defValue = new DefaultValue();
						defValue.setValue(stringResult);
						defValue.setDescription(stringResult);
						parameterValueList.add(defValue);
					} else {
						List<String> valList = (ArrayList) o;
						for (int k = 0; k < valList.size(); k++) {
							String itemVal = valList.get(k);
							DefaultValue defValue = new DefaultValue();
							defValue.setValue(itemVal);
							defValue.setDescription(itemVal);
							parameterValueList.add(defValue);

						}
					}
					parameterAsMap.put("parameterValue", converetParameterValueObjTOJsonArr(parameterValueList,DefaultValue.class));
				}
			}

			parameterAsMap.put("dependsOn", objParameter.getDependencies());	
			parameterAsMap.put("dataDependencies", converetDataObjTOJsonArr(objParameter.getDataDependencies(),  ObjParuse.class));		
			parameterAsMap.put("visualDependencies", converetVisualObjTOJsonArr(objParameter.getVisualDependencies(),  ObjParview.class));
			parameterAsMap.put("lovDependencies", (objParameter.getLovDependencies() != null) ? objParameter.getLovDependencies() : new ArrayList<>());

			// load DEFAULT VALUE if present and if the parameter value is empty
			if (objParameter.getDefaultValues() != null && objParameter.getDefaultValues().size() > 0) {
				DefaultValuesList valueList = null;
				if (jsonParameters.isNull(objParameter.getId())) {
					valueList = buildDefaultValueList(objParameter, permanentSession);
					if (valueList != null) {
						parameterAsMap.put("parameterValue", converetParameterValueObjTOJsonArr(valueList,DefaultValue.class));
					}
				}
			}

			if (showParameterLov) {
				parametersArrayList.add(parameterAsMap);
			}
		}
		if (parameters.size() > 0) {
			resultAsMap.put("filterStatus", parametersArrayList);
		} else {
			resultAsMap.put("filterStatus", new ArrayList<>());
		}

		logger.debug("OUT");
		return Response.ok(resultAsMap.toString()).build();
	}

	
	private JSONArray converetParameterValueObjTOJsonArr(DefaultValuesList valueList, Class<DefaultValue> o){
		JSONArray jsonArr = new JSONArray();
		for(int i=0; i<valueList.size();i++){
			DefaultValue op = (DefaultValue) valueList.get(i);
			try {
				jsonArr.put(new JSONObject(JsonConverter.objectToJson( op, o)));
			} catch (JSONException e) {
				logger.error(e.getMessage());
			}
		}
		return jsonArr;
	}
	
	private JSONArray converetVisualObjTOJsonArr(List<Object> list, Class<ObjParview> o){
		JSONArray jsonArr = new JSONArray();
		for(int i=0; i<list.size();i++){
			ObjParview op = (ObjParview) list.get(i);
			try {
				jsonArr.put(new JSONObject(JsonConverter.objectToJson( op, o)));
			} catch (JSONException e) {
				logger.error(e.getMessage());
			}
		}
		return jsonArr;
	}
	
	private JSONArray converetDepOnObjTOJsonArr(List<Object> list, Class<DataDependency> o){
		JSONArray jsonArr = new JSONArray();
		for(int i=0; i<list.size();i++){
			DataDependency op = (DataDependency) list.get(i);
			try {
				jsonArr.put(new JSONObject(JsonConverter.objectToJson( op, o)));
			} catch (JSONException e) {
				logger.error(e.getMessage());
			}
		}
		return jsonArr;
	}
	
	
	private JSONArray converetDataObjTOJsonArr(List<Object> list, Class<ObjParuse> o){
		JSONArray jsonArr = new JSONArray();
		for(int i=0; i<list.size();i++){
			ObjParuse op = (ObjParuse) list.get(i);
			try {
				jsonArr.put(new JSONObject(JsonConverter.objectToJson( op, o)));
			} catch (JSONException e) {
				logger.error(e.getMessage());
			}
		}
		return jsonArr;
	}
	
	
	private ArrayList<HashMap<String, Object>> manageDataRange(BIObject biObject, String executionRole, String biparameterId) throws EMFUserError,
			SerializationException, JSONException, IOException {

		BIObjectParameter biObjectParameter = null;
		List parameters = biObject.getBiObjectParameters();
		for (int i = 0; i < parameters.size(); i++) {
			BIObjectParameter p = (BIObjectParameter) parameters.get(i);
			if (biparameterId.equalsIgnoreCase(p.getParameterUrlName())) {
				biObjectParameter = p;
				break;
			}
		}

		try {
			if (DateRangeDAOUtilities.isDateRange(biObjectParameter)) {
				logger.debug("loading date range combobox");

			}
		} catch (Exception e) {
			throw new SpagoBIServiceException(SERVICE_NAME, "Error on loading date range combobox values", e);
		}

		Integer parID = biObjectParameter.getParID();
		Assert.assertNotNull(parID, "parID");
		ParameterUse param = DAOFactory.getParameterUseDAO().loadByParameterIdandRole(parID, executionRole);
		String options = param.getOptions();
		Assert.assertNotNull(options, "options");

		ArrayList<HashMap<String, Object>> dateRangeValuesDataJSON = getDateRangeValuesDataJSON(options);

		// TODO
		// int dataRangeOptionsSize = getDataRangeOptionsSize(options);
		// JSONObject valuesJSON = (JSONObject) JSONStoreFeedTransformer.getInstance().transform(dateRangeValuesDataJSON, VALUE_FIELD.toUpperCase(),
		// LABEL_FIELD.toUpperCase(), DESCRIPTION_FIELD.toUpperCase(), VISIBLE_COLUMNS, dataRangeOptionsSize);

		return dateRangeValuesDataJSON;

	}

	// private static int getDataRangeOptionsSize(String options) throws JSONException {
	// JSONObject json = new JSONObject(options);
	// JSONArray res = json.getJSONArray(DATE_RANGE_OPTIONS_KEY);
	// return res.length();
	// }

	private ArrayList<HashMap<String, Object>> getDateRangeValuesDataJSON(String optionsJson) throws JSONException {
		JSONObject json = new JSONObject(optionsJson);
		JSONArray options = json.getJSONArray(DATE_RANGE_OPTIONS_KEY);
		JSONArray res = new JSONArray();

		ArrayList<HashMap<String, Object>> defaultValues = new ArrayList<>();

		for (int i = 0; i < options.length(); i++) {
			// JSONObject opt = new JSONObject();
			JSONObject optJson = (JSONObject) options.get(i);
			String type = (String) optJson.get(DATE_RANGE_TYPE_JSON);
			// String typeDesc = getLocalizedMessage("SBIDev.paramUse." + type);
			String quantity = (String) optJson.get(DATE_RANGE_QUANTITY_JSON);
			String value = type + "_" + quantity;
			String label = quantity + " " + type;
			// message properties !!!
			HashMap<String, Object> obj = new HashMap<String, Object>();
			obj.put(VALUE_FIELD, value);
			obj.put(LABEL_FIELD, label);
			obj.put(DESCRIPTION_FIELD, label);
			obj.put(DATE_RANGE_TYPE_JSON, type);
			obj.put(DATE_RANGE_QUANTITY_JSON, quantity);
			defaultValues.add(obj);

		}
		return defaultValues;
	}

	@POST
	@Path("/parametervalues")
	@Produces(MediaType.APPLICATION_JSON + "; charset=UTF-8")
	// public Response getParameterValues(@QueryParam("label") String label, @QueryParam("role") String role, @QueryParam("biparameterId") String biparameterId,
	// @QueryParam("mode") String mode, @QueryParam("treeLovNode") String treeLovNode,
	// // @QueryParam("treeLovNode") Integer treeLovNodeLevel,
	// @Context HttpServletRequest req) throws EMFUserError {
	public Response getParameterValues(@Context HttpServletRequest req) throws EMFUserError, IOException, JSONException {

		RequestContainer aRequestContainer = RequestContainerAccess.getRequestContainer(req);
		Locale locale = GeneralUtilities.getCurrentLocale(aRequestContainer);

		String role;
		String label;
		String biparameterId;
		String treeLovNode;
		String mode;
		// GET PARAMETER

		JSONObject requestVal = RestUtilities.readBodyAsJSONObject(req);
		role = (String) requestVal.opt("role");
		label = (String) requestVal.opt("label");
		biparameterId = (String) requestVal.opt("biparameterId");
		treeLovNode = (String) requestVal.opt("treeLovNode");
		mode = (String) requestVal.opt("mode");

		IBIObjectDAO dao = DAOFactory.getBIObjectDAO();
		BIObject biObject = dao.loadBIObjectForExecutionByLabelAndRole(label, role);

		BIObjectParameter biObjectParameter = null;
		List<BIObjectParameter> parameters = biObject.getBiObjectParameters();
		for (int i = 0; i < parameters.size(); i++) {
			BIObjectParameter p = parameters.get(i);
			if (biparameterId.equalsIgnoreCase(p.getParameterUrlName())) {
				biObjectParameter = p;
				break;
			}
		}

		String treeLovNodeValue;
		Integer treeLovNodeLevel;

		if (treeLovNode.contains("lovroot")) {
			treeLovNodeValue = "lovroot";
			treeLovNodeLevel = 0;
		} else {
			String[] splittedNode = treeLovNode.split(NODE_ID_SEPARATOR);
			treeLovNodeValue = splittedNode[0];
			treeLovNodeLevel = new Integer(splittedNode[1]);
		}

		// ArrayList<HashMap<String, Object>> result = DocumentExecutionUtils.getLovDefaultValues(
		// role, biObject, biObjectParameter, requestVal, treeLovNodeLevel, treeLovNodeValue, req);
		HashMap<String, Object> defaultValuesData = DocumentExecutionUtils.getLovDefaultValues(role, biObject, biObjectParameter, requestVal, treeLovNodeLevel,
				treeLovNodeValue, req);

		ArrayList<HashMap<String, Object>> result = (ArrayList<HashMap<String, Object>>) defaultValuesData.get(DocumentExecutionUtils.DEFAULT_VALUES);

		//HashMap<String, Object> resultAsMap = new HashMap<String, Object>();
		JSONObject resultAsMap = new JSONObject();
		
		if (result != null && result.size() > 0) {
			resultAsMap.put("filterValues", result);
			resultAsMap.put("errors", new ArrayList<>());
		} else {
			resultAsMap.put("filterValues", new ArrayList<>());

			List errorList = DocumentExecutionUtils.handleNormalExecutionError(this.getUserProfile(), biObject, req,
					this.getAttributeAsString("SBI_ENVIRONMENT"), role, biObjectParameter.getParameter().getModalityValue().getSelectionType(), null, locale);

			resultAsMap.put("errors", errorList);
		}

		logger.debug("OUT");
		return Response.ok(resultAsMap.toString()).build();
	}

	/**
	 * @return the list of values when input parameter (urlName) is correlated to another
	 */
	@GET
	@Path("/filterlist")
	@Produces(MediaType.APPLICATION_JSON + "; charset=UTF-8")
	public Response getDocumentExecutionFilterList(@QueryParam("label") String label, @QueryParam("role") String role,
			@QueryParam("parameters") String jsonParameters, @QueryParam("urlName") String urlName, @Context HttpServletRequest req) {
		logger.debug("IN");

		String toBeReturned = "{}";

		try {
			role = getExecutionRole(role);

		} catch (DocumentExecutionException e) {
			return Response.ok("{errors: '" + e.getMessage() + "', }").build();
		} catch (Exception e) {
			logger.error("Error while getting the document execution filterlist", e);
			throw new SpagoBIRuntimeException("Error while getting the document execution filterlist", e);
		}

		logger.debug("OUT");
		return Response.ok(toBeReturned).build();
	}

	/**
	 * Produces a json of document metadata grouped by typeCode ("GENERAL_META", "LONG_TEXT", "SHORT_TEXT")
	 *
	 * @param id
	 *            of document
	 * @param id
	 *            of subObject
	 * @param httpRequest
	 * @return a response with a json
	 * @throws EMFUserError
	 */
	@GET
	@Path("/{id}/documentMetadata")
	public Response documentMetadata(@PathParam("id") Integer objectId, @QueryParam("subobjectId") Integer subObjectId, @Context HttpServletRequest httpRequest)
			throws EMFUserError {

		try {
			RequestContainer aRequestContainer = RequestContainerAccess.getRequestContainer(httpRequest);
			Locale locale = GeneralUtilities.getCurrentLocale(aRequestContainer);

			Map<String, JSONArray> documentMetadataMap = new HashMap<>();

			JSONArray generalMetadata = new JSONArray();
			documentMetadataMap.put("GENERAL_META", generalMetadata);

			MessageBuilder msgBuild = new MessageBuilder();

			// START GENERAL METADATA
			if (subObjectId != null) {
				// SubObj Name
				String textSubName = msgBuild.getMessage(SUBOBJ_NAME, locale);
				SubObject subobj = DAOFactory.getSubObjectDAO().getSubObject(subObjectId);
				addMetadata(generalMetadata, textSubName, subobj.getName());
			}

			BIObject obj = DAOFactory.getBIObjectDAO().loadBIObjectById(objectId);

			// Obj Label
			String textLabel = msgBuild.getMessage(LABEL, locale);
			addMetadata(generalMetadata, textLabel, obj.getLabel());

			// Obj Name
			String textName = msgBuild.getMessage(NAME, locale);
			addMetadata(generalMetadata, textName, obj.getName());

			// Obj Type
			String textType = msgBuild.getMessage(TYPE, locale);
			addMetadata(generalMetadata, textType, obj.getBiObjectTypeCode());

			// Obj Description
			String description = msgBuild.getMessage(DESCR, locale);
			addMetadata(generalMetadata, description, obj.getDescription());

			// Obj Engine Name
			String textEngName = msgBuild.getMessage(ENG_NAME, locale);
			addMetadata(generalMetadata, textEngName, obj.getEngine().getName());

			// END GENERAL METADATA

			List metadata = DAOFactory.getObjMetadataDAO().loadAllObjMetadata();
			if (metadata != null && !metadata.isEmpty()) {
				Iterator it = metadata.iterator();
				while (it.hasNext()) {
					ObjMetadata objMetadata = (ObjMetadata) it.next();
					ObjMetacontent objMetacontent = DAOFactory.getObjMetacontentDAO().loadObjMetacontent(objMetadata.getObjMetaId(), objectId, subObjectId);
					addTextMetadata(documentMetadataMap, objMetadata.getDataTypeCode(), objMetadata.getName(),
							objMetacontent != null && objMetacontent.getContent() != null ? new String(objMetacontent.getContent()) : "",
							objMetadata.getObjMetaId());
				}
			}

			if (!documentMetadataMap.isEmpty()) {
				return Response.ok(new JSONObject(documentMetadataMap).toString()).build();
			}
		} catch (Exception e) {
			logger.error(httpRequest.getPathInfo(), e);
		}

		return Response.ok().build();
	}

	@POST
	@Path("/saveDocumentMetadata")
	public Response saveDocumentMetadata(@Context HttpServletRequest httpRequest) throws JSONException {
		try {
			JSONObject params = RestUtilities.readBodyAsJSONObject(httpRequest);
			IObjMetacontentDAO dao = DAOFactory.getObjMetacontentDAO();
			dao.setUserProfile(getUserProfile());
			Integer biobjectId = params.getInt("id");
			Integer subobjectId = params.has("subobjectId") ? params.getInt("subobjectId") : null;
			String jsonMeta = params.getString("jsonMeta");

			logger.debug("Object id = " + biobjectId);
			logger.debug("Subobject id = " + subobjectId);

			JSONArray metadata = new JSONArray(jsonMeta);
			for (int i = 0; i < metadata.length(); i++) {
				JSONObject aMetadata = metadata.getJSONObject(i);
				Integer metadataId = aMetadata.getInt("id");
				String text = aMetadata.getString("value");
				ObjMetacontent aObjMetacontent = dao.loadObjMetacontent(metadataId, biobjectId, subobjectId);
				if (aObjMetacontent == null) {
					logger.debug("ObjMetacontent for metadata id = " + metadataId + ", biobject id = " + biobjectId + ", subobject id = " + subobjectId
							+ " was not found, creating a new one...");
					aObjMetacontent = new ObjMetacontent();
					aObjMetacontent.setObjmetaId(metadataId);
					aObjMetacontent.setBiobjId(biobjectId);
					aObjMetacontent.setSubobjId(subobjectId);
					aObjMetacontent.setContent(text.getBytes("UTF-8"));
					aObjMetacontent.setCreationDate(new Date());
					aObjMetacontent.setLastChangeDate(new Date());
					dao.insertObjMetacontent(aObjMetacontent);
				} else {
					logger.debug("ObjMetacontent for metadata id = " + metadataId + ", biobject id = " + biobjectId + ", subobject id = " + subobjectId
							+ " was found, it will be modified...");
					aObjMetacontent.setContent(text.getBytes("UTF-8"));
					aObjMetacontent.setLastChangeDate(new Date());
					dao.modifyObjMetacontent(aObjMetacontent);
				}

			}
			/*
			 * indexes biobject by modifying document in index
			 */
			BIObject biObjToIndex = DAOFactory.getBIObjectDAO().loadBIObjectById(biobjectId);
			LuceneIndexer.updateBiobjInIndex(biObjToIndex, false);

		} catch (Exception e) {
			logger.error(request.getPathInfo(), e);
			return Response.ok(new JSONObject("{\"errors\":[{\"message\":\"Exception occurred while saving metadata\"}]}").toString()).build();
		}
		return Response.ok().build();
	}

	private void addMetadata(JSONArray generalMetadata, String name, String value) throws JsonMappingException, JsonParseException, JSONException, IOException {
		addMetadata(generalMetadata, name, value, null);
	}

	private void addMetadata(JSONArray generalMetadata, String name, String value, Integer id)
			throws JsonMappingException, JsonParseException, JSONException, IOException {
		JSONObject data = new JSONObject();
		if (id != null) {
			data.put("id", id);
		}
		data.put("name", name);
		data.put("value", value);
		generalMetadata.put(data);
	}

	private void addTextMetadata(Map<String, JSONArray> metadataMap, String type, String name, String value, Integer id)
			throws JSONException, JsonMappingException, JsonParseException, IOException {
		JSONArray jsonArray = metadataMap.get(type);
		if (jsonArray == null) {
			jsonArray = new JSONArray();
		}
		addMetadata(jsonArray, name, value, id);
		metadataMap.put(type, jsonArray);
	}

	protected String getExecutionRole(String role) throws EMFInternalError, DocumentExecutionException {
		UserProfile userProfile = getUserProfile();
		if (role != null && !role.equals("")) {
			logger.debug("role for document execution: " + role);
		} else {
			if (userProfile.getRoles().size() == 1) {
				role = userProfile.getRoles().iterator().next().toString();
				logger.debug("profile role for document execution: " + role);
			} else {
				logger.debug("missing role for document execution, role:" + role);
				throw new DocumentExecutionException(message.getMessage("SBIDev.docConf.execBIObject.selRoles.Title"));
			}
		}

		return role;
	}

	private DefaultValuesList buildDefaultValueList(DocumentParameters objParameter, SessionContainer permanentSession) {
		SimpleDateFormat serverDateFormat = new SimpleDateFormat(SingletonConfig.getInstance().getConfigValue("SPAGOBI.DATE-FORMAT-SERVER.format"));

		if (objParameter.getParType() != null && objParameter.getParType().equals("DATE")) {
			String valueDate = objParameter.getDefaultValues().get(0).getValue().toString();
			String[] date = valueDate.split("#");
			SimpleDateFormat format = new SimpleDateFormat(date[1]);
			DefaultValuesList valueList = new DefaultValuesList();
			DefaultValue valueDef = new DefaultValue();
			try {
				Date d = format.parse(date[0]);
				String dateServerFormat = serverDateFormat.format(d);
				valueDef.setValue(dateServerFormat);
				valueDef.setDescription(objParameter.getDefaultValues().get(0).getDescription());
				valueList.add(valueDef);
				return valueList;
			} catch (ParseException e) {
				logger.error("Error while building defalt Value List Date Type ", e);
				return null;
			}
		} else if (objParameter.getParType() != null && objParameter.getParType().equals("DATE_RANGE")) {
			String valueDate = objParameter.getDefaultValues().get(0).getValue().toString();
			String[] date = valueDate.split("#");
			SimpleDateFormat format = new SimpleDateFormat(date[1]);
			DefaultValuesList valueList = new DefaultValuesList();
			DefaultValue valueDef = new DefaultValue();
			try {

				String dateRange = date[0];
				String[] dateRangeArr = dateRange.split("_");
				String range = dateRangeArr[dateRangeArr.length - 1];
				dateRange = dateRange.replace("_" + range, "");
				Date d = format.parse(dateRange);
				String dateServerFormat = serverDateFormat.format(d);
				valueDef.setValue(dateServerFormat + "_" + range);
				valueDef.setDescription(objParameter.getDefaultValues().get(0).getDescription());
				valueList.add(valueDef);
				return valueList;
			} catch (ParseException e) {
				logger.error("Error while building defalt Value List Date Type ", e);
				return null;
			}
		}

		else {
			return objParameter.getDefaultValues();
		}

	}

	private String convertDate(String dateFrom, String dateTo, String dateStr) {
		String date = dateStr;
		SimpleDateFormat dateFromFormat = new SimpleDateFormat(dateFrom);
		try {
			Date d = dateFromFormat.parse(dateStr);
			Format formatter = new SimpleDateFormat(dateTo);
			date = formatter.format(d);
			// jsonParameters.put(objParameter.getId(), date);
		} catch (ParseException e) {
			logger.error("Error prase date server ", e);

		}
		return date;
	}

}
