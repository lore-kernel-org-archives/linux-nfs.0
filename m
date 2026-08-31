Received: from BL2PR02CU003.outbound.protection.outlook.com (mail-eastusazon11011032.outbound.protection.outlook.com [52.101.52.32])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0B85E37267C;
	Mon, 31 Aug 2026 19:26:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.52.32
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788204364; cv=fail; b=Rzy64s7zsNVJQ2PFuaNl3v2AoBjXSsy8At2fXnudcPOKVxDnbbDT/4s5sqZ/c1XB6d4zK1A8a0m0MEFlu/dt3LppqU19qrEKjtOtDCsLE5uOJOpPROLa0OYZFTI0KaANvJFgj8ffBAFL4/WGbVdt1ftO+kNS/0qmXGS7dR2ZfCw=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788204364; c=relaxed/simple;
	bh=h0fF5srlZMbkymRg6qp2B5rR1Lvd3Lg4HBLYZ5W6W5U=;
	h=From:Subject:Date:Message-Id:Content-Type:To:Cc:MIME-Version; b=Mou+CNeINcRfUENifrMo6gV8yUC6ETRyDsyztcU+gIHjDl9FC8QCRDxOSHvl5jmVQPVaN8aLY3Weg6ROlvrkJsG/LSdEZO/GDXDUaiHSABHuKT0hNJaVTSvAHnAhC4RMFCeg7tOSxaAxyl1oavuD6XsLvDpKg7WwcNYK20icwPM=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=d+UgtiZG; arc=fail smtp.client-ip=52.101.52.32
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="d+UgtiZG"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=Izag6lOTbk0TC+BKQj5TpYJeX6iV3e5A2yIbAJ+p/egYWEdYGNXsZwZrUvqggEh2hwiX9diiOfbBd884vFz8J5CvP1j4oCa1ae3C5NDjMO0tF/m36mJRIfTOhk2gjkwB9uvEVPFCyMSFCAK7nNA0AyiaulPQoKL1/zgJmjxPrz3dj/wSANoxAIvO9vxRgQGVsywRSH2eVr9aKXS1BNa6vyix0ixu38gweI9ioRfdA5/1H/LmFUTAVwCWW7QAHaf2YsBRvcIgz1Tj/xCniHi3OCjUgLIHcK53JTA3jmRTz5ua3XHTjGNQcsizM65kWx3BLjV3ZhjPpeHX9YL61Nl/dA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=1M7t11bVlX5NiEt6HPea3pXuobyxilLjoOBo2kqy1z0=;
 b=ukjJ2fN7T+DluBFHtGO5rHNfOeojWk/xaeHJTLQxVg6RuVo3Y9ZRDrOTQEwLX7nlCmC7ekRG9fn8MGBinHFPbdVHlKoaBgZ5tPFXal7tC0PDSGvyjfEnDuxP55Pp6Fzh9/3pxC5BiESPjggBE3YKBn4XU9fjLu7153NHT1/zWofcKJYvVSJMgpAG2rvl+nNxCY3KxDjQZwXgHYz9ENO2mwxQAeUU6kDtc3GwX2iCb8PAodBhPoKJNN/I8uclDYkudIPUf1jGsGsMMH0NztbwVjmqW7SOuLfn9xrysIZcynND+y2Ol7mMtpUpuJvpDOk9xs9jMcKzuFyjOp1rlgLWlQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=1M7t11bVlX5NiEt6HPea3pXuobyxilLjoOBo2kqy1z0=;
 b=d+UgtiZGPj2sblyxOpIcXM7SJktNxDWdOozEjOnkAkye8n7UtMZyN/jOyZM/AeG99DHQ4GIRrAOAz+xOclj925+H0fjxv7k+I4CHW+/6RDwp8cc9deRQ9umdQEpBWBAKZRb0qk5XzOOZEnYW+84/lMlvZMlv5dgUq/3NfITDXJ3lOu/FuUYdp8hHEd+Ho9xG3EfRNRS66dum9BPwBejbuzcQ9NntBMBp6rBCIL8QstpH4GgNV0xiFn1+1cQS1PJvy945hxKSRjuO++Gjoq1uxKWk+ukM84JUWEn7AMWAQJKHcpJ1sm+TLDibqURugxJsSBonc5u71dd8jqTi6fGyBw==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from IA0PR12MB8374.namprd12.prod.outlook.com (2603:10b6:208:40e::7)
 by SA1PR12MB8742.namprd12.prod.outlook.com (2603:10b6:806:373::6) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.360.7; Mon, 31 Aug
 2026 19:25:38 +0000
Received: from IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16]) by IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16%5]) with mapi id 15.21.0360.008; Mon, 31 Aug 2026
 19:25:38 +0000
From: Zi Yan <ziy@nvidia.com>
Subject: [PATCH v2 00/14] Remove PG_private by using page/folio->private
 checks instead
Date: Mon, 31 Aug 2026 15:25:23 -0400
Message-Id: <20260831-remove-pg_private-v2-0-3668159cd9e8@nvidia.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/22Nyw6CMBBFf4XM2ho6aHms/A9DTC0DzALatKTRk
 P67lbh0eU5yz90hkGcK0BU7eIoc2K4Z8FSAmfU6keAhM2CJqqyxEZ4WG0m46eE8R72RMCO1qEw
 9NpWBvHOeRn4dzXufeeawWf8+LqL82l+tkn9qUYpSyAuatn7q6qrwtkYeWJ+NXaBPKX0AdZkNU
 bMAAAA=
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
X-Mailer: b4 0.15.2
X-ClientProxiedBy: YQBP288CA0014.CANP288.PROD.OUTLOOK.COM
 (2603:10b6:c01:6a::27) To IA0PR12MB8374.namprd12.prod.outlook.com
 (2603:10b6:208:40e::7)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: IA0PR12MB8374:EE_|SA1PR12MB8742:EE_
X-MS-Office365-Filtering-Correlation-Id: 41106e9b-83b1-4289-148e-08df0795a348
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|7416014|376014|366016|1800799024|23010399003|56012099006|10067099003|5023799004|11063799006|18002099003|3023799007|6133799003|921020;
X-Microsoft-Antispam-Message-Info:
	htBZZ7Vb0eSvRuQ6i6qCoafiHji3CmdV5q+gWWn3j5SvAJqLVVvyzr7grLrG1sgQn/Bm4NsXVwcpqWuNsYuZSEmYz8wBonsejxrvXRxhgaBiU380txw+dm6fJ6scn8Ya5yOfX5tfwcX9KopytlqfBOVOlbskj1efRgAVY9t1aK/8/nw6ga3RzmTgvdBEjdffhLOJvQOGImpxzMeWnrDjOC+WSQuEU6YwXNa9m23T4iaqk18laKGiTbLXNcUTS1jfWtB8bGkVFvyw5VIosMU3c2N4zUw/PwfzO7DMFK7ym/E4g3JG4N8DxBkkW4K0CAHy0LvCrG1RghbJxVDMCa9CLvk9zpCJzIRoiWtOkjt2S3uDAozEea+p7+YXq133RvaHZXq9ZMqk4Q9a/jdEut7x6VZDz9zgTyAyRitZmmtfUj0IPo6RUIiKKlmxY6brx0yRsJ8IMtBqpWK8XvAspquCK2YpzVcpkZIaKEcN+Dj9CtlKJMrDzf77KLesP4zpGJFJduRBQ9FrOcNHvGGTueB8NPWC59MUIDc4uw6mf1Naa35YScoP/TB6m2jf9NWxq3Zda9+uJ5qXI5Zo0LHl2g/bxA0UtkZAukAQyxh45SaiUn5UjQmZNvVfap3X0UiXa1gKZ40QqNL3VyFBltaZFJCSE92FJQpdbh/p/ybZaVlN5lWMdMWl0n+CCs7YuBljKU8TU5Tgt8PFmUsLS1V5HC7m/A==
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA0PR12MB8374.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(7416014)(376014)(366016)(1800799024)(23010399003)(56012099006)(10067099003)(5023799004)(11063799006)(18002099003)(3023799007)(6133799003)(921020);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?utf-8?B?aldNM29LWVhMQWN4WGlpSkJRWkxtZFRZNlFYRFNPMERWbkZyb211NWZRR25K?=
 =?utf-8?B?N2ZrOElmcTcxdXZybjBwLy84WUlRUlh0QjZDdGgzM0JqdEp2YXEyNTJZWUpI?=
 =?utf-8?B?cC80TEo3SzNNcDYwMitaNTdvQUgyck9UUlJkVUhtTVdhRDVjYUNINnRlOWVu?=
 =?utf-8?B?amxwRlN0UC9DTHdaMzlKYWtzVEpucU5zWjgrcUl2VkxjTVZDUUlUUGpub0Jj?=
 =?utf-8?B?RTFDR3VDdXN5T1llNGJMK01xVnNNYTgvTUlBL1VvMklwcFMwVERpTjBhcWll?=
 =?utf-8?B?UENNOUxuYlVIWVhkckhtS3pVQ3dqUnhBVUlIUjc0UmZxZnJkZnJBdWwvWm1E?=
 =?utf-8?B?ZjZrbjIrY21zSTYzYVVlY0d4M3BJb1lxa1ZmWTJBbUZRbUNlNFFuZGdrdDhu?=
 =?utf-8?B?bHlxNG85MnhvZVlVQjM3WlJhMWt1VXprV21jek1sVUdxR3RFTG1iWFNSYkxZ?=
 =?utf-8?B?TjR3eEhqQ3k1bnFubGs1eEZaOHM4WmRKamtPa24xZTFnbFZzQjFiQTBFUmwr?=
 =?utf-8?B?RnRKRkNWT00vRjUvTVBWVVBSRW0xTHQvLzI0T3VLR0VLRGpjR2RCOGYwclUz?=
 =?utf-8?B?dmFNaXlUVElXaWV3QXoxODh1OFFtMmcyM2dHMlU5ZDNCeVZMSFFCaXJzQStm?=
 =?utf-8?B?SFVtZ2c5enlDM3pVMmhEMTBweGFkTDFqZlRQN2tXSWhJZnRpODBzVW5BdW5D?=
 =?utf-8?B?L25CVWdDWG9JaTI0cXR1V2pqSnhRQ09vUTgrakk5OUhpclZra0VSZ2dOTmk2?=
 =?utf-8?B?L25XWEp4b1JPTUxGV0JUQ2ZpM21OOFlJMGZDMmJvQ2FxRUZBRTI5RjBrTGth?=
 =?utf-8?B?VVlOQktYenJ2emJFM2llazU1SUlIRkdEWG9QNldTQW1QWTFpT0tIYkpSdk1a?=
 =?utf-8?B?VzRQb1hYZys3R0lEaHA5Rkp4UEdkbzB3N3JYbElURGpZZWZ3MGttRVFLLzc4?=
 =?utf-8?B?amhBc3gvd21nK0dXb0FUQ2ZENkNKZHh3bFZiR0VBcGdiMTJIcHNkZ21nVHdl?=
 =?utf-8?B?bmZRY3Y1MWhlS2FEUU5UV0JKYmZiT0NWano5dFUyWFJpN0w1aWZENTVvSVNo?=
 =?utf-8?B?dHVHQjIzMmZRN0FDRXJqbGRHTkZEdXRHc3dxNUN0bXpSVVpOeXVJZmNyT3RM?=
 =?utf-8?B?cTA3SGNsdUFoc2QrMWxSNkZJNnFGQjkvQ3pYSDZJQ3NNQnJqRjlBY1pZUFJn?=
 =?utf-8?B?R0VpdndVbFlCa05SNG0rckgyZ0NiZ1dhMlIrSlpmcHBPQXNQMm1USitlaU4y?=
 =?utf-8?B?U0p1WC80UHU4VzJrZDZ5SnhGUm9URUFPajd2MlVWdkRiQTRrN05Jb0xHU1E3?=
 =?utf-8?B?cjBxZTFhWWtVamJHdzBua0Y0Q0JQOTBJYnN5eDJtdnl5YUtEUGc4MUdvWTdu?=
 =?utf-8?B?ZVRtclY2dFZaaFBtSy83aFN5QWdLNXlycUpTNisyNkE1YmZCOFRQQzA1bDdx?=
 =?utf-8?B?SkZDcm5zcEgyWHlYVEQvODliYXN6VTVrcDRTTGJOUVF0VmVRZStDV1dCT2Uw?=
 =?utf-8?B?UVVvYSsxMkpBMkpYeHBJSlM3TWZIeHZqM25LaWJMTG5yaFAxSHFNMlExSlpW?=
 =?utf-8?B?SU01YUk5TlZ6Zm9IZURRelFLNkMxaEZZRGJSa2ZaSTBoNXNRWU52bFd3NzJk?=
 =?utf-8?B?V091Q1RjdWVCMnRmRnh6RGZObmZ1WVhDNWdlUWRzSlBJR3Q2QVo1Szc4L2dB?=
 =?utf-8?B?WFhuN1ZBZjhwOFdFZG85bFNjRDQyYWtsQ1ZsZzZCNXBNU2Y2R21taUZTTlFj?=
 =?utf-8?B?emJPTnBNYUxicGw5cnNwVmlTYzJSMGZIeWh3dG9kcDdYWUJYZFQ4bm5ObG94?=
 =?utf-8?B?VTJCN1cvYy9rZEZDS2xIZjROMnpSMVB1VmVVRDEybEkxU1QveWE5bW5VVnls?=
 =?utf-8?B?RVd0N3VOdmlZb3lTYnpUb3lwckZMbHY1RFJCa05MY05PT090YTErME9BT0Zh?=
 =?utf-8?B?bHpIbTVNb2ZFaU1BQnQyQ1ZtamxuSE1YSFRza2FtaTU4UFN5Q1RDVXY2Y2NS?=
 =?utf-8?B?WmRlQThFNFZ6S043cWpuaWNVQUsyUU5lNGtDYVQzWGhraytqT2ZHakVQc1NE?=
 =?utf-8?B?VU9weW1ONjNrWVVZc2xBSVZKNG85ekg5eE9HQURBaVBxUDNvVUdENDdiR0xI?=
 =?utf-8?B?S1NrcytDZmNEMldBbVRXNnJNMnlEenM4Qml1ZVdJb1k4VXJkMmdHWW9WRFUw?=
 =?utf-8?B?SFNNWXM4UkpXSHl0ZzRXTnRHUThUeHhITmdDTG5la21FVmU1MzhtODAzWkI2?=
 =?utf-8?B?QzZvMkNjNlpVaEp5b0xIaGRuUFl6N3lHYmkxNjBkeUpCNVJoRzRWZUFvcWJI?=
 =?utf-8?Q?QUyE3mqIbnBvqUtxPa?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 41106e9b-83b1-4289-148e-08df0795a348
X-MS-Exchange-CrossTenant-AuthSource: IA0PR12MB8374.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 31 Aug 2026 19:25:38.2564
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: n843s1whvSfgneW2wvMilxUPWuaDS8ZfBLBStLsy0PfIZUOOEULUw1e08PmJRM8m
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SA1PR12MB8742

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
   is_first_zpdesc() is replaced by pointer comparison.

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
    the outputs of readahead_folio(). readahead_folio_last() is added to
    output folios in reversed order, so that ->private is no longer needed.

    5b. folio->private is used as an in-flight I/O counter. Convert the
    code to use folio_attach/detach/get_private() and add bias==1 to the
    counter to avoid folio->private being zero.

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
1. KPF_PRIVATE is removed after PG_private is removed.

2. Documentation/mm/hugetlbfs_reserv.rst is outdated, so I did not remove
   PG_private related text. It should be rewritten.

3. PG_folio is planned to be set on every page from a folio in
   page_rmappable_folio(), so folios with any order (currently
   PG_large_rmappable is used to identify >0 order folios) can be
   identified, vm_insert_*() can correctly reject all folios, and rmap code
   can accept only folios. Eventually, page_folio() will return NULL for
   non-folio pages by checking PG_folio, but before that all existing users
   that treat compound pages as folios will be converted. 

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
Changes in v2:
1. removed is_first_zpdesc() in patch 1 and open coded the checks.
2. fixed wording in patch 2's commit message and clarified page_private()
   also works when ring buffer's AUX page order is 0.
3. removed the empty loop in 64-bit gnttab_pages_set_private().
4. clarified folio->private will be reset to NULL by
   fscrypt_free_bounce_page() in the commit message.
5. clarified why hugetlb needs to restore hugetlb_vmemmap_optimized.
6. renamed readahead_folio_reverse() readahead_folio_last() and
   reimplemented readahead_folio_last() by adding a new readahead_control
   private member, _forward, and a new helper __readahead_advance().
7. added a bias, 1, to erofs I/O counter, so that folio->private stays non
   NULL between folio_attach_private() and folio_detach_private().
8. converted more call sites to use folio_test_fs_private().
- Link to v1: https://lore.kernel.org/r/20260731-remove-pg_private-v1-0-142c97ba3562@nvidia.com

---
Zi Yan (14):
      mm/zsmalloc: replace PG_private with pointer comparison
      perf/ring_buffer: stop using PG_private as AUX page high-order marker
      xen/grant-table: stop setting PG_private on pages for grant mapping
      fscrypt: stop setting PG_private on bounce page
      mm/hugetlb: use direct assignment instead of folio_change_private()
      f2fs: stop using PG_private
      erofs: mm/pagemap: add readahead_folio_last() to avoid folio->private
      erofs: use folio_attach/detach_private() instead of direct assignment
      mm/page-flags: check page/folio->private instead of PG_private
      mm/page-flags: introduce folio_test_fs_private()
      treewide: remove folio_set/clear_private()
      treewide: replace PagePrivate() with page_private()
      treewide: adjust comments on PagePrivate and PG_private
      mm/page-flags: remove PG_private

 Documentation/admin-guide/kdump/vmcoreinfo.rst |  2 +-
 Documentation/filesystems/vfs.rst              |  6 +--
 arch/x86/events/intel/bts.c                    |  3 --
 arch/x86/events/intel/pt.c                     |  6 +--
 drivers/md/md-bitmap.c                         |  6 +--
 drivers/xen/balloon.c                          |  5 +++
 drivers/xen/grant-table.c                      | 11 +++--
 fs/ceph/addr.c                                 |  8 ++--
 fs/crypto/crypto.c                             |  2 -
 fs/erofs/data.c                                | 16 ++++---
 fs/erofs/zdata.c                               | 13 ++----
 fs/f2fs/f2fs.h                                 |  8 ++--
 fs/nfs/file.c                                  |  4 +-
 fs/nfs/write.c                                 |  2 -
 fs/proc/page.c                                 |  1 -
 fs/ubifs/file.c                                |  8 ++--
 include/linux/buffer_head.h                    |  6 ---
 include/linux/kernel-page-flags.h              |  1 -
 include/linux/mm.h                             | 35 +++++++++------
 include/linux/mm_types.h                       |  4 +-
 include/linux/page-flags.h                     | 38 +++++++++++-----
 include/linux/pagemap.h                        | 60 +++++++++++++++++++++-----
 include/trace/events/mmflags.h                 |  2 +-
 include/trace/events/pagemap.h                 |  2 +-
 kernel/events/ring_buffer.c                    |  7 ++-
 kernel/vmcore_info.c                           |  1 -
 mm/huge_memory.c                               |  2 +-
 mm/hugetlb.c                                   |  6 +--
 mm/migrate.c                                   |  3 +-
 mm/page-writeback.c                            |  2 +-
 mm/vmscan.c                                    |  2 +-
 mm/zpdesc.h                                    |  2 +-
 mm/zsmalloc.c                                  | 24 +++--------
 tools/mm/page-types.c                          |  2 -
 34 files changed, 163 insertions(+), 137 deletions(-)
---
base-commit: 443451c85ca8d6389d34b1299decada62128f1fe
change-id: 20260728-remove-pg_private-cfe926c7f83c

Best regards,
--  
Yan, Zi

