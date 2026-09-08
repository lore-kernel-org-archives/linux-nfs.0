Received: from SA9PR02CU001.outbound.protection.outlook.com (mail-southcentralusazon11013007.outbound.protection.outlook.com [40.93.196.7])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F3EBE310784;
	Tue,  8 Sep 2026 02:57:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=40.93.196.7
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788836223; cv=fail; b=qu9FCLlJAzft4fdU+auoA8zZnSAZNNwA2lAQYLB0rEdf4VKqqMj23PqYWhHYrEBayRGSRB/5fAFlyZwowErtXRaKiZszOnJoEik20wFtkae0mwFj5+AEUrIkHyf8D/6XM/DeHQywp0wnxxTFvjnjscObxor1xPS/vwPTfhHCtdo=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788836223; c=relaxed/simple;
	bh=6bVD/tWpMJr7AWa1GQ8VlnzLtkamUSNn7ZsbpO7IKDQ=;
	h=From:Date:Subject:Content-Type:Message-Id:References:In-Reply-To:
	 To:Cc:MIME-Version; b=Pb1YZjyU/NgtS3uxvPPXSuLkrRuQTsAGqQaGJNzdmcM4LkELOhTwatAJzgPzdaiZQlq/+jAiI/wpYZf6kqv+/bBuTDRP13z0Qzio5a9TSMWPx/sKaXgRAZcz92NJ9Kx02I12E6MywEM1nFbGeIBAerTXtQXQqU2Dnv41kYpZMWc=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=PcKUBEiD; arc=fail smtp.client-ip=40.93.196.7
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="PcKUBEiD"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=Z4DCwRtdebX3tZzxjcC20KEcIxNjNMVezt08YCk1jEOgZVWrnZQXjgFvbgLBdvWH+tm7DXqOkR592Bt2D5fXEUbtBm2uLq0nNgTlbP/y9N5s77d4K1PubAXphQ54ODZsdvxbALQcUr1zo2Nwkaijx3GduQOyy8jKzNxj37UXCXP8oEDEtLBosBTwbGQxrOJvaT3qkV0PDYfo8lvNsZdEyQ/vomXuq6JqvIoTbgnYAUNrOGEoJ68l5IxE0WQx+1hSlGm17lxbSw58k0LQ6SUjUpSp4xbZ7rfgWJYVfMfJmBkp/WA/YxUbS0BWXRJJnQqfBfBbTgjJiYleo2w6ZXHrMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=4BaZCdTyCzuu2wqDL8UKDP5UuKagpSTbQvdL4j66OCE=;
 b=tm5+nTOWCK0LbryGTNu+uk9AMLl8sc9E581lsRClw/8V8Dgt/xhd9W8tk1fIcyptchfua+yGjfZiP0IHWApldCovB6LldvhT538zTl+hUmjHZcGC6sad0foMcMGHudop5tWKHKANAJtgjNxQv+vkirBtTd7q9kRRIFnZloQKDB3dSMhZ+sv4MjndGbB3pAAKOc7+qNwGKjag1eUOluzhxtedNJM4I93zTMmnax59klcwsQQbOPZac/DCV/ygv+NpC9qOmxwjOwgVhu4ROKGvISQJVkdHLzwMYb6ex20CPXhKR0sle26d2kwe7Vg8z/3N9QJVOjoIxrlWDfgdOiU+YA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=4BaZCdTyCzuu2wqDL8UKDP5UuKagpSTbQvdL4j66OCE=;
 b=PcKUBEiD/U7puGOr4+rANXlri1PiiDMIKdizJbVz9ejCyWfcukAZctrXfozJyHWBTF4BxUK6LaZ2HJzrAtI2KajRNLySWLtTBJYGxRyzoRcGDC9Y80BHLHkGhTBuvuZAwhk6XLu8ZFIT9utWDyF+JwmSG5/vLyOV1gM3iFPERZI+RJDqDUE8ZgDQRG5yFwFPqT91NeX6R4yf6SU+XI/XS1NfcHYH/SQ+lQypePJOFU+x2wGqmSmlB8tUCFCRwegzboo5nTtuGVvcMbn6p8o2ZUveAqMKCgsqrik0fNGnNTAIc0ImLx9UFXHID8RbI0162xlEwSvpbST2IPljvRIL0Q==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from IA0PR12MB8374.namprd12.prod.outlook.com (2603:10b6:208:40e::7)
 by DM6PR12MB4435.namprd12.prod.outlook.com (2603:10b6:5:2a6::23) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.382.15; Tue, 8 Sep
 2026 02:56:43 +0000
Received: from IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16]) by IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16%5]) with mapi id 15.21.0382.014; Tue, 8 Sep 2026
 02:56:42 +0000
From: Zi Yan <ziy@nvidia.com>
Date: Mon, 07 Sep 2026 22:56:18 -0400
Subject: [PATCH v3 11/14] treewide: remove folio_set/clear_private()
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260907-remove-pg_private-v3-11-6ae22f9d9272@nvidia.com>
References: <20260907-remove-pg_private-v3-0-6ae22f9d9272@nvidia.com>
In-Reply-To: <20260907-remove-pg_private-v3-0-6ae22f9d9272@nvidia.com>
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
 Zi Yan <ziy@nvidia.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Jan Kara <jack@suse.cz>, 
 Matthew Brost <matthew.brost@intel.com>, 
 Joshua Hahn <joshua.hahnjy@gmail.com>, Rakie Kim <rakie.kim@sk.com>, 
 Byungchul Park <byungchul@sk.com>, linux-nfs@vger.kernel.org, 
 linux-fsdevel@vger.kernel.org
X-Mailer: b4 0.15.2
X-ClientProxiedBy: DS7P221CA0039.NAMP221.PROD.OUTLOOK.COM (2603:10b6:8:25e::7)
 To IA0PR12MB8374.namprd12.prod.outlook.com (2603:10b6:208:40e::7)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: IA0PR12MB8374:EE_|DM6PR12MB4435:EE_
X-MS-Office365-Filtering-Correlation-Id: f7ba3392-5856-426e-1fa2-08df0d54cff6
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|376014|7416014|366016|23010399003|1800799024|921020|10067099003|56012099006|11063799006|22082099003|18002099003;
X-Microsoft-Antispam-Message-Info:
	UTwsJVOH9XV2eWuVNaYuVV5JnmqojkfhKtVkA/Yaj72+bjuriXgNDSbcq6TwRk3+6ph7VJxM8u4yhY371UiHn3XYA/i8/rjCQPZilDjMGNlU/XoIaBKwx2+FSI14WoxjkbSx6vl103azVjsjiBiiHmV4scHAuCHAb/Q0lQSrD9PLaO7LkwU62SkRLhRtySu0JK28C3JiQAGcgf4cliXhcO8DVa6j5k/V3+GxNHjzgC7brKwAY8HHRUtO5N8bsgOyAg7Wca9u2jQtgpSUGlicoXPD3duMOMzb8IhrF7XQ5zWkAKAkimveToRao0ti4jEIKABEtmF42HJu+Kh+7xQ4Qi/OObKKmUxF8gZk2X8a4bpzIbtUhgXjhzmBLvg8JV424AvfS/7PM1UiFb56zSxvW9Zd7PuJtSnrTPX7Sq27ZkJX818w118vtsaxaeNJuOK0cBV+4Px53c7powym7cPTefEh13TXvDvZMfkxP7gkpHq/aFjR6KFCvbMLlGvx/A6Mr2k7JXASAtYiY5adcCJvytjhDY/bjIPVHsZAxkz18XM5vhsEgYHBtUQQ5P2okClbNlAqUabnH2DAy5rYgbhwFAYPkiRyU7tPs/YktwYDa8h7O8HKk7v3qK1Lvio/QY86VxqKXxu1hXRAX2lV1HWWxqnLrG6s0NdIev5NaKU5BBFy4kAoLpc2h1RTXfdXtl33zk1gRqgMKDoy9113iiNtlQ==
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA0PR12MB8374.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(376014)(7416014)(366016)(23010399003)(1800799024)(921020)(10067099003)(56012099006)(11063799006)(22082099003)(18002099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?utf-8?B?blc3YUl6K2NnamhvU2JHZGcyNnllbkJNdXRrOXpHNS9JeDJoZW4yeGJZNFRr?=
 =?utf-8?B?azZzT2NPLzNnb1BOTkNROFNvcVFxT1VRVE5CemNDZUhuUmR6TThFRXRsbXVO?=
 =?utf-8?B?d0thdUFneHQvc2lnV3FnVTJ0MkROQ25UVFd6eDlVaHVZVEJyTDl4OVBqWXhQ?=
 =?utf-8?B?ZWVrdVBEOGlvbExVSzFEbEkxN2VUWnJIK0g5MHdBUENRdUhHbFd3cEN3VUZL?=
 =?utf-8?B?S0tyZm5JOHZYV1N4TFRMeG5tbXkvcjhkM1h1QUNjbU5PdEdpY2dnQ0p2N3FG?=
 =?utf-8?B?ZThPT0VxM05xcFV2b0dhaCtkY2pnM24yUGx6M2tqbkpZOFBDMCtKc0R0UCtF?=
 =?utf-8?B?NHIxZSt3QzBGdW1kT0x2R2p3MnBKQVB5cnQ1bjNIL2s4dDFra3RsdUNibmdL?=
 =?utf-8?B?UVF1aXIyUE54cHBWeGZJRGFMQU1naXgzK3hxK3JaQmlkeHUxU2lrcFZEVFpK?=
 =?utf-8?B?eVlBODg3d0hGeE9CSXhJYkZKV3BOSDVTOWFXc0sxci81UVlXVzlCYjVHRlhN?=
 =?utf-8?B?eVVST0ZDL3AyU3l4Y2trYUNpU0o3dlhSWlorZ3ROckdUREZwRlErK2NXN1lO?=
 =?utf-8?B?WmNSWHdqclp6MHBDQjlDNTV5MDNWZGtXWVBTSFVzZFRGT0ZwT3Mwai9RMjlQ?=
 =?utf-8?B?aEExL1dYZTFYc1dRWTJtQ3BoSTZHaXY5TC80WVdKd3NreEFMbEhOZ3p2YW1E?=
 =?utf-8?B?N3Q0d2RyZUV4MlczQ0pwbWZ6UFdydlg5emV3OE1PZGE0Q01QWWVvUE1OMTd3?=
 =?utf-8?B?QkhEMHVCS1llZXBlRUhJcUY3S0FEakw1a2hwcmMwTjhpeU14eE1ZMmNiWXdq?=
 =?utf-8?B?M3d4U0M2Z3hYOXZXZGJ0eVEvTWJ3UEwwYk5zZzFPVFZ4SW9mOVdvcXhwalR4?=
 =?utf-8?B?TjZlMUpkVnFoSzF5RGxodXRDNXN6cHU0S1psWWxwSkxEaFk2TjgzTkNTZ0VN?=
 =?utf-8?B?UWtlWTlLNm1iclJnQ2FLcFYvTGRRV1BhZ2tUWDB6VERleFo4YVRJSTczRmVG?=
 =?utf-8?B?MVNiT0xYN293dG1tSi9qMUpLRDJmT1MwUXd2MUR5cUNXQUFUYldpVjFaSUpD?=
 =?utf-8?B?U3YwS0pDRTBWdnBkVnRQQzdoNEhwYUxZaVJYOVNic2Z5ZHdKTmhyNE5md3dw?=
 =?utf-8?B?TG8zYzZ5b2ZwUEdOcG5BN2owYzlRRTM5SkYxRnJLZEpxb0luQnNzb2lKTGox?=
 =?utf-8?B?Skl0UCtYUHphS2VIUkZaZ2VNWExzOGViRS9hNjU4YlhtaXdPUU42SjhOSngv?=
 =?utf-8?B?ZHZZOUt1MHhzczZvQTJ2L09uRWo3RCt6UmlabXVLNXdxTW1aaTZYeGFUL3Bt?=
 =?utf-8?B?NDliUllDNjA3eDY4REhoWERaeVA4RnJ5Ui9nY1dJSWh2U1V5amZOUDYyeTh1?=
 =?utf-8?B?Mi9raXJzSFl1Vlo2WVI1TWZmRlRZSHVHcEhtdG5RQlFMeXBDNFc1OVkrZWV2?=
 =?utf-8?B?dWJUTnd2TTNGemJNaFB3RHFxRWFIWmQySTZ3UENkNUFuUk5yWmxoRFZ6eTlj?=
 =?utf-8?B?VjZlMEt4NFc4QSs0bStkR3YvOW9WUWduVlVjRGU0VDIzU2lucGZjUUxTV2Ex?=
 =?utf-8?B?Q1BCRDdiNGJTK3ExS0srb2U0d2s5a1JFclpkRlFIb1JkWlVRSUdPMHhrenQ1?=
 =?utf-8?B?andURHVZQmcwUzB4S0R4VEJ4Q1NURGFIZCtLaGh2ZHUvaDNtSFI4b01kSzBB?=
 =?utf-8?B?N04zT0pBaUxKNDY5enhFZTJ0MmVtN2QrekZES0FCMSs1NWJHeGZLZXI2QXZP?=
 =?utf-8?B?Mk1aTm1RZ3laT3BPSXArbzU0UkczdHhHVmlDeTg5VTRiVldhNG5XdmVNNi9O?=
 =?utf-8?B?S0NxSkdjNG5QNVF3OW53dXBONlFoT1hlSkZ0RnFSMStWd2V2azJyUnB1dHRk?=
 =?utf-8?B?cjRxOG5uUTZGVnEvbVhkbzhnV24zMFpBUC9GWkpRVTViYjh2Kzh5cks4UTJU?=
 =?utf-8?B?TzV2bmRvamNpbnBiMlhRdW16VWRkNll0VmJ3VmwyVWJSYmhmTCtJVDk5cmI1?=
 =?utf-8?B?dC9kQjUwWE53L3ozM3ZxdnJrZmc0Y3d1N2g1blR5c2xzaTM1dllESllmRHp4?=
 =?utf-8?B?TGF2TGE0TXlxTGVVSTFVUXg0VU82cFdxcmpLRGVSZDNMZEN5MU1Rczhja2oy?=
 =?utf-8?B?bVVUdlFOZDhDUjRydWdWNDBQZmlaQlBORllocWcvTW9ia2dSb0k3bkY5cGo1?=
 =?utf-8?B?RmNxblorNHFIZ0h5QWltNm1oSTYyQzcyNUVuTVNhamhkbnI3QU4vODJjQ0RU?=
 =?utf-8?B?c0VWVDZGZjZ2NUFlMmVkOEorK2J5MHpvMXF6aE5Jb2M4Tk1qQlZETWo4aFJI?=
 =?utf-8?Q?CLU28p+tnzmFY57NaF?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f7ba3392-5856-426e-1fa2-08df0d54cff6
X-MS-Exchange-CrossTenant-AuthSource: IA0PR12MB8374.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 08 Sep 2026 02:56:42.8273
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: AGXmY5Lxyni30sjpZNlc7hExINGeWP7KoJM/Hf95xa4cTSjzYF+TeGjV7qQH3tAZ
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR12MB4435

They are no-ops now. Remove them.

Assisted-by: Claude:claude-opus-4-8
Assisted-by: Codex:gpt-5
Signed-off-by: Zi Yan <ziy@nvidia.com>
To: Trond Myklebust <trondmy@kernel.org>
To: Anna Schumaker <anna@kernel.org>
To: "Matthew Wilcox (Oracle)" <willy@infradead.org>
To: Jan Kara <jack@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>
To: David Hildenbrand <david@kernel.org>
Cc: Zi Yan <ziy@nvidia.com>
Cc: Matthew Brost <matthew.brost@intel.com>
Cc: Joshua Hahn <joshua.hahnjy@gmail.com>
Cc: Rakie Kim <rakie.kim@sk.com>
Cc: Byungchul Park <byungchul@sk.com>
Cc: Gregory Price <gourry@gourry.net>
Cc: Ying Huang <ying.huang@linux.alibaba.com>
Cc: Alistair Popple <apopple@nvidia.com>
Cc: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 fs/nfs/write.c          | 2 --
 include/linux/pagemap.h | 4 +---
 mm/migrate.c            | 1 -
 3 files changed, 1 insertion(+), 6 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 623e7ef1f73d5..b6967b5286691 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -717,7 +717,6 @@ static void nfs_inode_add_request(struct nfs_page *req)
 	nfs_lock_request(req);
 	spin_lock(&mapping->i_private_lock);
 	set_bit(PG_MAPPED, &req->wb_flags);
-	folio_set_private(folio);
 	folio->private = req;
 	spin_unlock(&mapping->i_private_lock);
 	atomic_long_inc(&nfsi->nrequests);
@@ -745,7 +744,6 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 
 			spin_lock(&mapping->i_private_lock);
 			folio->private = NULL;
-			folio_clear_private(folio);
 			clear_bit(PG_MAPPED, &req->wb_head->wb_flags);
 			spin_unlock(&mapping->i_private_lock);
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 2257df004305e..cc5c2cca814bc 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -594,7 +594,6 @@ static inline void folio_attach_private(struct folio *folio, void *data)
 {
 	folio_get(folio);
 	folio->private = data;
-	folio_set_private(folio);
 }
 
 /**
@@ -629,9 +628,8 @@ static inline void *folio_detach_private(struct folio *folio)
 {
 	void *data = folio_get_private(folio);
 
-	if (!folio_test_private(folio))
+	if (!data)
 		return NULL;
-	folio_clear_private(folio);
 	folio->private = NULL;
 	folio_put(folio);
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 2e133d533c8da..77b89d0909f1f 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -835,7 +835,6 @@ void folio_migrate_flags(struct folio *newfolio, struct folio *folio)
 	 */
 	if (folio_test_swapcache(folio))
 		folio_clear_swapcache(folio);
-	folio_clear_private(folio);
 
 	/* page->private contains hugetlb specific flags */
 	if (!folio_test_hugetlb(folio))

-- 
2.53.0

