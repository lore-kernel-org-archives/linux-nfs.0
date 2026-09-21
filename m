Received: from SN4PR0501CU005.outbound.protection.outlook.com (mail-southcentralusazon11011015.outbound.protection.outlook.com [40.93.194.15])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8FB5E344D88;
	Mon, 21 Sep 2026 02:28:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=40.93.194.15
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789957729; cv=fail; b=HziJ8msRWq0lV27C+vsmgSjG18V4Q53XhjkZ+zcWeHr101D6sP0/v+A8XAR0dKS6b4LZRVzMcT7Vr27XaHIDJWqFgrqFxwHSphC7mNlm9vEj8WVwguob6np9PFY5Rxv3Acc1xNnHSFkyGyeAoe0PCM5tbezSxMoC3q9DzyCwlbY=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789957729; c=relaxed/simple;
	bh=SqRQvZmOoOsQmY27s0Ol0Xec3p7fygf4FypSBNyKyGY=;
	h=From:Date:Subject:Content-Type:Message-Id:References:In-Reply-To:
	 To:Cc:MIME-Version; b=j5CbKkJfqAGSJa+A4kK6gX7HKL+23Q36NRx/6sq3ceKF3araFayceXshCHvuxE/sH/tcnUQ9ublecnQCccaYs5HmM1ELTF+r/wv4qgLI07v2vHOW+ypxO39O68VJIRMW94lDcwaaY9WqrDRHtgmcRdIpnfij38m+V0IhMtwmM/w=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com; spf=fail smtp.mailfrom=nvidia.com; dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b=gYAq5oUu; arc=fail smtp.client-ip=40.93.194.15
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=nvidia.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nvidia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=Nvidia.com header.i=@Nvidia.com header.b="gYAq5oUu"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=oB+wHi9seeFz8ImexI1xoth6n8AiUel626z3Ltvbbr84iqrQuMvDFfEGrCRlgB8ce+y0I1pAt1MOktiwEi/5aeScvvmYf7emQ698HFruw3xtImBXZut3kw9mzqn9BlurTrBbMz92TjPii5KyaCaBqvOdrheVhN81txbal/uT9MmpFKgiK5qI6OSarxMUFbxhyTC8FZY+w6X37UDoelPli3BCCSmE0aXnjPur16JoJ8VAJ9Zvzrk0ivP3LxXHUTSA8RBlQQhWO0+V63G4OGXBeHaXeTvqpuDSxpV0iKSK7oH4heZmfoOyhoQ3BWAWk6GwI5FDW899shk86t5bqSAc2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=Pxl8REd7pjZ/pxg+5RJBiZwMjGvhapxp0OyAm4Ema5Q=;
 b=cnDMoAvOVCD/Zs7QOcpNLtERIebf6mlq8JIXjo1+7H0qsSLnaRWY03RRIk8mmEdfLiCM2Xq0gTKFgMznvbT7WQR6k7MRR4NhhaWD5OXGuRK+Cj/uehHP9BUN6Olj374eX4R1IGyHstex9/yPjKxwhd0T3WE88t/TF+BwDj1UaTRdVkV5y22JVYnskzdpBRKfRHQkxg+PH9jjwe+k+Bl3vY9WgvpyxX4Q2Kp0SD2GkZ2vvQPuPqVPGguGD5YZ3Oi+duobwGzztgB8oty5Ep1HyLG0XsdX/z+RLzWEZXvIjlPn7LRvHXSsBbuo+fEgiXE+TBlwT9j5ZqNaR3h0LP/VHA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=nvidia.com; dmarc=pass action=none header.from=nvidia.com;
 dkim=pass header.d=nvidia.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Nvidia.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Pxl8REd7pjZ/pxg+5RJBiZwMjGvhapxp0OyAm4Ema5Q=;
 b=gYAq5oUu2gxLN6Z1XQeCmu3pfJlpVa/u08Qdm12QDGwm7os3Sh2lJ2vDkKqYDzUAg6/oGaD5WO8ndpX6XH1PLioyt79AP9BKzGv8Yd6CIxwjAiog8Jv3Ml1zje39ZFiHH8pJjcLf0zGkldjS5zm7grfJGgG0WTJdGU2FkmM/MVSQsq27eM7zhfEUBlxnG1iGxyabGboA1OmV/n68FyclKme1dbrsJTK8ZR00hdRxAnag1lQGuf/L6qs33DBXLiV6dYrsKX9/gEzyI/QNR04s5O04FPZpaI1FmKmkOdTil1Ky3PBtCPJIpetqWolkgiLtnv8Z/skxT3t0mhATRTvhrQ==
Authentication-Results: dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=nvidia.com;
Received: from IA0PR12MB8374.namprd12.prod.outlook.com (2603:10b6:208:40e::7)
 by DM4PR12MB7719.namprd12.prod.outlook.com (2603:10b6:8:101::13) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.428.16; Mon, 21 Sep
 2026 02:28:36 +0000
Received: from IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16]) by IA0PR12MB8374.namprd12.prod.outlook.com
 ([fe80::d85f:4c87:ae84:3f16%6]) with mapi id 15.21.0428.014; Mon, 21 Sep 2026
 02:28:36 +0000
From: Zi Yan <ziy@nvidia.com>
Date: Sun, 20 Sep 2026 22:28:07 -0400
Subject: [PATCH v5 11/17] treewide: remove folio_set/clear_private() usage
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260920-remove-pg_private-v5-11-bb68b6a21869@nvidia.com>
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
 Zi Yan <ziy@nvidia.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Jan Kara <jack@suse.cz>, 
 Matthew Brost <matthew.brost@intel.com>, 
 Joshua Hahn <joshua.hahnjy@gmail.com>, Rakie Kim <rakie.kim@sk.com>, 
 Byungchul Park <byungchul@sk.com>, linux-nfs@vger.kernel.org, 
 linux-fsdevel@vger.kernel.org
X-Mailer: b4 0.16.0
X-ClientProxiedBy: YQBPR0101CA0184.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c01:f::27) To IA0PR12MB8374.namprd12.prod.outlook.com
 (2603:10b6:208:40e::7)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: IA0PR12MB8374:EE_|DM4PR12MB7719:EE_
X-MS-Office365-Filtering-Correlation-Id: 82f64fae-83d2-4850-ed32-08df178809d8
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|1800799024|376014|7416014|23010399003|366016|921020|10067099003|56012099006|11063799006|22082099003|18002099003;
X-Microsoft-Antispam-Message-Info:
	xoUJ97aMxh2RIKe5uUm2PKK0IzHvTsvDTcvmgGDWr7AMvx6Kh93LtMp8efmHMbEj7Oht7ehD09cdnK8HSyGjqEK52LPGs0bkODBb8+xk9zrR5n/ilmVfC1BFV0XOgORqC7eXtrReofzWOlIm+2c22RNHDD55276NKAN9uOnkzWBa98jgZGiDmdXFygqaciPZuYxiQATKue23/BS/tWl35OxyKDa+nicdCRAmtkA6Bx03kWkoTMH9AQ2SQxmgM2Oo2L6l/b6uzN4s4bgdtV9xL7m2dj5334YEyfkgBSnIfMl7CHDBmuWBz5wDhLJSZILXo7rxLyxDIh+fVpvC43CHsNdCS+0M7WTkg6wB3c56W4Ju0iKYXP36keTqE2GujB+bb5ZVT74IKvhZjfuQ1GKXhtaybVxttI5WJ1hpEZlZojI0ItXM9xmMGEdQSBB4bdwTaFaW7Lwv/vXAWeRP+LXnUAlLV0PtXZgESLg6o0LSiT3GIs5lTmE3DPU4yHaTkbVw3+x5Z6L7hCadqsDwh2iSSdvQ87K0kN8+dpgbvG1QtLMl5xqV7p7R8zF4cxrqVdeZBGXhrzm1UqIINaUmc9tNPYmDqCH87VtHOUUaVzl7agir39hGLklJGxlptBYkZSpywDsl5ckd/LFJt4dktuY/+1LwMe0pcBmGAgOkKNdjXT9Pi7dJXTfUnU9BdyAjvROUv38AbLK/oKb2zijgB3lrUg==
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:IA0PR12MB8374.namprd12.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(1800799024)(376014)(7416014)(23010399003)(366016)(921020)(10067099003)(56012099006)(11063799006)(22082099003)(18002099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?utf-8?B?MXNPYkU4NWJTNGV3MVE1bXd6OStzZE54b0pHZk9COXVFUFZ3dk14YjZsL1BH?=
 =?utf-8?B?Yzk3T2FtVSs3cXMrTDd6ZEVibHNmZS92TzZYOGxVUEdsQ0JZY2dKcUpiV2pP?=
 =?utf-8?B?N0I3S3JwY2JlUmV6amROdGZGemlpalAvb1I0NEdNNGlTeFJ0eis4QUZkQzBQ?=
 =?utf-8?B?QkszNHBQRU8rNlNXSlFHdGNCQjNucnRwdzFxbml6WVN1M2h4REJBU1V1cS9Q?=
 =?utf-8?B?eXJiNHowdUJkQ3N1L09TbFgyTjgzaHNWZmhqUzNyVHFWOFFMVUVqdGhJcHMv?=
 =?utf-8?B?T2dUR1N0anU1NzVUNUpZYjZ3eDBmejluM1NxRUhBck5lNTJWbG5FSURmNWt3?=
 =?utf-8?B?RmR3Nk5RbnZidXYwRGpxcWdiVzgyMTFpb2wyVDdNUUdHQXA0TFdTNzEyTEdV?=
 =?utf-8?B?Mk0rNnhvellUZjJNUGFCYVkwZ1hhSmRSL2plYUZkRk1nRkUxTGEzVHBiQW5Z?=
 =?utf-8?B?eElxaFpPUU1nWkxtbjRTWVQreGJJRUFxMDQwZmVORU5zbXVrQ24xMXFqbFlN?=
 =?utf-8?B?NXoxbVo1aEdBdXQ5NTRNVTkwUktYMmdrdmFSdllnQVRYRHB1RkJ1U3pyV09n?=
 =?utf-8?B?Ymp5SkJoeFF5a012ZXJLMnFnMC9xTGEyZDJ5a2VMa0x5RTQzQjNFZXdQc004?=
 =?utf-8?B?aGV0REtDRHhzT1FkejA0bzVPRERneXMwbFc4TFBMYmxpYzdsbSt1Tzg2YThv?=
 =?utf-8?B?M0lhb1BHdGNvbFhSNEM2VUZFVE5QdzE4Y0U4ZEVBemFWU0ZyUWlaci8zdm5W?=
 =?utf-8?B?QndjaUVKYVNvWXZWd2g5NjFDSmpGalMwU0grMVZFTWRIT1IrdHFZZmJKb08v?=
 =?utf-8?B?Zy9VeCtWY1BiRGlHMjlETFpIL05MZHBwRkJsZ2NsdTV4Zis5ZWk0R1BJczJq?=
 =?utf-8?B?K1ErUW5GSGtBZjEzMzBKNU5tVklScjFNZjVVa3hYQ204UG1nUnlBaDFtSEJq?=
 =?utf-8?B?SkxrVEh5SlNKbjd1UHpnQTJ1eCtiUVBpQi9Fb0NrRW01NThOZVhreTF6bWhs?=
 =?utf-8?B?djI0ZWl5SWlXVzcrV0J5UEVGekdVd0JwNGZBN2xnaTFNUi9vUlA3aWxsMnFI?=
 =?utf-8?B?TTBidUNaWXg5WWZGZW9NL3pZRXc2bWhjUHIxUXV5YnBydVhUZ0JVbjZ0dzBn?=
 =?utf-8?B?VlM0NjhPU0xieE9ZYVhpZGVTeXVUNkFuajVkcTFrbWtXdHVGZTRVRzdTTGZm?=
 =?utf-8?B?QkNNVXhFc2s1WWE3NVZsLytuY0s2SDVjSkcwM29iZ0RHcjBLa1c4YW41VUNO?=
 =?utf-8?B?UUV4UDFaamxvTVR3VmFwMXdyZHZMeTl2TUJUc1hFMEZxMDI4Ui9PeWZidkpR?=
 =?utf-8?B?TEZtaFI1dkdxSHRCQVk3cGVvWGVXVU5yNk40b0VMa2p3akVkTWZQbU9KSEVH?=
 =?utf-8?B?Z0k4bTZFaDVrdDl3Vi85SVZ6Y2JRQncxUU1TZDU2a1ZxU3JBOWhXRUM2OWVn?=
 =?utf-8?B?T0VGcncrb2JqN25qb0R0V0ZrY2RTRDJCeXkzTkc4STFZWkk4Nk55TVNtOTV6?=
 =?utf-8?B?MEtmV05XdDR6Tm5mc2E4TGgyVFlSaThRZUs3cTMwSGMrdVJqR3ZEemJTVlgx?=
 =?utf-8?B?NDd4bjBrL1U4VjBsMlhIYjBmVUVCcEdZdDBKUzl3QU9RcWg5SmwvaG9MZHBm?=
 =?utf-8?B?RHpaWHFqNWJ0TjdLSDBTZ0pUS0RHM05ENDF5SVI5cU9qWDQ1bGFMZmlSYmc0?=
 =?utf-8?B?L3dnQ2twME9zQ2JES2xubTRJUWsvWGlFVHJwMWtUSG9BZEJmQWJJVFhnNDBy?=
 =?utf-8?B?SE9MRnN4Mk9uN2tmaU5LMWRxS2pBNkY4dXBSTVBHZU5YN0RCUHZPcm14U09U?=
 =?utf-8?B?UmJ3c2lOUi85WEFRbjlQTVNoOEZ2TUZvNmlocitrYllRMXhmdURhZjFDdEhV?=
 =?utf-8?B?dm5UM091SytIU3dLVGNvWVhycWdaT3gva01OR09RbTBQVTE1MVRqQXJVUU5r?=
 =?utf-8?B?ZCtuRzhIQlNpSEUwd1dXWmV4ZFhYMUdTb1A1N2RTU0JzMDlrUm5wZXhDeVNN?=
 =?utf-8?B?UFFJMzUyY0Z6Z3BpQnVsNTd6djVpSk0ydVN6K0MxOFB4UFZTVVdWemRNS1pu?=
 =?utf-8?B?WC9SSnVLOWszYmdWeUpSak9sS20vUnNoRmJ6MW9DUU9CaXI2Y0NiUG5WSGFj?=
 =?utf-8?B?Tm8zWTVmd1lwUDF2Lzd5YmJKUHBRYlpVZXdRc253MjJHVnNpYnRMY1lIdWYz?=
 =?utf-8?B?ZHVzbTlTcndtU0UySWRHZW43MkhUaURRVmtGdzI0dHVhMEp1eXBaYlZwRG13?=
 =?utf-8?B?VlBkWFBJcURuZjFSWVM0dXhxeXFQYXFubCtOWUxNN05HanhpR0xCSHEydjF0?=
 =?utf-8?Q?V0mfDhb1og4q58h0T1?=
X-OriginatorOrg: Nvidia.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 82f64fae-83d2-4850-ed32-08df178809d8
X-MS-Exchange-CrossTenant-AuthSource: IA0PR12MB8374.namprd12.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 21 Sep 2026 02:28:35.9243
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 43083d15-7273-40c1-b7db-39efd9ccc17a
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: b83UN34jkDAO4XkRsQUZ16SBpo6aWrfBosnW7a/Qx7jFhwsx7eyNWV5TxxsER0Vd
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM4PR12MB7719

They are no-ops now. Remove them.

Assisted-by: LLM
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
Acked-by: David Hildenbrand (Arm) <david@kernel.org>
Signed-off-by: Zi Yan <ziy@nvidia.com>
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
index 1e3462357aaa4..bcbb0afe1a681 100644
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
index b7b92925a28c3..7e3a81f069744 100644
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

