Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=2 smtp.remote-ip=67.231.157.221
ARC-Seal: i=3; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793148528;
	b=r/OIuUVrAPN9JGnIQeTW0ut7/Puo0gseHMkmRc1YZBzs/N64Lw/G8DXPeNy59isGqlum
	 DSd4eV+mOthAdZ7EWkXPwoNbSXvO6Qoqzp7Tgc0UKSTQk/9X29lPmQ94fX4i1GfpEInkG
	 8CAv4Nz75Wp6VAO+Mp9rxQS7cydKNJyWnuIdzyZH6J5a011SettDF1nvw2P/sQJqQU7zP
	 7pYmWNP7eoDVLmpo9CH/UEP6y4yqhR9tHP4BFzDqdJmjusA6L9MtJQY4BnAtn1MLzRdc0
	 Rv8dHNRBuyg0wLqMUyHZdbwlJErTIydAE6PNrL2Ra0jO7LXT2BnCAzmiKNM/yJuP8GQ==
ARC-Message-Signature: i=3; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793148528;
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
	 X-Authority-Analysis:X-Proofpoint-Spam-Info:X-Proofpoint-ORIG-GUID:
	 X-Proofpoint-Spam-Details-Enc:X-Proofpoint-Virus-Version:
	 X-Proofpoint-Spam-Details;
	bh=k8cRTZXSyP/P2c4tq4XRDCBPKoZe+1tJ/PX8lHSjR1c=;
	b=200JB0JN14pfwJ2R87mKd8SwTXnmZLXO5Q2tRojRPkjnmfUqQf2Sb51eM2xPvxTUcqMS
	 hpLAuXxkQ3ncQX/XphNmtWYGg4fIloc6VP4OfW1HFprEGahsBULMr/VqUExBmsuj8/5Zc
	 x+gKOlPZQ/i43P7gC4WOY9nNDP4GHsuxUdok0AHnlRvzRqGPEcIjgbU4nmIiFTlvuGh8a
	 VKhKN3pvlBRosFU6verqQ8N+GK0rBRfQvtSD9Y1ajCsEOXTpqDUrxg1I8gsujd4lLtTm4
	 +ASRhnyk26/6nr4FtlTeuFjLUv2AVtd6ZLtJaVBYDq26nyWbTL/VOiYz1NM6sP1CjeQ==
ARC-Authentication-Results: i=3; smtp.subspace.kernel.org; 
	dmarc=pass header.from=netapp.com;
	spf=pass smtp.mailfrom=netapp.com;
	dkim=pass header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=pps1 header.b=pq3Ki59R;
	dkim=pass header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=selector1 header.b="a944/2/4";
	dkim=pass header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=selector1 header.b="a944/2/4";
	arc=pass header.oldest-pass=2 smtp.remote-ip=67.231.157.221
Received: from mx0b-003fbd02.pphosted.com (mx0b-003fbd02.pphosted.com [67.231.157.221])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DA101606A31A
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2026 00:48:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org DA101606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=netapp.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netapp.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=pps1 header.b=pq3Ki59R;
	dkim=pass (2048-bit key, unprotected) header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=selector1 header.b=a944/2/4;
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.a=rsa-sha256 header.s=selector1 header.b=a944/2/4
Received: from pps.filterd (m0412385.ppops.net [127.0.0.1])
	by mx0b-003fbd02.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 69S0kbv73047716;
	Wed, 28 Oct 2026 00:48:32 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=pps1; bh=k8cRT
	ZXSyP/P2c4tq4XRDCBPKoZe+1tJ/PX8lHSjR1c=; b=pq3Ki59R9n/V2CDkyvjFg
	ry8QoXub4gpp8uoYfRC2R0k+kuHdFXRDtzGd4kzKXtoKBDOgJipcAE0w6IL4xIhG
	IHQ4r/la+bmjGoRgj/QuUt3ET7d71xxid51iCG9u6oJ2jLnmnUwhcUN857okqm7F
	VJxESqC8lymGZrjvt4j4Q+WVNNFuSpkDZU1FSpLT8omaJ4oHMyE6l3OygNa//oYF
	boV3V8b0ml77LHka+Sp0TKk7oLqI3hp3JOfkHxtoOPZOXhjdIWGIWrtIyF8QK/s0
	XDnv5eoLKH+iiS5mxbMilQs8eykG5icFo76jPDM1fM2sDTeLZwVdax/2Nybtqn/V
	A==
Received: from bl2pr02cu003.outbound.protection.outlook.com (mail-eastusazon11011012.outbound.protection.outlook.com [52.101.52.12])
	by mx0b-003fbd02.pphosted.com (PPS) with ESMTPS id 4hjve7tuqu-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Wed, 28 Oct 2026 00:48:32 +0000 (GMT)
ARC-Seal: i=2; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=pass;
 b=uy1/3lLUGPh94d0yE/ZbkL2xtwKchGX+uEKybmYzJYZ2Ze3bejP1/1xsfKZ2kwNPxfc4ng2urUJwNTeV1gfCjyAEIN3VIOHhoSDXAIBdyrlL22aYHeFC/gmw/Qf6uOLUJxe4Uj3CbCmgpogB5qIA4igCiVyvij93JbRTalNOwbbIM4xpnqu502CTB3HnholPlPgi5dnFgnpYLahfAMpw7zKs9L48z8GwEhQpOQOyhIGSrLRUIz1RLnsugs83xneuQsCVlP43VDt5yYi/i0YXUB8zBmL033oav8VVhxzr7nWYiB8RPpEJ2pRMCCW0sgrMMT52JjzU9B9lRc277vEJlg==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=k8cRTZXSyP/P2c4tq4XRDCBPKoZe+1tJ/PX8lHSjR1c=;
 b=rAW8qsmY7o9wTpH3ig48mXWKRNvOpbuaOP/DvblROk/LB2bbvwfy1/8EqkpJRc7ysgWZfIJnS3PDej1mDB2B82XH9NUrv0GwqdlxW7EaUdJsu7r9jQbapP9p66nXN0SAl3f4UiMVxKQLDDnOyx+XmXNNcgNVXfJU4yseElZxM8yczhvurGku3vhqlDj7Q1LRuYrbXfQA6dyqxMyyxwOs0U/A90oXhHCx26s+PTW/ci1b6rhAC0JOcP7LQDH2TTs0PbjUZ3t3ckWd4L1sMA50sS1eYv7F9zwOr4GRhoFIy6FJIsC5sM6ReOyzSdRHCeQaeEzHaoahfqk5dYhmk54JcQ==
ARC-Authentication-Results: i=2; mx.microsoft.com 1; spf=fail (sender ip is
 136.226.152.57) smtp.rcpttodomain=kernel.org smtp.mailfrom=netapp.com;
 dmarc=pass (p=reject sp=reject pct=100) action=none header.from=netapp.com;
 dkim=pass (signature was verified) header.d=netapp.com; arc=pass (0 oda=1
 ltdi=1 spf=[1,1,smtp.mailfrom=netapp.com] dkim=[1,1,header.d=netapp.com]
 dmarc=[1,1,header.from=netapp.com])
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=k8cRTZXSyP/P2c4tq4XRDCBPKoZe+1tJ/PX8lHSjR1c=;
 b=a944/2/4UMhiipq++Xb+BIc7ALwAYxkNcVgM4KA5bPdXkPRpUO8JPYSkgT2CDuNWeEgtKsKeO5OfXVslvxpwjawsmHpNhw+0/EUECHeZAe3eYzOsq7dU+eX1B8P5p8t4kjXd+mTogaFMmlV2ERb0pX7Oydk+sO/ONBVyAqoG6CXK/yjGVF/z5IHg+UXZcnqLDdBLmJlbPPjyM7eQZyMdRlLUk9n1NXSroBgYSA93/36Tae/BN/ZqRSKIs5s5PkcNBmy7covIE2AZh2DyBIfveVfRYd+VKdIGHJlbTp2f6xw1t6P4fGCc8LdBvEmwNrOfOZGnInWjPfTD2WRB+G18Zg==
Received: from BN9PR03CA0792.namprd03.prod.outlook.com (2603:10b6:408:13f::17)
 by SJ2PR06MB9527.namprd06.prod.outlook.com (2603:10b6:a03:556::14) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.546.22; Wed, 28 Oct
 2026 00:48:29 +0000
Received: from BN1PEPF00018070.namprd04.prod.outlook.com
 (2603:10b6:408:13f:cafe::49) by BN9PR03CA0792.outlook.office365.com
 (2603:10b6:408:13f::17) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.472.20 via Frontend Transport; Wed,
 28 Oct 2026 00:48:29 +0000
X-MS-Exchange-Authentication-Results: spf=fail (sender IP is 136.226.152.57)
 smtp.mailfrom=netapp.com; dkim=pass (signature was verified)
 header.d=netapp.com;dmarc=pass action=none header.from=netapp.com;
Received-SPF: Fail (protection.outlook.com: domain of netapp.com does not
 designate 136.226.152.57 as permitted sender)
 receiver=protection.outlook.com; client-ip=136.226.152.57;
 helo=was11a5.mail.zscalertwo.net;
Received: from was11a5.mail.zscalertwo.net (136.226.152.57) by
 BN1PEPF00018070.mail.protection.outlook.com (10.167.245.198) with Microsoft
 SMTP Server (version=TLS1_3, cipher=TLS_AES_256_GCM_SHA384) id 15.21.569.4
 via Frontend Transport; Wed, 28 Oct 2026 00:48:28 +0000
Received: from bn1pr07cu003.outbound.protection.outlook.com ([40.93.12.5])
	by was11a5.mail.zscalertwo.net ([136.226.152.43])
	with ESMTPS id 6AE1465C08F70000;
	Tue, 27 Oct 2026 20:48:28 -0400
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=LMJADxhrFpdILR0QNj1miinb+Iet9WUMvQSV+IZfH91aNQVttjQ7YOoZ1OTaqMdx0KN0nm9F+ExOEFV4H+kwt6V0B9tqaCaf0QKPHEvDfDX/9iCqiXQHrt93I6ZcSJ4C2a48Gkmbk9t9THMe426MLRQbb3ibEg17GTVv6mB/YjGkHq/Uj1ae2u3PBQF/pFZzA/XA8uJjs2dyjsTp6nI+/tM8egXelWYHng/u1D9MR+jT+nVIDC9i1QFtkBm6xAKtvdpvFmsjwm9wPRJNNMz0/nM3+6XPmo1XOqzuC4RnRaX3CFqx0lAsGPocrgarFO1+RXQJcyCi9Aa2xjbHvv5zMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=k8cRTZXSyP/P2c4tq4XRDCBPKoZe+1tJ/PX8lHSjR1c=;
 b=WESU3HsaV8a0zhTmEw5PJELaz3mDZImci1I0HP1EIQOfUSu22RrUu6lQRaBjCO97I9Y5c0QV1UEXb+kH23O8A4VswIX1e7IpvOB/tch08n8xghvLO5ytP/gFor/fyn5gOEtgKdgqjRx+p6WHfqG07N1jfFWxmO9p4VLCLo3igWz3QiyGrhAeHd1XZ/8EWRY0peR7czsRUj3YODXgB1ubFJW3kMUuRje9Lbc7Ra+eyflb+EXmLmhiosqY2ZX+JNvKOaOq84OeXBLsiTZ4/MfhbHQZwVr1zLvGBFod1ESO9awI6Fem5als1JXRSdMkfwvNInbvcWvDf2pOWgB3slzQ/w==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=netapp.com; dmarc=pass action=none header.from=netapp.com;
 dkim=pass header.d=netapp.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=k8cRTZXSyP/P2c4tq4XRDCBPKoZe+1tJ/PX8lHSjR1c=;
 b=a944/2/4UMhiipq++Xb+BIc7ALwAYxkNcVgM4KA5bPdXkPRpUO8JPYSkgT2CDuNWeEgtKsKeO5OfXVslvxpwjawsmHpNhw+0/EUECHeZAe3eYzOsq7dU+eX1B8P5p8t4kjXd+mTogaFMmlV2ERb0pX7Oydk+sO/ONBVyAqoG6CXK/yjGVF/z5IHg+UXZcnqLDdBLmJlbPPjyM7eQZyMdRlLUk9n1NXSroBgYSA93/36Tae/BN/ZqRSKIs5s5PkcNBmy7covIE2AZh2DyBIfveVfRYd+VKdIGHJlbTp2f6xw1t6P4fGCc8LdBvEmwNrOfOZGnInWjPfTD2WRB+G18Zg==
Received: from SA1PR06MB11353.namprd06.prod.outlook.com
 (2603:10b6:806:4a2::17) by SA3PR06MB11086.namprd06.prod.outlook.com
 (2603:10b6:806:45f::21) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.546.22; Wed, 28 Oct
 2026 00:48:26 +0000
Received: from SA1PR06MB11353.namprd06.prod.outlook.com
 ([fe80::ff:880:c010:68bf]) by SA1PR06MB11353.namprd06.prod.outlook.com
 ([fe80::ff:880:c010:68bf%6]) with mapi id 15.21.0546.021; Wed, 28 Oct 2026
 00:48:26 +0000
From: "Mora, Jorge" <Jorge.Mora@netapp.com>
To: Benjamin Coddington <ben.coddington@hammerspace.com>,
        Jorge Mora
	<jmora1300@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "trondmy@kernel.org" <trondmy@kernel.org>,
        "anna@kernel.org"
	<anna@kernel.org>,
        "Bhargava, Rakesh" <Rakesh.Bhargava@netapp.com>,
        "Kumar,
 Mohit" <Mohit.Kumar@netapp.com>
Subject: Re: [PATCH] NFSv4/flexfiles: calculate stripe boundaries from the
 file offset
Thread-Topic: [PATCH] NFSv4/flexfiles: calculate stripe boundaries from the
 file offset
Thread-Index: AQHdY8EghguXFCAab0aeO1BzvWtJercQgFIAgAGi+vY=
Date: Wed, 28 Oct 2026 00:48:26 +0000
Message-ID:
 <SA1PR06MB1135333132B459F542BFD476AE16F2@SA1PR06MB11353.namprd06.prod.outlook.com>
References: <20261024140811.51694-1-mora@netapp.com>
 <17C675FE-0C61-412B-ADA1-882013ACC7B7@hammerspace.com>
In-Reply-To: <17C675FE-0C61-412B-ADA1-882013ACC7B7@hammerspace.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels:
Authentication-Results-Original: mx.microsoft.com 1; dkim=none (message not
 signed) header.d=none;dmarc=none action=none header.from=netapp.com;
x-ms-traffictypediagnostic:
	SA1PR06MB11353:EE_|SA3PR06MB11086:EE_|BN1PEPF00018070:EE_|SJ2PR06MB9527:EE_
X-MS-Office365-Filtering-Correlation-Id: c0bcb934-bbf6-4bfa-ef7d-08df348d2ec0
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam-Untrusted:
 BCL:0;ARA:13230040|1800799024|366016|376014|23010399003|261026121527099003|38070700021|4143699003|11063799006|56012099006|261021121427099003|261022105027099003|261009223027099003|10067099003|22082099003|18002099003|261026140227099003;
X-Microsoft-Antispam-Message-Info-Original:
 VJq2yEDBM5GxGCKrxMsfw0ki3ndAxi+8mqIJ2m+/E7CvewIzaBKHnIPGos/WhMK2nVkxlFRyUBE/9v12kEJF/kmPpskoCOXJdlhf2Rm0G4va43EYCOUCwarqdQ/5+xul4uWeb7lZEj+3CKDrxrVLrj3Hlx7qrUeokNxAwE1Axbr/v/8MUNXNBEBsq2EQn5HqSiRHy4mNgt98fPuoCTzDJvWtmEK/l7I0bo4AHjHiBUFvX/cBqiXnP1b763D8ruN4RYZApc05G90pU9CeUwOZ59C+lDCatXwdSihBeRj+SLv4StgzPmkI0iXPgWps5fDXZQfahISV/BjFdoZ8FDWyXB72BZgJOBFlxP22GV/Pp7lh8+Ju5H0N8MD5HEjpOi6yk9U2tMdUrBgWTjLyMwwfAPZb/k6P5FIGjE2dvudPKvBmoZ38t+ez4X84TNkyR5Qr0LMSOIbSFswhUlwT4BxcPTTJB5nrEHaayDn4PFHZQ/j0UccZ6FC6sz16rQYd60lqw9XYO8Pt9OhjJ7veECRSF76AALjuUcg2oa8C456TdtBje57bacpyyMZpf1p68uq6sfpKmxWaiNoIzaHP/Gmz03wJ5GxsTAgB8mr5raftQkpfuAg5X26Ioip5BDmgxvEq/EGMd9RGu+w56jpFJoaEEToOMO/OVoXI28ReCPzCvglQvTCXRW1yf5JxNmoxQc9OL6e2XoPoNwJquRh0zegx7uP8IhxVPlT1TGb5o00cT9U=
X-Forefront-Antispam-Report-Untrusted:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:SA1PR06MB11353.namprd06.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(1800799024)(366016)(376014)(23010399003)(261026121527099003)(38070700021)(4143699003)(11063799006)(56012099006)(261021121427099003)(261022105027099003)(261009223027099003)(10067099003)(22082099003)(18002099003)(261026140227099003);DIR:OUT;SFP:1101;
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
 Cll5yeP6SUYFUvRj1kkCtJCDqhTLb53fq5acHm3FhJN13vE7qaPqhb0dvKvumbufua7OBubZE9MpKdaTAfKfXNKmmyuz+1maAOau0i3JxCE6CmklQQg8Lt/PHcTlz5iJQ03vxJjsYabYFDLVmzkFSdkKUZ350dySraPzffm1e94TxBhd//hxHE7dhS36vepPdzWkCD6H6SJOePaDxQya5n9bsFNkVa8HMcJK30N8o/IJzRwtV3C4yR+FcGKg8qsJiXj5Qjx689PuKklKJ8Bn81evOAhnJse3kfXmFDpstHY3KpedIz6i1s3c1qqyJ9yu2fwiydmOVh9Rh6vmouYJPA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SA3PR06MB11086
X-Zscaler-Block: 0
X-EOPAttributedMessage: 0
X-MS-Exchange-Transport-CrossTenantHeadersStripped:
 BN1PEPF00018070.namprd04.prod.outlook.com
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id-Prvs:
	4e720c78-15b3-4951-3361-08df348d2d5d
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|35042699022|36860700016|23010399003|14060799003|82310400026|376014|1800799024|22082099003|261026121527099003|18002099003|56012099006|11063799006|261021121427099003|4143699003|261026140227099003|261009223027099003|261022105027099003|10067099003;
X-Microsoft-Antispam-Message-Info:
	CZV+z1EP72BoZK+87wRTgHIBVnNs5sLQHdKWK8WzjXfYakOLDFyOQ0JcJ5juy3P2k8HnwY60o0g3hFAoLVwKh0p/YGeS1geVCxM18e3VfT7xFr8Za4GxACPJGaXHQMI/qLz4q6uwChTdcsrxDFEwYZe2mkoGbZEOBcCXqq2Qv2bgI8HZGIS2T4UQyW9arj06UDP5sJBkmYfHi2+B5r/n0DsMjWZ0DHZ88CGFQWbUrpTY7dm0MNZGQisXVCnEFd8MKW+QQdGltmvAxt2ujAndhqEk7lND0+nqMu3zrvAPPpKgLdIWyviIaBVRCvw9JEGqe/fHX/9EgnXM5iNKk0rde0FwhU1WbtxiO6IwJC+zdE/6SfBtygt0SzPLFJrKTJCrqDN9jdz+LPvKff6xz9+pMyw72VUb81OijG4HsouIN2Zmga2tRrWO4ODJne7yqgVXGE+9rd5iczTCsAALigOMn7xzeSJUpmTSG5VAPdUiPj5tDsrzLxPaiZMm53A6XQ4yMJI4YOcROo3PbUdcqqH1+1wo/vCZRZtwtCVTBzk+vyCHnXadxEH1PgYfwjwxcycVZ7Emruaa2Xck/OqDLp8IDk4oB2HRooKhDmF/YV47KZCUfJtX9vpBJjigzeFeZUDNkS6HL8LoeBfe0GrYL0l1wOPqJhAuUTdDSoJtwHJxFuhej3KwNKK0DB3EHzrMFXkxAWVfYzQoIY4FByRV8yaLqQ==
X-Forefront-Antispam-Report:
	CIP:136.226.152.57;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:was11a5.mail.zscalertwo.net;PTR:was11a5.mail.zscalertwo.net;CAT:NONE;SFS:(13230040)(35042699022)(36860700016)(23010399003)(14060799003)(82310400026)(376014)(1800799024)(22082099003)(261026121527099003)(18002099003)(56012099006)(11063799006)(261021121427099003)(4143699003)(261026140227099003)(261009223027099003)(261022105027099003)(10067099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	GeDOaZdMbw8yF/DVHqaFrLgu4LIZ0FGybuqdxUSiJ9YCY1CY73+fqOkdH1g7n9Ujfn+v1YE/gXknTdOT3oysnfZw/uRi2sCmh7PjM/l/8kdpMagWwzyOv2BffOKKVj7XIPYuE1Y2U8gX+ehEwNWbcTXMg3WAQFk1kQojIRsnTM1b4ru/iQBQW4sdYei/20sb/5jS5j5n17UDJMiTc4fcAUQkZYhhfVAdWgBmdTQd6CdUul6ZOY+rXiCdFtmhdIKYif33SOPGZvyIFILgEL5QM7+jvLhUQ/oaexoPN6kN0nHAC1IaguIeqSeuYEonUDB8kh2UvREPvGh8l6AN/Kq8S/i0qbhNohApGE/++uXa/11EqLQ/8JOliq/FKJd9Yjbk56uWqz7REMvjuYW1PP4kE0/jViBtFKYa7dGzYMZZlzJkfI/hNCJqd+cn/GEU3f+K
X-Exchange-RoutingPolicyChecked:
	kUeYSvC0P3HJrNInH0YWr1InCD3i+oFdIoi8UuOV6gMup0pgYNm+fo2y4KWKslCWtBMGHHYUTTJOxDQ+IKwgofmoLUqGXU1/YqvpDepyhd0LfnTcbgR++rWJVHUYc44yuvo18Bhi8RD1P3mFqk7R5sgZCfXQF+RTrd6hDG+/dmOV3MsP+aZXUvuHCXSjR+ZeYLcNcZAjtybkKME72xC4dJmf5yArq3QND3v4oWlcc2j5/k1SloPDtv+/ADNUkhHhtu4C6GcHoXg+XSjLwYpVVpGT3S/vEsF1sE7bvOwIU3Rq9lK7nlDiWSeTQYx9JBstHAObbLIVcxlhiEIJP5bYIg==
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0:
	z5PYk37FMYqjMbG6NDgwTwYvTxzl9Mshxe/fLKsSlm/K41WGkMiVtbybKx2GrbSGWPjiy69gMusd/TPHtgllMxB3ndxvxQD1MDfCDregtdkAaqGm8c0BDxrN1TMG/AWpP/d0T1VjP4yflBvFbYw0FoAYxeX7NBy9yjyx4vpASS3928P0Z/6j4Jocw2oLkKQZHZBwwfjNm507u0JMw8BGBLgaeRmFZuu3q7hlad0ODsYH+U8yud91eGWhpwtvYJcAjmsQdG3iXsUvWec17H40P5qPAMmmT6gkPWIjrTDRCUY2/XFAhVFFrmPR3ey2np5CTqg7/DRyHtAA4xb/4HAcYSxRHdPj1SbuZxBKMrFc3BAczUFNpC95HZNccFtgCHqM54CjwSMJRznkjoCnuII9Jj/Pg4USzc9CCL42DUkKfiWmjB1sZBudHmMhLm1irk7+gzvq2kqT+Mxa6lHaOy85dkCYc9yolm9YlXhF6jGPG17vY1F1f6vkMmCxbiTIE0RJUQQrH30MeIf1RP5k/Ol+lIEWJB65L0l/AFhQbFyShBo+zFUGVKdThxehXXQ3Vn8JPtN+k6KE8SGziKLu0ZwudpqzPdcXMySYKTDHF3tchR47ugUg73UzrB4WK+6+qUX7
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 28 Oct 2026 00:48:28.8717
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: c0bcb934-bbf6-4bfa-ef7d-08df348d2ec0
X-MS-Exchange-CrossTenant-Id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=4b0911a0-929b-4715-944b-c03745165b3a;Ip=[136.226.152.57];Helo=[was11a5.mail.zscalertwo.net]
X-MS-Exchange-CrossTenant-AuthSource:
	BN1PEPF00018070.namprd04.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SJ2PR06MB9527
X-Proofpoint-GUID: BjKQkAUAnmZ79ROUdtXf1yfbOmU4rXpS
X-Authority-Analysis: v=2.4 cv=FuWQbGrq c=1 sm=1 tr=0 ts=6ae14660 cx=c_pps
 a=cRSuPULe8LMj8fTR+fkUeA==:117 a=y2qyX5seKirFBAuOJ2n+PQ==:17
 a=6eWqkTHjU83fiwn7nKZWdM+Sl24=:19 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19
 a=xqWC_Br6kY4A:10 a=N659UExz7-8A:10 a=660iZSQnnn4A:10 a=GWG4Yq0kndkA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=1lWG0UuNQvn8UhQ8Wh4S:22 a=SqyuW1mdmu-nm073FuYB:22
 a=SEtKQCMJAAAA:8 a=VwQbUJbxAAAA:8 a=JDjsHSkAAAAA:8 a=eKe13DaGcdewVyH831AA:9
 a=pILNOxqGKmIA:10 a=kyTSok1ft720jgMXX5-3:22 a=dseMxAR1CDlncBZeV_se:22
X-Proofpoint-Spam-Info: AW1haW4tMjYxMDI4MDAwMiBTYWx0ZWRfX8TuiQC0HNDPj
 F+EptMpHVxudRXtmjgH05nlhWRrLTd3xmOyYXssoZCdF3oCeYRT/vKkIeyFkL9CQCU86KcrU5RW
 hKawQSSVDRJX3ynf83TD/N3RlcL3tBY=
X-Proofpoint-ORIG-GUID: BjKQkAUAnmZ79ROUdtXf1yfbOmU4rXpS
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYxMDI4MDAwMiBTYWx0ZWRfX2CipsyTDBNGS
 Mcn4cUto/1kCytdxsfVsyIj4JFewTzjUbYK4309e5lBKfNKm1GEYwcpVCCKgL88YfHJhCNN9LV0
 9/+++9bcvrVO57v9svY1NpjRq6WmhaI3jbE1x+0BqAzNAz3Oww5kTN+kUU8Mtqr/ioGdgMHjRc8
 hZwz1Eih9E9lzo50XJN3Gq2bfV2T7RNccRILgesZKmUxu/8YcuZ7MTUBDp3N2KglG8qIGcO7jK6
 QkwZWbICesk7Qh4BySJo2jMmiQvJzoGfzj+/XcsbOYDMaiaBNmOo0QzTpokRjB42Tfdy89w1GAf
 kQS3TM0NuE1gd8VEpJW540tfa/boqz9SUeXzYsRBxn/Qnbgy7whjvzQhKhPVMWowQwO51E5be/r
 2Qz0+QFvAvt5scziuOWJNC28hKf0JFj1dOUrDPfXLIFkXNkSjDba/HWXn4nUWXn6iXjQjx+RJdW
 z0VjP7PpxTxeyuRj1Jg==
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.138,FMLib:17.12.100.49
 definitions=2026-10-28_01,2026-10-21_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 phishscore=0 suspectscore=0 lowpriorityscore=0 malwarescore=0 spamscore=0
 impostorscore=0 adultscore=0 bulkscore=0 clxscore=1015 priorityscore=1501
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2610190000 definitions=main-2610280002

Thank you Ben! Hope you=92re doing well.=0A=
=0A=
--Jorge=0A=
=0A=
________________________________________=0A=
From: Benjamin Coddington <ben.coddington@hammerspace.com>=0A=
Sent: Monday, October 26, 2026 5:44 PM=0A=
To: Jorge Mora=0A=
Cc: linux-nfs@vger.kernel.org; trondmy@kernel.org; anna@kernel.org; Bhargav=
a, Rakesh; Kumar, Mohit; Mora, Jorge=0A=
Subject: Re: [PATCH] NFSv4/flexfiles: calculate stripe boundaries from the =
file offset=0A=
=0A=
EXTERNAL EMAIL - USE CAUTION when clicking links or attachments=0A=
=0A=
=0A=
=0A=
=0A=
On 24 Oct 2026, at 7:08, Jorge Mora wrote:=0A=
=0A=
> From: Rakesh Bhargava <Rakesh.Bhargava@netapp.com>=0A=
=0A=
Hi Jorge, Rakesh =97 this is the same change as "NFSv4/flexfiles: Bound pag=
e=0A=
coalescing on the absolute stripe offset" (v4 06/24 of the flexfiles=0A=
device-notification series), which Anna has in her linux-next as=0A=
a84c62c4f037. Your base, 18a80121193c, is from Trond's tree and predates it=
.=0A=
=0A=
Ben=0A=
