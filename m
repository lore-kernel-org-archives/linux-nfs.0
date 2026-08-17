Received: from PH7PR06CU001.outbound.protection.outlook.com (mail-westus3azon11010034.outbound.protection.outlook.com [52.101.201.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E753D3D565F;
	Mon, 17 Aug 2026 16:34:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.201.34
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786984490; cv=fail; b=gdvP+8QOXCDL3R1DKhCMX36CL2CHiG5BeCDZfZanggUrDr4jlCoxePkjKoWUcMhxWMjiwJVAvTu8fFHfsGakbhD831WvckdijiwZ3vsyIbGKHUGrOvm9rWvIFDajidviBfnwExr0V6vOzX48QxqeYLeBS9KdNZ9VHa9S4bbQ1cQ=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786984490; c=relaxed/simple;
	bh=sCxUBodGOG9Da3uqCFMwFapZ5Hs5OiR494PgtfkEn0Q=;
	h=From:To:CC:Subject:Date:Message-ID:References:In-Reply-To:
	 Content-Type:MIME-Version; b=Bh7WoHLABdpzyGd7YHRXS/VsEK/G8fUNdpTltVrdXmF23PNDv0Gp2Re9GWErYRUMxgsxVQFuHDC2zUQi7CK6ZAeLdDCMDoC6+vBdtxGHvAaXVvkhpnbtT1WKbFsaLB6R4X9flL0pON+yOGz6XFHCMaby5btanSihvzERGbiXLw8=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amd.com; spf=fail smtp.mailfrom=amd.com; dkim=pass (1024-bit key) header.d=amd.com header.i=@amd.com header.b=cAHd3bfa; arc=fail smtp.client-ip=52.101.201.34
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amd.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=amd.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=amd.com header.i=@amd.com header.b="cAHd3bfa"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=dXw3cRbXz8dfPq/ynvxCvGhu3wO/jyq93ESexyq36Er39UNxCBvYy0Zu6uC3u6OuLfE1zWTk8x10JyRE3JKOU1w/RAtc/+e7A+qJ2KB8kOPLZXj/6RLTuQ/83CEtC9CAEQz6V75sMxOnRlMjfbKtt42xU54G6dmJXhzcFpj55/DR1p9NbxLK6EZUjKvHkXYOYocqSi/21y08vGB+okzo3mmmpEI/3OZdtJ0IfayC91TLcOGI9GlbntCkK1tHwm+a7a3/s+Fys893Bfceebc6AOOMz+N3Zu3FWMgDRHis1Rv0EoooVekT6Jmg8Tj5cQLcSCsxAzslqNc2fHmO3JuV3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=sCxUBodGOG9Da3uqCFMwFapZ5Hs5OiR494PgtfkEn0Q=;
 b=gynEsqcM5uFmttcWbKsGffgTWpNODvQNPZAPVO81UE0JhP+Bf2adZQb5lQwm+1vfF3jBlvPWlcvwBJWadCGDCGjEeTcJl1glQImDBDDb+kjsvKZ1Gwy7WxjnB1ja5rh3CC7mW0nm4XMbaAERVsk4OXd5oCJP55ng/tQkQgVL3q7p5fygHFLIR3b69sgTotWEY0I5nhfPmaGF3058bwZZbgAKWaQTXK55HBlDoGupwE7K/Uf3tJ+kLCiXIcgeOv3+Jf4pm0zk1iSey6swbwECihVSW8dmC41gwEg1RFz9JsBk4NCsmYzAY9CkZ3/koTMH5iWvF+72RuYA6nGLaPvSPg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=amd.com; dmarc=pass action=none header.from=amd.com; dkim=pass
 header.d=amd.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=amd.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=sCxUBodGOG9Da3uqCFMwFapZ5Hs5OiR494PgtfkEn0Q=;
 b=cAHd3bfa9atX3NzpX8es3xmPBIn2TJH7VH6FUgKj+6QXECnJS6WDvrx0xUDs8SwO3DzZSy1FT8theOHlXbNGpsy9FNvNRASYmmUquY+ZGGd6dCVgG8evpkHkSxnvYresh1TrAt9pG2qCGuEE2D3jjReWyoxaRMbR/qzxDMr+558=
Received: from BN9PR12MB5259.namprd12.prod.outlook.com (2603:10b6:408:100::17)
 by CH3PR12MB8850.namprd12.prod.outlook.com (2603:10b6:610:167::18) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.315.17; Mon, 17 Aug
 2026 16:34:39 +0000
Received: from BN9PR12MB5259.namprd12.prod.outlook.com
 ([fe80::122c:cca7:c2b3:90ed]) by BN9PR12MB5259.namprd12.prod.outlook.com
 ([fe80::122c:cca7:c2b3:90ed%2]) with mapi id 15.21.0315.016; Mon, 17 Aug 2026
 16:34:39 +0000
From: "Garg, Shivank" <shivankg@amd.com>
To: "nhuhuan@google.com" <nhuhuan@google.com>, "yiannis.nikolakop@gmail.com"
	<yiannis.nikolakop@gmail.com>
CC: "ying.huang@linux.alibaba.com" <ying.huang@linux.alibaba.com>,
	"xuezhengchu@huawei.com" <xuezhengchu@huawei.com>, "sj@kernel.org"
	<sj@kernel.org>, "lorenzo.stoakes@oracle.com" <lorenzo.stoakes@oracle.com>,
	"joshua.hahnjy@gmail.com" <joshua.hahnjy@gmail.com>, "david@kernel.org"
	<david@kernel.org>, "anna@kernel.org" <anna@kernel.org>,
	"ryan.roberts@arm.com" <ryan.roberts@arm.com>, "rientjes@google.com"
	<rientjes@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>,
	"tglx@kernel.org" <tglx@kernel.org>, "mhocko@suse.com" <mhocko@suse.com>,
	"weixugc@google.com" <weixugc@google.com>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "gourry@gourry.net" <gourry@gourry.net>,
	"Rao, Bharata Bhasker" <bharata@amd.com>, "byungchul@sk.com"
	<byungchul@sk.com>, "x86@kernel.org" <x86@kernel.org>, "bp@alien8.de"
	<bp@alien8.de>, "linux-trace-kernel@vger.kernel.org"
	<linux-trace-kernel@vger.kernel.org>, "rppt@kernel.org" <rppt@kernel.org>,
	"alirad.malek@zptcorp.com" <alirad.malek@zptcorp.com>,
	"Liam.Howlett@oracle.com" <Liam.Howlett@oracle.com>, "mhiramat@kernel.org"
	<mhiramat@kernel.org>, "jackmanb@google.com" <jackmanb@google.com>,
	"dimitrios@palyvos.net" <dimitrios@palyvos.net>, "surenb@google.com"
	<surenb@google.com>, "rostedt@goodmis.org" <rostedt@goodmis.org>,
	"matthew.brost@intel.com" <matthew.brost@intel.com>, "fvdl@google.com"
	<fvdl@google.com>, "trondmy@kernel.org" <trondmy@kernel.org>, "hpa@zytor.com"
	<hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "yiannis@zptcorp.com"
	<yiannis@zptcorp.com>, "rakie.kim@sk.com" <rakie.kim@sk.com>, RaghavendraKT
	<Raghavendra.KodsaraThimmappa@amd.com>, "dave@stgolabs.net"
	<dave@stgolabs.net>, "apopple@nvidia.com" <apopple@nvidia.com>,
	"ziy@nvidia.com" <ziy@nvidia.com>, "vbabka@kernel.org" <vbabka@kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "jic23@kernel.org"
	<jic23@kernel.org>, "mathieu.desnoyers@efficios.com"
	<mathieu.desnoyers@efficios.com>, "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>, "nifan.cxl@gmail.com" <nifan.cxl@gmail.com>,
	"dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC v2 1/3] mm, x86: support copying a folio using
 non-temporal stores
Thread-Topic: [PATCH RFC v2 1/3] mm, x86: support copying a folio using
 non-temporal stores
Thread-Index: AQHdLjulRdOdfNkj60iymqacCQxua7aIEZaAgBpehwA=
Date: Mon, 17 Aug 2026 16:34:38 +0000
Message-ID: <8af161b862695557c40ba9c2ddca0ba0fe004b86.camel@amd.com>
References: <20260730-rfc-nt-demote-v2-0-452dbe3b5073@zptcorp.com>
	 <20260730-rfc-nt-demote-v2-1-452dbe3b5073@zptcorp.com>
	 <CALwWd5usu+e=MgX95zGPUeqRjEu_SARLoiMPQpyMYBoUVQkk_g@mail.gmail.com>
In-Reply-To:
 <CALwWd5usu+e=MgX95zGPUeqRjEu_SARLoiMPQpyMYBoUVQkk_g@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=amd.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: BN9PR12MB5259:EE_|CH3PR12MB8850:EE_
x-ms-office365-filtering-correlation-id: f0e7798c-2b51-4ef1-72cf-08defc7d6ea2
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam:
 BCL:0;ARA:13230040|7416014|376014|366016|1800799024|23010399003|18002099003|22082099003|56012099006|3023799007|38070700021|11063799006|4143699003|10067099003;
x-microsoft-antispam-message-info:
 z4LQMb2ZP5QtsTo0ju07WE4w6bPgaDM4IGSE7UFaPmcK1ZOUjRY05t9t+uBXp4DOkJ94Q21/kp8OL+wcE/ZVOFca0VXL/1VEKOLLMgLdm8WhdKwTvjuPwBzPrLrlQ+Are+e2qPzkxFMdNUbWauqPuf9wqbnvW4i4abmachf0EjSzlaN5V2Vr7G3yEGekBS2WyU+JK+tXXCEzRd9GhXfi7g4rO5PPMtJJpYyagi2HB4xUB2SqDegP09evln5i5jceMlc6ox6ytB+hbdEMFjRxKVIyv72pIv6PspSGFA3IT7XhvFIBU2WALTNpq7N+rNWaRkaqlD/7ejlegyj7nQZq3mMN97+mWJFZiCE06j18tjzaS6QarqMaSTj4GTTCYNAG7Mqb92ogjQ4O2GZagz1wURWo2XGJuKr63+8X4J3HMVFQEzTdz9S9yofacEh2iEEjk0BqXlCH7se2tIeNZag9BcvTCluYydgbSz6ZA1tzKPEWb/QpRTSHlbjnklxiD9BGXy1bwyJrdAguqQW9Y0bpv/CiDvnxekbS3L2rWG9O6/qYX6wnSCePztH+VnZ5N3Xqb3WcVYhz1KYsHb9FGoKUg94mHc+BUITnQp8Onh04VlB4j70uEqMMt7u9sPg1xqg7GFMBlfjA8ZFcnymPVdB4ZF07u9mHFpqMCURZgfGFEIZGa+sO+2hZkRJ/JF1G98dmyWXpaRRukL/WLsijVgFIlL+jv9jkuLhorCOaZ7GsVr8=
x-forefront-antispam-report:
 CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:BN9PR12MB5259.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(7416014)(376014)(366016)(1800799024)(23010399003)(18002099003)(22082099003)(56012099006)(3023799007)(38070700021)(11063799006)(4143699003)(10067099003);DIR:OUT;SFP:1101;
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0:
 =?utf-8?B?QVlEUlZXSGcySnV6UmhtZ1dRcUZwcjBtbGQwRVJDTEcrNkF1MkEzVFRJZlkw?=
 =?utf-8?B?ZFdxd01MaVpuRkJVZStWcWM3bWd2bU0wRUFHcFl3SlFVSUd4SXpKbTZzMm1m?=
 =?utf-8?B?UXZ4aERnTHFEWnk1U3FDSHI5S2VmY1ZRcFU0aHRjRTA2T1ZacnZvWmZncFBa?=
 =?utf-8?B?dUNoSlhYaWtzU3NGU2RLczN1emZaanZTb2tTQmlBa21XVDJ5ejVST1p3SUxI?=
 =?utf-8?B?bmVBTFZjeWlzc25NVzRudUhWRmk0YWh2SmpBbURCMTNyTTR2ckpFWE5MREtZ?=
 =?utf-8?B?aU5VNW8xKy96Q0ZJOG5ydFM2ZWw1WnNuVFdFcVE3Zy9wWWNPWWM2Sy81dGky?=
 =?utf-8?B?VmorQ2Q1aDJ2V2NJNXNzV0NWV0s1ZmRnQXBSdmNrbGNoV2wzTURnVVRiL1Ry?=
 =?utf-8?B?QnZMZWNUZmxsSng2MkN5YXk0V2k4QWVWY0hCYWhTeHNQK3ZpaEJZQUM3dVhu?=
 =?utf-8?B?b2dHaFRtN3A0Wnl4Z1djQmVoVWZWcTZBMmptb3g1QmZnSzJSQ2hPV1h4VjlB?=
 =?utf-8?B?N0ZZanpuUGZDT000a2pjTjVoUmIzSlh3Q01PcmptWVpMQnBXclF2VE56d3N1?=
 =?utf-8?B?dDlkdjNoeXRlaXNSUDlXdnE1MkgxbXd6S2hLU0dlZ3VQakJsNEo1VTdzUGxz?=
 =?utf-8?B?RzNIRTV2SHVhMlhVTmt3R1dCdlJ2R3FZYXpoVDRiS29iYVZKakxIbmFBQ2Vz?=
 =?utf-8?B?VkpBS1IrSlJRdjN1cDlBV2VEemdMRmdFQndFQndYSW0vcnFkdWZwbXZxQ0Fp?=
 =?utf-8?B?ak5CVE1wbWxmZ3doRGNWd21XeTNCdUdBZVo0ZlQ0WWdGRHB1N0w0dllESlV4?=
 =?utf-8?B?bmR4MmdZK2tEYi95Y3JFNkVEQkErei9OQjdUUUZHSllkRVcxOHhTMThUdjho?=
 =?utf-8?B?TmFSdS9EaGxwUk10VUYweGkzRnUvbGp3NjB1Y1NpSDRpajhsNTV4MC9zUWpO?=
 =?utf-8?B?SHgydm9HYzJZWnE2M0hFdEVnQkVHc0F5ekdjbUVXbWVlOVh3WDZmdUhHOG5z?=
 =?utf-8?B?b28zWGIyY0F5YVUrNG1zRmt0T3EwVkFCMGo5SUNodEZDUWprSzRMSlpNVzkw?=
 =?utf-8?B?ME9CUGp4RERZdkhMK2orSk1RUVVuWHZxTFRRaVRTejdRYWYwbWpXcVhHOGF3?=
 =?utf-8?B?V0E3dlpzRDJaSEc4bXpEWEtoOUZWZm9nRjNTenpHbjkvdVN5VDVZWGsvVHE1?=
 =?utf-8?B?MW81N0k4eGxadlFPRERBbVlzWmFQOFA0akM5QmdzMm9IUzVZbHBkL1BkRmlk?=
 =?utf-8?B?b0xuYzc0eHJaRGc1TGUvSnJJMzNnQTllZ3VOMXZiamx3dEtoNmszZVZuRFNU?=
 =?utf-8?B?Rmthc0FUeHlnSlBaSVM3TEhCQkUzOGR4WE5oTWxBT05MdWxyazc2MmxSeVMy?=
 =?utf-8?B?S0tSMzNYK1IyOTJBQ1ptcHRGTTZnc0V1MFRWV1dack9HOEdHN2l0QzBNVkJh?=
 =?utf-8?B?Z1hDTFpJU1BuRUtBN09UcDZMRXpRUGMvWDZzVmM5cnp1Z2I4Mk1HSm5mZjJJ?=
 =?utf-8?B?YTlNZzg3TUZUQ1doZUZYc2tTUlJRaXRWRUFUTDZaSitCN0M0VW1CZUhid09r?=
 =?utf-8?B?bWlhR0NhNGUyTEhiT1ZNVkxteXR6TG43cStsNjlITmtJMEdDRW1iZWRtV2g2?=
 =?utf-8?B?SnZMaGRDY3FhNndlNTA1RklkemcyMlhQYk9IdExTaldKSEZyV1BJRUl4KzRi?=
 =?utf-8?B?TFZUS2w0ZzZ4TGx0bEVpMDBwa0lEeVRMYzRHY2xLck9TNGQ1b1dSbW5nczlj?=
 =?utf-8?B?cnprbWFYS29IUTNnNXp3YWpXS3RjUXdDL1M2M0R2OWp0QndQMnBkWGdvNjBJ?=
 =?utf-8?B?L2RrOWZBMnp3Zm03SFJZU01Fa2lBVlVVeWZmcXlIUnZHWWI2RFR2endrTkl5?=
 =?utf-8?B?eGdOc0g1c0dRd0ZhRDJmblNHNGs4MkYvMUZtcFZkZkJXNm43OXFrdmVZZ1Bt?=
 =?utf-8?B?ZXRvZU9STmhFdXRJeE1jZ3dJNGF4UjRGQ0x0VVVGVTN4UFJkN3NYVC9WNFlG?=
 =?utf-8?B?NHB1YVYvY25JR3VYMTNuZGJXWVpGRWsyanVkZER3OWV4dHVha2s0U3hJZ3lk?=
 =?utf-8?B?NEtDYkxYT0xvbm96cUtiOWdQL3dkaTRsM3pxZHpINEcwbE5wcUpURFRnTUxw?=
 =?utf-8?B?YjdhWCs1aEJ1V3lxNDVTVWcvcnNzc0RpSWFGcVNVaFJYeEcyN2tmMi91MUtQ?=
 =?utf-8?B?U2liTlhheHprVVRoZnJmbGYxYzlndmZvZkxnU2xjbllRWC9VaHIxZ2lZREE4?=
 =?utf-8?B?Mi9Ud2VhUDh3U2V2czFZRzVaOWd4Y04yd1RjZzRiSVYxTkVHTVlyR2hKMlla?=
 =?utf-8?B?VXVycTlwZ1lQK1ZKQ0tOeXgvL2ZOZ3E0dmRGOVc4aUxSdTYyeEVkQT09?=
Content-Type: text/plain; charset="utf-8"
Content-ID: <C52418229C0E314EA0CAFFAA235C4E24@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: BN9PR12MB5259.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f0e7798c-2b51-4ef1-72cf-08defc7d6ea2
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Aug 2026 16:34:39.0082
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: w9blSOMbf9b1NXYBTc38B3Vg76I1gfCPgbFkbEndWXEAlCSAOK+9b8wXR8IhBJt/ScUBqc6XmKqlAuA5rEFjRA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CH3PR12MB8850

T24gRnJpLCAyMDI2LTA3LTMxIGF0IDE0OjUzIC0wNzAwLCBIdWFuIE5ndXllbiB3cm90ZToNCj4g
SGkgWWlhbm5pcywNCj4gDQo+IEFsdGhvdWdoIGNvcHlfbWNfdG9fa2VybmVsX250KCkgYXNzZXJ0
cyBib3RoICJtYyIgKG1hY2hpbmUgY2hlY2sgZXhjZXB0aW9uKQ0KPiBhbmQgIm50IiAobm9uLXRl
bXBvcmFsIHN0b3JlKSwgdGhlIGltcGxlbWVudGF0aW9uIGZhaWxzIHRvIGRlbGl2ZXIgYm90aDoN
Cj4gMS4gY29weV9tY19mcmFnaWxlKCkgaXMgTUNFLXNhZmUsIGJ1dCBpdCBkb2VzIG5vdCB1c2Ug
bW92bnRpLg0KPiAyLiBtZW1jcHlfZmx1c2hjYWNoZSgpIHVzZXMgbW92bnRpLCBidXQgaXQgaXMg
bm90IE1DRS1zYWZlLg0KPiANCj4gQWRkaXRpb25hbGx5LCBhY2NvcmRpbmcgdG8gdGhlIEludGVs
IG1hbnVhbCwgc2luY2UgbW92bnRpIHVzZXMgdGhlIFdDIHByb3RvY29sDQo+IChhIHdlYWtseS1v
cmRlcmVkIG1lbW9yeSBtb2RlbCksIGEgZmVuY2luZyBvcGVyYXRpb24gaXMgcmVxdWlyZWQuIEJl
Y2F1c2UNCj4gbWVtY3B5X2ZsdXNoY2FjaGUoKSBsYWNrcyBhbiBzZmVuY2UsIGl0IGNhbiByZXN1
bHQgaW4gcmVhZGluZyBzdGFsZSBvciBjb3JydXB0ZWQNCj4gZGF0YSBhZnRlciBmb2xpb191bmxv
Y2soKS4NCj4gDQo+IEZ1cnRoZXJtb3JlLCBjb3B5X21jX2hpZ2hwYWdlKCkgaXMgdW5vcHRpbWl6
ZWQgZm9yIHBhZ2UgbWlncmF0aW9uIG9wZXJhdGlvbnMNCj4gYmVjYXVzZSBpdCByZXVzZXMgY29w
eV9tY190b19rZXJuZWwoKSwgYnVpbHQgdG8gaGFuZGxlDQo+IHZhcmlhYmxlLWxlbmd0aCwgdW5h
bGlnbmVkDQo+IG1lbW9yeS4gQXMgY29weV9tY19oaWdocGFnZV9udCgpIGZvbGxvd3MgY29weV9t
Y19oaWdocGFnZSgpLCBpdCBpbmhlcml0cyB0aGlzDQo+IGZsYXcuIEluIGNvbnRyYXN0LCBjb3B5
X2hpZ2hwYWdlKCkgaXMgb3B0aW1pemVkIGZvciBwYWdlIG1pZ3JhdGlvbiBieSBsZXZlcmFnaW5n
DQo+IGNvcHlfcGFnZSgpLCBkZWRpY2F0ZWQgdG8gNEtpQi1hbGlnbmVkIG1lbW9yeS4NCj4gDQoN
CkkgZG9uJ3QgdGhpbmsgY29weV9tY19oaWdocGFnZSgpIGlzIHVub3B0aW1pemVkIGZvciBwYWdl
IG1pZ3JhdGlvbiBjb3BpZXMuDQoNCk9uIEVSTVMgc3lzdGVtcywgY29weV9tY190b19rZXJuZWwo
KSB1c2VzIGNvcHlfbWNfZW5oYW5jZWRfZmFzdF9zdHJpbmcoKSwNCndoaWNoIGlzIHJlcCBtb3Zz
Yi4gY29weV9wYWdlKCkgdXNlcyByZXAgbW92c3Egb24gUkVQX0dPT0Qgc3lzdGVtcy4NCg0KKFRo
ZSBjb3B5X21jX2ZyYWdpbGVfZW5hYmxlZCBwYXRoIGxvb2tzIGxpa2UgYSBzcGVjaWFsIGNhc2Ug
YW5kDQplbmFibGVfY29weV9tY19mcmFnaWxlKCkgaXMgcmVhY2hhYmxlIGVpdGhlciB3aGVuIG1j
ZT1yZWNvdmVyeSBvciB0aHJvdWdoDQpvbmUgb2YgNCBpbnRlbCBDUFVzIGluIHg4Ni9rZXJuZWwv
cXVpcmtzLmMpDQoNCkluIG15IHRlc3Rpbmcgb24gQU1EIEVQWUMgOTY1NSAoWkVOIDUpLCBib3Ro
IGZvbGlvX21jX2NvcHkoKSBhbmQNCmZvbGlvX2NvcHkoKSBzaG93ZWQgc2ltaWxhciBwZXJmb3Jt
YW5jZS4NCg0KaHR0cHM6Ly9sb3JlLmtlcm5lbC5vcmcvYWxsLzIwMjYwNDI3MTQyMDM2LjExMTk0
MC0yLXNoaXZhbmtnQGFtZC5jb20NCg0KQW5kIHRoZXJlIGlzIGFjdHVhbGx5IHNjb3BlIG9mIHVw
dG8gfjJYIHNwZWVkdXAgZm9yDQpmb2xpb19jb3B5L2ZvbGlvX21jX2NvcHkgZm9yIGxhcmdlIHBh
Z2VzIGlmIHdlIGJhdGNoIDRLaUIgY29waWVzLiANCg0KVGhhbmtzLA0KU2hpdmFuaw0K
