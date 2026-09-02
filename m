Received: from SN4PR2101CU001.outbound.protection.outlook.com (mail-southcentralusazon11012020.outbound.protection.outlook.com [40.93.195.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5E82B477282;
	Wed,  2 Sep 2026 10:55:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=40.93.195.20
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788346516; cv=fail; b=Rkg2A/pIcxCPTJwzrtbK1fjeHFAWMKjnw0XJGfKe1hVsDRQeKluMWvCCEg2muy7EhE8W45KmcsD7y/yuOoy6EWFOVhm46C6uBAX8mURbjYe1ylx7rgtOl246KzX1enf7UNDUrIZd2xxlyZ+SL5KPjixCa2lfjckioYeKWFbNJro=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788346516; c=relaxed/simple;
	bh=LOl5eHjXADiF7hlMUDqzz5G/3F85i/QS9x6XGQEzTjk=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-ID:References:
	 In-Reply-To:To:CC; b=Vj6WIxgBiyBy9CuAKwCBnbbk/GyzSds0CjEPYeCLqpvldGb/L+gmfXiCNRVOTSykvVnTzgo4midIIq9xG+WHgy8jiJRzPRl4j9fTOO9DU3B2KGm2//W2XNToAK4rbjjkZd/+3rXtqMkHxGtlWiV4T11tIRSIwdJk4qXmFRK3eus=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amd.com; spf=fail smtp.mailfrom=amd.com; dkim=pass (1024-bit key) header.d=amd.com header.i=@amd.com header.b=eXtCgG6P; arc=fail smtp.client-ip=40.93.195.20
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amd.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=amd.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=amd.com header.i=@amd.com header.b="eXtCgG6P"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=PHWY6r+JZ+F/6AQhV+g6EKFQ1CcD+0TUtazQkYs3PODDhRR/ZixEkinI23aKDzf8K4HPJ32NPFOLmQZULoOR5D/IWFQZQhloL/ZGr7alQW57c4RXn40q9sTO6+isGUH5JfFRze/L4P0DG1uYloiMYuzUXvQu33xBguP48q0eltSbN9iUZ6hdRW32/48gfltjih0kXQObKpo3ETIKnWuTtlLQuHjBz/l0xw7EEQmyMHfJ0icinBcaXTiahZhbERvgvEu2e81rdwB90WNo3jWAHHWVPI7mz6UBrG+lc8JlfMvVRxSMc8s3ZMi8GFPiSLuVS+ptXlcGSQitwvpl/Ce47w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=zXdSE/kpzWbUy94HZbr2kS6pvG2nMVFr4ppud2knmyQ=;
 b=RXcn8jsk4AU7SgaK1K/i3Td6BqrZIppRXcJzMoQDV1EDcTjbjQk+QK4nOVHBLORidefUK46Ow2aLA6Lxa0tesRIZZo+BKvP6YTnRX+mF4TY1pI/Ce5KHdm8piHKI/uWnPupEhDGvRnMFIKToRI5fbZ7js6kltBMnzZYF8BJwr/z5MCSWrO7B3gTGRWFmQymrhSYytYGWQZaWe+qD4Ps/Nt6XNh1ATmLOfyPDcNRtulAkHKKpcNXO6H0Ah9Dvjz2D/DzpRxYN2IkX0HFwZYmItkV8QEWfJBbi6E+AknQcPLkfLkXrDhK/M0kZxjHAwF34YX01n/EZRXGv0sCgblwl6g==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass (sender ip is
 165.204.84.17) smtp.rcpttodomain=sk.com smtp.mailfrom=amd.com; dmarc=pass
 (p=quarantine sp=quarantine pct=100) action=none header.from=amd.com;
 dkim=none (message not signed); arc=none (0)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=amd.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=zXdSE/kpzWbUy94HZbr2kS6pvG2nMVFr4ppud2knmyQ=;
 b=eXtCgG6PFzVo3oRU14ip8RfUJVzTQNOYqiuL/ouGqAE3vilGVPldaCJ1dSFRiUE1cM322ZJT/rbV6ZYb88wkUH+CY1O9v3kwdpQLsKJe128frTP9aiuJg2ic7Cb/52vEt/ATPsVV5ygTxGJ96MGROnBcyD2AxPN5MFJ6ns0BOhA=
Received: from BN9P222CA0001.NAMP222.PROD.OUTLOOK.COM (2603:10b6:408:10c::6)
 by DM4PR12MB7671.namprd12.prod.outlook.com (2603:10b6:8:104::17) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.382.10; Wed, 2 Sep
 2026 10:55:04 +0000
Received: from BN5PEPF00046988.namprd02.prod.outlook.com
 (2603:10b6:408:10c:cafe::58) by BN9P222CA0001.outlook.office365.com
 (2603:10b6:408:10c::6) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.382.10 via Frontend Transport; Wed, 2
 Sep 2026 10:55:04 +0000
X-MS-Exchange-Authentication-Results: spf=pass (sender IP is 165.204.84.17)
 smtp.mailfrom=amd.com; dkim=none (message not signed)
 header.d=none;dmarc=pass action=none header.from=amd.com;
Received-SPF: Pass (protection.outlook.com: domain of amd.com designates
 165.204.84.17 as permitted sender) receiver=protection.outlook.com;
 client-ip=165.204.84.17; helo=satlexmb07.amd.com; pr=C
Received: from satlexmb07.amd.com (165.204.84.17) by
 BN5PEPF00046988.mail.protection.outlook.com (10.167.245.37) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.21.382.8 via Frontend Transport; Wed, 2 Sep 2026 10:55:04 +0000
Received: from [127.0.1.1] (10.180.168.240) by satlexmb07.amd.com
 (10.181.42.216) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.46; Wed, 2 Sep
 2026 05:54:48 -0500
From: Shivank Garg <shivankg@amd.com>
Date: Wed, 2 Sep 2026 10:52:24 +0000
Subject: [PATCH RFC 10/11] mm/migrate: pass migrate_control to
 migrate_pages()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-ID: <20260902-migrate-refactor-shivank-v1-10-9dcca87669c4@amd.com>
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
X-Developer-Signature: v=1; a=ed25519-sha256; t=1788346348; l=13649;
 i=shivankg@amd.com; s=20260518; h=from:subject:message-id;
 bh=LOl5eHjXADiF7hlMUDqzz5G/3F85i/QS9x6XGQEzTjk=;
 b=H9JSGPfjW+jdP0WD9kqP4t5MqC/arI8ecfrpaobnLmNWKDJK0yNI/ZubGwy+IU3KCS+BtCKiX
 O6hyMNlw/tZDUhpene2oN7UPwgprxMl4fnlGCD342IXoQ9RY9Pk8QMt
X-Developer-Key: i=shivankg@amd.com; a=ed25519;
 pk=2l2QGTeXuGkZTtfmx0nPQU8iFZfjYmX/ymMojitevx4=
X-ClientProxiedBy: satlexmb08.amd.com (10.181.42.217) To satlexmb07.amd.com
 (10.181.42.216)
X-EOPAttributedMessage: 0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: BN5PEPF00046988:EE_|DM4PR12MB7671:EE_
X-MS-Office365-Filtering-Correlation-Id: 99cb2392-3fb3-47ea-876d-08df08e0a51c
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|1800799024|23010399003|82310400026|7416014|36860700016|376014|10067099003|3023799007|18002099003|22082099003|11063799006|56012099006|921020;
X-Microsoft-Antispam-Message-Info:
	KnHTQZl48xc7Kdzv5SFB/TPUEzWWzT2gKOsC6E2nJNgPHQj3/FadTkcMLXXjeSBxw7bSVKpWUFujM7TLu2RzsMOJVbM4ZB9Yj2jwTd5XTbHKyDuOrGL+47QJV9jg0vIcLpqHmle54CdHCFMN/ijHTHIZ1c9ChwCQff4aIDgVlumgYIvBVjuRawT38RuEQZo2frcgaQYw4SBpmQqJF69YTtGm2zn3Ob1nhbJDa4R2W/Ne1a4s5NtZj7Okb0VWqIsjT4v4fuVE0qzXdMpKAzLwyeAREofFs4gIfT8/agl5nghVNLBsfxibDb4sNme6jlPt2YwgudQVJSQpbAWoNaB08s1gut0k8MLwE07mqnoSJvRsfGE1qH/hmzU4AgWw9l7JGAFR+LeOfB6azrsUxuE4mPgDxieGesX17RPFvemJfP5KuDMuCMrGEwPuOcCe40hbImxUFdq1bFag+jKm6QqohozuGDi6pqxlxJ6tbrkb2ZxBo3rPJ9JDBWaxhvx03+S7ibSPxywgvmcF91gD/Va6/y0+hQ+vgK3LfxjrBXUqjiu0zSRAmm2uGFPabQZE+xg4DAct+IA7LLfGFnYnsZzZR6SL6fP2uHEuY0jzwYrukvSg/rNslaAdnn4hjnCBbgRA2OEUftLaMuEWa1n+I1cIfqgeatCC8yy7+tKyoLXaxUMurgnzb2vwZ6UCkU/nY/1jIhBdghQhKveO1cGfzL/AFaWknTMKc0VzlIKvB4RtliD7SisHQjtf+ZBL06EJQT3q
X-Forefront-Antispam-Report:
	CIP:165.204.84.17;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:satlexmb07.amd.com;PTR:InfoDomainNonexistent;CAT:NONE;SFS:(13230040)(1800799024)(23010399003)(82310400026)(7416014)(36860700016)(376014)(10067099003)(3023799007)(18002099003)(22082099003)(11063799006)(56012099006)(921020);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	cxBtnbSCT3jrQ37WFsYCXMC/AvA0kUAUA8x7k5Ga5/g7PoDM5VNdXzk9dTaPHMBvVBEALLjNs9xfXEWTSK4/kzIKcTfNYhMPlMhBsnQt91i0ml9lsOgl8w5K0VYpqriBZefPNRhKpR+tIQLrk4q7UBDdDjXjtlELbe2uDyhwBbV81Nq4zdM+1t57rd7UqNToTpLzclTq9XaUa148cDeD1xnVvXsBbvxXB4jk1y/bN1/TR/aiU7HVdOlqmBwqHOXGSNkvqLarL5ceCZe4WKSo1yJRtpcc5xmJYC/5H8DgV+ShR8tkPFJYZA9twoJfaPZqw/VWG/sqEvRJi7BdORwc8890QOTQgkbxKmxoQRr1Xmouh1u76eKUJgtfY/sZKGKky7lQn7O5FGU6GHpG7/y1CKyRY2uAbdRzWVcevhtaOgpbG5UHBMTCdPC2fw93Cw5P
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 02 Sep 2026 10:55:04.5282
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 99cb2392-3fb3-47ea-876d-08df08e0a51c
X-MS-Exchange-CrossTenant-Id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=3dd8961f-e488-4e60-8e11-a82d994e183d;Ip=[165.204.84.17];Helo=[satlexmb07.amd.com]
X-MS-Exchange-CrossTenant-AuthSource:
	BN5PEPF00046988.namprd02.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM4PR12MB7671

migrate_pages() still takes mode and reason separately and reconstructs a
migrate_control internally. This prevents callers from supplying additional
migration policy without extending its argument list.

Change migrate_pages() to take a const struct migrate_control pointer and
update callers to construct it on the stack. Derive asynchronous controls
by copying the caller's control and overriding only the mode, preserving
any additional policy fields.

No functional change intended.

Signed-off-by: Shivank Garg <shivankg@amd.com>
---
 include/linux/migrate.h |  5 ++---
 mm/compaction.c         |  8 ++++++--
 mm/damon/ops-common.c   |  7 +++++--
 mm/gup.c                |  7 +++++--
 mm/memory-failure.c     |  6 +++++-
 mm/memory_hotplug.c     |  6 +++++-
 mm/mempolicy.c          | 13 ++++++++++---
 mm/migrate.c            | 36 +++++++++++++++++++-----------------
 mm/page_alloc.c         |  6 +++++-
 mm/vmscan.c             |  7 +++++--
 10 files changed, 67 insertions(+), 34 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 78424b3824c2..cec5713944e3 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -57,8 +57,7 @@ void putback_movable_pages(struct list_head *l);
 int migrate_folio(struct address_space *mapping, struct folio *dst,
 		struct folio *src, enum migrate_mode mode);
 int migrate_pages(struct list_head *l, new_folio_t new, free_folio_t free,
-		unsigned long private, enum migrate_mode mode,
-		enum migrate_reason reason,
+		unsigned long private, const struct migrate_control *ctl,
 		unsigned int *ret_succeeded);
 struct folio *alloc_migration_target(struct folio *src, unsigned long private);
 bool isolate_movable_ops_page(struct page *page, isolate_mode_t mode);
@@ -78,7 +77,7 @@ int set_movable_ops(const struct movable_operations *ops, enum pagetype type);
 static inline void putback_movable_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_folio_t new,
 		free_folio_t free, unsigned long private,
-		enum migrate_mode mode, enum migrate_reason reason,
+		const struct migrate_control *ctl,
 		unsigned int *ret_succeeded)
 	{ return -ENOSYS; }
 static inline struct folio *alloc_migration_target(struct folio *src,
diff --git a/mm/compaction.c b/mm/compaction.c
index a049415512c6..e75fcb0ee007 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -2566,6 +2566,10 @@ compact_zone(struct compact_control *cc, struct capture_control *capc)
 	unsigned long end_pfn = zone_end_pfn(cc->zone);
 	unsigned long last_migrated_pfn;
 	const bool sync = cc->mode != MIGRATE_ASYNC;
+	const struct migrate_control ctl = {
+		.mode = cc->mode,
+		.reason = MR_COMPACTION,
+	};
 	bool update_cached;
 	unsigned int nr_succeeded = 0, nr_migratepages;
 	int order;
@@ -2696,8 +2700,8 @@ compact_zone(struct compact_control *cc, struct capture_control *capc)
 		 */
 		nr_migratepages = cc->nr_migratepages;
 		err = migrate_pages(&cc->migratepages, compaction_alloc,
-				compaction_free, (unsigned long)cc, cc->mode,
-				MR_COMPACTION, &nr_succeeded);
+				compaction_free, (unsigned long)cc, &ctl,
+				&nr_succeeded);
 
 		trace_mm_compaction_migratepages(nr_migratepages, nr_succeeded);
 
diff --git a/mm/damon/ops-common.c b/mm/damon/ops-common.c
index fbda70d8ea4d..da848561aebb 100644
--- a/mm/damon/ops-common.c
+++ b/mm/damon/ops-common.c
@@ -315,6 +315,10 @@ static unsigned int __damon_migrate_folio_list(
 			__GFP_NOMEMALLOC | GFP_NOWAIT | __GFP_THISNODE,
 		.nid = target_nid,
 	};
+	const struct migrate_control ctl = {
+		.mode = MIGRATE_ASYNC,
+		.reason = MR_DAMON,
+	};
 
 	if (pgdat->node_id == target_nid || target_nid == NUMA_NO_NODE)
 		return 0;
@@ -324,8 +328,7 @@ static unsigned int __damon_migrate_folio_list(
 
 	/* Migration ignores all cpuset and mempolicy settings */
 	migrate_pages(migrate_folios, alloc_migration_target, NULL,
-		      (unsigned long)&mtc, MIGRATE_ASYNC, MR_DAMON,
-		      &nr_succeeded);
+		      (unsigned long)&mtc, &ctl, &nr_succeeded);
 
 	return nr_succeeded;
 }
diff --git a/mm/gup.c b/mm/gup.c
index eb898ea1ee22..73e1e8bfa4c0 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2357,10 +2357,13 @@ migrate_longterm_unpinnable_folios(struct list_head *movable_folio_list,
 			.gfp_mask = GFP_USER | __GFP_NOWARN,
 			.reason = MR_LONGTERM_PIN,
 		};
+		const struct migrate_control ctl = {
+			.mode = MIGRATE_SYNC,
+			.reason = MR_LONGTERM_PIN,
+		};
 
 		if (migrate_pages(movable_folio_list, alloc_migration_target,
-				  NULL, (unsigned long)&mtc, MIGRATE_SYNC,
-				  MR_LONGTERM_PIN, NULL)) {
+				  NULL, (unsigned long)&mtc, &ctl, NULL)) {
 			ret = -ENOMEM;
 			goto err;
 		}
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index a8b03e2920ba..85d0a69a0844 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -2860,6 +2860,10 @@ static int soft_offline_in_use_page(struct page *page)
 		.gfp_mask = GFP_USER | __GFP_MOVABLE | __GFP_RETRY_MAYFAIL,
 		.reason = MR_MEMORY_FAILURE,
 	};
+	const struct migrate_control ctl = {
+		.mode = MIGRATE_SYNC,
+		.reason = MR_MEMORY_FAILURE,
+	};
 
 	if (!huge && folio_test_large(folio)) {
 		const int new_order = min_order_for_split(folio);
@@ -2916,7 +2920,7 @@ static int soft_offline_in_use_page(struct page *page)
 
 	if (isolated) {
 		ret = migrate_pages(&pagelist, alloc_migration_target, NULL,
-			(unsigned long)&mtc, MIGRATE_SYNC, MR_MEMORY_FAILURE, NULL);
+			(unsigned long)&mtc, &ctl, NULL);
 		if (!ret) {
 			bool release = !huge;
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 226ab9cb078a..1250b0d47702 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1901,6 +1901,10 @@ static void do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			.gfp_mask = GFP_KERNEL | __GFP_MOVABLE | __GFP_RETRY_MAYFAIL,
 			.reason = MR_MEMORY_HOTPLUG,
 		};
+		const struct migrate_control ctl = {
+			.mode = MIGRATE_SYNC,
+			.reason = MR_MEMORY_HOTPLUG,
+		};
 		int ret;
 
 		/*
@@ -1918,7 +1922,7 @@ static void do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 		if (nodes_empty(nmask))
 			node_set(mtc.nid, nmask);
 		ret = migrate_pages(&source, alloc_migration_target, NULL,
-			(unsigned long)&mtc, MIGRATE_SYNC, MR_MEMORY_HOTPLUG, NULL);
+			(unsigned long)&mtc, &ctl, NULL);
 		if (ret) {
 			list_for_each_entry(folio, &source, lru) {
 				if (__ratelimit(&migrate_rs)) {
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 3498a5651d50..14f3f24a6fad 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1295,6 +1295,10 @@ static long migrate_to_node(struct mm_struct *mm, int source, int dest,
 		.gfp_mask = GFP_HIGHUSER_MOVABLE | __GFP_THISNODE,
 		.reason = MR_SYSCALL,
 	};
+	const struct migrate_control ctl = {
+		.mode = MIGRATE_SYNC,
+		.reason = MR_SYSCALL,
+	};
 
 	nodes_clear(nmask);
 	node_set(source, nmask);
@@ -1320,7 +1324,7 @@ static long migrate_to_node(struct mm_struct *mm, int source, int dest,
 
 	if (!list_empty(&pagelist)) {
 		err = migrate_pages(&pagelist, alloc_migration_target, NULL,
-			(unsigned long)&mtc, MIGRATE_SYNC, MR_SYSCALL, NULL);
+			(unsigned long)&mtc, &ctl, NULL);
 		if (err)
 			putback_movable_pages(&pagelist);
 	}
@@ -1499,6 +1503,10 @@ static long do_mbind(unsigned long start, unsigned long len,
 	long err;
 	long nr_failed;
 	LIST_HEAD(pagelist);
+	const struct migrate_control ctl = {
+		.mode = MIGRATE_SYNC,
+		.reason = MR_MEMPOLICY_MBIND,
+	};
 
 	if (flags & ~(unsigned long)MPOL_MF_VALID)
 		return -EINVAL;
@@ -1616,8 +1624,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 	if (!err && !list_empty(&pagelist)) {
 		nr_failed |= migrate_pages(&pagelist,
 				alloc_migration_target_by_mpol, NULL,
-				(unsigned long)&mmpol, MIGRATE_SYNC,
-				MR_MEMPOLICY_MBIND, NULL);
+				(unsigned long)&mmpol, &ctl, NULL);
 	}
 
 	if (nr_failed && (flags & MPOL_MF_STRICT))
diff --git a/mm/migrate.c b/mm/migrate.c
index e4bc7122076e..549f8b57092c 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2312,9 +2312,8 @@ static int migrate_lru_folios(struct list_head *from, new_folio_t get_new_folio,
  * @put_new_folio:	The function used to free target folios if migration
  *			fails, or NULL if no special handling is necessary.
  * @private:		Private data to be passed on to get_new_folio()
- * @mode:		The migration mode that specifies the constraints for
- *			folio migration, if any.
- * @reason:		The reason for folio migration.
+ * @ctl:		The policy for this migration: blocking discipline,
+ *			and reason.
  * @ret_succeeded:	Set to the number of folios migrated successfully if
  *			the caller passes a non-NULL pointer.
  *
@@ -2330,27 +2329,23 @@ static int migrate_lru_folios(struct list_head *from, new_folio_t get_new_folio,
  */
 int migrate_pages(struct list_head *from, new_folio_t get_new_folio,
 		free_folio_t put_new_folio, unsigned long private,
-		enum migrate_mode mode, enum migrate_reason reason, unsigned int *ret_succeeded)
+		const struct migrate_control *ctl, unsigned int *ret_succeeded)
 {
 	int rc, rc_gather;
 	LIST_HEAD(ret_folios);
 	struct migrate_pages_stats stats;
-	const struct migrate_control ctl = {
-		.mode = mode,
-		.reason = reason,
-	};
 
-	trace_mm_migrate_pages_start(ctl.mode, ctl.reason);
+	trace_mm_migrate_pages_start(ctl->mode, ctl->reason);
 
 	memset(&stats, 0, sizeof(stats));
 
 	rc_gather = migrate_hugetlbs(from, get_new_folio, put_new_folio, private,
-				     &ctl, &stats, &ret_folios);
+				     ctl, &stats, &ret_folios);
 	if (rc_gather < 0)
 		goto out;
 
 	rc = migrate_movable_ops_pages(from, get_new_folio, put_new_folio,
-				       private, &ctl, &stats,
+				       private, ctl, &stats,
 				       &ret_folios);
 	if (rc < 0) {
 		rc_gather = rc;
@@ -2359,7 +2354,7 @@ int migrate_pages(struct list_head *from, new_folio_t get_new_folio,
 	rc_gather += rc;
 
 	rc = migrate_lru_folios(from, get_new_folio, put_new_folio,
-			private, &ctl, &ret_folios, &stats);
+			private, ctl, &ret_folios, &stats);
 	if (rc < 0) {
 		rc_gather = rc;
 		goto out;
@@ -2386,8 +2381,8 @@ int migrate_pages(struct list_head *from, new_folio_t get_new_folio,
 	count_vm_events(THP_MIGRATION_SPLIT, stats.nr_thp_split);
 	trace_mm_migrate_pages(stats.nr_succeeded, stats.nr_failed_pages,
 			       stats.nr_thp_succeeded, stats.nr_thp_failed,
-			       stats.nr_thp_split, stats.nr_split, ctl.mode,
-			       ctl.reason);
+			       stats.nr_thp_split, stats.nr_split, ctl->mode,
+			       ctl->reason);
 
 	if (ret_succeeded)
 		*ret_succeeded = stats.nr_succeeded;
@@ -2454,9 +2449,13 @@ static int do_move_pages_to_node(struct list_head *pagelist, int node)
 		.gfp_mask = GFP_HIGHUSER_MOVABLE | __GFP_THISNODE,
 		.reason = MR_SYSCALL,
 	};
+	const struct migrate_control ctl = {
+		.mode = MIGRATE_SYNC,
+		.reason = MR_SYSCALL,
+	};
 
 	err = migrate_pages(pagelist, alloc_migration_target, NULL,
-		(unsigned long)&mtc, MIGRATE_SYNC, MR_SYSCALL, NULL);
+		(unsigned long)&mtc, &ctl, NULL);
 	if (err)
 		putback_movable_pages(pagelist);
 	return err;
@@ -2961,11 +2960,14 @@ int migrate_misplaced_folio(struct folio *folio, int node)
 	LIST_HEAD(migratepages);
 	struct mem_cgroup *memcg = get_mem_cgroup_from_folio(folio);
 	struct lruvec *lruvec = mem_cgroup_lruvec(memcg, pgdat);
+	const struct migrate_control ctl = {
+		.mode = MIGRATE_ASYNC,
+		.reason = MR_NUMA_MISPLACED,
+	};
 
 	list_add(&folio->lru, &migratepages);
 	nr_remaining = migrate_pages(&migratepages, alloc_misplaced_dst_folio,
-				     NULL, node, MIGRATE_ASYNC,
-				     MR_NUMA_MISPLACED, &nr_succeeded);
+				     NULL, node, &ctl, &nr_succeeded);
 	if (nr_remaining && !list_empty(&migratepages))
 		putback_movable_pages(&migratepages);
 	if (nr_succeeded) {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 12fac9084c48..8a921f6cdc86 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7146,6 +7146,10 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 		.gfp_mask = cc->gfp_mask,
 		.reason = MR_CONTIG_RANGE,
 	};
+	const struct migrate_control ctl = {
+		.mode = cc->mode,
+		.reason = MR_CONTIG_RANGE,
+	};
 
 	lru_cache_disable();
 
@@ -7172,7 +7176,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 		cc->nr_migratepages -= nr_reclaimed;
 
 		ret = migrate_pages(&cc->migratepages, alloc_migration_target,
-			NULL, (unsigned long)&mtc, cc->mode, MR_CONTIG_RANGE, NULL);
+			NULL, (unsigned long)&mtc, &ctl, NULL);
 
 		/*
 		 * On -ENOMEM, migrate_pages() bails out right away. It is pointless
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f11491ee9ed5..7e8b04c97342 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1013,6 +1013,10 @@ static unsigned int demote_folio_list(struct list_head *demote_folios,
 		.nmask = &allowed_mask,
 		.reason = MR_DEMOTION,
 	};
+	const struct migrate_control ctl = {
+		.mode = MIGRATE_ASYNC,
+		.reason = MR_DEMOTION,
+	};
 
 	if (list_empty(demote_folios))
 		return 0;
@@ -1031,8 +1035,7 @@ static unsigned int demote_folio_list(struct list_head *demote_folios,
 
 	/* Demotion ignores all cpuset and mempolicy settings */
 	migrate_pages(demote_folios, alloc_demote_folio, NULL,
-		      (unsigned long)&mtc, MIGRATE_ASYNC, MR_DEMOTION,
-		      &nr_succeeded);
+		      (unsigned long)&mtc, &ctl, &nr_succeeded);
 
 	return nr_succeeded;
 }

-- 
2.43.0

