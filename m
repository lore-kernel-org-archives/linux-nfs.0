Received: from BYAPR05CU005.outbound.protection.outlook.com (mail-westusazon11010031.outbound.protection.outlook.com [52.101.85.31])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D38FC3264DD;
	Mon, 14 Sep 2026 02:24:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.85.31
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789352701; cv=fail; b=AQEJfw1MlPVJ3Fs1hUwwXBMz0MkyBmCReDTsR9YaJ4o0YI1e7Uk1uij/WWAbinr4Evken0YhieOE5OIrSyI8HK2mrHB1AiwCnT6LHwvIsBZGNZ4oB7bAxY4wN+e7Xc1rgKEETxpypuvOhYKREXGRi4IDZgagdfAazk00e0s9YQw=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789352701; c=relaxed/simple;
	bh=jyCIZqHaHzMDVDMThSlBvPJYGCb9JGU/pfktsnaSDzA=;
	h=From:Date:Subject:Content-Type:Message-Id:References:In-Reply-To:
	 To:Cc:MIME-Version; b=Pi4OQkLYte14nTEJOSWWde6Lo+mYM6uLz9ipRpg9sOFgpZ7xv443n1sNo7EbQiN86cacHZpbQKtM9CcmeF1tJVbgjtyQ9kKj7YLS/GqtK5gHCZj5jf0h0nVyA4K9gPbGtTLyJrab2v61IYMiNbcRnHkB2hGywLbVB78XExqnk7U=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=ReZ14c4O; arc=fail smtp.client-ip=52.101.85.31
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="ReZ14c4O"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=R6bGCTxDMPwV60AzamER/kUR7rVPMtTtVxGFCh472WBc/Kpa3zBHT17zeXG9lOg6PhmQSbV5gR8YKIKFpaFF5FY21NTWvhc5ZPV1t/45axlTx0fAmSropPRNJ1D6CuQzBWSTlO+yU5IsAKX/Xf9xi3CyC5Jrzs92fEqCj3z6D+bq+Nflq75K07j8/qpamNH2KgeNp3JsOHUPKNlLgTBwpnPHSIbdngeoxqoICZsuhxE7OnL+yC1mQN8ZnMLCh4Dpydksjd6nCxRzL3Q6kS3qBZJFOLPkQWcOQIy/osGvQAyZVlqWoz9oIOIlWHIOtptc3KdRMZXIyRDTV216Y5dP9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=jzt3NPvDi10W6qHzF15o3z+l2gytr2fjHobdhoCYeR0=;
 b=EdUKePzIzHmIu8udwGbfMNVDuuWhAIAAb5pozu0lUOKnnI9cxiXS0MIOY+0LfaUBojX4cAklYP3H8RQSTi57DdU1VR29hHpP5T2j7C/eiMZB8/Ggkbm4iiGeAFdxRxuBSEhkiijfkEgY2sQcrwMu3/e/47ZryggSn0BLzJeowJ+z3kd8VaxbpkDpulvifgjcvwg37UIJcUwRcUU28MboQ3uVyudIEpGPkugkp36+zwL3nHAnsMDUfLZ8aNtCLyJYTRKfu9KCv0wk3AVRj+Esdbg9A6fyUhHs2tvUCnjdIlykmgtXNKV3LpvZcZMve6mMqcrRuyvxazeA3Uo9TeMboA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=jzt3NPvDi10W6qHzF15o3z+l2gytr2fjHobdhoCYeR0=;
 b=ReZ14c4O4X3A/GKYC2jLLzyc/FyBuPtpqTNKl155CVXuEvj8VW80TYHyrAxJ9CWVKzDoiQYFnaV0zWO85fN8VQOZqYPHy07BV6YSwxP/uYVJ66Y9IpPcCQC7l+GDDLsY+nPEjop1rwZxuexDk6WA8bL7My9zKXt32MCWJiiGHGK+Zv638qpcdRNP6fKUbjbrUYcmAyhR2eXkdQ1O9r6xT/Lv+W4yywISQ3C7gO0Ck6bbSY/1K5oJd94obcmZz4Om0hQO8NNBHO5r32dQUxua7QwpeoTnRVE2FTHt/PlxdbNhdoo8BV3LL9NTTRX0F1q8Hz6tw6xRRbUqvIsdlXKLEg==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from IA0PR12MB8374.namprd12.prod.outlook.com (2603:10b6:208:40e::7)
 by DS0PR12MB6486.namprd12.prod.outlook.com (2603:10b6:8:c5::21) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.406.12; Mon, 14 Sep
 2026 02:24:29 +0000
Received: from IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16]) by IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16%5]) with mapi id 15.21.0406.007; Mon, 14 Sep 2026
 02:24:29 +0000
From: Zi Yan <ziy@nvidia.com>
Date: Sun, 13 Sep 2026 22:24:13 -0400
Subject: [PATCH v4 15/16] treewide: remove PagePrivate() and PG_private
 from comments and docs
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260913-remove-pg_private-v4-15-848550f7574e@nvidia.com>
References: <20260913-remove-pg_private-v4-0-848550f7574e@nvidia.com>
In-Reply-To: <20260913-remove-pg_private-v4-0-848550f7574e@nvidia.com>
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
 Zi Yan <ziy@nvidia.com>, Ilya Dryomov <idryomov@gmail.com>, 
 Alex Markuze <amarkuze@redhat.com>, Viacheslav Dubeyko <slava@dubeyko.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Richard Weinberger <richard@nod.at>, Zhihao Cheng <chengzhihao1@huawei.com>, 
 ceph-devel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 linux-mtd@lists.infradead.org
X-Mailer: b4 0.16.0
X-ClientProxiedBy: YQBPR0101CA0319.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c01:6c::19) To IA0PR12MB8374.namprd12.prod.outlook.com
 (2603:10b6:208:40e::7)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: IA0PR12MB8374:EE_|DS0PR12MB6486:EE_
X-MS-Office365-Filtering-Correlation-Id: adfccd7b-253d-4087-7851-08df12074e44
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|23010399003|7416014|366016|376014|1800799024|6133799003|22082099003|18002099003|921020|10067099003|56012099006|11063799006;
X-Microsoft-Antispam-Message-Info:
	3xx3GClA1nOEPzZvDyfHbYC0HBFFz2N+1tdMfUvNPmaMX71b9gNM+Yqd99pYqxJk2i5ifEo3yxnUiBNmQaSlgNjKXchq1F/9Vd+o3mmLkF3PKt9xgdoLtx++HlXXyZHUv3naZPylNooSeD0EGE8mHvsw9vbgNNnTbvwB0Xrkold7WPjnjZ1eDP8Qu17xtuMFNR/hh0OAIvn/Z5guOW2RMpXKRknuWvMFKXNZY2OZQTfg10qQxpEovJ+Z538BQ8IsnRJn+n7dN/yEXYAOgIIIK/EyW7cSGIJcGXQQ9BOD6EzU2Do6TRjgauhumTfZmfmU1ZZvjdE7qpQPVBOvNA5T1qU8PSnuEILBNB2HfxfCJElvkdreXIJ3W9UfphPWdMZbbW7p3RQwiWt2uQv2D/cQC1nCMUrMFVFQvaaMfX0pRPnsbMlbYySVGN9h7Hq+FCWqz2ssa3OqOCCCC0R8NFl2msZso3ULaFX5Iw2brN3LSTmqTQR4J0QzpsoZpf5SLJZmEn8My6relfd5Y4WNh5UIsgkXwLlX3sUP6ZRUBRyAbZt0dVKtpbVBUhpp4nTtazhoRIh4s0gXFzlRZfvQuXkswZAAmhAsR5NHQE2q05JrmfWwk4N4TiELcpd+t5GB4VLobid4RN9J4GiHhNyyUGPh3Pm5EnKEaXZ7CiSoLtV2KuGVN/D+owsPhUVmcChuq66RSPzB3HAv5VD/rM6a/MYHGg==
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA0PR12MB8374.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(23010399003)(7416014)(366016)(376014)(1800799024)(6133799003)(22082099003)(18002099003)(921020)(10067099003)(56012099006)(11063799006);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?utf-8?B?NkNnS214aDBqQ2V0MzFnb0dwUlFDYktGR0ZPK3RET1hQL1Z6OGppYXBaOTYv?=
 =?utf-8?B?RFg1ZVRYMS9mM0dHRHpITWZ0c0NzZnYrcXdOaEhVZVdYL0VZcUM3M1VlK00y?=
 =?utf-8?B?S0lnVDhkc3diQnBPT2diUWJqMEVUeVZvcnIzYmNEL2prNm5JR080V24rbm5k?=
 =?utf-8?B?NzFCaUM5eGJhb09IdXZ2NDIwa0szelUyK3B2V2xNU1FYSVFzMlhGZ1h3WUMw?=
 =?utf-8?B?eWE3TU5TNXpFNUprbStmZHhLbjVSUUlDbGNVSzExT05NbHhaNTlRTTlYOFlE?=
 =?utf-8?B?emhQL21Pekg2ZlpOWGpBc1A4d2FpaUJoYXhBdGFUVzN1SS9JbE5qVzliRUpz?=
 =?utf-8?B?TkhlWVNDaGFZWForV0JpUEw3amx6NTI0dkpWNEticzNRdGxWZ2pOQW5TRmZ4?=
 =?utf-8?B?OGZlOWZ0VW5qNmR3ZkFSSlNINDQxUFdwV0hOUXNZcWw1UmljMUxvY282UytI?=
 =?utf-8?B?VElBaG4yZVhIcG83bHZ1K21jTDF0RmIwazY5S2xFZ0xDZ2I5MVRxMGVacVB6?=
 =?utf-8?B?dW1yQlJXRHpkbDNKYjlVSndMOWdxcG9mc0JEeHdQbXF2cXNPdWlZajlLdzdO?=
 =?utf-8?B?TGF1SWpyL2FiYUJYSC9OQjhNcS9KZklQT2FySk9kUHNVWTdpTmNsRWgwbGY1?=
 =?utf-8?B?WkplaWc3aURzcVlPajNneldkR3g2Mk02WUk5cGpudGluVUQ1Vm1WUU9KRjlW?=
 =?utf-8?B?WXc5dVpoT3JJcjdwUlVmV1Q0Yjl5UWJOZkxGaWFOV0RCVWJaVmM0QW5ldEVW?=
 =?utf-8?B?endSK1hLenowVVpjRnpSazBScldyY1JMVW1NR2xaSG02K3JubU9vcGNCR1Fv?=
 =?utf-8?B?cTZLcnZXZXNHekZxMW51Um5LNEtEVGtaZCsweTRRaVZ2VkpwOGdWVXZNajVU?=
 =?utf-8?B?ZUZkMGJLR0tsQVVxM3k5S0dBeVY1Z3NxR0RkUW52WlIwT2J6M25zZWluQjJU?=
 =?utf-8?B?dDdQWUN6d1dCYWFCT2toaUFvQzFuQWVkdlBvZkhQdCtMRjhsVTZuaUI4RDJR?=
 =?utf-8?B?b3c3Qyt4VWZ1OHRiMHRKU0RWT3h3dzNlTk1TYmdUTzhicjEvZU12TlJTNTFW?=
 =?utf-8?B?ekI3S1F3eUt4WVdwdW9NVXFoQitrZkN3Uk5UYVI1cGJjZlRIcTB4QWpqMkw5?=
 =?utf-8?B?L2QyeGU0dmVvZEhVaG5QQ0Z0YzVjLzJKNnllZ0xhUGZMaHk1SndDT2RldDdr?=
 =?utf-8?B?dTV5MXF0WXBtTTUzWEJuT1VzRUlvVEdDMWpqbyt2QWpINHVndExJbmN4c1lu?=
 =?utf-8?B?TllYRE01UjRYNDFqR0phdGJWL0xCZlFzd28xeHZYVE9zZC9nK0Juajd6NHow?=
 =?utf-8?B?TzBIZ1dCQTl2aitEVGFEYStDNUlSTkdEVWdWSmxndmNyRXRScG5zeHVwVU5H?=
 =?utf-8?B?NTdLTlZYdXBtWXBqMHc4R0pYSVUvOW9XUmZQQVQ2bk1RYU00MGphVyt4VG5r?=
 =?utf-8?B?WjFlbUNHYW1xQzB3RU9LM3lZRndzaWlvY1U4bnRXaXZFekRqb3Q4dDRaREJF?=
 =?utf-8?B?SWxkS2o1QmQ2TWdBTzFSL3VrWDVlQlJaVkU5a2F2M1pyRnBPVVhWWml3bFZE?=
 =?utf-8?B?SjAwZTdLZ0dYYTg1TW5QZFFmaSsxakgzTWExeVNxWnFsUE41bVR1RXpkdTBM?=
 =?utf-8?B?YmJ3eXM3cnd4S0RHQ1IxdHNNOUlOdzl4dTdDSXkxZnlaNzkzQStEWmRvRlh1?=
 =?utf-8?B?cEI3ZDUzLzk4cnBhdUY4VUw0OFRoZHhIQ0xEQ3NpZnpFR29ybXIzVDE3WExG?=
 =?utf-8?B?YjdmRnN4aWhYT0ZBVVd5RDZaYW1wMWlWTnZtU0R3aUZ5K2l3VFVDbndReWtW?=
 =?utf-8?B?enowUXY5anAxWlczU2xGL2pnc05oVElNeDlQaEtYMXZDQU5GVzloNndJL2lC?=
 =?utf-8?B?amNxRlZhOHpWL25VREtzak1YQ3NDREFEMEtha1FxT3FsMjFNNVB0VGlWVDZU?=
 =?utf-8?B?TThpdjhJd2NWeHR5OVdOZWRkcU0xK1BTQk1VejdUem5SMndEK1I1OUJPODRh?=
 =?utf-8?B?bFRQb1hIdWJKRUhzNkxaN3JML1VITTZDamErMERhbngwaEp0aGpkR1d2T0cr?=
 =?utf-8?B?ZzYySUN4ZDJwR1dJdWlVVHREUmFoMWJ2L1hPMmZ1UHlpSk1TNVpLaktERlpF?=
 =?utf-8?B?OXZhRHY1VHgyUEkzRzRKazdKbG5hZWxKYmtJTnp0MWY5WXpYaXZCNk9DdzZN?=
 =?utf-8?B?Um0wVENGR2cvaXhwaDZQRTFubG9meVdyVVM5SFR1K2E4blB5V1hjTEdPQ0NF?=
 =?utf-8?B?dFNIektKK0pVMzQ1aUFCMFowYnJRb0VMR2dKaHBKSTd0aFR6VmxGRlJJTDNl?=
 =?utf-8?Q?pyHpbr8XZLdCPGQgSj?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: adfccd7b-253d-4087-7851-08df12074e44
X-MS-Exchange-CrossTenant-AuthSource: IA0PR12MB8374.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 14 Sep 2026 02:24:29.8023
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: EWv4SEVFSyc4yJSod4HCDWtrWLSRZrpvwPutx66RCZFNSeO8rkRns8vk6hqqs35a
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DS0PR12MB6486

PG_private and PagePrivate() are no longer used. Adjust related comments
and documentations to refer to page/folio->private instead.

hugetlbfs_reserv.rst is outdated and left unchanged. It should be
rewritten.

Assisted-by: LLM
Signed-off-by: Zi Yan <ziy@nvidia.com>
To: Ilya Dryomov <idryomov@gmail.com>
To: Alex Markuze <amarkuze@redhat.com>
To: Viacheslav Dubeyko <slava@dubeyko.com>
To: Trond Myklebust <trondmy@kernel.org>
To: Anna Schumaker <anna@kernel.org>
To: Richard Weinberger <richard@nod.at>
To: Andrew Morton <akpm@linux-foundation.org>
To: David Hildenbrand <david@kernel.org>
Cc: Zhihao Cheng <chengzhihao1@huawei.com>
Cc: Lorenzo Stoakes <ljs@kernel.org>
Cc: "Liam R. Howlett" <liam@infradead.org>
Cc: Vlastimil Babka <vbabka@kernel.org>
Cc: Mike Rapoport <rppt@kernel.org>
Cc: Suren Baghdasaryan <surenb@google.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: ceph-devel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
Cc: linux-mtd@lists.infradead.org
Cc: linux-mm@kvack.org
---
 Documentation/admin-guide/kdump/vmcoreinfo.rst |  2 +-
 Documentation/filesystems/vfs.rst              |  6 +++---
 fs/nfs/file.c                                  |  4 ++--
 fs/ubifs/file.c                                |  8 ++++----
 include/linux/mm.h                             | 15 ++++++++-------
 include/linux/mm_types.h                       |  4 ++--
 6 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/Documentation/admin-guide/kdump/vmcoreinfo.rst b/Documentation/admin-guide/kdump/vmcoreinfo.rst
index 7663c610fe901..5f1df6d080508 100644
--- a/Documentation/admin-guide/kdump/vmcoreinfo.rst
+++ b/Documentation/admin-guide/kdump/vmcoreinfo.rst
@@ -325,7 +325,7 @@ NR_FREE_PAGES
 On linux-2.6.21 or later, the number of free pages is in
 vm_stat[NR_FREE_PAGES]. Used to get the number of free pages.
 
-PG_lru|PG_private|PG_swapcache|PG_swapbacked|PG_hwpoison|PG_head_mask
+PG_lru|PG_swapcache|PG_swapbacked|PG_hwpoison|PG_head_mask
 --------------------------------------------------------------------------
 
 Page attributes. These flags are used to filter various unnecessary for
diff --git a/Documentation/filesystems/vfs.rst b/Documentation/filesystems/vfs.rst
index d3a93eec3945f..dec7816303c6a 100644
--- a/Documentation/filesystems/vfs.rst
+++ b/Documentation/filesystems/vfs.rst
@@ -649,8 +649,8 @@ Writeback.
 
 The first can be used independently to the others.  The VM can try to
 release clean pages in order to reuse them.  To do this it can call
-->release_folio on clean folios with the private
-flag set.  Clean pages without PagePrivate and with no external references
+->release_folio on clean folios with folio->private set. Clean pages
+without folio->private set and with no external references
 will be released without notice being given to the address_space.
 
 To achieve this functionality, pages need to be placed on an LRU with
@@ -674,7 +674,7 @@ filemap_fdatawait_range, to wait for all writeback to complete.
 
 An address_space handler may attach extra information to a page,
 typically using the 'private' field in the 'struct page'.  If such
-information is attached, the PG_Private flag should be set.  This will
+information is attached, non-NULL 'private' field will
 cause various VM routines to make extra calls into the address_space
 handler to deal with that data.
 
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index e1bdd10b35f10..38f830a6467c9 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -484,7 +484,7 @@ static int nfs_write_end(const struct kiocb *iocb,
  * Partially or wholly invalidate a page
  * - Release the private state associated with a page if undergoing complete
  *   page invalidation
- * - Called if either PG_private or PG_fscache is set on the page
+ * - Called if either folio->private or PG_fscache is set on the page
  * - Caller holds page lock
  */
 static void nfs_invalidate_folio(struct folio *folio, size_t offset,
@@ -555,7 +555,7 @@ static void nfs_check_dirty_writeback(struct folio *folio,
  * Attempt to clear the private state associated with a page when an error
  * occurs that requires the cached contents of an inode to be written back or
  * destroyed
- * - Called if either PG_private or fscache is set on the page
+ * - Called if either page->private or fscache is set on the page
  * - Caller holds page lock
  * - Return 0 if successful, -error otherwise
  */
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index e73c28b12f97f..aa0298ce451ef 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -12,14 +12,14 @@
  * This file implements VFS file and inode operations for regular files, device
  * nodes and symlinks as well as address space operations.
  *
- * UBIFS uses 2 page flags: @PG_private and @PG_checked. @PG_private is set if
+ * UBIFS uses folio->private and page flag @PG_checked. folio->private is set if
  * the page is dirty and is used for optimization purposes - dirty pages are
- * not budgeted so the flag shows that 'ubifs_write_end()' should not release
+ * not budgeted so it shows that 'ubifs_write_end()' should not release
  * the budget for this page. The @PG_checked flag is set if full budgeting is
  * required for the page e.g., when it corresponds to a file hole or it is
  * beyond the file size. The budgeting is done in 'ubifs_write_begin()', because
  * it is OK to fail in this function, and the budget is released in
- * 'ubifs_write_end()'. So the @PG_private and @PG_checked flags carry
+ * 'ubifs_write_end()'. So the folio->private and the @PG_checked flag carry
  * information about how the page was budgeted, to make it possible to release
  * the budget properly.
  *
@@ -1509,7 +1509,7 @@ static vm_fault_t ubifs_vm_page_mkwrite(struct vm_fault *vmf)
 	 *
 	 * At the moment we do not know whether the folio is dirty or not, so we
 	 * assume that it is not and budget for a new folio. We could look at
-	 * the @PG_private flag and figure this out, but we may race with write
+	 * folio->private and figure this out, but we may race with write
 	 * back and the folio state may change by the time we lock it, so this
 	 * would need additional care. We do not bother with this at the
 	 * moment, although it might be good idea to do. Instead, we allocate
diff --git a/include/linux/mm.h b/include/linux/mm.h
index c9aad2c39fd9c..e4ee59beccbaf 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2048,20 +2048,21 @@ vm_fault_t finish_fault(struct vm_fault *vmf);
  *
  * A pagecache page contains an opaque `private' member, which belongs to the
  * page's address_space. Usually, this is the address of a circular list of
- * the page's disk buffers. PG_private must be set to tell the VM to call
- * into the filesystem to release these pages.
+ * the page's disk buffers. It tells the VM to call into the filesystem to
+ * release these pages.
  *
  * A folio may belong to an inode's memory mapping. In this case,
  * folio->mapping points to the inode, and folio->index is the file
  * offset of the folio, in units of PAGE_SIZE.
  *
- * If pagecache pages are not associated with an inode, they are said to be
- * anonymous pages. These may become associated with the swapcache, and in that
- * case PG_swapcache is set, and page->private is an offset into the swapcache.
+ * If pagecache folios are not associated with an inode, they are said to be
+ * anonymous folios. These may become associated with the swapcache, and in that
+ * case PG_swapcache is set, and folio->private is an offset into the swapcache.
  *
  * In either case (swapcache or inode backed), the pagecache itself holds one
- * reference to the page. Setting PG_private should also increment the
- * refcount. The each user mapping also has a reference to the page.
+ * reference to the folio. Attaching filesystem private data via
+ * folio_attach_private() also increments the refcount. Each user mapping also
+ * has a reference to the folio.
  *
  * The pagecache pages are stored in a per-mapping radix tree, which is
  * rooted at mapping->i_pages, and indexed by offset.
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 5413bd10fff2c..9d6c945ba4104 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -108,7 +108,7 @@ struct page {
 			};
 			/**
 			 * @private: Mapping-private opaque data.
-			 * Usually used for buffer_heads if PagePrivate.
+			 * Usually used for buffer_heads.
 			 * Used for swp_entry_t if swapcache flag set.
 			 * Indicates order in the buddy system if PageBuddy
 			 * or on pcp_llist.
@@ -675,7 +675,7 @@ static inline void ptdesc_pmd_pts_init(struct ptdesc *ptdesc)
 #define STRUCT_PAGE_MAX_SHIFT	(order_base_2(sizeof(struct page)))
 
 /*
- * page_private can be used on tail pages.  However, PagePrivate is only
+ * page_private can be used on tail pages.  However, it is only
  * checked by the VM on the head page.  So page_private on the tail pages
  * should be used for data that's ancillary to the head page (eg attaching
  * buffer heads to tail pages after attaching buffer heads to the head page)

-- 
2.53.0

