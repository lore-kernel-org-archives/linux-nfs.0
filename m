Received: from mx0b-00823401.pphosted.com (mx0b-00823401.pphosted.com [148.163.152.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5CE43280331;
	Wed, 29 Jul 2026 02:07:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=148.163.152.46
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785290828; cv=fail; b=rP/XHVHcynymznkVRhjX0qJQXxsPVA5t2TugH9zukEo90aUN9nPUMegQ+qEjTgle8dIrZptTk54ZS+sJnvxEiKQ4SIeTuZc/c/LgGkB1wRG5/mo36egxAb33S/f06FiDGc8mcc5xs8smg5oVAaH2UAdbH89lxoX72eDd7T5+6sc=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785290828; c=relaxed/simple;
	bh=1xyEUQTD5y3M8lTbP9eOhEtFeQ7wxB1ep2OF8KBisc8=;
	h=From:To:CC:Subject:Date:Message-ID:Content-Type:MIME-Version; b=hjcHNkFegbh5ZDVcF8iEjsU9KjIryfOJ6jpVZZjCwx6afWaXV62zzPDAIem71mJqOuw+o7sE3YOk9MsjciiDe3PpPoUWhJzC7UZSahDPoO61vOraQOMGrPvCd0gu1WWkUAUmzLyrc7e3r0bm0tr/lH8Cf7dAx7sfzeUz3JerAPo=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=lenovo.com; spf=pass smtp.mailfrom=lenovo.com; dkim=pass (2048-bit key) header.d=lenovo.com header.i=@lenovo.com header.b=YRd56EDl; arc=fail smtp.client-ip=148.163.152.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=lenovo.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lenovo.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=lenovo.com header.i=@lenovo.com header.b="YRd56EDl"
Received: from pps.filterd (m0464639.ppops.net [127.0.0.1])
	by mx0b-00823401.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 66T1HhTs006407;
	Wed, 29 Jul 2026 02:07:04 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=lenovo.com; h=cc
	:content-transfer-encoding:content-type:date:from:message-id
	:mime-version:subject:to; s=DKIM202306; bh=1xyEUQTD5y3M8lTbP9eOh
	EtFeQ7wxB1ep2OF8KBisc8=; b=YRd56EDlqyaTx+ET8/H9XVbK83+KmGr8ghnx3
	jz0I/8gd7b6gX3Phvx9i9oYp/R4LfT7upz0cFLEdylHeXpmYIxiJKQ5zQZDxS9ME
	KW0J0LfxxCNHzIYzGrQXFlverH1omqlhEk21ZP/MKuk/NbuBt2Cy4dUsObjbEg7Q
	ITvU+q90iUe9I42jN7n5wJrRZ6W0Nof4YEwir7pX5KCFKsLnz2mmnKcwCMe5hUw0
	NMItZ5vaE1j0+A5hC1KQT/jdvVlfezOWZjBR46nOM1Q+CP4CHNHQAvKoz2HF5so4
	j1DcrU2ToqgZkJZS4zw1ixuRhms9NrAzxHJ/zaq3Ldkz/qJEA==
Received: from os8pr02cu002.outbound.protection.outlook.com (mail-japanwestazon11012023.outbound.protection.outlook.com [40.107.75.23])
	by mx0b-00823401.pphosted.com (PPS) with ESMTPS id 4fnac6p1f5-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Wed, 29 Jul 2026 02:07:04 +0000 (GMT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=DZS8Ma7Vson02IuQ0WYWDOMHBRyeIn/5JJN/3Gu3SJb91W8QfPbWGF6/YWuSP+bTUosk3f3pIQloofuY4c8rMofgIVGDM2iux5aiBJoFSqlqvB0rJ9/ZFECbsbVJQGqx1DbY6atBQ86pLe944zZIpTKXPxl74nLu3S/Z02AJ5GkLPHDgauIXGP85Yo7Oqesh5Rzi8vMPWx+8TBno7YLMViyBbnHBZQhXoskx2g+YjWiih2kZb3CxYEtzoE7hCEGF/t67UHuWgl/dazCPi6tUxspbRu/qFQZKV7byNEzMbA2cS9MhrBVtH8RTEFgx3Pn1uyHHXQ0a4uIPZK6GhgLcxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=1xyEUQTD5y3M8lTbP9eOhEtFeQ7wxB1ep2OF8KBisc8=;
 b=IMPEyECt5v0KVJegBIhChBQ/abglUjA0QSeheV/xUnp7HWlOCOMGOecAkjje0U0X8G43GVuiBA2ecSHu3NmMGM0O/qbBb6HTnVN8hyyajVPoRs/JR/jXO58j4YPo2nL/giCcJq0+C0aIWc05F7ifjkWI0/7IAmW9ag7CdV/rLcRoGJPHZIkLktHKLXPgVnhfzEdWNMMymxf/9rbClN+Qcx+mSXtVNFzpWn6G3qUKIeuLa/VTiRDMn3VrOiSuCl251Skeo3+R8hmRacu8a2O63H1MUeei08RPp1OO32mUp3ZHvnA1yuCp/5YDLJ7dBpYML/1da4YvQvPJQuOj0HndaQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=lenovo.com; dmarc=pass action=none header.from=lenovo.com;
 dkim=pass header.d=lenovo.com; arc=none
Received: from KL1PR0302MB5202.apcprd03.prod.outlook.com (2603:1096:820:4d::9)
 by TYZPR03MB8614.apcprd03.prod.outlook.com (2603:1096:405:af::11) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.270.12; Wed, 29 Jul
 2026 02:07:01 +0000
Received: from KL1PR0302MB5202.apcprd03.prod.outlook.com
 ([fe80::923d:4104:30c8:d4e8]) by KL1PR0302MB5202.apcprd03.prod.outlook.com
 ([fe80::923d:4104:30c8:d4e8%3]) with mapi id 15.21.0270.009; Wed, 29 Jul 2026
 02:07:00 +0000
From: Quan Quan6 Wang <wangquan6@lenovo.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: NFSv4.2/pNFS: fix applacation get old size of file
Thread-Topic: NFSv4.2/pNFS: fix applacation get old size of file
Thread-Index: Ad0e/unUf+IDc6/dSGKf7ODq2Bt3Mw==
Date: Wed, 29 Jul 2026 02:07:00 +0000
Message-ID:
 <KL1PR0302MB52028CB56AB48DC0DEAA4A9786CA2@KL1PR0302MB5202.apcprd03.prod.outlook.com>
Accept-Language: zh-CN, en-US
Content-Language: zh-CN
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: KL1PR0302MB5202:EE_|TYZPR03MB8614:EE_
x-ms-office365-filtering-correlation-id: b661515f-9751-4f8a-24a9-08deed16138c
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam:
 BCL:0;ARA:13230040|23010399003|366016|1800799024|376014|18002099003|11063799006|38070700021|56012099006|10067099003;
x-microsoft-antispam-message-info:
 HM+UCmI5i74vaaBRvFy0YR2AcTdfNLAwiN7u+s2ybxyP40lSDZG62q8gd9Ive+r23Q2EB6nief6fol5WJgxjzpHFVmZ11j6RVTDEVeBmx+gD7Jb6dfn45WyDhgSnYtKIUt8I1JVYuCi8Mxv9V+JYhMaOceVbezEfNq/evRrgfLA38CAbtFTFo1Vo0Itu3vVyzJvPBqnej+zPylZtUw4PMp6xgIR1/N+8b+tXVbqWRcppvJkoLwzr4YDyWp0O787ujh6ldwCW4dpQNn15F44NGrBMcFgqbTCNwbLCzRw4fimgx88bc+hYSG4AJxfRkZKBqKgsXfCbCyea1y9yhmEQVaq54Behfb6LDDkNtAeRB+sOG7iAr/CS/mHJ3HF4Q1Ljz+6T/Ju7B5j95zj3urQgT7YV6X1hp8yBj2gvdnT7gQM0y4al42oD0AihAN66fjuAEAOJHxndbXguRP+mCtL5zfqIvzyGLtV5TlD+zf3MvWMqtohrtDUoxpoHdv4WxPyFfK8hcYQw9DkbNT8iM960GXywFi+grSchtdBoF3nI75mI+mKk3n8Q4HZtJq1cxJDmD3UNpUl7HVDuv6xqMI5eX67sZSnrxIKF54NS3Feqli3u4aNPIvbltLrNuJd0vic72qRhokP/NyRcclYSvCt3OOWFM6nhBaVkUcsXQuTutBxVGn23F0sLVtvdz+sdbBXRw1EqsqM1B6nh4tnMgeTKcquTYmvRH1HKsyvlZs6ILsc=
x-forefront-antispam-report:
 CIP:255.255.255.255;CTRY:;LANG:zh-cn;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:KL1PR0302MB5202.apcprd03.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(23010399003)(366016)(1800799024)(376014)(18002099003)(11063799006)(38070700021)(56012099006)(10067099003);DIR:OUT;SFP:1101;
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0:
 =?iso-8859-1?Q?ZIgkHM4vMhJomgeHIEz4PgcsjpoY5UxKm7j8P6Fsp6KCP9XAm6yIUbm9uL?=
 =?iso-8859-1?Q?e5TCtIyTBWlnd2W6GtcJBGkbLtUjneBCXK+kVMscyRDrLHEfub7UmFkavG?=
 =?iso-8859-1?Q?GB7flSYElUSpgYfFlmpl283zD4befhggClK2WwEgq3N1xJYc4iAq53rekg?=
 =?iso-8859-1?Q?kt47FZSSDgkfnVbiuYMY2dk73qKlULkyF/9AS7Rzo5F/FzHgJMFUsXS5A3?=
 =?iso-8859-1?Q?ERmUFTpsQj3NtKd9h+1hJvXTmmVaGJHVfWkOvydYK30frNvu/hP00kAPvi?=
 =?iso-8859-1?Q?7YDJKAvaH6EknNcxM7ysMhr1uiVwhN0wmFlNnXqwOWIF6wlPww/ZnzD4Xv?=
 =?iso-8859-1?Q?nr2LQdDMMbw/EGsA4d3Ar0oxyVn4i1TUdke03yz64MoOUIJ7wxBFf8Illa?=
 =?iso-8859-1?Q?7Ww+ZutCuXTWFNgCeNRXJMO0P/U+mCGTb+R9RiKnE3undu0y5jc0Mf92Xd?=
 =?iso-8859-1?Q?kPgBqLLZVb9Ftr+WuhKuc5Gn8nFoYa70t4TENYzAmLnNfnQ3xs3i2Q0nOC?=
 =?iso-8859-1?Q?YXmhVqtyZttFU5b7zkVUjVWmyd8pN4DtdnFZgZ8bQYi/XsjkvGhRoANrnZ?=
 =?iso-8859-1?Q?3jIEB041+OE61aumCoNCaWNaavDWCrSf4Ml6By2FQW8dW+WY595TQJsrqB?=
 =?iso-8859-1?Q?BgEWdX2S0CK2N4KMonwPrO8U8Ia1aGQTORXySh9jcHIfPcoSDztR4lGTKo?=
 =?iso-8859-1?Q?Sz+7b1SqDHRluM4Wzn7DfueKcz2eF1LazGp2wDY16W13Buqu6RAcEAkFxB?=
 =?iso-8859-1?Q?xQzd/DF13+MikD5mIsslsXI4Fpux/tIEBA/aQUze0G5KOHSUEbJFS/MJFM?=
 =?iso-8859-1?Q?76wUA04rWuaQfPyGT50qjeFCPSzhSwHnXZB7b/k52tydRTPJrw4LkOHKsm?=
 =?iso-8859-1?Q?DltuYyP9JvFxGsYsvq8PyPiMBb9br/PAdr1IK4YNao+Ksm7EpQrkyS3sOL?=
 =?iso-8859-1?Q?LTwL99huJ15GXRGrSF4Dy1PyYXU6w03P7EsLNPJyC9qK0ETK3dddUHAwIg?=
 =?iso-8859-1?Q?RBGvTouIx7sT8uFSzNeOtQVm8A6SjILXgsWkKQhfMVXIXY144Vu6tW82s2?=
 =?iso-8859-1?Q?pO+pwKUOxORSJ7XdAUL4N+KyoqSvwxOkuLOD1m7wqCv1NHnJNK+W1v+vgQ?=
 =?iso-8859-1?Q?xokY1wTFGNb3/vmPCNbBzpPW75x+pZgN+yrpi6+y1DqhjMwPzwuF418RWK?=
 =?iso-8859-1?Q?0+uj8lwHjYx4R+buzYQoolaP6ggKdD5AVl6RcIHfyEIYSj2bvPNAju/UIT?=
 =?iso-8859-1?Q?dSyXkl27cgdN0UtNK/oCb1sPNId2nVQ0CLVownd7yl5IsVsVFnPfvZJ7c7?=
 =?iso-8859-1?Q?tvqoEU8TjGnALulBUpvh8wja5xsMtQJ9zNUyeb6BOMDPCH6/Q3EeoSgqt+?=
 =?iso-8859-1?Q?+mFmpIBTNOj2EMlqYRQZuRkVBqcQQJpjSPdENl5VlTDmphUsq/90lyK0eH?=
 =?iso-8859-1?Q?Y+yogvDxIs3vnR8P6PZc7BW5Qfeaz00DqHT+WS9IMZqisrSO3BuMxWfqzs?=
 =?iso-8859-1?Q?kOCWPVZt+X3bXMyTYPGqw8GOC5viG5vvLU8J1bLJvKiCpDRmDZX5O8O2VK?=
 =?iso-8859-1?Q?rp+n0SropEZyNw8UK03bOEd3sn1TCXW32oFDRnN6Gky6PAIIR6gPTNrtUa?=
 =?iso-8859-1?Q?gLae/4zqATbPMcbk4fA8cSmTxaFQDkANTrKAtATqmGtb5MKH0rNgEbYVwL?=
 =?iso-8859-1?Q?SRXbt88xoAFeHq6KGhxRayztUubqCwgmypM9B0L3CGr2lrRjBErs+H6MLR?=
 =?iso-8859-1?Q?4rRSVTc0D4FNBHP27VRNNo1jx//T/f1kGTgzOyTo+zadyN?=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Exchange-RoutingPolicyChecked:
	mLv3ylsK50G463yq4iKesPANu/cFz5EsnCC8RnZi1vUdon2jlH7OPjEzKtc7O7w9+PW1V0KwOlvBLHzHFZT/8uWR/Vc5eVDXpJ+iL3lBIjlMHcd2SkYbrExW8yDVzrQt3ZCZiKNoMfXyTkgAVhA/GhmaWi4czg3JqKDAaGVECpbwXsgWDz6+h/p8T1MMrRwjJsKESmTo691HdUNmIOxVlywFcx3jNKVK9S9Xiwkvgyu7AnGofNMjhmBRh/IlKzm12Q7suuVZbV1LLqQtdQYCcDIVZJTOLhFjm/ygmsPlXhNKtbqydmx1LB2zf/nfzoo0oXWt4t+mJM4zNJiw1Z/A2Q==
X-OriginatorOrg: lenovo.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: KL1PR0302MB5202.apcprd03.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b661515f-9751-4f8a-24a9-08deed16138c
X-MS-Exchange-CrossTenant-originalarrivaltime: 29 Jul 2026 02:07:00.5607
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 5c7d0b28-bdf8-410c-aa93-4df372b16203
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: ejnlj7mndu0X3AVnSPDabWlvALCDChpoBKO3M2X1m0Nbimw6XJ3Pva3sz0moECs7It9HTMnm1sPrfTHkFQnyzQ==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: TYZPR03MB8614
X-Proofpoint-Spam-Info: AW1haW4tMjYwNzI5MDAxNCBTYWx0ZWRfX9KQITnpZ2d+I
 Sj6o+adD/+8dLm9WwlluvR4VjgcOaZ4d9su7EEJAwcebT/b2vihMVyiKGHNMopIOFc+Mjjz9PRO
 7xu5gzxN7uJmeBsWGwyQHPWF3ST/KSs=
X-Proofpoint-GUID: kxmIXvg73neprt1dgv8d8uC8SOeLhV9k
X-Proofpoint-ORIG-GUID: kxmIXvg73neprt1dgv8d8uC8SOeLhV9k
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwNzI5MDAxNCBTYWx0ZWRfX858vzy5lYMf/
 yiQGkvRwZaJGK0tsMoSP0ozYVw7yhkCUzbxHmuVKKz89VTOCuHJ7272qOUCAiY1dbsvymyDqYmn
 lTOSMD177rGTNesAMsFPl/ZKAPNBsQlcykoJ1NDla4jcLmG0NBLoZTd/rpj3nX871BFM84jNbOp
 y7+XjiB59sWeVpraSSz5+ndvFsGl7jgk1QsauVKgz1wB0RjBc1Cf5km2qN6Tp9YmhkUaOsG6B9A
 /n60duQ51dCgC0L//UXCHHh3XkLElbhEmBFRgofveuidpdiQj9ZPxRf1VY+tDoyLmoC9MgwDLIz
 fZ/p9TJan1rT1ZWkzijeIDXHI++ACyKnRhdn2R4sQISZlRT5uSDWYVr/Dvzt2I/VsxNzalOZ7X2
 UBBKXxmLyEXAZQbZBelwZy7UcsuXrUQ45Ewl/oEvtPVvzsYEgDOUm+WaApFuAOzcYVLkRVdV9F8
 9VbZvlMIjoxI2I++uKg==
X-Authority-Analysis: v=2.4 cv=JLwLdcKb c=1 sm=1 tr=0 ts=6a696048 cx=c_pps
 a=eLXmW/Zl0BgXf4qQ4TrZ+A==:117 a=z/mQ4Ysz8XfWz/Q5cLBRGdckG28=:19
 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19 a=xqWC_Br6kY4A:10 a=8nJEP1OIZ-IA:10
 a=RAioF0-LDSMA:10 a=VkNPw1HP01LnGYTKEx00:22 a=2RTuljz969oO5usasWGy:22
 a=tZVLdjz43cR2fSHv5-fA:22 a=8k6WQxmsAAAA:8 a=B4kpfZIjoO9n4QR95uQA:9
 a=lqcHg5cX4UMA:10 a=wPNLvfGTeEIA:10
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1143,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-07-29_01,2026-07-28_02,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 clxscore=1015 lowpriorityscore=0 impostorscore=0 adultscore=0 bulkscore=0
 priorityscore=1501 suspectscore=0 malwarescore=0 spamscore=0 phishscore=0
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=-20
 reason=mlx scancount=1 engine=8.22.0-2606150000 definitions=main-2607290014

From 5dca30906b0f705d6a1593e2a0c75bb044ef0dcc Mon Sep 17 00:00:00 2001
From: wangquan6 mailto:wangquan6@lenovo.com
Date: Tue, 28 Jul 2026 06:48:15 +0000
Subject: [PATCH] NFSv4.2/pNFS: fix applacation get old size of file

it happened when call nfs_lookup_revalidate_dentry
between pnfs_set_layoutcommit and nfs4_layoutcommit_release

Signed-off-by: Quan Wang=A0 mailto:wangquan6@lenovo.com
---
fs/nfs/inode.c | 3 ++-
1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 5bcd4027d..c07a046ff 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -2381,7 +2381,8 @@ static int nfs_update_inode(struct inode *inode, stru=
ct nfs_fattr *fattr)
=A0=A0=A0 if (fattr->valid & NFS_ATTR_FATTR_SIZE) {
=A0=A0=A0=A0=A0=A0=A0 new_isize =3D nfs_size_to_loff_t(fattr->size);
=A0=A0=A0=A0=A0=A0=A0 cur_isize =3D i_size_read(inode);
-=A0=A0=A0=A0=A0=A0 if (new_isize !=3D cur_isize && !have_delegation) {
+=A0=A0=A0=A0=A0=A0 if (new_isize !=3D cur_isize && !have_delegation &&
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 !pnfs_layoutcommit_outstanding(inode)) {
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 /* Do we perhaps have any outstanding wri=
tes, or has
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 * the file grown beyond our last write=
? */
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (!nfs_have_writebacks(inode) || new_is=
ize > cur_isize) {
--=20
2.34.1

