Received: from TY3P286CU002.outbound.protection.outlook.com (mail-japaneastazon11010048.outbound.protection.outlook.com [52.101.229.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1CED926D4CA
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 01:45:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.229.48
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792028719; cv=fail; b=rtg9yPx08KPHiXaRbL++7+W9Laej4aMhhdW7mtgDnFLX/N+qwf2uka4AidBZy7BaIktwOfrpOVk/wGH15zazXyU0KshIKraXzlLRvmeCtHIDZ52FDsQy7S1LBTNK69j+SKPAV/I7mcXYRTzbYBkikj1KzeqBEanDW+J0ja5eVBI=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792028719; c=relaxed/simple;
	bh=KAxP1vZvPp79Y1O6JfoJjB/541c1DumRQrfL42B41KQ=;
	h=From:To:CC:Subject:Date:Message-ID:Content-Type:MIME-Version; b=VD2uIR+lr3mp6w4mgYXImTyelQwfPpUqlSZIEmRHj1M5I1XW0bsP61EbogYsNDkcioJx6IzNtlGAzhkl5kAbTol8o79EXwzpksEpzCkbZ4GBCiNpnw+YwuqAwiYf7alUx+u/esqa2s9PVXwn671l0RCynd20JTTWtU2GSB7MDso=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=fujitsu.com; spf=pass smtp.mailfrom=fujitsu.com; dkim=pass (2048-bit key) header.d=fujitsu.com header.i=@fujitsu.com header.b=KwzB2UE7; arc=fail smtp.client-ip=52.101.229.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=fujitsu.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=fujitsu.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=fujitsu.com header.i=@fujitsu.com header.b="KwzB2UE7"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=t8wAVI/Co+Gha6hL6vrc1u0LdYR/sy+xyWnYs5Xfu+BwKr25vjCnGgNeYBBM+rUawZvpoj0BaIkH9dCm3UAQPaAdIYx0CWWsobVR6z8BcQ1UBKYWVkgxkdM6lU0OoIz5pP+SfVj/8cUpqzsQa+Q7LShT7GAc6WXIGb6owF1n3eRU65EsZ84cb/vqoIyvSPJkFXk4KE7GBSkgKxdVdxKkXRmrACz5+3zNHGuTNwYir0gTQliDI7cmHvuiGne+AXYMPdAL2LYG5MdOBEC0ximfPd8xyQIqPgfeOzn1YmqLSFgUK1+IS2hP64u2HUCdiGbYsTIT3QmZYCEOlSqZqyezng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=QK7CFBCW0Q9G0r4a/e/qpx1wTOwfI0kOlA2y2yg7o1A=;
 b=NXKc78GvSX0V3QRMi4/6KOvteRgDN5Rw4tQlstPZguhZ7fU/mJyCsl5nmTQeTIDnTIUyM4HbIFhoyzJAzid2PduSRNF8NyAU4epkZVJ/ca7bPWCrIBdb6/kMdNja0WOg25RJWp5Ol5RwBlh9/Ms816TvuAes6XafAAjuCmKhYrTODKdrBgTR90xTidNRDrJrrsbwl6RtEcF0pus1XxAg0ctn6k1XFYW+V3ZTtDmClDqWbBmRBdE1/fvq1JaoKDpCzakEPVMfORqQ2A/AliIY9pJQrnYx65I4njN6PTMDzXKmBPtBs53iPNXTSvh1iGiInrW0n/o7UJqlOOAJ83eGDg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fujitsu.com; dmarc=pass action=none header.from=fujitsu.com;
 dkim=pass header.d=fujitsu.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fujitsu.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=QK7CFBCW0Q9G0r4a/e/qpx1wTOwfI0kOlA2y2yg7o1A=;
 b=KwzB2UE7axIIi3vbL3cp3Vn22hcPWgkneNuDkS4Kr7I9TT0/XU+euW6mHY/vCPhuQ1kReEZpGqvmharjRjIE3gWrP0tf852vLDpxan03NH9FE+iQ2STBvO1tWXlzwVRZADwL8EUt5VMVv4bXFJCGDl+8xpV3A9308ZaJsPjeunBU4UR8SP9Jn1sRlO7e2UIjvZVXy62Ovgngwa0kfEXQgCdL6RGvKPmnIWoYxefZt8gmvufO5rh3QlmqgCPUwAQSngkGV6gRFiXBTFmZTiZTkT04smnLMks/rr4VkErn+8oUlfqRVeKH55zJag0QKvLaYDMbZkU5N8ZFJq03aW5RNw==
Received: from TYCPR01MB11476.jpnprd01.prod.outlook.com
 (2603:1096:400:3b8::10) by TYCPR01MB10020.jpnprd01.prod.outlook.com
 (2603:1096:400:1e8::5) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.522.13; Thu, 15 Oct
 2026 01:45:15 +0000
Received: from TYCPR01MB11476.jpnprd01.prod.outlook.com
 ([fe80::38e7:2:fa52:18cc]) by TYCPR01MB11476.jpnprd01.prod.outlook.com
 ([fe80::38e7:2:fa52:18cc%4]) with mapi id 15.21.0522.012; Thu, 15 Oct 2026
 01:45:15 +0000
From: "Seiichi Ikarashi (Fujitsu)" <s.ikarashi@fujitsu.com>
To: "'Jorge.Mora@netapp.com'" <Jorge.Mora@netapp.com>
CC: "'linux-nfs@vger.kernel.org'" <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfstest: DELEG: accept the attribute delegation
Thread-Topic: [PATCH] nfstest: DELEG: accept the attribute delegation
Thread-Index: Ad1cRpZREEYoNoJZS+iAEO6y6dGrBw==
Date: Thu, 15 Oct 2026 01:45:15 +0000
Message-ID:
 <TYCPR01MB114765511A83C913BD7E9EF9E889C2@TYCPR01MB11476.jpnprd01.prod.outlook.com>
Accept-Language: ja-JP, en-US
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels:
 MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_ActionId=ca17c145-1d8d-47dd-863a-b8b0ac4e89c5;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_ContentBits=0;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_Enabled=true;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_Method=Privileged;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_Name=FUJITSU-PUBLIC?;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_SetDate=2026-10-15T01:44:30Z;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_SiteId=a19f121d-81e1-4858-a9d8-736e267fd4c7;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_Tag=10,
 0, 1, 1;
authentication-results: mx.microsoft.com 1; dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=fujitsu.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: TYCPR01MB11476:EE_|TYCPR01MB10020:EE_
x-ms-office365-filtering-correlation-id: ebbf2ef4-c65d-4172-ccd8-08df2a5df5c0
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam:
 BCL:0;ARA:13230040|1800799024|376014|366016|23010399003|38070700021|56012099006|11063799006|261009223027099003|10067099003|18002099003|1580799027;
x-microsoft-antispam-message-info:
 FrHIo9vhHCgT8pzL1d7H767+DrD++jqEr4p8hW1CBV+8CkH1/3tSksBDE76sGLx8scfh8haJwlVmMFH4JObuhrd/FXEE9MBI24fASjJCCVD5LfPrJyXowBgfGcpiV0PNEXRFzRsX9tFL2fjKLdnXrHzGs4E1V9JZJVnSCeQz6SWtHv+QSE+EvslaTLA8X0Sj6zAQBNeXAe6Wk7YwLTaIyBRzM0Zi6uSsoUdoDmD9GzeMdyxneX0Lk8rG6Fnjx/u1rraQET/m01bPJXWANcoxJ2ZpV/+1ljg2IJewKWlgwNeZ/JQngkAblPHKAv8Uo67ksJLaGgiapwqRNNwMTL6UjEkwLkwcbWA/wx8fAGuAuP2NDgHDctER9NEGlRp2V0GQukiAm5LdoauFGS8T7Ge7ROARCgBeK2rqJS/NFlHys0ZjnjsDXZnUoDgKP1NJfj5XDTplHMpD2flOusXcbX0UChhDYp9Jv1UtrZvZbyCY0wzENTlTLRfaJ8vEG9jF5Fszf39jMX6hff6QLiMl+A1xi6J9MJaYX8LOD3KUGhHlQyQaB2+YU+04AUSrZQZQ8La8Co6QoirLlN5Lm7R9Y3dT4e+tS4FiyAaH0WnMygbRUDPJAoJN/jmbT/c4935bsEtYb0P72+AGMNSaUsBadRkMiRJO3abO1xelOxETLVHMZkkGCv5ehbuVOpG/m/OzhcwwbKK00vkuKSkZ9Rcam/e4J5yFaZBtKAtQ3bxifl4nff7T+vewtPkGJ+z4cRDvxsjy
x-forefront-antispam-report:
 CIP:255.255.255.255;CTRY:;LANG:ja;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:TYCPR01MB11476.jpnprd01.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(1800799024)(376014)(366016)(23010399003)(38070700021)(56012099006)(11063799006)(261009223027099003)(10067099003)(18002099003)(1580799027);DIR:OUT;SFP:1101;
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0:
 =?iso-2022-jp?B?L0Rsa3cvM0p4MWJNQkZKYkhDMlZ5ZUYyVGtaY0prazAyWFU2aEZoSWli?=
 =?iso-2022-jp?B?UU1tYTd4N0Z1Y2Q2Nk9DQk5CK3F6MWE2d1BYODFQZGlNTDd6eUE1Ky9L?=
 =?iso-2022-jp?B?R2R1UHFpcUt4ajk3eDZ4aWJZSFFScktXbXlsenNoSXd6QWNKTWNBdjE3?=
 =?iso-2022-jp?B?YVNJVHJwMHBtZ0JEYWNSRGpqK0RqQ3dqcUVVMktPSUMzdzNkdVd4Smpa?=
 =?iso-2022-jp?B?YmF6QnBCc05JbDBHQ1FVM2pHeEI5bHI4M3dUR0IvbUZoNmZTYkZRUkhh?=
 =?iso-2022-jp?B?WlVVOGZ1cVl2VVl1VHpmWlBSSnB6dlhUaS9ZcWJUcnIzOFdPa0dlem5w?=
 =?iso-2022-jp?B?V1YxWjYwZ2V0bXZSVDVRbEVmdWtCYVEzbGJGWnFhMHgway9udHdocGJh?=
 =?iso-2022-jp?B?Y0w2VnVRcXZVaThjOHllcUVPLzdlNUkrT1oyZmZadmRaOHJYRE81N0tM?=
 =?iso-2022-jp?B?MndiaXVGSUQ2UTlHTlJGRUVBZ0hyMHpXZVVyZTd6eDQrRDhXdVh2Q0FK?=
 =?iso-2022-jp?B?UWlLNEJnZ0puZEY3UGpISFF1WmZGdnFhVmsybkJyZFlnaWVIOFJoMlVj?=
 =?iso-2022-jp?B?eEdPOXZiQW5KT0JTK1c1VlhvRERCSGNadGhkS3BiUGNDNXZWKzljKzZr?=
 =?iso-2022-jp?B?RnlOUGZocW5hRFpGa3ZxK0ZNZHdNdDZKMVFPMU1MYkFJdFV6RFg3Ty85?=
 =?iso-2022-jp?B?ajYxUldobldxMkdlQTBkRExJcFUvUkY5VzlvamhxL1FNQlAzdEI4dmR1?=
 =?iso-2022-jp?B?NUlCSVRnUzY3YTBObzRvTWF2NnlYWmg5anBTcloxYmtnRUUzbjlxUmxv?=
 =?iso-2022-jp?B?K1U3dDEwOEhlK3cyVThmYm4xZHNiRzRjaGZXV01lZFhLTStacm9XTnNH?=
 =?iso-2022-jp?B?cHpnTzdaSzByYkdLQ3JBV0hWNkgzMVFxQWVXclg3bjZRbG1KclhyTEcv?=
 =?iso-2022-jp?B?N2pCSGYzcHYrSnVEWmRQQWQ4VE1CbDlMMWk1WnZrakI0UjVpczY3c2VB?=
 =?iso-2022-jp?B?VTU4d2ZYTDZjY05TN0tkVXkvUGNTQThuS1ZVRE9GalhMc2VQT2RLUXQv?=
 =?iso-2022-jp?B?d2JDUE1tMlQwSHoxMW0vTlg5UjhNcjc5TUVBbGhZTnVad0FnSGgySmkz?=
 =?iso-2022-jp?B?T2JWNjJPZ3NpWmF1bFZoRHRJeGdPd092YXg0RXdDUmNieUFPdWxjam1T?=
 =?iso-2022-jp?B?Qkk2V3cyUGFWbi9mcWxHTUplQ05oTDRJSFUrUUp6OWtoREJTVlBGeGlo?=
 =?iso-2022-jp?B?UFhvdkZxRDFjeEJTd2RxaSswVkNiQzlpTVNQUTNPbXF4dFRSOC8wb1dh?=
 =?iso-2022-jp?B?SnQ1VTd3SW5sU2toQ29IVGNJa3Q5NmVhdXV3OE1xeEZLdWtKamNOdjlB?=
 =?iso-2022-jp?B?b1JHUlVLczF4MWFmMm1vdGRycmhiUkRQZi9ZVUhVbk1hM2tGelFQWUhE?=
 =?iso-2022-jp?B?b0xkb21LTTRmNFRPOWZGM2w4NDY5cWdXNmtPbU5CV25DdUp1YUZXR081?=
 =?iso-2022-jp?B?VnpHV0NxQjBFVE1zbFAxbGNkUWxieEYreVFUZTNwY2xBOFFudEtENGFD?=
 =?iso-2022-jp?B?My85TEVZSHZYeFBxbGNhT05ZVkltMTZFVlpuT3liTUxDUVNrMHNEdVFX?=
 =?iso-2022-jp?B?M3JNemtGQTV0bmtvWXdhVTdla1NtcFlhVmRmRTRESlRTWVRveTMzY3Rt?=
 =?iso-2022-jp?B?cnFFY0hXdWtIOXZCZWdlS1dNNDROUzlzZ0p3c2xyVUxQZzRST0FvL0FD?=
 =?iso-2022-jp?B?OXVlZlVnT0tpRjlPQy9VWVpSeThJRHBKUFdzVDdFNFBqYUxoWnlIOXFP?=
 =?iso-2022-jp?B?ZjRaRFR4KytsR2I1RHZlV2FKOXN4V0dld3dvU3YxT2VxSGN3VjFON2ow?=
 =?iso-2022-jp?B?RUUwOWdLZ2RXMUhKVlRkdTBNdkNmTHJlZ1VjaGRUdHRZSGVnQ05Wdk9s?=
 =?iso-2022-jp?B?RHE1TGF1YnpicDVDZmVjLzBmZnJpWnIrSXBrenZyNFRnSTVZVklzbGxE?=
 =?iso-2022-jp?B?OFNaeHBZNkx2T0V2U0hCTy9JWWNUWFN4NjgyQnRxeEFrcmRzbkhLWlR4?=
 =?iso-2022-jp?B?eWxpU2FCZXZkUFJXOUpSRmRCOTl5NXN6UXhnNnZSRkNTVlcxWUZrMjkx?=
 =?iso-2022-jp?B?ZHV0cHIxWFE3cVA4bnJ5bWtkUmx5VmQ4cU5KSk1NWWlnOXIwTGZVRWVI?=
 =?iso-2022-jp?B?TXgwdlEzeS84Z0M2UTFiSEEvRStOS3hxRXRjNjNGZDJqdUlPelBTSC82?=
 =?iso-2022-jp?B?cUJzUlRtK1l5OTU3MmVESk5hMndwU1Z1TDlmaHNxNXQ4NkwvakhEMzQ0?=
 =?iso-2022-jp?B?WXhyUVduN3JmYml2VFVLd3JycTh3eXhZWWFtR21uNkN4NEJ0b2gralZW?=
 =?iso-2022-jp?B?S0QwbmVZYktJdUlVb2ZsWHQvMDhpUWJRTlo5Y2dHcGdJM0Q5RmRJZ2hx?=
 =?iso-2022-jp?B?ckttN2ZiNmNUT0dPV1dveFNiT25FMDNsTTFUV0hiaFFaR0pXREFxQkxz?=
 =?iso-2022-jp?B?aVNUV0VLaGRHUFA4WHBxNENCcnZuRjFXZCtFQT09?=
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Exchange-RoutingPolicyChecked:
	hVWBBPEJsQbC8dxeudHOzvU/SNNwmQFokOjlUg60Qr5ImLYJgai62Ca+IVePOgRWL+VhVLvBXFy+sL62zsjb+utgUc29toeXwhO+4MwTm+dQ7id/Gzb14boNvRSrcCzxFrLaV5qgE/SrBHhu4KCDDwNc5H3NNPGbmArA7YHuh/NkzC9av6Z5sdTVgKfcBdKbT75yMQjY9H9qQXncaC0H78lE4w9JAaN6Hei16z9l//IqZHP0cVn1m0JcuxpGVXvzbaSFuqqPGjh8hdgyY7oNii90kJi/wJcRPCsH/my0CiBuXuranFsqwyiLVLofLViiwA8J6ycLmy0w8k7UJP6liw==
X-OriginatorOrg: fujitsu.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: TYCPR01MB11476.jpnprd01.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ebbf2ef4-c65d-4172-ccd8-08df2a5df5c0
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Oct 2026 01:45:15.2767
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a19f121d-81e1-4858-a9d8-736e267fd4c7
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: G4wvVGiG+UH4Kk5qlDSAOIcVUg1iKId9QE4qfITZ52SnKYAjUjKN9A/CySSiZBTZ9T7B8wv4Gi468KLNu9XEUtTxzxXbaOvR69vq0blOWNQ=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: TYCPR01MB10020

Since the commit 6237a17, the timestamp delegation is enabled
by default. Then OPEN_DELEGATE_WRITE_ATTRS_DELEG (5) is often
returned as deleg_type instead of OPEN_DELEGATE_WRITE (2) as
per RFC 9754. Current NFStest cannot handle this and fails
with "FAIL: WRITE delegation should be granted" and others.

Let's accept OPEN_DELEGATE_WRITE_ATTRS_DELEG in the case that
OPEN_DELEGATE_WRITE has been expected, at least.

Signed-off-by: Seiichi Ikarashi <s.ikarashi@fujitsu.com>
---
 nfstest/nfs_util.py      | 10 +++++++---
 packet/nfs/nfs4.py       |  4 ++--
 packet/nfs/nfs4.x        |  4 +++-
 packet/nfs/nfs4_const.py |  4 ++++
 test/nfstest_delegation  |  2 ++
 test/nfstest_file        |  4 ++--
 test/nfstest_pnfs        |  2 +-
 7 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/nfstest/nfs_util.py b/nfstest/nfs_util.py
index cf8d6ae..393b073 100644
--- a/nfstest/nfs_util.py
+++ b/nfstest/nfs_util.py
@@ -567,7 +567,11 @@ class NFSUtil(Host):
             save_pktcall =3D pktcall
             xid =3D pktcall.rpc.xid
             open_str =3D "RPC.xid =3D=3D %d and NFS.status =3D=3D 0 and NF=
S.resop =3D=3D %d" % (xid, OP_OPEN)
-            if deleg_type is not None:
+            if deleg_type =3D=3D OPEN_DELEGATE_READ:
+                open_str +=3D " and NFS.delegation.deleg_type in %s" % ((O=
PEN_DELEGATE_READ, OPEN_DELEGATE_READ_ATTRS_DELEG),)
+            elif deleg_type =3D=3D OPEN_DELEGATE_WRITE:
+                open_str +=3D " and NFS.delegation.deleg_type in %s" % ((O=
PEN_DELEGATE_WRITE, OPEN_DELEGATE_WRITE_ATTRS_DELEG),)
+            elif deleg_type is not None:
                 open_str +=3D " and NFS.delegation.deleg_type =3D=3D %d" %=
 deleg_type
=20
             # Find OPEN reply to get filehandle of file
@@ -591,7 +595,7 @@ class NFSUtil(Host):
                 filehandle =3D claimfh
=20
             open_stateid =3D pktreply.NFSop.stateid.other
-            if pktreply.NFSop.delegation.deleg_type in [OPEN_DELEGATE_READ=
, OPEN_DELEGATE_WRITE]:
+            if pktreply.NFSop.delegation.deleg_type in [OPEN_DELEGATE_READ=
, OPEN_DELEGATE_WRITE, OPEN_DELEGATE_READ_ATTRS_DELEG, OPEN_DELEGATE_WRITE_=
ATTRS_DELEG]:
                 deleg_stateid =3D pktreply.NFSop.delegation.stateid.other
             else:
                 deleg_stateid =3D None
@@ -1723,7 +1727,7 @@ class NFSUtil(Host):
         (self.filehandle, self.open_stateid, self.deleg_stateid) =3D self.=
find_open(filename=3Dfilename, **kwargs)
         if self.open_stateid:
             self.stid_map[self.open_stateid] =3D "OPEN stateid"
-        if self.deleg_stateid and (write is None or self.openreply.NFSop.d=
elegation.deleg_type =3D=3D deleg_type):
+        if self.deleg_stateid and (write is None or self.openreply.NFSop.d=
elegation.deleg_type in [OPEN_DELEGATE_WRITE, OPEN_DELEGATE_WRITE_ATTRS_DEL=
EG]):
             # Delegation stateid should be used for I/O
             self.stateid =3D self.deleg_stateid
             self.stid_map[self.deleg_stateid] =3D "DELEG stateid"
diff --git a/packet/nfs/nfs4.py b/packet/nfs/nfs4.py
index 1cd48da..6911a40 100644
--- a/packet/nfs/nfs4.py
+++ b/packet/nfs/nfs4.py
@@ -2455,9 +2455,9 @@ class open_delegation4(BaseObj):
=20
     def __init__(self, unpack):
         self.set_attr("deleg_type", open_delegation_type4(unpack))
-        if self.deleg_type =3D=3D const.OPEN_DELEGATE_READ:
+        if self.deleg_type in [const.OPEN_DELEGATE_READ, const.OPEN_DELEGA=
TE_READ_ATTRS_DELEG]:
             self.set_attr("read", open_read_delegation4(unpack), switch=3D=
True)
-        elif self.deleg_type =3D=3D const.OPEN_DELEGATE_WRITE:
+        elif self.deleg_type in [const.OPEN_DELEGATE_WRITE, const.OPEN_DEL=
EGATE_WRITE_ATTRS_DELEG]:
             self.set_attr("write", open_write_delegation4(unpack), switch=
=3DTrue)
         elif self.deleg_type =3D=3D const.OPEN_DELEGATE_NONE_EXT:
             self.set_attr("whynone", open_none_delegation4(unpack), switch=
=3DTrue)
diff --git a/packet/nfs/nfs4.x b/packet/nfs/nfs4.x
index a9c2b6e..cc26e51 100644
--- a/packet/nfs/nfs4.x
+++ b/packet/nfs/nfs4.x
@@ -1746,7 +1746,9 @@ enum open_delegation_type4 {
     OPEN_DELEGATE_NONE      =3D 0,
     OPEN_DELEGATE_READ      =3D 1,
     OPEN_DELEGATE_WRITE     =3D 2,
-    OPEN_DELEGATE_NONE_EXT  =3D 3 /* New to NFSv4.1 */
+    OPEN_DELEGATE_NONE_EXT  =3D 3, /* New to NFSv4.1 */
+    OPEN_DELEGATE_READ_ATTRS_DELEG   =3D 4,
+    OPEN_DELEGATE_WRITE_ATTRS_DELEG  =3D 5
 };
=20
 enum open_claim_type4 {
diff --git a/packet/nfs/nfs4_const.py b/packet/nfs/nfs4_const.py
index b76cbf7..b788e21 100644
--- a/packet/nfs/nfs4_const.py
+++ b/packet/nfs/nfs4_const.py
@@ -1021,12 +1021,16 @@ OPEN_DELEGATE_NONE     =3D 0
 OPEN_DELEGATE_READ     =3D 1
 OPEN_DELEGATE_WRITE    =3D 2
 OPEN_DELEGATE_NONE_EXT =3D 3  # New to NFSv4.1
+OPEN_DELEGATE_READ_ATTRS_DELEG  =3D 4
+OPEN_DELEGATE_WRITE_ATTRS_DELEG =3D 5
=20
 open_delegation_type4 =3D {
     0 : "OPEN_DELEGATE_NONE",
     1 : "OPEN_DELEGATE_READ",
     2 : "OPEN_DELEGATE_WRITE",
     3 : "OPEN_DELEGATE_NONE_EXT",
+    4 : "OPEN_DELEGATE_READ_ATTRS_DELEG",
+    5 : "OPEN_DELEGATE_WRITE_ATTRS_DELEG",
 }
=20
 # Enum open_claim_type4
diff --git a/test/nfstest_delegation b/test/nfstest_delegation
index 717fa97..e51feb0 100755
--- a/test/nfstest_delegation
+++ b/test/nfstest_delegation
@@ -283,6 +283,8 @@ deleg_map =3D {
 deleg_str =3D {
     OPEN_DELEGATE_READ  : "READ",
     OPEN_DELEGATE_WRITE : "WRITE",
+    OPEN_DELEGATE_READ_ATTRS_DELEG  : "READ ATTRS",
+    OPEN_DELEGATE_WRITE_ATTRS_DELEG : "WRITE ATTRS",
 }
=20
 def file_lock(fd, open_type, absfile, lock_offset=3D0, lock_len=3D0):
diff --git a/test/nfstest_file b/test/nfstest_file
index eb3ac93..fb99289 100755
--- a/test/nfstest_file
+++ b/test/nfstest_file
@@ -319,7 +319,7 @@ if not fh_list and (dirfhcrc32 is not None or len(paths=
) =3D=3D 0):
                         for item in pkt.nfs.array:
                             if item.resop =3D=3D nfs4.OP_OPEN:
                                 stid_list.append(crc32(item.stateid.other)=
)
-                                if item.delegation.deleg_type in [nfs4.OPE=
N_DELEGATE_READ, nfs4.OPEN_DELEGATE_WRITE]:
+                                if item.delegation.deleg_type in [nfs4.OPE=
N_DELEGATE_READ, nfs4.OPEN_DELEGATE_WRITE, nfs4.OPEN_DELEGATE_READ_ATTRS_DE=
LEG, nfs4.OPEN_DELEGATE_WRITE_ATTRS_DELEG]:
                                     stid_list.append(crc32(item.delegation=
.stateid.other))
                             elif item.resop =3D=3D nfs4.OP_GETFH:
                                 fh_list.append(crc32(item.fh))
@@ -354,7 +354,7 @@ if fh_list:
                         continue
                     if item.resop =3D=3D nfs4.OP_OPEN:
                         stid_list.append(crc32(item.stateid.other))
-                        if item.delegation.deleg_type in [nfs4.OPEN_DELEGA=
TE_READ, nfs4.OPEN_DELEGATE_WRITE]:
+                        if item.delegation.deleg_type in [nfs4.OPEN_DELEGA=
TE_READ, nfs4.OPEN_DELEGATE_WRITE, nfs4.OPEN_DELEGATE_READ_ATTRS_DELEG, nfs=
4.OPEN_DELEGATE_WRITE_ATTRS_DELEG]:
                             stid_list.append(crc32(item.delegation.stateid=
.other))
                     elif item.resop =3D=3D nfs4.OP_GETFH:
                         fh_list.append(crc32(item.fh))
diff --git a/test/nfstest_pnfs b/test/nfstest_pnfs
index 71e91dd..8632896 100755
--- a/test/nfstest_pnfs
+++ b/test/nfstest_pnfs
@@ -335,7 +335,7 @@ class pNFSTest(TestUtil):
             index +=3D 1
             nio_total +=3D nio
         if nio_total =3D=3D 0:
-            if iomode =3D=3D LAYOUTIOMODE4_READ and stid_str =3D=3D 'DELEG=
' and openfh['deleg_type'] =3D=3D OPEN_DELEGATE_WRITE:
+            if iomode =3D=3D LAYOUTIOMODE4_READ and stid_str =3D=3D 'DELEG=
' and openfh['deleg_type'] in [OPEN_DELEGATE_WRITE, OPEN_DELEGATE_WRITE_ATT=
RS_DELEG]:
                 self.test(True, "%s should not be sent to DS when holding =
a write delegation" % io_str)
             elif openfh.get('dtcached'):
                 self.test(True, "%s should not be sent to DS if data has b=
een cached" % io_str)
