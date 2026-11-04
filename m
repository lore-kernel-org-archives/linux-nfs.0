Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=40.107.201.47
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793750990;
	b=l6WiH+Qsd8JVTVgQL1G4ndbbC8Wci2X6fizTRWjxbCEzeQcMLheoW2swPRUp3sjC+sND
	 /4zm1Ei2kVfs2D99hXLeVbwLLecuUlPlIyzJ8m/s+CdnS/rJLyNp5AYDdMcPTluQBDlgk
	 ZrMTECSGspbGB6806NCcki8uB7Ba7mpH5lc7Ch4PNK5RaN1Xcr9Ppkv/Wcg+XD0dQCyNL
	 PvvMFankvyF6frhmdVHMsw2U2sIHmQlc7QCwTetc/wM3NJ+axHWLrjMSjvfY/2rn38eA8
	 NeeoM9ZSHYTVaMrV3UY7GH13YTF5pGgeMLPFt1V0vtSk7nQPf36doz4zDtQ1qEyb05A==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793750990;
	h=DMARC-Filter:DKIM-Signature:Received:Received:From:To:Cc:Subject:
	 Date:X-Mailer:Message-ID:In-Reply-To:References:Content-Type:
	 Content-Transfer-Encoding:X-MS-Reactions:X-ClientProxiedBy:
	 MIME-Version:X-MS-PublicTrafficType:X-MS-TrafficTypeDiagnostic:
	 X-MS-Office365-Filtering-Correlation-Id:X-MS-Exchange-SenderADCheck:
	 X-MS-Exchange-AntiSpam-Relay:X-Microsoft-Antispam:
	 X-Microsoft-Antispam-Message-Info:X-Forefront-Antispam-Report:
	 X-MS-Exchange-AntiSpam-MessageData-ChunkCount:
	 X-MS-Exchange-AntiSpam-MessageData-0:X-OriginatorOrg:
	 X-MS-Exchange-CrossTenant-Network-Message-Id:
	 X-MS-Exchange-CrossTenant-AuthSource:X-MS-Exchange-CrossTenant-AuthAs:
	 X-MS-Exchange-CrossTenant-OriginalArrivalTime:
	 X-MS-Exchange-CrossTenant-FromEntityHeader:
	 X-MS-Exchange-CrossTenant-Id:X-MS-Exchange-CrossTenant-MailboxType:
	 X-MS-Exchange-CrossTenant-UserPrincipalName:
	 X-MS-Exchange-Transport-CrossTenantHeadersStamped;
	bh=YWHd5VmYYrXFvbPCeOrd+Af9IlcoShNzk3LjRBiZmIE=;
	b=3BwWI/2SBO3qOvCqmIxLF0BJnL2hrux6rmk2O+yirH7QwI3Kix5bnuMxfWETueYqG8sY
	 qSRm943ptd/WQuHLhmYUp2UvmEu0ZhfMTFcMZCbDZ/txaWgXAkVio5yb13MX4fTE1S7uM
	 i8xr8miqGisKnIHOfE7uRhqOti8DQt+QsgBRJ6ItoS2WJMHzDzi8Hb/Inn8/y4/2W5Ypu
	 S/QM6IN6QRPAoyc4SZOr6qd5QeIdluHn8VEBVew+LdxG7OaxtcWbqo8YzR+ScSXknXxOR
	 ns333PY0dtkjWSTFaYCTbduixHOBiW78QuJGaUbBeMF85M9UzkvuJeG4t35KL62zCUg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=nvidia.com;
	spf=fail smtp.mailfrom=nvidia.com;
	dkim=pass header.d=Nvidia.com header.i=@Nvidia.com header.a=rsa-sha256 header.s=selector2 header.b=qI3y7PNn;
	arc=pass header.oldest-pass=0 smtp.remote-ip=40.107.201.47
Received: from CH4PR04CU002.outbound.protection.outlook.com (mail-northcentralusazon11013047.outbound.protection.outlook.com [40.107.201.47])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (secp384r1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AC383606A31B;
	Wed,  4 Nov 2026 00:09:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org AC383606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=Nvidia.com header.i=@Nvidia.com header.a=rsa-sha256 header.s=selector2 header.b=qI3y7PNn
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=M4w/IEKfIVMqs6WMZGAMs2HxRy87ZiJVftxauIxQa9MsewjeOlVt/gVuyuoTQGlEMwni8vwQV2CjQaAXR8uQUEMhXAowVKYiUOnHhlCcUX/x8ESsoqpjRt9ZDjprq7XvQ6OF1Z0PLINWvUmeAccYHX08eDDSsdr9COZGbkZ4v2JG1NgTtLkIwKFs9xyKbjR+rgSP361UgDjGLp0VQ2UJof4myG1WS7bk7drndNAi2x1ox5t1rAkq0Jat07efOH7rpOU8xBNtGaqwCvnoPpTAPefX39PUXaD17kcq+eY/tttXgqev9TyythtO+gIauWstIJjI4+TXHWKYfdfa8ubf8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=YWHd5VmYYrXFvbPCeOrd+Af9IlcoShNzk3LjRBiZmIE=;
 b=gFgWoS0G2gpsSrzUylMGjHr681QHdb0W1ZCARYO8E8UcNB4LPiZioKsKMgT4H9qpIEP/Kjg5hNPr7/K8ccVe1YsKqqckKIuctik4ckXu2zfh1LmctF4sD83Lvryi5WOxnSftq3ccOo+w1ffYuvKORDeHLQFwOr1R77pky6eC/YF905uKXPMqXh+o//9AakhhzVyXfcLv1NoRAXpBtq+DzYrrkeZ4bhzYGff/cNUoLrNdkIrqzRd/Q2o8pTBtuOHur8N66tWl1gzoEww+0F4nL6anPLb0kW3zengvvUmrjTEotkqE9Pn3nzQb74lwHmZGULIqc4KCIGbrJq79ghXNeQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=YWHd5VmYYrXFvbPCeOrd+Af9IlcoShNzk3LjRBiZmIE=;
 b=qI3y7PNnHJqG9Ky1P6degguhorJM3LqD4nv4q8Cu9Un+/Y4YOUbVm0rmiQKQMr2dfHoPFkTTLGYybhY+QLI8DoUncgzHuwnSglushGT7js34AyF0s2HQjBpqkfCSJA1Lw9vQ66J3kr/W+e3jw1xpdcP/Th+ECB4JPTIZS0Jtg2kDX1AgSyBloVM7SQo0G8bRDQ88SRDwQAduMvL1ji0ufTy4USVcproxBXOQNISBdutvCyWU4pYgsYjdOct7qda6OOfCEsaS276LuE5Ges7Bq4fId9bI0v908pRzA4DMrrtiSGegMr1g51IxlvITJfX9HZaqYTBwUzBcOOjPU95EIg==
Authentication-Results: mx.microsoft.com 1; dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from IA0PR12MB8374.namprd12.prod.outlook.com (2603:10b6:208:40e::7)
 by SA1PR12MB9470.namprd12.prod.outlook.com (2603:10b6:806:459::19) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.592.8; Wed, 4 Nov 2026
 00:09:45 +0000
Received: from IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16]) by IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16%6]) with mapi id 15.21.0569.011; Wed, 4 Nov 2026
 00:09:45 +0000
From: Zi Yan <ziy@nvidia.com>
To: Huan Nguyen <nhuhuan@google.com>
Cc: tglx@kernel.org, mingo@redhat.com, bp@alien8.de,
 dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com,
 akpm@linux-foundation.org, david@kernel.org, ljs@kernel.org,
 Liam.Howlett@oracle.com, vbabka@kernel.org, rppt@kernel.org,
 surenb@google.com, mhocko@suse.com, trondmy@kernel.org, anna@kernel.org,
 matthew.brost@intel.com, joshua.hahnjy@gmail.com, rakie.kim@sk.com,
 byungchul@sk.com, gourry@gourry.net, ying.huang@linux.alibaba.com,
 apopple@nvidia.com, rostedt@goodmis.org, mhiramat@kernel.org,
 mathieu.desnoyers@efficios.com, jackmanb@google.com, hannes@cmpxchg.org,
 shivankg@amd.com, rientjes@google.com, dave@stgolabs.net,
 nifan.cxl@gmail.com, fvdl@google.com, jic23@kernel.org, rkodsara@amd.com,
 bharata@amd.com, sj@kernel.org, weixugc@google.com, xuezhengchu@huawei.com,
 yiannis@zptcorp.com, yiannis.nikolakop@gmail.com,
 dimitrios.palyvos@zptcorp.com, alirad.malek@zptcorp.com,
 ryan.roberts@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-nfs@vger.kernel.org, linux-trace-kernel@vger.kernel.org
Subject: Re: [RFC PATCH v3 0/3] mm: use non-temporal stores for demotion
Date: Tue, 03 Nov 2026 19:09:43 -0500
X-Mailer: MailMate (3.0r7038)
Message-ID: <7CF5AD15-B833-44E1-A9FE-C8E12F8C9E82@nvidia.com>
In-Reply-To: <20261103223025.2482227-1-nhuhuan@google.com>
References: <20260730-rfc-nt-demote-v2-0-452dbe3b5073@zptcorp.com>
 <20261103223025.2482227-1-nhuhuan@google.com>
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable
X-MS-Reactions: disallow
X-ClientProxiedBy: BLAPR03CA0072.namprd03.prod.outlook.com
 (2603:10b6:208:329::17) To IA0PR12MB8374.namprd12.prod.outlook.com
 (2603:10b6:208:40e::7)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: IA0PR12MB8374:EE_|SA1PR12MB9470:EE_
X-MS-Office365-Filtering-Correlation-Id: 8cfdfe55-c8f5-4924-b714-08df3a07ee9a
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|366016|23010399003|1800799024|7416014|376014|10067099003|22082099003|18002099003|3023799007|56012099006|261009223027099003|4143699003|11063799006|261022105027099003|261021133027099003|261022115727099003|261102123227099003|261028144727099003|261026135527099003|261021130227099003|261026121527099003|261021123027099003|261021121427099003|261026130827099003|261026140227099003|261022113327099003|261022075727099003|261021135927099003;
X-Microsoft-Antispam-Message-Info:
	oA6SJL0MxuGRrG2FSnHPVyjrEZjemRJy2DNZee/xbuHq6vvmhhin1MOdOoz94SmFcWSnwG5vxtPEIAQ2frERW3p+c6yOkB085mzPFhg4/ddT12bNFZPHAaAt14h6MC5yy2rXRbE6+Xd7+502wNLDzBYG2NUx+H4Sd4dDKl4uuEvHBeCcI+otq+3X/5oCMPUkuT/CvrTDyCiA6xufogHIFMuayT/LSniPMIC1K2FmAJ6nHUuCgf8EVxy9BpLTIZY21EarBJrHuX7yytswiqiotYAU3HS0ZFJKCkK16HhdmNBub7lCCLakgeJM1bXhuQwmdenV+pAem2CuyR0HJTKEswI4Zp34T00iBk87Qa4df5RJymMdZG66RYnSqAQvwnoldLzVzr9UCSsO5M9FqJAWBmdRIx2yV30mO3sZD1cl4AryXwzG3rf2kYbls3MeVBTHnEByXPrMj1ttfYb62Ar9tuqtJEI+SBdfWDFknsE3XOOM2cI+EwojVvuGf00YPEK1IxqugJsMJe6DTfxeXAmLN4hDJHY4SUHFwa4dHMqDfNMzdivWa06eb0HmZIpfWflYfmJT3kREWO0KyyFF6elxOjwoLPiD9FzxgAmRnCBclJqNC3xfJBGrL3xMiE31+3g32r+qbwRfSMOIUZoOcplvwmvJY8pcZChgpS7m79Sv7EM=
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA0PR12MB8374.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(366016)(23010399003)(1800799024)(7416014)(376014)(10067099003)(22082099003)(18002099003)(3023799007)(56012099006)(261009223027099003)(4143699003)(11063799006)(261022105027099003)(261021133027099003)(261022115727099003)(261102123227099003)(261028144727099003)(261026135527099003)(261021130227099003)(261026121527099003)(261021123027099003)(261021121427099003)(261026130827099003)(261026140227099003)(261022113327099003)(261022075727099003)(261021135927099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?us-ascii?Q?tz7RGcSbeUftiCeC0eMyxZc4JJfMbG0EbleuxUC2EFAS01ZtQ4DiniHpDoED?=
 =?us-ascii?Q?QKjqm4c9j7YhK/wTz1ST5HJOZ1Zm1UXJa6aoRkdSeZRNRzCxpRqtIWWUft/b?=
 =?us-ascii?Q?tDGsLCnLuVLXjaDsWTzYTDiocfbjmuux6eVBHMrc51LnbtEIA79Xj2fDRSNY?=
 =?us-ascii?Q?S5W0yR9hq94mNLUdmpolBKbU+E1Pe5fp3xbNM309P4RhUrba/FFvExAW/+Nm?=
 =?us-ascii?Q?lEf7yWkuXEg3paDcL6BkMYGS/yxn6cGN2+tAmEqexIF98ifZBW0o1Q9XdEIC?=
 =?us-ascii?Q?P3QIbkwZ/ny9rx5V+CCnvZK9x3r+nATqjWxUYNvvQ328o1jTaD8ioUnbez+r?=
 =?us-ascii?Q?70BoaAqUcb1RWBRfSoaY0ID+nz3OKniqH63IjBqkzYVDh7EZ3kBeVSQKlGIL?=
 =?us-ascii?Q?8hTuMP6Gpx/lq/OW/Cs+JevZfHql1j+105srwuSpzXYbLXhpp5KuMGoud54j?=
 =?us-ascii?Q?a/ion6uL8V9Y3BC+jyzWdCOjsLv93rgkYqzfFzrs0LV2jdj3J9jAUY1ukP0k?=
 =?us-ascii?Q?NEihwuBDK1RlSMfTwqUYZD8uALqZaMl2bRdqDUk6vycv3h8m9g71p3pUw9+1?=
 =?us-ascii?Q?0PEJZ8Uf8JVXzUD2Zz25PNT4B88dPCh0DoeHAdFqVPBYv84/81mJ9gjDX6bs?=
 =?us-ascii?Q?NN5yaug2y2ds1ITOuTukQ0CHTh9FypENw7giKxYxCmq7jSvJ1vfpFJyemgZ1?=
 =?us-ascii?Q?rtiitRaet12g32ijCsAYQuCE/umniBGqa5Yc39fU2oiKplVbY1/fpomdJ2Rn?=
 =?us-ascii?Q?0sZqVTOsVbNJHLEFdu6zWOl+lJCHai8pPl63SMX095XgtUDzM1rlEJqppw+B?=
 =?us-ascii?Q?Drrjtry7yuIAQg47z620v+8tEmgsWAKOuntvzR7ZXFq8PwSQvxUDZNvaqn7J?=
 =?us-ascii?Q?hzCL2gITJgKzd4Rx/fgrCXfRTJ1gStbRKahmDl3yJts2MhEqfYc3GGARsSSK?=
 =?us-ascii?Q?oA1iYBPrPoYdzDzPkHO+zW3o/9sbj8R+W/oJnfI2KNcMEI3cmDG+1Jrjm5pG?=
 =?us-ascii?Q?JGLE9eHhipuQoG7662i/OYPbh8T0c+ULMWV406Ql387JN6DEVqVKnuS03Ktk?=
 =?us-ascii?Q?PsMqGNQ6QHFxQsm1yZ+gnrYsKfNXo0plWwM/QsNmz6hkc+j5uPko7MdgASlw?=
 =?us-ascii?Q?sf3cvFnjl5NVcT06eKgUnXTjE/2bNNy9TEZyClWG7jNv/B8Nn6vFxGXNgnWb?=
 =?us-ascii?Q?fXcIhdrj49v9yRbz6DKa0KapUgzmL8ZX9jVmmFUclt0doc8SFggkpzU5RhXH?=
 =?us-ascii?Q?Wvn0e7hxbfbW7VlJDUAxrVFST0IYk0/jvBhuCJ+hoNE/CsElXcOahcCt32X7?=
 =?us-ascii?Q?lEAokN/UXj0Lfwm2Ju8zw1Kbyt36d5zw0pmVTdF+FxHQu4VApf0kB7If2aOB?=
 =?us-ascii?Q?0Y4yY6xCJmNNbECTApfApFCw44xb+8VycRf/gw4A6aWhc6M5oisRO5tgwhb/?=
 =?us-ascii?Q?Q/TCrlOM66KnAUPTmiqANp2P2P1kIUU6KXGPkac/9CJTWzHWY7XzJ1ALsXGM?=
 =?us-ascii?Q?Wx96uKsOb67QLcga9LbAUZwmSIZkgv9XDu4LbBS2XFVtHKHmPZ70Q6MSgGaU?=
 =?us-ascii?Q?9CKVscW7dfTqKxITRhLRQc+GZI/0FwWU99cK12GupAKc3QrQ/uzVPSTWvDLV?=
 =?us-ascii?Q?cZ4zauhL4sXRHm/crf/0Eg7nKNN4SgLrKW2KJ9a0cfK20SRT1QJq2AWIDnlq?=
 =?us-ascii?Q?2kmVunROxUQGhwp6CGzp819a8ek18wgqaIbV0ELatBX9vM9W?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8cfdfe55-c8f5-4924-b714-08df3a07ee9a
X-MS-Exchange-CrossTenant-AuthSource: IA0PR12MB8374.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 04 Nov 2026 00:09:45.3972
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: 6WF7/ELnDw3eaI0Uwv5JS4FGPILVALdYjs6YnTYR2KRZ1kzhFe4stlLESxJZXHFx
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SA1PR12MB9470

On 3 Nov 2026, at 17:30, Huan Nguyen wrote:

> This series continues the non-temporal demotion work originally posted
> by Yiannis Nikolakopoulos [1].
>
> Motivation
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> Memory tier demotion moves cold folios from local DRAM to slower memory=

> tiers, such as CXL or remote NUMA nodes. Standard store instructions
> force the CPU to allocate cache lines for cold data that is unlikely to=

> be referenced in the near term.
>
> Using non-temporal stores and prefetching on x86 bypasses CPU cache
> allocation, protecting active workload working sets and improving
> demotion throughput.
>
> Changes in v3
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> - Unified MCE-safe NT copy (addressing v2 Open #1):
>   Implement copy_mc_page_nt() in x86 assembly to provide machine-check
>   safe copying using non-temporal stores (movnti) and prefetchnta.
>
> - Architecture abstraction (addressing v2 Open #2):
>   v2 relied on memcpy_flushcache(), which lacks non-temporal stores on
>   architectures like arm64. RFC v3 replaces this with a dedicated
>   __HAVE_ARCH_COPY_PAGE_NT interface and generic fallback, enabling
>   architectures to plug in native non-temporal routines independently.
>
> - Memory ordering:
>   Add a wmb() barrier at the end of folio_mc_copy_nt() to ensure weakly=

>   ordered non-temporal stores are drained before page tables are update=
d.
>
> Discussions
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> 1. Migration mode vs. migration control refactoring:
>    Currently, this series introduces MIGRATE_ASYNC_NONTEMPORAL into
>    enum migrate_mode. In parallel, Shivank Garg's migration refactoring=

>    series [2] consolidates migration arguments into migrate_control.
>    Once that lands, demotion can simply rely on the migration reason
>    instead of adding a dedicated migration mode and helper.

If that is the ultimate goal, why not do it in this series to avoid
code churn? You probably can coordinate with Shivank on how to move
the migration control refactoring code to this series.

>
> 2. Large folio copy optimization:
>    Multi-page folios (such as 2MiB THP) are supported by iterating over=

>    constituent 4KiB pages via copy_mc_page_nt(). Once the batch page
>    copy series [3] lands, copy_mc_page_nt() can be extended to copy an
>    entire multi-page folio in a single invocation, eliminating per-4KiB=

>    loop overhead and keeping the prefetchnta stream uninterrupted.
>
> Thanks to Yiannis Nikolakopoulos, Alirad Malek, and Dimitrios
> Palyvos-Giannas for their original work, feedback, and collaboration.
>
> References
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [1] https://lore.kernel.org/linux-mm/20260730-rfc-nt-demote-v2-0-452dbe=
3b5073@zptcorp.com/
> [2] https://lore.kernel.org/linux-mm/20260902-migrate-refactor-shivank-=
v1-9-9dcca87669c4@amd.com/
> [3] https://lore.kernel.org/linux-mm/20261019-batpagecopy-v2-1-d75e7d0d=
faae@amd.com/
>
> Signed-off-by: Huan Nguyen <nhuhuan@google.com>
>
> Huan Nguyen (3):
>   mm, x86: support copying a folio using non-temporal stores
>   mm/migrate: introduce async non-temporal migration mode
>   mm/vmscan: demote folios using non-temporal stores
>
>  arch/x86/include/asm/page_64.h |  2 ++
>  arch/x86/lib/copy_page_64.S    | 65 ++++++++++++++++++++++++++++++++++=

>  fs/nfs/write.c                 |  2 +-
>  include/linux/highmem.h        | 21 +++++++++++
>  include/linux/migrate.h        |  5 +++
>  include/linux/migrate_mode.h   |  1 +
>  include/linux/mm.h             |  1 +
>  include/trace/events/migrate.h |  1 +
>  mm/compaction.c                | 18 +++++-----
>  mm/migrate.c                   | 29 +++++++++------
>  mm/util.c                      | 29 +++++++++++++++
>  mm/vmscan.c                    |  2 +-
>  12 files changed, 154 insertions(+), 22 deletions(-)
>
> base-commit: 05441d697f7f9a927264f4058cbbc6a03dfcac9d
> -- =

> 2.56.0.398.g882cbad275-goog


Best Regards,
Yan, Zi
