Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=2 smtp.remote-ip=67.231.157.221
ARC-Seal: i=3; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1792863495;
	b=eMT37vsqAFttHA5J7QR0aH3Is5h/8H5/M6L2vBH4RgM2OD99hvvla6rOSahpHe+bUyS/
	 /opo9/8feiasU6wShgPU7vOrcfj3RocNP/4+IASY6WkuQG5u/iEkCh4iHNmfeerzznuI5
	 KkmjuIPTAUJydxxdaJDVVvyidE8P4rD7pepr2TJMKXPsOXDLnbxaZaIoQVGt3e86DOb5r
	 yV/cj2N1SDBU5I3fMna1EVzFrgQqtnCErQsncEVqN4ltw+Ayd+qXf9nXHZL/jYRXpFaOp
	 CpGH+0qef0lsm6xCzGgqkpxVYalGcDPabexsp52YRJFLMNltSjeQ3AKp2VxdwY7OvIQ==
ARC-Message-Signature: i=3; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792863495;
	h=DMARC-Filter:Received:DKIM-Signature:Received:DKIM-Signature:
	 Received:Received:X-MS-Exchange-Authentication-Results:Received-SPF:
	 Received:Received:DKIM-Signature:Received:Received:From:To:CC:Subject:
	 Thread-Topic:Thread-Index:Date:Message-ID:References:In-Reply-To:
	 Accept-Language:Content-Language:X-MS-Has-Attach:X-MS-TNEF-Correlator:
	 msip_labels:Authentication-Results-Original:
	 x-ms-traffictypediagnostic:X-MS-Office365-Filtering-Correlation-Id:
	 X-MS-Exchange-SenderADCheck:X-MS-Exchange-AntiSpam-Relay:
	 X-Microsoft-Antispam-Untrusted:
	 X-Microsoft-Antispam-Message-Info-Original:
	 X-Forefront-Antispam-Report-Untrusted:Content-Type:
	 Content-Transfer-Encoding:MIME-Version:
	 X-Exchange-RoutingPolicyChecked:
	 X-MS-Exchange-Transport-CrossTenantHeadersStamped:X-Zscaler-Block:
	 X-EOPAttributedMessage:
	 X-MS-Exchange-Transport-CrossTenantHeadersStripped:
	 X-MS-PublicTrafficType:X-MS-Office365-Filtering-Correlation-Id-Prvs:
	 X-Microsoft-Antispam:X-Microsoft-Antispam-Message-Info:
	 X-Forefront-Antispam-Report:
	 X-MS-Exchange-AntiSpam-MessageData-ChunkCount:
	 X-MS-Exchange-AntiSpam-MessageData-0:X-Exchange-RoutingPolicyChecked:
	 X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount:
	 X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0:X-OriginatorOrg:
	 X-MS-Exchange-CrossTenant-OriginalArrivalTime:
	 X-MS-Exchange-CrossTenant-Network-Message-Id:
	 X-MS-Exchange-CrossTenant-Id:
	 X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp:
	 X-MS-Exchange-CrossTenant-AuthSource:X-MS-Exchange-CrossTenant-AuthAs:
	 X-MS-Exchange-CrossTenant-FromEntityHeader:
	 X-MS-Exchange-Transport-CrossTenantHeadersStamped:
	 X-Proofpoint-Spam-Details-Enc:X-Proofpoint-GUID:X-Authority-Analysis:
	 X-Proofpoint-ORIG-GUID:X-Proofpoint-Spam-Info:
	 X-Proofpoint-Virus-Version:X-Proofpoint-Spam-Details;
	bh=gUYAQyf5E3sqnzgd9Qvljw4xMqM740N2TuUTZfQPEWQ=;
	b=hNehjoJZkOglK+q+KMVZJNAXLaYSenzQEI/dIQHH/3kbW4qBrZfYt5lQo4CXJMYPKvJE
	 /a7rwgSMszCi1thfmmcb5P0JQz3jRDUvqmekwq8RjtS06L54ROYDY4JGaKifWNa+jhsJ4
	 kYT6bcatepgy5fBmoFMB5cmnnzooxWAYBZ2v9CbY5EVnXzJM4duuOVvyA6OisOCKCJCqn
	 xDoCa+dWFUlSEbp98CvhBdhimTeAsnswuhVC/HNwQmWs+csTYUgEik3DqvQBlEDkXRN4z
	 eaxN59o6mu82sB57oLbRN0zB8LSd2ughp/VzOF4fp/ow1VKAiXcQRGvHMaumzRBJJTw==
ARC-Authentication-Results: i=3; smtp.subspace.kernel.org; 
	dmarc=pass header.from=netapp.com;
	spf=pass smtp.mailfrom=netapp.com;
	dkim=pass header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=pps1 header.b=UAMLeuGE;
	dkim=pass header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=selector1 header.b=oOchz8Qq;
	dkim=pass header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=selector1 header.b=oOchz8Qq;
	arc=pass header.oldest-pass=2 smtp.remote-ip=67.231.157.221
Received: from mx0b-003fbd02.pphosted.com (mx0b-003fbd02.pphosted.com [67.231.157.221])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0C5AD606A31A
	for <linux-nfs@vger.kernel.org>; Sat, 24 Oct 2026 17:38:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0C5AD606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=netapp.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netapp.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=pps1 header.b=UAMLeuGE;
	dkim=pass (2048-bit key, unprotected) header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=selector1 header.b=oOchz8Qq;
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=selector1 header.b=oOchz8Qq
Received: from pps.filterd (m0412383.ppops.net [127.0.0.1])
	by mx0b-003fbd02.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 69OEwmOS058244;
	Sat, 24 Oct 2026 17:37:57 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=pps1; bh=gUYAQ
	yf5E3sqnzgd9Qvljw4xMqM740N2TuUTZfQPEWQ=; b=UAMLeuGEhuTIQa7Axbbyu
	ZEKAJqXG3SCrR0QjsY1u28EfDnpwj/jtG3Ad4lIy+a0eMeMmK1dF5VkydV/aBZFw
	6C9mRoQWx8hpW0sRaHeSQildi8yxACfbajB2KnNQ/fG+qPF+YP5Yq1sXMFqFgmlW
	u9y3QDIPvTW9pnhQ8uf30x+rqox2oJKv7GFq1+hlgrVwoiVTT1DNe5FU01gkyfxF
	xNR+IgMNloNENS5WcDTOOb9sU5u+HCpeZGNlJ9OlDngbzE6DKhZ50KH+UEFvidKP
	QOn6zwbLazGwaznDmA55iMN6jo1+5NBuHjEjhGjYahFZCyXBRr4UwLINW5s97B/d
	A==
Received: from sn4pr2101cu001.outbound.protection.outlook.com (mail-southcentralusazon11012004.outbound.protection.outlook.com [40.93.195.4])
	by mx0b-003fbd02.pphosted.com (PPS) with ESMTPS id 4hgud8gy17-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Sat, 24 Oct 2026 17:37:57 +0000 (GMT)
ARC-Seal: i=2; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=pass;
 b=a7xdvVYF/9D5Ly0mj9pD3zT6kHtbjKFYGC4I7OcGbpINCL91yY5Q0K7rtsAOvEO260tKXdXRC7Ibh4AquYHOO6waB2OEPn1lJDEw7H+lZQn/DWqozY9KZfbw9vuPFKwvxBBJa1KztJ1luH3WqeV/xs7K9Op6z1/1s6BEhMZw5FW0KiBgDBFMIrpzdOiamXNmJV77Wp40/R90ptDkHROVJZIxIXOMWWfbfHc1/Ecp5eYZ749yOj/rhUmnIY6NQVfJC68OYCMiITcZMN682E30+DLMH7cRU4pDA5a/tfqTKyD622lKzSzZSe4k9Ny9Z/ll3qLFO+ly3JxFQIPeOj4hHg==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=gUYAQyf5E3sqnzgd9Qvljw4xMqM740N2TuUTZfQPEWQ=;
 b=v38mV1tPIEKO3IahbI5cVc61sNaCX01G/pa2M6EmATl84oeADM4K87/q7vRMGNAz0EGGCguDf9W2zsi2QljIIp7FBmqoHI+pTdENoGi8aVEPQii5frT884BE+36uw2BUbKmsPp6JSDEvgo4tMJajDSumUO+6UeHWcCHv8FT3mW6TfLUbTZ/GkB4kJvE5vPP6PjqhfRw83uDoDiv0oUCUlBodHSPIKi6Sx88FOOkG2o5EBGHmSCXicBpAPzCl1Q461upF68XraPb/EQNJJoEnlKrA+Glc8kB9tz4L5iugvrT74OUqXe2yEzJOLx+LA+7nX6htJS+VF+GuinzhkeF3FA==
ARC-Authentication-Results: i=2; mx.microsoft.com 1; spf=fail (sender ip is
 136.226.152.57) smtp.rcpttodomain=kernel.org smtp.mailfrom=netapp.com;
 dmarc=pass (p=reject sp=reject pct=100) action=none header.from=netapp.com;
 dkim=pass (signature was verified) header.d=netapp.com; arc=pass (0 oda=1
 ltdi=1 spf=[1,1,smtp.mailfrom=netapp.com] dkim=[1,1,header.d=netapp.com]
 dmarc=[1,1,header.from=netapp.com])
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=gUYAQyf5E3sqnzgd9Qvljw4xMqM740N2TuUTZfQPEWQ=;
 b=oOchz8QqF/E3rZvp8slV7DyHhvNcyBDc6ZAyB6ffJN2mL7PAHhHR5PRYaBvJ8KXF4TXoVEQeNnfuJh+HTpUG1McdJCNiGIwNQWFz/e6PQ2EXqRfiBEH4UPmzkVoHAef95HVeq2zMAj3255vU8Y8e7KSqxH94Ao+SNRv6+T488vsVyaSG46DHUXOy4v3oNXWxZYLCyUhJB8Wz2BHNQBNFAIDwiG2RKhDhOsvgC4l4cvAad75zZMvSVgOJKAwL7ubjv1ZfRmF/C4wtdhOyP2aopnXTx1NJgjUvi2CnVNmrPieBf507qTyyMxjj8d77Vs+FzJ61KqdJDdLffMcPi5ZaFw==
Received: from CH0PR03CA0086.namprd03.prod.outlook.com (2603:10b6:610:cc::31)
 by BL4PR06MB9637.namprd06.prod.outlook.com (2603:10b6:208:4e4::10) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.546.16; Sat, 24 Oct
 2026 17:37:53 +0000
Received: from LV8PEPF0000005D.namprd02.prod.outlook.com
 (2603:10b6:610:cc:cafe::c) by CH0PR03CA0086.outlook.office365.com
 (2603:10b6:610:cc::31) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.546.20 via Frontend Transport; Sat,
 24 Oct 2026 17:37:53 +0000
X-MS-Exchange-Authentication-Results: spf=fail (sender IP is 136.226.152.57)
 smtp.mailfrom=netapp.com; dkim=pass (signature was verified)
 header.d=netapp.com;dmarc=pass action=none header.from=netapp.com;
Received-SPF: Fail (protection.outlook.com: domain of netapp.com does not
 designate 136.226.152.57 as permitted sender)
 receiver=protection.outlook.com; client-ip=136.226.152.57;
 helo=was11a5.mail.zscalertwo.net;
Received: from was11a5.mail.zscalertwo.net (136.226.152.57) by
 LV8PEPF0000005D.mail.protection.outlook.com (10.167.245.134) with Microsoft
 SMTP Server (version=TLS1_3, cipher=TLS_AES_256_GCM_SHA384) id 15.21.569.4
 via Frontend Transport; Sat, 24 Oct 2026 17:37:52 +0000
Received: from ds2pr08cu001.outbound.protection.outlook.com ([40.93.13.49])
	by was11a5.mail.zscalertwo.net ([136.226.152.43])
	with ESMTPS id 6ADCECF008F70000;
	Sat, 24 Oct 2026 13:37:52 -0400
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=EIPWa8ZbA354na4bKNXcLdsQRQ8p6vk07HeW5r4+/NfYDtc6kZwc/6fc4rFEnNrw8jcXKhwKJHLAL2wkHrLInL89NOw3TDQdIjLAzDE4l53RXA25heSSnoXXHG/7gJpp6GwFpBrDR0sOzi0HXRXOLuRB6Zz4HXtqRSpuIbkgGo2GIOG5XpD7hVzLOy8NQAGbHeYt8+pTR5K5ynI/abLjfCmmrLaFUilUDF5wQW7QpKWEOid3nbs5lXn4oM8Q0m2DsPKXjEhni7Swq/ES/Xqm2pSQ8qR9kr09qGBXgq0v/vUlxD0hWXseECw9RkG0zyoJlEWvldFrJO6p7VmRJEjLOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=gUYAQyf5E3sqnzgd9Qvljw4xMqM740N2TuUTZfQPEWQ=;
 b=Zbe5j6icIC67f9SN4qrDrgxabzzzi4c7yWrekofQ0JLXyZkoS8ZLAYlBMmg+Eu8xl/J83nBPf0eicfLTKCLdt6yWsQUdRmn/kvCNxHT8Ol+36A05aFbSPw2Ye+X2YnWLh3n8PWjqxwgTAN5IOM3yXH0P+LavPE/hMVg/mMWOdIyi2aomc2MLYn3kIA2JHQZT4RlOWJACg2MMxI6G9OSmbXbiy0MyRXKO+zxi7J0db+FmG1GYw/xsucAtsEaHrcJjIOzrjh/RBogKvydX+vBBNApBCR4zOb8Ucen0tPJxTjlJ1AMJg2DKzIsszuetQ5OjSlX7bZMqClu+jSth2XwoFg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=netapp.com; dmarc=pass action=none header.from=netapp.com;
 dkim=pass header.d=netapp.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=gUYAQyf5E3sqnzgd9Qvljw4xMqM740N2TuUTZfQPEWQ=;
 b=oOchz8QqF/E3rZvp8slV7DyHhvNcyBDc6ZAyB6ffJN2mL7PAHhHR5PRYaBvJ8KXF4TXoVEQeNnfuJh+HTpUG1McdJCNiGIwNQWFz/e6PQ2EXqRfiBEH4UPmzkVoHAef95HVeq2zMAj3255vU8Y8e7KSqxH94Ao+SNRv6+T488vsVyaSG46DHUXOy4v3oNXWxZYLCyUhJB8Wz2BHNQBNFAIDwiG2RKhDhOsvgC4l4cvAad75zZMvSVgOJKAwL7ubjv1ZfRmF/C4wtdhOyP2aopnXTx1NJgjUvi2CnVNmrPieBf507qTyyMxjj8d77Vs+FzJ61KqdJDdLffMcPi5ZaFw==
Received: from SA1PR06MB11353.namprd06.prod.outlook.com
 (2603:10b6:806:4a2::17) by MW4PR06MB8396.namprd06.prod.outlook.com
 (2603:10b6:303:12f::8) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.546.21; Sat, 24 Oct
 2026 17:37:50 +0000
Received: from SA1PR06MB11353.namprd06.prod.outlook.com
 ([fe80::ff:880:c010:68bf]) by SA1PR06MB11353.namprd06.prod.outlook.com
 ([fe80::ff:880:c010:68bf%6]) with mapi id 15.21.0546.021; Sat, 24 Oct 2026
 17:37:49 +0000
From: "Mora, Jorge" <Jorge.Mora@netapp.com>
To: Jorge Mora <jmora1300@gmail.com>,
        "linux-nfs@vger.kernel.org"
	<linux-nfs@vger.kernel.org>
CC: "trondmy@kernel.org" <trondmy@kernel.org>,
        "anna@kernel.org"
	<anna@kernel.org>,
        "Bhargava, Rakesh" <Rakesh.Bhargava@netapp.com>,
        "Kumar,
 Mohit" <Mohit.Kumar@netapp.com>,
        "cel@kernel.org" <cel@kernel.org>
Subject: Re: [PATCH] xprtrdma: fix race between frwr_unmap_sync() and
 transport disconnect
Thread-Topic: [PATCH] xprtrdma: fix race between frwr_unmap_sync() and
 transport disconnect
Thread-Index: AQHdY9dCQIpQCgW3dEW+XeuXo9/TPLcM9D8u
Date: Sat, 24 Oct 2026 17:37:49 +0000
Message-ID:
 <SA1PR06MB11353D27DD730F2AED3E2CF10E1632@SA1PR06MB11353.namprd06.prod.outlook.com>
References: <20261024164633.256458-1-mora@netapp.com>
In-Reply-To: <20261024164633.256458-1-mora@netapp.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels:
Authentication-Results-Original: mx.microsoft.com 1; dkim=none (message not
 signed) header.d=none;dmarc=none action=none header.from=netapp.com;
x-ms-traffictypediagnostic:
	SA1PR06MB11353:EE_|MW4PR06MB8396:EE_|LV8PEPF0000005D:EE_|BL4PR06MB9637:EE_
X-MS-Office365-Filtering-Correlation-Id: a2490eaa-8dee-4db5-260d-08df31f5881c
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam-Untrusted:
 BCL:0;ARA:13230040|366016|23010399003|376014|1800799024|6133799003|10067099003|22082099003|18002099003|56012099006|11063799006|5023799004|261009223027099003|261022105027099003|261021135927099003|261021121427099003|261021123027099003|38070700021;
X-Microsoft-Antispam-Message-Info-Original:
 K7vafIOvLxBUBXqVukydGvJi+8E1VjSS2kCXi/D/A2GNrFaetB1fI1sO6O7IADFX+4zYmdnHUXJc8IYQzaVwxgf5TnMaVNpjrLiyG8ZjbHFa9hXMAtSyJluFx7amMhoZkgjF5Ho0n2F8wiFls79iDsB6o0j51x966oGMd0KHnLconbbwPbs+MKKL52XLxnGhdfEvCY0cq3J2xTY/HnsAA16Pnz1pXCFaa9xZVmvDY2JmNk2IMEQ30LUYG0LNHfK02NjmqNHMqrG8f7cOz3EqAEGHK4PQFprp1DaORJKIxiWdtUGzjkdXsmGVhX+Nq5p80elfki+NiO4SQMhnqZ1mON3cTqqVZbh5R2aq5ZUa9yBAOmLvrrQogaJwstHBvWkZr+5VT9pNipXZpoXt4fTc07Cv+uaUWALKza/Pig4YkPv6+ur23YD2FYtPO92tOhBm8OJ3Lyym8IW8L80F/DjSoadiQxFAQI5RAprZHOpb9sfIeLpLCJONSyiFI5mNRXlYw/JYVM3BTGJLy6EM4i2HmdX7qllQMXcTzb6TBMEZRozUtOcocptRJfS/owaRszQeU1ns1VzEbRN5pW/tlV7SwV6NjG5HInL+swYOjbeV6s+Af60K3PP2Ew6IvFn1s9OkS4iofXeSNDcs2nZBXDuJkdUUIO1i6+vBd5gaobaQtrcJBNNM6H5VpfnDy4rCICkIUDhnI0NecMK4RC2y2DxP82EaKx+8ShGcCKBxNIgq57w=
X-Forefront-Antispam-Report-Untrusted:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:SA1PR06MB11353.namprd06.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(366016)(23010399003)(376014)(1800799024)(6133799003)(10067099003)(22082099003)(18002099003)(56012099006)(11063799006)(5023799004)(261009223027099003)(261022105027099003)(261021135927099003)(261021121427099003)(261021123027099003)(38070700021);DIR:OUT;SFP:1101;
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-Exchange-RoutingPolicyChecked:
 b6KmeF2SI30mQ2Bid+0JMzWTuEe8yDU0ihEi5eylPyA71HQGccL7S1XOUkuaF9WHDbChVmqy/8D+1ULXgP23Qdk93QoaWfyROFI2aTJPzhXr/QahRJs3l6IP6RV3RYF+VDVJ3ODZAWASV0oaEjK3Oug/kzK0FkvobC26p7ugTMFGyezsG+lSmo8pOXKp/8UDk3ua1PvfjO6KVJQyikuiF2EHo/afKo+lIsZbPa3O90KnigAuGtgD3f8UjIPls2i1gfhFaFZ98fGFK8AcgeNvQciVaz6Ijdy1OZ/IHtTyrtpggp3TIp1RiKXgtoUEztII0ZMkYicy7dYiAI2OGG6Qaw==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MW4PR06MB8396
X-Zscaler-Block: 0
X-EOPAttributedMessage: 0
X-MS-Exchange-Transport-CrossTenantHeadersStripped:
 LV8PEPF0000005D.namprd02.prod.outlook.com
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id-Prvs:
	6c9ac03e-9f41-40b1-cb7f-08df31f58634
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|23010399003|1800799024|35042699022|376014|36860700016|14060799003|82310400026|261021135927099003|261022105027099003|56012099006|5023799004|11063799006|10067099003|261021121427099003|261021123027099003|261009223027099003|22082099003|18002099003|6133799003;
X-Microsoft-Antispam-Message-Info:
	f3GFCOLnUmql6l50mkLXGMFTb0ruP5Hmi1vJvB2FcNfuZvpXbMxq04llDJutIPkR78/No8d2brDx7N3dFW+ujrF7w+/C075gaExf8f9OoM38yu2ORTetQ6r0+qalOo2HtrgArgoXKDuAwSTVhSEo/tK5HWUfmMgl2GtnbeNxZ2IFv7qLqlS7bdFlD3bKz8b0Jci5fMHoarM8BavzLWxnBQwOKkQr17LCF8EOBpgkHfrfiGu89ZSg9YiX3wDnrgzQ2vqwYEJ44o3Kn0IoHa07dz8ymFKEW8/fFxqnXz2EeZr8tafCIkQuXhYRtpQ71V4dK/RCG7DerUiUPKTdZgQCA4N9fcA4zGg4D5iG++SF0eJrCEXB7VHpNEjcGlSJOKjW8Ck3YR9b7zMavkx4a9EhxMZr+utj4iKIfoFDnQ5LB/I0ODZTF8AtOvHKNMTEel+yS5MYHZqkNHEB3afWAUN1ivw16aS3SAwtaA9ns+fmNY+oMB1jIcDXpzszyskes90Fflz36cI/vEBWc3XAr99xKRsMaVNePyxEI+HHBlotn7jec3/4YjzwwxHi8Z1cSyN2cEXCB3Lmv2+CMZEg2wYk0vtzUlKAYN5/wvqQqf9pRHmmWw4+OGwNcm1S/OhuwTKvOaEXJNaq+NudrWlXowCkZRy/77eIAjt+4ezvwYHNuOuA+55pU7kdTx942d0vJeHIMR0/dPxTz+9tnr9Uw8UhUA==
X-Forefront-Antispam-Report:
	CIP:136.226.152.57;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:was11a5.mail.zscalertwo.net;PTR:was11a5.mail.zscalertwo.net;CAT:NONE;SFS:(13230040)(23010399003)(1800799024)(35042699022)(376014)(36860700016)(14060799003)(82310400026)(261021135927099003)(261022105027099003)(56012099006)(5023799004)(11063799006)(10067099003)(261021121427099003)(261021123027099003)(261009223027099003)(22082099003)(18002099003)(6133799003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	OpRM5CLO3Shax8POMaC0XA7Isc3VB6ri6K8oNAFiDVc7rRA1rWZEf5hTiMPuy66jqD3CRRx8GeTqv3i9gLQL9MxB5p/tsBJaoBBB4nEjVO1BlIR7kdTbRu9p8sWcsiN1KyfWMdKALDSZFtjs29p9qop8haKNOORMY//wAqpzAJung+i/C373OKeZjdCzcwXaXcJMc9IpBAFXKJhpypigo76dK9RgVsetoU90FVin5wd0FJ6cbW4Hk7Pvm9yhZDFR+cWAKFRNOtJdOe+1br/uOzLWN+clq7O2MLr9OXseU4nWS5pNOgWauAPt2tPxJ8Px1/tLnX4kKXfaeUZ+gXIS2e43VM5u93QntsoTbm7QD4Bm9Dj8T9J2w1eOXeXuvKKP0THZ0NQiMyAg2tRDrRacK5IZsFobHdRC9U/+FNu/6iY3xHnQv60pk1q2v7hwDR8S
X-Exchange-RoutingPolicyChecked:
	V2z0mcY6TQRtKImFU++ifVlnDhPdI166zoOKCKWxFdSnFH4h4ERUn2A39h1Rqp8Ux5cnbvHsyM7OWKyUjfWYyUWf5lSYgmVrJOBdACQkQA3JaQSw6PQuK+cIDfu+FXGKyWHOCPTFPtbSY8hoJ6qzk5zryE39XSLz5+mgqk111UKTKYL2kDoxq3z1QcMGXUuSTyG6f7T58P0fYOzkRarEb3NiE2tYzzC4EiaHZ0OBCja9EaWLSv/vqFAqLWtUr6sSxIUjwAPAxwUwigPdFJiQIylQYcy1XNbKa/zc8d1qzkmF58BnjCh8bM1NEWdKk1yrsFVANjVhczC1We30YrSMjw==
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0:
	yuIm9HB1XSTx5vVKr5Lqp6VJG8KEAFLph8pl15osDr1/W6nvbHKIG9rrbb/7nqvvRnJGSOdHEBFbS1mqXnUwbGXKMdZ9mIi7WLZ9UNlwXgYVBJZ8OddQGqw2VEYK4LbO4e7+NQnH/tiTOEZI5XcOX/9SYgad5CKBKCdJilkWNHxxSnRZAd3eek9LTUDfdJCNUkvoA24jXbUyMGk0v1NWBShX65FXvpSsMGjCyxrUkj8f04mnOnsryZUEbpuF5gv+Id6vFzwoPTYNo6rC600SM4ajXFUbonoWTK4TTqitKftKPd/LG+2z5/kctCP16CB8yVQsqihWYWlu2EqM7lCSd3WwM2DHelkwUZ/FNV30dZ2H63TFS68Cmn4QDLSR1ZdvW5GrBK0WUvGb1BYYUHFQSGQfAWUxm+1ivZad1SzDKGwEeAt8zoYqbhv897n+PnfaSzVM++P9VaiqclBVTYrb0/KNEHmLrTsZkCL13kXf9gRqSbjzDLxL30U/eMyz+SPeM7WWTqnf1ueQlwsi4y4+/j2gOxMFYmde3ecHgjpPVp0hiq5wuAn8e/1pR2iEED/4XVSb2iQp43DZ8RSpB8W2b1KIjXCiXsebib/VZl+WBJ1+CZdY3fgFX6sEDg3nErz6
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 24 Oct 2026 17:37:52.9431
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: a2490eaa-8dee-4db5-260d-08df31f5881c
X-MS-Exchange-CrossTenant-Id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=4b0911a0-929b-4715-944b-c03745165b3a;Ip=[136.226.152.57];Helo=[was11a5.mail.zscalertwo.net]
X-MS-Exchange-CrossTenant-AuthSource:
	LV8PEPF0000005D.namprd02.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BL4PR06MB9637
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYxMDI0MDA3MCBTYWx0ZWRfX+T2vNEfgl770
 7NZY20Qm7fD475Lq44jefy+h3hEeOxTFglzs3iMdx+yXNykg0MtZPsR6GMp5/euRbFGllezYnnT
 kKK3R1DGQ1OeEojCHiwlW0+pBVv+bGzrT1kSWnCqrmpf7/OOPy2Q5wAvwEcFmv4S4AD46pkqoff
 kTNsXrqzDdaabZQp4S42fj8IuuTPeTcDfoGlJknWvMUJXmmooS+TQUN27awNR/ZjhTO7QeG8wFg
 2QJ5rgGRHbdaASOw/ND74dK3jutKjpHVesemAIscVfj4BTJfCAhhAFAC7aMe2Cp+iAJrwz0HjGb
 9l6gbn1mL3GCbzoTCEEn0e02XS737xeiUmWZrRvS1slLbFA5cCZWdHQ9woFkEv0IK1xNjzHDtso
 ekOATo8gqoE82SeqCgP05dK5DprMDiko6gy3n3evaNV1eSGTuYGvK0+0h1G/qA+A7q/+1TGMyYq
 3Z5tCzjGEut0W0xX/Gg==
X-Proofpoint-GUID: 2qxUxgDg8Fh7lSQUsGkpT8zEaDuvMiHL
X-Authority-Analysis: v=2.4 cv=bKqDs/+Z c=1 sm=1 tr=0 ts=6adcecf5 cx=c_pps
 a=eN70jGNn7EKSdYhrfilGAg==:117 a=y2qyX5seKirFBAuOJ2n+PQ==:17
 a=6eWqkTHjU83fiwn7nKZWdM+Sl24=:19 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19
 a=xqWC_Br6kY4A:10 a=8nJEP1OIZ-IA:10 a=660iZSQnnn4A:10 a=GWG4Yq0kndkA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=1lWG0UuNQvn8UhQ8Wh4S:22 a=X7e-fZ-CKB32rjcIpVUG:22
 a=pGLkceISAAAA:8 a=VwQbUJbxAAAA:8 a=JDjsHSkAAAAA:8 a=9kkPong5pDjL4wnOnGUA:9
 a=wPNLvfGTeEIA:10 a=dseMxAR1CDlncBZeV_se:22
X-Proofpoint-ORIG-GUID: 2qxUxgDg8Fh7lSQUsGkpT8zEaDuvMiHL
X-Proofpoint-Spam-Info: AW1haW4tMjYxMDI0MDA3MCBTYWx0ZWRfX18UA8dn7+/FH
 8AMpYV07gXuYbq0Dgdri19BaPI/W272OoFJHoJKw98x2Fxjt7AcnexWTddLkQ9GDzXmkH2aod29
 bwAucKZCFStgJWwVcEq4X1M824ICcRw=
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.138,FMLib:17.12.100.49
 definitions=2026-10-24_02,2026-10-21_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 malwarescore=0 impostorscore=0 clxscore=1011 suspectscore=0
 lowpriorityscore=0 spamscore=0 adultscore=0 phishscore=0 priorityscore=1501
 bulkscore=0 classifier=typeunknown authscore=0 authtc= authcc= route=outbound
 adjust=0 reason=mlx scancount=1 engine=8.22.0-2610190000
 definitions=main-2610240070

Adding Chuck Lever.=0A=
=0A=
=0A=
________________________________________=0A=
From: Jorge Mora <jmora1300@gmail.com>=0A=
Sent: Saturday, October 24, 2026 10:46 AM=0A=
To: linux-nfs@vger.kernel.org=0A=
Cc: trondmy@kernel.org; anna@kernel.org; Bhargava, Rakesh; Kumar, Mohit; Mo=
ra, Jorge=0A=
Subject: [PATCH] xprtrdma: fix race between frwr_unmap_sync() and transport=
 disconnect=0A=
=0A=
EXTERNAL EMAIL - USE CAUTION when clicking links or attachments=0A=
=0A=
=0A=
=0A=
=0A=
From: Rakesh Bhargava <Rakesh.Bhargava@netapp.com>=0A=
=0A=
frwr_unmap_sync() is called from xprt_rdma_free() via ->buf_free, which=0A=
xprt_release() invokes without holding the transport send lock and=0A=
without XPRT_LOCKED. rpcrdma_xprt_disconnect() runs from xprt_autoclose()=
=0A=
under XPRT_LOCKED and, after draining the QP, resets every rpcrdma_req=0A=
(rpcrdma_reqs_reset) and destroys every MR (rpcrdma_mrs_destroy). Nothing=
=0A=
orders the two, so both can walk and list_del() the same req's=0A=
rl_registered list and the same MRs. Observed on RHEL 10.2=0A=
(6.12.0-211.7.3.el10_2) NFS/RDMA FlexFiles clients as:=0A=
=0A=
  kernel BUG at lib/list_debug.c:65!=0A=
  frwr_unmap_sync+0x75 [rpcrdma]=0A=
  xprt_release+... [sunrpc]=0A=
=0A=
In a vmcore, the panicking task was in frwr_unmap_sync() for r_xprt X=0A=
while another kworker was in xprt_autoclose -> rpcrdma_xprt_disconnect=0A=
-> rpcrdma_reqs_reset -> frwr_mr_release for the same r_xprt X. The=0A=
window was large because 256 transports were being torn down at once,=0A=
each blocked in mlx5_core_destroy_mkey waiting on firmware.=0A=
=0A=
Other consequences of the same race are a use of ep after=0A=
rpcrdma_ep_put() frees it, and rpcrdma_flush_disconnect() dereferencing=0A=
r_xprt->rx_ep after disconnect cleared it.=0A=
=0A=
Fix it by making frwr_unmap_sync() and disconnect cooperate through=0A=
rb_lock:=0A=
=0A=
 - frwr_unmap_sync() reads rx_ep, checks rb_closing and that=0A=
   rl_registered is non-empty, and claims all of the req's MRs under=0A=
   rb_lock. It bumps rb_unmap_users while it still references the MRs=0A=
   and the ep, and drops it (waking rb_unmap_wq) when done.=0A=
 - If rb_closing is set, frwr_unmap_sync() returns and leaves the MRs on=0A=
   rl_registered. rb_closing is only set after rdma_disconnect(), when=0A=
   the QP is in the error state and the peer cannot reach the MRs;=0A=
   rpcrdma_reqs_reset() then releases them.=0A=
 - rpcrdma_xprt_disconnect() sets rb_closing after rdma_disconnect(),=0A=
   waits for rb_unmap_users to reach zero after draining the QP and=0A=
   before releasing reps, reqs and MRs, and clears rx_ep and rb_closing=0A=
   under rb_lock before dropping the ep reference.=0A=
 - rpcrdma_flush_disconnect() tolerates a NULL rx_ep.=0A=
=0A=
Signed-off-by: Rakesh Bhargava <Rakesh.Bhargava@netapp.com>=0A=
Signed-off-by: Jorge Mora <mora@netapp.com>=0A=
---=0A=
 net/sunrpc/xprtrdma/frwr_ops.c  | 43 ++++++++++++++++++++++++++------=0A=
 net/sunrpc/xprtrdma/verbs.c     | 44 ++++++++++++++++++++++++++++++---=0A=
 net/sunrpc/xprtrdma/xprt_rdma.h | 14 +++++++++++=0A=
 3 files changed, 90 insertions(+), 11 deletions(-)=0A=
=0A=
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.=
c=0A=
index e83cef19e656..03e0e6c475b1 100644=0A=
--- a/net/sunrpc/xprtrdma/frwr_ops.c=0A=
+++ b/net/sunrpc/xprtrdma/frwr_ops.c=0A=
@@ -567,12 +567,33 @@ static void frwr_wc_localinv_wake(struct ib_cq *cq, s=
truct ib_wc *wc)=0A=
  */=0A=
 void frwr_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)=
=0A=
 {=0A=
+       struct rpcrdma_buffer *buf =3D &r_xprt->rx_buf;=0A=
        struct ib_send_wr *first, **prev, *last;=0A=
-       struct rpcrdma_ep *ep =3D r_xprt->rx_ep;=0A=
        const struct ib_send_wr *bad_wr;=0A=
+       struct rpcrdma_ep *ep;=0A=
        struct rpcrdma_mr *mr;=0A=
        int rc;=0A=
=0A=
+       /* This function is invoked via ->buf_free, which does not=0A=
+        * hold the transport send lock. It therefore races with=0A=
+        * rpcrdma_xprt_disconnect(), which resets every req and=0A=
+        * destroys every MR.=0A=
+        *=0A=
+        * Claim the req's MRs, and pin the transport's ep, under=0A=
+        * rb_lock. If the disconnect path has already put the QP=0A=
+        * into the error state, leave the MRs on rl_registered:=0A=
+        * the peer can no longer reach them, and=0A=
+        * rpcrdma_reqs_reset() releases them.=0A=
+        */=0A=
+       spin_lock(&buf->rb_lock);=0A=
+       ep =3D r_xprt->rx_ep;=0A=
+       if (buf->rb_closing || !ep ||=0A=
+           list_empty(&req->rl_registered)) {=0A=
+               spin_unlock(&buf->rb_lock);=0A=
+               return;=0A=
+       }=0A=
+       buf->rb_unmap_users++;=0A=
+=0A=
        /* ORDER: Invalidate all of the MRs first=0A=
         *=0A=
         * Chain the LOCAL_INV Work Requests and post them with=0A=
@@ -598,6 +619,7 @@ void frwr_unmap_sync(struct rpcrdma_xprt *r_xprt, struc=
t rpcrdma_req *req)=0A=
                *prev =3D last;=0A=
                prev =3D &last->next;=0A=
        } while ((mr =3D rpcrdma_mr_pop(&req->rl_registered)));=0A=
+       spin_unlock(&buf->rb_lock);=0A=
=0A=
        mr =3D container_of(last, struct rpcrdma_mr, mr_invwr);=0A=
=0A=
@@ -621,15 +643,22 @@ void frwr_unmap_sync(struct rpcrdma_xprt *r_xprt, str=
uct rpcrdma_req *req)=0A=
         */=0A=
        if (bad_wr !=3D first)=0A=
                wait_for_completion(&mr->mr_linv_done);=0A=
-       if (!rc)=0A=
-               return;=0A=
+       if (rc) {=0A=
+               /* On error, the MRs get destroyed once the QP has drained.=
 */=0A=
+               trace_xprtrdma_post_linv_err(req, rc);=0A=
=0A=
-       /* On error, the MRs get destroyed once the QP has drained. */=0A=
-       trace_xprtrdma_post_linv_err(req, rc);=0A=
+               /* Force a connection loss to ensure complete recovery.=0A=
+                */=0A=
+               rpcrdma_force_disconnect(ep);=0A=
+       }=0A=
=0A=
-       /* Force a connection loss to ensure complete recovery.=0A=
+       /* The MRs and the ep are no longer referenced. Allow=0A=
+        * rpcrdma_xprt_disconnect() to proceed.=0A=
         */=0A=
-       rpcrdma_force_disconnect(ep);=0A=
+       spin_lock(&buf->rb_lock);=0A=
+       if (!--buf->rb_unmap_users)=0A=
+               wake_up(&buf->rb_unmap_wq);=0A=
+       spin_unlock(&buf->rb_lock);=0A=
 }=0A=
=0A=
 /**=0A=
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c=0A=
index be335eed329d..8848cebc42b2 100644=0A=
--- a/net/sunrpc/xprtrdma/verbs.c=0A=
+++ b/net/sunrpc/xprtrdma/verbs.c=0A=
@@ -133,8 +133,14 @@ void rpcrdma_force_disconnect(struct rpcrdma_ep *ep)=
=0A=
  */=0A=
 void rpcrdma_flush_disconnect(struct rpcrdma_xprt *r_xprt, struct ib_wc *w=
c)=0A=
 {=0A=
-       if (wc->status !=3D IB_WC_SUCCESS)=0A=
-               rpcrdma_force_disconnect(r_xprt->rx_ep);=0A=
+       struct rpcrdma_ep *ep =3D READ_ONCE(r_xprt->rx_ep);=0A=
+=0A=
+       /* A flushed completion can be processed after the disconnect=0A=
+        * path has already divested the transport of its endpoint.=0A=
+        * In that case the connection is already gone.=0A=
+        */=0A=
+       if (wc->status !=3D IB_WC_SUCCESS && ep)=0A=
+               rpcrdma_force_disconnect(ep);=0A=
 }=0A=
=0A=
 /**=0A=
@@ -580,6 +586,7 @@ int rpcrdma_xprt_connect(struct rpcrdma_xprt *r_xprt)=
=0A=
  */=0A=
 void rpcrdma_xprt_disconnect(struct rpcrdma_xprt *r_xprt)=0A=
 {=0A=
+       struct rpcrdma_buffer *buf =3D &r_xprt->rx_buf;=0A=
        struct rpcrdma_ep *ep =3D r_xprt->rx_ep;=0A=
        struct rdma_cm_id *id;=0A=
        int rc;=0A=
@@ -591,16 +598,42 @@ void rpcrdma_xprt_disconnect(struct rpcrdma_xprt *r_x=
prt)=0A=
        rc =3D rdma_disconnect(id);=0A=
        trace_xprtrdma_disconnect(r_xprt, rc);=0A=
=0A=
+       /* The QP is in the error state now, so the peer can no=0A=
+        * longer access any registered MR. From here on, a=0A=
+        * frwr_unmap_sync() caller that has not yet claimed a req's=0A=
+        * MRs leaves them on rl_registered: rpcrdma_reqs_reset()=0A=
+        * releases them below.=0A=
+        */=0A=
+       spin_lock(&buf->rb_lock);=0A=
+       buf->rb_closing =3D true;=0A=
+       spin_unlock(&buf->rb_lock);=0A=
+=0A=
        rpcrdma_xprt_drain(r_xprt);=0A=
+=0A=
+       /* frwr_unmap_sync() runs without the transport send lock.=0A=
+        * Callers that claimed MRs before rb_closing was set may=0A=
+        * still be posting or waiting on LOCAL_INV Work Requests.=0A=
+        * Those complete (or flush) because the QP has been=0A=
+        * drained, but the callers still reference the MRs and the=0A=
+        * ep, so wait for them before anything is released.=0A=
+        */=0A=
+       wait_event(buf->rb_unmap_wq, !READ_ONCE(buf->rb_unmap_users));=0A=
+=0A=
        rpcrdma_reps_unmap(r_xprt);=0A=
        rpcrdma_sendctxs_destroy(r_xprt);=0A=
        rpcrdma_reqs_reset(r_xprt);=0A=
        rpcrdma_mrs_destroy(r_xprt);=0A=
=0A=
+       /* Unpublish the ep before dropping the last reference to it=0A=
+        * so that frwr_unmap_sync() never picks up a stale pointer.=0A=
+        */=0A=
+       spin_lock(&buf->rb_lock);=0A=
+       r_xprt->rx_ep =3D NULL;=0A=
+       buf->rb_closing =3D false;=0A=
+       spin_unlock(&buf->rb_lock);=0A=
+=0A=
        if (rpcrdma_ep_put(ep))=0A=
                rdma_destroy_id(id);=0A=
-=0A=
-       r_xprt->rx_ep =3D NULL;=0A=
 }=0A=
=0A=
 /* Fixed-size circular FIFO queue. This implementation is wait-free and=0A=
@@ -1168,6 +1201,9 @@ int rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt=
)=0A=
=0A=
        buf->rb_bc_srv_max_requests =3D 0;=0A=
        spin_lock_init(&buf->rb_lock);=0A=
+       buf->rb_closing =3D false;=0A=
+       buf->rb_unmap_users =3D 0;=0A=
+       init_waitqueue_head(&buf->rb_unmap_wq);=0A=
        INIT_LIST_HEAD(&buf->rb_mrs);=0A=
        INIT_LIST_HEAD(&buf->rb_all_mrs);=0A=
        INIT_WORK(&buf->rb_refresh_worker, rpcrdma_mr_refresh_worker);=0A=
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdm=
a.h=0A=
index 4cbc941e4a3e..0161317e4916 100644=0A=
--- a/net/sunrpc/xprtrdma/xprt_rdma.h=0A=
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h=0A=
@@ -402,6 +402,20 @@ struct rpcrdma_buffer {=0A=
        u32                     rb_bc_max_requests;=0A=
=0A=
        struct work_struct      rb_refresh_worker;=0A=
+=0A=
+       /* Serializes frwr_unmap_sync(), which runs from ->buf_free=0A=
+        * without holding the transport send lock, against=0A=
+        * rpcrdma_xprt_disconnect(). Protected by rb_lock.=0A=
+        *=0A=
+        * rb_closing: the QP is in the error state and the disconnect=0A=
+        *      path is about to reset all reqs and destroy all MRs.=0A=
+        * rb_unmap_users: number of frwr_unmap_sync() callers that=0A=
+        *      own MRs taken from a req's rl_registered list, or have=0A=
+        *      LOCAL_INV Work Requests outstanding on the QP.=0A=
+        */=0A=
+       bool                    rb_closing;=0A=
+       unsigned int            rb_unmap_users;=0A=
+       wait_queue_head_t       rb_unmap_wq;=0A=
 };=0A=
=0A=
 /*=0A=
=0A=
base-commit: 18a80121193c6d19519e218434c9acf90e8d0e5c=0A=
--=0A=
2.47.3=0A=
=0A=
