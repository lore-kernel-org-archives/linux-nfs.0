Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.228.46
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1792993242;
	b=y0VtdFgoOB+a8lBFbDKWdQftk9/qBGjzuscmBipyeoaXP6xXNYsK6ZDY/oYnQXMfKjuS
	 29JUIvJoaU9M7ag60Eqx9nQslzsv+6P3OL3Gd5RCLB9knbCtvNxaYEOhppzR7adlSzyFt
	 qcUs+hTg/gDbLeDrJX7YnRjSK95e2nLODgYuJBlP4mEfVMdl39gRDx6N2vjJCXHfhhfZR
	 jYwWmZzUK/yqnJXTDBAiGn7gH08aRFLEzR/8EYjjYjLD0OmJ3fVn8Tp57gxb5WQI5o0h8
	 LjY88mAw/gg05rTwOnxDNLhGBtbOU15kjchUr8GyUl+wpYhiB2u/b/FwQbXGHR9BGYg==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792993242;
	h=DMARC-Filter:DKIM-Signature:Received:Received:From:To:CC:Subject:
	 Thread-Topic:Thread-Index:Date:Message-ID:References:In-Reply-To:
	 Accept-Language:Content-Language:X-MS-Has-Attach:X-MS-TNEF-Correlator:
	 msip_labels:x-ms-publictraffictype:x-ms-traffictypediagnostic:
	 x-ms-office365-filtering-correlation-id:x-ms-exchange-senderadcheck:
	 x-ms-exchange-antispam-relay:x-microsoft-antispam:
	 x-microsoft-antispam-message-info:x-forefront-antispam-report:
	 x-ms-exchange-antispam-messagedata-chunkcount:
	 x-ms-exchange-antispam-messagedata-0:Content-Type:
	 Content-Transfer-Encoding:MIME-Version:
	 X-Exchange-RoutingPolicyChecked:X-OriginatorOrg:
	 X-MS-Exchange-CrossTenant-AuthAs:X-MS-Exchange-CrossTenant-AuthSource:
	 X-MS-Exchange-CrossTenant-Network-Message-Id:
	 X-MS-Exchange-CrossTenant-originalarrivaltime:
	 X-MS-Exchange-CrossTenant-fromentityheader:
	 X-MS-Exchange-CrossTenant-id:X-MS-Exchange-CrossTenant-mailboxtype:
	 X-MS-Exchange-CrossTenant-userprincipalname:
	 X-MS-Exchange-Transport-CrossTenantHeadersStamped;
	bh=pSK9+ipH2Eqm6Nuyjw05tdV9kEGoE5yeWIv2ZP2r8wI=;
	b=WSVKmY6qKjCdB8Gez9NeSPaHHpTbRA+PilU2OjuhcA07e0b289JHg33myhO9JYSoyfqY
	 XObGFEH3g7CtQGsh7QMsDa81JZN48Rqebc4FQqUL4sP1qEnoDGpVzBH3HESehr9zBSjgl
	 91XhVx5/4c9mIxLO2bbMiOdJflJcz3Z7TaMt+jRQvQjGFioDokh0y0WE9Cune7XjLo9o8
	 +YaUpPbKpg6GbQORJj2aNYvRPi0Mf1fvRTvUe0adONalNsxzlqV5c8ccYEVcwsixHw9Qp
	 bTAAivllu9uBUmnGa5cghL/HPC65TksJlWxICTbWAzamB5qTzed/OzfEAG+Yo0dTanw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=fujitsu.com;
	spf=pass smtp.mailfrom=fujitsu.com;
	dkim=pass header.d=fujitsu.com header.i=@fujitsu.com header.a=rsa-sha256 header.s=selector1 header.b=s0B62fMh;
	arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.228.46
Received: from OS0P286CU011.outbound.protection.outlook.com (mail-japanwestazon11010046.outbound.protection.outlook.com [52.101.228.46])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (secp384r1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 71F46606A31A
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 05:40:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 71F46606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=fujitsu.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=fujitsu.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=fujitsu.com header.i=@fujitsu.com header.a=rsa-sha256 header.s=selector1 header.b=s0B62fMh
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=w8N3LteYA7Q/hDNYoV7yDvx6GJqf1BhzYbfqgJC1i4AnX0Ib9lqnMgZ67yn1lUlPloqJ33HYp1y/EuaHiEp/C8YJBkhUSVFuemyiv8jfYHuSgtHB+1NxiMALN+mrcQlvM/cdGdd1w62CsE2uYs5CgL2xWR8XTEA6913SeJWxow5RgbT7Fj6Sa5f6BmmX1C6NEMFqyb8VURq+39IwjTDf4KjXpmOrTLLR/DootnzJWLrZhArW3kfoHzAC6xvm8oA2Dp1Z36cso6tJ51xAM1GBTrzj8nJAQX32D9ED1xWdH1MO47HGVHLfbAfd7Gl/5wiNmZR30okA3GJDEHI10QOqUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=pSK9+ipH2Eqm6Nuyjw05tdV9kEGoE5yeWIv2ZP2r8wI=;
 b=EA73m3l1iukzLyaYsOjVUxqHhkooaQ/T33LXawqwAi1GhT6GQACVtzuAsUIcrjP9sV+u6QIeIUaLuom2z1SRv1a2zXGA/13lchlsJNwP021jv77YR9YJpoFxHHRyZRIzrEwCHaqwb3ieoZr8yIzq0EoSybb+TnD9KWL3gSHrji+Q88bYsuLi3HiggbEFsEF8zypNmoWBEMG2kNB4I4lzGyaKvWK+tRMDQ7qWF9AiATHLTmLIqOvJZeVL4VSnD5ZBqrWF4W7ZQjoodD6VhjiqFET8fkmFBpKdDS9e7LxzelOrr47CnKhYybiNkTZ06wJ6/ecdEqZy2qnQ9dbfY/PUcg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fujitsu.com; dmarc=pass action=none header.from=fujitsu.com;
 dkim=pass header.d=fujitsu.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fujitsu.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=pSK9+ipH2Eqm6Nuyjw05tdV9kEGoE5yeWIv2ZP2r8wI=;
 b=s0B62fMhJsToBUi+marG/CyTkm46rP+nP6VFpwp94N2wUfJ2nlCTmJ/KHwy4x6aEwARUtTfOCvksg0+OS0p288nFUtCQl1nc1RSwgW59SF9sLQ3r+fQ5jeuQD5jXagW5AKXnuUrSeG0cj5dKUoQS6UtmQlWjvwlB6ZRJ93IGymWaRuP6izCjMW1APYU56LuQeqM1ApNNeYgtEJP5IIgyXSEODNlj9o8nGTPIQUHW7SHt3zRAF15SROl2cUUIL5MvLKK12vFWLHeKaOyzVrXUKPTcJ+hq5CZz1GdQPEQPFlOECe0UYj0Y8788QS3hmiGeOAfIfYG/+a+159RqcbC73Q==
Received: from OS3PR01MB7359.jpnprd01.prod.outlook.com (2603:1096:604:149::10)
 by TYCPR01MB11197.jpnprd01.prod.outlook.com (2603:1096:400:3bf::12) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.546.22; Mon, 26 Oct
 2026 05:40:38 +0000
Received: from OS3PR01MB7359.jpnprd01.prod.outlook.com
 ([fe80::e76e:70c6:e826:8776]) by OS3PR01MB7359.jpnprd01.prod.outlook.com
 ([fe80::e76e:70c6:e826:8776%5]) with mapi id 15.21.0546.021; Mon, 26 Oct 2026
 05:40:37 +0000
From: "Seiichi Ikarashi (Fujitsu)" <s.ikarashi@fujitsu.com>
To: "'Jorge.Mora@netapp.com'" <Jorge.Mora@netapp.com>
CC: "'linux-nfs@vger.kernel.org'" <linux-nfs@vger.kernel.org>
Subject: RE: [PATCH] nfstest: DELEG: accept the attribute delegation
Thread-Topic: [PATCH] nfstest: DELEG: accept the attribute delegation
Thread-Index: Ad1cRpZREEYoNoJZS+iAEO6y6dGrBwIxXpqg
Date: Mon, 26 Oct 2026 05:40:37 +0000
Message-ID:
 <OS3PR01MB73599A129E70C80670DA570188612@OS3PR01MB7359.jpnprd01.prod.outlook.com>
References:
 <TYCPR01MB114765511A83C913BD7E9EF9E889C2@TYCPR01MB11476.jpnprd01.prod.outlook.com>
In-Reply-To:
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
x-ms-traffictypediagnostic: OS3PR01MB7359:EE_|TYCPR01MB11197:EE_
x-ms-office365-filtering-correlation-id: 3136e1ea-7367-483c-2a44-08df3323a9fc
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam:
 BCL:0;ARA:13230040|366016|23010399003|1800799024|376014|261009223027099003|261021121427099003|261021123027099003|261022105027099003|10067099003|56012099006|1580799027|22082099003|18002099003|11063799006|38070700021;
x-microsoft-antispam-message-info:
 W5wN5EWbOUwWN6VXh15RC6kD8Hq4FUdN1OWc8/McKwC3f9ijLUvWy/dM4THr+hDsytPBNRzk9z4W3WeDvHXAIkoyL5/gOH2vtL5bK5JOqQA9cAdbyfLmyTR/T/B7ULM2t4ZFbXeAclmNLi0h+Xo5gQVWdULhy1cVl/vCqaK7lNOiJ5PqMyG3WzcHg4l+02dtS/yOu+Kcgkygi3M0vM1aLTtq/RkuLsYZBT+UVr7SEEhCD0GVur5Gya8ddg6l1TxWBuPo9rdZtExvUW9u7SK76PW1t8RAklgvlpEBMbHYXXtgCIag9c45UY4yIYiAM2l1dhya5Wxdcza6Ye3rmSBSdpxH1HX2SHX4MaiV74kpe5LS3NCcOLentspUE+Dc0dFUAHacIOObPwDY8o4LE/1MPBJnBXQ5JeBWLYsR0YNmSXumGxrhb1zOCoMzb6gwO1eRrghvsmb4qg9Hm7kle6J4dGceEKrjmGk9TpLuTuMCTjQiGADueXeZKiembKsk/Va+HRcgLdYpoL5Et96/A7E9Wr/vx2COVz4KuubLUhjRDZqqsCtsp5oljfq9ORe9Ty9PcM5ofa9+4sXm7dQV7D6vcuwItyqZwUyN3czjCU7fncrHA9WV0ymf1LEERWY1UlRExyFmEQnoZ+95ihg6YK1A+CLIfoOtCCd5PDsFk8aXS+YQUrRrHnBauKqr3LFuds+5Tg+XEDClBldliEhChfc11nTQebPKortIIVCvAatbjI1WffGFuSgPOizoaPt1L3DH
x-forefront-antispam-report:
 CIP:255.255.255.255;CTRY:;LANG:ja;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:OS3PR01MB7359.jpnprd01.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(366016)(23010399003)(1800799024)(376014)(261009223027099003)(261021121427099003)(261021123027099003)(261022105027099003)(10067099003)(56012099006)(1580799027)(22082099003)(18002099003)(11063799006)(38070700021);DIR:OUT;SFP:1101;
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0:
 =?iso-2022-jp?B?Q0tPTWs5QWcvSEpBc25yVEpQVFBCSW4zT0xQTnB3b2dhN1FCeWVlTHFR?=
 =?iso-2022-jp?B?NFRiWnV3NHJNSjk1OFpxclJHNnJSTk5wQTF6SlZvQjZ6UU50T2hnV3Fi?=
 =?iso-2022-jp?B?Ykh5YUMyL094OS95LzJYaTAyamgvNGxLRkhRSUZYTkVEc2RUaURtUEd2?=
 =?iso-2022-jp?B?bWhXNEFVbUFGRHFvdTVvbTdkb1dwQWhxaVNvMS9iQ1RmZVRyNkxMWGhs?=
 =?iso-2022-jp?B?eEpYVFdnNUNwUkRZM3N0djExQmhWelZLMXVUOHY5U3BNb00wMGxiRW1o?=
 =?iso-2022-jp?B?elZNTFcxMFlKK3FJMis5Z3A4K1BnSzZnckxIcFJzblJyOU8ra0NBcklC?=
 =?iso-2022-jp?B?dzRVZGtUYktRZXk1K2FNa3V2MFhuTGIzbVpaK1FaejM5NnZOcXFEMzMz?=
 =?iso-2022-jp?B?OFAzVmQzNnJkZ3RhZjhLNVFkclBVeXJMYmw0RlUrRS81bXRDQmluc1BF?=
 =?iso-2022-jp?B?WEllWm0rZjJ0ZzArbWdheDRWN2NLTmhvZ0IwMXVGeXBSSHJTQ1VHWEVM?=
 =?iso-2022-jp?B?SlMzbjMyb1hVTlp0bVFCR0s5M0NEZmhEcmFxbDk3NWxXR2dDUWc5NmFY?=
 =?iso-2022-jp?B?RnFUQmRIUWw4TVlFN0h4S1RMdC9zZ25HK1g5MkdEWng0ZFF3WG00SGtQ?=
 =?iso-2022-jp?B?blByeEhTUHVFYmZMSGVUUWVkNmMvYTBFeGdzT0ttK0cyVFdZejNlcnlk?=
 =?iso-2022-jp?B?K1p2Sm1lSGsrWFpISmZhRkVFcUVhWlFxWjFZQUFnbldmWHhkTTVSNVl5?=
 =?iso-2022-jp?B?UHA3di9JeG9YYi9XZkI5ZncxazErNFo0Rng4cXJFMzZwcWp2clFNQjBQ?=
 =?iso-2022-jp?B?c3dUeC9PelhjRnNsMEd3VHdJTkpwZUFYeGtmZU5MNHczODJtUW9BS3Y2?=
 =?iso-2022-jp?B?QjlIQWcyT0VLQm10VVcyeFBrQ1NpdFNnazA3eElQVlZOQUJ3SWl0UFJB?=
 =?iso-2022-jp?B?TEZKemlqQzIvMkc0UlVQWTQ0OGgxeWhnNEdRU0dOaU5UTEJ3S0dnaU1k?=
 =?iso-2022-jp?B?MVFVV29mcEY3YnVYSFpqMU5BbEFtSjdLSmt5cWhLL1RabUJ6bWs5bW5x?=
 =?iso-2022-jp?B?S1Q3R2ZNaDNVemxXODkzZnZiaVpxVC9JTThkYlJvNkg0KzIwT2pQVTBH?=
 =?iso-2022-jp?B?b3l1eTlsNHJJWVA4ZVFvWXpNZjkxczYxNE4rMFB5b3pBd1lFMTJXSUR1?=
 =?iso-2022-jp?B?ZWJPZlhSU01oN0gyWXFjSTFDNmxrZXlwbnovWTRpbGw0UEsydUZINVRE?=
 =?iso-2022-jp?B?Y252TjdOREc5bEJMbmh3YUdJNHQxejQ3Q0lONS9zSEpESnBHWmhpMnpG?=
 =?iso-2022-jp?B?Q200ZGJQczZka0QzMWxXdmxZMXFCajlZb0IwWUFtSlNHZU41d1dVZzBN?=
 =?iso-2022-jp?B?UGR3NVRSd3ZUMnZ4YlRxZkZVZ0orclJweCt3eVBaR2tGbjEycWV6VUxH?=
 =?iso-2022-jp?B?S1luMHBZRmUrZStLbHVzd3R6VU5UOUZXUEhqaDduQXM1RlM3dVFiSm40?=
 =?iso-2022-jp?B?S1gvaitBcFUzMEhrTS83QU4xU25zelR5TjllRWdoUlVCMTlMSG5LQVlC?=
 =?iso-2022-jp?B?VXJkWVRLNTNudlhWRTgxVThhUmprMWJHWlJxUmpnVTRHUlVUam5USFhP?=
 =?iso-2022-jp?B?MmREVndvUVJ3L3lXN3l3THRUbHM4RTFOejlNc2E0NWpTZ2xSamhIU29Q?=
 =?iso-2022-jp?B?QXlucmg4VDVrZnVFZFQ1T0lPck5tbDByZEV4M1RwYWJXZVFYTERiQUtj?=
 =?iso-2022-jp?B?MDlEYVloc0o5NTRkd0V5SkpLOHpwWkFOWm5ZWFBTc29UM3RydEQ0dnMr?=
 =?iso-2022-jp?B?TFJMWk5kWVgyc0hRTVQrM0djY1FQMmR6QmxXQkVrajNNV0dVR0tSL2FJ?=
 =?iso-2022-jp?B?WUpkc3JHU0NKNHR1ci93TlN3K3pyT1BFRHBPbXBHUmRvUDdZZTRveFV5?=
 =?iso-2022-jp?B?VGovS3NINzBrZzNOQmFEQ0ZmT1BSWUZpR3FISW1aQXNmU29vbVpWQTFn?=
 =?iso-2022-jp?B?SFc3WllNV1o1QnlMVEV2YW41VHRDU1IrYk5GY254a2doMmh5T2R1SjJw?=
 =?iso-2022-jp?B?LzNGRWJ2S25jTkZ3dVk4akNpeVlFS3pLZEtKa0tzTGZNZm5nNGFFbGp5?=
 =?iso-2022-jp?B?Yjk1ZUIvbkQxRXR6UGtkVCtMaU9vKzhydW9FZHMrck82Y3BqSmthNC9r?=
 =?iso-2022-jp?B?dW5OdjBqL3pMVEhFMmIzQWpFZVl5RlBVWUdjeWlXWXM5cFBJTjJNbUF1?=
 =?iso-2022-jp?B?bnVGVzJCbURzYXVERmpqR1g3WkEwNkl0ZS9oeDNRQm93b1Z1ZCt5cnlH?=
 =?iso-2022-jp?B?WGlJeW9WRHVGeUJNdWE3bmFJRkErVmkvUW5SUG12bkdvWjVGWjN3czhh?=
 =?iso-2022-jp?B?SHoyOHBmdlJraDg1REhoc2gyU2N6V0xlZFlmTHkzZEpjR2M4NDg2Ynkv?=
 =?iso-2022-jp?B?TzBpbTl3RGhlOTBqSFZJaTN0Z2NkZUFtL1hReVpTOS9Sd2JpekZrVU1M?=
 =?iso-2022-jp?B?b0JRL1dPOGczbDlDV0FIZEhFWHBwK25rOFdGUT09?=
Content-Type: text/plain; charset="iso-2022-jp"
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
	YBtwUg2aMxnBlkZRngBSCVNmng/C3Le0LxngaCkExKS8+oPELkEDfcnO0ahDFiV2088oq3Gs4xuM6DgbJ93yrtkqjVAtHZKkpHZjj8yogKBwoWW++A4fH0Zh1Xi9Ohpu1Z9EjljPV/iWrL68GABZfZ/FvNyJ9oAjI16g3Y97NdybTWOqanFROxKU6SvOlgqmnAWqGpzrswUVxjIN0hMiXsErNqI4jX5MsLsIKpy5FRkuxJp+PLWchHd4ePbMA8+OIT26ryI/UMZbFjdnQ3kKtCZlPPC8znjU/KQrqOK1I3CXjFGGl0QV8bQjyk/OQpSUa7gDZMFwMUPhinUiPAfGWQ==
X-OriginatorOrg: fujitsu.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: OS3PR01MB7359.jpnprd01.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 3136e1ea-7367-483c-2a44-08df3323a9fc
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Oct 2026 05:40:37.8279
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a19f121d-81e1-4858-a9d8-736e267fd4c7
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: ho+aOFU8B5TGhgny3QJ+l7Kn5/YlVAFVEo6oF/E2ryhhXWZlex88ARcan/0tXNxJeLNt+Ij00pcq0E2MuXZM9O7Z5UEkRrNF2XltN9aRTRw=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: TYCPR01MB11197

Hi Jorge,

Do you have time to review my patches for your NFStest?

Thanks.

> -----Original Message-----
> From: Ikarashi, Seiichi/=1B$B8^=3D=3DMr=1B(B =1B$B@;0l=1B(B
> Sent: Thursday, October 15, 2026 10:45 AM
> To: 'Jorge.Mora@netapp.com' <Jorge.Mora@netapp.com>
> Cc: 'linux-nfs@vger.kernel.org' <linux-nfs@vger.kernel.org>
> Subject: [PATCH] nfstest: DELEG: accept the attribute delegation
>=20
> Since the commit 6237a17, the timestamp delegation is enabled
> by default. Then OPEN_DELEGATE_WRITE_ATTRS_DELEG (5) is often
> returned as deleg_type instead of OPEN_DELEGATE_WRITE (2) as
> per RFC 9754. Current NFStest cannot handle this and fails
> with "FAIL: WRITE delegation should be granted" and others.
>=20
> Let's accept OPEN_DELEGATE_WRITE_ATTRS_DELEG in the case that
> OPEN_DELEGATE_WRITE has been expected, at least.
>=20
> Signed-off-by: Seiichi Ikarashi <s.ikarashi@fujitsu.com>
> ---
>  nfstest/nfs_util.py      | 10 +++++++---
>  packet/nfs/nfs4.py       |  4 ++--
>  packet/nfs/nfs4.x        |  4 +++-
>  packet/nfs/nfs4_const.py |  4 ++++
>  test/nfstest_delegation  |  2 ++
>  test/nfstest_file        |  4 ++--
>  test/nfstest_pnfs        |  2 +-
>  7 files changed, 21 insertions(+), 9 deletions(-)
>=20
> diff --git a/nfstest/nfs_util.py b/nfstest/nfs_util.py
> index cf8d6ae..393b073 100644
> --- a/nfstest/nfs_util.py
> +++ b/nfstest/nfs_util.py
> @@ -567,7 +567,11 @@ class NFSUtil(Host):
>              save_pktcall =3D pktcall
>              xid =3D pktcall.rpc.xid
>              open_str =3D "RPC.xid =3D=3D %d and NFS.status =3D=3D 0 and =
NFS.resop =3D=3D %d" % (xid, OP_OPEN)
> -            if deleg_type is not None:
> +            if deleg_type =3D=3D OPEN_DELEGATE_READ:
> +                open_str +=3D " and NFS.delegation.deleg_type in %s" % (=
(OPEN_DELEGATE_READ, OPEN_DELEGATE_READ_ATTRS_DELEG),)
> +            elif deleg_type =3D=3D OPEN_DELEGATE_WRITE:
> +                open_str +=3D " and NFS.delegation.deleg_type in %s" % (=
(OPEN_DELEGATE_WRITE, OPEN_DELEGATE_WRITE_ATTRS_DELEG),)
> +            elif deleg_type is not None:
>                  open_str +=3D " and NFS.delegation.deleg_type =3D=3D %d"=
 % deleg_type
>=20
>              # Find OPEN reply to get filehandle of file
> @@ -591,7 +595,7 @@ class NFSUtil(Host):
>                  filehandle =3D claimfh
>=20
>              open_stateid =3D pktreply.NFSop.stateid.other
> -            if pktreply.NFSop.delegation.deleg_type in [OPEN_DELEGATE_RE=
AD, OPEN_DELEGATE_WRITE]:
> +            if pktreply.NFSop.delegation.deleg_type in [OPEN_DELEGATE_RE=
AD, OPEN_DELEGATE_WRITE, OPEN_DELEGATE_READ_ATTRS_DELEG, OPEN_DELEGATE_WRIT=
E_ATTRS_DELEG]:
>                  deleg_stateid =3D pktreply.NFSop.delegation.stateid.othe=
r
>              else:
>                  deleg_stateid =3D None
> @@ -1723,7 +1727,7 @@ class NFSUtil(Host):
>          (self.filehandle, self.open_stateid, self.deleg_stateid) =3D sel=
f.find_open(filename=3Dfilename, **kwargs)
>          if self.open_stateid:
>              self.stid_map[self.open_stateid] =3D "OPEN stateid"
> -        if self.deleg_stateid and (write is None or self.openreply.NFSop=
.delegation.deleg_type =3D=3D deleg_type):
> +        if self.deleg_stateid and (write is None or self.openreply.NFSop=
.delegation.deleg_type in [OPEN_DELEGATE_WRITE, OPEN_DELEGATE_WRITE_ATTRS_D=
ELEG]):
>              # Delegation stateid should be used for I/O
>              self.stateid =3D self.deleg_stateid
>              self.stid_map[self.deleg_stateid] =3D "DELEG stateid"
> diff --git a/packet/nfs/nfs4.py b/packet/nfs/nfs4.py
> index 1cd48da..6911a40 100644
> --- a/packet/nfs/nfs4.py
> +++ b/packet/nfs/nfs4.py
> @@ -2455,9 +2455,9 @@ class open_delegation4(BaseObj):
>=20
>      def __init__(self, unpack):
>          self.set_attr("deleg_type", open_delegation_type4(unpack))
> -        if self.deleg_type =3D=3D const.OPEN_DELEGATE_READ:
> +        if self.deleg_type in [const.OPEN_DELEGATE_READ, const.OPEN_DELE=
GATE_READ_ATTRS_DELEG]:
>              self.set_attr("read", open_read_delegation4(unpack), switch=
=3DTrue)
> -        elif self.deleg_type =3D=3D const.OPEN_DELEGATE_WRITE:
> +        elif self.deleg_type in [const.OPEN_DELEGATE_WRITE, const.OPEN_D=
ELEGATE_WRITE_ATTRS_DELEG]:
>              self.set_attr("write", open_write_delegation4(unpack), switc=
h=3DTrue)
>          elif self.deleg_type =3D=3D const.OPEN_DELEGATE_NONE_EXT:
>              self.set_attr("whynone", open_none_delegation4(unpack), swit=
ch=3DTrue)
> diff --git a/packet/nfs/nfs4.x b/packet/nfs/nfs4.x
> index a9c2b6e..cc26e51 100644
> --- a/packet/nfs/nfs4.x
> +++ b/packet/nfs/nfs4.x
> @@ -1746,7 +1746,9 @@ enum open_delegation_type4 {
>      OPEN_DELEGATE_NONE      =3D 0,
>      OPEN_DELEGATE_READ      =3D 1,
>      OPEN_DELEGATE_WRITE     =3D 2,
> -    OPEN_DELEGATE_NONE_EXT  =3D 3 /* New to NFSv4.1 */
> +    OPEN_DELEGATE_NONE_EXT  =3D 3, /* New to NFSv4.1 */
> +    OPEN_DELEGATE_READ_ATTRS_DELEG   =3D 4,
> +    OPEN_DELEGATE_WRITE_ATTRS_DELEG  =3D 5
>  };
>=20
>  enum open_claim_type4 {
> diff --git a/packet/nfs/nfs4_const.py b/packet/nfs/nfs4_const.py
> index b76cbf7..b788e21 100644
> --- a/packet/nfs/nfs4_const.py
> +++ b/packet/nfs/nfs4_const.py
> @@ -1021,12 +1021,16 @@ OPEN_DELEGATE_NONE     =3D 0
>  OPEN_DELEGATE_READ     =3D 1
>  OPEN_DELEGATE_WRITE    =3D 2
>  OPEN_DELEGATE_NONE_EXT =3D 3  # New to NFSv4.1
> +OPEN_DELEGATE_READ_ATTRS_DELEG  =3D 4
> +OPEN_DELEGATE_WRITE_ATTRS_DELEG =3D 5
>=20
>  open_delegation_type4 =3D {
>      0 : "OPEN_DELEGATE_NONE",
>      1 : "OPEN_DELEGATE_READ",
>      2 : "OPEN_DELEGATE_WRITE",
>      3 : "OPEN_DELEGATE_NONE_EXT",
> +    4 : "OPEN_DELEGATE_READ_ATTRS_DELEG",
> +    5 : "OPEN_DELEGATE_WRITE_ATTRS_DELEG",
>  }
>=20
>  # Enum open_claim_type4
> diff --git a/test/nfstest_delegation b/test/nfstest_delegation
> index 717fa97..e51feb0 100755
> --- a/test/nfstest_delegation
> +++ b/test/nfstest_delegation
> @@ -283,6 +283,8 @@ deleg_map =3D {
>  deleg_str =3D {
>      OPEN_DELEGATE_READ  : "READ",
>      OPEN_DELEGATE_WRITE : "WRITE",
> +    OPEN_DELEGATE_READ_ATTRS_DELEG  : "READ ATTRS",
> +    OPEN_DELEGATE_WRITE_ATTRS_DELEG : "WRITE ATTRS",
>  }
>=20
>  def file_lock(fd, open_type, absfile, lock_offset=3D0, lock_len=3D0):
> diff --git a/test/nfstest_file b/test/nfstest_file
> index eb3ac93..fb99289 100755
> --- a/test/nfstest_file
> +++ b/test/nfstest_file
> @@ -319,7 +319,7 @@ if not fh_list and (dirfhcrc32 is not None or len(pat=
hs) =3D=3D 0):
>                          for item in pkt.nfs.array:
>                              if item.resop =3D=3D nfs4.OP_OPEN:
>                                  stid_list.append(crc32(item.stateid.othe=
r))
> -                                if item.delegation.deleg_type in [nfs4.O=
PEN_DELEGATE_READ, nfs4.OPEN_DELEGATE_WRITE]:
> +                                if item.delegation.deleg_type in [nfs4.O=
PEN_DELEGATE_READ, nfs4.OPEN_DELEGATE_WRITE, nfs4.OPEN_DELEGATE_READ_ATTRS_=
DELEG, nfs4.OPEN_DELEGATE_WRITE_ATTRS_DELEG]:
>                                      stid_list.append(crc32(item.delegati=
on.stateid.other))
>                              elif item.resop =3D=3D nfs4.OP_GETFH:
>                                  fh_list.append(crc32(item.fh))
> @@ -354,7 +354,7 @@ if fh_list:
>                          continue
>                      if item.resop =3D=3D nfs4.OP_OPEN:
>                          stid_list.append(crc32(item.stateid.other))
> -                        if item.delegation.deleg_type in [nfs4.OPEN_DELE=
GATE_READ, nfs4.OPEN_DELEGATE_WRITE]:
> +                        if item.delegation.deleg_type in [nfs4.OPEN_DELE=
GATE_READ, nfs4.OPEN_DELEGATE_WRITE, nfs4.OPEN_DELEGATE_READ_ATTRS_DELEG, n=
fs4.OPEN_DELEGATE_WRITE_ATTRS_DELEG]:
>                              stid_list.append(crc32(item.delegation.state=
id.other))
>                      elif item.resop =3D=3D nfs4.OP_GETFH:
>                          fh_list.append(crc32(item.fh))
> diff --git a/test/nfstest_pnfs b/test/nfstest_pnfs
> index 71e91dd..8632896 100755
> --- a/test/nfstest_pnfs
> +++ b/test/nfstest_pnfs
> @@ -335,7 +335,7 @@ class pNFSTest(TestUtil):
>              index +=3D 1
>              nio_total +=3D nio
>          if nio_total =3D=3D 0:
> -            if iomode =3D=3D LAYOUTIOMODE4_READ and stid_str =3D=3D 'DEL=
EG' and openfh['deleg_type'] =3D=3D OPEN_DELEGATE_WRITE:
> +            if iomode =3D=3D LAYOUTIOMODE4_READ and stid_str =3D=3D 'DEL=
EG' and openfh['deleg_type'] in [OPEN_DELEGATE_WRITE, OPEN_DELEGATE_WRITE_A=
TTRS_DELEG]:
>                  self.test(True, "%s should not be sent to DS when holdin=
g a write delegation" % io_str)
>              elif openfh.get('dtcached'):
>                  self.test(True, "%s should not be sent to DS if data has=
 been cached" % io_str)
