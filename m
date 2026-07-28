Received: from mx0a-00823401.pphosted.com (mx0a-00823401.pphosted.com [148.163.148.104])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8FDE03C416A
	for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2026 07:06:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=148.163.148.104
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785222403; cv=fail; b=qilRWqc+aop1KhRTsAKiVQRbxT4dexhg2KHdgbCTwW4Jmpk3LC3wwGeUHYXTf0Is5fD9gtTxz/WRe1wk5ckxdNmhx6rsUDneDLJ1rM4WPMA3ium6cLxm3icNXiIFcLFt3QyG2EQsHdVMPQxG9cAsT2v8TKj0a/ouhFwsYzMO2mc=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785222403; c=relaxed/simple;
	bh=6kZb7iOqEm6Ws5bCKz+jx8XlJc1F/jDjvBNQsnZbb3I=;
	h=From:To:CC:Subject:Date:Message-ID:Content-Type:MIME-Version; b=khk+6SzpRbrjNBtYrDXbtRnKOfycT7vgonca3JlzWuQQ6EMzDz/49QZchbbyeukO5pi8JcEfurNJfPouZKShFhPfGsyEbRIN48tSSs9ykYCg2lhZ9hWNfgO/qMG0Cb51EovHjUIgV9dtB4PXgQj8OgzIY8RnziSz8yHMcxq59jk=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=lenovo.com; spf=pass smtp.mailfrom=lenovo.com; dkim=pass (2048-bit key) header.d=lenovo.com header.i=@lenovo.com header.b=lmpm+tAU; arc=fail smtp.client-ip=148.163.148.104
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=lenovo.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lenovo.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=lenovo.com header.i=@lenovo.com header.b="lmpm+tAU"
Received: from pps.filterd (m0355087.ppops.net [127.0.0.1])
	by mx0a-00823401.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 66S3aSdv1657123;
	Tue, 28 Jul 2026 07:06:21 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=lenovo.com; h=cc
	:content-type:date:from:message-id:mime-version:subject:to; s=
	DKIM202306; bh=soPMkIpE4ByaA6kqZVkjfny/vrhdZwFprAGOH7yCzGM=; b=l
	mpm+tAUIeGYWa2oAKfMlTRzs87sEY8xUavp0kRpskoThxol00tAj08YeeQRE/Ku0
	ISw/VW1h69ESYYKAfM9Cj0gu+9NGmsBzUl/RTnNAKaiU3qUh3hWe68QeXaQAO3yG
	POXyxJRIOM443T9HFMq9xqIk5dK7eXeYvhp4t3zcPE5Xh0Z5qNbc34mC6XwP7zLw
	X9iicOLDhSCS5ll8z16CqjQK88cBsZ5FT3noJtlezcpnAzpBde/rCDKkvRIhYKIb
	GHJgovnDO5zMCN/lSVtHti972keKlkq0HQe3pPe8ni8YzNYt+8S/Y48dE638qVxc
	231Bmtw/+fYz378CGGwSg==
Received: from os8pr02cu002.outbound.protection.outlook.com (mail-japanwestazon11012002.outbound.protection.outlook.com [40.107.75.2])
	by mx0a-00823401.pphosted.com (PPS) with ESMTPS id 4fna0ebntn-1
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NOT);
	Tue, 28 Jul 2026 07:06:21 +0000 (GMT)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=yMnZ1YKh5QQ5qkyFDykme+YXWeEG7q7xmM7ON/227xt/QqQj7LVmI78ZKeLuCF7oTERYTFu4VONUzp4E0tvhJ7axExm0HXWicYHpvfvE+UOjaGXTLHwHJ3tAiuY34lptIToN0OhZH5oCkyGwF0a7IBILqDflI+XKbSXPNLRJTRDc66OnQPZ6p/VN6trL0L6vU1W3D+EEtYHY2MQcDHNiL9dJnQrAsmvSEuD4mt1zd1L5gMMK2C2XSHyFXhbexI7q6koCGc3G+uYaGg8qhaQv2Mln+uRcMuX4EeIYO8v5AqAVJoh4R/N5j4vGv4IoiDgykBSOQnF4B5KILrkDbOSSQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=soPMkIpE4ByaA6kqZVkjfny/vrhdZwFprAGOH7yCzGM=;
 b=t9azECwG/MpEFGLFRQzZ610g6IXjUES88KRFjoqwnYFlzPz58AJeZJklEAOLHQRQXL+gQO3lWS7JVz4iEsvuBcL55MI7MTQ5TS7oTGfnaUDZrrizD+K1hDKCAChDaVDYY8o1CFdRSTsez+wR7UxeeDRhYaZU5eIzm0fz5gc/PDIda5tZzLG0YaKEzD0+iFtMaxFTuS5ASRq4tLAYaMzCKaBCGg7Ow1lKU4De46xyU/ea6FkfISgQUi0YSoo12h6GB49chNBf1AE9a0ncYLWIFTcnHoawCb1IX7hmaG8m3dX1dZSs7aGLid88B/I8ktC0SHN022Ve5nIFQJ61HVDj7Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=lenovo.com; dmarc=pass action=none header.from=lenovo.com;
 dkim=pass header.d=lenovo.com; arc=none
Received: from KL1PR0302MB5202.apcprd03.prod.outlook.com (2603:1096:820:4d::9)
 by TYQPR03MB9524.apcprd03.prod.outlook.com (2603:1096:405:377::17) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.245.13; Tue, 28 Jul
 2026 07:06:19 +0000
Received: from KL1PR0302MB5202.apcprd03.prod.outlook.com
 ([fe80::923d:4104:30c8:d4e8]) by KL1PR0302MB5202.apcprd03.prod.outlook.com
 ([fe80::923d:4104:30c8:d4e8%3]) with mapi id 15.21.0245.012; Tue, 28 Jul 2026
 07:06:19 +0000
From: Quan Quan6 Wang <wangquan6@lenovo.com>
To: "anna@kernel.org" <anna@kernel.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: NFSv4.2/pNFS: fix applacation get old size of file
Thread-Topic: NFSv4.2/pNFS: fix applacation get old size of file
Thread-Index: Ad0eXzoaIblMDmtORrmxzH42GaBTEw==
Date: Tue, 28 Jul 2026 07:06:19 +0000
Message-ID:
 <KL1PR0302MB520263A7814093607F9B8BE086CB2@KL1PR0302MB5202.apcprd03.prod.outlook.com>
Accept-Language: zh-CN, en-US
Content-Language: zh-CN
X-MS-Has-Attach: yes
X-MS-TNEF-Correlator:
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: KL1PR0302MB5202:EE_|TYQPR03MB9524:EE_
x-ms-office365-filtering-correlation-id: b5bd0c27-b6f8-46e5-1443-08deec76b94a
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam:
 BCL:0;ARA:13230040|376014|23010399003|6049299003|366016|1800799024|4053099003|18002099003|38070700021|8096899003|56012099006|11063799006|10067099003;
x-microsoft-antispam-message-info:
 wFIdYAJEhxPeCoOPV1hCJBMplqxAJjvmFJZT9JjEyjrccKsghv+YOGi/J/wH1zi0KAsHYw5QqNuXXUoVnx3NUvUJtwFI3p86Eb5JqHSBxqhyRz2zICGqZWKJGtI0Ac9Ic3eoUT61pWO5EDvraQNzn3+gQmKGctFPoGtna+TZxS7XSgiKyeX7T9UEKWFBLCPa+Pcf3OtYm81oRV5gI7D6DYLmaa2rd7jzRzZGsaSVtl/f4IFb3muoGhI/2mRLz+YZW72oYELHBv1juGFG+esFI9JrjG4MhQirVA4KgFwxNwpO83Y2FP6N5YY3DXxNxzxNmEW59CTjFb8AJwg85mTbgBlYjgdJNA23rGGH0YBWOuTJTUDk/pW6hKjH7KlDaOwRyYN0dfktQ9Nvpl0bVrX6fAI3FpfG6176QdW7TbPhCqrz4haLuKpZUUcQ0cXNorXC/evUauWg5H1IdHoEnYtOOA==
x-forefront-antispam-report:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:KL1PR0302MB5202.apcprd03.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(376014)(23010399003)(6049299003)(366016)(1800799024)(4053099003)(18002099003)(38070700021)(8096899003)(56012099006)(11063799006)(10067099003);DIR:OUT;SFP:1101;
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0:
 =?us-ascii?Q?FfJwnhiOQF+U0ftpXaS+e1PiqvO3AUo9SurfSsnqYindpyS9d9p+vtxXySPA?=
 =?us-ascii?Q?5BopxwJ85NcAB7adwF7KqX/ybFKLIL+0CJepLQwdufvqM1Yg0hK1WEU9ACFH?=
 =?us-ascii?Q?Jk/V3cYOKpHhUXNVlMs/WLPpEBmRnKsDfbI4WP3BP4Ec99lNneN0XNUOBmNO?=
 =?us-ascii?Q?kY4TKSaB3sXTi14I2aOxcoOMB2HUi0gaQBXb/63Wh7Oz/yItkas/2WmQBn76?=
 =?us-ascii?Q?euWtH593ypILn5kU7BF4kxaC6QdYtNNesT7QmoPPAGxF3IED8zPrE7VPynU7?=
 =?us-ascii?Q?0wQqSL6DQRC/KZULf55BpG4VHAGI6dQjkZzeHSp4a90nUFIMXfcXmI0ESeua?=
 =?us-ascii?Q?aRhkcVxO0ZrUYr8O1lKF6bJOznudBFLbNYsD7OgKSO2v+NJzCFlf2bNV49x9?=
 =?us-ascii?Q?nrHs1QiW7txUoMTbDmK34i/sK0vNIot6LHvTMnZwKG/CflCsoIZfZ1Q1GS43?=
 =?us-ascii?Q?mLkPGmUj7fx09mZidxgjWkjPLJXolz741/ksUcEWe94AG31d7fCu7x1bPhlE?=
 =?us-ascii?Q?eFZtRU+odhC0ZxEJJNdM5Z4gcI5bZT5Ce/eR9IM/djrOigjkQ862FfcRpIbY?=
 =?us-ascii?Q?zwZGBn7+lc5njFlEYc4FqPMPRds4Q/lyrHkjey9PNcQHCfU3IJtEcD+MBCr0?=
 =?us-ascii?Q?vXGz609RTaA5R/f8wBxP11rXAxSXXNPCqEV/4q2VG7T98rwMJtl813JLkcYe?=
 =?us-ascii?Q?orLpocJKANdu27X9TFHwDzSfEvHshmZ19c4f3KXzQIwGvc73oKXwCO7NYIo2?=
 =?us-ascii?Q?rB5SRhvCuaTMu+7d1OW6Z7mma70DWqO+KINo3to5jgzk29qNCfhnjvUm8JT4?=
 =?us-ascii?Q?2B+ZMFvhJNIvCtheXffsYA6mPuO/XnhVKhFrhK2UltREY4D/5lcpk4kfCHxo?=
 =?us-ascii?Q?P1uRvYIE4ZseoO8duQ5qgo1UoOGtBTZa8bhrOG/sNe7LAFQUXoCol1TeeFmT?=
 =?us-ascii?Q?CPIydG5UABkvLNqMAOG9HGqVzK8veamj8ZfogHUO7Vbapo7ozbrKJ+N5dIpw?=
 =?us-ascii?Q?A0v9CgJb8D6ZQY5+EQS1L84eYVsYUa1SlytgbWA3a6AS49OqXgfk/5eQyrqV?=
 =?us-ascii?Q?+W4p5ahLug7kHuURX5eRHzq7s+MHyz3mLCoW7228JLLfmou2QIS5Stuwch88?=
 =?us-ascii?Q?V3pX/WhlpNaIeSu9x/oLRTovheqhw0kp1KM0tOqsBZRR1KKoPXBdPE1Yv60q?=
 =?us-ascii?Q?rIkhVxftoWLRu1jRQe1kix8RRdtmojhlSAsyVZ9ZDA82nFJ2VrL0XEovSR/r?=
 =?us-ascii?Q?2F+ICpq1H2VB1jxY3+5DLmelHDsMC2QCBvaz6csNpmHjmYS+oBjb+OgeS0YW?=
 =?us-ascii?Q?eILaRkRObzV9BFpo/o9sEPoDyS5is2pqJmMzs6rR994tJUQXfM9Vz4K2wOmz?=
 =?us-ascii?Q?L6khSrW9HCY+jrEgHwm1jufYiCF02n9VaUT7Swi1ykFAIDh2pyqfvXnQxfJA?=
 =?us-ascii?Q?9llMjmCZFIzx2xGvzOr94gMkU4VFvAIjmTWEvaiKlQn47bEcLtwn1ZDwWr1v?=
 =?us-ascii?Q?osE9ULzUCcxWY5o1IOn6slOK5dMIHuf0TygyU9hlXmoIEv4+RRjN5D72sCV9?=
 =?us-ascii?Q?GOt8xvY2fuNh11iZJdvyOPW317yU+zJ7Nw4V+79bhzU2ljUu3cs0QVSp9OiR?=
 =?us-ascii?Q?Jja+xdwzT+e8r8a7DZC31GQE2AS538hyKW5WXNIusGf6/E7H/KnHNe7upJe1?=
 =?us-ascii?Q?98RgehBzY9RVnSwBktLUVU9MHNUX/GY5kLrol2GTq+/X7Xpl?=
Content-Type: multipart/mixed;
	boundary="_004_KL1PR0302MB520263A7814093607F9B8BE086CB2KL1PR0302MB5202_"
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Exchange-RoutingPolicyChecked:
	Ehke4RaWU1TCrRjk05tjAD9pIU1JH1eGOd+XjEauzlRddtwSA0mNQrToSsxzWjTi9g9/X90s1xpmELfQc/VWDErPWNozB61otGL/nyRNhJOdvIatG/C46PAE54M12ILFXYS9QKdgu4B8YY16w1UpOEbISEI+IheEj9iMQXQ+aZELNG1yWrymStsYpl2AHS9IW5bKS2xmKo5XxKFAiVnpolHtjJs7MzJ2fZsatjpnr87N8AEl+hlrNTOKsdykfWUQuv9gptOT1932W6rWgiqJrf/7sMIYjJqZW/GRji9O5csUTbczwwcAxjYuEI1a9pOpaBp/9sHibuyNuhlcJuNUEA==
X-OriginatorOrg: lenovo.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: KL1PR0302MB5202.apcprd03.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b5bd0c27-b6f8-46e5-1443-08deec76b94a
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Jul 2026 07:06:19.1729
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 5c7d0b28-bdf8-410c-aa93-4df372b16203
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: +vP4ZWiuDPXUQbcTMwCwjZRoqnpTorSA/o8rShBtNI6/AAfn2eS+/sMgk4Db6+Rvdj+c/LDiGQkwtTTwep1Wxw==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: TYQPR03MB9524
X-Authority-Analysis: v=2.4 cv=K/kS2SWI c=1 sm=1 tr=0 ts=6a6854ed cx=c_pps
 a=uxO36MsyforZG/P9Ztohsw==:117 a=z/mQ4Ysz8XfWz/Q5cLBRGdckG28=:19
 a=lCpzRmAYbLLaTzLvsPZ7Mbvzbb8=:19 a=xqWC_Br6kY4A:10 a=RAioF0-LDSMA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=2RTuljz969oO5usasWGy:22 a=qMr132F7aASziHDET4f3:22
 a=tclcd6dtLQvEqt9_mmAA:9 a=CjuIK1q_8ugA:10 a=yMhMjlubAAAA:8 a=SSmOFEACAAAA:8
 a=2ffwIzrdQkbWnz4NKjkA:9 a=gKO2Hq4RSVkA:10 a=UiCQ7L4-1S4A:10
 a=hTZeC7Yk6K0A:10 a=frz4AuCg-hUA:10 a=ywXJP0tKQ-MYeFn8L_MA:9
 a=B2y7HmGcmWMA:10
X-Proofpoint-GUID: VGCJ-X6Jy4B16Z9-XKQhphUESm0eZ8TL
X-Proofpoint-ORIG-GUID: VGCJ-X6Jy4B16Z9-XKQhphUESm0eZ8TL
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYwNzI4MDA2MSBTYWx0ZWRfXwn64cNMwMSUA
 WvShEXS9jEuRyFXfvCgzVrV+AWslB5arlqOY1Asz9SioIazL6oqpqU/6F4RG+Wm9X62Ob8nGpF2
 sNHSeOd/LZ/FxIHWg6A/xXKIjdcOfMUQdUuyShpkDRgqk3Nw/UPDv1XEHbKuSK2gdpGrdA1jXz2
 zQ9x8zc0JJxzcJXoPfnTf7gulsnPN+7rU/J2d+wQwruOsc87xQ2bFTFrU3GcZBcd26eflGCuKbj
 oRO9loqg7G0RysqR3LH6g3rf76gCcgRn9m26dFQEhWeONqbKg2BRalxJoZHfuHJGr9o7tLh9ZQ5
 pSN5sddbsdyRK81P8/7ouplHvKaUM9+f7w8IHw68eYKhm2qIpYlEYwpTXeEIR2R74UtI2Y9BDU6
 7bXe9zXOvwjsfG7Qhl8BSAhDLrNhbRZB/xjXZoLtl55UYytTgnuu73+ds+dSVkt6ebtjI8GYXtH
 lhtStPrQkrUIHNmDprQ==
X-Proofpoint-Spam-Info: AW1haW4tMjYwNzI4MDA2MSBTYWx0ZWRfX4a5826H59BbD
 aMvwHrHOiftAT1wzCKrCqJgFWSffU9hyNknIyqS1vzgwtzoUGDJKLpg20amPUjVyvhGdL1Xndrw
 0v6GmVsNtdhzzKFs7+T5w7D3GQ0qtEw=
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1143,Hydra:6.1.134,FMLib:17.12.100.49
 definitions=2026-07-28_01,2026-07-27_01,2025-10-01_01
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 priorityscore=1501 lowpriorityscore=0 bulkscore=0 suspectscore=0
 malwarescore=0 impostorscore=0 clxscore=1011 phishscore=0 spamscore=0
 adultscore=0 classifier=typeunknown authscore=0 authtc= authcc=
 route=outbound adjust=-20 reason=mlx scancount=1 engine=8.22.0-2606150000
 definitions=main-2607280061

--_004_KL1PR0302MB520263A7814093607F9B8BE086CB2KL1PR0302MB5202_
Content-Type: multipart/alternative;
	boundary="_000_KL1PR0302MB520263A7814093607F9B8BE086CB2KL1PR0302MB5202_"

--_000_KL1PR0302MB520263A7814093607F9B8BE086CB2KL1PR0302MB5202_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable



--_000_KL1PR0302MB520263A7814093607F9B8BE086CB2KL1PR0302MB5202_
Content-Type: text/html; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

<html xmlns:o=3D"urn:schemas-microsoft-com:office:office" xmlns:w=3D"urn:sc=
hemas-microsoft-com:office:word" xmlns:m=3D"http://schemas.microsoft.com/of=
fice/2004/12/omml" xmlns=3D"http://www.w3.org/TR/REC-html40">
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
<meta name=3D"Generator" content=3D"Microsoft Word 15 (filtered medium)">
<style><!--
/* Font Definitions */
@font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;}
@font-face
	{font-family:DengXian;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
@font-face
	{font-family:DengXian;
	panose-1:2 1 6 0 3 1 1 1 1 1;}
/* Style Definitions */
p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0cm;
	font-size:11.0pt;
	font-family:DengXian;
	mso-ligatures:standardcontextual;}
span.EmailStyle17
	{mso-style-type:personal-compose;
	font-family:DengXian;
	color:windowtext;}
.MsoChpDefault
	{mso-style-type:export-only;}
/* Page Definitions */
@page WordSection1
	{size:612.0pt 792.0pt;
	margin:72.0pt 90.0pt 72.0pt 90.0pt;}
div.WordSection1
	{page:WordSection1;}
--></style>
</head>
<body lang=3D"ZH-CN" link=3D"#467886" vlink=3D"#96607D" style=3D"word-wrap:=
break-word;text-justify-trim:punctuation">
<div class=3D"WordSection1">
<p class=3D"MsoNormal"><span lang=3D"EN-US"><o:p>&nbsp;</o:p></span></p>
</div>
</body>
</html>

--_000_KL1PR0302MB520263A7814093607F9B8BE086CB2KL1PR0302MB5202_--

--_004_KL1PR0302MB520263A7814093607F9B8BE086CB2KL1PR0302MB5202_
Content-Type: application/octet-stream;
	name="0001-NFSv4.2-pNFS-fix-applacation-get-old-size-of-file.patch"
Content-Description:
 0001-NFSv4.2-pNFS-fix-applacation-get-old-size-of-file.patch
Content-Disposition: attachment;
	filename="0001-NFSv4.2-pNFS-fix-applacation-get-old-size-of-file.patch";
	size=1132; creation-date="Tue, 28 Jul 2026 07:01:54 GMT";
	modification-date="Tue, 28 Jul 2026 07:06:18 GMT"
Content-Transfer-Encoding: base64

RnJvbSA1ZGNhMzA5MDZiMGY3MDVkNmExNTkzZTJhMGM3NWJiMDQ0ZWYwZGNjIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiB3YW5ncXVhbjYgPHdhbmdxdWFuNkBsZW5vdm8uY29tPgpEYXRl
OiBUdWUsIDI4IEp1bCAyMDI2IDA2OjQ4OjE1ICswMDAwClN1YmplY3Q6IFtQQVRDSF0gTkZTdjQu
Mi9wTkZTOiBmaXggYXBwbGFjYXRpb24gZ2V0IG9sZCBzaXplIG9mIGZpbGUKCml0IGhhcHBlbmVk
IHdoZW4gY2FsbCBuZnNfbG9va3VwX3JldmFsaWRhdGVfZGVudHJ5CiBiZXR3ZWVuIHBuZnNfc2V0
X2xheW91dGNvbW1pdCBhbmQgbmZzNF9sYXlvdXRjb21taXRfcmVsZWFzZQoKU2lnbmVkLW9mZi1i
eTogUXVhbiBXYW5nICA8d2FuZ3F1YW42QGxlbm92by5jb20+Ci0tLQogZnMvbmZzL2lub2RlLmMg
fCAzICsrLQogMSBmaWxlIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKSwgMSBkZWxldGlvbigtKQoK
ZGlmZiAtLWdpdCBhL2ZzL25mcy9pbm9kZS5jIGIvZnMvbmZzL2lub2RlLmMKaW5kZXggNWJjZDQw
MjdkLi5jMDdhMDQ2ZmYgMTAwNjQ0Ci0tLSBhL2ZzL25mcy9pbm9kZS5jCisrKyBiL2ZzL25mcy9p
bm9kZS5jCkBAIC0yMzgxLDcgKzIzODEsOCBAQCBzdGF0aWMgaW50IG5mc191cGRhdGVfaW5vZGUo
c3RydWN0IGlub2RlICppbm9kZSwgc3RydWN0IG5mc19mYXR0ciAqZmF0dHIpCiAJaWYgKGZhdHRy
LT52YWxpZCAmIE5GU19BVFRSX0ZBVFRSX1NJWkUpIHsKIAkJbmV3X2lzaXplID0gbmZzX3NpemVf
dG9fbG9mZl90KGZhdHRyLT5zaXplKTsKIAkJY3VyX2lzaXplID0gaV9zaXplX3JlYWQoaW5vZGUp
OwotCQlpZiAobmV3X2lzaXplICE9IGN1cl9pc2l6ZSAmJiAhaGF2ZV9kZWxlZ2F0aW9uKSB7CisJ
CWlmIChuZXdfaXNpemUgIT0gY3VyX2lzaXplICYmICFoYXZlX2RlbGVnYXRpb24gJiYKKwkJCSFw
bmZzX2xheW91dGNvbW1pdF9vdXRzdGFuZGluZyhpbm9kZSkpIHsKIAkJCS8qIERvIHdlIHBlcmhh
cHMgaGF2ZSBhbnkgb3V0c3RhbmRpbmcgd3JpdGVzLCBvciBoYXMKIAkJCSAqIHRoZSBmaWxlIGdy
b3duIGJleW9uZCBvdXIgbGFzdCB3cml0ZT8gKi8KIAkJCWlmICghbmZzX2hhdmVfd3JpdGViYWNr
cyhpbm9kZSkgfHwgbmV3X2lzaXplID4gY3VyX2lzaXplKSB7Ci0tIAoyLjM0LjEKCg==

--_004_KL1PR0302MB520263A7814093607F9B8BE086CB2KL1PR0302MB5202_--
