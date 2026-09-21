Received: from SJ2PR03CU001.outbound.protection.outlook.com (mail-westusazon11012058.outbound.protection.outlook.com [52.101.43.58])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 584B4351C34;
	Mon, 21 Sep 2026 02:28:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.43.58
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789957734; cv=fail; b=DZNBY02frCbTTDn/0sLU12/VyWSo51BYQshouuzKzEn45661FNTe850642HLBvaGvU7oz9aKCC66ytzLWvuAOioErZ+0kT336xFaSnwRd+uzZ8ZEi36VXVggy3kSrnUWAWeY/joTYPYdwDPyHcabzpzpK5E7yQriv8NUrYydX7w=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789957734; c=relaxed/simple;
	bh=/StSJ7Iv2ZPbidi+Pd/gMFJjHtaKhgzvpRbIm+QBaGc=;
	h=From:Date:Subject:Content-Type:Message-Id:References:In-Reply-To:
	 To:Cc:MIME-Version; b=th+xHldVcRlkMeOP3ZZ/aKzyKH4P4q+QoJ1v7h+u5OuVz47pbSGJ/I+nKtjFv4GAdJJY48t1zxfbNs2KCrT33e4z2JSZl7ZlxVSCPtsnbhL3jlMqTREU3NHvOmedG205L3mK4KQFCikHuWp67PrXJk+oC1LoyCMv7AxJWnUgNJI=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=nF6ALZPl; arc=fail smtp.client-ip=52.101.43.58
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="nF6ALZPl"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=HJGpBKVAvou3rpKxM6s2Ki0Fz5TY3h5dV45MLJXKrNv6A/pMyk9MH3WdyQ1Y9+poJFrsBa8BfK9zwnTW0HRA9HRV4QQ+bPqAgaVD4K2qtJrR3uJPKMvR8lFUA/9zynlf+IpyhBlpSepeJx9o+SmtapYHkuOUq5Q+bZbRUW4bm1PkOxY6yPN8d/CI9F2P0FyUzv0El6g67zJrUiqmqtCIQrxUwj9Dig7tLITN+ItPQUtYfqjfSEx8JMjc1SVt+yr3C46FgPrt5+BQmwuK080dDQIp7gNTIBAnDRuqN/JLBc1I0b/788ZeUwoinhLBYX1gbRIHzH5/AWKYwswosJDYxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=gy9SEKH5y9YZF5tt5iXjB5JVr/kM2C+dpwgx7eDwiVM=;
 b=g6xhe6dszv5zFPevNgKj+IpJJFVzFmsORcUSjtZZtxEVYFB4nG/BtMk/a0pOKg3lg/TwE0TBmGeWPousoE2EId974sm7agGLPPfLGtPdhGKbn+G+EeOR4BkKDdMcf2kFc+H3IZIBqz0qe1FRY/eHEKCDWU9A8eIbPdFpCicRr5Pd9lxvqpICZ3OzWj6F+Tt0DgqgikA8Pym50pw3z521R5OTqJddV+mhQ/WinPR5juJShlVQeJ5g9KvOpeZQtnN+FtPJit7SnSXUmfHlmFzT++XSP4kd1xZa2kOQVp0Y0pJHBOXub/cwmr51H5Z2D4DgKhpfL3Efs/DGvg+OJ+jcwg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=gy9SEKH5y9YZF5tt5iXjB5JVr/kM2C+dpwgx7eDwiVM=;
 b=nF6ALZPlUtGLfLiqKYn4298+LhEF0WVqnPFdgsat2glHje1N0nBOHq19ywB39ELvh940eUuz/nshvD/4HnqEuLQPWnPZM8pib7fVbem+RIdvCJmHE2gGE1jy9fBSbmtXTKEiJd4bmg9MLhxhRhnn42N+dhf1wX1thXyXh7vRiwclkAqmZbXN2kARWIn/zItn7ScOgXoIzdS1+oHEg6894eyWcuSF3yf+cmmSYrQd6wZbA4muaMN3kLzstsTq4F4oMOlKEYv3NVVuUzez3olPjWLYN39B+d0wbnFyBCbo10WuKTrpCwUyyN5WncrXxmtQ53ZRgLEC+EF13ugF5t6UVQ==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from IA0PR12MB8374.namprd12.prod.outlook.com (2603:10b6:208:40e::7)
 by SJ1PR12MB6097.namprd12.prod.outlook.com (2603:10b6:a03:488::6) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.428.15; Mon, 21 Sep
 2026 02:28:44 +0000
Received: from IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16]) by IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16%6]) with mapi id 15.21.0428.014; Mon, 21 Sep 2026
 02:28:43 +0000
From: Zi Yan <ziy@nvidia.com>
Date: Sun, 20 Sep 2026 22:28:12 -0400
Subject: [PATCH v5 16/17] treewide: remove PagePrivate() and PG_private
 from comments and docs
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260920-remove-pg_private-v5-16-bb68b6a21869@nvidia.com>
References: <20260920-remove-pg_private-v5-0-bb68b6a21869@nvidia.com>
In-Reply-To: <20260920-remove-pg_private-v5-0-bb68b6a21869@nvidia.com>
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
X-ClientProxiedBy: YQBPR0101CA0354.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c01:6b::11) To IA0PR12MB8374.namprd12.prod.outlook.com
 (2603:10b6:208:40e::7)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: IA0PR12MB8374:EE_|SJ1PR12MB6097:EE_
X-MS-Office365-Filtering-Correlation-Id: 68999f74-ea2c-4f55-7b04-08df17880e64
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|1800799024|376014|7416014|366016|23010399003|921020|6133799003|10067099003|56012099006|11063799006|18002099003|22082099003;
X-Microsoft-Antispam-Message-Info:
	uBvp90y4FtHJdO9/OgPskMvff5e7txGdQ+d0vvaFRaCLyJBvGSC9IF81THehq7g8o0+PC7nqsPy6ELs6hAcYbSnAkMDFokU3r/ICU4xF+6VM/mT/ZX6hrRcIR6qHF5Pv7tq75rCTOp59W6565/eqp3Rewd+LZETofZ+Z1SOEZzesJaYxrI8ylwHTNBlH/8UpiLG7ywUhO0025iIaBcR+4m2zPGjVedPSl0YkYrgtt46RUkjqNRhYi4WqbOklPnxZfE+CyksRMJk5Lqukd1e1FBSbbFIYQWkSCoECsFwXMWvtlI2DGt6/f+8ogrisyeDyYRpy5mvo/eEU4cWMmesL1iCrretgxUrn5UKlmwKXlKb425431V/lNZDJ8/a4czSSKW4Nd+Qfh3/O+Uqg0R0+ABhP/Img7k9T2Xhmal3nEnjrsy13SOO2LBO/D+0sm+7qJljV9AtFPIjfpNo2v+CN5SLiOAyM2SOVcvHv+TQY/x44Tl15W8PF5M1jet348rUj4Ar0LpfbwGqG+4b2J5dbbirYM+ZghtaitIQSjELt4bQdbIak+QVzilm602xZfzWar18HiXUfqzbqo9PUR5B3ur5gNa8LptbaZejfHq0vvHP/KcHkoXEwglnIwMu1a2RcXIL8GAwj9fk6uoBbp82FY8XhR9GzIj3XqBRsYdH+w/q4bFVUkSJf8BIGFHyblPlyGORAzrfo5oXkBhe43ohqAA==
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA0PR12MB8374.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(1800799024)(376014)(7416014)(366016)(23010399003)(921020)(6133799003)(10067099003)(56012099006)(11063799006)(18002099003)(22082099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?utf-8?B?NlRDRWlXRUJsN0tMaWdTbHlZaTh2UUdWbUxkSGJwdWIwOWYvKzNYYmpwNTl3?=
 =?utf-8?B?U0ZBMXRXa25JaDFPdUc2dURISi80OUdTWTdUdmdEaWVCTkRnTlpoSXE2d2hP?=
 =?utf-8?B?VjgrUUczOG1ZV1dsMnRsNGNvaXQ5NjNuZVBkVGRsakhTdlJnaHpRSXd4VTdn?=
 =?utf-8?B?NnA3VTk5STYwaEtlS2VFQndRWXFDSjRHQ09lVTBiVXRSSy9MQzJOdDZZTGFv?=
 =?utf-8?B?R29MUXJoSGVVVkpHUDZ4UVdhRTBWaU0vL0RvWjFlZ25UaVJPTS9JV0FYRzRR?=
 =?utf-8?B?MmhDazZWYk81ajZpMmhxOUZ5WWd6NVZjcG15V0F1WlFzZ3NVRTdUdjNLdlda?=
 =?utf-8?B?VXJ2SWRmVThiYytmNHQzSEluejFhSDJJTk9BdGJTMWZEZFYxU1lTOVBoZUZY?=
 =?utf-8?B?ZGRsT1JwM1Zuc3hxbVZEWHJTR1dqSy9UY3k5N2pVODFmOTJiUmkya2pKeE1x?=
 =?utf-8?B?dEs4S2RMM2RROC93SmtmWnEyL0VKdkRCN2tEV2dMVThmNHhxQ0ZIbE4zYy9m?=
 =?utf-8?B?dUJXZnVOUlVBR29ya3hRTU43c3lhQzZNTkRlOVhyMVR6bktRR0pNV3RqSFg0?=
 =?utf-8?B?bDdvV3pDQ0d3RnN3ZHFjajM4d3V6ZFEzejNudUFURWVUZ0RFeSt6elRQbnd5?=
 =?utf-8?B?cjJRMHluend1emxGdmJvQW5Md0d2VWJ1eCtYM1QweDJveVJVdnFvaXhxYjVj?=
 =?utf-8?B?VFZiNFN1Yk5yYWJycnJsdndoUFhZMmQ3WTY2eVdjUUxxaUJ6VDJHcVNZTy8z?=
 =?utf-8?B?a0RpMFNVaVMxdVprcFZ6cEt2TEhkZ3Z4TENEU00xaXl5VXpCOTUyb3pWQm1I?=
 =?utf-8?B?NDF6TGpCazFOVnJzK1hneW11a2NxeXRpNGUrSG1zVFB0SnR0REZIeEJaN3dr?=
 =?utf-8?B?TGdiSmlWdWdPczNkTS94L2wyeFJMdDRXeHVEWWZWd0JmMkUxZm1MOVNQM0Yr?=
 =?utf-8?B?dXM1dUlWc0xaRTE2VEtzb3ZGS3BKcDY5NWFTSGdOd3FWSjFZRHVjZVpJOXMx?=
 =?utf-8?B?eDBHWml0UUdpYllOdUJLa0IrNW9JVEd6Q1hEcjdMOVlPQ2hpSDRvRjg1ZzlM?=
 =?utf-8?B?TSt0aGl1bUN2aVk1ZDdIdlU5ajk5cEJwQXh3UGNCMmxKUFRhS1VXdUV1akVv?=
 =?utf-8?B?U0F6OVNZd2M4YlVLU2NLSUR2RW5Cb0NlZlR3dFpaWXkxZE5za0hXejlsTkFz?=
 =?utf-8?B?QzN0MnJSZ3dYVkxXZFJEeFMxK1RVdUdRYzdoQlVuVXNJZkdyTE1udHVNcjRX?=
 =?utf-8?B?eEJUVFNKL1E3dkJLSFdqQ2dqcC9OMHViYk9OODhnUXZ0a0RTZHk3VGNyV1hT?=
 =?utf-8?B?VU93dUp5QjdDd0lYMHNUdDhuZkl5ZndWSXFFbmJhaytBUVVYMyt3b0tGQjlJ?=
 =?utf-8?B?c3BHZ1lsVzcrbC9YNmc4WlJOOXdWcjZmRlRkRjYwVXROb29qTnJjb0ZWdzFm?=
 =?utf-8?B?OU9mdnhYUHJheDg5N0laUm9NL21RMXhzTGVMSjZuV3Q1V09Xb3pKaVRBNWRt?=
 =?utf-8?B?SlBjWHdEaEhqMWJSWVpFOFByM1BseHdNaVphOUFVZ3R3WXZmR1lra1VMek1q?=
 =?utf-8?B?L3RuTnkydHlVSUd6MHBJNlZrY3V3SnVqeEtQZThremFrQnEyZjJhaVBZR1ZU?=
 =?utf-8?B?czIydksrRnAzOWlscTY3bVdWV3NPaE1raDA1MkRtZ3dCTWtiQ2pXTWVNYXd0?=
 =?utf-8?B?SlhiVVJYMDB4czREeDMrVVdTRWFRUXFEeUsydFJZTENiUVAxU3ZsejVNZWhM?=
 =?utf-8?B?SUJ1R2ZvMGI1Qk9EVGRncDhKSnVMSEcyOEk5Ry9SWmRmeW16eEQzR0lMV0Iw?=
 =?utf-8?B?WnhnUVcvNUt2N2ltaDdEdkVZdGNUNnBWeDhENzdrRyszUHJHb0tDTk1XaTkr?=
 =?utf-8?B?THEweHovc2RBQlU4OE9ZdGFCSjZZZ2tMSHBGa0E4WWtPbUNObmtaR3lLYmZv?=
 =?utf-8?B?YnVjOEwycVUxSTA4anRwMFJ2NG82OFd1Q2MrNjY0bVN1ekowRXFrMTZsRkFF?=
 =?utf-8?B?ZnFyVVJWZ3BGdExGdXVZS3BCYUFXbDJ5NmQ5RnpTb1BNL0g3c01velVVckJa?=
 =?utf-8?B?VWdITWpiSG1YOXhGNlN0NkF6WUxybDF3QmM1V2VuUjQvU1d6aVlxUlg0d0xO?=
 =?utf-8?B?TTBub3NTNFJSdEFoeWxIcE5teFR6R2V1NW43aE0yMUYyZTlRYlJJWkhxaDhI?=
 =?utf-8?B?NVhUd0NrSzR4VldFa3M4Y2VCWUJzVmx4NHJibmcvNk8zdzJ3a0VtNkxWSlhI?=
 =?utf-8?B?VEgxbDVncHFzRHVnd1ZvZlB0dGtES08xTm52TEJOTGhmQktjdTlSUHBNSXhD?=
 =?utf-8?Q?/12qGFLgdDCpKuwxY+?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 68999f74-ea2c-4f55-7b04-08df17880e64
X-MS-Exchange-CrossTenant-AuthSource: IA0PR12MB8374.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 21 Sep 2026 02:28:43.5155
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: OZdHaUt++c9nz5/HVRpHY5KPMR7jbQ0N69irpZzecq35IjgulXpvNVM1c4cy0jzb
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SJ1PR12MB6097

PG_private and PagePrivate() are no longer used. Adjust related comments
and documentations to refer to page/folio->private instead.

hugetlbfs_reserv.rst is outdated and left unchanged. It should be
rewritten.

Assisted-by: LLM
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
Acked-by: David Hildenbrand (Arm) <david@kernel.org>
Signed-off-by: Zi Yan <ziy@nvidia.com>
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
index d9392ac8dff9f..262d1de5c1161 100644
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

