Received: from mgamail.intel.com (mgamail.intel.com [198.175.65.9])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 15B64175A5;
	Wed, 16 Sep 2026 06:02:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=198.175.65.9
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789538550; cv=fail; b=Vb5eRrmRpI0VW73I/M+qqeIzB+TAWFLUyYGUDTjZIE8MwDV2pjIPOtWsWOHWmKtK+nFYGpMPyo7n6EWhLxbqyjks6nacMhhUfriIJKj6nD+jURVQgQuwbYfrtBp4DiwFVGfplIRQML/DgqDdmOSPyTE5a56OJTYMbweGaRQaMNg=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789538550; c=relaxed/simple;
	bh=u4yzirQYlivPBDz9N1zo3Ck5+27+iE09ZnvZeviNmMs=;
	h=From:To:CC:Subject:Date:Message-ID:References:In-Reply-To:
	 Content-Type:MIME-Version; b=X8FFlNDelJDQYhzU2HyAEphiZvGu16jTQbzFyPCd84iU+F29me+J1X8O58EtQRSfxSGQIFqqENdA2tPS0wa6mBrHarsbYuhrUoAHCJhLB+m7zsxTZs1GGs31NyZWB8CBsv3IPCOM4IR1SA8UrvXP7tjtetBJ+4Ssq4LiKhxLqzQ=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com; spf=pass smtp.mailfrom=intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=CFwRVKZf; arc=fail smtp.client-ip=198.175.65.9
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="CFwRVKZf"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1789538547; x=1821074547;
  h=from:to:cc:subject:date:message-id:references:
   in-reply-to:content-transfer-encoding:mime-version;
  bh=u4yzirQYlivPBDz9N1zo3Ck5+27+iE09ZnvZeviNmMs=;
  b=CFwRVKZfeVxhHxduTJL7Y1wu8bMdjojyRNREsTZT7PPUED67K2OVhoT1
   tz18j/ISvQUlyUogZg5RezQpO/DK1/jIvUBQ2HPW9cbxndIPKUf1JT5J+
   iwNIxRnkteK/hd+pR1kPPQM1/RMRcD8sSEKDMGXd/A+1m3b0EiBsrh0QH
   QQvtXw1AM5ymj4kYbABkcCUKBrMnBxKvPR483otLwKbMFRCKGzcf4Qmgr
   48wMVIQWl3A2KprtXvXVzAiUuFZ97sHV3vlm1tukweFe6OYFpOR9m2Z+h
   iaRdYXJJO82gwqcUSdj4gWAVxuO+CaEB0U6WJ5mnc4eRO4XvwEXBW5yTS
   w==;
X-CSE-ConnectionGUID: 3GDhkpA9SxySIpKJeLgwDg==
X-CSE-MsgGUID: FGYJNDMCQuK8TLNnoNPoZQ==
X-IronPort-AV: E=McAfee;i="6800,10657,11905"; a="112678054"
X-IronPort-AV: E=Sophos;i="6.27,103,1787036400"; 
   d="scan'208";a="112678054"
Received: from orviesa001.jf.intel.com ([10.64.159.141])
  by orvoesa101.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 15 Sep 2026 23:02:25 -0700
X-CSE-ConnectionGUID: +Gcs1DTWTo22UW5kkM9i4Q==
X-CSE-MsgGUID: JqfhoEyZTnaN/hzIt5IC5g==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.27,103,1787036400"; 
   d="scan'208";a="311507272"
Received: from orsmsx903.amr.corp.intel.com ([10.22.229.25])
  by orviesa001.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 15 Sep 2026 23:02:25 -0700
Received: from ORSMSX901.amr.corp.intel.com (10.22.229.23) by
 ORSMSX903.amr.corp.intel.com (10.22.229.25) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.46; Tue, 15 Sep 2026 23:02:24 -0700
Received: from ORSEDG902.ED.cps.intel.com (10.7.248.12) by
 ORSMSX901.amr.corp.intel.com (10.22.229.23) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.46 via Frontend Transport; Tue, 15 Sep 2026 23:02:24 -0700
Received: from DM1PR04CU001.outbound.protection.outlook.com (52.101.61.10) by
 edgegateway.intel.com (134.134.137.112) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.46; Tue, 15 Sep 2026 23:02:22 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=kR52ULN357eYwueyJDJU/6xnCLtc+Lehz2ipfmcllwq0DS2dEhQ7sKKZlcP5koUcPtvCXYDQ1DAqS7P5GlIxL/UQ+2VFcsBRJl822XdpxnmnGF2QKp2QkqKnyQozFMabNfz8qnGSrZb89sw3i70YcwvGlkXs/W3vtPjs2EZe/YXZZZUgX7h2Vg/IzxTiKw0CmPS5SGn3617AtomLrRJMjD3FhBG+1BU8UhhtGPZRmeH4xuP4NGxixr6G+gC9XHWyXrX8RHjU3mRMKelSBOcjP37D9CJATnV6NPuYZQ2G9vqR6Zf4Dm3ZCv5q2RVNmzj65CCaabY6rRBOQgf4d7/sFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=u4yzirQYlivPBDz9N1zo3Ck5+27+iE09ZnvZeviNmMs=;
 b=wl3bEXi98TLo2VfZe2QCxRtuGjAhAOJSmAAr/jLtcYcjzHSTm6dhWpXT78yiPhldLZ+HXKhwNQDmZfuHHcubyOvawne7VKGMxLu+91wyLp6XUZUp3aH4xP+zBOK8GLeu/utU4aj0EhqN3bRzCcYcnfoM51DWYMG7gRnMAnb0o1u0Q7FJEba+nE/XsK7RZyqvvnXE/E1C59NqCN8pJ3Kg027UiB4LuapozXm5QcR6NP7hju9BYWBoi63W9frRUYvKPLRhzSBpnPNrq6wDW0IsRWNm7A5W556iAWX5yM3baqYAHe+w79CL5RO89Iz6OdbYKjDKhbKHYLEjlTShpURyfA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=intel.com; dmarc=pass action=none header.from=intel.com;
 dkim=pass header.d=intel.com; arc=none
Received: from IA3PR11MB8986.namprd11.prod.outlook.com (2603:10b6:208:577::21)
 by CY8PR11MB7948.namprd11.prod.outlook.com (2603:10b6:930:7f::10) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.406.12; Wed, 16 Sep
 2026 06:02:16 +0000
Received: from IA3PR11MB8986.namprd11.prod.outlook.com
 ([fe80::e6f0:6afb:6ef9:ab5c]) by IA3PR11MB8986.namprd11.prod.outlook.com
 ([fe80::e6f0:6afb:6ef9:ab5c%6]) with mapi id 15.21.0406.007; Wed, 16 Sep 2026
 06:02:16 +0000
From: "Loktionov, Aleksandr" <aleksandr.loktionov@intel.com>
To: Bill Wendling <morbo@google.com>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
CC: "codemender-patching+linux@google.com"
	<codemender-patching+linux@google.com>, Russell King <linux@armlinux.org.uk>,
	Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, "Thomas
 Bogendoerfer" <tsbogend@alpha.franken.de>, "James E.J. Bottomley"
	<James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, Thomas
 Gleixner <tglx@kernel.org>, Ingo Molnar <mingo@redhat.com>, "Borislav Petkov"
	<bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "x86@kernel.org"
	<x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "Ian Abbott"
	<abbotti@mev.co.uk>, H Hartley Sweeten <hsweeten@visionengravers.com>, "Luck,
 Tony" <tony.luck@intel.com>, Maarten Lankhorst
	<maarten.lankhorst@linux.intel.com>, Maxime Ripard <mripard@kernel.org>,
	Thomas Zimmermann <tzimmermann@suse.de>, David Airlie <airlied@gmail.com>,
	Simona Vetter <simona@ffwll.ch>, "Brost, Matthew" <matthew.brost@intel.com>,
	=?utf-8?B?VGhvbWFzIEhlbGxzdHLDtm0=?= <thomas.hellstrom@linux.intel.com>,
	"Vivi, Rodrigo" <rodrigo.vivi@intel.com>, Dmitry Torokhov
	<dmitry.torokhov@gmail.com>, Matthias Schwarzott <zzam@gentoo.org>, "Mauro
 Carvalho Chehab" <mchehab@kernel.org>, "Nguyen, Anthony L"
	<anthony.l.nguyen@intel.com>, "Kitszel, Przemyslaw"
	<przemyslaw.kitszel@intel.com>, Andrew Lunn <andrew+netdev@lunn.ch>, "David
 S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, "Jakub
 Kicinski" <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, "Arend van
 Spriel" <arend.vanspriel@broadcom.com>, Rob Herring <robh@kernel.org>,
	Saravana Kannan <saravanak@kernel.org>, Krzysztof Kozlowski
	<krzk@kernel.org>, Sylwester Nawrocki <s.nawrocki@samsung.com>, Peter Griffin
	<peter.griffin@linaro.org>, Alim Akhtar <alim.akhtar@samsung.com>, "Linus
 Walleij" <linusw@kernel.org>, Anil Gurumurthy <anil.gurumurthy@qlogic.com>,
	Sudarsana Kalluru <sudarsana.kalluru@qlogic.com>, "Martin K. Petersen"
	<mkp@kernel.org>, Trond Myklebust <trondmy@kernel.org>, Anna Schumaker
	<anna@kernel.org>, Mike Marshall <hubcap@omnibond.com>, Martin Brandenburg
	<martin@omnibond.com>, Kees Cook <kees@kernel.org>, Jiri Pirko
	<jiri@resnulli.us>, Simon Horman <horms@kernel.org>, Chuck Lever
	<cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
	<neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
	<Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, Jaroslav Kysela
	<perex@perex.cz>, Takashi Iwai <tiwai@suse.com>, Andrew Morton
	<akpm@linux-foundation.org>, "Mike Rapoport (Microsoft)" <rppt@kernel.org>,
	Kanglong Wang <wangkanglong@loongson.cn>, Tiezhu Yang
	<yangtiezhu@loongson.cn>, Qiang Ma <maqianga@uniontech.com>, Randy Dunlap
	<rdunlap@infradead.org>, Pengpeng Hou <pengpeng@iscas.ac.cn>, Ard Biesheuvel
	<ardb@kernel.org>, Breno Leitao <leitao@debian.org>, Thorsten Blum
	<blum@kernel.org>, Harshit Mogalapalli <harshit.m.mogalapalli@oracle.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Lyude Paul
	<lyude@redhat.com>, Ashutosh Desai <ashutoshdesai993@gmail.com>, "Deak, Imre"
	<imre.deak@intel.com>, Dmitry Baryshkov <dmitry.baryshkov@oss.qualcomm.com>,
	Johan Hovold <johan@kernel.org>, "Berg, Johannes" <johannes.berg@intel.com>,
	"Korenblit, Miriam Rachel" <miriam.rachel.korenblit@intel.com>, "Alexander
 Stein" <alexander.stein@ew.tq-group.com>, Cryolitia PukNgae
	<cryolitia@uniontech.com>, Jiaming Zhang <r772577952@gmail.com>, Will Porter
	<mrwillporter@gmail.com>, Cen Zhang <zzzccc427@gmail.com>,
	=?utf-8?B?Q8Ohc3NpbyBHYWJyaWVs?= <cassiogabrielcontato@gmail.com>, Rong Zhang
	<i@rong.moe>, Arun Raghavan <arunr@valvesoftware.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "loongarch@lists.linux.dev"
	<loongarch@lists.linux.dev>, "linux-mips@vger.kernel.org"
	<linux-mips@vger.kernel.org>, "linux-parisc@vger.kernel.org"
	<linux-parisc@vger.kernel.org>, "linux-edac@vger.kernel.org"
	<linux-edac@vger.kernel.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "intel-xe@lists.freedesktop.org"
	<intel-xe@lists.freedesktop.org>, "linux-input@vger.kernel.org"
	<linux-input@vger.kernel.org>, "linux-media@vger.kernel.org"
	<linux-media@vger.kernel.org>, "intel-wired-lan@lists.osuosl.org"
	<intel-wired-lan@lists.osuosl.org>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>, "linux-wireless@vger.kernel.org"
	<linux-wireless@vger.kernel.org>, "brcm80211@lists.linux.dev"
	<brcm80211@lists.linux.dev>, "brcm80211-dev-list.pdl@broadcom.com"
	<brcm80211-dev-list.pdl@broadcom.com>, "devicetree@vger.kernel.org"
	<devicetree@vger.kernel.org>, "linux-samsung-soc@vger.kernel.org"
	<linux-samsung-soc@vger.kernel.org>, "linux-gpio@vger.kernel.org"
	<linux-gpio@vger.kernel.org>, "linux-scsi@vger.kernel.org"
	<linux-scsi@vger.kernel.org>, "linux-nfs@vger.kernel.org"
	<linux-nfs@vger.kernel.org>, "devel@lists.orangefs.org"
	<devel@lists.orangefs.org>, "linux-hardening@vger.kernel.org"
	<linux-hardening@vger.kernel.org>, "linux-sound@vger.kernel.org"
	<linux-sound@vger.kernel.org>
Subject: RE: [PATCH 22/28] media: si2165: Use snprintf() to format frontend
 name
Thread-Topic: [PATCH 22/28] media: si2165: Use snprintf() to format frontend
 name
Thread-Index: AQHdRTY9jQOWMk2AsEKP3/0hyhb3d7bQt1qg
Date: Wed, 16 Sep 2026 06:02:16 +0000
Message-ID: <IA3PR11MB89868A02973EDFC70AE3A494E5B92@IA3PR11MB8986.namprd11.prod.outlook.com>
References: <20260915081910.4142719-1-morbo@google.com>
 <20260915081910.4142719-23-morbo@google.com>
In-Reply-To: <20260915081910.4142719-23-morbo@google.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=intel.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: IA3PR11MB8986:EE_|CY8PR11MB7948:EE_
x-ms-office365-filtering-correlation-id: 91c638da-22f2-4603-a1fc-08df13b80f97
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;ARA:13230040|376014|7416014|23010399003|366016|1800799024|18002099003|22082099003|38070700021|4143699003|10067099003|56012099006|5023799004|11063799006;
x-microsoft-antispam-message-info: XewQrtOjkcFP6QiNecvqxrYjG97TlNOdSb92edTyFwdIzjCkGOnJh8pHAsK7qQF1C0M8J3BN+hsqdcVsLBXEbuxRoDLLuzECFb6DCa4r3+mFupLEOHr4JHJJ2HVLRXeckLh3Ycu0AIjqOmTWWWguiXGWTMTUGXXpLh3eD9fyFXMripgxglmbpwloQL5v1XFmkbpITTU75jVNmtpa4sfDoEpuB5D3TtTmYo/J4sVB9CH77+cmQ2oCm0xQuhqo5zLKdhq4+5XjmWlnzTvvE1Lk5ZpsWZ+5z15c+k6BLnMJcfCTico1ldxskteB+Ic3Mmdcl4q+df6SnyJSMwhdRIfkha2fE/B70PdyfSzCNRzaWnuAYViE3FPy5xIh2y9GDvZoETpkCbuJjPRa6feHmAeKQvnBd8OVw/34D4iIQoORjthfOaDIyD/5WJ2Y4sjf/VL8/2Q7aaUDDSVORPFWLCUwovqxucASOTDnTmzeWlMJs+uyliK7/LzJ7znwBRRbALq1wcZwm7Rqqea2nwOJAQbwrOrG2B+cVFa23tdvMDkEbv/T9N0T7Fka+A71kfEkFLse+9dG8YCTRFJoKinqA6Z4m7AR5sW9Jw3EI7ebe0aV4cWqZV04+hocwZOS3pI2xcfxtiA2CJJ+ehxmSi/jHTbX56G0M8CddOmfFTxBhtxNiALsZ31V+OFG4UM5YvQs4RvLQldK9k9LaZ3M8GFTn6cdy6I/RNgdID4STIIxiuEMpJg=
x-forefront-antispam-report: CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA3PR11MB8986.namprd11.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(376014)(7416014)(23010399003)(366016)(1800799024)(18002099003)(22082099003)(38070700021)(4143699003)(10067099003)(56012099006)(5023799004)(11063799006);DIR:OUT;SFP:1101;
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?L1BidmFOZnZ3WlR0L25ZamtWWkZoTDYwSmJqQlBYSWlUTVc1NnM0SXEranYw?=
 =?utf-8?B?NDlobVQzNVY3Ty85aFpnc1FTVEQ2WlVOcDQ2VmdPZjZLYXdOS2pKbWdEYWJn?=
 =?utf-8?B?WTRVVlU2eTRDYTMreVlFYnFEMHJBR3FSKzlSbVptdFVKYzFiMy9SV1lzM2Jo?=
 =?utf-8?B?QjBFWFBXbDVGQS9VYTNheEpyd0ZqUTRteU80WFZzT202RUM2SU5TdkxnSnll?=
 =?utf-8?B?QmxCSEVPNytPZGhlOWUreDlpZzdxWjBnbFRJQlpuZzNmaklPc1hDOU1NVHZE?=
 =?utf-8?B?ZE9xRUJPZ2pISGErQVNEWkpvZTNuYmUwMW9sNng1OUNzbVFiTERZZEpKdmdr?=
 =?utf-8?B?bEswMUl4OHQ5eVRqVGkxdncxTVc0UWRQYzVkYVJGbCsxN3llUnFSRmFsVEFl?=
 =?utf-8?B?TGl3V09JTEc3dVhyUm1INy80Y2c0dXZjSENWQVQxRHZBcGZJL1hqWnBKaDNq?=
 =?utf-8?B?SWRDeTFBWkZmbWphVWdwaUxCODJEZzEyVTQ3UjhiWWdEbmlVVXg5N0NRcTln?=
 =?utf-8?B?bUpaUUZ4N3MzUkVZeHFoT05WemRscEJXMmkwYS96VXBuTGh4dzRKOE8vSkxR?=
 =?utf-8?B?ejlyQ3FVTmtRTUpYMzM1QndaSkwyZitBQ0M4c0lvaWRra0xuZ3NycmFNVDBW?=
 =?utf-8?B?TnJwZDZ3bGlseVZxNEJtUFk2U1owWVJqNlAyU0g4NlBMQ0xkVGs2WHhBSGdF?=
 =?utf-8?B?VHFXdjMzMlBuRk9Xbmp1TVhVUU1VVHVaclBjTTFFREthUGorbmJhbHljY1E0?=
 =?utf-8?B?L203TDRsY0IzZFQ4Z0cvd1hNbHlQYWgvRHFpeTRncGw5aXdjNEc0dlhOZk9T?=
 =?utf-8?B?ZFhrQzMyVi9OaWltSldodWZXTGVoeEJrSHF3aGlsK2UwTHNLRitIRG52Rm9q?=
 =?utf-8?B?NzB3S213SGNPZHRwczdYdVBHbzdrWW9pVDFVZXM3RlRlZXh5ZVI3TzNrVHlq?=
 =?utf-8?B?QmZnMU9MMFpLY2hLQk1oS3NRaTR2a05SaFRlMDFoOHlMeUJvSGhPRGJWSUh2?=
 =?utf-8?B?ZVB0SkVncnVKejNBeVZxTlJ2dXk2SHVMT094OXFwZDV3V1RUU2E1T01jNFVS?=
 =?utf-8?B?NHVPZmhPUUFEbWs1cCt4R04yMS9hM3VxSkViNzZiekRwdGZxVUM3Mitncjlu?=
 =?utf-8?B?YlFjK3F2Qjd1TGdaeWdRSks4bEVMR1hISzArM0lReW5QYm50eXhXQmllRitt?=
 =?utf-8?B?eXVCQzBZb0l5UzRVRDdmQktqMUd5ODFOZGZVN3hhQnBIRy9uM0RYeTRJc2JC?=
 =?utf-8?B?K29VMlZ0aHRlQjFjcHJBSXV3cDNDZU5jWjY4Wm1YeWdCSHVKeEg4ZzZNa2cr?=
 =?utf-8?B?TzlaYUZ0ckl1T2NOTmlkOEFTZWZBL0RaeDVGblVXcWhqcFM2UCswby9qTXhz?=
 =?utf-8?B?MzhWcDAwa3Q2bDJRTHU4V1VCS250ZDlZeU9POFA1MVpqRC9vM1FWdXB6Qm1B?=
 =?utf-8?B?cDVWUW5VMGhocTNhWFNta0dCNFlwZUxiUDNQT2xCU3RkVzJwWklLY3A4dCtv?=
 =?utf-8?B?ZjQ0cDJLY0hleFpra1VlR3JvRVFzaXp6eFNlYkplbEJCTFVUQTBvc0JVdFFL?=
 =?utf-8?B?MmYvWEVVTmR3eGQyVUg5ODNzRWRIR1hWWHdycEk2WWtBVTdZZU1NeEhBMWhM?=
 =?utf-8?B?N0VvTmZvYSt6VDNqZjR5SnhLNUtyRDNVMG5MM0Q5eS8rWk8vWHFtWUJPMUpx?=
 =?utf-8?B?NzZpOVplc0YwWWVNcEZTcFdLV2ZFdFpzbWhkZjR6bkpHUmM3YUxFbG9TUEFy?=
 =?utf-8?B?bEdzWjcyRkNEVnhZaUw3M1JkZ3pNODZvMXo4SjBaTlVwM2xGMFZMK2VzT3hL?=
 =?utf-8?B?cDNkTEtXcEIyMXVwaUwrcVlua25sbmY4NWZhYjNNVVhYeTBQZStOR04yMGFB?=
 =?utf-8?B?ak4vYnEwV0NGSjA1amwvcGpYaUUvM1kxRW9YZWUwWG5UOENMRzdCd1VPTkZw?=
 =?utf-8?B?V2VEeTc1QXROSUY2dG1DSFhsRFdOOXg3ako1RWxjMHRkdTdweWNiZm93cm5P?=
 =?utf-8?B?RWR2a2tkbEljK3ArRGJ1L1Y3ZnlzbE4zZjRCT1Z0Si9rU3podlFrb2FzY1Vp?=
 =?utf-8?B?ZE1XUzR2VmIxSHk4dnFoSmRaVVN5NE40amlEaGNKMHQva29ueVZ1OGRIWkZR?=
 =?utf-8?B?bWpRak9WOHIrVDR1ZHJBVmlneXhLVW9adHFndWtTcmNmVGVuVGE3dlJXY0tE?=
 =?utf-8?B?a0t3VUpKQUFVREJnTVZxRGhoMGFuekROM3FjL3o1RnFLL3p2VmtmVkRQQitQ?=
 =?utf-8?B?Vi9mVVU1M25EampMZFVVMklMY1ZDU2xidHZQTysyQlBaTlJrbEVTbVpoczZp?=
 =?utf-8?B?OWVHTFBHSTFxbmJEcjFwcUZoRFB1MVBxeEhhS3NWaE1ZbElvZUhWQT09?=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Exchange-RoutingPolicyChecked: mAxZV488Z677DzSzDhBi/SG3NsoAlLRyBRKn0J2vp0L9SzfHnjJwF5uCGP7BK+FREN16/wLJ9MIHSJTnX92D9GH2nSUzaUVwuSZR8zFJKjXnl3Chb1IGlnLLqIB3ipP727J52TZwwuaJ7xU5wvHB2xe4s7pvrV9P2ZhV61Anec3UmWP1e5P2t4bX1GBAyFZDOXfOMKcOYE3NlsbNwfaXHjdo2auGzz6RUjLtqJTRBw+xJSog/RvNK2c5y3tb/EQYpLLIryu67tbfgdlh8wMcqhbZRRkYE1jLbABOVMr3cxxqPEgZb6i+g1R0/f7HW6L6Aq0thy0l1mNmuzLznCswXQ==
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: IA3PR11MB8986.namprd11.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 91c638da-22f2-4603-a1fc-08df13b80f97
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 Sep 2026 06:02:16.5871
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 46c98d88-e344-4ed4-8496-4ed7712e255d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: gYtgf4WCR+DcAqsRpw52+thgwRp+JxdkvCQHkinxUPbdyTv5adw22R14ZgcetkT1VFYLHN/4yDYgavvFZDF9F/g2LzPLRCY58bj/9NLtuWA=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CY8PR11MB7948
X-OriginatorOrg: intel.com

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogQmlsbCBXZW5kbGluZyA8
bW9yYm9AZ29vZ2xlLmNvbT4NCj4gU2VudDogVHVlc2RheSwgU2VwdGVtYmVyIDE1LCAyMDI2IDEw
OjE5IEFNDQo+IFRvOiBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnDQo+IENjOiBCaWxsIFdl
bmRsaW5nIDxtb3Jib0Bnb29nbGUuY29tPjsgY29kZW1lbmRlci0NCj4gcGF0Y2hpbmcrbGludXhA
Z29vZ2xlLmNvbTsgUnVzc2VsbCBLaW5nIDxsaW51eEBhcm1saW51eC5vcmcudWs+Ow0KPiBIdWFj
YWkgQ2hlbiA8Y2hlbmh1YWNhaUBrZXJuZWwub3JnPjsgV0FORyBYdWVydWkgPGtlcm5lbEB4ZW4w
bi5uYW1lPjsNCj4gVGhvbWFzIEJvZ2VuZG9lcmZlciA8dHNib2dlbmRAYWxwaGEuZnJhbmtlbi5k
ZT47IEphbWVzIEUuSi4gQm90dG9tbGV5DQo+IDxKYW1lcy5Cb3R0b21sZXlASGFuc2VuUGFydG5l
cnNoaXAuY29tPjsgSGVsZ2UgRGVsbGVyIDxkZWxsZXJAZ214LmRlPjsNCj4gVGhvbWFzIEdsZWl4
bmVyIDx0Z2x4QGtlcm5lbC5vcmc+OyBJbmdvIE1vbG5hciA8bWluZ29AcmVkaGF0LmNvbT47DQo+
IEJvcmlzbGF2IFBldGtvdiA8YnBAYWxpZW44LmRlPjsgRGF2ZSBIYW5zZW4NCj4gPGRhdmUuaGFu
c2VuQGxpbnV4LmludGVsLmNvbT47IHg4NkBrZXJuZWwub3JnOyBILiBQZXRlciBBbnZpbg0KPiA8
aHBhQHp5dG9yLmNvbT47IElhbiBBYmJvdHQgPGFiYm90dGlAbWV2LmNvLnVrPjsgSCBIYXJ0bGV5
IFN3ZWV0ZW4NCj4gPGhzd2VldGVuQHZpc2lvbmVuZ3JhdmVycy5jb20+OyBMdWNrLCBUb255IDx0
b255Lmx1Y2tAaW50ZWwuY29tPjsNCj4gTWFhcnRlbiBMYW5raG9yc3QgPG1hYXJ0ZW4ubGFua2hv
cnN0QGxpbnV4LmludGVsLmNvbT47IE1heGltZSBSaXBhcmQNCj4gPG1yaXBhcmRAa2VybmVsLm9y
Zz47IFRob21hcyBaaW1tZXJtYW5uIDx0emltbWVybWFubkBzdXNlLmRlPjsgRGF2aWQNCj4gQWly
bGllIDxhaXJsaWVkQGdtYWlsLmNvbT47IFNpbW9uYSBWZXR0ZXIgPHNpbW9uYUBmZndsbC5jaD47
IEJyb3N0LA0KPiBNYXR0aGV3IDxtYXR0aGV3LmJyb3N0QGludGVsLmNvbT47IFRob21hcyBIZWxs
c3Ryw7ZtDQo+IDx0aG9tYXMuaGVsbHN0cm9tQGxpbnV4LmludGVsLmNvbT47IFZpdmksIFJvZHJp
Z28NCj4gPHJvZHJpZ28udml2aUBpbnRlbC5jb20+OyBEbWl0cnkgVG9yb2tob3YgPGRtaXRyeS50
b3Jva2hvdkBnbWFpbC5jb20+Ow0KPiBNYXR0aGlhcyBTY2h3YXJ6b3R0IDx6emFtQGdlbnRvby5v
cmc+OyBNYXVybyBDYXJ2YWxobyBDaGVoYWINCj4gPG1jaGVoYWJAa2VybmVsLm9yZz47IE5ndXll
biwgQW50aG9ueSBMIDxhbnRob255Lmwubmd1eWVuQGludGVsLmNvbT47DQo+IEtpdHN6ZWwsIFBy
emVteXNsYXcgPHByemVteXNsYXcua2l0c3plbEBpbnRlbC5jb20+OyBBbmRyZXcgTHVubg0KPiA8
YW5kcmV3K25ldGRldkBsdW5uLmNoPjsgRGF2aWQgUy4gTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQu
bmV0PjsgRXJpYw0KPiBEdW1hemV0IDxlZHVtYXpldEBnb29nbGUuY29tPjsgSmFrdWIgS2ljaW5z
a2kgPGt1YmFAa2VybmVsLm9yZz47IFBhb2xvDQo+IEFiZW5pIDxwYWJlbmlAcmVkaGF0LmNvbT47
IEFyZW5kIHZhbiBTcHJpZWwNCj4gPGFyZW5kLnZhbnNwcmllbEBicm9hZGNvbS5jb20+OyBSb2Ig
SGVycmluZyA8cm9iaEBrZXJuZWwub3JnPjsNCj4gU2FyYXZhbmEgS2FubmFuIDxzYXJhdmFuYWtA
a2VybmVsLm9yZz47IEtyenlzenRvZiBLb3psb3dza2kNCj4gPGtyemtAa2VybmVsLm9yZz47IFN5
bHdlc3RlciBOYXdyb2NraSA8cy5uYXdyb2NraUBzYW1zdW5nLmNvbT47IFBldGVyDQo+IEdyaWZm
aW4gPHBldGVyLmdyaWZmaW5AbGluYXJvLm9yZz47IEFsaW0gQWtodGFyDQo+IDxhbGltLmFraHRh
ckBzYW1zdW5nLmNvbT47IExpbnVzIFdhbGxlaWogPGxpbnVzd0BrZXJuZWwub3JnPjsgQW5pbA0K
PiBHdXJ1bXVydGh5IDxhbmlsLmd1cnVtdXJ0aHlAcWxvZ2ljLmNvbT47IFN1ZGFyc2FuYSBLYWxs
dXJ1DQo+IDxzdWRhcnNhbmEua2FsbHVydUBxbG9naWMuY29tPjsgTWFydGluIEsuIFBldGVyc2Vu
IDxta3BAa2VybmVsLm9yZz47DQo+IFRyb25kIE15a2xlYnVzdCA8dHJvbmRteUBrZXJuZWwub3Jn
PjsgQW5uYSBTY2h1bWFrZXINCj4gPGFubmFAa2VybmVsLm9yZz47IE1pa2UgTWFyc2hhbGwgPGh1
YmNhcEBvbW5pYm9uZC5jb20+OyBNYXJ0aW4NCj4gQnJhbmRlbmJ1cmcgPG1hcnRpbkBvbW5pYm9u
ZC5jb20+OyBLZWVzIENvb2sgPGtlZXNAa2VybmVsLm9yZz47IEppcmkNCj4gUGlya28gPGppcmlA
cmVzbnVsbGkudXM+OyBTaW1vbiBIb3JtYW4gPGhvcm1zQGtlcm5lbC5vcmc+OyBDaHVjayBMZXZl
cg0KPiA8Y2VsQGtlcm5lbC5vcmc+OyBKZWZmIExheXRvbiA8amxheXRvbkBrZXJuZWwub3JnPjsg
TmVpbEJyb3duDQo+IDxuZWlsQGJyb3duLm5hbWU+OyBPbGdhIEtvcm5pZXZza2FpYSA8b2tvcm5p
ZXZAcmVkaGF0LmNvbT47IERhaSBOZ28NCj4gPERhaS5OZ29Ab3JhY2xlLmNvbT47IFRvbSBUYWxw
ZXkgPHRvbUB0YWxwZXkuY29tPjsgSmFyb3NsYXYgS3lzZWxhDQo+IDxwZXJleEBwZXJleC5jej47
IFRha2FzaGkgSXdhaSA8dGl3YWlAc3VzZS5jb20+OyBBbmRyZXcgTW9ydG9uDQo+IDxha3BtQGxp
bnV4LWZvdW5kYXRpb24ub3JnPjsgTWlrZSBSYXBvcG9ydCAoTWljcm9zb2Z0KQ0KPiA8cnBwdEBr
ZXJuZWwub3JnPjsgS2FuZ2xvbmcgV2FuZyA8d2FuZ2thbmdsb25nQGxvb25nc29uLmNuPjsgVGll
emh1DQo+IFlhbmcgPHlhbmd0aWV6aHVAbG9vbmdzb24uY24+OyBRaWFuZyBNYSA8bWFxaWFuZ2FA
dW5pb250ZWNoLmNvbT47DQo+IFJhbmR5IER1bmxhcCA8cmR1bmxhcEBpbmZyYWRlYWQub3JnPjsg
UGVuZ3BlbmcgSG91DQo+IDxwZW5ncGVuZ0Bpc2Nhcy5hYy5jbj47IEFyZCBCaWVzaGV1dmVsIDxh
cmRiQGtlcm5lbC5vcmc+OyBCcmVubyBMZWl0YW8NCj4gPGxlaXRhb0BkZWJpYW4ub3JnPjsgVGhv
cnN0ZW4gQmx1bSA8Ymx1bUBrZXJuZWwub3JnPjsgSGFyc2hpdA0KPiBNb2dhbGFwYWxsaSA8aGFy
c2hpdC5tLm1vZ2FsYXBhbGxpQG9yYWNsZS5jb20+OyBHcmVnIEtyb2FoLUhhcnRtYW4NCj4gPGdy
ZWdraEBsaW51eGZvdW5kYXRpb24ub3JnPjsgTHl1ZGUgUGF1bCA8bHl1ZGVAcmVkaGF0LmNvbT47
IEFzaHV0b3NoDQo+IERlc2FpIDxhc2h1dG9zaGRlc2FpOTkzQGdtYWlsLmNvbT47IERlYWssIElt
cmUgPGltcmUuZGVha0BpbnRlbC5jb20+Ow0KPiBEbWl0cnkgQmFyeXNoa292IDxkbWl0cnkuYmFy
eXNoa292QG9zcy5xdWFsY29tbS5jb20+OyBKb2hhbiBIb3ZvbGQNCj4gPGpvaGFuQGtlcm5lbC5v
cmc+OyBCZXJnLCBKb2hhbm5lcyA8am9oYW5uZXMuYmVyZ0BpbnRlbC5jb20+Ow0KPiBLb3JlbmJs
aXQsIE1pcmlhbSBSYWNoZWwgPG1pcmlhbS5yYWNoZWwua29yZW5ibGl0QGludGVsLmNvbT47DQo+
IEFsZXhhbmRlciBTdGVpbiA8YWxleGFuZGVyLnN0ZWluQGV3LnRxLWdyb3VwLmNvbT47IENyeW9s
aXRpYSBQdWtOZ2FlDQo+IDxjcnlvbGl0aWFAdW5pb250ZWNoLmNvbT47IEppYW1pbmcgWmhhbmcg
PHI3NzI1Nzc5NTJAZ21haWwuY29tPjsgV2lsbA0KPiBQb3J0ZXIgPG1yd2lsbHBvcnRlckBnbWFp
bC5jb20+OyBDZW4gWmhhbmcgPHp6emNjYzQyN0BnbWFpbC5jb20+Ow0KPiBDw6Fzc2lvIEdhYnJp
ZWwgPGNhc3Npb2dhYnJpZWxjb250YXRvQGdtYWlsLmNvbT47IFJvbmcgWmhhbmcNCj4gPGlAcm9u
Zy5tb2U+OyBBcnVuIFJhZ2hhdmFuIDxhcnVuckB2YWx2ZXNvZnR3YXJlLmNvbT47IGxpbnV4LWFy
bS0NCj4ga2VybmVsQGxpc3RzLmluZnJhZGVhZC5vcmc7IGxvb25nYXJjaEBsaXN0cy5saW51eC5k
ZXY7IGxpbnV4LQ0KPiBtaXBzQHZnZXIua2VybmVsLm9yZzsgbGludXgtcGFyaXNjQHZnZXIua2Vy
bmVsLm9yZzsgbGludXgtDQo+IGVkYWNAdmdlci5rZXJuZWwub3JnOyBkcmktZGV2ZWxAbGlzdHMu
ZnJlZWRlc2t0b3Aub3JnOyBpbnRlbC0NCj4geGVAbGlzdHMuZnJlZWRlc2t0b3Aub3JnOyBsaW51
eC1pbnB1dEB2Z2VyLmtlcm5lbC5vcmc7IGxpbnV4LQ0KPiBtZWRpYUB2Z2VyLmtlcm5lbC5vcmc7
IGludGVsLXdpcmVkLWxhbkBsaXN0cy5vc3Vvc2wub3JnOw0KPiBuZXRkZXZAdmdlci5rZXJuZWwu
b3JnOyBsaW51eC13aXJlbGVzc0B2Z2VyLmtlcm5lbC5vcmc7DQo+IGJyY204MDIxMUBsaXN0cy5s
aW51eC5kZXY7IGJyY204MDIxMS1kZXYtbGlzdC5wZGxAYnJvYWRjb20uY29tOw0KPiBkZXZpY2V0
cmVlQHZnZXIua2VybmVsLm9yZzsgbGludXgtc2Ftc3VuZy1zb2NAdmdlci5rZXJuZWwub3JnOyBs
aW51eC0NCj4gZ3Bpb0B2Z2VyLmtlcm5lbC5vcmc7IGxpbnV4LXNjc2lAdmdlci5rZXJuZWwub3Jn
OyBsaW51eC0NCj4gbmZzQHZnZXIua2VybmVsLm9yZzsgZGV2ZWxAbGlzdHMub3JhbmdlZnMub3Jn
OyBsaW51eC0NCj4gaGFyZGVuaW5nQHZnZXIua2VybmVsLm9yZzsgbGludXgtc291bmRAdmdlci5r
ZXJuZWwub3JnDQo+IFN1YmplY3Q6IFtQQVRDSCAyMi8yOF0gbWVkaWE6IHNpMjE2NTogVXNlIHNu
cHJpbnRmKCkgdG8gZm9ybWF0DQo+IGZyb250ZW5kIG5hbWUNCj4gDQo+IHNpMjE2NV9wcm9iZSgp
IGNvbnN0cnVjdHMgdGhlIGZyb250ZW5kIG5hbWUgYnkgYXBwZW5kaW5nIHRoZSBjaGlwIG5hbWUN
Cj4gYW5kIHN1cHBvcnRlZCBkZWxpdmVyeSBzeXN0ZW0gc3VmZml4ZXMgKCIgRFZCLVQiLCAiIERW
Qi1DIikgdG8NCj4gc3RhdGUtPmZlLm9wcy5pbmZvLm5hbWUgdXNpbmcgbXVsdGlwbGUgc3RybGNh
dCgpIGNhbGxzLg0KPiANCj4gSW4gcHJlcGFyYXRpb24gZm9yIHJlbW92aW5nIHRoZSBkZXByZWNh
dGVkIHN0cmxjYXQoKSBBUElbMV0sIGZvcm1hdA0KPiB0aGUgY29tcGxldGUgZnJvbnRlbmQgbmFt
ZSBpbiBhIHNpbmdsZSBzbnByaW50ZigpIGNhbGwuDQo+IA0KPiBMaW5rOiBodHRwczovL2dpdGh1
Yi5jb20vS1NQUC9saW51eC9pc3N1ZXMvMzcwIFsxXQ0KPiBDYzogY29kZW1lbmRlci1wYXRjaGlu
ZytsaW51eEBnb29nbGUuY29tDQo+IEFzc2lzdGVkLWJ5OiBEZXZlbG9wZXI6R2VtaW5pIFtlZGl0
b3JfdXBkYXRlX2ZpbGUsDQo+IG1ha2Vfa2VybmVsX2J1aWxkX3NpbmdsZV9maWxlLCBzaGVsbF9j
b21tYW5kX3J1bl0NCj4gU2lnbmVkLW9mZi1ieTogQmlsbCBXZW5kbGluZyA8bW9yYm9AZ29vZ2xl
LmNvbT4NCj4gLS0tDQo+IENjOiBSdXNzZWxsIEtpbmcgPGxpbnV4QGFybWxpbnV4Lm9yZy51az4N
Cj4gQ2M6IEh1YWNhaSBDaGVuIDxjaGVuaHVhY2FpQGtlcm5lbC5vcmc+DQo+IENjOiBXQU5HIFh1
ZXJ1aSA8a2VybmVsQHhlbjBuLm5hbWU+DQo+IENjOiBUaG9tYXMgQm9nZW5kb2VyZmVyIDx0c2Jv
Z2VuZEBhbHBoYS5mcmFua2VuLmRlPg0KPiBDYzogIkphbWVzIEUuSi4gQm90dG9tbGV5IiA8SmFt
ZXMuQm90dG9tbGV5QEhhbnNlblBhcnRuZXJzaGlwLmNvbT4NCj4gQ2M6IEhlbGdlIERlbGxlciA8
ZGVsbGVyQGdteC5kZT4NCj4gQ2M6IFRob21hcyBHbGVpeG5lciA8dGdseEBrZXJuZWwub3JnPg0K
PiBDYzogSW5nbyBNb2xuYXIgPG1pbmdvQHJlZGhhdC5jb20+DQo+IENjOiBCb3Jpc2xhdiBQZXRr
b3YgPGJwQGFsaWVuOC5kZT4NCj4gQ2M6IERhdmUgSGFuc2VuIDxkYXZlLmhhbnNlbkBsaW51eC5p
bnRlbC5jb20+DQo+IENjOiB4ODZAa2VybmVsLm9yZw0KPiBDYzogIkguIFBldGVyIEFudmluIiA8
aHBhQHp5dG9yLmNvbT4NCj4gQ2M6IElhbiBBYmJvdHQgPGFiYm90dGlAbWV2LmNvLnVrPg0KPiBD
YzogSCBIYXJ0bGV5IFN3ZWV0ZW4gPGhzd2VldGVuQHZpc2lvbmVuZ3JhdmVycy5jb20+DQo+IENj
OiBUb255IEx1Y2sgPHRvbnkubHVja0BpbnRlbC5jb20+DQo+IENjOiBNYWFydGVuIExhbmtob3Jz
dCA8bWFhcnRlbi5sYW5raG9yc3RAbGludXguaW50ZWwuY29tPg0KPiBDYzogTWF4aW1lIFJpcGFy
ZCA8bXJpcGFyZEBrZXJuZWwub3JnPg0KPiBDYzogVGhvbWFzIFppbW1lcm1hbm4gPHR6aW1tZXJt
YW5uQHN1c2UuZGU+DQo+IENjOiBEYXZpZCBBaXJsaWUgPGFpcmxpZWRAZ21haWwuY29tPg0KPiBD
YzogU2ltb25hIFZldHRlciA8c2ltb25hQGZmd2xsLmNoPg0KPiBDYzogTWF0dGhldyBCcm9zdCA8
bWF0dGhldy5icm9zdEBpbnRlbC5jb20+DQo+IENjOiAiVGhvbWFzIEhlbGxzdHLDtm0iIDx0aG9t
YXMuaGVsbHN0cm9tQGxpbnV4LmludGVsLmNvbT4NCj4gQ2M6IFJvZHJpZ28gVml2aSA8cm9kcmln
by52aXZpQGludGVsLmNvbT4NCj4gQ2M6IERtaXRyeSBUb3Jva2hvdiA8ZG1pdHJ5LnRvcm9raG92
QGdtYWlsLmNvbT4NCj4gQ2M6IE1hdHRoaWFzIFNjaHdhcnpvdHQgPHp6YW1AZ2VudG9vLm9yZz4N
Cj4gQ2M6IE1hdXJvIENhcnZhbGhvIENoZWhhYiA8bWNoZWhhYkBrZXJuZWwub3JnPg0KPiBDYzog
VG9ueSBOZ3V5ZW4gPGFudGhvbnkubC5uZ3V5ZW5AaW50ZWwuY29tPg0KPiBDYzogUHJ6ZW1layBL
aXRzemVsIDxwcnplbXlzbGF3LmtpdHN6ZWxAaW50ZWwuY29tPg0KPiBDYzogQW5kcmV3IEx1bm4g
PGFuZHJldytuZXRkZXZAbHVubi5jaD4NCj4gQ2M6ICJEYXZpZCBTLiBNaWxsZXIiIDxkYXZlbUBk
YXZlbWxvZnQubmV0Pg0KPiBDYzogRXJpYyBEdW1hemV0IDxlZHVtYXpldEBnb29nbGUuY29tPg0K
PiBDYzogSmFrdWIgS2ljaW5za2kgPGt1YmFAa2VybmVsLm9yZz4NCj4gQ2M6IFBhb2xvIEFiZW5p
IDxwYWJlbmlAcmVkaGF0LmNvbT4NCj4gQ2M6IEFyZW5kIHZhbiBTcHJpZWwgPGFyZW5kLnZhbnNw
cmllbEBicm9hZGNvbS5jb20+DQo+IENjOiBSb2IgSGVycmluZyA8cm9iaEBrZXJuZWwub3JnPg0K
PiBDYzogU2FyYXZhbmEgS2FubmFuIDxzYXJhdmFuYWtAa2VybmVsLm9yZz4NCj4gQ2M6IEtyenlz
enRvZiBLb3psb3dza2kgPGtyemtAa2VybmVsLm9yZz4NCj4gQ2M6IFN5bHdlc3RlciBOYXdyb2Nr
aSA8cy5uYXdyb2NraUBzYW1zdW5nLmNvbT4NCj4gQ2M6IFBldGVyIEdyaWZmaW4gPHBldGVyLmdy
aWZmaW5AbGluYXJvLm9yZz4NCj4gQ2M6IEFsaW0gQWtodGFyIDxhbGltLmFraHRhckBzYW1zdW5n
LmNvbT4NCj4gQ2M6IExpbnVzIFdhbGxlaWogPGxpbnVzd0BrZXJuZWwub3JnPg0KPiBDYzogQW5p
bCBHdXJ1bXVydGh5IDxhbmlsLmd1cnVtdXJ0aHlAcWxvZ2ljLmNvbT4NCj4gQ2M6IFN1ZGFyc2Fu
YSBLYWxsdXJ1IDxzdWRhcnNhbmEua2FsbHVydUBxbG9naWMuY29tPg0KPiBDYzogIk1hcnRpbiBL
LiBQZXRlcnNlbiIgPG1rcEBrZXJuZWwub3JnPg0KPiBDYzogVHJvbmQgTXlrbGVidXN0IDx0cm9u
ZG15QGtlcm5lbC5vcmc+DQo+IENjOiBBbm5hIFNjaHVtYWtlciA8YW5uYUBrZXJuZWwub3JnPg0K
PiBDYzogTWlrZSBNYXJzaGFsbCA8aHViY2FwQG9tbmlib25kLmNvbT4NCj4gQ2M6IE1hcnRpbiBC
cmFuZGVuYnVyZyA8bWFydGluQG9tbmlib25kLmNvbT4NCj4gQ2M6IEtlZXMgQ29vayA8a2Vlc0Br
ZXJuZWwub3JnPg0KPiBDYzogSmlyaSBQaXJrbyA8amlyaUByZXNudWxsaS51cz4NCj4gQ2M6IFNp
bW9uIEhvcm1hbiA8aG9ybXNAa2VybmVsLm9yZz4NCj4gQ2M6IENodWNrIExldmVyIDxjZWxAa2Vy
bmVsLm9yZz4NCj4gQ2M6IEplZmYgTGF5dG9uIDxqbGF5dG9uQGtlcm5lbC5vcmc+DQo+IENjOiBO
ZWlsQnJvd24gPG5laWxAYnJvd24ubmFtZT4NCj4gQ2M6IE9sZ2EgS29ybmlldnNrYWlhIDxva29y
bmlldkByZWRoYXQuY29tPg0KPiBDYzogRGFpIE5nbyA8RGFpLk5nb0BvcmFjbGUuY29tPg0KPiBD
YzogVG9tIFRhbHBleSA8dG9tQHRhbHBleS5jb20+DQo+IENjOiBKYXJvc2xhdiBLeXNlbGEgPHBl
cmV4QHBlcmV4LmN6Pg0KPiBDYzogVGFrYXNoaSBJd2FpIDx0aXdhaUBzdXNlLmNvbT4NCj4gQ2M6
IEJpbGwgV2VuZGxpbmcgPG1vcmJvQGdvb2dsZS5jb20+DQo+IENjOiBBbmRyZXcgTW9ydG9uIDxh
a3BtQGxpbnV4LWZvdW5kYXRpb24ub3JnPg0KPiBDYzogIk1pa2UgUmFwb3BvcnQgKE1pY3Jvc29m
dCkiIDxycHB0QGtlcm5lbC5vcmc+DQo+IENjOiBLYW5nbG9uZyBXYW5nIDx3YW5na2FuZ2xvbmdA
bG9vbmdzb24uY24+DQo+IENjOiBUaWV6aHUgWWFuZyA8eWFuZ3RpZXpodUBsb29uZ3Nvbi5jbj4N
Cj4gQ2M6IFFpYW5nIE1hIDxtYXFpYW5nYUB1bmlvbnRlY2guY29tPg0KPiBDYzogUmFuZHkgRHVu
bGFwIDxyZHVubGFwQGluZnJhZGVhZC5vcmc+DQo+IENjOiBQZW5ncGVuZyBIb3UgPHBlbmdwZW5n
QGlzY2FzLmFjLmNuPg0KPiBDYzogQXJkIEJpZXNoZXV2ZWwgPGFyZGJAa2VybmVsLm9yZz4NCj4g
Q2M6IEJyZW5vIExlaXRhbyA8bGVpdGFvQGRlYmlhbi5vcmc+DQo+IENjOiBUaG9yc3RlbiBCbHVt
IDxibHVtQGtlcm5lbC5vcmc+DQo+IENjOiBIYXJzaGl0IE1vZ2FsYXBhbGxpIDxoYXJzaGl0Lm0u
bW9nYWxhcGFsbGlAb3JhY2xlLmNvbT4NCj4gQ2M6IEdyZWcgS3JvYWgtSGFydG1hbiA8Z3JlZ2to
QGxpbnV4Zm91bmRhdGlvbi5vcmc+DQo+IENjOiBMeXVkZSBQYXVsIDxseXVkZUByZWRoYXQuY29t
Pg0KPiBDYzogQXNodXRvc2ggRGVzYWkgPGFzaHV0b3NoZGVzYWk5OTNAZ21haWwuY29tPg0KPiBD
YzogSW1yZSBEZWFrIDxpbXJlLmRlYWtAaW50ZWwuY29tPg0KPiBDYzogRG1pdHJ5IEJhcnlzaGtv
diA8ZG1pdHJ5LmJhcnlzaGtvdkBvc3MucXVhbGNvbW0uY29tPg0KPiBDYzogSm9oYW4gSG92b2xk
IDxqb2hhbkBrZXJuZWwub3JnPg0KPiBDYzogSm9oYW5uZXMgQmVyZyA8am9oYW5uZXMuYmVyZ0Bp
bnRlbC5jb20+DQo+IENjOiBNaXJpIEtvcmVuYmxpdCA8bWlyaWFtLnJhY2hlbC5rb3JlbmJsaXRA
aW50ZWwuY29tPg0KPiBDYzogQWxleGFuZGVyIFN0ZWluIDxhbGV4YW5kZXIuc3RlaW5AZXcudHEt
Z3JvdXAuY29tPg0KPiBDYzogQ3J5b2xpdGlhIFB1a05nYWUgPGNyeW9saXRpYUB1bmlvbnRlY2gu
Y29tPg0KPiBDYzogSmlhbWluZyBaaGFuZyA8cjc3MjU3Nzk1MkBnbWFpbC5jb20+DQo+IENjOiBX
aWxsIFBvcnRlciA8bXJ3aWxscG9ydGVyQGdtYWlsLmNvbT4NCj4gQ2M6IENlbiBaaGFuZyA8enp6
Y2NjNDI3QGdtYWlsLmNvbT4NCj4gQ2M6ICJDw6Fzc2lvIEdhYnJpZWwiIDxjYXNzaW9nYWJyaWVs
Y29udGF0b0BnbWFpbC5jb20+DQo+IENjOiBSb25nIFpoYW5nIDxpQHJvbmcubW9lPg0KPiBDYzog
QXJ1biBSYWdoYXZhbiA8YXJ1bnJAdmFsdmVzb2Z0d2FyZS5jb20+DQo+IENjOiBsaW51eC1hcm0t
a2VybmVsQGxpc3RzLmluZnJhZGVhZC5vcmcNCj4gQ2M6IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5l
bC5vcmcNCj4gQ2M6IGxvb25nYXJjaEBsaXN0cy5saW51eC5kZXYNCj4gQ2M6IGxpbnV4LW1pcHNA
dmdlci5rZXJuZWwub3JnDQo+IENjOiBsaW51eC1wYXJpc2NAdmdlci5rZXJuZWwub3JnDQo+IENj
OiBsaW51eC1lZGFjQHZnZXIua2VybmVsLm9yZw0KPiBDYzogZHJpLWRldmVsQGxpc3RzLmZyZWVk
ZXNrdG9wLm9yZw0KPiBDYzogaW50ZWwteGVAbGlzdHMuZnJlZWRlc2t0b3Aub3JnDQo+IENjOiBs
aW51eC1pbnB1dEB2Z2VyLmtlcm5lbC5vcmcNCj4gQ2M6IGxpbnV4LW1lZGlhQHZnZXIua2VybmVs
Lm9yZw0KPiBDYzogaW50ZWwtd2lyZWQtbGFuQGxpc3RzLm9zdW9zbC5vcmcNCj4gQ2M6IG5ldGRl
dkB2Z2VyLmtlcm5lbC5vcmcNCj4gQ2M6IGxpbnV4LXdpcmVsZXNzQHZnZXIua2VybmVsLm9yZw0K
PiBDYzogYnJjbTgwMjExQGxpc3RzLmxpbnV4LmRldg0KPiBDYzogYnJjbTgwMjExLWRldi1saXN0
LnBkbEBicm9hZGNvbS5jb20NCj4gQ2M6IGRldmljZXRyZWVAdmdlci5rZXJuZWwub3JnDQo+IENj
OiBsaW51eC1zYW1zdW5nLXNvY0B2Z2VyLmtlcm5lbC5vcmcNCj4gQ2M6IGxpbnV4LWdwaW9Admdl
ci5rZXJuZWwub3JnDQo+IENjOiBsaW51eC1zY3NpQHZnZXIua2VybmVsLm9yZw0KPiBDYzogbGlu
dXgtbmZzQHZnZXIua2VybmVsLm9yZw0KPiBDYzogZGV2ZWxAbGlzdHMub3JhbmdlZnMub3JnDQo+
IENjOiBsaW51eC1oYXJkZW5pbmdAdmdlci5rZXJuZWwub3JnDQo+IENjOiBsaW51eC1zb3VuZEB2
Z2VyLmtlcm5lbC5vcmcNCj4gLS0tDQo+ICBkcml2ZXJzL21lZGlhL2R2Yi1mcm9udGVuZHMvc2ky
MTY1LmMgfCAxNyArKysrKysrLS0tLS0tLS0tLQ0KPiAgMSBmaWxlIGNoYW5nZWQsIDcgaW5zZXJ0
aW9ucygrKSwgMTAgZGVsZXRpb25zKC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEvZHJpdmVycy9tZWRp
YS9kdmItZnJvbnRlbmRzL3NpMjE2NS5jIGIvZHJpdmVycy9tZWRpYS9kdmItDQo+IGZyb250ZW5k
cy9zaTIxNjUuYw0KPiBpbmRleCBmMTI0MWI2M2FhNWMuLmJkMTVlYjU4ZmM4NCAxMDA2NDQNCj4g
LS0tIGEvZHJpdmVycy9tZWRpYS9kdmItZnJvbnRlbmRzL3NpMjE2NS5jDQo+ICsrKyBiL2RyaXZl
cnMvbWVkaWEvZHZiLWZyb250ZW5kcy9zaTIxNjUuYw0KPiBAQCAtMTI0MywyMCArMTI0MywxNyBA
QCBzdGF0aWMgaW50IHNpMjE2NV9wcm9iZShzdHJ1Y3QgaTJjX2NsaWVudA0KPiAqY2xpZW50KQ0K
PiAgCQljaGlwX25hbWUsIHJldl9jaGFyLCBzdGF0ZS0+Y2hpcF90eXBlLA0KPiAgCQlzdGF0ZS0+
Y2hpcF9yZXZjb2RlKTsNCj4gDQo+IC0Jc3RybGNhdChzdGF0ZS0+ZmUub3BzLmluZm8ubmFtZSwg
Y2hpcF9uYW1lLA0KPiAtCQlzaXplb2Yoc3RhdGUtPmZlLm9wcy5pbmZvLm5hbWUpKTsNCj4gKwlz
bnByaW50ZihzdGF0ZS0+ZmUub3BzLmluZm8ubmFtZSwgc2l6ZW9mKHN0YXRlLQ0KPiA+ZmUub3Bz
LmluZm8ubmFtZSksDQo+ICsJCSAiU2lsaWNvbiBMYWJzICVzJXMlcyIsDQo+ICsJCSBjaGlwX25h
bWUsDQo+ICsJCSBzdGF0ZS0+aGFzX2R2YnQgPyAiIERWQi1UIiA6ICIiLA0KPiArCQkgc3RhdGUt
Pmhhc19kdmJjID8gIiBEVkItQyIgOiAiIik7DQo+IA0KPiAgCW4gPSAwOw0KPiAtCWlmIChzdGF0
ZS0+aGFzX2R2YnQpIHsNCj4gKwlpZiAoc3RhdGUtPmhhc19kdmJ0KQ0KPiAgCQlzdGF0ZS0+ZmUu
b3BzLmRlbHN5c1tuKytdID0gU1lTX0RWQlQ7DQo+IC0JCXN0cmxjYXQoc3RhdGUtPmZlLm9wcy5p
bmZvLm5hbWUsICIgRFZCLVQiLA0KPiAtCQkJc2l6ZW9mKHN0YXRlLT5mZS5vcHMuaW5mby5uYW1l
KSk7DQo+IC0JfQ0KPiAtCWlmIChzdGF0ZS0+aGFzX2R2YmMpIHsNCj4gKwlpZiAoc3RhdGUtPmhh
c19kdmJjKQ0KPiAgCQlzdGF0ZS0+ZmUub3BzLmRlbHN5c1tuKytdID0gU1lTX0RWQkNfQU5ORVhf
QTsNCj4gLQkJc3RybGNhdChzdGF0ZS0+ZmUub3BzLmluZm8ubmFtZSwgIiBEVkItQyIsDQo+IC0J
CQlzaXplb2Yoc3RhdGUtPmZlLm9wcy5pbmZvLm5hbWUpKTsNCj4gLQl9DQo+IA0KPiAgCS8qIHJl
dHVybiBmZSBwb2ludGVyICovDQo+ICAJKnBkYXRhLT5mZSA9ICZzdGF0ZS0+ZmU7DQo+IC0tDQo+
IDIuNTUuMC4xMDMyLmc3M2E0Y2Q3M2RlLWdvb2cNCg0KUmV2aWV3ZWQtYnk6IEFsZWtzYW5kciBM
b2t0aW9ub3YgPGFsZWtzYW5kci5sb2t0aW9ub3ZAaW50ZWwuY29tPg0K
