Received: from OS0P286CU011.outbound.protection.outlook.com (mail-japanwestazon11010057.outbound.protection.outlook.com [52.101.228.57])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E767448592F
	for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2026 08:17:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.228.57
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791965866; cv=fail; b=cAfQm+9ZUZOXiUsGW87JGWWJVwCWsFjSD2ujmCK38Dn5bbxphwqsCsQI8C4oe2B6QwOdrQrw4YrCAUSmS4TI5DbjzsEyi5HBv1RaE+X5117Xr4Spz/5aMb+vgiSwJBPaIPb2JhdiizjybbK6JAEY04vdZ5u4b1RYanTLn0ELixA=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791965866; c=relaxed/simple;
	bh=q324V9BY3nDL/N8bh1BY+WLj39AqH57RsRUwhvGKBjY=;
	h=From:To:CC:Subject:Date:Message-ID:Content-Type:MIME-Version; b=CdiNzLbhR2s/MvWvxg5hL0fRHY1uQDmCHxJXPTl3QssoBVpqL+pmI1nnX1AI+RIKc9/WftNv4vFT463lWTiadxWqozPAfzg7blgA2CWDHvcp+s2AGeNA6Lov3fufTDWeeNBQxAoF6ws/Dg6V/wHoK1zwqeMUtyzhILEMZkuNEO4=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=fujitsu.com; spf=pass smtp.mailfrom=fujitsu.com; dkim=pass (2048-bit key) header.d=fujitsu.com header.i=@fujitsu.com header.b=ZyJSCfxv; arc=fail smtp.client-ip=52.101.228.57
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=fujitsu.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=fujitsu.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=fujitsu.com header.i=@fujitsu.com header.b="ZyJSCfxv"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=n2IT/wTs9y+VNTv0LG5TXw4POTpyEgzY30LoNUv8EqAA7qvAfjFnK+XiiyNdgcqdwe5T6iQptLlPzw9MzFr+OY4iXcL0nQkzTW760tWzaSQroHJqF6jjOIM8SdIYMIl4rIzfrzTNe78mltUvcFLZ87tFUr92inyoS96RTldAW6jQhvFct+9Yz/jUAkf2n1i0Ac+ILIUNnaBTywglVnERDZz8sVH45wf/icQp6nUessHL0Lbiz/bjxVGOOQE7u5pJ1WOS+PtFlPUbVImz6+7j9BOxpCaUyvMlOW29kuw7qrgHtyO3uTfqWT71KnV/HX7K2IGCjYHwigqgIvz1sAeZ5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=io1LmFjGn1ykFhIkdODpabQWJkxyye9l/B/3DMmLUKk=;
 b=o0BE2X2lgP6RFK564ORSTk0/VCOn4bXUuelOlaEcecC7zxRIlLGzqY9HG6tk20cqVnQXh/LYEpkm94lSw7x46giOBX/g7UsxI19iTLpinsSKjcUjrBJb5bNha7/+MPhpj+sfbimloehUTbVJaFuoMTBgkMYxh461vvmdBuMY41bydLMTpvSAv59M8KFACjDvVYBTICo9Vy8RTI+8W4mfeYzDooF/umcjUbUSVXt4Sic3ZkbhTWrG4DEiLnMaW+RtnassrE33UBdaDxuELUavkAjNPXswcG1QcOthAR6QD5JDDpPp7rsC5UkkJoY7134ZXOIehY8Nj2Fx3vjhk3CQfQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fujitsu.com; dmarc=pass action=none header.from=fujitsu.com;
 dkim=pass header.d=fujitsu.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fujitsu.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=io1LmFjGn1ykFhIkdODpabQWJkxyye9l/B/3DMmLUKk=;
 b=ZyJSCfxvtoMkYdU7ApK1pRAX9A9BP+0IwTAaZszUX638pRNX1Ntw453eWzrtkBe3Ib7YWf19vMRVGoD/MWcGoGY1UI0oDRK2kKccwyQ19ugrvf4bj8uwhXTiq63plWQR5rn5xdjdOkq7hI1DW25ya1YCfHUXMfLhfU99S8L04cUCCIeEhK1IfPHNaaE1cBYYEt/uoJiCYBn4YvzNKBEkJ5HmEh2aDK3pNvUiDHuwn0HdO/9Zxizz3bBNwflP4CBKCMibz1UF72x4L3uokRSjkiTSXGEuw+u8skIC8tuEnXzviTqSSqTejTpU7M7Q4CbZ+99SgCdRhGLi9PiYsqFqqA==
Received: from TYCPR01MB11476.jpnprd01.prod.outlook.com
 (2603:1096:400:3b8::10) by OSZPR01MB8629.jpnprd01.prod.outlook.com
 (2603:1096:604:187::13) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.522.12; Wed, 14 Oct
 2026 08:17:35 +0000
Received: from TYCPR01MB11476.jpnprd01.prod.outlook.com
 ([fe80::38e7:2:fa52:18cc]) by TYCPR01MB11476.jpnprd01.prod.outlook.com
 ([fe80::38e7:2:fa52:18cc%4]) with mapi id 15.21.0522.012; Wed, 14 Oct 2026
 08:17:35 +0000
From: "Seiichi Ikarashi (Fujitsu)" <s.ikarashi@fujitsu.com>
To: "'Jorge.Mora@netapp.com'" <Jorge.Mora@netapp.com>
CC: "'linux-nfs@vger.kernel.org'" <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfstest: CACHE: skip "should have changed just after" test
 for ac{reg,dir}min
Thread-Topic: [PATCH] nfstest: CACHE: skip "should have changed just after"
 test for ac{reg,dir}min
Thread-Index: Ad1btDV9kItLNQ9OTWSy1iAEiSnP5g==
Date: Wed, 14 Oct 2026 08:17:35 +0000
Message-ID:
 <TYCPR01MB1147654DC0BFFD29BC7F0A18E889D2@TYCPR01MB11476.jpnprd01.prod.outlook.com>
Accept-Language: ja-JP, en-US
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
msip_labels:
 MSIP_Label_a7295cc1-d279-42ac-ab4d-3b0f4fece050_ActionId=07e62a62-8c6d-449c-981b-224ed0e6befc;MSIP_Label_a7295cc1-d279-42ac-ab4d-3b0f4fece050_ContentBits=0;MSIP_Label_a7295cc1-d279-42ac-ab4d-3b0f4fece050_Enabled=true;MSIP_Label_a7295cc1-d279-42ac-ab4d-3b0f4fece050_Method=Standard;MSIP_Label_a7295cc1-d279-42ac-ab4d-3b0f4fece050_Name=FUJITSU-RESTRICTED?;MSIP_Label_a7295cc1-d279-42ac-ab4d-3b0f4fece050_SetDate=2026-10-14T08:14:37Z;MSIP_Label_a7295cc1-d279-42ac-ab4d-3b0f4fece050_SiteId=a19f121d-81e1-4858-a9d8-736e267fd4c7;MSIP_Label_a7295cc1-d279-42ac-ab4d-3b0f4fece050_Tag=10,
 3, 0, 1;
authentication-results: mx.microsoft.com 1; dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=fujitsu.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: TYCPR01MB11476:EE_|OSZPR01MB8629:EE_
x-ms-office365-filtering-correlation-id: d8e1facb-e042-4c90-ed7f-08df29cb9a3e
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam:
 BCL:0;ARA:13230040|376014|1800799024|23010399003|366016|10067099003|18002099003|1580799027|11063799006|38070700021|56012099006;
x-microsoft-antispam-message-info:
 i/lG9gy+WiO3dXrF0637UZGCQcvafPaJ60b8odg3juvYur+p2lsgL11STK385WwR49SMxky6Qjyt6msXC3ZF8SNMwrAHWtNsw0KYBdlJng7Nyhqx0WqekDi0OZ6yvXd4BgpIgNCmYTQgPr2QBo5BjDYZJfV8ZrrW1X/aG63fapHgRZLkGRfteAeEXdwKoZlyS7iZBOAHd/olVWVNfb+cpunDIpIk8BPGkNoX0hKbK/pLEaBqV/N2C/NLgPnXzHaqvOuwpStWf8h/BeK/HU1Wn1XBIhu7RjfK3ahkvr1YCtNctdEPjdv+ay1KhQMtWgeaRB1LFIOm6NAgLTeWQLhyHSViky32E+wYfPSITzLJAUuwdHCRJ03d8xsB16rEOvFKl5UPMMc4kvoyjPkMm2xxpHWxxEOflII/cfSw8NOLwcY5Hm7t8vA82EfSjGiec5mejaXVinJ3o2cyGUd+bB3eMWR12gTdJsYXGMrAvQQIAjNZjpMBBaVtx7mhQFqT7NfSIFj2tuQpAaf+Fl8VbznRBMnxQC28xW05mKApktWfry2o7LHI6f2bTXzP9viYpek24vavgj0sWz6oQZotqlqvgGYcdyTjL+l/wUU0CVjUfSaLUXwLgs8Mz0P2jbaEpEyA4taP/VNmHkhwrqneF4+yCxYvjg0Vt6MRaOh0OD7rLnBtLE9idK2TkZe5IunW3jF2m5TGatujTs8JGWIdu6iU8NxgDUuP5OtaVRhGwjDzmddzbfxaEYAQAH8NYWeOxiuR
x-forefront-antispam-report:
 CIP:255.255.255.255;CTRY:;LANG:ja;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:TYCPR01MB11476.jpnprd01.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(376014)(1800799024)(23010399003)(366016)(10067099003)(18002099003)(1580799027)(11063799006)(38070700021)(56012099006);DIR:OUT;SFP:1101;
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0:
 =?iso-2022-jp?B?R2o5czZ1MEQxb0ZGcmdoQU5rbXNvT2JSeXJHTDFYdmhkcUVxTUQ0ZTc4?=
 =?iso-2022-jp?B?S3JxNG5TbEV0UUdYMmYxZTFxRFlKZkZIU20xUE8vRVYxeUlURmtvMjZo?=
 =?iso-2022-jp?B?RzVRMzlhbERTdld2blF3eFF0aTNsb3ExV1djUEszQ0h5RGF4Q0pKKzVW?=
 =?iso-2022-jp?B?aW52YlVPeVFIVWNHbDliU1dXY1NiT1drR2hkZEI0K2tRVEdZcHZOcUNz?=
 =?iso-2022-jp?B?eHdoQ3E4OXd3QnlnVlJaVkxON1F4ZUVmYlFmZWZFKzdWSXdGWUtvL2dj?=
 =?iso-2022-jp?B?UXFKT1puY3pFbzNBM3pFdmhLZTlrRnNvVGxoSkthYkxPMnp5L0N4WEFS?=
 =?iso-2022-jp?B?bWNXcUlDUUUweHpkMlUzZlYwQmF4K0R2R2xHckdJUzNQb2gvdkVObG9M?=
 =?iso-2022-jp?B?R2h0dG1aazV4THRIL0NUOEtaTkRTNmVsQkRWZmNKUmk0TFpBK2lta21P?=
 =?iso-2022-jp?B?azZpdWt5K0hURGFIRXhJQVQ3RXZremE2elVHSkRoRVZmLzZUbkk1SG5v?=
 =?iso-2022-jp?B?MEdiMDdVak11R2xSaWNvQkIvNllnQlU4Y3doa0kreDVhayt6U2RuZllp?=
 =?iso-2022-jp?B?VXV4VDlQUThCQ1RaaFo5YXAyd016YUw5d1kzc3RzL2V2YS9HZzRDUXFP?=
 =?iso-2022-jp?B?blRDa3JaR0RQSlVuMXpIY25qTldSMHN6ejRkMXRLazFpakNyczhSWlpT?=
 =?iso-2022-jp?B?UndXalNwUzNuT1huV3V1eS9KbkNNWGNiZlM4alFkZFFhWnN4L3NOOGlB?=
 =?iso-2022-jp?B?UWJvWkNaZEV2S041SzdMaTVPbHl4Nld5QmxmeGd4Q2ZuZWs5MHduTURn?=
 =?iso-2022-jp?B?S3NHSm40dTNpbUJ3cTNaTzBVSmZLZXNjMXZlYW1zZTlzcWNQd1JEYXRa?=
 =?iso-2022-jp?B?K2pXTGdROU5NM3lxRkdwNjJEb1oyWStRRE9abVdoNFZEc0t3Wks0U2xH?=
 =?iso-2022-jp?B?a0FrZGFNMVpSaXZRRVl2S0tMZzhRRmJzQ3YxMnZPbmt0czVGZzYrOWNa?=
 =?iso-2022-jp?B?UUYxNGNlcHNBdnZmZGlDVHJWMEQ1S1M4ZVhIQjZPNkhLNEF2UXpqLzNO?=
 =?iso-2022-jp?B?dldUeURLT05DbEJQcUxTVGZGNHNTclpVMks4ZUJMRFdvRFlpMmdJQ0M0?=
 =?iso-2022-jp?B?dmFhWGZHYnZTOEJLRmRnUzY0cnJUZ0Zha2JWOHY3ZnlyS1ZLckhsb1FC?=
 =?iso-2022-jp?B?N2Q5VGlERUFUOEFnWGNIL0NheEQ4MHF5M2pWTXkyTmZxZ1liTU1MRytp?=
 =?iso-2022-jp?B?bDFKaHE0WjdaODRMMXVSa0NUNEs5cGRobDZWeVJhOGo2Z0dxMzQxYTZP?=
 =?iso-2022-jp?B?aXhwcTlNL2VnSEltaDFybGlOby9jeXhhNVZ6cG14bUhIdjNERkwwc1Bs?=
 =?iso-2022-jp?B?YVhYNWZMbU90N0JsUkRLRmQ1cytTN2ZES243TVFSMWRmY1ZlYzlBZWh5?=
 =?iso-2022-jp?B?aHpqYVAyOTJHTWZ5aERMcVh2b094b3Q5MlJheXowdXg4T2hHc2tjbDM5?=
 =?iso-2022-jp?B?eENSRTNBRU90aWg3RFNlM0Vua2o1ZFg1U2ZMenhPTzR2SHIzRGV6YUF5?=
 =?iso-2022-jp?B?ODY3bm5CRTdyMGhRa1VnRnVtL3VzMjBPUU1KS1NpTTFWV0J2bDY4SEps?=
 =?iso-2022-jp?B?d1NwT29VdzBBMnJpeVp3REx3bkI2SXQwSlY4R3BwVWI1TUlOZXNpMFFP?=
 =?iso-2022-jp?B?ZGR3aCsxUW9ZYUpLczNydnhsZ1JzWW5CRisrbnM5d3JONWVWM2JvbUoy?=
 =?iso-2022-jp?B?Mm84WWZ3cmhhQ1A0MElNbFBNMnZkckNNYWhqQ2o2aWdpemEya1B4L1BR?=
 =?iso-2022-jp?B?SW8xYXMzSTJOZCs2T2srWHlKQkl2RE1nOFdBTnhteC9ENmVENzVDNXRO?=
 =?iso-2022-jp?B?VGVWZ2RaVUNCNjQvWG85UDdadXRzTy9aMnJVdVFJQTEveUMrSW5PajNK?=
 =?iso-2022-jp?B?VEl4UHY0NXFYZTlJaUJ4UUtNRk8wd1NoUDk1dlZQWjNpYkMwajhBODdB?=
 =?iso-2022-jp?B?ZjgralFXcTFaYVFjeENKdHIxWTBVSndYeG05WU5JbGdTT0xzQTcydHFE?=
 =?iso-2022-jp?B?V29LVGRia1Y5Qlc2S1FUR3lHb0xyYmhLWk1EWXEwcXlhQnptdkRKRDVt?=
 =?iso-2022-jp?B?Qko4VlFVL1BoOG9vZ0htMXkrcXpjMVJiTVA0YUM5ZkduMUFhUmZrbHY5?=
 =?iso-2022-jp?B?dWR4RGJmN25JbG00L0tZYnBHUEVabFdicjZ6Sk4rWmlDT09lemczMnJz?=
 =?iso-2022-jp?B?R3labGlBTlRTSnhZYlBRcTU0S05HZXFTbVJrUWYxZnFjakxkTHJxbEk2?=
 =?iso-2022-jp?B?aERSV3FPdENyS21Ub25QalJIZ1cyRmRyUTZ6Um43NEEyQTcySit4cENQ?=
 =?iso-2022-jp?B?UFVXMlEzYXVTZVhXK0VmOEVSL0NQbmIxdXhQSDE4c0R5dzIrSGt2alF4?=
 =?iso-2022-jp?B?bmVpQkRkcjhyVXNlaHpKQnZhZTRGK2ZjUGZXalhLS2xzQWlBQ2tLMTlI?=
 =?iso-2022-jp?B?WUUvQ0c5aTZjQzlmakhxSzFSY3k2V1RQZGFaQT09?=
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Exchange-RoutingPolicyChecked:
	4GXvGiGPc9Q8oXnbHGrZIlS/ISmRKLe2TzfrOGldaE5ArUi0TQ6kdPLps4Jx8wJDwseNMXFzSwqxV/7PL7NrnxHG2pxB3HWWl25l/tCQzwjlLpJjRjnt9DZxv1PGyQha7MXSy6dynCGuVFTIW5D9XP1GGpk9eMqXDXPOvSbTWPG2yu+s7Vhn/HHekn0juhvYjFGb4uSrMpLbYtE7CKVLhhcfMK2ySQ1HOnYvDb/FcM7ytajemiiFJUbR427VqWgPEu6vsWshd0WMHLh0jPLVprLHSS1WTwU0Pw70RJ8TjI3bjFtGH50T6YuqUBOr+LDflVIGhvbepkpC2Oipuj8JMA==
X-OriginatorOrg: fujitsu.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: TYCPR01MB11476.jpnprd01.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: d8e1facb-e042-4c90-ed7f-08df29cb9a3e
X-MS-Exchange-CrossTenant-originalarrivaltime: 14 Oct 2026 08:17:35.2244
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a19f121d-81e1-4858-a9d8-736e267fd4c7
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: K9NVYPg6/40fhjwv3pzhQet0KdqlQcBxGca21Dq0JtYt2owg1LfPaIm2gEkIWTjSdDOmDrTp4dGh7xciDCnCDrIFeKBCfhxWYXNe1E0WWu4=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: OSZPR01MB8629

The test expects a file modification on remote client will be seen
on local client immediately after ac*max/ac*min seconds, which is
guaranteed for ac*max but is not for ac*min.

Signed-off-by: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>

diff --git a/test/nfstest_cache b/test/nfstest_cache
index 0014366..3e6d86e 100755
--- a/test/nfstest_cache
+++ b/test/nfstest_cache
@@ -257,11 +257,11 @@ class CacheTest(TestUtil):
             self.dprint('DBG3', "Sleeping for %f secs, just past %s" % (se=
lf.justbefore, acstr))
             sleep(self.justbefore)
=20
-            # Should go to server
-            test_expr =3D self.file_test(data_cache, fd, data+data1, dlen+=
dlen1, atime=3D(time()-stime), inwire=3DTrue)
-            self.test(test_expr, "File %s should have changed just after %=
s" % (cache_str, acstr))
-
             if acregmax:
+                # Should go to server
+                test_expr =3D self.file_test(data_cache, fd, data+data1, d=
len+dlen1, atime=3D(time()-stime), inwire=3DTrue)
+                self.test(test_expr, "File %s should have changed just aft=
er %s" % (cache_str, acstr))
+
                 stime =3D time()
                 self.dprint('DBG3', "Change file %s again from remote clie=
nt -- cache timeout should be back to acregmin" % cache_str)
                 self.clientobj.run_cmd('echo -n %s >> %s' % (data, self.ab=
sfile))
@@ -280,10 +280,6 @@ class CacheTest(TestUtil):
                 # Go just past acregmin
                 self.dprint('DBG3', "Sleeping for %f secs, just past acreg=
min" % self.justbefore)
                 sleep(self.justbefore)
-
-                # Should go to server
-                test_expr =3D self.file_test(data_cache, fd, data+data1+da=
ta, 2*dlen+dlen1, atime=3D(time()-stime), inwire=3DTrue)
-                self.test(test_expr, "File %s should have changed just aft=
er acregmin" % cache_str)
         except Exception:
             self.test(False, traceback.format_exc())
         finally:
@@ -424,13 +420,13 @@ class CacheTest(TestUtil):
             self.dprint('DBG3', "Sleeping for %f secs, just past %s" % (se=
lf.justbefore, acstr))
             sleep(self.justbefore)
=20
-            # Should go to server
-            dirlist.append(dirname2)
-            test_expr =3D self.dir_test(data_cache, dirlist, nlink+1, atim=
e=3D(time()-stime), inwire=3DTrue)
-            self.test(test_expr, "%s should have changed just after %s" % =
(cache_str.capitalize(), acstr))
-            nlink +=3D 1
-
             if acdirmax:
+                # Should go to server
+                dirlist.append(dirname2)
+                test_expr =3D self.dir_test(data_cache, dirlist, nlink+1, =
atime=3D(time()-stime), inwire=3DTrue)
+                self.test(test_expr, "%s should have changed just after %s=
" % (cache_str.capitalize(), acstr))
+                nlink +=3D 1
+
                 # Increase the hard link count by creating another sub-dir=
ectory
                 stime =3D time()
                 dirname3 =3D self.get_dirname(dir=3Ddirname)
@@ -451,11 +447,6 @@ class CacheTest(TestUtil):
                 # Go just past acdirmin
                 self.dprint('DBG3', "Sleeping for %f secs, just past acdir=
min" % self.justbefore)
                 sleep(self.justbefore)
-
-                # Should go to server
-                dirlist.append(dirname3)
-                test_expr =3D self.dir_test(data_cache, dirlist, nlink+1, =
atime=3D(time()-stime), inwire=3DTrue)
-                self.test(test_expr, "%s should have changed just after ac=
dirmin" % cache_str.capitalize())
         except Exception:
             self.test(False, traceback.format_exc())

