Received: from OS0P286CU011.outbound.protection.outlook.com (mail-japanwestazon11010066.outbound.protection.outlook.com [52.101.228.66])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2A8EF1DDC38
	for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2026 08:21:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.228.66
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791966080; cv=fail; b=KT+KxI9mDeEB1JlqQm3mrcJzmVSDAOIAjLbr3GBAbmIkNsK7fZmTf/VQsgR5CB2ufoQMamBgMY1Qf/G9oVl9q5hSXOjI7tcnDuRDuEZPCB5FCy183k8nrjnRffrPW0s/eajA64XUjqnj9A0ImZZploLUC/E4NloclDg6RstB+Ts=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791966080; c=relaxed/simple;
	bh=z5A8D8Pf5yl63GPGb42eKq2CzVxCl6fpQvOEfviM5pU=;
	h=From:To:CC:Subject:Date:Message-ID:Content-Type:MIME-Version; b=WrTmsSuVy069O11P7ewos7F+FhSwZXlXuONh+sOxMlWbOBHXI+2beFCu5Wx0GpcLWCp8Sby9u38EchD4piIBPDuyJjoqiL3RpUTK/F4kAS0cjZCqXKMEVnKf1kO067TSSF0p3MKbII2LoRXZqXWZUeJsrydXd33Ww4KDJDrNNqY=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=fujitsu.com; spf=pass smtp.mailfrom=fujitsu.com; dkim=pass (2048-bit key) header.d=fujitsu.com header.i=@fujitsu.com header.b=J68ibE0O; arc=fail smtp.client-ip=52.101.228.66
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=fujitsu.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=fujitsu.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=fujitsu.com header.i=@fujitsu.com header.b="J68ibE0O"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=T43y3uWEJzVR8T7rF4WbM90AUxrmD3Mo4pMMzhKayKYTM9UdSrKbixw6Oy734DWAoDfzEGdnKe7IywWU62BKRJsTX7nebRewJY7Alzvqzl7ff2CFtAZqAvPjGHxA5vdbVunuzUGRr/ncFSYd+IkhPIWHWav05ykOyLYrzH0LCkp6FApfgC4nOBg9Y5VMcRrN7vFyKY0mmd6EHYCC4/zifWt3wzeSNGgSH8Sz2XNqXU4RFzvx9ys5fvS9wQs7QsB4KHTG3WNeom2L2rFayJK7ui8Fm2PBEdZNyN1zJfUG7PWkAAOU2MTaPvKG/QYbf8CoWHROBvjX9QGYctc9uEWNTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=jsPJ+vDLYQL/53QefJh6YalroLHu1bwEVWJFw85XMxw=;
 b=fHYcK90FHy/TIQVshcowDGc2ZN382XSCUfqxW6M5eko/hzOKplefc1ZHXdMX6lv5u+7L6mzJASAmsZo9CPVDlOmYLBTeBYfLvU9w9cyy8u6jBNgAy8H1UBw34QBjTs5RHB1LZ9JPAZ4ONx3fFxSFxZ4s2D74h96kGfkEo8Qc0WveH82Scq2XaJLk9aNONeljz/ThTbhHAOT9JvzrO1Q7TRLZsGIUUV/7vGv+HiEBnV/oDV6Fegb4NAv/2DU7DEDeUViWA0WprdlyFHop2f2NhvrZp8O2HOh8fdJDlfPe17AW1vbi9ypTAAW/3VGsX+ymexDo65IliLLpvzXuM14i3Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fujitsu.com; dmarc=pass action=none header.from=fujitsu.com;
 dkim=pass header.d=fujitsu.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fujitsu.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=jsPJ+vDLYQL/53QefJh6YalroLHu1bwEVWJFw85XMxw=;
 b=J68ibE0OmDY9lp6Y2HYmtRaEyaC85LsUUDUYRQvrfLd/TVwlr0msKc6gr7INAsyFyEQiu/osfqTowthFAGJ32wL7pTM+swmYfjwZ+MHY156Aw+OjOuqPExRMF9ajCs0PaCIvCfs1j4zG4UxV03GfSVUQ9eS3Ckou9R5vS6UExtZkQZX8F2ZarqaLy3uhAIQ/JurRFuRNCI5MTDri1W7YoXndKO4qc1ISO4FiErfnjbe0XXiDnp6kC+A4NBNkv1K6GyiQAKhkogABBRuhSdCXqDDnjrygOIGZ+UbweYp2zNWFEds0kZCu4onDm5Lte/X9N5+IktfZfQCqQej4Eyj4TQ==
Received: from TYCPR01MB11476.jpnprd01.prod.outlook.com
 (2603:1096:400:3b8::10) by TYCPR01MB10889.jpnprd01.prod.outlook.com
 (2603:1096:400:26f::6) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.522.13; Wed, 14 Oct
 2026 08:21:17 +0000
Received: from TYCPR01MB11476.jpnprd01.prod.outlook.com
 ([fe80::38e7:2:fa52:18cc]) by TYCPR01MB11476.jpnprd01.prod.outlook.com
 ([fe80::38e7:2:fa52:18cc%4]) with mapi id 15.21.0522.012; Wed, 14 Oct 2026
 08:21:17 +0000
From: "Seiichi Ikarashi (Fujitsu)" <s.ikarashi@fujitsu.com>
To: "'Jorge.Mora@netapp.com'" <Jorge.Mora@netapp.com>
CC: "'linux-nfs@vger.kernel.org'" <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfstest: CACHE: mount with "noac" option on remote client
Thread-Topic: [PATCH] nfstest: CACHE: mount with "noac" option on remote
 client
Thread-Index: Ad1btM73cBKQKIVGSQu4SCgEmGC6Dg==
Date: Wed, 14 Oct 2026 08:21:17 +0000
Message-ID:
 <TYCPR01MB114761B70698D667415686BCC889D2@TYCPR01MB11476.jpnprd01.prod.outlook.com>
Accept-Language: ja-JP, en-US
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels:
 MSIP_Label_a7295cc1-d279-42ac-ab4d-3b0f4fece050_ActionId=c07f9c08-b072-4ca0-911f-076a2a2ac75e;MSIP_Label_a7295cc1-d279-42ac-ab4d-3b0f4fece050_ContentBits=0;MSIP_Label_a7295cc1-d279-42ac-ab4d-3b0f4fece050_Enabled=true;MSIP_Label_a7295cc1-d279-42ac-ab4d-3b0f4fece050_Method=Standard;MSIP_Label_a7295cc1-d279-42ac-ab4d-3b0f4fece050_Name=FUJITSU-RESTRICTED?;MSIP_Label_a7295cc1-d279-42ac-ab4d-3b0f4fece050_SetDate=2026-10-14T08:19:04Z;MSIP_Label_a7295cc1-d279-42ac-ab4d-3b0f4fece050_SiteId=a19f121d-81e1-4858-a9d8-736e267fd4c7;MSIP_Label_a7295cc1-d279-42ac-ab4d-3b0f4fece050_Tag=10,
 3, 0, 1;
authentication-results: mx.microsoft.com 1; dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=fujitsu.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: TYCPR01MB11476:EE_|TYCPR01MB10889:EE_
x-ms-office365-filtering-correlation-id: 0a134686-1beb-4cf7-bc4c-08df29cc1e73
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam:
 BCL:0;ARA:13230040|1800799024|376014|366016|23010399003|38070700021|56012099006|11063799006|10067099003|18002099003|1580799027;
x-microsoft-antispam-message-info:
 sevjZzlysChcoQZLrkgUbBZLgHtpFVFtSkaQrlKHcpYwICb5vSkm+IZgu5uJ6iv8O1XHm0bl3GAH2Q9472R8yP/Zlq+iBBkMEkJF+RNuAnGXPZriA56bi5qY+H2EGDQPS5BdBJdzmM4N4ChrB//L1nB0lI7PiDGDQtiwwbe+w3sxghgFWlMqVDDl5vvN4Jv+irM4+029bhVRFNZkK/BlNfrEMMAUn8pylvsuwIAxM0Y03ZwV92DZFgx1lgRb2KmloOqikAEpI3OuNzD7b0J1NsQxzEvSZMcg4d0/W5nVAYP7OA332lxRqrs5otLGbhgndholmzvI81tWqPaGt4+6RjfaCMYT7md3/cQNQA3naWSMUskJRZKaUisWxKR3Di7g0wFce+fdcxDaelc2dwJPX23rxBfyuBeQj5xajvGAGjpph+uGmlMKJKAlH15y/h5oixsQe97qzq5ZnMRDhGTNO64QetTdXl9EdnhewY+p6YaWnIs14DhwurkbWpQ3CLIkCRsOlhMQvhzBAg2snQIoPhxerwaJa5gWtZXehhPHcwsAUnGPmu7ewlc/xR18xW9ltzS/phevBo4ppo+WfBRkoLSyev7DIPjEERyP9O5UMVcrR12ovxts41gP/fR7+arf1RIvq1S7ScARrBLIOW7Vi1OX+bxbxzAhOU9rH9lPABflhfdlyjbkJb9a8htuZS/hTNTJmRFz0vCdnbFA1K+D3nEW7ow4dYA3ulMAOPguDFJ8rkDcRZs/6ctZVq6fKMOt
x-forefront-antispam-report:
 CIP:255.255.255.255;CTRY:;LANG:ja;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:TYCPR01MB11476.jpnprd01.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(1800799024)(376014)(366016)(23010399003)(38070700021)(56012099006)(11063799006)(10067099003)(18002099003)(1580799027);DIR:OUT;SFP:1101;
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0:
 =?iso-2022-jp?B?VVdrRjJ1dzNBR1hreUZ5RFRCd3c0V3BWVnoyallyY3JYdVJ5Q1owa0xP?=
 =?iso-2022-jp?B?NTUwVGVSSm9tdGFibXNxT0JzL3U1ZDJpNS9JWFpSQlp0d1dpV3l2VU1z?=
 =?iso-2022-jp?B?eEU5dnVlQ0MrdkFmQjVoS0NzNEtKSmNhLzNobFZUZFBwOWZsc2E4Yll4?=
 =?iso-2022-jp?B?THhnbjJId3BwNE13VWRBVFRzNUp5TE0zcXpKQ0VXQ1NXZ0liRVFwMDlN?=
 =?iso-2022-jp?B?YitJbmkzY0htUWd5dTRHNUZlZ1ZoSmhUb2FNUkFneVBjWGpvTHdQVzVX?=
 =?iso-2022-jp?B?alpPeUw5QWUvUXZWcWI1OUdZeGdtMTE5b0wyNFJaMHZWZHh5ZmpYRmEr?=
 =?iso-2022-jp?B?ZCtxSUt6dC81OUM1MDgxV2pDOU91R2h0REYxL0UwZnArLy85aWlwTW5B?=
 =?iso-2022-jp?B?ZHZXM0ozK1YwZ2RnK21kM0pYS2xObTVNUUJyNnNibnBTMjFNV0RVUmdr?=
 =?iso-2022-jp?B?UmxhUlM4SEtaOG9yUjNFMm03bExWYjZUVEUxc3lNZ3F0Yk1qckZLYnVI?=
 =?iso-2022-jp?B?aUtSQURQdUx6UjVFTUpHNmk5NnEwSjZMMmswNEUwWElYSGNuUnpUc2NO?=
 =?iso-2022-jp?B?MGhDcUppaGd3eG5VMFZBZmRiTy9rbDFhYWVnMWovTW4yYW1VcE5xQVNV?=
 =?iso-2022-jp?B?WisrUVF3QmNHaFpCWFg5cFo0VU5ManI1M0M4eUFZWDNqSyt4YVRydVQ4?=
 =?iso-2022-jp?B?SXhxbUpVNUowVHd2ZnNwRFh2NEhqaTJteVovS1RNc0IyNkdmUVM0RGpB?=
 =?iso-2022-jp?B?U3lic1VMRGVpTzZhQWNzTW1OOVRXN3NNbmZrYlhVNXNYWURQZ3JYZHFW?=
 =?iso-2022-jp?B?Y3BmaFVpTFZyb1pXREp1MEU3M2dpb0xPQmtmdWp5dnpUa3hZbnNLaGQr?=
 =?iso-2022-jp?B?VC9sMUdZLzFoeXhDVWJ6c2pZMTRPY0VrSFVtU0lleUhUWm52bFZUVktX?=
 =?iso-2022-jp?B?Z0dyRWMxakszTEhFMXhpeGx5eVVpakF1cUNyMGJ5RnRlYitzcU9rNDBo?=
 =?iso-2022-jp?B?R1o3bDcrYlE3R0NxV09na01ZSldRNUJNdU9GcnhpaVRPWUN4OWRaWklS?=
 =?iso-2022-jp?B?dDNnTXpqc1lBRzNoRFZOa0Mrb0R1VU9GdDM4ZTczQ1ladVEvaVpvR0hJ?=
 =?iso-2022-jp?B?bWVPbFV5aGpBdGF2WUI3Y1dFU1dDZnRUWXozc0x2ZWVRQXZnQ29ENS9j?=
 =?iso-2022-jp?B?L0YxejFqSEdzOFV0TGZrZHhOempNZm1od1VXMWVkcTRod2U5ZU9iSVpF?=
 =?iso-2022-jp?B?S1huSGhqdWtmc0pESElVanZGOTNGTTNkYy92M0s5YnJEU1E0T3lQSGZj?=
 =?iso-2022-jp?B?akpLd0NHdWErZHMvMWp3OXJSL0pxSVlRQ2FOVHY1eEYzTUFEeWJTS1VI?=
 =?iso-2022-jp?B?cWZSMXRHOHBJS2lGNVV0OUtxdi9WQS9SRkJSU1RqWVVhM3hEVjA3eWZ6?=
 =?iso-2022-jp?B?VUlsWVNrUW9lekJYWlZaNjcxSHVUdGN0WTg2VXkvb1dKcTVUNUFDWEhR?=
 =?iso-2022-jp?B?ODlLY3JSYnJQbEMyNnFFR3hjVmNFQVE3R0MyZ1hxZW5DSmtXZHpwOVZq?=
 =?iso-2022-jp?B?VWNTS2M1Y20vYnVtb0ozeENtczB0dWd2TzNjMGNHQnZKTkoxZVpMODZl?=
 =?iso-2022-jp?B?SXZ6ZVA0dmVkS1dGZEREc0kzNWJmaU1QT2ZtVzB1NXpMQzBQdjUrTDNj?=
 =?iso-2022-jp?B?bGpqazlBZkxMejNBSHVCMXBBSHJ4K1RxcnZhSkpLb1A0MWlhV2xtaktr?=
 =?iso-2022-jp?B?aVY1Y2VEV29JSnF2RlgvQ09pcDJWRHYwWUhwZHArUy9KU0lrZmNVd0Jh?=
 =?iso-2022-jp?B?eFR6NTFJYWc3aUlJUjN0NWdZbjBqaUkwR3hDY1pndWVJcGxvdHNiRFZ3?=
 =?iso-2022-jp?B?ZHl5VHdJTFhoS0tEcU1YU1NmWWNlcVo2YXFiNWdqbjQzUTIxbHRQYmZj?=
 =?iso-2022-jp?B?ZHJrS2pMT0xKWE5NakhvYmNuaHh1Wm5FUlNqRVZEUnJKY1FOQi9aUGtn?=
 =?iso-2022-jp?B?QmJmaStrRE1DejBQaUxXc3h3M1k1Y3Z0UndnVDgyem9mdTlpWVlSaUZE?=
 =?iso-2022-jp?B?dGRvMnB4VUVrVUd6bTArTTJ5QmtDQW5MSEp0dWFrcTVvUHBiSDd3NnYr?=
 =?iso-2022-jp?B?OTBlOGMrbUlDQUgzU0VjSGpWZ3dJUHBPL29mUGl1MWlOSkZqMUE5QUc0?=
 =?iso-2022-jp?B?R0dpSFJjMWNrN01BUEM5aXhVM0kyclJOOW5OSUNaMzhzRHN5Tk9vdG1Q?=
 =?iso-2022-jp?B?TFlTVWt3amM1dGc0R2wwbG03ZzhWc1JHSXd5anQzc0pOcmlwUVBjazZx?=
 =?iso-2022-jp?B?VEoxUnFmUjZ3bmNCRTVhczlQZUxGdTZ2dk9GQTMrZXFFcGJqZ2llYWhN?=
 =?iso-2022-jp?B?bDVVUHhMaXR2dElHS0psR3ltc29nd2t4bmZvcnl5bS9HTEJGSnRFc2dn?=
 =?iso-2022-jp?B?QnBDQjFtT3lYalFmUDFqd2JTblErR09FTWxvTDhhbmNTaTByTmw2Rnl2?=
 =?iso-2022-jp?B?VkFKY0daZjNKV2VUTTN1c25wellVc2lMNXVWdz09?=
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Exchange-RoutingPolicyChecked:
	gK0OydV8v1acXaoscbvtIl4iP3FpjeVeLloLNiRMSQDM22popIZOGKahmQyPi/noQtDfrEcyeEgkk0trgOd/zw4UoZu9TD4b1wsOCQU14r0dJSiBJq44IF7aEGSCW6fKEkv5pdDb4VRdVx8+APkiJz+6K5nywwBFzaDl7EXLiZyfnyDFrxAxcr/PN6mSmMTuefiH6MsBHwCCZF5FngxxPqGL09H3BCwPV7tmeSeKlQhkuOlC3rUTIpb94CGAfpPijKsAsgMnIQDBCYrK9QASvQew/zkVf4OGHFMMX/k9hCUoTkMaaj4l5rSKsH4xCi+fIESe/scH0ABEWY1D9HS6Sg==
X-OriginatorOrg: fujitsu.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: TYCPR01MB11476.jpnprd01.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 0a134686-1beb-4cf7-bc4c-08df29cc1e73
X-MS-Exchange-CrossTenant-originalarrivaltime: 14 Oct 2026 08:21:17.0758
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a19f121d-81e1-4858-a9d8-736e267fd4c7
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: HeEx1sZCbXEI+PibYjTwz+CBuL9bNcZtoZ5uK82Pw2sGCaMZLfLZoAm9SSOSA5cU+z8jOAW3khz26K4u9sah21LgCVxQYtP6oQG54GaBYKg=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: TYCPR01MB10889

The nfstest_cache expects that any file modifications on remote client
are immediately reflected to the files on NFS server and then are
reflected to local client depending on ac* time mount options.
So it needs to change the mount option on remote client from the
default "ac" to "noac".

Signed-off-by: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>

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

