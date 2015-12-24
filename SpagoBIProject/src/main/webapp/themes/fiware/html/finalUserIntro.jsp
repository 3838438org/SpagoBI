<%@ page language="java"
         extends="it.eng.spago.dispatching.httpchannel.AbstractHttpJspPagePortlet"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         session="true" 
         import="it.eng.spago.base.*,
                 it.eng.spagobi.commons.constants.SpagoBIConstants"
%>
<%@page import="it.eng.spagobi.commons.utilities.ChannelUtilities"%>
<%@page import="it.eng.spagobi.commons.utilities.messages.IMessageBuilder"%>
<%@page import="it.eng.spagobi.commons.utilities.messages.MessageBuilderFactory"%>
<%@page import="it.eng.spagobi.commons.utilities.urls.UrlBuilderFactory"%>
<%@page import="it.eng.spagobi.commons.utilities.urls.IUrlBuilder"%>
<%@page import="it.eng.spago.base.SourceBean"%>
<%@page import="it.eng.spago.navigation.LightNavigationManager"%>
<%@page import="it.eng.spagobi.utilities.themes.ThemesManager"%>
<%@page import="it.eng.spagobi.commons.constants.ObjectsTreeConstants"%>
<%@page import="org.apache.commons.lang.StringEscapeUtils"%>
<%@page import="java.util.Enumeration"%>

<html>
<head>
	<link rel="stylesheet" href="${pageContext.request.contextPath}/js/lib/bootstrap/css/bootstrap.min.css">

<style>


html,
body {
    height: 100%;
}

body {
	background-image: url('../img/pixels.png');
	background-repeat: repeat;
	 height: 100%;
}

.carousel,
.item,
.active {
    height: 100%;
}

.carousel-inner {
    height: 100%;
}

/* Background images are set within the HTML using inline CSS, not here */

.fill {
    width: 100%;
    height: 100%;
	filter: alpha(opacity=50); /* internet explorer */
	-khtml-opacity: 0.5;      /* khtml, old safari */
	-moz-opacity: 0.5;       /* mozilla, netscape */
	opacity: 0.5;           /* fx, safari, opera */
    background-position: center;
    -webkit-background-size: cover;
    -moz-background-size: cover;
    background-size: cover;
    -o-background-size: cover;
}

footer {
    margin: 50px 0;
}


.layer
{
			height:100%;
			width:100%;
			position:fixed;
			left:0;
			top:0;
			z-index:1 !important;
			/*background-image: url('../img/backgroundlogo.png');*/
			background-size: cover;
			filter: alpha(opacity=50); /* internet explorer */
			-khtml-opacity: 0.5;      /* khtml, old safari */
			-moz-opacity: 0.5;       /* mozilla, netscape */
			opacity: 0.5;           /* fx, safari, opera */
}

.layer img  {
    position: absolute;
    top: 0px;
    right: 0px;
    margin: 10px;
    width: 35%;  
    filter: alpha(opacity=50); /* internet explorer */
	-khtml-opacity: 0.5;      /* khtml, old safari */
	-moz-opacity: 0.5;       /* mozilla, netscape */
	opacity: 0.5;           /* fx, safari, opera */
}

</style>  
</head>
<body>
  

	<div class="layer">
		<img src="../img/userLogo.png" class="logo"/>

	</div>

<header id="myCarousel" class="carousel slide">
        <!-- Indicators -->
        <ol class="carousel-indicators">
            <li data-target="#myCarousel" data-slide-to="0" class="active"></li>
            <li data-target="#myCarousel" data-slide-to="1" class=""></li>
            <li data-target="#myCarousel" data-slide-to="2" class=""></li>
        </ol>

        <!-- Wrapper for Slides -->
        <div class="carousel-inner">
            <div class="item active">
                <!-- Set the first background image using inline CSS below. -->
                <div class="fill" style="background-image:url('../img/introImage1.jpg');"></div>
                <div class="carousel-caption">
                    <h1>Your data at a glance</h1>
                    Define queries on your data instantly, with a few clicks and simple drag&drop actions.
                </div>
            </div>
            <div class="item">
                <!-- Set the second background image using inline CSS below. -->
                <div class="fill" style="background-image:url('../img/introImage2.jpg');"></div>
                <div class="carousel-caption">
                    <h1>Smart data</h1>
                    Turn your data into knowledge, for effective decision making!
                </div>
            </div>
            <div class="item ">
                <!-- Set the third background image using inline CSS below. -->
                <div class="fill" style="background-image:url('../img/introImage3.jpg');"></div>
                <div class="carousel-caption">
                    <h2>Easy Data analysis</h2>
                    No need to be an expert to use the BI Tools.
                </div>
            </div>
        </div>

        <!-- Controls -->
        
        

    </header>
 <script src="${pageContext.request.contextPath}/js/lib/jquery-1.11.3/jquery-1.11.3.min.js"></script>
 <script src="${pageContext.request.contextPath}/js/lib/bootstrap/bootstrap.min.js"></script>
</body>
</html>