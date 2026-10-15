Received: from OS0P286CU011.outbound.protection.outlook.com (mail-japanwestazon11010071.outbound.protection.outlook.com [52.101.228.71])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DD9682C325C
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 01:46:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.228.71
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792028814; cv=fail; b=fY1w/dMqXK9Lyhe9Yzh9UHBXwJz5Gt5KhOPfpdD7BmO22Pm/oOu8o8g38U3/ROiIoA5zfqezeywmNJkgxO2X+Q2Pa2TYhz75cIr0L6IIcPbdRtHXVg3pOQWjC8kLyj/fN80+JcV9y28uUYfVmCPkHfUA9PVETh1k6aG36jaPJoU=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792028814; c=relaxed/simple;
	bh=JpD/R6tGvBL0thYRLaVxmCaGm8j49984jSqexnin+so=;
	h=From:To:CC:Subject:Date:Message-ID:Content-Type:MIME-Version; b=TOAyWI5cWjjr/UgvTLt0mMq/XJPrfXTz3WVzy1FpM5t54dFe9asj5uxmdGALoJ5E99uI8x4Ub3klzNloRMZs3u2XJ8hUUW03yrC8j4uD1f+Mh/4dsa3OWmmgYwOtEJndNawpO61uKxfEw7e1PnmZrHE4CcAxPAr+K8cZjB06068=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=fujitsu.com; spf=pass smtp.mailfrom=fujitsu.com; dkim=pass (2048-bit key) header.d=fujitsu.com header.i=@fujitsu.com header.b=lYyiiC8D; arc=fail smtp.client-ip=52.101.228.71
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=fujitsu.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=fujitsu.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=fujitsu.com header.i=@fujitsu.com header.b="lYyiiC8D"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=G/+V5RogKJR9GKcOYh62pVdUr4DGjNZl2xzJFcifJUsFXMtFudPB2PEAUXJCQxRfYqJ1Qr+WKOpdo3Xd1qyLXOSxn47hrjHn8tzEiY1WWQT69DBWvQ9eE996HwQUs2P1PxLmGvw0eNL+UBnFaI443tgFiskZl+Tz/enxnJlFrHG1bkAiSlDqa6RW8MKY0hbDsVRa5SjRyvfilqmQCrSgj8Vm4I6i120yDMEBKqEQpnGbn6/kFLUO3U7w+Amhu30PRqh84HhdnJZGLGCHDvpiHNfkjLfdd7mViUVdPShTy2eioUiBGpK/V/6j1dKetm8JZ72lFjGfpLcbB3FQYkIC1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=AKsnCPNOop2xHpuvqGEG4WR2n/xooNXb+Y3LuXZHW9c=;
 b=r8kRKTw4JJBrwE9lU3s/2h9EgyTJ3AsNLrU0EEFNODsmwzqjvc9l/VZYs53keuAY2W1NoRkmvzRnjWRt25KBqN1z55dVTbUCJoNJqm3vNSr/o9oZuxufcodibMv85AAlw6pHuGFoujqsq81t3iXjCBO4fT9BGvGLkdy0hGHFDivZe9hFgJJ4uarVqBxofOa5k5CnkWizS2iHWL8GYQDzLbbanWtHKxCD3tIEviG4Kb4o78LKdzE2XXRE0tDmcZrDoHnVJ8NBZsOlOQE72bPF+09jahfOC+psYLVm3PGEBrMYcnHCG9ts7xOfl8/uAqxgkOlA7/3Tc2uKxVP5+8bHGQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fujitsu.com; dmarc=pass action=none header.from=fujitsu.com;
 dkim=pass header.d=fujitsu.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fujitsu.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=AKsnCPNOop2xHpuvqGEG4WR2n/xooNXb+Y3LuXZHW9c=;
 b=lYyiiC8DEHnI9mNJuQw8rR3W6D52g/mlDParhL6t6Ww0qgPchYBlKbzJOvX229d1IXFVktn6aREHBREtb/gaFFIxc8gYOILI0olPhm7Cyh7/oCegNJbYRpeudg4HzDWufSb7iQUFigyDgqyXnV12jYGBvOe0uyOElAp+EElnYQH800BnAOeflXbGNv7AUMg+pOiIcjbvEJPcI+3uuNCuvWyCOVzYngaEDi1Uy4BtMzzEAFaORrCtEsBGZKw3WWlUOgdAlswKuFuK2I1Twq1R6iCKfnImwdOZBAx1/LHHfgDF4oG44UkII37wjS+zWJ/vLWUTMYigQXQR8WdG27tY4g==
Received: from TYCPR01MB11476.jpnprd01.prod.outlook.com
 (2603:1096:400:3b8::10) by OSZPR01MB8371.jpnprd01.prod.outlook.com
 (2603:1096:604:16d::9) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.522.13; Thu, 15 Oct
 2026 01:46:49 +0000
Received: from TYCPR01MB11476.jpnprd01.prod.outlook.com
 ([fe80::38e7:2:fa52:18cc]) by TYCPR01MB11476.jpnprd01.prod.outlook.com
 ([fe80::38e7:2:fa52:18cc%4]) with mapi id 15.21.0522.012; Thu, 15 Oct 2026
 01:46:49 +0000
From: "Seiichi Ikarashi (Fujitsu)" <s.ikarashi@fujitsu.com>
To: "'Jorge.Mora@netapp.com'" <Jorge.Mora@netapp.com>
CC: "'linux-nfs@vger.kernel.org'" <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfstest: CACHE: mount with "noac" option on remote client
Thread-Topic: [PATCH] nfstest: CACHE: mount with "noac" option on remote
 client
Thread-Index: Ad1cRt6U42A3v9d5RuiFgFoGCP2D/A==
Date: Thu, 15 Oct 2026 01:46:49 +0000
Message-ID:
 <TYCPR01MB11476E0721588F2AD72378E3A889C2@TYCPR01MB11476.jpnprd01.prod.outlook.com>
Accept-Language: ja-JP, en-US
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels:
 MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_ActionId=5de5ac03-f6da-4ada-b82d-10801ee9e87b;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_ContentBits=0;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_Enabled=true;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_Method=Privileged;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_Name=FUJITSU-PUBLIC?;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_SetDate=2026-10-15T01:45:37Z;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_SiteId=a19f121d-81e1-4858-a9d8-736e267fd4c7;MSIP_Label_1e92ef73-0ad1-40c5-ad55-46de3396802f_Tag=10,
 0, 1, 1;
authentication-results: mx.microsoft.com 1; dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=fujitsu.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: TYCPR01MB11476:EE_|OSZPR01MB8371:EE_
x-ms-office365-filtering-correlation-id: 2c605ba1-d093-4d5c-49ee-08df2a5e2dd2
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam:
 BCL:0;ARA:13230040|23010399003|1800799024|366016|376014|10067099003|18002099003|1580799027|11063799006|38070700021|56012099006;
x-microsoft-antispam-message-info:
 105/kpWOvVR4ys5V/9gZLssgnUt1wpUQM18ebBnpCbSA2jz651avFFhhYlhvCrA20KaHhsWc/EgqSz5CiZ7x+LFGoIZDu4QQgH6/F7GFuJeoOBa/6HMqId23Iw2CM0qSyrM4OqY5quB/g7K1RlkwYssSO/ddafdxQGbHOOT86DhSzPmc0uuWE8mI4h1FGew15MxlN+eNjADI5T7kX26Mq7pGh2xBUrym6pRwn9LtbOgZFGeb8UbyUqznUPX8ym6fbdVxPOy7wzqqHzXZw4AGP3gS41w04c82TusdfT1/utwZUlCvbntytwjMBSL4O+58HY3oW6CdSETLgiAI6ftyHot3tx/Y92YcsUOQFEY8MbklvuUY2QujOuxxsDni4m4rQKCE+qVkZNCKz8r3kwABArviqmABfFYJRcE7vudxc3Hzy4aei4zlmByGzX7FRkaj5gKp7iVzEIEHWNJpo8bdDUjDmFexpJ5l0R9LKhCRSr2FexEIVwCt7jj8bCi0nHEVV+BNu8zmjLu7DgYUSqq0Y5NFwQum86tKuN4NW+ACrZ7SbryRcu++BsNAnFcEmEnZyezKMrIewBkwluVn9c/8ohM+VpvuTOSgO5oUw3cSsoCrUR02ns/hpHbjB13rLfZ/MXYcF/3/eBKjw/9Ec2doz58ihMlT+REnr3+JNaPNsGNGBvfeC1FY2rDjsl8eVsO8jPsvaPtHRw7PCkageNCqD7kmx7lXx5/+hd4DjlEyztyGqwN5gYYCTIkWaIsb6lBG
x-forefront-antispam-report:
 CIP:255.255.255.255;CTRY:;LANG:ja;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:TYCPR01MB11476.jpnprd01.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(23010399003)(1800799024)(366016)(376014)(10067099003)(18002099003)(1580799027)(11063799006)(38070700021)(56012099006);DIR:OUT;SFP:1101;
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0:
 =?iso-2022-jp?B?U0diZVpJV2hscE1uTHc2OS9KcUF1ZVNTRXJOTXpYSlprQVJJbGZMSXJV?=
 =?iso-2022-jp?B?WGFtSG5KYnQ3Wk1wa1ZlUHJMYUp6TXJIMHloWnBXUU5yZm9NaWVFeWxK?=
 =?iso-2022-jp?B?dEVDMzBrL280cll2N1hsS1dSam1VTXFpMXU1NWVUNE9FSzV1RjM3TXM3?=
 =?iso-2022-jp?B?WlNMS1JrKzF4WXV5MDlHOVRRNmk0aDdBdFlSUWZSR3VpQzZtbFk5ZUp6?=
 =?iso-2022-jp?B?TG9rMU1TaGovT3h6dFZIejZLRm5Zd29GOWtwYzdDZ2ZMV24yam5Ma0tx?=
 =?iso-2022-jp?B?MkpMdVM5MVBGUVlncS9KKzl0ZVpxd082ZWZtVnJ6dkNtZENWald0QXQ5?=
 =?iso-2022-jp?B?RDJ1enA3dEUrS0dXOFloNUh2akhkUU1QNCt3RC94TmduVlAvM1JuR1Rw?=
 =?iso-2022-jp?B?aVJWTnNhSUgwUjYzM0Q2WEFoei9LbDc4U1hLWXJQZmRMbE1lZEcxd3Zj?=
 =?iso-2022-jp?B?TmNhVXFzL0F5RnY5OWZWL2daWFE4MjJRb0N5ckpiQTVsWHpTZUNSU21F?=
 =?iso-2022-jp?B?ZnA3UU1EbnFRZXR3UzJvN1ZaMDBaSDZYbHk4UkRyZ21pdXhhSW9rNXZx?=
 =?iso-2022-jp?B?YjFJUFo4TnR2VDNMR2hIeWRZZ25nL00wUWdjMzdENXdVNzROYnYxRisz?=
 =?iso-2022-jp?B?NDBNOHYyOTBwc3lJak8xTkY1aEJjbGFGWjNnOUlFeklZcGtXRzVZY0ox?=
 =?iso-2022-jp?B?REdzbERvcm9GR3MyMkJkNlV5cldmUm5JTEMwaDg4TFZZb2ZJRHZiMlF5?=
 =?iso-2022-jp?B?dit3bFlITFJsZXRIalBSczYzZkM0SnNUVnV0UUVQNW5oTHJnMFlreTBG?=
 =?iso-2022-jp?B?VTFoTkFPOEV3NjB4K3dURHZzY01LWkpPN056ekdnZXBwRENOZG5DY1A1?=
 =?iso-2022-jp?B?ekVsSjdueVkvcWk5azJqdGZxS0U5M2FrM2hDcVo1eXZaMGpmMGp5T2Jt?=
 =?iso-2022-jp?B?Z083ZFUwbkZ4S1pVMFRxZnQzNmdZcjg0eWF6RmF0aEVCUlVTUWpwWmxt?=
 =?iso-2022-jp?B?MHAvazBZQzRxdUxXYnRjMjFyQ0lKb1FWVi9WYnpDMTNuVFZwb05ITlBq?=
 =?iso-2022-jp?B?RFN1WGttbzRUZU13ZExSUjBDQ2lOZk9VNFYyQTNVTi9tMmJPdmRrRkFw?=
 =?iso-2022-jp?B?YkZvNUNaMFozcWR6VnMxWEs3MTVpZzZDSDRLSC85NEtucDg4eGtBTVNz?=
 =?iso-2022-jp?B?Q3g4LzNxaFB5MmlSUy9DYUJOQjd5dE9CT0s4ZXJHdHlScVJJTmR6bG1W?=
 =?iso-2022-jp?B?RTIyWU9MSVlWZXB2RVRTbzh3a1U3YlAycWRzbk1kZFJxT3Fkb1Zqdmta?=
 =?iso-2022-jp?B?RnY0bFF2cWJYTFZla3BMdWdoUE1xRkZveUM2UFJsUjJlaGJrTnowVVVQ?=
 =?iso-2022-jp?B?SklMRHRIZXdRVW13SzVRQ0VVSUVlbVE3RnJlSVFpdzIrNXB2VEdNc0U2?=
 =?iso-2022-jp?B?R3RGZWY3c1VLeUM3UDcyQ2xNT3FwUktxU3RONU5kVTNBbFowcE9CRURQ?=
 =?iso-2022-jp?B?RjdvTldUS3VWeXQ2TExNbUloT3Z6Kzg1U0s1VmRZR25XRkRZSXNEN05D?=
 =?iso-2022-jp?B?eTFqaldHd1VRcHRidzhjZE5seDdhcHZUa0pkVVY2THhDYXhzb05MbFVT?=
 =?iso-2022-jp?B?bjZLWHFKVkRoMEZJQ1Vyd3FJUjNLNnpXdmtMS1VLaTB2d1Q2d09QUElk?=
 =?iso-2022-jp?B?Qk45enEwYmZtUitlZWJhdjRETFMzai85dnVTS1poUFJSRGFUNk5SK0ts?=
 =?iso-2022-jp?B?V3JTYWNLcUxQTkxyaG9UR3k2K0pwRVIrRnRKelk2Wm5YV1BERFJyZ1pK?=
 =?iso-2022-jp?B?VUFkV2pzVWxqUTNPLzlyajNqVXBhMEVmcUhGZ1NWM0FhV3FNWEdGZy9Q?=
 =?iso-2022-jp?B?QWF1L2lBOGg0YVpPZEZrNVZFOEtQakV0eXJzeWVmSGVlMGJpcThtTDB3?=
 =?iso-2022-jp?B?c3FzeUx2VFB3TS9xd1d4RHdhc0I0WERyTndrVDMzVUY3UjcycThNRVUv?=
 =?iso-2022-jp?B?ait4ZStDSVJCUDBSY21iNUptYkd4ajNlL0gxWXV1VExmcTJxcjBNWlhU?=
 =?iso-2022-jp?B?b2F4aUpPWmNkSmxFRU5sY3N6VEdVcGtBZWd5RTdrMUNqc01XTHNrQkFt?=
 =?iso-2022-jp?B?U0FaNHZqcWlCQXpacEVHdVJKS1g4bEEvd1o0Q3ZNcGhLT0JHemxEeFls?=
 =?iso-2022-jp?B?TmFYWit4K3JuanZna1p2L3lWVmo5RTNmRWpXb09BT3B6RDFpcGxJM3Fl?=
 =?iso-2022-jp?B?OFV6azhxMlZ4S3BxMklPQVI1QlpTTUdCakQ3NWZJbE9sNTZ0TzYxZTVU?=
 =?iso-2022-jp?B?cFhrRG1pcTYwQTNSb3gxZi9JNVdxZzVKQzRFZU4xRFZXRlB0cWtwV3dZ?=
 =?iso-2022-jp?B?OXJDaUVyZUJpRFd4S0hRUWk2UGYyczd4Q2pNTTNmYnhLRDFsbFpWQU1l?=
 =?iso-2022-jp?B?S2ZvKy9ucnNQbjVpc2R2MW5XdlNrWitnMVlxdmxXYnMxVmJHSjVSNWha?=
 =?iso-2022-jp?B?MzdhUmZINkd3eXFrMUhEeTU3U2N6WVlyWWxVdz09?=
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Exchange-RoutingPolicyChecked:
	v6DsSv1phkiw5nqsGGMRsJTckmUtp/VdhxuE+9jNZkEryCqn+/xhs+dSTjh/cYDJ8N1QntotywKaQt6a0udmZvfBr+Ef0Fmb81hSipg6VtpzwffzIaEvaXrgjUDjwk3G7WyYL6XR4aaWDE4WKLtGX0gcEN1+1VEf7GW2MKTOATNBZ1sEJgYcn6Ljh4PlymSs1K7BxPSZNZx6dqOoCpwNQQhaeT+kilFOfzfzGIxrkqDJMOXVakWA3DRXUg7uwYliP0oSgqKnG3qedLYhI5Y3cf4JNPWk69DNVcJRb3VnA5GoP3JmnqCr3Lo+vGqvXrpl0aki28LnAY9R98PK3n6r/w==
X-OriginatorOrg: fujitsu.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: TYCPR01MB11476.jpnprd01.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 2c605ba1-d093-4d5c-49ee-08df2a5e2dd2
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Oct 2026 01:46:49.3819
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a19f121d-81e1-4858-a9d8-736e267fd4c7
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: 2yMopp+OhktIQj4DRLhpUGStxBDvL1ACHyBhTE4tmFLHUKK+ArSeyurXSoHEO57NQRcD64qoJFEEemmdiOPj4aQ5SfRzHk1gPGetO8KMV2M=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: OSZPR01MB8371

The nfstest_cache expects that any file modifications on remote client
are immediately reflected to the files on NFS server and then are
reflected to local client depending on ac* time mount options.
So it needs to change the mount option on remote client from the
default "ac" to "noac".

Signed-off-by: Seiichi Ikarashi <s.ikarashi@fujitsu.com>

diff --git a/test/nfstest_cache b/test/nfstest_cache
index 0014366..d9da733 100755
--- a/test/nfstest_cache
+++ b/test/nfstest_cache
@@ -589,7 +589,7 @@ try:
     x.clientobj.umount()
=20
     # Mount server on remote client
-    x.clientobj.mount()
+    x.clientobj.mount(mtopts=3D"noac," + c.NFSTEST_MTOPTS)
=20
     # Run all the tests
     x.run_tests()

