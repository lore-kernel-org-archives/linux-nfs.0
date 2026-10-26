Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=2 smtp.remote-ip=67.231.157.221
ARC-Seal: i=3; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793029614;
	b=bOzDaFBG2cSOUphP1N8b38BGUooIGKdAimhWqZguBDCi4l9ZLy1po0Dl6j0LXiqH6ARb
	 T61PjSi9inhtv5zIwaioR/7Iv1H678QmVNc/73A+U3s6/jYB/HfDHhHPKFYJZaNld+XfY
	 7jArJX1cBpH+apUdxsOh9JOK1qjuyXxRT2Qxd6COuAPdwMhUywpR52McuVaxHHsuM57MB
	 +aGr/IHK0TQxzuBzfykxNoDFuKAFulzQ5FmZRZXdzclvI9BXCY5Hii9oFXWwjV2v25YHS
	 faAeCbaC0BxKdDSko8Mzx2fTIAQCJ+UhvCv8fdXXtuSZ4B83epZK/3x5tdXczrBWQAA==
ARC-Message-Signature: i=3; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793029614;
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
	 X-MS-Exchange-Transport-CrossTenantHeadersStamped:X-Proofpoint-GUID:
	 X-Proofpoint-ORIG-GUID:X-Proofpoint-Spam-Details-Enc:
	 X-Authority-Analysis:X-Proofpoint-Spam-Info:
	 X-Proofpoint-Virus-Version:X-Proofpoint-Spam-Details;
	bh=RPIxL9hht7VCHkbuyQ1bFByTUXGNFlzn159sdWhq19A=;
	b=v6RtGTEWU8afONyjwVPAG7WA58ioAHPler/OAszJ4j7vkaAXNOCrkxZdaqVHlHYWMtmE
	 /GyQiMXEWvBNvii3CkQkvgn1UXDyeKQwBCCebnp0QrhS7yxnZyYvO7YBgxUl/xSA9eRYA
	 6V3eqrOVUV10feBO9/OF5pmdBGKgnJxww7rBWaKRD0ZPpMXzBEe+YAdWopp4JWM0ZlizW
	 v9ong+bkd8wpS46axtJDCyOEncKWG1WLr5a+bPV6WqqLYc4P5DHO0cjzJeQoAZnoD7VD5
	 jdppH6zNrevTBEyGBJ6FEnPWTEnJZKs6vN7OQ5tCglndHRsCFMw5zB8S84qq7h/ISaw==
ARC-Authentication-Results: i=3; smtp.subspace.kernel.org; 
	dmarc=pass header.from=netapp.com;
	spf=pass smtp.mailfrom=netapp.com;
	dkim=pass header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=pps1 header.b=Ut7TAp+M;
	dkim=pass header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=selector1 header.b=AJOMFj38;
	dkim=pass header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=selector1 header.b=AJOMFj38;
	arc=pass header.oldest-pass=2 smtp.remote-ip=67.231.157.221
Received: from mx0b-003fbd02.pphosted.com (mx0b-003fbd02.pphosted.com [67.231.157.221])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C4A3F606A31B
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 15:46:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C4A3F606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=netapp.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netapp.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=pps1 header.b=Ut7TAp+M;
	dkim=pass (2048-bit key, unprotected) header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=selector1 header.b=AJOMFj38;
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=selector1 header.b=AJOMFj38
Received: from pps.filterd (m0412384.ppops.net [127.0.0.1])
	by mx0b-003fbd02.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 69QEum8w2977523;
	Mon, 26 Oct 2026 15:46:39 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=pps1; bh=RPIxL
	9hht7VCHkbuyQ1bFByTUXGNFlzn159sdWhq19A=; b=Ut7TAp+Me7AZJBIVHyhkx
	QyXg35+EkP4HKaXWuj9siN6CvF4RossrDJdk7ynq8QoBDbHDqEZy2vUd8/L8/iST
	Yqwkdt2J1gNGqVsGg1CO/HfduEXxrW9747JYQKqP0+Jvn1WF8JvzZ0cSJiT80mu7
	oBGNnzI4RDP6FQoENt1BorzzrB8HYjTDOyYkp2oFaghAFwnuuds1VI87rDfHRk9N
	eQ9Vztcm3+WKE4RVR7ApfXmCi49uv44f258sAgfs4ADqeWhP3Bk4daby6oblpR4M
	ZWOcDBp/NtwSi/OOept8wyHI5DbvZsG1VKnwCAR1lhs9hTU6irdNLI99zA3pZbc9
	w==
Received: from dm5pr21cu001.outbound.protection.outlook.com (mail-centralusazon11011008.outbound.protection.outlook.com [52.101.62.8])
	by mx0b-003fbd02.pphosted.com (PPS) with ESMTPS id 4hha0j4xq7-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Mon, 26 Oct 2026 15:46:39 +0000 (GMT)
ARC-Seal: i=2; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=pass;
 b=ZWPX6AoDgGQIxfbbldQqpWvF1DzicjCd1aJ/CatiZLrvWxEukj9qKBrrLGqikGvRew+xMT1KrJ8vtdrlq+GhFE2N8C0cZFG8ZLNFDWyNZ2WtEgvQNsHibTaLSy+8s08RDPCWRAumkmiBokTriT+65K8KAjljpOk8lnqmVATQL/3FlagZBcDN6Ktdl9UGU6dYQulKZvsP3wvegcQx0oVykrLKGkEaKIEBOxXOQw3PNx3rPFogG8K6lFLVJaTc4ed6ZEPg5uuDt4LohXO8ggGuBmf4EBnv7yopTisV5fceaEDbKH51OrIeLkGf0LgK5QKawZv6j4dBmAPssIdWwqD1mw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=RPIxL9hht7VCHkbuyQ1bFByTUXGNFlzn159sdWhq19A=;
 b=MQnElved/mOPh6n7arNv9ILM57szPizLx9ZNJgKM3kzvwKP9hbxs7eNotsVTIOKIviZwlHyFLj647FmTosmwt2Iz6na6gHI22bHKf5CSXh8oY4BRiXvs8vj4dYwoigO34JBKsDADbZe2oUlKoBVaj93i01901CAsFwuhhGfRqz18AXJU9tkelsAkdHfiVyjGUVaNJclXqvpzFu3JxNyLjO9sEuA1y56bK8SQKZ7nANM+lUjR94aQQSCw5tRx/wSG9APfEAElg1AknNXGAHrknQeYQ/BseJGINdUyAkSqBSodu6ywGW6+l3AD1l5zgzAcqFJvxJuyk0lmYtWLNwKy1w==
ARC-Authentication-Results: i=2; mx.microsoft.com 1; spf=fail (sender ip is
 136.226.152.54) smtp.rcpttodomain=kernel.org smtp.mailfrom=netapp.com;
 dmarc=pass (p=reject sp=reject pct=100) action=none header.from=netapp.com;
 dkim=pass (signature was verified) header.d=netapp.com; arc=pass (0 oda=1
 ltdi=1 spf=[1,1,smtp.mailfrom=netapp.com] dkim=[1,1,header.d=netapp.com]
 dmarc=[1,1,header.from=netapp.com])
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=RPIxL9hht7VCHkbuyQ1bFByTUXGNFlzn159sdWhq19A=;
 b=AJOMFj38+xyb1m85mH2pJ8y1JDGH/VIBPvw57AESgD8ooaXrb88sfYEL/1KtIxBEAJT1K/B8SBfvCO9uNeVRezu8Vud/FSW5gAhzttDYor8jVYqo2lI3/QG/AD4Jm5cgeQexdRpJzVmJVoP1TkIEIH5GLnzd9Nf9uFhoA6dPWjFFQd+qEXDGvAgUg5DkrZA80RLbnF3jDAexBeb04WP3+AXfuWNO161jo4p4wKHxjzbVktJz8NUIL1IbSevsJ8KFx7LIeKXzK8o6yEFSqRhWy4uztAaj7a9HCzK1N3ItMtlH72FolX1VkPLYrJRvSNfJKPSuD8tpDvAET+kgHwh9Ig==
Received: from DS7PR05CA0024.namprd05.prod.outlook.com (2603:10b6:5:3b9::29)
 by CH3PPF555A01F5A.namprd06.prod.outlook.com (2603:10b6:61f:fc00::426) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.546.22; Mon, 26 Oct
 2026 15:46:29 +0000
Received: from CH2PEPF000166BE.namprd04.prod.outlook.com
 (2603:10b6:5:3b9:cafe::81) by DS7PR05CA0024.outlook.office365.com
 (2603:10b6:5:3b9::29) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.569.7 via Frontend Transport; Mon, 26
 Oct 2026 15:46:28 +0000
X-MS-Exchange-Authentication-Results: spf=fail (sender IP is 136.226.152.54)
 smtp.mailfrom=netapp.com; dkim=pass (signature was verified)
 header.d=netapp.com;dmarc=pass action=none header.from=netapp.com;
Received-SPF: Fail (protection.outlook.com: domain of netapp.com does not
 designate 136.226.152.54 as permitted sender)
 receiver=protection.outlook.com; client-ip=136.226.152.54;
 helo=was11a2.mail.zscalertwo.net;
Received: from was11a2.mail.zscalertwo.net (136.226.152.54) by
 CH2PEPF000166BE.mail.protection.outlook.com (10.167.252.8) with Microsoft
 SMTP Server (version=TLS1_3, cipher=TLS_AES_256_GCM_SHA384) id 15.21.569.4
 via Frontend Transport; Mon, 26 Oct 2026 15:46:28 +0000
Received: from ch4pr07cu001.outbound.protection.outlook.com ([40.93.20.99])
	by was11a2.mail.zscalertwo.net ([136.226.152.43])
	with ESMTPS id 6ADF75D408F40000;
	Mon, 26 Oct 2026 11:46:28 -0400
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=t7wV9n/pE1xCn8VXB3b1QMgXZ6soRKfMAU7TKEXjKJhOiX338xE0dySIVpDCTUHSCFgaS4ojQX2MIT5mUXzD/5wd/i7llREMiYePUcsFcQPQ5tGqLzqGySwS8QLxWwNt8uT2eTLtOred7lS6pFNj4q2Ze8yC9lqZ/JryAFjuLRe/IoQiZPUBonEwLGoA3bXlf5OIco83R5afYiVgaa/RcDaeaFSW0ey8z6Auwd9YTholX468uXBVBFPMHFD7/X/vvy+voz5h5xZk6rZJkYYoygyUPlC8IbDDcqbfdmsvnPpl++Qe6k1EuwKEt/UqQBPUBuq+X5nIwwadpElpfny7tA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=RPIxL9hht7VCHkbuyQ1bFByTUXGNFlzn159sdWhq19A=;
 b=msCtxWeQFtrGV12S+Jc5V/Cz6HaVfg15Fy13feikaaBRX2teKXN8RzZiIaTZqSVgPxu7Kv17A8M2608X9MAC2+B6HYCVVArNa4hMVeWEv0eEeKik+o+J7xOMPjizCIOJdA3AnSHW2qZvmQeqD42tTnv+fikkAg4fwyFDEoKpNkxgRZ/YUwmtEoEeDjWbYezLQWHhkcU9ZEwUTHXEXuJ2lwCjpHs++aZstSjXhvKT7E3aajueQ2JRG7J+OjRpXgL2OTzX2APPzDv0d6nifZeqQsQoYSTQlx/BMtCgSE29+g2qpNGZqbZPNLFTH9iE2YzfMm7GWMT0N2P8HPO8YShAmA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=netapp.com; dmarc=pass action=none header.from=netapp.com;
 dkim=pass header.d=netapp.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=RPIxL9hht7VCHkbuyQ1bFByTUXGNFlzn159sdWhq19A=;
 b=AJOMFj38+xyb1m85mH2pJ8y1JDGH/VIBPvw57AESgD8ooaXrb88sfYEL/1KtIxBEAJT1K/B8SBfvCO9uNeVRezu8Vud/FSW5gAhzttDYor8jVYqo2lI3/QG/AD4Jm5cgeQexdRpJzVmJVoP1TkIEIH5GLnzd9Nf9uFhoA6dPWjFFQd+qEXDGvAgUg5DkrZA80RLbnF3jDAexBeb04WP3+AXfuWNO161jo4p4wKHxjzbVktJz8NUIL1IbSevsJ8KFx7LIeKXzK8o6yEFSqRhWy4uztAaj7a9HCzK1N3ItMtlH72FolX1VkPLYrJRvSNfJKPSuD8tpDvAET+kgHwh9Ig==
Received: from SA1PR06MB11353.namprd06.prod.outlook.com
 (2603:10b6:806:4a2::17) by SA2PR06MB7516.namprd06.prod.outlook.com
 (2603:10b6:806:14c::14) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.546.22; Mon, 26 Oct
 2026 15:46:26 +0000
Received: from SA1PR06MB11353.namprd06.prod.outlook.com
 ([fe80::ff:880:c010:68bf]) by SA1PR06MB11353.namprd06.prod.outlook.com
 ([fe80::ff:880:c010:68bf%6]) with mapi id 15.21.0546.021; Mon, 26 Oct 2026
 15:46:26 +0000
From: "Mora, Jorge" <Jorge.Mora@netapp.com>
To: Chuck Lever <cel@kernel.org>, Jorge Mora <jmora1300@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "trondmy@kernel.org" <trondmy@kernel.org>,
        "anna@kernel.org"
	<anna@kernel.org>,
        "Bhargava, Rakesh" <Rakesh.Bhargava@netapp.com>,
        "Kumar,
 Mohit" <Mohit.Kumar@netapp.com>
Subject: Re: [PATCH] xprtrdma: fix race between frwr_unmap_sync() and
 transport disconnect
Thread-Topic: [PATCH] xprtrdma: fix race between frwr_unmap_sync() and
 transport disconnect
Thread-Index: AQHdY9dCQIpQCgW3dEW+XeuXo9/TPLcNJjiAgALTptk=
Date: Mon, 26 Oct 2026 15:46:26 +0000
Message-ID:
 <SA1PR06MB1135363CDB9980FE0C9FC0E68E1612@SA1PR06MB11353.namprd06.prod.outlook.com>
References: <20261024164633.256458-1-mora@netapp.com>
 <425e2489-72a0-49c6-8a69-21069a878aa4@slotpi15m67>
In-Reply-To: <425e2489-72a0-49c6-8a69-21069a878aa4@slotpi15m67>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels:
Authentication-Results-Original: mx.microsoft.com 1; dkim=none (message not
 signed) header.d=none;dmarc=none action=none header.from=netapp.com;
x-ms-traffictypediagnostic:
	SA1PR06MB11353:EE_|SA2PR06MB7516:EE_|CH2PEPF000166BE:EE_|CH3PPF555A01F5A:EE_
X-MS-Office365-Filtering-Correlation-Id: c673a5e9-785e-4756-6565-08df33784cc0
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam-Untrusted:
 BCL:0;ARA:13230040|366016|1800799024|376014|23010399003|261026135527099003|38070700021|261026140227099003|261026130827099003|4143699003|11063799006|56012099006|261021135927099003|261022113327099003|261022075727099003|261021130227099003|261022105027099003|261009223027099003|261021133027099003|261021123027099003|261022115727099003|261021121427099003|10067099003|261026121527099003|22082099003|18002099003|4133799003;
X-Microsoft-Antispam-Message-Info-Original:
 /U8v3HA5RE458lBYLk63JvLalpGKx3sUSTfI+w8CiDFXZae3gVtcVAMzJXVrUvhg3O+rxvHzsl90r18NMbHmj8iSGcJDW3qa+5ewnv8a6H5Gj3qyANaWKygmfYKu8E6YjX5n9ADuWlGc6XMGE7JP17MEooSGneO6x9xbo5GEy3/OqXTYhZl23FvW+Zff6J5db+k2+K6FamFdFmhnbkThV3DAmoES1tmSqj7mw9x+Xco6Ei/QyVnDReuvjuhkb2Ty8ukbItWrWoPQZG7GudYyFQEh5rTgk5zHLfJHhGN2b/tJlP1inS+jG/NiMGpUEMVy12YPYK8bWf/3U1kflvXpRwSrJdFTxBcqcA8rsUwc0NsLE5B8T5Y4z3+kEAWbVY9whOtHtJXLKQWLI0ZOBD8+KKBnDyr/QqQat52Qndd5zNdna9LIsAjq53TT1ESpdFZwNPPTiwpFc2fSkXnhjO/uUQS1QQDq8LtgNpBoQDam5+PqQ55H9UxaISq6oA1dNvyXn58KIunnZ87qmOTu8U+4eMoSXvlDx2J59D8WEkh2u+j4qy+hOZfbAAXXHHZxSuNNEWJMKSi7q2O0LtTOkGX9lDhYel7E2tWOmbwOKRQS6NBMtlFLE/caiAVNSTEytxuWG3R5tBS0afwC64z5a9QLohHklPkjsSdamvvesQTMo4c=
X-Forefront-Antispam-Report-Untrusted:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:SA1PR06MB11353.namprd06.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(366016)(1800799024)(376014)(23010399003)(261026135527099003)(38070700021)(261026140227099003)(261026130827099003)(4143699003)(11063799006)(56012099006)(261021135927099003)(261022113327099003)(261022075727099003)(261021130227099003)(261022105027099003)(261009223027099003)(261021133027099003)(261021123027099003)(261022115727099003)(261021121427099003)(10067099003)(261026121527099003)(22082099003)(18002099003)(4133799003);DIR:OUT;SFP:1101;
Content-Type: text/plain; charset="Windows-1252"
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
 rDZ7M5YDujbwXxocPsSLOmyzpDscSRZrWuoj0xPuKu3MPNqedujGOEwYVAbPLw5LUSO10toyalj7lPXmm8FBHQt+RDesaCLiKX5e7FDua+no8ksgrq8POunfJFW5F5wJExMvQ9TXgbarvRD2KFf8tdxRgiz2F2O44DI1IRc5NV126uJPt+2lsZTV3n7Na1USYNiQSjpXkb/A6DvFNkYwL/ITIFZr3JT1+V8qQdBpTz0u6XJRH+zLIKmCRWNodLaEofKRp/J5lhKKlHdmZgERrVOQAEh2SGyOWcU+9/S0xKQrt0Ff5+yqP/cvWuxtAlmEvNk1nAA9ZagseI9tEs+zWQ==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SA2PR06MB7516
X-Zscaler-Block: 0
X-EOPAttributedMessage: 0
X-MS-Exchange-Transport-CrossTenantHeadersStripped:
 CH2PEPF000166BE.namprd04.prod.outlook.com
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id-Prvs:
	32c776c8-e4dc-4b27-a076-08df33784b32
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|14060799003|23010399003|36860700016|1800799024|82310400026|35042699022|376014|261009223027099003|261022105027099003|261021130227099003|261021133027099003|261022113327099003|261022075727099003|261021121427099003|261021135927099003|261021123027099003|261022115727099003|10067099003|56012099006|261026135527099003|261026140227099003|4133799003|261026130827099003|22082099003|18002099003|261026121527099003|11063799006|4143699003;
X-Microsoft-Antispam-Message-Info:
	L42kjAjRAmCOCopPId5do3Ap4tShY3YDzplklV7uRbqFhpOK9iM3+WicwsxEQbOfk/GqWYO0Lva/HmNwqe2nlhmzjvDWGXtbBQEgnxcFsneU3TxTRMMULxBDrKVloyH67m2r2K8lkJ6EIu9r7P6mjDqG57TC3VsoXKZoYffz3868yPeGsBK7kLFugZaxcrURF1hR8+KPj4oMsEo3XRa8dcZeuTDdOOVZwvAQ4rdHJETVBOmVmKPcRZ8p1rVYlguXsNdKl9z3Ywq6OsnPWX/BhuRjsCcVwdz6zzQF7YQArktVF2+C9HLHT0oYhDhpDkshcysu0TPLqzHhTogmKUetnWHI3NFXFx3yMl3VZl6de73+vWVbpknOg6lioRAhojWglxtcUp9rPEVYUBosO2BYzoIzFoSoVCyPKKT/9Qt2UVNZSZbIE9cp5kTPTeX7Cw0IIWdVSVo6g2XEBPweb9LYoypyYkf9Xv0DGUnay6t4HBlKMSqV76Fmp0jFRcKkYBAzy7q6x7akrnvEZz8/uSUVPyMJ7DBAhawGUeV7uOhNPN1vgEGnoqAef3OtqAjLy/msqFutVFt7tMsrjYqDdqVFKiuUuEVo73Qsl6z606J1NeXkEnSTSZB+tBl9EsmW0Rd9HfvTzSTgNnzggKZBneTxtg==
X-Forefront-Antispam-Report:
	CIP:136.226.152.54;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:was11a2.mail.zscalertwo.net;PTR:was11a2.mail.zscalertwo.net;CAT:NONE;SFS:(13230040)(14060799003)(23010399003)(36860700016)(1800799024)(82310400026)(35042699022)(376014)(261009223027099003)(261022105027099003)(261021130227099003)(261021133027099003)(261022113327099003)(261022075727099003)(261021121427099003)(261021135927099003)(261021123027099003)(261022115727099003)(10067099003)(56012099006)(261026135527099003)(261026140227099003)(4133799003)(261026130827099003)(22082099003)(18002099003)(261026121527099003)(11063799006)(4143699003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	kraEL/T3UPlgr1vW6I97Cc/4lHOEbQer0F1+yFr72KIpDzaOgPSZSASVnkFqlMbdaX7knOxekNpwJENUK2W/8Mdl+lSoNTDS0QBEEeWJC1dnKxTki4vYIh9KIeAh7U4S1gJxD5FbqUI7M3gG7k785wBpoespMWp1xr6C/D6gKkCkGlLX+CSOrzH9auaaemqUM66tlShSUeUSuYjuIYtplOlXjJrIHopEArm0ccNOq17aZv2Ee0KUfrT+mRUidzKNVQ0CEyM4RmrWZ08N+My1Eiq0lzPJroNx2/YC09vepZBcg7iDQivU78/5qFbF35C8KJOdEap0BhCdEikDR2m9K4tkQZRUwWfcQ+e+CcHkFTbCzDVVmtkMG7VNsit8FnniEuJK0X9rD84vkQ70DvJgVVMJbzzDHuM9yg4vBTVyKbUN+HNiuqalKnSa68FLTywP
X-Exchange-RoutingPolicyChecked:
	S6zaS7W2DxsKC8HwVrK2OE5KGHgYqdh8wao2ebqfUYEvCFW5cVnLfjf+0+lKCMoU4sLRK3Si7QcOQYnMfREtfQ8HGk/lqnLnodW56pRZTv8YiwOj2zqfTiU4PEbKgjaffdhAzFaQ6DGRy324ge7Fe9naj05YypU1eRMgTz/X/D7hDZ02M/4+xcHDTRHCFwQ8Epu1ARPlVFn0G1AG1aRIuSmyBrs6lUBWZEXfXlLndiTOMaHjAB3uQOBN8qC0Q/d4nnH+GboKKC1U/Ia0nFTvW7XgjyIKhgRvPeXVNz68oKgyEce1PsmAMLMUo6m49E4WDCVVR9BwVq4okZ+1d+IzqQ==
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0:
	zMyQ4/CnM11N/o8fPifpCg9dHJTBxvlNPMcdMilnzKYNJui4w6GGYoA2IUOVxFrrX8rhHZwl91Ie908oteWOearP2+bhqU8djFDAaEAgBDhtjJIXmnYEW1QCA2tfM+69QhWmX3aVCqChRp/QhoSwf1gwHcso0BonHwsA7w8+vIx3zcFBw/kiolNg6v795uXd5up239AdkyH6bgMSxjcCuolwNg2JW7Wrj4ggzoCarHz7gzO5Q8E8IalvHY36hp7fLOXUIKIqYu9HvoJ1XnZOtxRgEUUKAjJcL5pJIRRf5pu7DNDMzuf0Kcghmdx12Mgl87zXLBZvie/pQRW3aEl1LYbujuyTC8y5ihyro2TH7VKkzkVBZnFiXb/9gi9C1a2LisEE8a7dtIo5oWUmgU7FPsvJ8YTZX6d52N2Pv9FMRGJmGE5v4LB6fxUIe2XjhlrQ3R/RVe+/znb84Z6yxQf854dMpKI2smE7MNWcMHji4vwUR2Y/IJE2D+8/QC6YUBrC/ot1+Ov030m1o6dnLFHJzjAG1c95hP2Wh5ZxkHE8OR+YtDRVL96yCBOh/z2/+h0JeYN68/Nfre1GN4KhmHMxMG9xLPIQdlNxl19rWE8iDgG1Ky3gk0BuhhTsCaiUVQzN
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 26 Oct 2026 15:46:28.4622
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: c673a5e9-785e-4756-6565-08df33784cc0
X-MS-Exchange-CrossTenant-Id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=4b0911a0-929b-4715-944b-c03745165b3a;Ip=[136.226.152.54];Helo=[was11a2.mail.zscalertwo.net]
X-MS-Exchange-CrossTenant-AuthSource:
	CH2PEPF000166BE.namprd04.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CH3PPF555A01F5A
X-Proofpoint-GUID: 1sN3DgorMNK_ha1f8MWBRxE_zC4GK3O1
X-Proofpoint-ORIG-GUID: 1sN3DgorMNK_ha1f8MWBRxE_zC4GK3O1
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYxMDI2MDA2MiBTYWx0ZWRfX+YXXEzbH12wj
 JbjNftsSMpCRuNfAaoNecmx0UWJwpFY3XIjVTiUuzQvOJM43FyJvgAy6nJcjX/1zU/+R0NWPcU8
 U2LQIKSnZj8zYvmcfhUbN748bdzl2MrRadPMzkwMgugCh3Ma0kq8vSsT0hc9dzYGvFUbNi8Q6jt
 d+Wlmfcx/tegwjnaTOu+I3Lq9sYYmC5KbzniQAz8zmj2en5yBqpKZrWMR7CYS1R/rhohc/yx7Az
 csQb5ww1rOpBbQv+LH92Vv63+muiQc6UMicra6r8c2CLkwf32ubkOfXGeEjNmGuhnLNzn4Y6Y8d
 2J0EQobfjEq0cDVESfMrfDicHMxnS3HBnlHnL1NzPbDzYDyol0SNFL3tE8kAW7LzbhcNVCgRLqq
 n/7XZxER7nHI2u/fN+QdWy51wD4VIbu3MbY8xsA1Ra8q4u43AV6Ht72yBDfYvm+y474601h/MQI
 /iyCGSF+3mgYiYjw9HQ==
X-Authority-Analysis: v=2.4 cv=JuRkP84C c=1 sm=1 tr=0 ts=6adf75df cx=c_pps
 a=fYaSdR3m0whpxnlOBVIaHQ==:117 a=/R7wsi6P8MDabg3Hr5WfTA==:17
 a=6eWqkTHjU83fiwn7nKZWdM+Sl24=:19 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19
 a=xqWC_Br6kY4A:10 a=N659UExz7-8A:10 a=660iZSQnnn4A:10 a=GWG4Yq0kndkA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=1lWG0UuNQvn8UhQ8Wh4S:22 a=aI3CQ4rmUk7SosRCZclN:22
 a=mEza3si5AAAA:8 a=VwQbUJbxAAAA:8 a=unZ8_Y6l9Bx7PXjlAroA:9 a=pILNOxqGKmIA:10
 a=rjRlSLlayDNRPJ6elN85:22
X-Proofpoint-Spam-Info: AW1haW4tMjYxMDI2MDA2MiBTYWx0ZWRfXzj/hNwW7lI9J
 7vBoSVIzoqPwW+8DZ8bjTet7gLrYVFLef+QgDjmjqhoDwfMNmx0QMO96WYcHXGfJCAVz1NUBflX
 9bBfq/DB7IW+zrjIFaA20/RGcU9lk44=
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.138,FMLib:17.12.100.49
 definitions=2026-10-26_03,2026-10-21_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 suspectscore=0 phishscore=0 clxscore=1015 spamscore=0 priorityscore=1501
 lowpriorityscore=0 malwarescore=0 impostorscore=0 adultscore=0 bulkscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2610190000 definitions=main-2610260062

Thank you Chuck.=0A=
=0A=
I=92ll work on version 2 and send it over as soon as it=92s tested and read=
y.=0A=
=0A=
=0A=
--Jorge=0A=
=0A=
________________________________________=0A=
From: Chuck Lever <cel@kernel.org>=0A=
Sent: Saturday, October 24, 2026 2:33 PM=0A=
To: Jorge Mora=0A=
Cc: linux-nfs@vger.kernel.org; trondmy@kernel.org; anna@kernel.org; Bhargav=
a, Rakesh; Kumar, Mohit; Mora, Jorge=0A=
Subject: Re: [PATCH] xprtrdma: fix race between frwr_unmap_sync() and trans=
port disconnect=0A=
=0A=
EXTERNAL EMAIL - USE CAUTION when clicking links or attachments=0A=
=0A=
=0A=
=0A=
=0A=
On Sat, Oct 24, 2026, at 12:46 PM, Jorge Mora wrote:=0A=
> Other consequences of the same race are a use of ep after=0A=
> rpcrdma_ep_put() frees it, and rpcrdma_flush_disconnect() dereferencing=
=0A=
> r_xprt->rx_ep after disconnect cleared it.=0A=
=0A=
...=0A=
=0A=
>  - rpcrdma_xprt_disconnect() sets rb_closing after rdma_disconnect(),=0A=
>    waits for rb_unmap_users to reach zero after draining the QP and=0A=
>    before releasing reps, reqs and MRs, and clears rx_ep and rb_closing=
=0A=
>    under rb_lock before dropping the ep reference.=0A=
>  - rpcrdma_flush_disconnect() tolerates a NULL rx_ep.=0A=
=0A=
Let's drop the reorder and the rpcrdma_flush_disconnect() hunk.=0A=
=0A=
The only new reader of rx_ep that runs without the transport send=0A=
lock is frwr_unmap_sync(), and rb_closing already gates it. It=0A=
returns before touching the ep whenever rb_closing is set, and=0A=
rb_closing stays set until the locked section that clears rx_ep. So=0A=
keep the ep put where it is today, and clear rx_ep and rb_closing=0A=
together under rb_lock after the put. A late frwr_unmap_sync() caller=0A=
then bails on rb_closing before it can see a stale pointer.=0A=
=0A=
So the rpcrdma_flush_disconnect() change addresses a problem the=0A=
patch itself introduces, not a pre-existing one. Removing both keeps=0A=
the fix to just two pieces: claiming a req's MRs under rb_lock, and=0A=
waiting for claimants before disconnect releases the MRs and the ep.=0A=
The sentence in the patch description about rpcrdma_flush_disconnect()=0A=
dereferencing a cleared rx_ep can be removed too.=0A=
=0A=
=0A=
--=0A=
Chuck Lever (Come to NFS bake-a-thon! https://urldefense.com/v3/__https://n=
fsv4bat.org__;!!Nhn8V6BzJA!VxUh92K-zhEMEpDyLcpzRSd3RNztFVPJieCH70PiuYNx43DJ=
DzRIJ4rsBibjklmrLado8Qs$ )=0A=
