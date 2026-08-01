Received: from BN8PR05CU002.outbound.protection.outlook.com (mail-eastus2azon11011002.outbound.protection.outlook.com [52.101.57.2])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9F45E3ACF0F;
	Sat,  1 Aug 2026 02:17:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.57.2
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785550626; cv=fail; b=gdk5HtQrKKbcaKM6vNQWUv3D7Kc8yKJX3FoqlzhTHwhuYHc4t8YQaW/KM5/k5rACUepntFUSBZCJ78l3SUWhgDWhJf8vT6zIxc/+RPZH2pOwn7tUIacHgGFyGH6TlmRZmYdqM5NFUAJv4CyntQkap+N3Xnid5lsYd7mlLZgL5X4=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785550626; c=relaxed/simple;
	bh=sC1FvhFhnE95FDcTTbwJDopZgy6VV3OmPtThvPD4g7A=;
	h=From:Subject:Date:Message-Id:Content-Type:To:Cc:MIME-Version; b=L6k5/ki6qY89LCKQ8fsmld4kKvJxj+/U+Hz9pJQtKdpLyYut2OiTtMXgMv3ekO2pZTg1wE+smPu/kwUVdmfafNmwD8ejf5ZL0vu9s1rHx+dLknvWsJsHjm+pBk8c9MD7EbB9nIH9qU3nqkgtrb+1IFv/u707EVi4JPF4TrUzQ+E=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=FB5Uzv+j; arc=fail smtp.client-ip=52.101.57.2
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="FB5Uzv+j"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=juOG2d/steEklncNOvTy2HvMCzBRsBGtDaBigF+Zw99wCtxthKH9xaGYT9qWEVMP8Q76Iov7fdZDUGjwHlvM66fNmEIIPjId1D7gZZLIViWJAtaPlxuhcb7/aCtyiXWtwjSDdkuhSj4uxmaU6voqSMzVv+wLCaZdEpm1UniIM6XXr/y08d3cNmlDzA37/s+JyM+lKktnI+pPDcw4LcroYMhMWSlFXabL9JX7qqq2G9GkbyzxNZZdBfDXhiVcwodCDaUwfV4RLlUop1Vjl3p2ixOvETBfmnPpPYyDCHPwUZ6z8D4R4UBbp3gbajUber9EYwmfNycR/9reTyem8JAXug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=1Dj2NYUyQZvuonVfcvoKoW2H3adtSVWranxYgEi8YQU=;
 b=nS22Y21LUCkU9rE1tarBHVVoAOS6WoqXifPtaQIE8OYP/CiU7e1kuVgaMB8YfpBfwoWAzik518UdioQWoZmjgtRvCkiZoV18o6PNnRTVj6ggOgtj6OEdb9s9LF2yhoqyLMGg1EJ5eSVv4eBT1+JcD+3kJZrBt9FU0cKgRk9BBrqrjgM5c0KkO59dyK/lRP96h2SLx1wu57lFNzyM/iAKasNf3twQFbmJao0qMCbFWmBjeHqehUINFK536hvgVac4mYp2NrOIMZcRh5B4mo81JHleaUmUx1urY27cvvzQgM2iZgZQWkKx38i1rxQ8hux3PaeLK5OtUsv35myLt1YIAw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=1Dj2NYUyQZvuonVfcvoKoW2H3adtSVWranxYgEi8YQU=;
 b=FB5Uzv+jjIOz2Gqd5kNRUmj0oMIAGc13ZaO7PxN87N2Vsm1h2AmI6UBCGxbiU8v7rBmpSk66cpyjk9doS0l2Cwug3L6tWxa7EnpwkUAI8obSHPvyEZtRmsQRP4Ad/qzEarvlDy1s6rnXeWJmaBg7+kXQP80MMmTUTKKx60Kkrzh78dZdHaCQVnN4Ent82GUKgm+hwh7r8TitUV618trGITHpcjPjn9zyBwtkgbG20BWoOZwi5n1SC1ZzVLkEqAMp7SKzKMlAu2o6c8XmMv0HO0zTS1DVdv1s4GB47p2UxxkBgmCmVu6y6Mvahl6HousWTQ32VDFXU9udlm0xGrD9Mg==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from IA0PR12MB8374.namprd12.prod.outlook.com (2603:10b6:208:40e::7)
 by PH8PR12MB7373.namprd12.prod.outlook.com (2603:10b6:510:217::16) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.270.16; Sat, 1 Aug
 2026 02:16:55 +0000
Received: from IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16]) by IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16%5]) with mapi id 15.21.0270.015; Sat, 1 Aug 2026
 02:16:55 +0000
From: Zi Yan <ziy@nvidia.com>
Subject: [PATCH RFC 00/14] Remove PG_private by using page/folio->private
 checks instead
Date: Fri, 31 Jul 2026 22:13:23 -0400
Message-Id: <20260731-remove-pg_private-v1-0-142c97ba3562@nvidia.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-B4-Tracking: v=1; b=H4sIAENWbWoC/6tWKk4tykwtVrJSqFYqSi3LLM7MzwNyDHUUlJIzE
 vPSU3UzU4B8JSMDIzMDcyML3aLU3PyyVN2C9PiCosyyxJJU3eS0VEsjs2TzNAvjZCWgvoKi1LT
 MCrCZ0UpBbs5KsbW1AC4r+oRoAAAA
X-Change-ID: 20260728-remove-pg_private-cfe926c7f83c
To: David Hildenbrand <david@kernel.org>, 
 "Matthew Wilcox (Oracle)" <willy@infradead.org>, 
 Andrew Morton <akpm@linux-foundation.org>, 
 Muchun Song <muchun.song@linux.dev>, Lorenzo Stoakes <ljs@kernel.org>, 
 "Liam R. Howlett" <liam@infradead.org>, Vlastimil Babka <vbabka@kernel.org>, 
 Mike Rapoport <rppt@kernel.org>, Suren Baghdasaryan <surenb@google.com>, 
 Michal Hocko <mhocko@suse.com>, Baolin Wang <baolin.wang@linux.alibaba.com>, 
 Nico Pache <nico.pache@linux.dev>, Ryan Roberts <ryan.roberts@arm.com>, 
 Dev Jain <dev.jain@arm.com>, Barry Song <baohua@kernel.org>, 
 Lance Yang <lance.yang@linux.dev>, Usama Arif <usama.arif@linux.dev>, 
 Gregory Price <gourry@gourry.net>, 
 Ying Huang <ying.huang@linux.alibaba.com>, 
 Alistair Popple <apopple@nvidia.com>, Johannes Weiner <hannes@cmpxchg.org>, 
 Qi Zheng <qi.zheng@linux.dev>, Shakeel Butt <shakeel.butt@linux.dev>, 
 Kairui Song <kasong@tencent.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
 Zi Yan <ziy@nvidia.com>, Minchan Kim <minchan@kernel.org>, 
 Sergey Senozhatsky <senozhatsky@chromium.org>, 
 Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, 
 Arnaldo Carvalho de Melo <acme@kernel.org>, 
 Namhyung Kim <namhyung@kernel.org>, Thomas Gleixner <tglx@kernel.org>, 
 Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, 
 x86@kernel.org, Mark Rutland <mark.rutland@arm.com>, 
 Alexander Shishkin <alexander.shishkin@linux.intel.com>, 
 Jiri Olsa <jolsa@kernel.org>, Ian Rogers <irogers@google.com>, 
 Adrian Hunter <adrian.hunter@intel.com>, 
 James Clark <james.clark@linaro.org>, "H. Peter Anvin" <hpa@zytor.com>, 
 linux-perf-users@vger.kernel.org, Juergen Gross <jgross@suse.com>, 
 Stefano Stabellini <sstabellini@kernel.org>, 
 Oleksandr Tyshchenko <oleksandr_tyshchenko@epam.com>, 
 xen-devel@lists.xenproject.org, Eric Biggers <ebiggers@kernel.org>, 
 "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, 
 linux-fscrypt@vger.kernel.org, Oscar Salvador <osalvador@suse.de>, 
 Chao Yu <chao@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, 
 Gao Xiang <xiang@kernel.org>, Jan Kara <jack@suse.cz>, 
 Yue Hu <zbestahu@gmail.com>, Jeffle Xu <jefflexu@linux.alibaba.com>, 
 Sandeep Dhavale <dhavale@google.com>, Hongbo Li <hongbohbli@tencent.com>, 
 Chunhai Guo <guochunhai@vivo.com>, linux-erofs@lists.ozlabs.org, 
 linux-fsdevel@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>, 
 Masami Hiramatsu <mhiramat@kernel.org>, 
 Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, 
 Matthew Brost <matthew.brost@intel.com>, 
 Joshua Hahn <joshua.hahnjy@gmail.com>, Rakie Kim <rakie.kim@sk.com>, 
 Byungchul Park <byungchul@sk.com>, 
 Axel Rasmussen <axelrasmussen@google.com>, Yuanchu Xie <yuanchu@google.com>, 
 Wei Xu <weixugc@google.com>, linux-trace-kernel@vger.kernel.org, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 linux-nfs@vger.kernel.org, Song Liu <song@kernel.org>, 
 Yu Kuai <yukuai@fygo.io>, Ilya Dryomov <idryomov@gmail.com>, 
 Alex Markuze <amarkuze@redhat.com>, Viacheslav Dubeyko <slava@dubeyko.com>, 
 Li Nan <magiclinan@didiglobal.com>, Xiao Ni <xiao@kernel.org>, 
 linux-raid@vger.kernel.org, ceph-devel@vger.kernel.org, 
 Richard Weinberger <richard@nod.at>, Zhihao Cheng <chengzhihao1@huawei.com>, 
 linux-mtd@lists.infradead.org, Baoquan He <baoquan.he@linux.dev>, 
 Pasha Tatashin <pasha.tatashin@soleen.com>, 
 Pratyush Yadav <pratyush@kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
 Dave Young <ruirui.yang@linux.dev>, Shuah Khan <skhan@linuxfoundation.org>, 
 kexec@lists.infradead.org, linux-doc@vger.kernel.org
X-Mailer: b4 0.14.3
X-ClientProxiedBy: BL1PR13CA0208.namprd13.prod.outlook.com
 (2603:10b6:208:2be::33) To IA0PR12MB8374.namprd12.prod.outlook.com
 (2603:10b6:208:40e::7)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: IA0PR12MB8374:EE_|PH8PR12MB7373:EE_
X-MS-Office365-Filtering-Correlation-Id: 8049e82e-f2ed-4234-27b6-08deef72f511
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|7416014|376014|1800799024|23010399003|366016|5023799004|11063799006|56012099006|10067099003|18002099003|3023799007|6133799003|921020;
X-Microsoft-Antispam-Message-Info:
	pNDbTnWlggYMSHNy6jsULJFDGtRzmhD27769oJzJU2pngka0LaGEKVpniUoUJ3CQmbg9xv959+2z+JRtqFf67HdU+qB4JaCwRrXHvxitHS4+X0w1LJjCqx7wSOTmTpy3XxuOd9+f8rK/oQHRePQKndJw/6mlHZZMRqE9wjM6o1AKyiS+KOoN9AwCyphX8Vge1MTQ4lDkgWBEWecQpXPpnk0UVsgsZQXPhDQPsCCipKZBMP4VxfsQyzGYHKkCHv+pjywEZE4DEG6l+4rl5dqSNtc7Qp/DQhsoH47boah3/NyuS1fH0f4kWHFAY6G6Uc40wwSbnwNwgs+WyRKk+i8gXQhhXxEgFiKIttIR6DzHA+ZDDvqLRYbRPY4/hfrCcr7v8m7gnFeK1A/TZtrfpXTX8OQHDcrLTPwZSWiqO7CgFcVOlcx6g3XcpK6DY058ctzvMykbyqZaT3/MipYsv6FlMBL6ObuDgleNuUqlH1qFmIrE1zerLMArOoouhPo7b0s2r8t/oX7VceX7KaXz8dR06EcgNpjyds4vn+pl4J9+JGfO801D7wUbLE0kNRfs3NfM96JMpb8PT2+Pv0dezg5+fDtkUnY8TRZh/pSBDuNLl0m7gAChrxtLbAkf1kt7TaGiF4i0NjEzc+x2hdxLFU5P8kIq8nFhZ6pjA5bStDcTp7wi6cPDfsKsUTMx1/68zgx1mYhoWmcx/XO8OqmYGdg28g==
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA0PR12MB8374.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(7416014)(376014)(1800799024)(23010399003)(366016)(5023799004)(11063799006)(56012099006)(10067099003)(18002099003)(3023799007)(6133799003)(921020);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?utf-8?B?S0xSZ2tsSUJ1YURzL2lvL2tRdmRuVEFFNFlkQnBtd1dkOG4vbTg2cHFsVnRG?=
 =?utf-8?B?VFNoYzN2cXdwK3picTlObkZKZGdHYTMxUjNlR0xycFB4WXUycHhxeEhYOHd3?=
 =?utf-8?B?K0J2Uk9rVk1WUkZOVEFtd2ZwNWdOZ2QxekZNTEphRWh5L2NxRlFZZFlVUXZB?=
 =?utf-8?B?K3NxZWdPQ0lyVThKaFZBelNPV1EzOVl5VEhQaFZydTRzblRDNDY1U01mQnhD?=
 =?utf-8?B?NDhiU1dKdE5SWXVoSjkvdDc0dnNUSzdoVjdSQnordHV1Tk0zSFZwaS9EUGto?=
 =?utf-8?B?aEtpY2ExQzM3T1VTbWEycmdiT1hzSTVFclVkMXg0eWJhWDI5WmhtL1duV0Z2?=
 =?utf-8?B?SlNBK1lYUCtaVkFtdFdRZ2RuQVZuTGdoVjl4V2xmVTBTRmhZQ2JYUDBORDJH?=
 =?utf-8?B?QnV2b2RvbnVFRUtOcnZHcTlRQlZMaWtzMXFyWnk5OXpvd1Vib0ZkSUdJZWdP?=
 =?utf-8?B?UDJ3Y2xwTmtNRVdYR1JJeTgvMXNOTERXcDFRaDBiQlpHOThGTnFQR1RCNnRr?=
 =?utf-8?B?SHE4M1BFZXBFTW9BbXExQWJYNEZsNTl6WkRtd1NMU08ycU5wRVFnWHlxb05L?=
 =?utf-8?B?a1pFT2h1VW9BdDlrYnBCNExFdWRTYnNmbVk4UEdaYnJyL0pueVZJczJ1MC85?=
 =?utf-8?B?RlJhcnRCbkl2SzZuV3ovN01xcjhkcWVNSVJqZHp1akNhUDA2b2Q1YWY5RkNa?=
 =?utf-8?B?TVpvUG9tSG5mcm0xMG9mTHFwZnVMYjBrdVRleG5UcmlXSVlnWGs5eWQ0Kzll?=
 =?utf-8?B?RDBSMlFuL3JucEFxeHRGYURTOERQdkxmYWMrWEFLak0xZVZ2RGVqUWZieFBu?=
 =?utf-8?B?NmhZMk9yci9URFpuaHUwQVpGa2p3VnJFK2pNRjduanF2Lys0Z0JDMTBkblBp?=
 =?utf-8?B?L3dQd2hhTC9PSkZhY09neFIxWEo1d2Q2UmJQQWdyMkF0aGQwWVprQ1hJTVcv?=
 =?utf-8?B?RTl0Z25ZM2J5SW8rMkMrblhROS9vZFZNTHIzY1BjKzFlTEZOTGd6ckozVmhY?=
 =?utf-8?B?YXBPdHVMRjgzNHgra3VibnRFbkdScXNjVkdFQ2pIdVJBRE81OWlsaS9IL01R?=
 =?utf-8?B?L25MZE92SFBFVFd6TFpEdG4wZ1JlRVdxS2x3WE5JbVViOXFsdU92eVN1TFdE?=
 =?utf-8?B?ak1UUjRUak5tVVh4MzFqdVpUT3BNbFNVRFBPUDc3d1ZXSlV6Nktoa0RhSjlW?=
 =?utf-8?B?UDlpRlViYzJaM09aY1lEYjVOOVNpWExmVFo1cFNSaXB3WGRKWlNaUGt1WkVv?=
 =?utf-8?B?bVp5QTFDM1BHZWZqZGQzbjFRMC8zM1I1Q1VtZWVhZWp5Ull6T2hJMmszTGFl?=
 =?utf-8?B?eXo5V0RMQWFUVHFMMG1ZQThHVW1nMDVIaEVKOEc5djY0TFIvNEpKVnJPM093?=
 =?utf-8?B?MHh4NmdhV0dERDZYTE5RdGF6OURVRThnUko4aDBsTmppSVRyb0pMYkV3b05u?=
 =?utf-8?B?UUVaNkxQNlp0NHRCWkFlVHhiR3hRZDF0RHMvcjFnelhHZU1peEpqYlNyLzlY?=
 =?utf-8?B?c1VsL1lNbHBEYk12cDkxZHJHM3Q2eS82UnZmT00vY0p2eWlwelRpeXc0cWxM?=
 =?utf-8?B?cVRpVExMSXdEQk1LUllBQ3RmOW02S0lOWDRqMFhoL2JTSkh0SnFhcGNzZWpC?=
 =?utf-8?B?eDYwR05Xbmg1WVhybkRrWW1sRTJZM1NENjlUNkM4RzdEWVZBSHN4NlcyRFdP?=
 =?utf-8?B?UUxDOEVZTXFsQVk1dCtmQ2Z0THZHTlRGdzlwV0FkTU5wdVdzZ3VncFNweEVH?=
 =?utf-8?B?WHBvSGUwcG5qVU10ZVBGYitrSkc2aUQvdzZaZXFKdzh5SjFHemVMTkhtSEhi?=
 =?utf-8?B?Slo0ZE9Cdjk4UkdVZ3I5dXhoNzlqdGE3c0xkOFM3clRCSDlnN2puNnFDWlhw?=
 =?utf-8?B?ZDZyTXNEQXBKdGc2LzhUSzNTVmYvOGZ0WEpxQXptbTA0ME5KWTQ5cHVybGov?=
 =?utf-8?B?SWNYYnJ3QVJlaW91d3VvMjFEcGl3R0RWemdqM1hYTHAxak5wL1VQeUo0TFdY?=
 =?utf-8?B?RDdmS3kxSUYwMlBwN01CTmlZMlpvQlg5Mkp0SWxzZTFMY3BrcEpqMHdGZ2Fy?=
 =?utf-8?B?Y0g3eWE3UlRuUmkrTnVnc29adHdwM3J2V3VrS21NUU92T3dBVHkwcThlbWJh?=
 =?utf-8?B?UkRmUDYwdy95cVByVklSRHpXenhpdHNORWJKdTNFaFV6WjNsbmZpaFRvM052?=
 =?utf-8?B?clUzczgvaXVmaWZjamxqNDVqQTRHR2M4MzFUQmN0Z2NkUjVROHJvakFZVlhD?=
 =?utf-8?B?TWRpYnhlNU5ZMjFXZDFzellUTlloTDMwZE1aTkxWYi8rM0xCbmpuM3JabDVp?=
 =?utf-8?Q?rIlyagVXs903sFdXgk?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8049e82e-f2ed-4234-27b6-08deef72f511
X-MS-Exchange-CrossTenant-AuthSource: IA0PR12MB8374.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 01 Aug 2026 02:16:55.1454
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: dHRY+Bi+1YHiBNSqzAr7tvYfQ+7uKeAf5TdP84c5qEpoH6FkhhVKrN9emBFarEQs
X-MS-Exchange-Transport-CrossTenantHeadersStamped: PH8PR12MB7373

Hi all,

This patchset removes PG_private to make space for upcoming PG_folio
(reserved as __PG_folio) for identifying pages from a folio (more details
in Note below). Instead of checking PG_private, all code is changed to
check page/folio->private != NULL instead.

MM people are cc'd on all patches and subsystem people are cc'd on the
cover letter and corresponding patches.

Overview
===
Most code uses folio_attach/detach/change_private() functions, so folio
refcount is increased and decreased when folio->private is set and reset,
respectively. There is no need to change them.

Changes are needed for exceptional users:
1. zsmalloc uses PG_private to indicate first component zpdesc page and
   page->private is used to store zspage in zpdesc. To remove PG_private,
   is_first_zpdesc() is changed to zpdesc->zspage->first_zpdesc == zpdesc
   instead of checking PG_private.

2. kernel/events/ring_buffer.c stores page order in page->private.
   Replacing PG_private with page->private != NULL works.

3. drivers/xen/grant-table.c stores xen_page_foreign in page->private,
   where on 32-bit, a pointer to xen_page_foreign is stored; on 64-bit,
   page->private is used as xen_page_foreign. PG_private check is replaced
   by page->private != NULL on 32-bit for xen_page_foreign deallocation.
   On 64-bit, page->private is cleared unconditionally since {domid=0,
   gref=0} (xen_page_foreign can be 0) is valid.

4. fs/crypto/crypto.c stores a folio pointer in page->private, PG_private
   checks are replaced by page->private != NULL.

5. fs/erofs has two different uses:

    5a. folio->private is used to form a reversed list of
    the outputs of readahead_folio(). readahead_folio_reverse() is added to
    output folios in reversed order, so that ->private is no longer needed.

    5b. folio->private is used as an in-flight I/O counter. Convert the
    code to use folio_attach/detach/get_private().

6. fs/nfs/write.c: folio refcount maintenance is in a bigger scope than
   folio->private. So folio_attach/detach/get_private() is not used.
   Nothing to change.

7. fs/f2fs uses attach_page_private() to first reset folio->private then
   immediately sets PAGE_PRIVATE_NOT_POINTER bit on it. Change it to use
   attach_page_private() to set PAGE_PRIVATE_NOT_POINTER bit directly to
   avoid folio->private == NULL gap inside set_page_private_##name().

8. hugetlb uses folio_change_private(folio, NULL) without folio refcount
   maintenance. Change it to folio->private = NULL.

After the above changes, PG_private ops are converted to
page/folio->private ops.

folio_test_fs_private() is added to check filesystem-only private data by
excluding swapcache and hugetlb folios, because swapcache folios overlap
swp_entry_t swap with ->private and hugetlb sets its own flags in
->private.

Note
===
1. KPF_PRIVATE has a minor semantic change. Since PG_private will be
   removed, KPF_PRIVATE represents pagecache folios whose ->mapping is not
   NULL and with ->private set. Currently KPF_PRIVATE can be set for
   orphaned pagecache folios with ->mapping == NULL.

2. Documentation/mm/hugetlbfs_reserv.rst is outdated, so I did not remove
   PG_private related text. It should be rewritten.

3. PG_folio is planned to be set on every page from a folio in
   page_rmappable_folio(), so folios with any order (currently
   PG_large_rmappable is used to identify >0 order folios) can be
   identified, vm_insert_*() can correctly reject all folios, and rmap code
   can accept only folios. Eventually, page_folio() will return NULL for
   non-folio pages.

Tests
===
1. allmodconfig build passed.

2. zsmalloc is tested using ext4 on a 1GB lz4 zram:
    2a. zram load + zsmalloc compaction;
    2b. concurrent zspage migration via memory compaction;
    2c. confirmed that multi-page zspages actually formed.

    Details: https://github.com/x-y-z/linux-dev/blob/b4/remove-pg_private/test_zsmalloc.md

3. erofs is tested on images created with -C4096 and lz4hc, lzma,
   deflate, and zstd algorithms:
   3a. cold read of all files, verify checksums match source;
   3b. readahead + reclaim/migration race.

   Details: https://github.com/x-y-z/linux-dev/blob/b4/remove-pg_private/test_erofs.md

4. fscrypt is tested on software-encrypted ext4 with writes to exercise
   bounce pages.

   Details: https://github.com/x-y-z/linux-dev/blob/b4/remove-pg_private/test_fscrypt.md

5. f2fs is tested on an image with inline_data,compress_algorithm=lz4:
    5a. INLINE_INODE — lots of tiny files;
    5b. REF_RESOURCE + general writeback — buffered write churn with fsync;
    5c. ONGOING_MIGRATION — force GC / page migration;
    5d. ATOMIC_WRITE — atomic-write ioctl path.

    Details: https://github.com/x-y-z/linux-dev/blob/b4/remove-pg_private/test_f2fs.md
    (I did not run xfstests)

6. MM selftests passed.

LLM use
===
Claude was used to form a concrete plan on what code needs to be changed
and how to change them. The plan was reviewed by Codex until no issue was
spotted.

Plan is at: https://github.com/x-y-z/linux-dev/blob/b4/remove-pg_private/plan.md

I then followed the plan to make code changes. I did bounce ideas with
Claude how to change fs/erofs, since I did not like the original idea.
After each change, I asked Claude to review my code and git commit message.
I also asked Claude to give me test plans (see above).

At last, Codex was used to review all patches.

Comments and suggestions are welcome. Thanks.

Assisted-by: Claude:claude-opus-4-8
Assisted-by: Codex:gpt-5
Signed-off-by: Zi Yan <ziy@nvidia.com>
---
Zi Yan (14):
      mm/zsmalloc: replace PG_private with pointer comparison
      perf/ring_buffer: stop using PG_private as AUX page high-order marker
      xen/grant-table: stop setting PG_private on pages for grant mapping
      fs/crypto: stop setting PG_private on bounce page
      mm/hugetlb: use direct assignment instead of folio_change_private()
      fs/f2fs: stop using PG_private
      fs/erofs: mm/pagemap: add readahead_folio_reverse() to avoid folio->private
      fs/erofs: use folio_attach/detach_private() instead of direct assignment
      mm/page-flags: check page/folio->private instead of PG_private
      mm/page-flags: introduce folio_test_fs_private()
      treewide: remove folio_set/clear_private()
      treewide: replace PagePrivate() with page_private()
      treewide: adjust comments on PagePrivate and PG_private
      mm/page-flags: remove PG_private

 Documentation/admin-guide/kdump/vmcoreinfo.rst |  2 +-
 Documentation/filesystems/vfs.rst              |  6 ++--
 arch/x86/events/intel/bts.c                    |  3 --
 arch/x86/events/intel/pt.c                     |  6 ++--
 drivers/md/md-bitmap.c                         |  6 ++--
 drivers/xen/balloon.c                          |  5 ++++
 drivers/xen/grant-table.c                      |  7 ++---
 fs/ceph/addr.c                                 |  8 ++----
 fs/crypto/crypto.c                             |  2 --
 fs/erofs/data.c                                |  5 ++--
 fs/erofs/zdata.c                               | 11 ++------
 fs/f2fs/f2fs.h                                 |  8 +++---
 fs/nfs/file.c                                  |  4 +--
 fs/nfs/write.c                                 |  2 --
 fs/proc/page.c                                 |  5 +++-
 fs/ubifs/file.c                                |  6 ++--
 include/linux/buffer_head.h                    |  6 ----
 include/linux/mm.h                             | 16 +++++------
 include/linux/mm_types.h                       |  4 +--
 include/linux/page-flags.h                     | 38 ++++++++++++++++++--------
 include/linux/pagemap.h                        | 35 ++++++++++++++++++++++--
 include/trace/events/mmflags.h                 |  2 +-
 include/trace/events/pagemap.h                 |  2 +-
 kernel/events/ring_buffer.c                    |  7 ++---
 kernel/vmcore_info.c                           |  1 -
 mm/huge_memory.c                               |  2 +-
 mm/hugetlb.c                                   |  6 ++--
 mm/migrate.c                                   |  3 +-
 mm/page-writeback.c                            |  5 +++-
 mm/vmscan.c                                    |  3 +-
 mm/zpdesc.h                                    |  2 +-
 mm/zsmalloc.c                                  | 15 ++--------
 32 files changed, 127 insertions(+), 106 deletions(-)
---
base-commit: bcd5eb68a6a189497eb26c1b9f622538aa48895d
change-id: 20260728-remove-pg_private-cfe926c7f83c

Best regards,
-- 
Yan, Zi

