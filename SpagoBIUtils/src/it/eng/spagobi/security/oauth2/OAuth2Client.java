/* SpagoBI, the Open Source Business Intelligence suite

 * Copyright (C) 2012 Engineering Ingegneria Informatica S.p.A. - SpagoBI Competency Center
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0, without the "Incompatible With Secondary Licenses" notice.
 * If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package it.eng.spagobi.security.oauth2;

import it.eng.spagobi.utilities.exceptions.SpagoBIRuntimeException;

import java.io.IOException;
import java.util.Properties;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpException;
import org.apache.commons.httpclient.HttpState;
import org.apache.commons.httpclient.HttpStatus;
import org.apache.commons.httpclient.UsernamePasswordCredentials;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.log4j.LogMF;
import org.apache.log4j.Logger;
import org.json.JSONException;
import org.json.JSONObject;

import sun.misc.BASE64Encoder;

public class OAuth2Client {
	private static Logger logger = Logger.getLogger(OAuth2Client.class);
	private static Properties config;

	public OAuth2Client() {
		config = OAuth2Config.getInstance().getConfig();
	}

	public String getToken(String email, String password) {
		logger.debug("IN");
		try {
			HttpClient client = getHttpClient();
			PostMethod httppost = new PostMethod(config.getProperty("TOKENS_URL"));
			httppost.addParameter("email", email);
			httppost.addParameter("password", password);
			int statusCode = client.executeMethod(httppost);
			byte[] response = httppost.getResponseBody();
			if (statusCode != HttpStatus.SC_OK) {
				logger.error("Error while getting access token from OAuth2 provider: server returned statusCode = " + statusCode);
				LogMF.error(logger, "Server response is:\n{0}", new Object[] { new String(response) });
				throw new SpagoBIRuntimeException("Error while getting access token from OAuth2 provider: server returned statusCode = " + statusCode);
			}
			logger.debug("statusCode=" + statusCode);
			String responseStr = new String(response);
			logger.debug("response=" + responseStr);
			JSONObject jsonObject = new JSONObject(responseStr);
			String token = jsonObject.getString("token");
			return token;
		} catch (Exception e) {
			throw new SpagoBIRuntimeException("Error while trying to get token from OAuth2 provider", e);
		} finally {
			logger.debug("OUT");
		}
	}

	public String getAdminToken() {
		String adminEmail = config.getProperty("ADMIN_EMAIL");
		String adminPassword = config.getProperty("ADMIN_PASSWORD");

		return getToken(adminEmail, adminPassword);
	}

	public HttpClient getHttpClient() {

		String proxyUrl = System.getProperty("http.proxyHost");
		String proxyPort = System.getProperty("http.proxyPort");
		String proxyUser = System.getProperty("http.proxyUsername");
		String proxyPassword = System.getProperty("http.proxyPassword");

		HttpClient client = new HttpClient();
		if (proxyUrl != null && proxyPort != null) {
			logger.debug("Setting proxy configuration ...");
			client.getHostConfiguration().setProxy(proxyUrl, Integer.parseInt(proxyPort));
			if (proxyUser != null) {
				logger.debug("Setting proxy authentication configuration ...");
				HttpState state = new HttpState();
				state.setProxyCredentials(null, null, new UsernamePasswordCredentials(proxyUser, proxyPassword));
				client.setState(state);
			}
		} else {
			logger.debug("No proxy configuration found");
		}

		return client;
	}

	public String getAccessToken(String code) {
		logger.debug("IN");
		try {
			PostMethod httppost = createPostMethod();
			httppost.setParameter("grant_type", "authorization_code");
			httppost.setParameter("code", code);
			httppost.setParameter("redirect_uri", config.getProperty("REDIRECT_URI"));

			return sendHttpPost(httppost);
		} catch (Exception e) {
			throw new SpagoBIRuntimeException("Error while trying to get access token from OAuth2 provider", e);
		} finally {
			logger.debug("OUT");
		}
	}

	public String getAccessToken(String username, String password) {
		logger.debug("IN");
		try {
			PostMethod httppost = createPostMethod();
			httppost.setParameter("grant_type", "password");
			httppost.setParameter("username", username);
			httppost.setParameter("password", password);
			httppost.setParameter("client_id", config.getProperty("CLIENT_ID"));

			return sendHttpPost(httppost);
		} catch (Exception e) {
			throw new SpagoBIRuntimeException("Error while trying to get access token from OAuth2 provider", e);
		} finally {
			logger.debug("OUT");
		}
	}

	// The generated PostMethod object is used to retrieve access token
	private PostMethod createPostMethod() {
		String authorizationCredentials = config.getProperty("CLIENT_ID") + ":" + config.getProperty("SECRET");
		String encoded = new String(new BASE64Encoder().encode(authorizationCredentials.getBytes()));
		encoded = encoded.replaceAll("\n", "");

		HttpClient httpClient = getHttpClient();
		PostMethod httppost = new PostMethod(config.getProperty("GET_ACCESS_TOKEN_URL"));
		httppost.setRequestHeader("Authorization", "Basic " + encoded);
		httppost.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

		return httppost;
	}

	// It sends the http request specified in PostMethod and returns the access token returned by server
	private String sendHttpPost(PostMethod httppost) throws HttpException, IOException, JSONException {
		HttpClient httpClient = getHttpClient();
		int statusCode = httpClient.executeMethod(httppost);
		byte[] response = httppost.getResponseBody();
		if (statusCode != 200) {
			logger.error("Error while getting access token from OAuth2 provider: server returned statusCode = " + statusCode);
			LogMF.error(logger, "Server response is:\n{0}", new Object[] { new String(response) });
			throw new SpagoBIRuntimeException("Error while getting access token from OAuth2 provider: server returned statusCode = " + statusCode);
		}

		String responseStr = new String(response);
		LogMF.debug(logger, "Server response is:\n{0}", responseStr);
		JSONObject jsonObject = new JSONObject(responseStr);
		String accessToken = jsonObject.getString("access_token");

		return accessToken;
	}
}