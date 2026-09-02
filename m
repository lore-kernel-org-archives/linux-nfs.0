Received: from BL2PR02CU003.outbound.protection.outlook.com (mail-eastusazon11011058.outbound.protection.outlook.com [52.101.52.58])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E530948095E;
	Wed,  2 Sep 2026 10:54:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.52.58
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788346468; cv=fail; b=igrohRed+b8B5gMucrQ/DGC0aAi9S4MO8kCqMfvSmARD1+f1DJKvfl//udbBKf1klq+SnpqZI9oKjdLmXtV7AhFA6ZDU2260y8fzK6rUa36n3AN5QJRHNE01yixhiLBO9J30zUNvP0sM2Sbm78Z0FGhPR8CN8HpIzziCniJkjYY=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788346468; c=relaxed/simple;
	bh=u2F2xCkZE0q+qmMOCPw9IxCNywUjEYGF+hTf65vZiD4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-ID:References:
	 In-Reply-To:To:CC; b=PazNxDS2hzqQNKGw9rkqYL1aO102ffODV+5t+fn1Gb6zx3dV7iRQWkDVBlfhgfcCBl3SGUkGjbnlhXaFsQ9bskASQgtWKlGotu1sD4q0nAkseVH7hlXFIGKvZJmVVsuy8LJ9FMlHFUJmLVX1gcXYUTnKX/1vmtZi7ixKfsOexRM=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amd.com; spf=fail smtp.mailfrom=amd.com; dkim=pass (1024-bit key) header.d=amd.com header.i=@amd.com header.b=2U+Lt/VU; arc=fail smtp.client-ip=52.101.52.58
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amd.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=amd.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=amd.com header.i=@amd.com header.b="2U+Lt/VU"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=V0WuO4dSMOu2i53smEJzpy9iM8sKFQ/JbW27a8CdRDRMNr/XKUnYNdYptpEnDPkuZspMeOHTzgaDuhT0S1n7QeVnDx5/nk//I51l1WBQQNQvb8uD3yd4pvpMxstKRtSGeFlrXG1UcwMkOBitnkeCZtSrKxYd628wOIkM5HLSmcIKQibwHwmyqdvS2V2LannUqIF08Yl2FcJYMaLTggN/Vqt7pL5XBbrvmL8BJVB2O1wgSjK8jqIYFFd3sLLMy2hm+sd5Ur0TvxhhNsY8JpU8AiLrn5/YFVjZGL+TLA2IHPdFDi63XiZeDZ5oF9a7fyvvTDRzkJEC0/mDm6ehKV99Rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=Tdz5xv3kSUOFgxN7OQPUeQ34gulDFo6FUym0A+A2cuk=;
 b=ktpfbSFkKjrc4muC0XllgBtX3fGPIzomntQB052F3NWNQ93xS0gQFBtSxkMvWy3j6Lj8Q6UZPpeh+A7dh5XzhDw1gNFyzNh9hww1reWLsjGV2Tcv9FbSwXyCFZwMn3HqdJoRMkCqqAeUxC6hRlLCwnIVu5ShkvDTqina9xjN8qSzqZlJIqy0Stpo741PsoEmxhrmxG5m3H/Wf03gHaDnOSlvVckpZoib9CAYGf6DzcJlUhiTI99+5cxWP2cTgqVqKozQ/Ghca5M1guncOQ4AsSpFeKxrJT41xqK3CBnp3Qyn5fj85e4bN9ZaybQQU2YPH5uPu+FMwI7CcM5vw2LAFA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass (sender ip is
 165.204.84.17) smtp.rcpttodomain=sk.com smtp.mailfrom=amd.com; dmarc=pass
 (p=quarantine sp=quarantine pct=100) action=none header.from=amd.com;
 dkim=none (message not signed); arc=none (0)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=amd.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Tdz5xv3kSUOFgxN7OQPUeQ34gulDFo6FUym0A+A2cuk=;
 b=2U+Lt/VUY3odyMW62j/k6Bd76vtcxf8fnmnJOT/YIYnxiQwjytxYyQU0wg8jMspXxks0wXAEl8CcEAsSBExuz0sJw2HCSfFUsTB3mevkN4sf47tLhvYq5aTNHZ3RV52MXiVH1GVdunIAejVoPAGXHBvAkuAR/Ctr/szAjl+Y0IU=
Received: from BN0PR08CA0027.namprd08.prod.outlook.com (2603:10b6:408:142::25)
 by DS7PR12MB5840.namprd12.prod.outlook.com (2603:10b6:8:7b::10) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.360.13; Wed, 2 Sep
 2026 10:54:20 +0000
Received: from BN5PEPF00046987.namprd02.prod.outlook.com
 (2603:10b6:408:142:cafe::6f) by BN0PR08CA0027.outlook.office365.com
 (2603:10b6:408:142::25) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.382.10 via Frontend Transport; Wed, 2
 Sep 2026 10:54:20 +0000
X-MS-Exchange-Authentication-Results: spf=pass (sender IP is 165.204.84.17)
 smtp.mailfrom=amd.com; dkim=none (message not signed)
 header.d=none;dmarc=pass action=none header.from=amd.com;
Received-SPF: Pass (protection.outlook.com: domain of amd.com designates
 165.204.84.17 as permitted sender) receiver=protection.outlook.com;
 client-ip=165.204.84.17; helo=satlexmb07.amd.com; pr=C
Received: from satlexmb07.amd.com (165.204.84.17) by
 BN5PEPF00046987.mail.protection.outlook.com (10.167.245.36) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.21.382.8 via Frontend Transport; Wed, 2 Sep 2026 10:54:20 +0000
Received: from [127.0.1.1] (10.180.168.240) by satlexmb07.amd.com
 (10.181.42.216) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.46; Wed, 2 Sep
 2026 05:54:06 -0500
From: Shivank Garg <shivankg@amd.com>
Date: Wed, 2 Sep 2026 10:52:21 +0000
Subject: [PATCH RFC 07/11] mm/migrate: add migrate_lru_folios() entry point
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-ID: <20260902-migrate-refactor-shivank-v1-7-9dcca87669c4@amd.com>
References: <20260902-migrate-refactor-shivank-v1-0-9dcca87669c4@amd.com>
In-Reply-To: <20260902-migrate-refactor-shivank-v1-0-9dcca87669c4@amd.com>
To: Andrew Morton <akpm@linux-foundation.org>, David Hildenbrand
	<david@kernel.org>, Zi Yan <ziy@nvidia.com>, Matthew Brost
	<matthew.brost@intel.com>, Joshua Hahn <joshua.hahnjy@gmail.com>, Rakie Kim
	<rakie.kim@sk.com>, Byungchul Park <byungchul@sk.com>, Gregory Price
	<gourry@gourry.net>, Ying Huang <ying.huang@linux.alibaba.com>, "Alistair
 Popple" <apopple@nvidia.com>, Vlastimil Babka <vbabka@kernel.org>, "Suren
 Baghdasaryan" <surenb@google.com>, Michal Hocko <mhocko@suse.com>, "Brendan
 Jackman" <brendan.jackman@linux.dev>, Johannes Weiner <hannes@cmpxchg.org>,
	"SJ Park" <sj@kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>, John Hubbard
	<jhubbard@nvidia.com>, Peter Xu <peterx@redhat.com>, Miaohe Lin
	<linmiaohe@huawei.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>, "Oscar
 Salvador" <osalvador@suse.de>, Kairui Song <kasong@tencent.com>, Qi Zheng
	<qi.zheng@linux.dev>, Shakeel Butt <shakeel.butt@linux.dev>, Barry Song
	<baohua@kernel.org>, Axel Rasmussen <axelrasmussen@google.com>, Yuanchu Xie
	<yuanchu@google.com>, Wei Xu <weixugc@google.com>, Lorenzo Stoakes
	<ljs@kernel.org>, "Matthew Wilcox (Oracle)" <willy@infradead.org>, Jan Kara
	<jack@suse.cz>, Jonathan Corbet <corbet@lwn.net>, Shuah Khan
	<skhan@linuxfoundation.org>, Randy Dunlap <rdunlap@infradead.org>, "Alexander
 Viro" <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>,
	Benjamin LaHaise <bcrl@kvack.org>, Chris Mason <clm@fb.com>, David Sterba
	<dsterba@suse.com>, Muchun Song <muchun.song@linux.dev>, Dave Kleikamp
	<shaggy@kernel.org>, Trond Myklebust <trondmy@kernel.org>, Anna Schumaker
	<anna@kernel.org>, Mike Rapoport <rppt@kernel.org>, Sean Christopherson
	<seanjc@google.com>, Paolo Bonzini <pbonzini@redhat.com>, Bharata B Rao
	<bharata@amd.com>, David Rientjes <rientjes@google.com>, "Yiannis
 Nikolakopoulos" <yiannis@zptcorp.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<damon@lists.linux.dev>, <linux-cxl@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<linux-aio@kvack.org>, <linux-btrfs@vger.kernel.org>,
	<jfs-discussion@lists.sourceforge.net>, <linux-nfs@vger.kernel.org>,
	<kvm@vger.kernel.org>, Shivank Garg <shivankg@amd.com>
X-Mailer: b4 0.15-dev-47d62
X-Developer-Signature: v=1; a=ed25519-sha256; t=1788346348; l=5305;
 i=shivankg@amd.com; s=20260518; h=from:subject:message-id;
 bh=u2F2xCkZE0q+qmMOCPw9IxCNywUjEYGF+hTf65vZiD4=;
 b=zqyQvwcNEi60YOe3AxACpfKEgwGmV73sSQzkEJMafgIW3N0CXpY2388d84qsUylEeGLAFlZUM
 cEsPDSIVPOTAuwHu2AWobA6LL5zUqJp1pgclWiK6rwE6Dw0s3MUzb1W
X-Developer-Key: i=shivankg@amd.com; a=ed25519;
 pk=2l2QGTeXuGkZTtfmx0nPQU8iFZfjYmX/ymMojitevx4=
X-ClientProxiedBy: satlexmb08.amd.com (10.181.42.217) To satlexmb07.amd.com
 (10.181.42.216)
X-EOPAttributedMessage: 0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: BN5PEPF00046987:EE_|DS7PR12MB5840:EE_
X-MS-Office365-Filtering-Correlation-Id: 74e23bd3-ff60-47b7-34d0-08df08e08ae8
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|23010399003|36860700016|82310400026|1800799024|7416014|376014|921020|56012099006|10067099003|11063799006|22082099003|18002099003;
X-Microsoft-Antispam-Message-Info:
	k8b/OHNwOl28Wf4jqbJs24GBLk2c6/IftKlUZE4XPiQQOqkSUyaoLlL9sB9rbaPN4LXxpzO6J6vkAOoTkKMFGBCKfoBudDS+t4vt2Jzaa5FF0rL6JcdKX3t/tYgFz+7drolHVVuB82HTQdB0c5aRxcyqUp9gsC9xayC6ep5z03gLq4z1cIwlwzDxG6rEnL+Ra8MzeqAqTv2NNFlaw6mehBJaF6ajlPqB1sYwBwS6uLKmHSEzPg1ZmVZfn0gTqIdK49oDTHVT3TXk6znOXkpA6JIHsRqIl+EbBZsv2pQyKODY220WLk5tst4DrTUS8bhFOGBuAXQ1N4wZ/hfcaRDj6ZMiPZoBD68pFADYU5H0w6sGFZKF6tNtDLqwqG+Pi7BKsHOMqXhJK4y3YU8kBtuDrv+XNjjTYnB8/BtlDJge+TLPwKE3Tr743d7rSpTsQBMqVYQmjQwKvHNdjMpWwwBaNohBv7YJXgrE9lAx998lJU/JEhpBWuFspwl+VB4wd7C89eVwy5q5u2GJpCb32PQurt9LcFRZ6uPD/YX3vAavMFv+W78mP8aLZiuZG1m0+jiXK2sVSI+lv4dn6Dj8UYC+aahwLD0Tl/EhEzNsIXlwW9XJs7NBEJKkMU1gmKRawh2FKPjABJFbX0C0kNuxkCrFYH/1OCmMeCFy/RBZEa+mW4uRHFVVaIwetzEZaiG3c7uhebls5FNEeJ82Jdtwd7YHSscE5KUdt4yO4LZ3w8+ajtK3Z9oRz+FOZKWCnLcf7MXg
X-Forefront-Antispam-Report:
	CIP:165.204.84.17;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:satlexmb07.amd.com;PTR:InfoDomainNonexistent;CAT:NONE;SFS:(13230040)(23010399003)(36860700016)(82310400026)(1800799024)(7416014)(376014)(921020)(56012099006)(10067099003)(11063799006)(22082099003)(18002099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	0/r4dlIPGtuXD4B2ND+NmRl6NVufQQwZ8kJAFjMu3+hfl0abn5qt16LYADGUBLlb8FvK3O9KWKE0vUvHEsu7RqDrkq/hBT9a2SzspGsWkUCJSKe654c8MZGa/xvlzTHDHaA/sLBKnkw68v50Rl6Evf0Svc3hgxLWbi7pCk/pewqTzgLiWYegCZn4t70PdE7fUqEBOuSIZvsxbmBwAU48ltEGe7IHA22cwi36uFM1Pr7/ooAqWxPj4gBxini9Ueic/SavG5qtgz+72pl1y89WUzNWafrxFOVfwEwGClrACh0QZ01BQy+6nmB/BMdy1gJKVAeUktTJdsbklXQ5S45l/lpxU6wrwiJWtu4drdbc1lkrM7fTp9wixhybqKGWHT4ZpwuWXqfVGbODnlShBpkyGWHRcPTzX5OekonYvc1jAkynihu7+WYLD3MOlDKSJGrX
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 02 Sep 2026 10:54:20.5638
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 74e23bd3-ff60-47b7-34d0-08df08e08ae8
X-MS-Exchange-CrossTenant-Id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=3dd8961f-e488-4e60-8e11-a82d994e183d;Ip=[165.204.84.17];Helo=[satlexmb07.amd.com]
X-MS-Exchange-CrossTenant-AuthSource:
	BN5PEPF00046987.namprd02.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DS7PR12MB5840

migrate_pages() currently handles the asynchronous and synchronous LRU
paths separately and retries split folios itself.

Move this logic into migrate_lru_folios(), leaving migrate_pages() to
dispatch hugetlb, movable_ops, and LRU folios through their respective
entry points.

Keep the existing retry and accounting behavior unchanged.

Signed-off-by: Shivank Garg <shivankg@amd.com>
---
 mm/migrate.c | 70 ++++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 40 insertions(+), 30 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 163f13344fd2..d39149cbd43d 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2182,20 +2182,34 @@ static int migrate_folios_batch(struct list_head *from,
 	return rc;
 }
 
-static int migrate_pages_sync(struct list_head *from, new_folio_t get_new_folio,
+/*
+ * Migrate LRU folios.  MIGRATE_ASYNC processes a batch directly.  The
+ * other modes first make a short asynchronous pass, then retry each remaining
+ * folio separately in the requested mode.
+ */
+static int migrate_lru_folios(struct list_head *from, new_folio_t get_new_folio,
 		free_folio_t put_new_folio, unsigned long private,
 		enum migrate_mode mode, enum migrate_reason reason,
-		struct list_head *ret_folios, struct list_head *split_folios,
+		struct list_head *ret_folios,
 		struct migrate_pages_stats *stats)
 {
 	int rc, nr_failed = 0;
 	LIST_HEAD(folios);
+	LIST_HEAD(split_folios);
 	struct migrate_pages_stats astats;
 
+	if (mode == MIGRATE_ASYNC) {
+		rc = migrate_folios_batch(from, get_new_folio, put_new_folio,
+				private, mode, reason, ret_folios,
+				&split_folios, stats,
+				NR_MAX_MIGRATE_PAGES_RETRY);
+		goto out;
+	}
+
 	memset(&astats, 0, sizeof(astats));
 	/* Try to migrate in batch with MIGRATE_ASYNC mode firstly */
 	rc = migrate_folios_batch(from, get_new_folio, put_new_folio, private,
-			MIGRATE_ASYNC, reason, &folios, split_folios, &astats,
+			MIGRATE_ASYNC, reason, &folios, &split_folios, &astats,
 			NR_MAX_MIGRATE_ASYNC_RETRY);
 	stats->nr_succeeded += astats.nr_succeeded;
 	stats->nr_thp_succeeded += astats.nr_thp_succeeded;
@@ -2205,7 +2219,7 @@ static int migrate_pages_sync(struct list_head *from, new_folio_t get_new_folio,
 		stats->nr_failed_pages += astats.nr_failed_pages;
 		stats->nr_thp_failed += astats.nr_thp_failed;
 		list_splice_tail(&folios, ret_folios);
-		return rc;
+		goto out;
 	}
 	stats->nr_thp_failed += astats.nr_thp_split;
 	/*
@@ -2222,15 +2236,31 @@ static int migrate_pages_sync(struct list_head *from, new_folio_t get_new_folio,
 	while (!list_empty(from)) {
 		list_move(from->next, &folios);
 		rc = migrate_folios_batch(&folios, get_new_folio, put_new_folio,
-				private, mode, reason, ret_folios, split_folios,
-				stats, NR_MAX_MIGRATE_SYNC_RETRY);
+				private, mode, reason, ret_folios,
+				&split_folios, stats,
+				NR_MAX_MIGRATE_SYNC_RETRY);
 		list_splice_tail_init(&folios, ret_folios);
 		if (rc < 0)
-			return rc;
+			goto out;
 		nr_failed += rc;
 	}
+	rc = nr_failed;
+out:
+	if (rc < 0) {
+		list_splice_tail(&split_folios, ret_folios);
+	} else if (!list_empty(&split_folios)) {
+		/*
+		 * Folios split along the way get one asynchronous attempt at
+		 * their new order.  Their failure is not counted: the large
+		 * folio they came from was already counted as one failure.
+		 */
+		migrate_folios_batch(&split_folios, get_new_folio, put_new_folio,
+				private, MIGRATE_ASYNC, reason, ret_folios,
+				NULL, stats, 1);
+		list_splice_tail_init(&split_folios, ret_folios);
+	}
 
-	return nr_failed;
+	return rc;
 }
 
 /*
@@ -2268,7 +2298,6 @@ int migrate_pages(struct list_head *from, new_folio_t get_new_folio,
 	struct folio *folio, *folio2;
 	LIST_HEAD(folios);
 	LIST_HEAD(ret_folios);
-	LIST_HEAD(split_folios);
 	struct migrate_pages_stats stats;
 
 	trace_mm_migrate_pages_start(mode, reason);
@@ -2300,32 +2329,13 @@ int migrate_pages(struct list_head *from, new_folio_t get_new_folio,
 		list_cut_before(&folios, from, &folio2->lru);
 	else
 		list_splice_init(from, &folios);
-	if (mode == MIGRATE_ASYNC)
-		rc = migrate_folios_batch(&folios, get_new_folio, put_new_folio,
-				private, mode, reason, &ret_folios,
-				&split_folios, &stats,
-				NR_MAX_MIGRATE_PAGES_RETRY);
-	else
-		rc = migrate_pages_sync(&folios, get_new_folio, put_new_folio,
-				private, mode, reason, &ret_folios,
-				&split_folios, &stats);
+	rc = migrate_lru_folios(&folios, get_new_folio, put_new_folio,
+			private, mode, reason, &ret_folios, &stats);
 	list_splice_tail_init(&folios, &ret_folios);
 	if (rc < 0) {
 		rc_gather = rc;
-		list_splice_tail(&split_folios, &ret_folios);
 		goto out;
 	}
-	if (!list_empty(&split_folios)) {
-		/*
-		 * Failure isn't counted since all split folios of a large folio
-		 * is counted as 1 failure already.  And, we only try to migrate
-		 * with minimal effort, force MIGRATE_ASYNC mode and retry once.
-		 */
-		migrate_folios_batch(&split_folios, get_new_folio,
-				put_new_folio, private, MIGRATE_ASYNC, reason,
-				&ret_folios, NULL, &stats, 1);
-		list_splice_tail_init(&split_folios, &ret_folios);
-	}
 	rc_gather += rc;
 	if (!list_empty(from))
 		goto again;

-- 
2.43.0

