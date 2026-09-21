Received: from SN4PR0501CU005.outbound.protection.outlook.com (mail-southcentralusazon11011015.outbound.protection.outlook.com [40.93.194.15])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2AE83326928;
	Mon, 21 Sep 2026 02:28:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=40.93.194.15
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789957716; cv=fail; b=lLn4eVIS1g5KL9Sr44rfFO+ppS4PNPP29F3kZVb3MgylCuz5x3AVf396gbq8ezX+BDs2ZL+HnbTpKcWDpCJY1r2eQnwDTMC5Ey/1XFb2ZtLCP/Q593J0GUejCkmz9wL0jP9/mLPZzthTTDQPgX/5HbS3KkKsAeSDh5lQHiD9jXM=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789957716; c=relaxed/simple;
	bh=93iVqjiy+qQANVz1klztr09MAx6AWZ8Qp8/8VTvVLc8=;
	h=From:Subject:Date:Message-Id:Content-Type:To:Cc:MIME-Version; b=oLuFlmKcl5jenJshez+lySaFi3eCobmPqrN/tmbMGmn0TTQUtzeEYuCDYTWq+YXSYYKAz1552WBOqGxlXcLRhh9OA1RRPWgRmTEDKLc2u9zSU8AX/Hx/vVA5mm5cUGErkmHvudfhczKKjpHi5T3UGpjkCMMGYGI9Fk0JDYn5THU=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=fEXTqQxI; arc=fail smtp.client-ip=40.93.194.15
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="fEXTqQxI"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=RRFY7uye0kx9GQjjkISBpRHpDPL29B8yQ8lXNXezss2d2gGhkyEutGGa453W1maOcE5lOC0c87pJYQSpAovCTeVp79gCbcGzIb1UsGjMcEkg6D7MwCpdDlVlVV64xw/2hfSWrKZ+SSEKkb92rUy2RuT1uPDh0D26tF1YqL0Ii6SAoNeZbcf6UGGOB8Cjxc7LkJ46mn16Qo2DbtAaHvqdi200cHvnlPNSPKi1AQ9JNz/U9PCYDi6j9gB2V2wfxR78nSAq7MrEsu7e20E+bbhKT0llTFJRt22gtee/mIbq4YYaUQwPmTQjBgkQQZBvXGPy8J/wMOTso6+IukkamcdsZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=CTl7/MYdyvkpIqnqDSwOLFKKPNvDoeCHW7e7oy+63k0=;
 b=C4tE/dxsYHZQAyzC2DHfdVYqYy6Byc+yhITkYPh+yeVAmZJldjQuSs1hcIMiS9tHypL7L7UsSL5kASM8SXhAAa6ZXtRXCRE6wssr8zCstro7lTgF+RYkma/KGDucTovMozlA1dD3O/L7ZTqandjqyjNP/AWQbqxiEDj6Havc3M7kDYSNdgLyW0Bp7UA+UbK7zLx7xNqT+CNh4IgyQx4jUCdUTRp/MneciXqrB7gt9ucSbri5bbULTtdf2w1tV9i2dHX5+zqsasXbq9olvlUVQBDSogo4z+v2r8TR8Zmk024RYV0RjwxIotJoU1ipBUV4/1wPuYECVSZkDv4hmEIfBQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=CTl7/MYdyvkpIqnqDSwOLFKKPNvDoeCHW7e7oy+63k0=;
 b=fEXTqQxIw31L8b/z2am/tbWCoSGLWor9huaABv/x7xO/ux5Vo7KYzrKY0kLSbPSsVlIWvou7Cidj/Ich23k2IsLy0eViq/qPUwVYgWStZgMSFCf5K2OeSVfKb/zUn1YeuUql3/xMHIwHA+2U4sUTKe43+NwjTxEfNPKqY1TxKW4++6qxXGCXv2ORuACN4FESbTm7chTOCAB1KQTHvtIyYdapyNsELsFXg3k6KBHYTJ6misbEwJSVUf0IfSbN1YgJAIXjww+rlfKmtfdqE7nqZHyBhhEua/pP4J85O6YSeSRsIRKSXo+2XC0Hg7/qsOXLAtaDI/t4eXjNVE9C0LJoCA==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from IA0PR12MB8374.namprd12.prod.outlook.com (2603:10b6:208:40e::7)
 by DM4PR12MB7719.namprd12.prod.outlook.com (2603:10b6:8:101::13) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.428.16; Mon, 21 Sep
 2026 02:28:20 +0000
Received: from IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16]) by IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16%6]) with mapi id 15.21.0428.014; Mon, 21 Sep 2026
 02:28:20 +0000
From: Zi Yan <ziy@nvidia.com>
Subject: [PATCH v5 00/17] Remove PG_private by using page/folio->private
 checks instead
Date: Sun, 20 Sep 2026 22:27:56 -0400
Message-Id: <20260920-remove-pg_private-v5-0-bb68b6a21869@nvidia.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/23OzWrDMAzA8VcpPs/Dlr932nuUUjxHbnVoEpxiW
 krevU4YdKM5/gX6SQ82YSGc2NfuwQpWmmjoW5iPHUvn2J+QU9eagQArHHhe8DJU5OPpOBaq8Yo
 8ZQxgk8teJdb2xoKZbqu5P7Q+03Qdyn09UeUy/dWU3NCq5IJLDSm4n6iMhe++UkfxMw0XtnAVX
 oTfJqARylovTUhdQP9GqBcRhNsiVCNsRIAcugDu/Qv9h5Bqi9CN8NobI7IzTuM/Yp7nJ2Wbryl
 8AQAA
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
 Tal Zussman <tz2294@columbia.edu>, Gao Xiang <xiang@kernel.org>, 
 Jan Kara <jack@suse.cz>, Yue Hu <zbestahu@gmail.com>, 
 Jeffle Xu <jefflexu@linux.alibaba.com>, 
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
 linux-nfs@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, 
 Alex Markuze <amarkuze@redhat.com>, Viacheslav Dubeyko <slava@dubeyko.com>, 
 ceph-devel@vger.kernel.org, Richard Weinberger <richard@nod.at>, 
 Zhihao Cheng <chengzhihao1@huawei.com>, linux-mtd@lists.infradead.org, 
 Baoquan He <baoquan.he@linux.dev>, 
 Pasha Tatashin <pasha.tatashin@soleen.com>, 
 Pratyush Yadav <pratyush@kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
 Dave Young <ruirui.yang@linux.dev>, Shuah Khan <skhan@linuxfoundation.org>, 
 kexec@lists.infradead.org, linux-doc@vger.kernel.org
X-Mailer: b4 0.16.0
X-ClientProxiedBy: YQZPR01CA0096.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c01:84::29) To IA0PR12MB8374.namprd12.prod.outlook.com
 (2603:10b6:208:40e::7)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: IA0PR12MB8374:EE_|DM4PR12MB7719:EE_
X-MS-Office365-Filtering-Correlation-Id: cd7bc866-ada1-4775-a366-08df1788007e
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|1800799024|376014|7416014|23010399003|366016|921020|3023799007|6133799003|10067099003|56012099006|5023799004|11063799006|18002099003;
X-Microsoft-Antispam-Message-Info:
	jVeqbV/tHFeiMu+SHY69AVMUwlHgvJsFntwh78c0mOcyBYkE8gAjYMbep7rFh8vHMGgr8l7yUZE0wDAJUPHvuknsIrb4O+8a8CBU5khXkWuMT+npJhPIuSRVZKqAXkS6AUfSBuwwxl7f3QNiNU+g4Qk/Qz5PmSRNx55YKYEiDYSb55PzugiK3ZDls1OYDO3v7MpXnErGtt8oYnSGtUru5y3fimvQH+lf0rZLZm2+oXMLQNsu83LlHdG99VtP6Njhe6MJbXuqX8q5F1rD/jCXNX2wYn8PLKDDdgZykqjyL1BvD6H14oNNo+G/QudzvRY77JbHnOJfhGWnIp1dSLfxa+OjBX1b80BYxzKQd0bAchUIwnQFMIHAezbWzJ08R1jRMcq/11N0FReMEhWF1GPfKuMEh04duME2n6TloQln/Qc99yjLw0DDTr0X5vL3NJ+tlN/aSUtrzclqW5fsIDUHFOW6X4ryYk8GRDzm3ohrdzu2gWRCEg90EEJqKp6rzqFAuUndZvP/69JkVVw0lhJSQaPElhG/kpxVTut8iWtLi3QBhQpc2G+2oWMnQmTrxW20F4aQlX5gRFsRrHp4w+zciUct2j0VVdvsbZ8trJDLj+mGNgdE1I25ddAnyDjmbr8eeckeeGIqtfjL1uI3WeoeM99Xa9VuytHz5wAtj5HVOXJq3cDZ4gqbt9qr5aDkOV+74+B9ckF4Zxx/OgvbcR51ZA==
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA0PR12MB8374.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(1800799024)(376014)(7416014)(23010399003)(366016)(921020)(3023799007)(6133799003)(10067099003)(56012099006)(5023799004)(11063799006)(18002099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?utf-8?B?eWpRa1g4TTBZTnQ2bnRZS3h1WFA4c1gzWm4xSFB3Z3JNZFZJcGk1cm5aVGF0?=
 =?utf-8?B?dnhIY3hJdDBSaWxZTnVHR3BrTGRGUGZScHI3MVFrbTcxbEJ6d3dBN3NRcy9T?=
 =?utf-8?B?RlZ6STN1Yi9VMnlOSTJodjA3M0dqK0Z3TG5KNnI0M2VNUGh4NVU1SFk3Vmk5?=
 =?utf-8?B?ekZmTXpEUnZveFdHdFpMMkRmdjBtT3JNV2l6L29NUmdYZjFHZWpSMVE0V2ln?=
 =?utf-8?B?bDNWZktoRjZEbGRtUHBxSmp3OGdZc2hBeFVvUyt6ajVQMkE2OXNqbHFJS2Vu?=
 =?utf-8?B?ekduYlJVZkI0ek44NXdvMW5KUW55aXdRR0JPd3lPeE53Y0ZuZjJOb2VkMTYx?=
 =?utf-8?B?c1cvSHh0S3RCNWxQT3J5cTJBazg2WVc3dUdXeUxkQ0FnMHZhM3ppdWY5TFhl?=
 =?utf-8?B?djhIcHdTNlFtZEswcHZCUkZyKzlwMVRjS1VkejhESlZFa1U0d1hmVXFzcDZw?=
 =?utf-8?B?V0VUcktpRmNCZTNWaXNuR0dQVTNueThqQzFidFJxOTA2YU5hOTdoYmZGNllx?=
 =?utf-8?B?eUl0K1RLU2V2QmZzWnErVk8vSmhOYkVFQk9YRFdwdXJ1WWNxQk9vc3NWTE9B?=
 =?utf-8?B?TEdYdUNQUHRUS1crNjA0T2hJUUtySSsya3czK2dDbUJGMTNPbDJyWEVYNk5q?=
 =?utf-8?B?K3Azc2hTWUNKdnNIalZiMjdhVzJ0OThLWkg4ckU2ZkRnTzFzUjdKRGZSRXpr?=
 =?utf-8?B?cGl1dGo0bTRqRzdQSldDQWM0bnpXdWxqNG9rdDh2TklqR0VaelNVYkVPTkVB?=
 =?utf-8?B?YzhBN3ljUFkzeUxvOUloZndyNjY5Z3FSL0FDeHIreXBsZWplL1I5TmhQREw5?=
 =?utf-8?B?dm1TTm9wdldrc1ZIK2RUWHJVZnEvbjlPMTVKSGhoSXdLc0tPK0pjSnJmWHY1?=
 =?utf-8?B?NStheFlWUExNS3RLLzAvYmhSVmk2S3V0bS94Q2ZySlJtYUYxQlkrZkRhU0Zh?=
 =?utf-8?B?YjdnQkZua05CS29Ua2pxUWUzNjRuRHltQnhRWVIxVFBQN0pDSWhSOWZuNDhE?=
 =?utf-8?B?M21oR0ZLL2ZSaUdnWThwb3NtQmtrZmc1dkpSMmxPMU05VWppWlJYVFZUVHlz?=
 =?utf-8?B?MW50Qm5TVE1zbElPMWVURFhNdG5VbjVzdnNvZW1wTE85Sm4raEh6ZW4rVFBC?=
 =?utf-8?B?RExVc0s0M2R3QkNMK2J0Z2RxM1NVMW5OU05XS3h1M09YQlZWMTNqMFZTVXM4?=
 =?utf-8?B?dVJjdUdvR1Ird3lBekVGd1ZWVndnWEFNbTU3ME50dzh0L0l4WUhDb2tVcmUx?=
 =?utf-8?B?aTJiNG9pS3NhN0xJU2hxMU1xSEFYNDA0UVpCSy9nSFhuV3RaZkxpcmdFZ2x0?=
 =?utf-8?B?Z205cTB0WG5USUdJeGJHOEF0R3hJay9aZUVnVUhCc1JudVFGL0g1alFyeG9C?=
 =?utf-8?B?UHUybldqS3BvRGx6MDc0bnpwS1VOYkNmRnVEdE1qQ2l0Mm9NODBqdVV1UEtZ?=
 =?utf-8?B?Zm9pZWF6K2hSVFg3M0l4K3FDNko3Sy9vQ3UwdWNad3ZyQ1FOeHpGNlc5aytt?=
 =?utf-8?B?cXZRQUl2T0xUTkRoWno1TFZZV3NDMXZEWk9uNk1Nc1VYM2VBNEprVVd3cTkz?=
 =?utf-8?B?S3lrTkZLRjJDNWpqdWtENkcrN3pMbjV0RUt5UlVodzRFZGtRWkhTdndBMncx?=
 =?utf-8?B?Zk5Wd2d4NTdTb3BNaDNlSndvV1RaUXM1QXB4SGNVKzlWRVBEYlRaRk5idmRr?=
 =?utf-8?B?UTM3cDJsQlMxczBjaW90R29ickJTME02UXRDME0yM0NBMGV0cVB2c3BHVEVQ?=
 =?utf-8?B?RktwK1MyT3kzMXlzbStCazF5YTJCMitHbWRra2ErWXRXYmE3aGU3bFRGSnZW?=
 =?utf-8?B?VkhqUXhjZ0NaQU0zUjFJNHBiTWMxUUR1cmxBN1BwZFp4RGNYRlFpTjJSTlZn?=
 =?utf-8?B?dGRDdGR3OHpiem1nbGl6cHdlWWtGdlZ2Vnp3aG04bUJBNFd3c2l1Rlh5MG54?=
 =?utf-8?B?dGM0NW9MbFhucmFOMG1FSmVxQXh2MG5SM0xQNnc0MklWMFgzQ1V2NTF2a3h1?=
 =?utf-8?B?OGRvcCtxcWRVcTdwMVlzWW94aGhsd0dMVFZZaWhQejRjeGdMZ1hyOG5wTGJ4?=
 =?utf-8?B?cFRlQm9UTlp1ZU44MW9kVWNoSnh0TlpsZ2gwaWNFRG5DMG9xMVVOTWtuOUZv?=
 =?utf-8?B?RDZVSHZaaWtaZmpNTzI3Z0h4OWlGd3o4YmxmRFhlT0U2YmRxaEVEaGNZWU1u?=
 =?utf-8?B?UUdoUWw3dUg3TVZLS3p2VTZmUEZZTU5JZnRPWXR5VW5QMzkwKzZlRUFUVU0y?=
 =?utf-8?B?TE9xTFllTWRMTjFwRWxKd2tmU1hUaXlRSHJTbjRuOGdSclhTa284U28vQ1FT?=
 =?utf-8?Q?F1TFjtIkGgWhFLH9mx?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: cd7bc866-ada1-4775-a366-08df1788007e
X-MS-Exchange-CrossTenant-AuthSource: IA0PR12MB8374.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 21 Sep 2026 02:28:20.2879
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: vyBX7Kyzqii8eJcu8TMIvK1/ygKw2l6cNqXR5BHUUQfr5ne4lK/kybDBlk0qcMdP
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM4PR12MB7719

Hi all,

This patchset removes PG_private to make space for upcoming PG_folio for
identifying pages from a folio (more details in Note below). Instead of
checking PG_private, all code is changed to check page/folio->private !=
NULL instead.

MM people are cc'd on all patches and subsystem people are cc'd on the
cover letter and corresponding patches.

This patchset is on top of commit ef0ea92854987 ("mm: zswap: return -ENOENT
when the swap device is gone") from mm-new, which is the same base as V4 of
this patchset and no conflict is found during the rebase. I also tried to
cherry pick the remaining patches from mm-everything on top of this
patchset and find no conflict.

Patch 10 and Patch 13 are the only two patches without any Ack or Rb tag.

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

folio_has_attached_private() is added to check filesystem-only private data
by excluding swapcache and hugetlb folios, because swapcache folios overlap
swp_entry_t swap with ->private and hugetlb sets its own flags in
->private.

Note
===
1. KPF_PRIVATE is removed after PG_private is removed.

2. Documentation/mm/hugetlbfs_reserv.rst is outdated, so I did not remove
   PG_private related text. It should be rewritten.

3. PG_folio is planned to be set on every page from a folio in
   page_rmappable_folio(), so folios with any order (currently
   PG_large_rmappable is used to identify >0 order folios, but not order-0
   folios) can be identified. Then vm_insert_*() can correctly reject all
   folios and rmap code will only see folios. Eventually, page_folio()
   will return NULL for non-folio pages by checking PG_folio, but before
   that all existing users that treat compound pages as folios will need
   to be converted.

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

Assisted-by: LLM
Signed-off-by: Zi Yan <ziy@nvidia.com>
---
Changes in v5:
1. replaced md patches (patch 13 and 14 in v4) with Matthew Wilcox's
   version (see Matthew's replies to v4).
2. used data_race() inside folio_test_private() and PagePrivate(), so that
   the new versions can be used without KCSAN warnings while not holding
   folio lock like before.
3. moved folio_has_attached_private() implementation detail comment next to
   the code.
- Link to v4: https://patch.msgid.link/20260913-remove-pg_private-v4-0-848550f7574e@nvidia.com

Changes in v4:
1. dropped set_page_private(0) in balloon_retrieve(), since page->private
   is cleared at that point.
2. simplified the comment in add_hugetlb_folio().
3. additional cleanup for f2fs to remove fio->page uses and convert
   PAGE_PRIVATE_* flags and helper to folio-only.
4. added a comment for __readahead_advance().
5. added core-mm split/migration interaction information on newly added
   folio_attach/detach_private() for erofs.
6. renamed folio_test_fs_private() to folio_has_attached_private() and
   merged the commit introducing folio_test_fs_private() into its prior
   commit.
7. adjusted the patch subject: "treewide: remove folio_set/clear_private()
   *usage*"
8. split "treewide: replace PagePrivate() with page_private()" into three.
9. moved some comments in "treewide: remove PagePrivate() and PG_private
   from comments and docs" to prior patches along with code changes.
10. used PG_folio instead of __PG_folio to avoid additional
    code change in __def_pageflag_names().
- Link to v3: https://patch.msgid.link/20260907-remove-pg_private-v3-0-6ae22f9d9272@nvidia.com

Changes in v3:
1. changed folio_test_fs_private() to check PG_swapbacked instead of
   PG_swapcache for excluding swapcache folios. Because folio->private and
   PG_swapcache are not set as a whole, making folio_test_fs_private() give
   false positive, whereas PG_swapbacked is always set for swapcache
   folios.
2. added __DEF_PAGEFLAG_NAME() to show __PG_folio instead of open code.
3. f2fs change is picked up at
   https://git.kernel.org/jaegeuk/f2fs/c/5ad9409a9533, mm-new currently
   does not have it, so the patch is sent for MM testing purpose.
- Link to v2: https://patch.msgid.link/20260831-remove-pg_private-v2-0-3668159cd9e8@nvidia.com

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
Matthew Wilcox (Oracle) (3):
      md: Use folio_alloc_buffers()
      md: Use folio APIs in free_page()
      md: Remove the last use of page_buffers()

Zi Yan (14):
      mm/zsmalloc: replace PG_private with pointer comparison
      perf/ring_buffer: stop using PG_private as AUX page high-order marker
      xen/grant-table: stop setting PG_private on pages for grant mapping
      fscrypt: stop setting PG_private on bounce page
      mm/hugetlb: use direct assignment instead of folio_change_private()
      f2fs: stop using PG_private
      f2fs: convert the ->private flag helpers to folio-only
      erofs: mm/pagemap: add readahead_folio_last() to avoid folio->private
      erofs: use folio_attach/detach_private() instead of direct assignment
      mm/page-flags: check page/folio->private instead of PG_private
      treewide: remove folio_set/clear_private() usage
      ceph: replace PagePrivate() with page_private()
      treewide: remove PagePrivate() and PG_private from comments and docs
      mm/page-flags: remove PG_private

 Documentation/admin-guide/kdump/vmcoreinfo.rst |  2 +-
 Documentation/filesystems/vfs.rst              |  6 +-
 arch/x86/events/intel/bts.c                    |  3 -
 arch/x86/events/intel/pt.c                     |  6 +-
 drivers/md/md-bitmap.c                         | 18 +++--
 drivers/xen/grant-table.c                      | 11 ++-
 fs/buffer.c                                    |  8 ---
 fs/ceph/addr.c                                 |  8 +--
 fs/crypto/crypto.c                             |  2 -
 fs/erofs/data.c                                | 16 +++--
 fs/erofs/zdata.c                               | 13 +---
 fs/f2fs/compress.c                             | 35 +++++----
 fs/f2fs/data.c                                 |  2 +-
 fs/f2fs/f2fs.h                                 | 99 ++++++++++----------------
 fs/f2fs/segment.c                              |  2 +-
 fs/nfs/file.c                                  |  4 +-
 fs/nfs/write.c                                 |  2 -
 fs/proc/page.c                                 |  1 -
 fs/ubifs/file.c                                |  8 +--
 include/linux/buffer_head.h                    |  8 +--
 include/linux/kernel-page-flags.h              |  1 -
 include/linux/mm.h                             | 34 +++++----
 include/linux/mm_types.h                       |  4 +-
 include/linux/page-flags.h                     | 51 ++++++++++---
 include/linux/pagemap.h                        | 64 ++++++++++++++---
 include/trace/events/mmflags.h                 |  2 +-
 include/trace/events/pagemap.h                 |  2 +-
 kernel/events/ring_buffer.c                    |  7 +-
 kernel/vmcore_info.c                           |  1 -
 mm/huge_memory.c                               |  2 +-
 mm/hugetlb.c                                   |  7 +-
 mm/migrate.c                                   |  3 +-
 mm/page-writeback.c                            |  2 +-
 mm/vmscan.c                                    |  2 +-
 mm/zpdesc.h                                    |  2 +-
 mm/zsmalloc.c                                  | 24 ++-----
 tools/mm/page-types.c                          |  2 -
 37 files changed, 238 insertions(+), 226 deletions(-)
---
base-commit: ef0ea92854987c1e61cd72e100c8b61b485955d8
change-id: 20260728-remove-pg_private-cfe926c7f83c

Best regards,
--  
Yan, Zi

