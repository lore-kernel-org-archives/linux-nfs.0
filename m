Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=2 smtp.remote-ip=67.231.157.221
ARC-Seal: i=3; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793981992;
	b=jTb06CDMX9nBI6sPbXwDGM2Wqc9tEiaOOdHuTd5kJ5wUnUR5OQ7GkM/bSTZHvmbIxWeM
	 JnWNqrmNui2OUAjyOZkDHKT01/JLHF64uHOjbgcQASrbr7tz34zRjKoviWOS5lQMZDQfu
	 qb4hSWAZIpz+m2Rpaj/7EpWWMAfNI5I3jt/5ZMMMJppAorlnXM7ppGLaGtCxpg+XZb4aE
	 coRSDptHf9GBBx0xUgNGdURm3RY3hMi0Ax6jcQ91WGn938AxDTGWUxOeFIsggwVDXDxfY
	 jHpMwAer7dO5a84ijU045AFXlA4XOrS0341nbT+o+skp/3VgXbwbutKLbKIOPnbyHDw==
ARC-Message-Signature: i=3; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793981992;
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
	 X-Proofpoint-ORIG-GUID:X-Authority-Analysis:X-Proofpoint-GUID:
	 X-Proofpoint-Spam-Info:X-Proofpoint-Spam-Details-Enc:
	 X-Proofpoint-Virus-Version:X-Proofpoint-Spam-Details;
	bh=nS268Saru4tNBw4ULsaHKSVmr22x5Zked37diA/Nm7I=;
	b=ZIovCiqzSL3wAfYFEmVFV3qcRMWqN/sPX0KHXAaUnqQjjrr+Bc9tPb22SHmZklHOe3cH
	 sEfXiCX4LMGOv5K1aDc34i3qcc+S08uYqT4FY0DryDDfrcULCkpA2blwulaeeSyZ5ELrF
	 /iIVwk1makKEikn68OBGjyP5BvvbTZWTRwoMT4Dcx9ZyV+P/c4pM91RtJq2E5zDbiwT9c
	 w1Cp9FaCH58CwGSuBnsOK7p10U/Z31ECCxUnABfrwK/dwrGA80kw4iV2XegG3ico2ImXv
	 clhaScv7wwZCPr9GIG/EVdVHoXzaFW0pv/ls6v4qPbXq19ko18el0ey1ebpS19HGcdQ==
ARC-Authentication-Results: i=3; smtp.subspace.kernel.org; 
	dmarc=pass header.from=netapp.com;
	spf=pass smtp.mailfrom=netapp.com;
	dkim=pass header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=pps1 header.b=G7hDP2fj;
	dkim=pass header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=selector1 header.b=c2q59h3X;
	dkim=pass header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=selector1 header.b=c2q59h3X;
	arc=pass header.oldest-pass=2 smtp.remote-ip=67.231.157.221
Received: from mx0b-003fbd02.pphosted.com (mx0b-003fbd02.pphosted.com [67.231.157.221])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B61D6606A32F
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 16:19:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B61D6606A32F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=netapp.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netapp.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=pps1 header.b=G7hDP2fj;
	dkim=pass (2048-bit key, unprotected) header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=selector1 header.b=c2q59h3X;
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=selector1 header.b=c2q59h3X
Received: from pps.filterd (m0412383.ppops.net [127.0.0.1])
	by mx0b-003fbd02.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 6A6F1mGd1058087;
	Fri, 6 Nov 2026 16:19:37 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=pps1; bh=nS268
	Saru4tNBw4ULsaHKSVmr22x5Zked37diA/Nm7I=; b=G7hDP2fjv4nUSQETWIvkA
	zkvEXQcL4ERhwESNOPKOIaF7BypaCxN2IFPR/E8utY/LP8jWpfxeglnQH8FaiEY0
	wXug0M1D2kcHtTn8K+RcqzaJmYij8N7wr5Zw4J80Ww1u3DT6IsD/CQ+14BuYa3eP
	xgBa9wVVyILu7+M+Pyfe6VhwdpmEKWZykKlVMtiGqaF13yOkQ5r5aKpWlbIq84kv
	epIUg2B+7JcAjSvZ3joF3ryQb3Q23nbqUblVammfJTQrAFXqscNoqc34g9S5sQHN
	cbQKsFiC9BTmu1aodveUK1ZERJox1LuLPsJ0eX95+HM6+uTgLStLkcEDGFk3CItv
	Q==
Received: from dm5pr21cu001.outbound.protection.outlook.com (mail-centralusazon11011026.outbound.protection.outlook.com [52.101.62.26])
	by mx0b-003fbd02.pphosted.com (PPS) with ESMTPS id 4hs3px2ucw-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Fri, 06 Nov 2026 16:19:36 +0000 (GMT)
ARC-Seal: i=2; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=pass;
 b=vP5eTv/8RTY6KceaLuiNT/czbTrAI/i0I/MmBOLtfd0Pc9bn+fNlI6IY/mRARsYYtG6J17HNGlXS6Uj8jNElp5jielXCTWzalbquJntxuagfW+Vdi3HZ0I6ZD1X7M7dbBQaJ/xCBfUI2VZpOT4RxvnWHK8f3PERJtCMI3RWjABL2Duu+T2y5VmchSY+YHNAS/Ue+KVGASjxqwVwJTi5AtscxSyEpsLZuOMj9c/vtX/Cii7mIt3+cK6r1ps9yIKnBDa8SqHoltq8aMsTEW8prsC1/GarxRRvU2OIMwRKZbesElrLduYls6l+yeo3pa4IJMNo26JsfLhadLKTOHWUYMw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=nS268Saru4tNBw4ULsaHKSVmr22x5Zked37diA/Nm7I=;
 b=tPWohIbEQ4CbE1SJk8G/OFxun3khNq/fTKIu6813ykIH4X6mcxQMdMntZWnV+KG4exTNvJgr4jnvgnFcQ5jyOovEL6+mBI6DCCR0iq3H9+UsEnhQCShEp8ZJ4i8cmZrYLWbj69n3UeTmWhZgFJXqrrDj563ym7zUfBS1Bx8dMn0WRIukA9Mm740SjraoUT2RFIWkEIAwkVCgLKslI+e4oaUsvRTwEXBtXHBIJeIEAp31HrcRkbsc6X67iykCL6rHoFfi5KExczhjpZm7LcJyK6RCf8tmFo31dJ3VT6e+Ar3CJzVbf8En7Xo9qpUJRSiJTNJCNC3LtJTNPDrB6QuTBQ==
ARC-Authentication-Results: i=2; mx.microsoft.com 1; spf=fail (sender ip is
 136.226.142.114) smtp.rcpttodomain=kernel.org smtp.mailfrom=netapp.com;
 dmarc=pass (p=reject sp=reject pct=100) action=none header.from=netapp.com;
 dkim=pass (signature was verified) header.d=netapp.com; arc=pass (0 oda=1
 ltdi=1 spf=[1,1,smtp.mailfrom=netapp.com] dkim=[1,1,header.d=netapp.com]
 dmarc=[1,1,header.from=netapp.com])
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=nS268Saru4tNBw4ULsaHKSVmr22x5Zked37diA/Nm7I=;
 b=c2q59h3XsPfa/GZ+t0Oj8WGUKQlGDH+JkCvxUBG/WcEuf0G8Eik4cmGBiWgkcTDqoiYWAcHxa/1cMM4gMMfV3TSIxbiGPjQLXhLTqIHxQJUKSZal9zuQ+yCgqu4cYYCuTCoz+6ZpsqBiAWL+k1qko6x3fMoSETY3pU5AzvcVcMb5ZC2WXVowKAMToDC1tY1bHFqec7SidOhPwU4sDRt8PQEhpYrBhpZARgr/zcMsV0uQQ1CSfchcku6LLefcABBAhBlm8gncrsLgx3wIeT9Hpgq6auLzJMg4w9Howk6q4bvvX1UfYIqqtvUF0N1AynAJhuA+k6waUSGWHQ/FMsAUdg==
Received: from DM6PR08CA0059.namprd08.prod.outlook.com (2603:10b6:5:1e0::33)
 by CY0PR06MB138629.namprd06.prod.outlook.com (2603:10b6:930:138::12) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.592.11; Fri, 6 Nov
 2026 16:19:25 +0000
Received: from CY5PEPF00000E7A.namprd02.prod.outlook.com
 (2603:10b6:5:1e0:cafe::70) by DM6PR08CA0059.outlook.office365.com
 (2603:10b6:5:1e0::33) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.592.11 via Frontend Transport; Fri, 6
 Nov 2026 16:19:25 +0000
X-MS-Exchange-Authentication-Results: spf=fail (sender IP is 136.226.142.114)
 smtp.mailfrom=netapp.com; dkim=pass (signature was verified)
 header.d=netapp.com;dmarc=pass action=none header.from=netapp.com;
Received-SPF: Fail (protection.outlook.com: domain of netapp.com does not
 designate 136.226.142.114 as permitted sender)
 receiver=protection.outlook.com; client-ip=136.226.142.114;
 helo=sjc41b5.mail.zscalertwo.net;
Received: from sjc41b5.mail.zscalertwo.net (136.226.142.114) by
 CY5PEPF00000E7A.mail.protection.outlook.com (10.167.247.42) with Microsoft
 SMTP Server (version=TLS1_3, cipher=TLS_AES_256_GCM_SHA384) id 15.21.615.4
 via Frontend Transport; Fri, 6 Nov 2026 16:19:24 +0000
Received: from sn1pr07cu001.outbound.protection.outlook.com ([40.93.14.102])
	by sjc41b5.mail.zscalertwo.net ([136.226.142.95])
	with ESMTPS id 6AEDFE0B08C40001;
	Fri, 06 Nov 2026 08:19:23 -0800
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=klpB+LY6UblHqJ1uCTZd15C01cGSDvYlqVHrdFToTBxLZ6a5c/6xZJaxvI+q5bM6/g9L9jmBBgRZS4AMETKQ7ibklp9rVMY+Gk9FjUwx2SHZOPkB/qMvI3LAvmaOQ1WvZ2yE2/3aNGC9bkZQ33B3XG4cLiHgAIQn/EjwfY0frD12rK+wZ7rmRKebW9vl7Uc2/Hn5HRlB8cZdGj52NfF3z/kYo25UkD6UuM8ffm/cq6mI5QbHpFWGqZRqDUSE0EZs9EEuSgJjMyhrKZLvwi8zTM4hFJSQt17d3y29U7+pLyNvLRhc3PGpZzZ/0b8M7WPRhlmrCUe64Z4MVh+Q76uexg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=nS268Saru4tNBw4ULsaHKSVmr22x5Zked37diA/Nm7I=;
 b=iE8fIwu4tawhIm+UFxDFqh8Zo3ZuGPM6vlCapaA+kceL48MhDlrN0Wn1rBxBmaEmQn1ZO50SIDQNOsu78EqxiaXg1wXEaeKtqvVWWvRuiguAOVyZw7n5vR9tcRSnO0FpWhUOtpu3IJJ3o9ceNOn97aSCx4Y/U9WikHwzhDbYHNoFA2DpHhDqmiL4R5ipXwEm3YL+8I4HBRdQ8cqY8RIVLxbdiCFpT8/pIZiSN4u32cus+WK4gtarnpJqQSDk3yoLZxSmMJcS5boek0DlVbTVLMxrt/4gtW0GHKIm3JgrmstBg+1M5PSXqWHy309OqO0pI3nvZH2XDQ2divKexJsR3Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=netapp.com; dmarc=pass action=none header.from=netapp.com;
 dkim=pass header.d=netapp.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=nS268Saru4tNBw4ULsaHKSVmr22x5Zked37diA/Nm7I=;
 b=c2q59h3XsPfa/GZ+t0Oj8WGUKQlGDH+JkCvxUBG/WcEuf0G8Eik4cmGBiWgkcTDqoiYWAcHxa/1cMM4gMMfV3TSIxbiGPjQLXhLTqIHxQJUKSZal9zuQ+yCgqu4cYYCuTCoz+6ZpsqBiAWL+k1qko6x3fMoSETY3pU5AzvcVcMb5ZC2WXVowKAMToDC1tY1bHFqec7SidOhPwU4sDRt8PQEhpYrBhpZARgr/zcMsV0uQQ1CSfchcku6LLefcABBAhBlm8gncrsLgx3wIeT9Hpgq6auLzJMg4w9Howk6q4bvvX1UfYIqqtvUF0N1AynAJhuA+k6waUSGWHQ/FMsAUdg==
Received: from SA1PR06MB11353.namprd06.prod.outlook.com
 (2603:10b6:806:4a2::17) by LV3PR06MB10076.namprd06.prod.outlook.com
 (2603:10b6:408:23b::12) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.592.10; Fri, 6 Nov
 2026 16:19:21 +0000
Received: from SA1PR06MB11353.namprd06.prod.outlook.com
 ([fe80::ff:880:c010:68bf]) by SA1PR06MB11353.namprd06.prod.outlook.com
 ([fe80::ff:880:c010:68bf%6]) with mapi id 15.21.0592.010; Fri, 6 Nov 2026
 16:19:21 +0000
From: "Mora, Jorge" <Jorge.Mora@netapp.com>
To: Chuck Lever <cel@kernel.org>, Jorge Mora <jmora1300@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "trondmy@kernel.org" <trondmy@kernel.org>,
        "anna@kernel.org"
	<anna@kernel.org>,
        "Bhargava, Rakesh" <Rakesh.Bhargava@netapp.com>,
        "Kumar,
 Mohit" <Mohit.Kumar@netapp.com>,
        "tmenninger@everpuredata.com"
	<tmenninger@everpuredata.com>
Subject: Re: [PATCH v2] xprtrdma: fix race between frwr_unmap_sync() and
 transport disconnect
Thread-Topic: [PATCH v2] xprtrdma: fix race between frwr_unmap_sync() and
 transport disconnect
Thread-Index: AQHdbXypY3rvKRiOM0GpQ7vSbUrvx7chJfgAgAATkwQ=
Date: Fri, 6 Nov 2026 16:19:21 +0000
Message-ID:
 <SA1PR06MB11353CAFA628A73CFBFE8DE13E1762@SA1PR06MB11353.namprd06.prod.outlook.com>
References: <20261105232137.4706-1-mora@netapp.com>
 <e62137dd-e1ce-46bb-8973-734ce8ed5489@slotpi15m67>
In-Reply-To: <e62137dd-e1ce-46bb-8973-734ce8ed5489@slotpi15m67>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels:
Authentication-Results-Original: mx.microsoft.com 1; dkim=none (message not
 signed) header.d=none;dmarc=none action=none header.from=netapp.com;
x-ms-traffictypediagnostic:
	SA1PR06MB11353:EE_|LV3PR06MB10076:EE_|CY5PEPF00000E7A:EE_|CY0PR06MB138629:EE_
X-MS-Office365-Filtering-Correlation-Id: 73f7b18a-4b84-43eb-f59f-08df3c21b94a
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam-Untrusted:
 BCL:0;ARA:13230040|23010399003|1800799024|366016|376014|38070700021|261022105027099003|261021121427099003|11063799006|5023799004|10067099003|261022075727099003|261021135927099003|261022113327099003|56012099006|261021123027099003|261009223027099003|261022115727099003|261021133027099003|261026121527099003|261028144727099003|261102123227099003|261026140227099003|261026130827099003|261021130227099003|261026135527099003|4143699003|22082099003|18002099003|6133799003|4133799003;
X-Microsoft-Antispam-Message-Info-Original:
 6CCczVF/hDFyWSICa3Utmiq6c7zUwCV2FXbgNNdqZ8PjO+GTQ6aGFQ27XdF2O4xRgNZaALL0Z3Ubu60dkRf2KVEl7EzBZ3SDxwLMQ/kMhIsKHfc2dOk3bA2UJCu6zsRvTaZ3tuS4R46ilop/vIcyGtgFrQYAjdEb5abCzHJvmCFeLalzdLO2JKc8+1BJE4fDNEkSMYc12kL9i4w4WJ3LKiLslc/BxuFd/BnZpM0BYV+tiYWW33ti9kXJuY7imJpOX9IQtIieb5ukK+5M2gcXTI52355rTPHhLtYnvv75CsXWNbZ/UrOtjE1ZP4/sGvHkV4b/Ejs4YtqRPIq679NXuoQQ2zkg/sOAp4ColONnIAHMKGAPUpQPwgKTObHdXtz2lxn+rKp3ktati6kNgY678aXrR1G1x4ZEmkjGpqSSJd/RQIESFt7HzkvulfRrYlOClBEcsTC/h4r9s8YYtLG9gc+Ez1hfaMs0tfPIfL5NI9E7PacyJnI6EDrLt+03PyOsKxHJtqoxK+ODvoDFb7zknTDbNJ7i/LPiEZGyhMK+eD37aHz1N3vVbdz5h4V2dPzACAmzOQrtJM3OdmOY2AaoyNNFw3ERg+oZbQIVlxfCKfI995m9yKfFeXNxE+dW8xYzhi6uwySw/syH6HZ+iVLRHElnzi6qQg0o5sxJ/PzikRg=
X-Forefront-Antispam-Report-Untrusted:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:SA1PR06MB11353.namprd06.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(23010399003)(1800799024)(366016)(376014)(38070700021)(261022105027099003)(261021121427099003)(11063799006)(5023799004)(10067099003)(261022075727099003)(261021135927099003)(261022113327099003)(56012099006)(261021123027099003)(261009223027099003)(261022115727099003)(261021133027099003)(261026121527099003)(261028144727099003)(261102123227099003)(261026140227099003)(261026130827099003)(261021130227099003)(261026135527099003)(4143699003)(22082099003)(18002099003)(6133799003)(4133799003);DIR:OUT;SFP:1101;
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
 1wlr+YheYxURxwS4tXipXiUD0QWL+65TEhHYTzguGKIHrXNgc+HQT3SNgVMfjHYBgVYH6v/H4ja7xk3bMz6uAmFMYdlzxe1bzGngXiz8S8hLiyZxqsh3+2CDkb/GHztJtQNZexo75ThKirnQqUI9sdPFJyC2KJh8LLkBAG/qfAGaVl4LHPw+Ce+Jms4yHzE4ojRTMtxeETR0iPIxLDfxO3oU0ZLNCIDSp3zM8SpT2BUzDHbMA9CrmyerdT+VpwL6VXfhsrLcK3pDO2Mlar2Tpu8jX5UW9lPTIBR4XB9ZqWRTUEvuGIISiO52s0FHvzGtB88Mefj5yGgpE1l7alw6hA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: LV3PR06MB10076
X-Zscaler-Block: 0
X-EOPAttributedMessage: 0
X-MS-Exchange-Transport-CrossTenantHeadersStripped:
 CY5PEPF00000E7A.namprd02.prod.outlook.com
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id-Prvs:
	29274c7f-0e05-471a-0851-08df3c21b720
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|82310400026|14060799003|36860700016|1800799024|35042699022|23010399003|376014|18002099003|22082099003|4133799003|6133799003|10067099003|56012099006|5023799004|11063799006|4143699003|261026135527099003|261026130827099003|261026140227099003|261026121527099003|261102123227099003|261028144727099003|261022113327099003|261022115727099003|261021121427099003|261021123027099003|261021135927099003|261021130227099003|261021133027099003|261022105027099003|261009223027099003|261022075727099003;
X-Microsoft-Antispam-Message-Info:
	oz6+RHnDgWtdPBvPpGUZDg+lXPOMpbSt+Sv3JvYq1oA3vDFoPHNm9wdb2xXx6nBItnxdF+d/p1yj/ULYV72tABdOt7eMCSgaTDPIm9oSAlNVM+c0Lxz7aPYvOC1RdsqsVPc4PFIWbD2IPnilv/+Y8aWjb8zwSDPcberibRj1NYtYMf7HBDKg5iJ+y5e7bvfJyPCLb/DZi8evQzeL0HOcJ20TysetcnpkgU8MdKa54coBDcaAkdotUzU5tz3tiglmzQo8SSwnYr5mGX3YdCJVrmFKPUjV1eF1s0+U+i6MryfbsUKnkpCfgnvzY56oMrH1HXE1RF1tluQE9z2p3XwwAQiuRMVzYT4hYMTgKNkG/UmACNIXwb5wmq1grfVvH5XypwUmFR0d8o6rIOI5rt92jPg9+eulaM4pXfCGZndFq6UVbEm7xRceYoOUZhklChtw4kzSeqxmm0up4Mgt1h786O15l6yZC/UVH/v4knOp3uVHEJTkf1GEapb/jshuGQQv5ack0YKJKl4qp5/r14nYOmuNlBpCPlGI0wU8MpN7PdVGpJyErYHWUy/AqX6KbzEnQ2Kgua8gSkR7bH959Piw9J6dlTqxOId60n/3DpaTGV6bTGwXHDWMUaP19Csu2/7YWMp56HuSwt9MdHBg99eb8Q==
X-Forefront-Antispam-Report:
	CIP:136.226.142.114;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:sjc41b5.mail.zscalertwo.net;PTR:sjc41b5.mail.zscalertwo.net;CAT:NONE;SFS:(13230040)(82310400026)(14060799003)(36860700016)(1800799024)(35042699022)(23010399003)(376014)(18002099003)(22082099003)(4133799003)(6133799003)(10067099003)(56012099006)(5023799004)(11063799006)(4143699003)(261026135527099003)(261026130827099003)(261026140227099003)(261026121527099003)(261102123227099003)(261028144727099003)(261022113327099003)(261022115727099003)(261021121427099003)(261021123027099003)(261021135927099003)(261021130227099003)(261021133027099003)(261022105027099003)(261009223027099003)(261022075727099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	++qdY8eGuBxQ0fAsABRT+SGV8gtXM9i7du8hHpsyEadGewxBERuyO3sHkGs6MFmNLhr9GFCDpQpJb1racqDugc1GxquR0sn8oB/df3SgOslpa+GcbWKdMmpPcJugLebupfyMUw0fdpP3PocrF95c0kdSrb8Ep/tsM/UPIAzLLgXTjisomYMz7E66Qycr7NoxCsGAiWGxvgYUXNJUKe0zNtWrHQgy14MqDqOgGqhyZ7pbESWHjVVbBK3fJAFBDWhoUarbqM2/O1TjcZoSkCnGoraJNeRqQrr+ZMeu+TJAoDDHzrwSqgNTPdXrv3G+nWZ2+TLRsC2CQjAXSBJk8s8NGb92jpM1BtKDA17ZYEEoOqdb/SyYegC9VwAuOHVb2t+Agw/1YpAeyNJH1Q4BWlFYSBreVrRs1+iSkLOZfVdv5DoYw8YSs75wEkZ7Y0+KwGKq
X-Exchange-RoutingPolicyChecked:
	FlrvCMmzrYDCyj5cWCJfD7PefX0+0vpsUHijMIjtG7SQzdOZS4S/mhzXNjE+kSBlN9F6bvXaInDmwtkJtlReYWwr2XxGhjGC7xgIJBQWiyOvE4SLce1RlRDhDoSuAEiTrNBgefGk2Om8DJ/MClVHrMyvhVLYTE8QK/pNdLRKEn8hBZxgpTdfMtUCsDNaXL02D5n0QZMOkiieo6F/LRX4G8LtFob2jHK6+BBWCYL1CKa7YCJZ9Uk1uDtrcarxZ+kMuRXnzFua2RHsVJelLnDIh58/Re8L3MrhGNaxRckC5qcoeFwfkQpC1CNRA/swjLEdj1iW+Os3F9bewx3ALnIt8g==
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0:
	/NB60lqagdNiav41u7/nD8D3/DVZQp5AuMO5UAQEYeFn5hrOVWoTrVuR7vWxOiLDDJKFeKplt+huZgCcEmzUOCv/idHXePTpaiSZ2nNGz59yZKSRFKMAp8nKJrhwEK7aXcwrHwenilbjWCy845XwxDGgiGVVVW8/IQVpFnPzFXGuOw+vLE2sWlXHkde/IwasC4cJVKLaqEBbxwGSrKol32NV7lw9+f7csjmQMylAP56BHmVTIs8X5KR6JlLcPrxnaSLoV6/qlpbioqJ09WklNCeDVthMe0x8Q3lUsVRB/UzBUyrehtnKoISvEZZSkOjzKTmN4PYo5ArY7+fQJ7dWkRgV0m3Ki4L/54slHL4N2PDMhiKBBgBNiZ1nH+nhPI6W/dCLT0NGKbc2XGjuVMVBB3ltXYUKu+2fZIgHJpQ3pc+bNiUD3iNXnDEcgKkvI4VuOF6n/fnnqwQiuamzDT4Y8HCGBEIiLPFcNTwAUWSleJGtetgPQ0cCz2qAYMSKsKHvmFXzTzNBrGt4XKG86YBe2v7IPu42ZhiJJOv2/rBUcprUScbTHK+KVBLEXNQon38O7XYDemJDR2H9BviCj6d30Rmdz11r7NPHIV2d2w8aeD8Get6MCmCbxd5cucbzJd0N
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 06 Nov 2026 16:19:24.7998
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 73f7b18a-4b84-43eb-f59f-08df3c21b94a
X-MS-Exchange-CrossTenant-Id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=4b0911a0-929b-4715-944b-c03745165b3a;Ip=[136.226.142.114];Helo=[sjc41b5.mail.zscalertwo.net]
X-MS-Exchange-CrossTenant-AuthSource:
	CY5PEPF00000E7A.namprd02.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CY0PR06MB138629
X-Proofpoint-ORIG-GUID: wAgjpKRsriwiwRBiLJHHW4XCpx9_aOvp
X-Authority-Analysis: v=2.4 cv=Caqdd7rl c=1 sm=1 tr=0 ts=6aedfe18 cx=c_pps
 a=zTxK1Vn4TPWW1Y7kXDJIYQ==:117 a=ykUZaGlhMcAjilxMIcqxIg==:17
 a=6eWqkTHjU83fiwn7nKZWdM+Sl24=:19 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19
 a=xqWC_Br6kY4A:10 a=8nJEP1OIZ-IA:10 a=zJRp6_cAMcgA:10 a=GWG4Yq0kndkA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=1lWG0UuNQvn8UhQ8Wh4S:22 a=X7e-fZ-CKB32rjcIpVUG:22
 a=VwQbUJbxAAAA:8 a=RaCL_buRAAAA:8 a=mEza3si5AAAA:8 a=25ivYq9jVMRdNtMSL9oA:9
 a=wPNLvfGTeEIA:10 a=D8jZDuKwTAu7wmFJcm7v:22 a=rjRlSLlayDNRPJ6elN85:22
X-Proofpoint-GUID: wAgjpKRsriwiwRBiLJHHW4XCpx9_aOvp
X-Proofpoint-Spam-Info: AW1haW4tMjYxMTA2MDA2NCBTYWx0ZWRfX3SG1ugUOeg+/
 xXYHYbNDbrGsyAToAW2bJbxw4zJfBWT2Mx5rqUynUtht+drpfMrEe9A5BGUhpJ+Ax1lH8JUsUlS
 onncn+PlwRK0VENHhL22ZWN04zSqFXU=
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYxMTA2MDA2NCBTYWx0ZWRfX9z+cP0OgIrjr
 uKTOa5FA7m102yoI1upgzWQ2TTt5+A8DKGgFroPTe9H96+dfY9Rf+8CGDTpG5pWRvgrz2gh2P0M
 RVCcsbUV6DqLlAM68J+6mrjHd08kzcJIeVYOam+gj862wUazmgfkLlI1XJN+3Hlm5NP7yHsw+Np
 PgLEep41FzAZNUHqlQhsNhlMtSE1p9xov9zxzGQv+PwGJlYkMcnrrUPTSZH7/IlsBjPtGT0SFX2
 RmdkUcWrIGIlsNzuyfb+1siamMXjwmUEDfOg44qjYfUOYNRv1TYGIkAfWaipHS3hNsODMhuTroK
 0fsfjt8X3SzOX8IsJNHtbvvNAEJ1en8H6DcgH9vZ5PEaFkssZCRM73RG6T9vvOovOj4AeUztAmA
 PrqxkvoNd1xoyJvzmWliOrUxOBQQe9W3u0Yfo8jAYzf/sVV305HkbK5H6Cx75efdDWQIU5xutlZ
 21E5N9l6lt6ITOogFoA==
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.138,FMLib:17.12.100.49
 definitions=2026-11-06_05,2026-11-06_01,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 suspectscore=0 spamscore=0 bulkscore=0 impostorscore=0 malwarescore=0
 adultscore=0 clxscore=1015 priorityscore=1501 phishscore=0 lowpriorityscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2611040001 definitions=main-2611060064

Hello Chuck,=0A=
=0A=
I will take a look at Tim's patch.=0A=
=0A=
Have a great weekend and thank you.=0A=
=0A=
--Jorge=0A=
=0A=
________________________________________=0A=
From: Chuck Lever <cel@kernel.org>=0A=
Sent: Friday, November 6, 2026 8:07 AM=0A=
To: Jorge Mora=0A=
Cc: linux-nfs@vger.kernel.org; trondmy@kernel.org; anna@kernel.org; Bhargav=
a, Rakesh; Kumar, Mohit; tmenninger@everpuredata.com=0A=
Subject: Re: [PATCH v2] xprtrdma: fix race between frwr_unmap_sync() and tr=
ansport disconnect=0A=
=0A=
EXTERNAL EMAIL - USE CAUTION when clicking links or attachments=0A=
=0A=
=0A=
=0A=
=0A=
On 11/5/26 6:21 PM, Jorge Mora wrote:=0A=
> frwr_unmap_sync() is called from xprt_rdma_free() via ->buf_free, which=
=0A=
> xprt_release() invokes without holding the transport send lock and=0A=
> without XPRT_LOCKED. rpcrdma_xprt_disconnect() runs from xprt_autoclose()=
=0A=
> under XPRT_LOCKED and, after draining the QP, resets every rpcrdma_req=0A=
> (rpcrdma_reqs_reset) and destroys every MR (rpcrdma_mrs_destroy). Nothing=
=0A=
> orders the two, so both can walk and list_del() the same req's=0A=
> rl_registered list and the same MRs.=0A=
=0A=
Thanks for the vmcore analysis, and for the detail about the=0A=
destroy_mkey stall widening the window. That explains why the=0A=
list corruption is what shows up on your systems.=0A=
=0A=
Tim Menninger has been working the same race from the other=0A=
symptom, a hung task in frwr_unmap_sync() when the LOCAL_INV chain=0A=
is posted after the QP drain. His v5 went out this morning:=0A=
=0A=
  https://urldefense.com/v3/__https://lore.kernel.org/linux-nfs/20261106142=
039.1066437-1-tmenninger@everpuredata.com/__;!!Nhn8V6BzJA!VKRwv5y7IYIdxq4TX=
POHCY6wtyQ49nOa9F4m192VwlYSRqCQXJxF5lOKHGGCcTmvecPKnNR6x52l$=0A=
=0A=
> + - If rb_closing is set, frwr_unmap_sync() returns and leaves the MRs on=
=0A=
> +   rl_registered. rb_closing is only set after rdma_disconnect(), when=
=0A=
> +   the QP is in the error state and the peer cannot reach the MRs;=0A=
> +   rpcrdma_reqs_reset() then releases them.=0A=
=0A=
When frwr_unmap_sync() returns here, xprt_rdma_free() returns and=0A=
the RPC's pages go back to the consumer while the MRs are still=0A=
DMA-mapped. frwr_mr_unmap() does not run until rpcrdma_req_reset()=0A=
reaches that req. On a platform with swiotlb or a bounce-buffering=0A=
IOMMU, the deferred dma_unmap_sg() for a FROM_DEVICE mapping copies=0A=
the bounce buffer into a page that may already be freed and reused.=0A=
Tim's version always unmaps before frwr_unmap_sync() returns,=0A=
either in the LOCAL_INV completion handler or because the reset=0A=
already ran.=0A=
=0A=
=0A=
> +     /* frwr_unmap_sync() runs without the transport send lock.=0A=
> +      * Callers that claimed MRs before rb_closing was set may=0A=
> +      * still be posting or waiting on LOCAL_INV Work Requests.=0A=
> +      * Those complete (or flush) because the QP has been=0A=
> +      * drained, but the callers still reference the MRs and the=0A=
> +      * ep, so wait for them before anything is released.=0A=
> +      */=0A=
> +     wait_event(buf->rb_unmap_wq, !READ_ONCE(buf->rb_unmap_users));=0A=
=0A=
A caller that bumped rb_unmap_users just before rb_closing was set=0A=
can still reach ib_post_send() after rpcrdma_xprt_drain() has=0A=
returned. The comment relies on the provider flushing a WR posted=0A=
to an error-state QP. Tim's report is that no CQE arrived in that=0A=
case on his hardware. I can't tell from here which providers=0A=
guarantee the flush, but if his observation holds, this patch=0A=
leaves that hang in place and adds a second waiter: disconnect now=0A=
sleeps in wait_event() for the stuck caller, so the autoclose work=0A=
and the whole transport stop with it.=0A=
=0A=
Tim's rwsem makes the post happen before the drain or not at all,=0A=
which removes the dependence on provider behavior. The counter,=0A=
flag, and waitqueue here are doing the same job as his rwsem by=0A=
hand, with that one ordering missing.=0A=
=0A=
Would you be able to run Tim's v5 against your reproducer? If it=0A=
holds up, a Tested-by from NetApp, plus the vmcore details added=0A=
to his patch description, would make a stronger single submission=0A=
than either patch alone.=0A=
=0A=
I'm a reviewer here, not the maintainer, so the final call on=0A=
which fix goes in is Anna's and Trond's. Tim's looks a little=0A=
more complete. Sorry I didn't realize earlier that both of you=0A=
were working the same issue.=0A=
=0A=
=0A=
--=0A=
Chuck Lever (Come to NFS bake-a-thon! https://urldefense.com/v3/__https://n=
fsv4bat.org__;!!Nhn8V6BzJA!VKRwv5y7IYIdxq4TXPOHCY6wtyQ49nOa9F4m192VwlYSRqCQ=
XJxF5lOKHGGCcTmvecPKnI-QvuUw$ )=0A=
=0A=
