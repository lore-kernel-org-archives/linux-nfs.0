Received: from mgamail.intel.com (mgamail.intel.com [198.175.65.11])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9B2983BED32;
	Wed, 16 Sep 2026 06:01:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=198.175.65.11
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789538522; cv=fail; b=LCHyCJgUCB1qw6RzwYNVqKPxtiMoZwk/LERyoX7e/ayrbtxy0EKGLWNqcV+uzAKuY51WNPS83fz7BS315zAgTYP8ZLrmEtUvdrqOqBpfUHuZ9AhA3bMKzq5MwWs21LF5MOJ5xY7fow2Z9Fk38oCFzt1LIdtv93AFtwbc9CfBRD4=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789538522; c=relaxed/simple;
	bh=zfSrx0d3xqkPjk1WnxZvRPKPNFtLFFkz29wuiD4q/QA=;
	h=From:To:CC:Subject:Date:Message-ID:References:In-Reply-To:
	 Content-Type:MIME-Version; b=R5NNjY72rxtQ1L060d9rJl9AedfwVkVpk4EBMPODUz88W/Rzeo8nFdOKdqkGnZMY883ApCwZqrH4MmPI90eJ/1S6cCLIyiXnAL1mUBaBysQrwdv4WDn8mXLdvyuBWGooTkt2L+3JE0yvFQAslwRtaEelktxYxuNC+h2vkBBTlx8=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com; spf=pass smtp.mailfrom=intel.com; dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b=NKj0fskn; arc=fail smtp.client-ip=198.175.65.11
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=intel.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=intel.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=intel.com header.i=@intel.com header.b="NKj0fskn"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1789538520; x=1821074520;
  h=from:to:cc:subject:date:message-id:references:
   in-reply-to:content-transfer-encoding:mime-version;
  bh=zfSrx0d3xqkPjk1WnxZvRPKPNFtLFFkz29wuiD4q/QA=;
  b=NKj0fsknoqCf0xFVTZaQN6IT7YqUQ5i8y79ZA+Tu6LWP95GtNsGmKgCQ
   PWm164MSyOOobxF+DBzTxF722pQihbBdClRLekSoDtU9vCKHD/KWxolL0
   RRvBfIYTyc0gYRZHtR3US5ewxm4h76bJCZSEmcMIwri6UyjtZ+kpVq5A/
   eGjHjjDKgZqbdIXxMdcSUgOmclixVjN1jaklBPL5KDZAc03M3N3nO61FE
   O+5KXp4xcrnKDbhGE4akmQ+e/XFH/4mWP2opTb+wqgtJjDzSy0YjrdDO8
   zkkaGRoEUd0UiNPlX5qmbL/9xPglA5QIZR6CeHgjxcVJV6Iy6dNBI2xcS
   Q==;
X-CSE-ConnectionGUID: 2dDGe5VJTG6KRHwK87VQdw==
X-CSE-MsgGUID: SUNz5P7aSCyi7TP0LOXu6w==
X-IronPort-AV: E=McAfee;i="6800,10657,11905"; a="100233120"
X-IronPort-AV: E=Sophos;i="6.27,103,1787036400"; 
   d="scan'208";a="100233120"
Received: from orviesa007.jf.intel.com ([10.64.159.147])
  by orvoesa103.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 15 Sep 2026 23:01:57 -0700
X-CSE-ConnectionGUID: wYq2vQ/rQlmLp/GL1R9A2w==
X-CSE-MsgGUID: cbh2xi79TLKJ6aHPRlYxXA==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="6.27,103,1787036400"; 
   d="scan'208";a="273203624"
Received: from orsmsx901.amr.corp.intel.com ([10.22.229.23])
  by orviesa007.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 15 Sep 2026 23:01:58 -0700
Received: from ORSMSX901.amr.corp.intel.com (10.22.229.23) by
 ORSMSX901.amr.corp.intel.com (10.22.229.23) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.46; Tue, 15 Sep 2026 23:01:57 -0700
Received: from ORSEDG902.ED.cps.intel.com (10.7.248.12) by
 ORSMSX901.amr.corp.intel.com (10.22.229.23) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.46 via Frontend Transport; Tue, 15 Sep 2026 23:01:56 -0700
Received: from BYAPR05CU005.outbound.protection.outlook.com (52.101.85.24) by
 edgegateway.intel.com (134.134.137.112) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.46; Tue, 15 Sep 2026 23:01:55 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=CoAr12ego/HvFVaGP01TyxADCelMngZetbVgT3mESODFD13+JOtPo6x0Xf68ECqNGQZFFESH4h6O248sP5uilwRPQh5gHas18MuIM6qYNm8pX1tcDOjYFe0uqIKOAQHd4J8qQ7xViIpP6jniAeQvtAR4NTa8vlIsBDbqZ5yN/VWWJktf8JEcwFUKRZhon3rggKlCMJRy7nYtyUAmFWqTGZ0q+phPwSku+9JW88CDT7zMRnFD3aQNe84771HMwA+l2oMde+qm3scT0lJFqKRQyzNoFCe2MYtPof6WJn2A8QeKZVDIF928ti7jcXDHdL1niWIc4vy6voFYzQZ1q3I0Pw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=zfSrx0d3xqkPjk1WnxZvRPKPNFtLFFkz29wuiD4q/QA=;
 b=ruppwDwZfDQIUObhUDtKgR5+SyFm20+G41YcJlDhFiVyqB5I90bJagiFUy/6SIf934KZprCbwFdIk6II1mSK7OSCGWA9+wpoJFVKFFvBTOI/zTuO4+qagzpwf61+AgmPPSsjTm1hT8hNvi8TR6GLpzbVwp9QCQKablF9d4VkVQxiPS4tbqbq6n4PDVjSoXFI2s1hGGUINE5BxIga9kUz5syp7fzUz4LqX2ht5BC5YlmP8gCLApngjs+QW6QuD1tVa4JJ54k2vufFMTeljt+4oMJSB2CYV0ywlxOppcVbf83aF0x3zbSA98hma3H23MlLcimUaTXnX9IvPA8IezBxBA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=intel.com; dmarc=pass action=none header.from=intel.com;
 dkim=pass header.d=intel.com; arc=none
Received: from IA3PR11MB8986.namprd11.prod.outlook.com (2603:10b6:208:577::21)
 by CY8PR11MB7948.namprd11.prod.outlook.com (2603:10b6:930:7f::10) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.406.12; Wed, 16 Sep
 2026 06:01:47 +0000
Received: from IA3PR11MB8986.namprd11.prod.outlook.com
 ([fe80::e6f0:6afb:6ef9:ab5c]) by IA3PR11MB8986.namprd11.prod.outlook.com
 ([fe80::e6f0:6afb:6ef9:ab5c%6]) with mapi id 15.21.0406.007; Wed, 16 Sep 2026
 06:01:47 +0000
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
Subject: RE: [PATCH 16/28] pinctrl: samsung: Use snprintf() to construct pin
 bank names
Thread-Topic: [PATCH 16/28] pinctrl: samsung: Use snprintf() to construct pin
 bank names
Thread-Index: AQHdRTYxW8a1zlgdb0KluhLfctpiybbQty8Q
Date: Wed, 16 Sep 2026 06:01:46 +0000
Message-ID: <IA3PR11MB89864738BB45E249AAF2EF63E5B92@IA3PR11MB8986.namprd11.prod.outlook.com>
References: <20260915081910.4142719-1-morbo@google.com>
 <20260915081910.4142719-17-morbo@google.com>
In-Reply-To: <20260915081910.4142719-17-morbo@google.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=intel.com;
x-ms-publictraffictype: Email
x-ms-traffictypediagnostic: IA3PR11MB8986:EE_|CY8PR11MB7948:EE_
x-ms-office365-filtering-correlation-id: 81e0e115-e6cd-4869-ac2c-08df13b7fdec
x-ms-exchange-senderadcheck: 1
x-ms-exchange-antispam-relay: 0
x-microsoft-antispam: BCL:0;ARA:13230040|376014|7416014|23010399003|366016|1800799024|18002099003|22082099003|38070700021|4143699003|10067099003|56012099006|11063799006;
x-microsoft-antispam-message-info: fq26WHDdGAsSWHKXN2II3JEsxNYnPdQEnse4v9YburU5HqII63n3h57KDxmScEbqX7tK1KNeZqRTkJUGOafyXttbNgD5GI+xvQ9RJqmm1zuZjwvox/0jlWMQdFtL9XrYb6Lacnkeb+NvCNomUSDWKyCo7AEAg7i+tExpXutIvV7fjpyj6hMIH60So+nN4nfaqG23jw5O/niL9yq7EyKdjngbRxmAwr25G7GpEDPHoy7DEHSH2wefuHI3uPnI1GqKBQ+uU5quRxVY89F8HIxYlPO8+SeYKrxZCJfCUItuziU3xVZh90NoBz0uBLB2ZZAWYweI2ceWIKi3a8Apq/G78pKKMU4/3DNdgmAIb8+VmddLSNHtCbYIs14lCl8eB95FAL14N/xFI3Optdi76jie6cHsMFYliv9ujbSxjesOLe2UrHd6foFBGIc7xQ3roio9PKJtQkprRMQk2trfHg6GO3VdrlYSWMh6JfnCPhPc8uIwChs86eJDF0JJv7XWsSuBW/pTivtPAo69sXnpiN4e9CAg8LrjYfb9hRBZH7NEv7VjQ7pMJ9cBxVNUwKzcfpD6iR1l8A8jy1TH2/R9H9PBr6AIq9nLE8W1QwV9/7oLLaag7XKOe/4zFs81iUaSLYUKhid/+/d3bisdVIgLon1QGJf8z0frhsi3d1StdPA/m8AG3RAua9dmDQTS8qQ/FcA0AJx+XnxktKWXArGG+sQkaRgL08XIcStWlOTKwom+tvg=
x-forefront-antispam-report: CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA3PR11MB8986.namprd11.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(376014)(7416014)(23010399003)(366016)(1800799024)(18002099003)(22082099003)(38070700021)(4143699003)(10067099003)(56012099006)(11063799006);DIR:OUT;SFP:1101;
x-ms-exchange-antispam-messagedata-chunkcount: 1
x-ms-exchange-antispam-messagedata-0: =?utf-8?B?bnZFN1dqYTBrc3JTVmkrR0dEUFRlbnZXMGtjNVZKUHM3TS8rZnJJYzhQRlpk?=
 =?utf-8?B?TzljVjgyTjhuRXBWMUpZWWlkeFdvalZTZWdQa1c0ODc1TEVIQk1JSlRyV0hl?=
 =?utf-8?B?Ry9ndWtTRS84ODYvMkVjNW1xb0RWM2poYnVsRXZtNUNoV0tTUk9KY1JwS29p?=
 =?utf-8?B?WXdPb2VpTWJ5VU9NNjB4dTBBNVhYckJLamhPZGcyN1c4MTRBQ3ZXRjZkMVVV?=
 =?utf-8?B?cDhpbHJNQU5GenREdWhudHl0czJuY1p3blV6VllZRlpNdVY1d1NJNUJEbDF1?=
 =?utf-8?B?eS9wZVpyU1NsS0ljLzJUU0NZdDE2UDhLajFYRU1GVTFPYkJYenRHK05XdElM?=
 =?utf-8?B?V3RNOHZVS253VnA4c2NiNVgydmNUTkxxZTdLZXhTQ0JGbzI3RHc2eFFrMDEy?=
 =?utf-8?B?SVpUTUpzaS9zaldKZE9UNEs4dXpybUZtNk5kVWFVN1N4MldkYVczbEp0Umtv?=
 =?utf-8?B?SGVmL3QzK1VPWVl3T1pmSVI0WVRlYjlzWlNMWGVpUFlhM3R4dUNLUXNhaEFS?=
 =?utf-8?B?aGtETm9HQVJvNFhHbjBlSUZVMXFDTmw3MUc2RzV4eEN0aW11MXZRc1RHNEsr?=
 =?utf-8?B?USt1N1Y1am80RTNPTkRYOERmRjhqOFNjUFlPWEFseXZBaWNsaDZmYkJzdk9E?=
 =?utf-8?B?WU93Z0RmTUFsZStwSmtQTnZXUDJoYXBINGliVVFFSEYxV0VVZ3dZSDlNV3c5?=
 =?utf-8?B?OWxYS05KV2U5bDlLQ2hLV3ZEcFA2eDBTSkZjYVdwZDJVaTBwVzZVdDZzQ24r?=
 =?utf-8?B?N0FzRE5UWDJvdWl5RzNNRDVMUmVzN2x6bzlYb2NBbC95V1JURTlFL3BJSXVn?=
 =?utf-8?B?VVloL2NkSnAzclFFU1dYMm5DaTg4TE8xOXl2RUd4NHE1T2xYTEFjMC85RXF6?=
 =?utf-8?B?TVBDVnpQZ0lUNzZZMnlyVTFyVDhneHpBS0Y0SWc1NzVIQTdFTGV5TGdXa3Zv?=
 =?utf-8?B?aks4eFNxeFpWbHdEVUhaRHVKQzZzeTZDUnhVOTBCMURKQnFNc2tiNUpnRzdm?=
 =?utf-8?B?cDdtRk05MnFHRy9JNHl5TFhiOThDK080VlJmVUh0TmE1QkRhdmNRUXVYRmN2?=
 =?utf-8?B?dXRNaFVwOWNmR09oL0tWc0RYWmV3VU15NGFxRjltNmFqQ1dlcWwzYXViQ0E0?=
 =?utf-8?B?TWFrdjR4NytQQldhbXV5ck5lTGFld0pseExieXdIM202elpZODdMMUpEN1VF?=
 =?utf-8?B?V0ZyUFRjamR0NXRhZ1ljN0YycFpNVzZFa29RTElyS0ZlS1J6WkFaZkE2bmFx?=
 =?utf-8?B?UEt2K0RibGJ2dzMxWHRKdHBzNms3OHQrSFRpejNhRWFBUnltK2dJTGFFSVc2?=
 =?utf-8?B?bGd5cnhsNTB5aFcwandLenF2R1lZN0pRZkNBbDB5Yk9DK0tnZkhyRjdyQjdE?=
 =?utf-8?B?bnptdGEvSHVtSEFVK3k4Lzk5QUFYVEloRHUxZlRZRVRNNGZJSXFVUlR3cElH?=
 =?utf-8?B?ZmkzWDdsa2hZNkgyUmNlOGllWnpBaC9iM2ZmN2N5Q0l6aUpTNEIveXlqWWJN?=
 =?utf-8?B?cWkzeCt5QW9jUXNCb3lvS1Fvd0N1dGlFb3BDajBsdDg5WkN2NGpBbklPRFpC?=
 =?utf-8?B?YnA0SStFNGtEdEpNRnlKakpNdUxJaDIvM0VsT2pKbk9RWUM5QVJHVUE5eDdQ?=
 =?utf-8?B?SEE1MXJ3dGRKT3dOOFdTakl2N0pLVDRzeGdTa1hRSVZScEZpZ2xuR1NaT0Rm?=
 =?utf-8?B?SDI0anl3UWNBM09wOGV4OE1LcmNiNzI5OVlqZkVZR2swc0dDMldXVnZ1a3cy?=
 =?utf-8?B?eWhnRWFnK0hXWVdwamVJYklZQTI5L1F1dXphdzJzL0l0eU9ESEp6MmRBM29F?=
 =?utf-8?B?VWtMQVRBRmJFNGR3TnVyMFJrcy9yL0diRjArS29GQXJVa0xCSG5zSXBYRDdH?=
 =?utf-8?B?TzF2MXZuWnRSRmFYY2E5TXY1TVFwd0V1SDdLbjI5ekU3anFIQUZ0cXg3Y1NM?=
 =?utf-8?B?THRzdVY4OVBtbE1EWmVoZURRL2w3ODYvRXRlc0doa2tZNEQwbml5RWRtZ1Bt?=
 =?utf-8?B?QkRtS2k1Y252LzkyVVFSYXRwU1d3bTkvU3QwdXlRNGkvNjRuTHc2OE1rMkht?=
 =?utf-8?B?UEYwSW5LZ2xIS3duVWljcEt4emVDaXZCY1lwY1ZXclBPeEUvdmVGT2xHRjJD?=
 =?utf-8?B?bjBvTkpQVk5LNklEbGdkTlFkZFZOMGVKWitRNUpPOTZBK3E4MHB4ZWNvU21t?=
 =?utf-8?B?UmZaTVRZVGozeUtCWjhLZkVaVk0vRnFneTExckgwaVR4YS9tWVQ5ZzkxS2lO?=
 =?utf-8?B?SHZzMHNQZVZqTUlhdU1LZFlzVUJjdk43dGZUcTYxeDA5ZndzSmkyYXd6ZVV5?=
 =?utf-8?B?Mzl1SG1IL1R6MzJHNUF6dnlTbEt3UXcreXdDR1plRG5oM1EvNUZFQT09?=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Exchange-RoutingPolicyChecked: TmnQ3NiEvRzcpXrygzHLSA3uyzTkmntvTXHQrRL0+XumHB8p5KiMH3eSCELlq07R91fUdpqSBVTDPwO/zu7BrT1p3fZ7ZSOaybN2yPTCrEoTgzAcdMA+u0PpdSQvBqdoiBz+IjTuW2n0vaQhgQeEzytns2E+zskigpmHFPdcyVgYBv4r7udhDQfU7a33jg7Y5Prm+8vHiYr47yo4E9O627c5HW5sFuKQGYWh/zPhzIkFTgZNbwSjOLx/wewjXw8yN34AOOCIWKnPzTcu8l4ewQNmuFMXiJvz2v6abq8P0i+b1VS3oKKvvH11zvwP3guKSBzjSsVis2j4Hfs3aWtPXg==
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-AuthSource: IA3PR11MB8986.namprd11.prod.outlook.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 81e0e115-e6cd-4869-ac2c-08df13b7fdec
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 Sep 2026 06:01:46.9871
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 46c98d88-e344-4ed4-8496-4ed7712e255d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: MQ7LsUNxWNVnCSpdC1WD/OTr3XdVud2vP76J4P3p4nA+RkJWpy2O3ah8sjLwAvfpN7weU1PL/ge0CwC/f5Tuz7L3EqOq5/bleOyw8TPsJNI=
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
ZXJuZWwub3JnDQo+IFN1YmplY3Q6IFtQQVRDSCAxNi8yOF0gcGluY3RybDogc2Ftc3VuZzogVXNl
IHNucHJpbnRmKCkgdG8gY29uc3RydWN0DQo+IHBpbiBiYW5rIG5hbWVzDQo+IA0KPiBzYW1zdW5n
X2JhbmtzX25vZGVfZ2V0KCkgY29uc3RydWN0cyBlYWNoIHBpbiBiYW5rIG5vZGUgbmFtZSBieSBj
b3B5aW5nDQo+IGJhbmstPm5hbWUgd2l0aCBzdHJzY3B5KCkgYW5kIGFwcGVuZGluZyB0aGUgc3Vm
Zml4IHdpdGggc3RybGNhdCgpLg0KPiANCj4gSW4gcHJlcGFyYXRpb24gZm9yIHJlbW92aW5nIHRo
ZSBkZXByZWNhdGVkIHN0cmxjYXQoKSBBUElbMV0sIGZvcm1hdA0KPiB0aGUgbm9kZSBuYW1lIGlu
IGEgc2luZ2xlIHNucHJpbnRmKCkgY2FsbCwgd2hpY2ggcHJlc2VydmVzIHRoZQ0KPiBleGlzdGlu
ZyB0cnVuY2F0aW9uIGNoZWNrIGFnYWluc3Qgc2l6ZW9mKG5vZGVfbmFtZSkuDQo+IA0KPiBMaW5r
OiBodHRwczovL2dpdGh1Yi5jb20vS1NQUC9saW51eC9pc3N1ZXMvMzcwIFsxXQ0KPiBDYzogY29k
ZW1lbmRlci1wYXRjaGluZytsaW51eEBnb29nbGUuY29tDQo+IEFzc2lzdGVkLWJ5OiBHZW1pbmk6
UHJvIFtlZGl0b3JfdXBkYXRlX2ZpbGUsDQo+IG1ha2Vfa2VybmVsX2J1aWxkX3NpbmdsZV9maWxl
LCBjaGVja3BhdGNoX3J1bl0NCj4gU2lnbmVkLW9mZi1ieTogQmlsbCBXZW5kbGluZyA8bW9yYm9A
Z29vZ2xlLmNvbT4NCj4gLS0tDQo+IENjOiBSdXNzZWxsIEtpbmcgPGxpbnV4QGFybWxpbnV4Lm9y
Zy51az4NCj4gQ2M6IEh1YWNhaSBDaGVuIDxjaGVuaHVhY2FpQGtlcm5lbC5vcmc+DQo+IENjOiBX
QU5HIFh1ZXJ1aSA8a2VybmVsQHhlbjBuLm5hbWU+DQo+IENjOiBUaG9tYXMgQm9nZW5kb2VyZmVy
IDx0c2JvZ2VuZEBhbHBoYS5mcmFua2VuLmRlPg0KPiBDYzogIkphbWVzIEUuSi4gQm90dG9tbGV5
IiA8SmFtZXMuQm90dG9tbGV5QEhhbnNlblBhcnRuZXJzaGlwLmNvbT4NCj4gQ2M6IEhlbGdlIERl
bGxlciA8ZGVsbGVyQGdteC5kZT4NCj4gQ2M6IFRob21hcyBHbGVpeG5lciA8dGdseEBrZXJuZWwu
b3JnPg0KPiBDYzogSW5nbyBNb2xuYXIgPG1pbmdvQHJlZGhhdC5jb20+DQo+IENjOiBCb3Jpc2xh
diBQZXRrb3YgPGJwQGFsaWVuOC5kZT4NCj4gQ2M6IERhdmUgSGFuc2VuIDxkYXZlLmhhbnNlbkBs
aW51eC5pbnRlbC5jb20+DQo+IENjOiB4ODZAa2VybmVsLm9yZw0KPiBDYzogIkguIFBldGVyIEFu
dmluIiA8aHBhQHp5dG9yLmNvbT4NCj4gQ2M6IElhbiBBYmJvdHQgPGFiYm90dGlAbWV2LmNvLnVr
Pg0KPiBDYzogSCBIYXJ0bGV5IFN3ZWV0ZW4gPGhzd2VldGVuQHZpc2lvbmVuZ3JhdmVycy5jb20+
DQo+IENjOiBUb255IEx1Y2sgPHRvbnkubHVja0BpbnRlbC5jb20+DQo+IENjOiBNYWFydGVuIExh
bmtob3JzdCA8bWFhcnRlbi5sYW5raG9yc3RAbGludXguaW50ZWwuY29tPg0KPiBDYzogTWF4aW1l
IFJpcGFyZCA8bXJpcGFyZEBrZXJuZWwub3JnPg0KPiBDYzogVGhvbWFzIFppbW1lcm1hbm4gPHR6
aW1tZXJtYW5uQHN1c2UuZGU+DQo+IENjOiBEYXZpZCBBaXJsaWUgPGFpcmxpZWRAZ21haWwuY29t
Pg0KPiBDYzogU2ltb25hIFZldHRlciA8c2ltb25hQGZmd2xsLmNoPg0KPiBDYzogTWF0dGhldyBC
cm9zdCA8bWF0dGhldy5icm9zdEBpbnRlbC5jb20+DQo+IENjOiAiVGhvbWFzIEhlbGxzdHLDtm0i
IDx0aG9tYXMuaGVsbHN0cm9tQGxpbnV4LmludGVsLmNvbT4NCj4gQ2M6IFJvZHJpZ28gVml2aSA8
cm9kcmlnby52aXZpQGludGVsLmNvbT4NCj4gQ2M6IERtaXRyeSBUb3Jva2hvdiA8ZG1pdHJ5LnRv
cm9raG92QGdtYWlsLmNvbT4NCj4gQ2M6IE1hdHRoaWFzIFNjaHdhcnpvdHQgPHp6YW1AZ2VudG9v
Lm9yZz4NCj4gQ2M6IE1hdXJvIENhcnZhbGhvIENoZWhhYiA8bWNoZWhhYkBrZXJuZWwub3JnPg0K
PiBDYzogVG9ueSBOZ3V5ZW4gPGFudGhvbnkubC5uZ3V5ZW5AaW50ZWwuY29tPg0KPiBDYzogUHJ6
ZW1layBLaXRzemVsIDxwcnplbXlzbGF3LmtpdHN6ZWxAaW50ZWwuY29tPg0KPiBDYzogQW5kcmV3
IEx1bm4gPGFuZHJldytuZXRkZXZAbHVubi5jaD4NCj4gQ2M6ICJEYXZpZCBTLiBNaWxsZXIiIDxk
YXZlbUBkYXZlbWxvZnQubmV0Pg0KPiBDYzogRXJpYyBEdW1hemV0IDxlZHVtYXpldEBnb29nbGUu
Y29tPg0KPiBDYzogSmFrdWIgS2ljaW5za2kgPGt1YmFAa2VybmVsLm9yZz4NCj4gQ2M6IFBhb2xv
IEFiZW5pIDxwYWJlbmlAcmVkaGF0LmNvbT4NCj4gQ2M6IEFyZW5kIHZhbiBTcHJpZWwgPGFyZW5k
LnZhbnNwcmllbEBicm9hZGNvbS5jb20+DQo+IENjOiBSb2IgSGVycmluZyA8cm9iaEBrZXJuZWwu
b3JnPg0KPiBDYzogU2FyYXZhbmEgS2FubmFuIDxzYXJhdmFuYWtAa2VybmVsLm9yZz4NCj4gQ2M6
IEtyenlzenRvZiBLb3psb3dza2kgPGtyemtAa2VybmVsLm9yZz4NCj4gQ2M6IFN5bHdlc3RlciBO
YXdyb2NraSA8cy5uYXdyb2NraUBzYW1zdW5nLmNvbT4NCj4gQ2M6IFBldGVyIEdyaWZmaW4gPHBl
dGVyLmdyaWZmaW5AbGluYXJvLm9yZz4NCj4gQ2M6IEFsaW0gQWtodGFyIDxhbGltLmFraHRhckBz
YW1zdW5nLmNvbT4NCj4gQ2M6IExpbnVzIFdhbGxlaWogPGxpbnVzd0BrZXJuZWwub3JnPg0KPiBD
YzogQW5pbCBHdXJ1bXVydGh5IDxhbmlsLmd1cnVtdXJ0aHlAcWxvZ2ljLmNvbT4NCj4gQ2M6IFN1
ZGFyc2FuYSBLYWxsdXJ1IDxzdWRhcnNhbmEua2FsbHVydUBxbG9naWMuY29tPg0KPiBDYzogIk1h
cnRpbiBLLiBQZXRlcnNlbiIgPG1rcEBrZXJuZWwub3JnPg0KPiBDYzogVHJvbmQgTXlrbGVidXN0
IDx0cm9uZG15QGtlcm5lbC5vcmc+DQo+IENjOiBBbm5hIFNjaHVtYWtlciA8YW5uYUBrZXJuZWwu
b3JnPg0KPiBDYzogTWlrZSBNYXJzaGFsbCA8aHViY2FwQG9tbmlib25kLmNvbT4NCj4gQ2M6IE1h
cnRpbiBCcmFuZGVuYnVyZyA8bWFydGluQG9tbmlib25kLmNvbT4NCj4gQ2M6IEtlZXMgQ29vayA8
a2Vlc0BrZXJuZWwub3JnPg0KPiBDYzogSmlyaSBQaXJrbyA8amlyaUByZXNudWxsaS51cz4NCj4g
Q2M6IFNpbW9uIEhvcm1hbiA8aG9ybXNAa2VybmVsLm9yZz4NCj4gQ2M6IENodWNrIExldmVyIDxj
ZWxAa2VybmVsLm9yZz4NCj4gQ2M6IEplZmYgTGF5dG9uIDxqbGF5dG9uQGtlcm5lbC5vcmc+DQo+
IENjOiBOZWlsQnJvd24gPG5laWxAYnJvd24ubmFtZT4NCj4gQ2M6IE9sZ2EgS29ybmlldnNrYWlh
IDxva29ybmlldkByZWRoYXQuY29tPg0KPiBDYzogRGFpIE5nbyA8RGFpLk5nb0BvcmFjbGUuY29t
Pg0KPiBDYzogVG9tIFRhbHBleSA8dG9tQHRhbHBleS5jb20+DQo+IENjOiBKYXJvc2xhdiBLeXNl
bGEgPHBlcmV4QHBlcmV4LmN6Pg0KPiBDYzogVGFrYXNoaSBJd2FpIDx0aXdhaUBzdXNlLmNvbT4N
Cj4gQ2M6IEJpbGwgV2VuZGxpbmcgPG1vcmJvQGdvb2dsZS5jb20+DQo+IENjOiBBbmRyZXcgTW9y
dG9uIDxha3BtQGxpbnV4LWZvdW5kYXRpb24ub3JnPg0KPiBDYzogIk1pa2UgUmFwb3BvcnQgKE1p
Y3Jvc29mdCkiIDxycHB0QGtlcm5lbC5vcmc+DQo+IENjOiBLYW5nbG9uZyBXYW5nIDx3YW5na2Fu
Z2xvbmdAbG9vbmdzb24uY24+DQo+IENjOiBUaWV6aHUgWWFuZyA8eWFuZ3RpZXpodUBsb29uZ3Nv
bi5jbj4NCj4gQ2M6IFFpYW5nIE1hIDxtYXFpYW5nYUB1bmlvbnRlY2guY29tPg0KPiBDYzogUmFu
ZHkgRHVubGFwIDxyZHVubGFwQGluZnJhZGVhZC5vcmc+DQo+IENjOiBQZW5ncGVuZyBIb3UgPHBl
bmdwZW5nQGlzY2FzLmFjLmNuPg0KPiBDYzogQXJkIEJpZXNoZXV2ZWwgPGFyZGJAa2VybmVsLm9y
Zz4NCj4gQ2M6IEJyZW5vIExlaXRhbyA8bGVpdGFvQGRlYmlhbi5vcmc+DQo+IENjOiBUaG9yc3Rl
biBCbHVtIDxibHVtQGtlcm5lbC5vcmc+DQo+IENjOiBIYXJzaGl0IE1vZ2FsYXBhbGxpIDxoYXJz
aGl0Lm0ubW9nYWxhcGFsbGlAb3JhY2xlLmNvbT4NCj4gQ2M6IEdyZWcgS3JvYWgtSGFydG1hbiA8
Z3JlZ2toQGxpbnV4Zm91bmRhdGlvbi5vcmc+DQo+IENjOiBMeXVkZSBQYXVsIDxseXVkZUByZWRo
YXQuY29tPg0KPiBDYzogQXNodXRvc2ggRGVzYWkgPGFzaHV0b3NoZGVzYWk5OTNAZ21haWwuY29t
Pg0KPiBDYzogSW1yZSBEZWFrIDxpbXJlLmRlYWtAaW50ZWwuY29tPg0KPiBDYzogRG1pdHJ5IEJh
cnlzaGtvdiA8ZG1pdHJ5LmJhcnlzaGtvdkBvc3MucXVhbGNvbW0uY29tPg0KPiBDYzogSm9oYW4g
SG92b2xkIDxqb2hhbkBrZXJuZWwub3JnPg0KPiBDYzogSm9oYW5uZXMgQmVyZyA8am9oYW5uZXMu
YmVyZ0BpbnRlbC5jb20+DQo+IENjOiBNaXJpIEtvcmVuYmxpdCA8bWlyaWFtLnJhY2hlbC5rb3Jl
bmJsaXRAaW50ZWwuY29tPg0KPiBDYzogQWxleGFuZGVyIFN0ZWluIDxhbGV4YW5kZXIuc3RlaW5A
ZXcudHEtZ3JvdXAuY29tPg0KPiBDYzogQ3J5b2xpdGlhIFB1a05nYWUgPGNyeW9saXRpYUB1bmlv
bnRlY2guY29tPg0KPiBDYzogSmlhbWluZyBaaGFuZyA8cjc3MjU3Nzk1MkBnbWFpbC5jb20+DQo+
IENjOiBXaWxsIFBvcnRlciA8bXJ3aWxscG9ydGVyQGdtYWlsLmNvbT4NCj4gQ2M6IENlbiBaaGFu
ZyA8enp6Y2NjNDI3QGdtYWlsLmNvbT4NCj4gQ2M6ICJDw6Fzc2lvIEdhYnJpZWwiIDxjYXNzaW9n
YWJyaWVsY29udGF0b0BnbWFpbC5jb20+DQo+IENjOiBSb25nIFpoYW5nIDxpQHJvbmcubW9lPg0K
PiBDYzogQXJ1biBSYWdoYXZhbiA8YXJ1bnJAdmFsdmVzb2Z0d2FyZS5jb20+DQo+IENjOiBsaW51
eC1hcm0ta2VybmVsQGxpc3RzLmluZnJhZGVhZC5vcmcNCj4gQ2M6IGxpbnV4LWtlcm5lbEB2Z2Vy
Lmtlcm5lbC5vcmcNCj4gQ2M6IGxvb25nYXJjaEBsaXN0cy5saW51eC5kZXYNCj4gQ2M6IGxpbnV4
LW1pcHNAdmdlci5rZXJuZWwub3JnDQo+IENjOiBsaW51eC1wYXJpc2NAdmdlci5rZXJuZWwub3Jn
DQo+IENjOiBsaW51eC1lZGFjQHZnZXIua2VybmVsLm9yZw0KPiBDYzogZHJpLWRldmVsQGxpc3Rz
LmZyZWVkZXNrdG9wLm9yZw0KPiBDYzogaW50ZWwteGVAbGlzdHMuZnJlZWRlc2t0b3Aub3JnDQo+
IENjOiBsaW51eC1pbnB1dEB2Z2VyLmtlcm5lbC5vcmcNCj4gQ2M6IGxpbnV4LW1lZGlhQHZnZXIu
a2VybmVsLm9yZw0KPiBDYzogaW50ZWwtd2lyZWQtbGFuQGxpc3RzLm9zdW9zbC5vcmcNCj4gQ2M6
IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmcNCj4gQ2M6IGxpbnV4LXdpcmVsZXNzQHZnZXIua2VybmVs
Lm9yZw0KPiBDYzogYnJjbTgwMjExQGxpc3RzLmxpbnV4LmRldg0KPiBDYzogYnJjbTgwMjExLWRl
di1saXN0LnBkbEBicm9hZGNvbS5jb20NCj4gQ2M6IGRldmljZXRyZWVAdmdlci5rZXJuZWwub3Jn
DQo+IENjOiBsaW51eC1zYW1zdW5nLXNvY0B2Z2VyLmtlcm5lbC5vcmcNCj4gQ2M6IGxpbnV4LWdw
aW9Admdlci5rZXJuZWwub3JnDQo+IENjOiBsaW51eC1zY3NpQHZnZXIua2VybmVsLm9yZw0KPiBD
YzogbGludXgtbmZzQHZnZXIua2VybmVsLm9yZw0KPiBDYzogZGV2ZWxAbGlzdHMub3JhbmdlZnMu
b3JnDQo+IENjOiBsaW51eC1oYXJkZW5pbmdAdmdlci5rZXJuZWwub3JnDQo+IENjOiBsaW51eC1z
b3VuZEB2Z2VyLmtlcm5lbC5vcmcNCj4gLS0tDQo+ICBkcml2ZXJzL3BpbmN0cmwvc2Ftc3VuZy9w
aW5jdHJsLXNhbXN1bmcuYyB8IDMgKy0tDQo+ICAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24o
KyksIDIgZGVsZXRpb25zKC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEvZHJpdmVycy9waW5jdHJsL3Nh
bXN1bmcvcGluY3RybC1zYW1zdW5nLmMNCj4gYi9kcml2ZXJzL3BpbmN0cmwvc2Ftc3VuZy9waW5j
dHJsLXNhbXN1bmcuYw0KPiBpbmRleCA1ZWNjOWVkNGM0NGQuLjBkNjM5ZWVjNjg5YyAxMDA2NDQN
Cj4gLS0tIGEvZHJpdmVycy9waW5jdHJsL3NhbXN1bmcvcGluY3RybC1zYW1zdW5nLmMNCj4gKysr
IGIvZHJpdmVycy9waW5jdHJsL3NhbXN1bmcvcGluY3RybC1zYW1zdW5nLmMNCj4gQEAgLTExNTUs
OCArMTE1NSw3IEBAIHN0YXRpYyB2b2lkIHNhbXN1bmdfYmFua3Nfbm9kZV9nZXQoc3RydWN0IGRl
dmljZQ0KPiAqZGV2LCBzdHJ1Y3Qgc2Ftc3VuZ19waW5jdHJsX2RyDQo+IA0KPiAgCWJhbmsgPSBk
LT5waW5fYmFua3M7DQo+ICAJZm9yIChpID0gMDsgaSA8IGQtPm5yX2JhbmtzOyArK2ksICsrYmFu
aykgew0KPiAtCQlzdHJzY3B5KG5vZGVfbmFtZSwgYmFuay0+bmFtZSwgc2l6ZW9mKG5vZGVfbmFt
ZSkpOw0KPiAtCQlsZW4gPSBzdHJsY2F0KG5vZGVfbmFtZSwgc3VmZml4LCBzaXplb2Yobm9kZV9u
YW1lKSk7DQo+ICsJCWxlbiA9IHNucHJpbnRmKG5vZGVfbmFtZSwgc2l6ZW9mKG5vZGVfbmFtZSks
ICIlcyVzIiwNCj4gYmFuay0+bmFtZSwNCj4gK3N1ZmZpeCk7DQo+ICAJCWlmIChsZW4gPj0gc2l6
ZW9mKG5vZGVfbmFtZSkpIHsNCj4gIAkJCWRldl9lcnIoZGV2LCAiVG9vIGxvbmcgcGluIGJhbmsg
bmFtZSAnJXMnLA0KPiBpZ25vcmluZ1xuIiwNCj4gIAkJCQliYW5rLT5uYW1lKTsNCj4gLS0NCj4g
Mi41NS4wLjEwMzIuZzczYTRjZDczZGUtZ29vZw0KDQpSZXZpZXdlZC1ieTogQWxla3NhbmRyIExv
a3Rpb25vdiA8YWxla3NhbmRyLmxva3Rpb25vdkBpbnRlbC5jb20+DQo=
