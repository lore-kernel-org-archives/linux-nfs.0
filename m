Received: from mx0b-003fbd02.pphosted.com (mx0b-003fbd02.pphosted.com [67.231.157.221])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3A3ED3A59A7
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 15:52:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=67.231.157.221
ARC-Seal:i=3; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791474772; cv=fail; b=GHrhf6zKQuUjDAJ1NQaAnRn5L5X+Y8hwGd83M/+ljBlUxb89UNNo3AYZM+kLd1wN6TPZefkP7SyIiiBIRpP4T9e/OtOpQhHoOSL3c+zTm1BHMu9p0tCPE7u9UTk3rg46S0OAsiu6W3hjVh3oS2oHx7dhiZqi6Tnu6hZTTvcSTus=
ARC-Message-Signature:i=3; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791474772; c=relaxed/simple;
	bh=7jgGldpEM01fALq6gVG0r17gyVpQAFV1IczZpoCNPQo=;
	h=From:To:CC:Subject:Date:Message-ID:References:In-Reply-To:
	 Content-Type:MIME-Version; b=qdt4wNu7PMlZFZkmXPo/pucUEWl1oWkxBYs2PVeVk5hgrwrCb/eRSIizJl6onaUQQMiAzEx9KCHFxlMJyi+ZPVrWqE/P1tg0yvjRq5LNaG7or4CHFOr3V0SEa2pY93ay7J/uESoCaq7xyX7HSwARf04EFCAfHdVwU8g0p2wBwA0=
ARC-Authentication-Results:i=3; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=netapp.com; spf=pass smtp.mailfrom=netapp.com; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=Jbw74/fV; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=QDcPSVcM; dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b=QDcPSVcM; arc=fail smtp.client-ip=67.231.157.221
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=netapp.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=netapp.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="Jbw74/fV";
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="QDcPSVcM";
	dkim=pass (2048-bit key) header.d=netapp.com header.i=@netapp.com header.b="QDcPSVcM"
Received: from pps.filterd (m0412383.ppops.net [127.0.0.1])
	by mx0b-003fbd02.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 698EW8Dt106121;
	Thu, 8 Oct 2026 15:14:23 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com; h=cc
	:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=pps1; bh=CPRNg
	CgHDJWXdmsn5izKTkeQXYIOy1ZitMzXnWJHQnQ=; b=Jbw74/fV3SVkI7MovV3ra
	mVbeQB3pE7Wc6vdsV+hXWUYbHqaqKT/HcSgNn6zp5KRb9hBJbQ/AG0A8IdXG2ENN
	ChN6b97xVXP0TzPsVzBOMgLiTyUNpZOXDvAbJZEejTFdm0Qu5PHiJFoD3EzhPQeE
	QHaeFr/vKGZLsRGMC2xAmbNnbJtF7foGLTNwRROBhh9DEVufvbE2lZzLwKNezmcS
	93LGupC1/ZuoxV9lmWm15cNp47ZDO6qFevgbz7kXzRUiQzBx0+E1wP8UtEYr8VH8
	1hyx5nOrZsJw56611ATPRgm1apyc4bHbBcE6AZp2jc9H/l1sz7WbFooysa1CEyvr
	A==
Received: from ch4pr04cu002.outbound.protection.outlook.com (mail-northcentralusazon11013054.outbound.protection.outlook.com [40.107.201.54])
	by mx0b-003fbd02.pphosted.com (PPS) with ESMTPS id 4h6ca40bxj-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Thu, 08 Oct 2026 15:14:23 +0000 (GMT)
ARC-Seal: i=2; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=pass;
 b=YhQUWKf12JgPUW34fNYKdt4Jm7IGtdmnfYQREAvx2XaZeZXIkMmQFJ4++L4h/dITR6i+buVZnBusQMY9/ZUt7/5+Ja0KkVvPerWGoMDjOcDxJhq4/MaJUeMx7dHLRBLuiEO3EbvgNR6XUHgYTueKLyys9cLklUkaVpymDyKPCYU0dnByyfgwfEvxMbbLR3nq21k2YEfzSUD54QU9MJrIhLKx6yOnB66OKsFhKLgAZnU6y+JKg6x757OrN7UXX1Vz2e9NoZPtx0oX+Xi9UpcffYkX2Ayqincv7ZwAFfPaxaoBJTF3ttiqDANgJrYdX+DCuU/WTPJsTrx8pEIYTx+PAg==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=CPRNgCgHDJWXdmsn5izKTkeQXYIOy1ZitMzXnWJHQnQ=;
 b=mrAF/1NTeKmVN5fzLZix738POusCNQACpFPW0qlGxx4Lc2sJHrRAGLBkD67rRNUB/OgQSc+woW30cTpYH5YHCdW5flHaOzdH34YeUVtRyiov+JsUzVgLMWOlTWRJtp7LT+HUSY15obGnV2VqnuGvsm7OVAM17W0aInp7RQ1BcaXh3wDx8Dj16uyg++9Nw25JkthGEjqn2kWkiHZ/N4glpCHGuebujVGQYeytNQmZGoQmI6rQ4eLQxeRtaYpTUqzJ/6oDRukbBFuVamliHUih6f9X2l1bagkNGH3spouwjrQArgQg8qn6hcXF6tiFA3kHAQLJo/sHXu22MFxd67A/+w==
ARC-Authentication-Results: i=2; mx.microsoft.com 1; spf=fail (sender ip is
 136.226.152.56) smtp.rcpttodomain=gsacapital.com smtp.mailfrom=netapp.com;
 dmarc=pass (p=reject sp=reject pct=100) action=none header.from=netapp.com;
 dkim=pass (signature was verified) header.d=netapp.com; arc=pass (0 oda=1
 ltdi=1 spf=[1,1,smtp.mailfrom=netapp.com] dkim=[1,1,header.d=netapp.com]
 dmarc=[1,1,header.from=netapp.com])
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=CPRNgCgHDJWXdmsn5izKTkeQXYIOy1ZitMzXnWJHQnQ=;
 b=QDcPSVcMRli/cQHJVLMs8Szvi7aCnEtN9M1b/96/AoTolU1UIB9qiViJNv/5HfH7KzPHmAn8fW+GmJDN0D9PijStGM+/+n8doeDxkY2QOMRa6IyY8HF0Jwm3m1tbgArxZHba9WliUQSBY0Rfc/VGnm7K5qdVp/1YAY/Jt/IWx8iFpgcTD/ppsmoPovIPmm6P5wNGTJVxC90qT/PH9tWZu10ncvDVLFnOqVYc7A24VfFQ2OhHHmfa23cV4xZMElu0A/M/qpwrL3lALP6gZaiKjSWpnnWZNDPnv3t1SFI1ryukS0SfQ93WL+Op09K29BjMQjbkzlawaWm1gQ+nY6bWlA==
Received: from MN2PR22CA0021.namprd22.prod.outlook.com (2603:10b6:208:238::26)
 by BLAPR06MB7012.namprd06.prod.outlook.com (2603:10b6:208:29d::5) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.496.17; Thu, 8 Oct
 2026 15:14:18 +0000
Received: from BN3PEPF00022BCD.namprd03.prod.outlook.com
 (2603:10b6:208:238:cafe::68) by MN2PR22CA0021.outlook.office365.com
 (2603:10b6:208:238::26) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.472.20 via Frontend Transport; Thu, 8
 Oct 2026 15:14:18 +0000
X-MS-Exchange-Authentication-Results: spf=fail (sender IP is 136.226.152.56)
 smtp.mailfrom=netapp.com; dkim=pass (signature was verified)
 header.d=netapp.com;dmarc=pass action=none header.from=netapp.com;
Received-SPF: Fail (protection.outlook.com: domain of netapp.com does not
 designate 136.226.152.56 as permitted sender)
 receiver=protection.outlook.com; client-ip=136.226.152.56;
 helo=was11a4.mail.zscalertwo.net;
Received: from was11a4.mail.zscalertwo.net (136.226.152.56) by
 BN3PEPF00022BCD.mail.protection.outlook.com (10.167.248.169) with Microsoft
 SMTP Server (version=TLS1_3, cipher=TLS_AES_256_GCM_SHA384) id 15.21.496.14
 via Frontend Transport; Thu, 8 Oct 2026 15:14:17 +0000
Received: from dm2pr04cu003.outbound.protection.outlook.com ([40.93.13.57])
	by was11a4.mail.zscalertwo.net ([136.226.152.43])
	with ESMTPS id 6AC7B34908F60002;
	Thu, 08 Oct 2026 11:14:17 -0400
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=t5VudIgSjSzTg5N6/741ytcYedJEDKaiAuAK3Y6jq+FVvnX2br7In/bq0uTmKUIQwG+GI9XEBPtYnYyY0w9k3aqyaUeBPvh6c2L8euXXgZeNC6L/2fLd6dF9BPZ9Vm97gE6Ah3/lmFqz/30mQqmNKz/ENDNPfVlwlZy7hje3WJ50nTYC/ASXatIxNeSNlO2xdphGcP3w/d1lOdVwSxzWrQoXqK7FSSBp+nq1fnYV90TX4lD02LsoXLO+y2b+jP9uswGmRqsXwShQgif6q3AaConZJ3FHdmN/41TYOxm5/MKP8dx/pf3RXSvFqsBOH0PDzlTWxczrikBBGoSmEITazw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=CPRNgCgHDJWXdmsn5izKTkeQXYIOy1ZitMzXnWJHQnQ=;
 b=qctMFGZrz0wDqSbeH6dNtZaHcJ9vtg0Cyf7yDRbG/c+N4XwXs6MiGcNNH6A5Iwla/oPHcBT1AvTI5cr5BORhrrlvdmuhfujLs1F/W5SFa+hL8FuTVHILv61Yd4FuUfX9ycaWQ+CvllAaVULh/HnLdtmybaPAgdiFWBxG37b/urVRQQDXsZbUfm2z1M2sxKn+MzsaXsAWm+tmkKpotkv4lJ4v8kV6TzOQQNhZxBKg3KU82Q5bMPIC7dStbUv38Si51QjG/9lWWhPShQTkItB7/qwNW1lkCz5ObG8h95mli1wz6M1sLPeJ5IU4hmwTpfGfshIbhHccaVo1rKSenG9Jnw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=netapp.com; dmarc=pass action=none header.from=netapp.com;
 dkim=pass header.d=netapp.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=netapp.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=CPRNgCgHDJWXdmsn5izKTkeQXYIOy1ZitMzXnWJHQnQ=;
 b=QDcPSVcMRli/cQHJVLMs8Szvi7aCnEtN9M1b/96/AoTolU1UIB9qiViJNv/5HfH7KzPHmAn8fW+GmJDN0D9PijStGM+/+n8doeDxkY2QOMRa6IyY8HF0Jwm3m1tbgArxZHba9WliUQSBY0Rfc/VGnm7K5qdVp/1YAY/Jt/IWx8iFpgcTD/ppsmoPovIPmm6P5wNGTJVxC90qT/PH9tWZu10ncvDVLFnOqVYc7A24VfFQ2OhHHmfa23cV4xZMElu0A/M/qpwrL3lALP6gZaiKjSWpnnWZNDPnv3t1SFI1ryukS0SfQ93WL+Op09K29BjMQjbkzlawaWm1gQ+nY6bWlA==
Received: from SA1PR06MB11353.namprd06.prod.outlook.com
 (2603:10b6:806:4a2::17) by MW4PR06MB8451.namprd06.prod.outlook.com
 (2603:10b6:303:12c::10) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.496.17; Thu, 8 Oct
 2026 15:14:14 +0000
Received: from SA1PR06MB11353.namprd06.prod.outlook.com
 ([fe80::ff:880:c010:68bf]) by SA1PR06MB11353.namprd06.prod.outlook.com
 ([fe80::ff:880:c010:68bf%6]) with mapi id 15.21.0496.015; Thu, 8 Oct 2026
 15:14:14 +0000
From: "Mora, Jorge" <Jorge.Mora@netapp.com>
To: Anna Schumaker <anna@kernel.org>,
        "linux-nfs@vger.kernel.org"
	<linux-nfs@vger.kernel.org>,
        Trond Myklebust <trondmy@kernel.org>,
        Olga
 Kornievskaia <okorniev@redhat.com>,
        Scott Mayhew <smayhew@redhat.com>,
        Benjamin Coddington <ben.coddington@hammerspace.com>
CC: "rushil.patel@gsacapital.com" <rushil.patel@gsacapital.com>,
        "tim.saunders@gsacapital.com" <tim.saunders@gsacapital.com>,
        "mark.brading@gsacapital.com" <mark.brading@gsacapital.com>,
        "ben.roberts@gsacapital.com" <ben.roberts@gsacapital.com>
Subject: Re: Close-to-open consistency on SIGKILL
Thread-Topic: Close-to-open consistency on SIGKILL
Thread-Index: AQHdVSBlpS+KtLjd9ki6JO7yF3rKErbxAeUAgALDDm4=
Date: Thu, 8 Oct 2026 15:14:13 +0000
Message-ID:
 <SA1PR06MB11353080992DEADE0E7E9FA67E1932@SA1PR06MB11353.namprd06.prod.outlook.com>
References:
 <SA1PR06MB113533BFC97DA85AE6D37D99DE1962@SA1PR06MB11353.namprd06.prod.outlook.com>
 <d39afd89-0543-410c-8c3a-c8869ba643bb@app.fastmail.com>
In-Reply-To: <d39afd89-0543-410c-8c3a-c8869ba643bb@app.fastmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels:
Authentication-Results-Original: mx.microsoft.com 1; dkim=none (message not
 signed) header.d=none;dmarc=none action=none header.from=netapp.com;
x-ms-traffictypediagnostic:
	SA1PR06MB11353:EE_|MW4PR06MB8451:EE_|BN3PEPF00022BCD:EE_|BLAPR06MB7012:EE_
X-MS-Office365-Filtering-Correlation-Id: fef2a843-a2ce-43cc-d5c2-08df254ed293
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam-Untrusted:
 BCL:0;ARA:13230040|23010399003|376014|7416014|366016|1800799024|56012099006|4143699003|38070700021|11063799006|10067099003|18002099003|22082099003|3023799007;
X-Microsoft-Antispam-Message-Info-Original:
 mZZlsz8tUN9SDTEST9nwCJhX25wyVWy4AJIx1yhJHY/PVI4LDIjGKXmibucCKzk+8UB/ZOCRkOyLt+awLYZwjX9/sg6u8qqZcnGClt9PXBA6qWKJiJ8BtFYbWCupdcjmJEs5E9ngQC9btWwFhXk6KZzJjP8SEB4lFhk7/Cq59MVVhJxiyR+CSIAJZpd2u9YawoSmSq1qMWbzppOo1r5CbxA+3pgsX0U2px/A20o/dj3NUKgDBRXWyK9cin0cnkmnqPcuAyeP4RVrm7hbWI/stU278QENoRQzx2a7QnOtzpGxjGkoeyFqm+6KBR8c6/6CJVLm+Eo1pe722K/dCzBJWpyU2tQFcoXhA5rjUuCTng7S+m1z2qP3FXrFKRXksH3/Ia1mzO29jYr0tbB5lT3+KrIzhiPL3gLYABtnSIQiMF1/42WFQcJT1dLcKkRsqynplIXtW/sT1yutTmLBF5mfhuXV2knGg1+WEXhlJjxNhunw99UVanCLHMhOwyDa4gcbU1i36tEYlaJNBfcdjI772wiqa+k7XL8NkddktykWsOiKbWBnUVIfQQPddrxSJY9TJW9yMWVThSmatW578IYBfvlt8JsNq0KSsvgFjO/rf01/RlBvZFjoSfjFss6zKNCyS5KBUJkXlGud7U8DgIxNr3Avk0Qyckl+Y/qlA1sdiFc=
X-Forefront-Antispam-Report-Untrusted:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:SA1PR06MB11353.namprd06.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(23010399003)(376014)(7416014)(366016)(1800799024)(56012099006)(4143699003)(38070700021)(11063799006)(10067099003)(18002099003)(22082099003)(3023799007);DIR:OUT;SFP:1101;
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Exchange-RoutingPolicyChecked:
 gIvPeBCUJdpJIj5LzRYyFqV18px2kOnP5iv6X80gY9hoz0lIMOX/rVlL+0BaWHXiJP/FIThyUYfJFYdhf9joZ0z3nfznTr5KmkWg+xh0PRi9S9AR5iDnnzbpBxvS3P4rSjaLdWTq+hUfr4rLMtHmA+cnYi1EXb6OIolIG2QuvlUpGIjatNPgP6vbmM5a6/Nce9BO0MFyYNuybT4gNhBcQ8cdpcGolWR6sXkhuBsSUncdNjUxDKTTAMrdLWJ2xSgOylTZwQ0Fuwq/ZCFCfs+I+H2y3DUyiUCXcxEtByIRL6tmUiNIOTN+/nxwJFwQRgqFY8tCZV1IN0SAtgUQjeZEUA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MW4PR06MB8451
X-Zscaler-Block: 0
X-EOPAttributedMessage: 0
X-MS-Exchange-Transport-CrossTenantHeadersStripped:
 BN3PEPF00022BCD.namprd03.prod.outlook.com
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id-Prvs:
	52979fa1-bdc8-411d-fe0b-08df254ed02c
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|376014|1800799024|36860700016|14060799003|35042699022|23010399003|82310400026|56012099006|11063799006|4143699003|10067099003|18002099003|22082099003|3023799007;
X-Microsoft-Antispam-Message-Info:
	KJDXj8oic58wkdmnj3Z4inhPAN5aBni2E/uJr0iOMaxE2xcf5BNcTrKb6ZYl/U9OYdqoQNeBFf3S/vZ2hX8h+UTewtiod1I72b2/784/PhKf+wlKrDKklExZHkL7OKGIMN9iGZ/UoCwl0V4dNlCcX0JqcXizmqVi9ItBSwwQEfnQqz73S8lINxdpJfqDRHvx4wpBtLWdZb4feYg60L0/mZKJ0gO5MudhREGbcQHR9pS94JtmAY3JEkTtpcse954Fn7UDSFmfwj5uKfj5F1ciHBDKIVB3fdDjSPWVWn0Zg7h1v9IsFSgwOVv71BUD0oNVJEYYVVcbUZ5ttPT7p5HzV+9lSn4RsIhPb9fk8xC5NjNhrxyJ8tkZdC0ttb2oCh8Ve5uXX2DtL+3oWVmKswcP5R9OORAfyLvIY7hn5SdMYJG7eRexiIZsKyKgVfBm34BpGFkXetKlv7VMQIm9JWyV1yfDkR5WDIAcSKkcE2n3RSePUlsXZNvWWh4C03DBFFlTg+7qI4FEKn/AxSR4LJCEFO+nBVEX2pzn0TRnZsgHfJSxYmz4XMk5FJCX9sXg35iGxg+d6gCjaPZ++wV1VYucj7a1f1XleZupBHqPmoB9f8SYKGVLlkKKSMyQFwsGkS+4ca5Uu687MLjdpCbM3bpoxw==
X-Forefront-Antispam-Report:
	CIP:136.226.152.56;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:was11a4.mail.zscalertwo.net;PTR:was11a4.mail.zscalertwo.net;CAT:NONE;SFS:(13230040)(376014)(1800799024)(36860700016)(14060799003)(35042699022)(23010399003)(82310400026)(56012099006)(11063799006)(4143699003)(10067099003)(18002099003)(22082099003)(3023799007);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	D10MXh3N/kGE2z6mYCDfzJIIrr/2nXtfLIwxqRYINoZsfwfYX/6T6MiqYLgipmfFAL/ZoqP3A86uGPM02ElTW+Rv0L8rEyOoqHkKVQt6JMYRrnYtBqKcUwUs3zVGIfz7u0nt9N5x6WsB0D/5su5u8+EN4KVjp1MsmPrmwE7tOKwmfkivnBIdH51KNCngn/nhuDFuVO3RvnlbMjOYvTlk6v+FFZaIo6/RTup+coq2b5i5+pDXCl0y9eRmce2eOEISf4JhQiotrb1C6KJr5kRyx6gLSlMdCXfJQvcdqdUC5979gspbs1imrSHJvv4mpU189OC5o05BhvAOu0EYPMd5naPHj2WH9Y/Ctlea/ujPapXSk1K5tplrErEB5v79lLZlOkjxuOZ4VhRF+oNM2Q9SsVxw1bQgcTA2lcX7hwruTV62OjAa8Djs41a16VHviYYn
X-Exchange-RoutingPolicyChecked:
	t7g0VOu8Ox0c8+sV7uM1R+zR5Xg9yjOImMgX1xBg7cWTH9WZ977SIEvde/RNu/98zb9lFQ+3CqUYxD6IQ/oeIP3mV4HACalfnDJGAB5166WeWHNoVKdnX4JwARqhsrLPenDr1N8PtfHNf42Zp3XV+gTPfm+xqfq8B6wG8JMBQJXlXFWxiFnoV5zEkfwi62S85Hj3T856VfEuDuz81PtvV6Atpm9WfnrY4RDffforbxvWab0WUxSDUdJX3iYXwjBSkjXpnxN8KlvtYVGr9+xao+2w8hjq98OhIqfBEYHJwDGJJPWsj3WI6GAfQyTJLAfzGmuRc1wRSF2Enw0ZvZiBTQ==
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-ExternalHop-MessageData-0:
	G4QJjCuYSDy8V4xCcyaMSlfAwBUqc/9RPGX0IY338iukfNPSiYidRwEhuqk/CjnOseSxpzZTH2Ow0ubmWuGIO/kzL7rUCRBx4sD/KxS3jnZBigNZxvBZt9sOF+pfUgeUhvvyEtinLQaBH3lfWolq7SjCEUkHKvQRcwnlAx1ZO7HffDotrpRtBNgr+qfUD8C6jsRUbbZq2L1QKaGiMnl1OaVYcOzcLVmfR1VUvHxt2uxOFHNobe54tOk3hbZE9kEcWYXRdthYLEwHc4p5ynqZ6VijCw+sgCkj3qsP1gCCNGG/qhyDh+p4EAIfbfEJMOOsPTS1mam/qbTQ6C+HvElfl/bqLATx9g/6aHhrtscQfhquEw6ziVq1QArxHeRDE/3+pVK1sJFTlEO3N+5pdYezPyQC46m+qqCJYNWubXpLKKongkUevOomMMpJpW6FAcnszTA2FLzVqHFCxH9BMTvGYLdmNAzNkFsQdLl6bx957fK/OtFoA7RmdFz5xzuQHDsZgESXkMM2oaejQtncvHblftZxbwdSaEj+oSn0sITeu/33Rd9IJkazyJNbpmEJhRnmkK0b2sQxQWrKouKT6e9DZyNDkGPiH9/jL4Cn/fSCP6QrFRKYoPZSWU8hnyWSxclz
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 08 Oct 2026 15:14:17.9684
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: fef2a843-a2ce-43cc-d5c2-08df254ed293
X-MS-Exchange-CrossTenant-Id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=4b0911a0-929b-4715-944b-c03745165b3a;Ip=[136.226.152.56];Helo=[was11a4.mail.zscalertwo.net]
X-MS-Exchange-CrossTenant-AuthSource:
	BN3PEPF00022BCD.namprd03.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BLAPR06MB7012
X-Proofpoint-GUID: GPaBO24_7L7ssBVbCHym2mgZ_AplY9QZ
X-Proofpoint-Spam-Info: AW1haW4tMjYxMDA4MDA2MCBTYWx0ZWRfX6bgVOMS0E7Wp
 ySLaJUj+5AJWXk9NAS7vrtlcSBd4A7o+7FdcBjwyKqBRhZ4B1arl9i+dxNqGd5mJj+y8Tr0sp2p
 XiwkBkzkTi8zG+Wmx4m7OtVSXFfMgRw=
X-Authority-Analysis: v=2.4 cv=BYRNQbt2 c=1 sm=1 tr=0 ts=6ac7b34f cx=c_pps
 a=ikWRpWbkSoEIfbFFe8At+Q==:117 a=VFj4HkS9einQcKoZxhKFlg==:17
 a=6eWqkTHjU83fiwn7nKZWdM+Sl24=:19 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19
 a=xqWC_Br6kY4A:10 a=N659UExz7-8A:10 a=660iZSQnnn4A:10 a=GWG4Yq0kndkA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=1lWG0UuNQvn8UhQ8Wh4S:22 a=X7e-fZ-CKB32rjcIpVUG:22
 a=VwQbUJbxAAAA:8 a=aU7qV5IrAAAA:8 a=JfrnYn6hAAAA:8 a=b0mFJZusheAhyYxQ_kkA:9
 a=pILNOxqGKmIA:10 a=XeeNnEZWyIaKVUq9vuPT:22 a=1CNFftbPRP8L7MoqJWF3:22
X-Proofpoint-ORIG-GUID: GPaBO24_7L7ssBVbCHym2mgZ_AplY9QZ
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYxMDA4MDA2MCBTYWx0ZWRfX8NoI9iCwUfln
 Tk69xlS4Ht9IA1yYitNz0uEw3rsnCIqAE2GprzNnxfIcjeUxwGhaq25mgXXhwoZJNUyzhuLI0AW
 wbp8nedXwdCvMXrglKw+lUzytJ2R1nzZpZw6gXp+eZv8x1qilXS45wEFijlJYEAYszoecg62fPL
 3HcJYiTa3mbovgZUgazG1FW5zLnRDz484RZfbOc1oy6YJKGuSDBT1OeRborWK3yPD+EbTf2rPrY
 wn3Q/dUzstOwOxBhy9qCiwKn97BwjyDlbD8W86jzIXMXKmY7egxrMJ5vyGrNcWjx+uJPHS3dqI9
 2heVqtgfJ4B8BYGagmbr5WbWKDNARVwXVYztM8Dd749pPYnzIuVwA3hOAVNUEDMVufyjZdXj/NN
 ldmYVh1CCDnEo6nU+WZ+LJpdBZ10tybKfi/PHTj6oeOKgAfUxTcfBKLPmLWKJllNd0wVV6Z34oC
 u48fd0acHTLJeTrKZiw==
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1176,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-10-08_05,2026-10-08_01,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 spamscore=0 lowpriorityscore=0 bulkscore=0 clxscore=1015 impostorscore=0
 malwarescore=0 priorityscore=1501 adultscore=0 phishscore=0 suspectscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2610020000 definitions=main-2610080060

Thank you Anna.=0A=
=0A=
=0A=
________________________________________=0A=
From: Anna Schumaker <anna@kernel.org>=0A=
Sent: Tuesday, October 6, 2026 3:03 PM=0A=
To: Mora, Jorge; linux-nfs@vger.kernel.org; Trond Myklebust; Olga Kornievsk=
aia; Scott Mayhew; Benjamin Coddington=0A=
Cc: rushil.patel@gsacapital.com; tim.saunders@gsacapital.com; mark.brading@=
gsacapital.com; ben.roberts@gsacapital.com=0A=
Subject: Re: Close-to-open consistency on SIGKILL=0A=
=0A=
EXTERNAL EMAIL - USE CAUTION when clicking links or attachments=0A=
=0A=
=0A=
=0A=
=0A=
Hi Jorge,=0A=
=0A=
On Mon, Oct 5, 2026, at 7:38 PM, Mora, Jorge wrote:=0A=
> Hello,=0A=
>=0A=
> I'd like to get the NFS client's view on a patch that showed up on=0A=
> linux-mm, and in particular on how the proposed behaviour interacts=0A=
> with NFS close-to-open (CTO) consistency.=0A=
>=0A=
> Background=0A=
> ----------=0A=
> Rushil Patel reported that on NFSv4.1 (Slurm jobs, NetApp filer),=0A=
> cancelling a job can leave processes stuck in D-state in=0A=
> folio_wait_bit_common() while __filemap_fdatawait_range() waits=0A=
> uninterruptibly for writeback. If the server is slow or unreachable,=0A=
> the only practical recovery is rebooting the client.=0A=
>=0A=
> The linux-mm patch:=0A=
>=0A=
> https://urldefense.com/v3/__https://lore.kernel.org/linux-mm/202603251136=
16.785496-1-rushil.patel@gsacapital.com/__;!!Nhn8V6BzJA!Xl2GlCQUQklUBCYzpDn=
CMPGWagSPwub-YMfWvj2K03aSZH8M4oenhGrd74g-nS74uKf5Mz9g1eiDQg$=0A=
>=0A=
> The patch makes the wait killable, and also skips the wait entirely when=
=0A=
> PF_EXITING is set. The PF_EXITING part is needed because after SIGKILL=0A=
> wakes the first wait, do_exit() -> exit_files() -> nfs4_file_flush()=0A=
> -> nfs_wb_all() re-enters filemap_write_and_wait(), and at that point=0A=
> wants_signal() will not deliver SIGKILL to a PF_EXITING task, so a=0A=
> second killable wait can hang forever.=0A=
>=0A=
> Matthew Wilcox's reply (CC'd linux-nfs):=0A=
>   https://urldefense.com/v3/__https://lore.kernel.org/linux-mm/acQ0YRLM_S=
xYfjfI@casper.infradead.org/__;!!Nhn8V6BzJA!Xl2GlCQUQklUBCYzpDnCMPGWagSPwub=
-YMfWvj2K03aSZH8M4oenhGrd74g-nS74uKf5Mz_S6HeTrg$=0A=
>=0A=
> suggests that the PF_EXITING special case may belong in NFS rather=0A=
> than in __filemap_fdatawait_range(), e.g. in nfs_wb_all():=0A=
>=0A=
>     if (current->flags & PF_EXITING)=0A=
>         ret =3D filemap_fdatawrite(inode->i_mapping);=0A=
>     else=0A=
>         ret =3D filemap_write_and_wait(inode->i_mapping);=0A=
>=0A=
> He also flagged the subsequent:=0A=
>     ret =3D nfs_commit_inode(inode, FLUSH_SYNC);=0A=
>=0A=
> as another possible synchronous wait that could trap an exiting task=0A=
> even if the filemap wait is skipped.=0A=
>=0A=
> Matthew's take on CTO was that other filesystems do not flush-on-close=0A=
> the way NFS does, and that it is probably acceptable to weaken the=0A=
> guarantee for an involuntary termination (SIGKILL / exit) rather than=0A=
> an orderly close. I'd like confirmation (or pushback) from the NFS=0A=
> side before we settle on an approach.=0A=
>=0A=
> Questions for the NFS client community=0A=
> --------------------------------------=0A=
> 1. CTO on involuntary close=0A=
>    NFS flush-on-close exists largely to uphold close-to-open: after=0A=
>    close, a subsequent open on another client should see the writer's=0A=
>    data.=0A=
>    If we skip waiting for writeback (and possibly COMMIT) because the=0A=
>    process is exiting after SIGKILL:=0A=
>    - Is it acceptable that CTO may not hold for that file until=0A=
>      writeback/COMMIT later complete (or fail) asynchronously?=0A=
=0A=
I think that if the user is explicitly killing the application, then they=
=0A=
are already aware of the risk of losing any unwritten data. This does=0A=
sound like you want 'softerr' semantics for killed tasks, however.=0A=
=0A=
>    - Are there known applications or protocols that assume even a=0A=
>      killed writer has pushed data to stable storage by the time the=0A=
>      file descriptor is gone?=0A=
=0A=
Not that I'm aware of off the top of my head (but of course, that doesn't=
=0A=
mean they don't exist!).=0A=
=0A=
>    - Should we still initiate writeback (filemap_fdatawrite) and an=0A=
>      async COMMIT, and only avoid the wait =97 or is skipping more of=0A=
>      the flush path preferred when PF_EXITING?=0A=
=0A=
I would prefer still making a best-effort attempt to writing back stale=0A=
data since a slow server will eventually process it.=0A=
=0A=
>=0A=
> 2. Where should the special case live?=0A=
>    - Generic: PF_EXITING / killable wait in __filemap_fdatawait_range()=
=0A=
>      (as in the linux-mm patch), affecting all callers.=0A=
>    - NFS-specific: change nfs_wb_all() / nfs4_file_flush() (and any=0A=
>      other flush-on-close paths) as Matthew sketched, leaving the mm=0A=
>      helper alone except perhaps for making the wait killable.=0A=
>    Preference? Any other NFS entry points that need the same treatment?=
=0A=
=0A=
We should probably handle this in the NFS client since it sounds like other=
=0A=
filesystems don't have the same issue.=0A=
=0A=
I hope this helps!=0A=
Anna=0A=
=0A=
>=0A=
> 3. nfs_commit_inode(..., FLUSH_SYNC) during exit=0A=
>    If we only replace filemap_write_and_wait() with filemap_fdatawrite()=
=0A=
>    on PF_EXITING, does FLUSH_SYNC COMMIT still block uninterruptibly=0A=
>    on a wedged server? If so, should exit-time flush use a non-waiting=0A=
>    commit mode, and what are the CTO / stability implications of that?=0A=
>=0A=
> 4. Error reporting / other openers=0A=
>    If the dying task stops waiting, writeback may still fail later.=0A=
>    Mapping wb_err / errseq_t should still surface errors to other=0A=
>    users of the inode =97 is that sufficient for NFS, or do we need=0A=
>    explicit handling so that a later open/revalidate does not=0A=
>    incorrectly assume a successful close flush?=0A=
>=0A=
> Ask=0A=
> ---=0A=
> Could people familiar with the client's CTO and flush-on-close paths=0A=
> weigh in on:=0A=
>   (a) whether weakening wait-for-stable-storage on SIGKILL/exit is OK=0A=
>       for CTO,=0A=
>   (b) NFS-side vs mm-side placement of the PF_EXITING bypass, and=0A=
>   (c) what to do about FLUSH_SYNC commit in that same exit path?=0A=
>=0A=
> Thanks,=0A=
>=0A=
> --Jorge=0A=
