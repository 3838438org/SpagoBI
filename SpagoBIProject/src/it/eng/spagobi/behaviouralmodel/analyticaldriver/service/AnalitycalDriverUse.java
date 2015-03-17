package it.eng.spagobi.behaviouralmodel.analyticaldriver.service;

import it.eng.spago.error.EMFUserError;
import it.eng.spagobi.behaviouralmodel.analyticaldriver.bo.ParameterUse;
import it.eng.spagobi.behaviouralmodel.analyticaldriver.dao.IParameterUseDAO;
import it.eng.spagobi.behaviouralmodel.check.bo.Check;
import it.eng.spagobi.commons.bo.Role;
import it.eng.spagobi.commons.dao.DAOFactory;
import it.eng.spagobi.commons.serializer.SerializerFactory;
import it.eng.spagobi.utilities.assertion.Assert;
import it.eng.spagobi.utilities.exceptions.SpagoBIServiceException;
import it.eng.spagobi.utilities.rest.RestUtilities;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import org.apache.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONObject;

@Path("/analyticalDriverUse")
public class AnalitycalDriverUse {

	static private Logger logger = Logger.getLogger(AnalitycalDriverUse.class);

	@GET
	@Produces(MediaType.APPLICATION_JSON)
	public String get() {

		logger.debug("IN");

		IParameterUseDAO parametersUseDAO = null;
		List<ParameterUse> parametersUse;
		JSONObject parametersUseJSON = new JSONObject();

		try {
			parametersUseDAO = DAOFactory.getParameterUseDAO();
			parametersUse = parametersUseDAO.loadParametersUseByParId(1);

			parametersUseJSON = serializeParametersUse(parametersUse);

			logger.debug("OUT: Returned analitical driver uses");

		} catch (Exception e) {

			logger.debug("OUT: Exception in returning analitical driver uses");
			throw new SpagoBIServiceException("analyticalDriverUse", "There is the problem with get", e);
		}

		return parametersUseJSON.toString();

	}

	@DELETE
	@Produces(MediaType.APPLICATION_JSON)
	public Response delete(@Context HttpServletRequest req) {

		logger.debug("IN");

		ParameterUse parameterUse = null;

		try {
			JSONObject requestBodyJSON = RestUtilities.readBodyAsJSONObject(req);
			String id = (String) requestBodyJSON.opt("USEID");
			int intId = Integer.parseInt(id);
			parameterUse = DAOFactory.getParameterUseDAO().loadByUseID(intId);

			DAOFactory.getParameterUseDAO().eraseParameterUse(parameterUse);
			logger.debug("OUT: Deleted analitical driver use");

			return Response.ok().build();

		} catch (Exception e) {

			logger.debug("OUT: Exception in deleting analitical driver use");
			throw new SpagoBIServiceException("analyticalDriverUse", "There is the problem with delete", e);

		}

	}

	@POST
	@Produces(MediaType.APPLICATION_JSON)
	public Response put(@Context HttpServletRequest req) {

		logger.debug("IN");

		try {
			JSONObject reqJsonObject = RestUtilities.readBodyAsJSONObject(req);
			IParameterUseDAO parameterUseDAO = DAOFactory.getParameterUseDAO();

			ParameterUse parameterUse = recoverParameterUseDetails(reqJsonObject);

			parameterUseDAO.insertParameterUse(parameterUse);

			logger.debug("OUT: Posted analitical driver use");

			return Response.ok().build();
		} catch (Exception e) {

			logger.debug("OUT: Exception in posting analitical driver use");
			throw new SpagoBIServiceException("analyticalDriverUse", "There is the problem with post", e);

		}

	}

	@PUT
	@Produces(MediaType.APPLICATION_JSON)
	public Response post(@Context HttpServletRequest req) {

		logger.debug("IN");

		try {
			JSONObject requestBodyJSON = RestUtilities.readBodyAsJSONObject(req);
			IParameterUseDAO parameterUseDAO = DAOFactory.getParameterUseDAO();

			ParameterUse parameterUse = recoverParameterUseDetails(requestBodyJSON);

			parameterUseDAO.modifyParameterUse(parameterUse);

			logger.debug("OUT: Put analitical driver use");

			return Response.ok().build();
		} catch (Exception e) {

			logger.debug("OUT: Exception in putting analitical driver use");
			throw new SpagoBIServiceException("analyticalDriverUse", "There is the problem with put", e);

		}

	}

	private JSONObject serializeParametersUse(List<ParameterUse> parametersUse) {

		logger.debug("IN");

		JSONObject parametersUseJSON = new JSONObject();
		JSONArray parametersUseJSONArray = new JSONArray();

		Assert.assertNotNull(parametersUse, "Parameter use list cannot be null");

		try {
			parametersUseJSONArray = (JSONArray) SerializerFactory.getSerializer("application/json").serialize(parametersUse, null);
			parametersUseJSON.put("ADUSE", parametersUseJSONArray);

			logger.debug("OUT: Serialized analitical driver use");

		} catch (Exception e) {

			logger.debug("OUT: Exception in serializing analitical driver use");
			throw new SpagoBIServiceException("analyticalDriverUse", "There is a serialize problem", e);

		}

		return parametersUseJSON;
	}

	private ParameterUse recoverParameterUseDetails(JSONObject requestBodyJSON) throws EMFUserError {

		logger.debug("IN");

		ParameterUse parameterUse = new ParameterUse();
		Integer id = -1;
		String idStr = (String) requestBodyJSON.opt("USEID");
		if (idStr != null && !idStr.equals("")) {

			id = new Integer(idStr);

		}

		String idd = (String) requestBodyJSON.opt("ID");
		String lovid = (String) requestBodyJSON.opt("LOVID");
		String deflovid = (String) requestBodyJSON.opt("DEFAULTLOVID");
		String label = (String) requestBodyJSON.opt("LABEL");
		String name = (String) requestBodyJSON.opt("NAME");
		String desc = (String) requestBodyJSON.opt("DESCRIPTION");
		String manualInput = (String) requestBodyJSON.opt("MANUALINPUT");
		String selectionType = (String) requestBodyJSON.opt("SELECTIONTYPE");

		Assert.assertNotNull(id, "Id cannot be null");
		Assert.assertNotNull(idd, "Idd cannot be null");
		Assert.assertNotNull(lovid, "Lov Id cannot be null");
		Assert.assertNotNull(label, "Label cannot be null");
		Assert.assertNotNull(name, "Name cannot be null");
		Assert.assertNotNull(desc, "Description cannot be null");
		Assert.assertNotNull(manualInput, "Manual input cannot be null");
		Assert.assertNotNull(selectionType, "Selection type cannot be null");

		parameterUse.setId(new Integer(idd));
		parameterUse.setUseID(id);
		parameterUse.setIdLov(new Integer(lovid));
		parameterUse.setIdLovForDefault(6);
		parameterUse.setLabel(label);
		parameterUse.setName(name);
		parameterUse.setDescription(desc);
		parameterUse.setManualInput(new Integer(manualInput));
		parameterUse.setSelectionType(selectionType);

		List<Role> roles = new ArrayList();
		roles.add(DAOFactory.getRoleDAO().loadByID(5));

		List<Check> checks = new ArrayList();
		checks.add(DAOFactory.getChecksDAO().loadCheckByID(4));

		parameterUse.setAssociatedRoles(roles);
		parameterUse.setAssociatedChecks(checks);

		logger.debug("OUT: Recovered analitical driver use");

		return parameterUse;
	}
}
