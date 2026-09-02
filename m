Received: from BL2PR02CU003.outbound.protection.outlook.com (mail-eastusazon11011032.outbound.protection.outlook.com [52.101.52.32])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E111447D945;
	Wed,  2 Sep 2026 10:54:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.52.32
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788346458; cv=fail; b=XyGWPVj/4GTfzEzylhX1lvUfCfrRfkNNSMxhhykqdpJKDfLjizN5kf5qSMjS7gUl+/0UYIA3QxeZ7GQQbluCuRdJbU7hDkRKYE0cnPaOhIpLUhWGy/3xhmWLg6kYwUqT+3xkWcr3I/Msgi7iXJsH42uUSzwHZGjW53ovfMOLN3I=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788346458; c=relaxed/simple;
	bh=RI02LIU5Xi5+P6WIx4/tIFhoYu3m0iIqrPm3yd4Pync=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-ID:References:
	 In-Reply-To:To:CC; b=X+q3HC96KPGdF6jn9LhEEa6c5tbEUULW+wa0Vx+2Gsfr6ZeSUi80gWNZa7iJY6R8jxvr+yEpym7Yds7bDziIiLW58plEHuRuXGhD1aEbOJD2t3BcMUbTIRCiYkUoLa5ZgotA6W/Yx9mlbgj8OlSa0J9BWRR5abaa5/T16wrLUHc=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amd.com; spf=fail smtp.mailfrom=amd.com; dkim=pass (1024-bit key) header.d=amd.com header.i=@amd.com header.b=KJVsKZmq; arc=fail smtp.client-ip=52.101.52.32
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amd.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=amd.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=amd.com header.i=@amd.com header.b="KJVsKZmq"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=Kd4rbzA4h2ohuWRDSW2ETZ1bg3pTm2JvmOEkAG9pABPCERKQ0My2sxtnurkYOKUMC/V58tEleKU6JdjzDi7Lqja5JrlZe2ISdqI4rJC5Jp8yUU9+Ucq0+KmyXU0GId5XWEhcnJxISPvh6pkUXT6QF9ql+E6FBIYFZlqY0wy2EiTDGFfrCHE0eDBLgSE9gSqfAz2RoVjM9yYLUzoiG+zqwydQ152XcYNBohSAmnvOcJKA+IX13TBy11HH2RnyJTMcSJthy/bpCJOu5gapOu2W/RdnfpqZrCgBzwz2O6TWxtLa2AbAnscuGhfB1WK9tPFXkU/t2haaeN06Eus4Viw4vQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=UvMQi60+FK1dsYsCkrpCg0bZwxaBYKJwFTlW/+3nxs0=;
 b=hGcURAFlDFaN67O54aplpIIF2V8bOYNbkUN2dHEIedJYXrERwedeH+k5JyHQhzPLZJswVw53+KX0eIwaGMsMuntWX7lF6qlIqQZgYX6+KvTNNZmF2ZWZH6YPxDDDJw7H5D7EQ9gUOXlt6GBMMCFelVjoMqUzU57lsMbE7q26FtMbSGTv9dix5bou2Vxq2GZU8JDrYh2UWL/XTMxBvpfAnF4A9J6HLHgFTMsrZx7CkF8F13URoRgaGGsCRh9vlvBad6uxT0/fVmMKqwD3h0Ed4/bnALf0GONlVddH/Y5KTcjeYBhI5HP8AYpQeqdgxWSfYC3/Ix/zIUOfNZw5gfbXzQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass (sender ip is
 165.204.84.17) smtp.rcpttodomain=sk.com smtp.mailfrom=amd.com; dmarc=pass
 (p=quarantine sp=quarantine pct=100) action=none header.from=amd.com;
 dkim=none (message not signed); arc=none (0)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=amd.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=UvMQi60+FK1dsYsCkrpCg0bZwxaBYKJwFTlW/+3nxs0=;
 b=KJVsKZmqWyvBnly57LP8j92xJ1D5zHt4BKzxOwl9fOlqSmy1hNJYzVvgLp2+Ruupr8purDFcBNFDMaR1Wgg4nJiUP/NbsG8yvknF63XyksfPSojvLNwdwP1YDzZpVRS4puPpsMncFHeeM8gm7NopXPjrMUGb7DYcV4/oZ4xwRN0=
Received: from BN9P222CA0028.NAMP222.PROD.OUTLOOK.COM (2603:10b6:408:10c::33)
 by DM4PR12MB6206.namprd12.prod.outlook.com (2603:10b6:8:a7::6) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.21.360.8; Wed, 2 Sep 2026 10:53:53 +0000
Received: from BN5PEPF00046988.namprd02.prod.outlook.com
 (2603:10b6:408:10c:cafe::24) by BN9P222CA0028.outlook.office365.com
 (2603:10b6:408:10c::33) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.382.11 via Frontend Transport; Wed, 2
 Sep 2026 10:53:53 +0000
X-MS-Exchange-Authentication-Results: spf=pass (sender IP is 165.204.84.17)
 smtp.mailfrom=amd.com; dkim=none (message not signed)
 header.d=none;dmarc=pass action=none header.from=amd.com;
Received-SPF: Pass (protection.outlook.com: domain of amd.com designates
 165.204.84.17 as permitted sender) receiver=protection.outlook.com;
 client-ip=165.204.84.17; helo=satlexmb07.amd.com; pr=C
Received: from satlexmb07.amd.com (165.204.84.17) by
 BN5PEPF00046988.mail.protection.outlook.com (10.167.245.37) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.21.382.8 via Frontend Transport; Wed, 2 Sep 2026 10:53:52 +0000
Received: from [127.0.1.1] (10.180.168.240) by satlexmb07.amd.com
 (10.181.42.216) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.46; Wed, 2 Sep
 2026 05:53:38 -0500
From: Shivank Garg <shivankg@amd.com>
Date: Wed, 2 Sep 2026 10:52:19 +0000
Subject: [PATCH RFC 05/11] mm/migrate: add a dedicated movable_ops
 migration pass
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-ID: <20260902-migrate-refactor-shivank-v1-5-9dcca87669c4@amd.com>
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
X-Developer-Signature: v=1; a=ed25519-sha256; t=1788346348; l=7549;
 i=shivankg@amd.com; s=20260518; h=from:subject:message-id;
 bh=RI02LIU5Xi5+P6WIx4/tIFhoYu3m0iIqrPm3yd4Pync=;
 b=RgY8vSnVIPQsmK943ISVn6MTBagX09K5oB348FwCOtuM9MSJH0KouONPqM5xSgCuB6HKJbT1g
 GGA6rUEJZdGC5n7GadcCcNT3I8f8fzzWx31E3cImzeyhxTKOIRGl7om
X-Developer-Key: i=shivankg@amd.com; a=ed25519;
 pk=2l2QGTeXuGkZTtfmx0nPQU8iFZfjYmX/ymMojitevx4=
X-ClientProxiedBy: satlexmb08.amd.com (10.181.42.217) To satlexmb07.amd.com
 (10.181.42.216)
X-EOPAttributedMessage: 0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: BN5PEPF00046988:EE_|DM4PR12MB6206:EE_
X-MS-Office365-Filtering-Correlation-Id: f937f727-3c07-4d69-c0d4-08df08e07a6c
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|82310400026|23010399003|36860700016|1800799024|7416014|376014|921020|11063799006|10067099003|56012099006|18002099003|22082099003;
X-Microsoft-Antispam-Message-Info:
	JLmKwFcWA2ODtF1rJV7WikYZo/kj67e0p+yiPjpjzLaJapqNvdztWQ+yzjtrw/gfORv4JynGHzkHF5ZwYc5Vqqkb5b6ndJkCfo36mJGRhhfWbzWH/dsSTeaY0vFKCoVX5xSNJ6ABR44zmYxVOB7AX5kVvZwtrloZ5p3we3ibf/yqC1fNr/NQtcCAMsezzQu2PYif0hORmbiheiZgbXEx15TI9rFm4z+yXnpQse5ol0C2wmiObA/Ufl3aeow6ZjYK13PAfcEr7Mm+fpGONYnjYujB9hh2IRjNQzFYjrkpP50iEeX7Uo5gliok01KnsyIQ5oQGIS3ZLFYkw/mJEIfzdl4Qm0f11XB02I2BCz2baJ5FFSwM+C5bB0OjAqrMfMOKdD26k2FdiOCEs3G/b26hXnE68yjOneWHuoPpaboYvmHrfkzGkH+xgjGYXED81/TRcCfvnYJ6ZwRHNlOteZ0YwigC7yVWxnZK8ecN/1Rxk25tn7e9nX1ioW+EBbtvBLnr2aX1HX4O4mNAEvHV9nvkgyBKkREQqAwBiLxXb9BBzpAgMvQOFHTAW/Yxcs82Nq47TlMN2Jh0mwloAhcHpnxTVysP5fcdJNh6JT3epZC40rDhWgDNQlyZQzZD8/x8cOrLmTbc3cYPpbE4by6USDAqgC/b20FVVN8OK1aClYaoLbNeQnC9BbHFjTBVXHIxZayc9gymAj6RQ/fgEC0U5W9JipimTxTQLUODlDLe/VKikgJdlBaVZuuGxypYiQztQCZz
X-Forefront-Antispam-Report:
	CIP:165.204.84.17;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:satlexmb07.amd.com;PTR:InfoDomainNonexistent;CAT:NONE;SFS:(13230040)(82310400026)(23010399003)(36860700016)(1800799024)(7416014)(376014)(921020)(11063799006)(10067099003)(56012099006)(18002099003)(22082099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	Rzl/PSo5863amWDCOMMJnDej+UR52MhjzYogGUotGK0/LH2WoUNcTUs+7bUhxxz1nBBoaT+gdjjDRKf5OuC0aZBOfxuDslKHZeq5wQnh8vRAqKIDHqH4zJSAqKnaB9XlSMtPEZNP+V41oRil74Kili9bCKXcL5I0LnRSDNMfNAJlSIOwNuikrRA66dGjOTshGSoe6IaDNvpuNAzgaMfD+vMzvXFK9dd9Q1vzWLGl3/mOvjmHGESREMtmMRWxChRaRddEglpb7sQ03/I1P41ShT8ZgGxtqr2+zvg610mU4mz31f3y/Kck06a1uJyjXcA7JhUnuqQURaZz9Vi402uVPDwaPRjdc4PVWyzw9xzZhnUmnKBOGYgwhAHN7K5OGakuOU6gml6EMMv8vsPt7ccoeYfGhiJ7uopCHaPXLkDEuHeO+7OnJsCr1jnvU98luc1T
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 02 Sep 2026 10:53:52.9141
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: f937f727-3c07-4d69-c0d4-08df08e07a6c
X-MS-Exchange-CrossTenant-Id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=3dd8961f-e488-4e60-8e11-a82d994e183d;Ip=[165.204.84.17];Helo=[satlexmb07.amd.com]
X-MS-Exchange-CrossTenant-AuthSource:
	BN5PEPF00046988.namprd02.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM4PR12MB6206

Pages with movable_ops transfer ownership through a driver callback and do
not need the unmap, TLB flush, copy, or LRU handling used for LRU folios.
These pages are expected to stop being represented as folios. Separating
their migration from the LRU folio path prepares for that conversion.

Add migrate_movable_ops_pages() before LRU folio migration to handle
allocation, locking, retries, and cleanup on a separate list. Return
remaining pages through @ret_folios and remove the now-unreachable
movable_ops branches from the LRU path.

This changes three details of movable_ops migration:
 - Pages are processed before LRU folios rather than in source-list order.
 - Synchronous callers use the requested mode from the first attempt
   instead of the LRU asynchronous pre-pass.
 - A callback returning -EAGAIN ends the current attempt, so a later
   retry allocates a fresh destination.
 - MIGRATE_SYNC_LIGHT waits for the page lock instead of giving up,
   because !uptodate check is not applicable for movable_ops
   pages.

Suggested-by: Zi Yan <ziy@nvidia.com>
Suggested-by: David Hildenbrand (Arm) <david@kernel.org>
Signed-off-by: Shivank Garg <shivankg@amd.com>
---
 mm/migrate.c | 156 +++++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 140 insertions(+), 16 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 7a136cec275f..55f352efdf2b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1200,7 +1200,7 @@ static void migrate_folio_undo_dst(struct folio *dst, bool locked,
 static void migrate_folio_done(struct folio *src,
 			       enum migrate_reason reason)
 {
-	if (likely(!page_has_movable_ops(&src->page)) && reason != MR_DEMOTION)
+	if (reason != MR_DEMOTION)
 		mod_node_page_state(folio_pgdat(src), NR_ISOLATED_ANON +
 				    folio_is_file_lru(src), -folio_nr_pages(src));
 
@@ -1309,11 +1309,6 @@ static int migrate_folio_unmap(new_folio_t get_new_folio,
 		goto out;
 	dst_locked = true;
 
-	if (unlikely(page_has_movable_ops(&src->page))) {
-		__migrate_folio_record(dst, old_folio_state, anon_vma);
-		return 0;
-	}
-
 	/*
 	 * Corner case handling:
 	 * 1. When a new swap-cache page is read into, it is added to the LRU
@@ -1376,13 +1371,6 @@ static int migrate_folio_move(free_folio_t put_new_folio, unsigned long private,
 	prev = dst->lru.prev;
 	list_del(&dst->lru);
 
-	if (unlikely(page_has_movable_ops(&src->page))) {
-		rc = migrate_movable_ops_page(&dst->page, &src->page, mode);
-		if (rc)
-			goto out;
-		goto out_unlock_both;
-	}
-
 	if (folio_order(src) > 1 &&
 	    !data_race(list_empty(&src->_deferred_list))) {
 		src_deferred_split = true;
@@ -1418,7 +1406,6 @@ static int migrate_folio_move(free_folio_t put_new_folio, unsigned long private,
 	if (old_folio_state & FOLIO_WAS_MAPPED)
 		remove_migration_ptes(src, dst, 0);
 
-out_unlock_both:
 	folio_unlock(dst);
 	folio_set_owner_migrate_reason(dst, reason);
 	/*
@@ -1816,6 +1803,135 @@ static void migrate_folios_undo(struct list_head *src_folios,
 	}
 }
 
+/*
+ * Migrate one isolated movable_ops page. Keep @src on its list for retry and
+ * move it to @ret_folios on permanent failure.
+ *
+ * Return 0 on success or a negative error.
+ */
+static int move_movable_ops_page(struct folio *src,
+		new_folio_t get_new_folio, free_folio_t put_new_folio,
+		unsigned long private, enum migrate_mode mode,
+		enum migrate_reason reason, struct list_head *ret_folios)
+{
+	struct folio *dst;
+	int rc = -EAGAIN;
+
+	dst = get_new_folio(src, private);
+	if (!dst)
+		return -ENOMEM;
+
+	if (!folio_trylock(src)) {
+		if (mode == MIGRATE_ASYNC)
+			goto out_put_dst;
+		if (current->flags & PF_MEMALLOC)
+			goto out_put_dst;
+		folio_lock(src);
+	}
+
+	if (unlikely(!folio_trylock(dst)))
+		goto out_unlock_src;
+
+	rc = migrate_movable_ops_page(&dst->page, &src->page, mode);
+	folio_unlock(dst);
+	if (rc)
+		goto out_unlock_src;
+
+	folio_set_owner_migrate_reason(dst, reason);
+	/* Drop migration's reference after transferring ownership to dst. */
+	folio_put(dst);
+
+	list_del(&src->lru);
+	folio_unlock(src);
+
+	if (reason != MR_MEMORY_FAILURE)
+		folio_put(src);
+
+	return 0;
+
+out_unlock_src:
+	folio_unlock(src);
+out_put_dst:
+	if (put_new_folio)
+		put_new_folio(dst, private);
+	else
+		folio_put(dst);
+
+	if (rc != -EAGAIN)
+		list_move_tail(&src->lru, ret_folios);
+
+	return rc;
+}
+
+/*
+ * Move movable_ops pages from @from to a local list and try to migrate each
+ * page up to NR_MAX_MIGRATE_PAGES_RETRY times. Any remaining pages are moved
+ * to @ret_folios.
+ *
+ * Return the number of failed pages, or a negative error.
+ */
+static int migrate_movable_ops_pages(struct list_head *from,
+		new_folio_t get_new_folio, free_folio_t put_new_folio,
+		unsigned long private, enum migrate_mode mode,
+		enum migrate_reason reason, struct migrate_pages_stats *stats,
+		struct list_head *ret_folios)
+{
+	int retry = 1;
+	int nr_failed = 0;
+	int pass;
+	struct folio *folio, *folio2;
+	int rc, ret;
+	LIST_HEAD(movable_ops_pages);
+
+	list_for_each_entry_safe(folio, folio2, from, lru)
+		if (page_has_movable_ops(&folio->page))
+			list_move_tail(&folio->lru, &movable_ops_pages);
+
+	for (pass = 0; pass < NR_MAX_MIGRATE_PAGES_RETRY && retry; pass++) {
+		retry = 0;
+
+		list_for_each_entry_safe(folio, folio2, &movable_ops_pages, lru) {
+			cond_resched();
+
+			rc = move_movable_ops_page(folio, get_new_folio,
+						   put_new_folio, private,
+						   mode, reason, ret_folios);
+			switch (rc) {
+			case -ENOMEM:
+				/* Count this page and those awaiting retry. */
+				nr_failed += 1 + retry;
+				ret = -ENOMEM;
+				goto out;
+			case -EAGAIN:
+				retry++;
+				break;
+			case 0:
+				stats->nr_succeeded++;
+				break;
+			default:
+				nr_failed++;
+				break;
+			}
+		}
+	}
+	/* Count pages that exhausted the retry limit. */
+	nr_failed += retry;
+	ret = nr_failed;
+out:
+	/* movable_ops pages are order-0, so one failed page each. */
+	stats->nr_failed_pages += nr_failed;
+	list_splice_tail(&movable_ops_pages, ret_folios);
+
+	return ret;
+}
+
+/*
+ * Split a large folio after destination allocation fails and queue the resulting
+ * folios on @split_folios.
+ *
+ * Return: 0 on success, -EAGAIN to retry splitting later, or -ENOMEM to stop the
+ * unmap phase.
+ */
 static int migrate_folio_split_on_alloc_fail(struct folio *folio,
 		struct list_head *split_folios, enum migrate_mode mode,
 		enum migrate_reason reason, struct migrate_pages_stats *stats)
@@ -1940,8 +2056,7 @@ static int migrate_folios_unmap(struct list_head *from,
 			 * If we are holding the last folio reference, the folio
 			 * was freed from under us, so just drop our reference.
 			 */
-			if (likely(!page_has_movable_ops(&folio->page)) &&
-			    folio_ref_count(folio) == 1) {
+			if (folio_ref_count(folio) == 1) {
 				folio_clear_active(folio);
 				folio_clear_unevictable(folio);
 				list_del(&folio->lru);
@@ -2165,6 +2280,15 @@ int migrate_pages(struct list_head *from, new_folio_t get_new_folio,
 	if (rc_gather < 0)
 		goto out;
 
+	rc = migrate_movable_ops_pages(from, get_new_folio, put_new_folio,
+				       private, mode, reason, &stats,
+				       &ret_folios);
+	if (rc < 0) {
+		rc_gather = rc;
+		goto out;
+	}
+	rc_gather += rc;
+
 again:
 	nr_pages = 0;
 	list_for_each_entry_safe(folio, folio2, from, lru) {

-- 
2.43.0

