<!---
example code using the bitly.cfc component
--->

<cfscript>
	// define the user variables
	strUser 	= '<your bit.ly account name>';
	strKey		= '<your bit.ly api key>';

	// instantiate the object
	objBitly = createObject('component', 
		'com.coldfumonkeh.bitly.bitly')
		.init(
			username	=	strUser,
			apikey		=	strKey,
			parse		=	true
		);

	// let's shorten a URL
	shorten = objBitly.shorten(longURL='http://www.google.com',format='xml',domain='j.mp');
	
	// let's expand a URL using a bit.ly short URL
	expand1 = objBitly.expand(shortURL='http://bit.ly/1RmnUT',format='json');	
	// or by using a hash
	expand2 = objBitly.expand(hash='2bYgqR');
	
	// validate the user and apiKey pair
	validate = objBitly.validate(x_login=strUser,x_apikey=strKey,format='json');

	// get info on a shortURL
	info = objBitly.info(shortURL='http://bit.ly/1RmnUT');
	
	// clicks on the same URL
	clicks = objBitly.clicks(shortURL='http://bit.ly/1RmnUT,http://tcrn.ch/a4MSUH',format='json');
	
	// bit.ly professional domain check
	proDomain = objBitly.proDomain(domain='nyti.ms', format='xml');

	// url lookup
	lookup	  = objBitly.lookup(url='http://code.google.com/p/bitly-api/,http://betaworks.com/', format='xml');
	
	// info
	info = objBitly.info(shortURL='http://tcrn.ch/a4MSUH,http://bit.ly/1YKMfY',hash='j3',format='json');
	
	qrCode = objBitly.generateQRCode(shortURL='http://bit.ly/d6sCNC');
</cfscript>

<cfdump var="#shorten#" 	label="shorten URL response" />

<cfdump var="#expand1#" 	label="expand short URL response" />

<cfdump var="#expand2#" 	label="expand hash response" />

<cfdump var="#validate#" 	label="validate response" />

<cfdump var="#info#" 		label="info short URL response" />

<cfdump var="#clicks#" 		label="clicks short URL response" />

<cfdump var="#proDomain#" 	label="proDomain response" />

<cfdump var="#lookup#" 		label="lookup URL response" />

<cfdump var="#qrCode#" 		label="QRCode binary response" />

<cfimage action="writeToBrowser" source="#qrCode#" />