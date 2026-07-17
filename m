Received: from mx0b-003fbd02.pphosted.com (mx0b-003fbd02.pphosted.com [67.231.157.221])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3ABEF3F8EDF
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 16:59:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=67.231.157.221
ARC-Seal:i=3; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784307581; cv=fail; b=UuYA5hgsp0Rn0bdElK7nTffFeFxEDhtFcPJ/0nu9jiR1yH2Zu8muZyC9+bwQht4mI4scdMaygAJ9A16FAxBumWWoWTw6ZKTHZilKsiENOxLDvfXWKNNQ/zOC9rUAJjRyVL/rFErVZ92GKFyHEPMPNxZjw4d3M57ThUsSWhoQavA=
ARC-Message-Signature:i=3; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784307581; c=relaxed/simple;
	bh=q6lpdz3wliNy85S7Nah5COERmtGsDqxnN7jqmdaJRtc=;
	h=From:To:CC:Subject:Date:Message-ID:References:In-Reply-To:
	 Content-Type:MIME-Version; b=LGWPl3xECrENj+tKCStwJsvjxwGpS48z7RlvZlbSUPegIdcmmXElRO4IlJhoQMC0f3dYM6DyGKXAl/111QdsvJs1zAMyHVx62hRLaht9FMDYOlftB86bCASrgrC8XnUgdbQFZlu9BufLAgpb0XEiGVxYQ8oOYNhFou3qZ7Kv5+U=
ARC-Authentication-Results:i=3; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=netapp.com; spf=pass smtp.mailfrom=netapp.com; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=lS0xWa+v; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=DTPmMi2A; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=DTPmMi2A; arc=fail smtp.client-ip=67.231.157.221
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=netapp.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netapp.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="lS0xWa+v";
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="DTPmMi2A";
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="DTPmMi2A"
Received: from pps.filterd (m0412385.ppops.net [127.0.0.1])
	by mx0b-003fbd02.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 66HE6n1X629184;
	Fri, 17 Jul 2026 16:35:39 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=pps1; bh=q6lpd
	z3wliNy85S7Nah5COERmtGsDqxnN7jqmdaJRtc=; b=lS0xWa+vxWL0LskBdTIL5
	vst60dqpz0runPQ4RCH0MiCA71MrIhA/AYrl9XPizKQyqKVT7rrqg/pqkxQN2CU2
	tkqrbAHm0gyZ3pwR5N5+oxPkshXtJ5ed+mm7X3L+EeXGwXDpLTznvZs0KjAHe7ak
	qz/86jJavxXHPwczeqtqmVuAB0hcBD0zwSqqRPxFNH67ydy791JFS98HtV1DPHCj
	bzcQk4J3lSAUBPKOtuFjWll0qi3Xh0PzudqGfcvOErHzn3RNLYOidqoNKqcipSyl
	VP8MyMPausVllGGPanYC4LK46d0MMXklGFw+84u/XBAkasqC7ktpdzY9Dgn/Y6tJ
	g==
Received: from sj2pr03cu001.outbound.protection.outlook.com (mail-westusazon11012064.outbound.protection.outlook.com [52.101.43.64])
	by mx0b-003fbd02.pphosted.com (PPS) with ESMTPS id 4fey2sd0p7-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Fri, 17 Jul 2026 16:35:38 +0000 (GMT)
ARC-Seal: i=2; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=pass;
 b=axkQsqmjPNQbOgi/oNX6nIx+dOQlktyyvCAWyaChlWjx5OVPhQwe3YvEsFDB4E0c6P90TIRzNzdV4yhVQ6gCNyWT7M/233R9l3MQAyrCQ7U7i1UZMZp54tjkfm/tlK+DnjcaSCSIuk9J+uy2Wm9Z1rlUabQmQ9902/GnD/W+jTKNmOD1zHGLkwQa64YAd7s6kyWLb/KHGvHIxkKWZ3C6aT/x8dqnkPmjpRVC1ntLfoVQZs7Gdexf2HK//Gcr9N/cK7OguiTtOeh60U9DVIgL9zL/8Bb3pqqO9Le22Qk6aDcy7yV3PRFLSQ0tkhpp8qANxECVt3wRxyd/iWZBjFIneA==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=q6lpdz3wliNy85S7Nah5COERmtGsDqxnN7jqmdaJRtc=;
 b=AsNoQQr+nWeWkHFX2aetjMqm88Y7sGhjY+dRdVt5gequb44SE5KAspgnPEEi5I2hw4IL6ada4O/YMK9aWTNUP10QkeFj5aQAGdInJ/+paAqUJQEFDy5A9PjGNeD4WpIGnE08DhncBk7LfZL2wE3k9CXRJdpDYObLQnVOvKECEXmP1aXAGcPOjEDtGEjyGEsvh9N2OKdcZWY8A6R5Dn6l5y9jVrU5ALJxAR4gvCygeXyh8ng3L2PhdZXhaqvCcDNJuzmIWFzlj7RFzU1jnvMEGBFLm2jX7YeKRP30+mEj5vfvP/FIjiFggaZ0V8VJYFOTetk2Ips/xVLEeasX4zmbnw==
ARC-Authentication-Results: i=2; mx.microsoft.com 1; spf=fail (sender ip is
 136.226.142.113) smtp.rcpttodomain=nvidia.com smtp.mailfrom=netapp.com;
 dmarc=pass (p=reject sp=reject pct=100) action=none header.from=netapp.com;
 dkim=pass (signature was verified) header.d=netapp.com; arc=pass (0 oda=1
 ltdi=1 spf=[1,1,smtp.mailfrom=netapp.com] dkim=[1,1,header.d=netapp.com]
 dmarc=[1,1,header.from=netapp.com])
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=q6lpdz3wliNy85S7Nah5COERmtGsDqxnN7jqmdaJRtc=;
 b=DTPmMi2A95QuQFwpB5MTlZA5XMABEDWUz17hLR0bwZvgMsdK7p8oQzLjiWdWeLxw1H2T5qditjQp8/nLvUwV1wAATwZotaiB2YrXgAMviYiIVUl4wy4+7sXE9Nb+VbnDUtWolsjiXW//CfGm+m2F8ir3fci6i7PQ5EK8rSLcUTnvOMSOyONvlAVIP5mi2AIrG71qN07pFAsspef8LEl05r2ODyjEjjGPnF2x2WRWg4y3vr1h9ZBOoqA6/fywk3uf1FApiKgLHmkvVGGFEFZ6v+CBLl+QjOcDO8KZFNDisTUEbZTqleWbxegtdCsqQqKMPJgcTLIU5rBQ5imuRE2rTQ==
Received: from SJ0PR03CA0213.namprd03.prod.outlook.com (2603:10b6:a03:39f::8)
 by MN2PR06MB6718.namprd06.prod.outlook.com (2603:10b6:208:206::24) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.245.6; Fri, 17 Jul
 2026 16:35:35 +0000
Received: from SJ1PEPF000026C8.namprd04.prod.outlook.com
 (2603:10b6:a03:39f:cafe::75) by SJ0PR03CA0213.outlook.office365.com
 (2603:10b6:a03:39f::8) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.223.12 via Frontend Transport; Fri,
 17 Jul 2026 16:35:34 +0000
X-MS-Exchange-Authentication-Results: spf=fail (sender IP is 136.226.142.113)
 smtp.mailfrom=netapp.com; dkim=pass (signature was verified)
 header.d=netapp.com;dmarc=pass action=none header.from=netapp.com;
Received-SPF: Fail (protection.outlook.com: domain of netapp.com does not
 designate 136.226.142.113 as permitted sender)
 receiver=protection.outlook.com; client-ip=136.226.142.113;
 helo=sjc41b4.mail.zscalertwo.net;
Received: from sjc41b4.mail.zscalertwo.net (136.226.142.113) by
 SJ1PEPF000026C8.mail.protection.outlook.com (10.167.244.105) with Microsoft
 SMTP Server (version=TLS1_3, cipher=TLS_AES_256_GCM_SHA384) id 15.21.245.5
 via Frontend Transport; Fri, 17 Jul 2026 16:35:34 +0000
Received: from bn1pr07cu003.outbound.protection.outlook.com ([40.93.12.6])
	by sjc41b4.mail.zscalertwo.net ([136.226.142.95])
	with ESMTPS id 6A5A59D508C30000;
	Fri, 17 Jul 2026 09:35:33 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=keqjEgwpatfUY7tYM36ZuA4pZ+vISZAD02ks7/Jex2a+Lm44krLXf1+4JD1pwceOi0Xal/5ZkXMV8MUWIP0Qq9Q4rjIDkp95IqFaJ1N78xFjd8tn6AbviHc9+QuPOd3mj4yyZAjQ5CZT7AHKcI7nWRJVIjTuiJR1RH0JY8wTuynLcc0DbCcifENOMlJU3yArAVna3fxvopzWKs4mfaFVn0/q7J76fwGs4m2Vum+VvsBZLGqSofQpVy5ugJ0w7f9c/zf7JzViGpKqXictC3yT/DWhE2dXd0sDP/SCwtd5vzWhs/J2MJA0xDDx7kBEGWBgOABIa/btyWZOjw8SGYeaGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=q6lpdz3wliNy85S7Nah5COERmtGsDqxnN7jqmdaJRtc=;
 b=Gy/yLRr6g2OIHJMZoDNa1W+W7i6d06EMdFOuI2uibyCnzUSAV7O9Y1Dk4OVKkHmzE4IzTBLwRjfyje9zoEBz9dRykttHRqIN++1lJyNBp0PWTobmjnER4GyRKRK05eY6y1QJvv9RKFH2HSnr/p/HhQs8jV3s5QwSPZ2fBqt2ic++5bQx7IoC8w+1EsKSrkfV4Q7azubDtUzJjXEdiyPBt+Ytx55+OMEl+yhDVjnIrlB+0zSnBm4UXVzJNtBTLSnfBCjmpXu88sohHLKKvdJgtLH3hLnPyt+/UO03TR42v6EJEkg327gSZEHWcsNlF1e6siSnNMAE1r/+9wDqsv+n3A==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=netapp.com; dmarc=pass action=none header.from=netapp.com;
 dkim=pass header.d=netapp.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=q6lpdz3wliNy85S7Nah5COERmtGsDqxnN7jqmdaJRtc=;
 b=DTPmMi2A95QuQFwpB5MTlZA5XMABEDWUz17hLR0bwZvgMsdK7p8oQzLjiWdWeLxw1H2T5qditjQp8/nLvUwV1wAATwZotaiB2YrXgAMviYiIVUl4wy4+7sXE9Nb+VbnDUtWolsjiXW//CfGm+m2F8ir3fci6i7PQ5EK8rSLcUTnvOMSOyONvlAVIP5mi2AIrG71qN07pFAsspef8LEl05r2ODyjEjjGPnF2x2WRWg4y3vr1h9ZBOoqA6/fywk3uf1FApiKgLHmkvVGGFEFZ6v+CBLl+QjOcDO8KZFNDisTUEbZTqleWbxegtdCsqQqKMPJgcTLIU5rBQ5imuRE2rTQ==
Received: from SA1PR06MB11353.namprd06.prod.outlook.com
 (2603:10b6:806:4a2::17) by LV3PR06MB10008.namprd06.prod.outlook.com
 (2603:10b6:408:23b::22) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.245.5; Fri, 17 Jul
 2026 16:35:29 +0000
Received: from SA1PR06MB11353.namprd06.prod.outlook.com
 ([fe80::ff:880:c010:68bf]) by SA1PR06MB11353.namprd06.prod.outlook.com
 ([fe80::ff:880:c010:68bf%3]) with mapi id 15.21.0223.008; Fri, 17 Jul 2026
 16:35:29 +0000
From: "Mora, Jorge" <Jorge.Mora@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust
	<trondmy@kernel.org>
CC: "Williams, Keith" <Keith.Williams@netapp.com>,
        "ben.coddington@hammerspace.com" <ben.coddington@hammerspace.com>,
        "sabbene@nvidia.com" <sabbene@nvidia.com>,
        "pyoo@nvidia.com"
	<pyoo@nvidia.com>
Subject: Re: NFS mount option rdirplus
Thread-Topic: NFS mount option rdirplus
Thread-Index: AQHdDxsh9JJiyX9uik6pS7FOpN4H8bZx5nsu
Date: Fri, 17 Jul 2026 16:35:29 +0000
Message-ID:
 <SA1PR06MB11353323AA28FA09C4EC56163E1C62@SA1PR06MB11353.namprd06.prod.outlook.com>
References:
 <SA1PR06MB1135309B2E478CE0323EF04BCE1FF2@SA1PR06MB11353.namprd06.prod.outlook.com>
In-Reply-To:
 <SA1PR06MB1135309B2E478CE0323EF04BCE1FF2@SA1PR06MB11353.namprd06.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels:
Authentication-Results-Original: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=netapp.com;
x-ms-traffictypediagnostic:
	SA1PR06MB11353:EE_|LV3PR06MB10008:EE_|SJ1PEPF000026C8:EE_|MN2PR06MB6718:EE_
X-MS-Office365-Filtering-Correlation-Id: 66eb3df0-b62d-496e-4b41-08dee4216ce0
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam-Untrusted:
 BCL:0;ARA:13230040|1800799024|376014|366016|23010399003|10067099003|56012099006|11063799006|18002099003|22082099003|38070700021;
X-Microsoft-Antispam-Message-Info-Original:
 ltQr6Gn1HFHG9D8gVopq1eARtWCChB0qxEZFqjhuT9eBgn06839dXgDEo7UIZbYwAJ6+89qVgo0JrHlmDSYPDfLWvSOHKi+YjvWs0aWNGvhrBoZJNll/K8/hGIKuSQ4QgDH+nPd4w1EtY02jORpda98s68qbGhVnIjs1dc763hkR6LtIIQ4HVPHBLCbrv/l2LS4Yn+oWgS2z/uVTnTtVIyDTjJKiBbOVYbfVPydxcnmBzaSYao6azOEX0RKHCVh4qHJ2HnWdYUpCAxM74KFrlWveyJ6eWYgjMylUTH0S5doIz0odZs0ygrAoJkpjHc3E+0NhELLx4CXaI0ESiB/jXmdz64mErFNZUqd0iFQJVAFQONXZdLRubVgc3Vb/DURTs7D+RDwHmZ2kBtip/8CAjPQXwgR9+pyIYS/zwrM7U7mDi8cVesHpXtc7uReiMjT+feML+M6bK/x8gWtGvI4VtCJSAs06iXwBCcLN77PmcwkMBPpHKU0/SyuEEdjp52q9Ul9SYdNcUAbr6ZvWCUv8PGAxfHX5JalusS5l0CG3Q2B4fTOtlDVO1F1qvKGudgeDmLBR/bRI+TtMT99GUBDbri77FXOv+xI/RLHCgEHT6/mcj5WbsYfkxQceNSGpZ3c9fodF/Di/6uQjZsdTtR1ja8pSeGPL9DjZtIUpu7ZybGtyx3Nrl8cmgVXespW7O+LsupVhrHlc0EbmdP0HWcQGd4vCmuAJq1sjT85LHAjvY2c=
X-Forefront-Antispam-Report-Untrusted:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:SA1PR06MB11353.namprd06.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(1800799024)(376014)(366016)(23010399003)(10067099003)(56012099006)(11063799006)(18002099003)(22082099003)(38070700021);DIR:OUT;SFP:1101;
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Exchange-RoutingPolicyChecked:
 Ab9IIHSzFQt+YPJn+S4/LBw3bbIJ3+C1Qm1gJv2grr7r9sTHqoMYa8yYeqYQbRhM+1y4ulZFF/vHAsUivqDEDXxyTiBnS9ALX9GvgRt81VHIjoNqvVN4j4Iwj0lH43eE+IlAaecHHcSIo06LKbhSONcC+fTOUWrroFQtQ/paULSoVZNwQA3XkXKaBpua3euuyoVCmgEN4UamaBn4W21mkYh6uVqhTk1jQzzqx9uB+BFl0TF/PHuauOwwBRhYo9Vk1+3M9hWKrxwTDjflYTtp74VukbbSfggJsqma1hYgsCi4slOMRgjUnOf4dj5Gm9J+p9E0zGEcF4lPYA1VTSVWxA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: LV3PR06MB10008
X-Zscaler-Block: 0
X-EOPAttributedMessage: 0
X-MS-Exchange-Transport-CrossTenantHeadersStripped:
 SJ1PEPF000026C8.namprd04.prod.outlook.com
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id-Prvs:
	eee56655-d4f5-436d-525a-08dee42169ee
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|35042699022|82310400026|1800799024|14060799003|23010399003|376014|36860700016|10067099003|11063799006|56012099006|22082099003|18002099003;
X-Microsoft-Antispam-Message-Info:
	3tjczMw4guVT5QJ6UiR9MSaFJBYtI2vjos3VRPmTGTrjnTal8OJu3u8K0BQrn1TW9P/CozrXO3uMKl6FSh83MeNE/vEMdtUfZDcUI9Vs24JoXkIGCmcAgA5FfN3Hl0j1Belw8AoJTYhh1YAw7jVAk2cpjBGLdoLumPXnnIAM9oPl1utrJt9+tsCVK1qPJF6V8PsqMvmlC/UaEFVoFSMtDulNWLEtu7TvE59M+dXuFZTmadEYoVY2Nvkz+Hud51+jjZAMe65d+psZXvqr/Ggz4H2Y4x0RxWkcOA+uSuuSt7S8hFRN7BExtgwhumsOUSp5l1+br8Ykx/Rbi1gfa6sEue+90zvAncrrDWym5s3PzaL+92xdzWiFhe9+Admn7BZNRMiOgwihoFJPOxpoullUKflrvCq377FL2Jz4lolBplbj0PTyICJoV3DZiM0eNKTRxKmf7Cupnn/EjTUUgwPPWPS59VSwjGblmWMEq/A2dk2Z2yCGc8a3IFxstfxDv02frFdqWRFCX6zj2T2Vv5vbjLLbZK/skgGbr7C8REYdZT5RbKDSKDmtQ8IW/sFpowBgmHl/lmAEXfhTKd2QS9xwaSMnZxocxlbDk+SCctiAFpTAkkCBmlsI4vbBhHZ2ZBYNvHPGHV9Wwc4tTIIesnxsIjUAhfYaDA5fek6YFpWVzMRruzV8wVPhlOccOr7G3/BhrVdCl/3D1SdPx4xEsdfNQg==
X-Forefront-Antispam-Report:
	CIP:136.226.142.113;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:sjc41b4.mail.zscalertwo.net;PTR:sjc41b4.mail.zscalertwo.net;CAT:NONE;SFS:(13230040)(35042699022)(82310400026)(1800799024)(14060799003)(23010399003)(376014)(36860700016)(10067099003)(11063799006)(56012099006)(22082099003)(18002099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	MMQCqaJyhatwBi5RTiZ1DGpbJaSzASmnpX7spFW+oOUdmueDttRJ3cQ/N3VghVAgN+Sp2wGdKe/dMd2DxFnFJVXb9+zpBkNWocJCFpdIf3eIgRYlrjsOGGQG5Ynl/rO1lcFZ0aj+ukgmjV8MMVyPJToG4kgo6zEhj8YEOW9t/xyuaXdsF/LJNvU0sFKEV4K3hP46ZrCBYUydR0ZhJTGLVaBUpWss64wLZHf6R4pWolWpoJi244ZRmnJJ9h6/uves/Hk4zAezhKyjgnyaTu2uWyimrhHMkbSMLaZAHb381CmGEjPCKInveBXMGbHhJ9ZUwXsufQkpbGOuiu2qsmW8TxUpAJpWNmObUCm6zmoDKfLgBCNo9kK/0d3DZsk/kHRDGN+cXC0HRZhuPvxdqPxjtvY/JlzqWx754R07Pu8RMp5q3y+fb2j8Aw0wEx3onlyv
X-Exchange-RoutingPolicyChecked:
	V976w7gHtvZbFCduVY663i63h57/Q7iCJtOFd42RTKeXJoeDyl18MF+mkt/3B3u97TY+lo8DiGF0jEdv7xIZOZooNduldCOJRfWXh2E5B/JGJepTjKw1zyGW0ZQpLmLgdUP3YHw64gMGR0rcxBCm6518m7jae8Oh48nWsgJo7D5iphjUVnlFm0NrwZC/0HodZmLtQQcXVckOQchMBcDJBJGPR9b8ukyueM/vzEeAbL3GW0nqffh3NAoJXbqtBTQ7TyHycxCC089bzkUmaID9RD/nBSGwqz1p3Qbzj3dGdGs8q7cJcEnKf7Ldib4I3jcjRVANs1J44OPWdErwBbJXvg==
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0:
	5bGoIW7r7KZ8Ko3eneCxfdO7etsKjeLrxgCy/EIFNa4IoZW7Zmmvz2l65XMenbeWoOFfeWUcBhRceFMr8RDNKP6dk5jHoiCHEKWMnACWvBazDDVFam27XDFtTPU4qSW/wICv3Zka0U8OMZ0KMLtnyJXJplvVD4z3pdgojc1T0QVgdpm+jihNZaK3T9K3lu5H1oDvTVH04PDv1UQuzsz3/cSdhTyPY5ZW3syv7KD+WKT6G5EXwzCjzOmnAaLR54yuoN8bWriHw48amyz4HLlWwdRWElhrvokxpx8/2aM8TUB7UUQNtIj+SmqmLjLH5Og1P3orK+xRW5XubX//1TfiMo+eiDO+u1yeUlCl6JSlpfzuvlfaWrDwAttfaq5io76RS1e150rVGrJlNM2wZr3LCIrtwE5kBmpc5HgkndP+dzi38m1ONnCuoUZp1oIjZAUhwuOkvVACrrWGs2LyRADb/63f4nM6CI5SvtA86FJrwH78XwLB8iWMLaKhqjQ8zuyCxt3F7IlBt+vcToZFgXft71FXjwPqGqHZkMUqP2p4LkISGITxHAf47cXnog2aGfIyJJjgRZNGodGrvkAAh6uPs24WfcLmrxRa8YrWmDSZf3FyhHz9GH5tnU5PYEq26lQo
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 17 Jul 2026 16:35:34.4209
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 66eb3df0-b62d-496e-4b41-08dee4216ce0
X-MS-Exchange-CrossTenant-Id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=4b0911a0-929b-4715-944b-c03745165b3a;Ip=[136.226.142.113];Helo=[sjc41b4.mail.zscalertwo.net]
X-MS-Exchange-CrossTenant-AuthSource:
	SJ1PEPF000026C8.namprd04.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR06MB6718
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwNzE3MDE2OSBTYWx0ZWRfXzpYAjsVo8mq4
 m3HbRfHtRunT9GACxQ/9X1VBVe01gcWNADr3gppEjaxYuRS2q5RdgzQJluy1kj3r4+fcm4EKxWC
 iejrARVIioGxN5IS2c765x/PO+/pcDuzEY8yCUm72n1dOp3+63wHp3An0M6A6uEIl4Wth6Z9xSU
 QTeRlKN52UVojZa7kOjPqyeDW6vOlGi9zotvsxZIoaC/DPtLfm8/0WJta7SUtVh2UMJAEGfTHFG
 XM571G6czHBFbe0mSJAi7mk4eryjSkX7HIpI17TwCJdVwkTtYwMvZTLqO0kK0TxQbfnXOO6qQNW
 GXIXqQWYja4g14S91A8qBdDALgcmMO225T2T53tq8HJJ5lLj/uiQeKTrEtC6+Im7JkLZC3aRt9E
 FPXwSrMRwB2jEXQwj2nFud+FO7OxF4xjKQmUSXv7WO7GhtFys8C7PcapH9pwSvEXnq5NmzaXhyu
 o0IrGJ49lRAwGr38v4A==
X-Proofpoint-ORIG-GUID: 9fGYusWDMuqSR7CBe3XjvfZT285se_LD
X-Proofpoint-GUID: 9fGYusWDMuqSR7CBe3XjvfZT285se_LD
X-Authority-Analysis: v=2.4 cv=QL9YgALL c=1 sm=1 tr=0 ts=6a5a59da cx=c_pps
 a=vzG6OqJaKuDO37FI3iuMvQ==:117 a=66US0ekucDd9sSMTPlLWUg==:17
 a=6eWqkTHjU83fiwn7nKZWdM+Sl24=:19 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19
 a=xqWC_Br6kY4A:10 a=8nJEP1OIZ-IA:10 a=RAioF0-LDSMA:10 a=GWG4Yq0kndkA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=1lWG0UuNQvn8UhQ8Wh4S:22 a=SqyuW1mdmu-nm073FuYB:22
 a=VwQbUJbxAAAA:8 a=TMFGcvvbl9YHuFNxX2sA:9 a=wPNLvfGTeEIA:10
X-Proofpoint-Spam-Info: AW1haW4tMjYwNzE3MDE2OSBTYWx0ZWRfX9dQop9R/VcMh
 aGDPtRNhSCks+e2hLWU3p74+QoUeb5XVwCO65wNpjv6bdGYrECLD3UmMsIXxM/qRyWOptgX79KO
 +uG6LcLEPy2nSYBgUZ2FHOl+kmfPyTw=
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1143,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-07-17_04,2026-07-17_01,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 suspectscore=0 impostorscore=0 spamscore=0 lowpriorityscore=0 phishscore=0
 clxscore=1011 adultscore=0 priorityscore=1501 bulkscore=0 malwarescore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2607170169

+Stephen Abbene=0A=
+Peter Yoo=0A=
=0A=
--Jorge=0A=
________________________________________=0A=
From: Mora, Jorge=0A=
Sent: Wednesday, July 8, 2026 2:59 PM=0A=
To: linux-nfs@vger.kernel.org; Trond Myklebust=0A=
Cc: Williams, Keith=0A=
Subject: NFS mount option rdirplus=0A=
=0A=
Hello Trond,=0A=
=0A=
A customer is experiencing significant performance degradation after switch=
ing from Rocky Linux 8.7 clients to a 6.12 upstream kernel. The clients wit=
h the newer kernel are seeing a dramatic increase in GETATTR/LOOKUP operati=
ons. Their workload primarily involves traversing a read-only directory tre=
e and reading or retrieving file attributes.=0A=
=0A=
This issue is related to changes made to add heuristics to READDIRPLUS. We =
have been testing on RHEL 9.7 using the mount option 'rdirplus=3Dforce' to =
reduce the number of GETATTR/LOOKUP operations. However, this option introd=
uces other issues.=0A=
=0A=
Is it possible to add a mount option to completely bypass the readdir heuri=
stics, such as 'rdirplus=3Dlegacy'? Alternatively, could a mount option be =
added to make the client less aggressive in sending READDIRPLUS requests, s=
uch as 'rdirplus=3Deager'?=0A=
=0A=
=0A=
--Jorge=0A=
