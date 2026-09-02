Received: from CH4PR04CU002.outbound.protection.outlook.com (mail-northcentralusazon11013035.outbound.protection.outlook.com [40.107.201.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8D89C47ACFD;
	Wed,  2 Sep 2026 10:53:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=40.107.201.35
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788346426; cv=fail; b=i/rjvnh5NQ5Th5tqUTSyigrD+XN6ektg9054hoH/Zqg+Os2PVUJJ7Of6rxcche7Tpkwi5OCLIfFKORh5ZxF6nlGxQGMaLhzpX6HJvl++C9EzpiJKbVb484+nnf3c/FDWmkewpNpL0BK+sRY9S4fPEv6cETl/2tYAhGs5UAtzEzw=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788346426; c=relaxed/simple;
	bh=/JxnB8st+ToDiE6MnHWThIRZ2LywdNjTjPkffj1Qf68=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-ID:References:
	 In-Reply-To:To:CC; b=ha2Gc8UZLYop93UA7rFp+NCFDUvfIic852ef+uAzry0MFvl9J1OqGc2kt1DimynhQnp5/UpsTGiSEc6JcglF5l1mJjLNVwuWXk7IO9o7zdQGcQY2f6Y0YRXjo4kRuAgiNAUo7P3Si5P4to1Fl4N1/VdPX5MipYs6ymnhIdb0pLU=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amd.com; spf=fail smtp.mailfrom=amd.com; dkim=pass (1024-bit key) header.d=amd.com header.i=@amd.com header.b=mFCB1MsP; arc=fail smtp.client-ip=40.107.201.35
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amd.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=amd.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=amd.com header.i=@amd.com header.b="mFCB1MsP"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=AkgjLory456MAIGKbFAAxcc4JGtV5NTgeNIiXrIDIkUe3JysWRPtDh/Uohkmcnx7y+x4L81h3khYkeRB8NFYmEg5GuwmMfZcT/3LodAsHXYm50jsP4Q23+wA9UNEtQ0FNO4NHQ1VU5+HBQ0YSEMnam7IuNwTo1MgWUtko6Rr5XEJXvmobYXVvj1QXpa4qiH4SkLLEdurn27gAzI/JccdilWBDA6i0V7rjGBZPw5aE1UZOVu0nCQVTvhevlgtAgBmdnMxz3udMxuV6wsm13IAItNnAClh+O2E9iokF5mRd7f+IKn245skLXHJkhblAYBPH5hCz5caOulmqlGnha6aFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=bU+UL8NKIGvBCO/o+qeY9aeQfFCC3b6xl8+STqtXFkg=;
 b=Kh+cZ9ZE+HjnnMz7K8KD+USlw0RCwdzYTRbrrNpbayCUbf5+qCa6SPLdaohgVZR9jgRtgL9AuyMDusDRvysRKzUgdlfmlTxjI5Xs9Bw86CqsJd4uGJcDfPOkTz4zgBxh1+fYepHZ8gq2k8G+D03rwrPG0CVyiq/N+JqoDSGKYwXSsBlJiFcIf4y7SjDp4KxeSdJhasDNjLRkfWh4aLH79WXFKLbNgJM2X3YX3e/UGxVsYl4Bk7iVA1fvSgKmWstoMNVIm9e74RrzLE58FHjOrd3aVcKdEph7uDQ0KqA1Yiqw/ggIe/X1eRf0pyVNvkkv13/Euuow9nh+NkEvBOQeWA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass (sender ip is
 165.204.84.17) smtp.rcpttodomain=sk.com smtp.mailfrom=amd.com; dmarc=pass
 (p=quarantine sp=quarantine pct=100) action=none header.from=amd.com;
 dkim=none (message not signed); arc=none (0)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=amd.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=bU+UL8NKIGvBCO/o+qeY9aeQfFCC3b6xl8+STqtXFkg=;
 b=mFCB1MsP0OuX+GwywJB2fr0WnSvWSroA5Ip1TiCeJpb2mCZdIcv2jyNKagzjRMHZU3AoNXpV8aN+3Ekpgd+9uovgD5QrHgX/vG5/a3S7C8zMzM9YHzaCaknZ1tzR+qSFGZCAdzG78OL0v6yaVMLmLQdWi2kNiEKGeXj2fjEiRdc=
Received: from BN9PR03CA0713.namprd03.prod.outlook.com (2603:10b6:408:ef::28)
 by SA1PR12MB6773.namprd12.prod.outlook.com (2603:10b6:806:258::16) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.360.13; Wed, 2 Sep
 2026 10:53:25 +0000
Received: from BN1PEPF0000467F.namprd03.prod.outlook.com
 (2603:10b6:408:ef:cafe::9c) by BN9PR03CA0713.outlook.office365.com
 (2603:10b6:408:ef::28) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.382.11 via Frontend Transport; Wed, 2
 Sep 2026 10:53:25 +0000
X-MS-Exchange-Authentication-Results: spf=pass (sender IP is 165.204.84.17)
 smtp.mailfrom=amd.com; dkim=none (message not signed)
 header.d=none;dmarc=pass action=none header.from=amd.com;
Received-SPF: Pass (protection.outlook.com: domain of amd.com designates
 165.204.84.17 as permitted sender) receiver=protection.outlook.com;
 client-ip=165.204.84.17; helo=satlexmb07.amd.com; pr=C
Received: from satlexmb07.amd.com (165.204.84.17) by
 BN1PEPF0000467F.mail.protection.outlook.com (10.167.243.84) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.21.382.8 via Frontend Transport; Wed, 2 Sep 2026 10:53:24 +0000
Received: from [127.0.1.1] (10.180.168.240) by satlexmb07.amd.com
 (10.181.42.216) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.46; Wed, 2 Sep
 2026 05:53:10 -0500
From: Shivank Garg <shivankg@amd.com>
Date: Wed, 2 Sep 2026 10:52:17 +0000
Subject: [PATCH RFC 03/11] mm/migrate: factor out folio splitting on
 allocation failure
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-ID: <20260902-migrate-refactor-shivank-v1-3-9dcca87669c4@amd.com>
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
X-Developer-Signature: v=1; a=ed25519-sha256; t=1788346348; l=3615;
 i=shivankg@amd.com; s=20260518; h=from:subject:message-id;
 bh=/JxnB8st+ToDiE6MnHWThIRZ2LywdNjTjPkffj1Qf68=;
 b=uthfNhzsNdSB9qClSgRMWX6hdgqq8bCKeKI9zTwDpd0pZFnJ3KatPzbj7TvfElm0ZmOlA1V7W
 NHiLIEYiVoHBGQbPdeS1V/97EdEqGpvWfO/+541WcNYjV+tBEI60ifk
X-Developer-Key: i=shivankg@amd.com; a=ed25519;
 pk=2l2QGTeXuGkZTtfmx0nPQU8iFZfjYmX/ymMojitevx4=
X-ClientProxiedBy: satlexmb08.amd.com (10.181.42.217) To satlexmb07.amd.com
 (10.181.42.216)
X-EOPAttributedMessage: 0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: BN1PEPF0000467F:EE_|SA1PR12MB6773:EE_
X-MS-Office365-Filtering-Correlation-Id: 5e2f9f49-7daf-4857-a660-08df08e0697d
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|23010399003|36860700016|82310400026|1800799024|7416014|376014|921020|10067099003|56012099006|11063799006|18002099003|22082099003;
X-Microsoft-Antispam-Message-Info:
	iPmU/b2Splm99CrkVXk93Y1Ie93q7bkIgwC+NZn37FeCidDDS3P1J9bOZH9gXu4foKOBleM838N1Q/x9wwaASsRCGFCzPSV+bYkcdhuVqVzcfv+0u02y9i17Hpv3VCGYPgobwnlcBE/XQnHDBRu8EKoNbbguL4pQN0HaB5ndjIZEH056AhRnenaEzCH56rkpjGmljZ2WBZys1rwW4NNJRys4sCh+51RxqPQ42VBN5wAqYxeh2nqlTjUJu6kdC2J8Il5w3UWi9MzP5+DBKvuPup7LPHL6sx0XKgAJbaagrKrTReZaidyNbqQ1ioAO+HmSiTKnx5avOucrD2iND1OxOIx0DQZ1YSeVcSBweou+49aM9dsxkkJ53DZr7I4U7o0OCwiIoDA4PXHUqXZWv0/TAfygpsSW8VUFGjSH1GfhbjQUxSKkdyj5TUTIwMePh6WA6XCP57ksJU9DAGEHlKo4NNmt58Hol06lG02uDUzewtboQoKzv0gWH9hWWwA5W8lQ5oRMWW8jiipqe5rF0sM5O7zX3R2WkRgRnVyAYTMX6r25FnZwSO5r57g9smUhYbf8YUuf91JelXOS/K3i42z9HHc1zxGv+M/yKuja23hmuYv7l4LlqFMrus3rQ9vCmkP7ZVUqaoHkh1ExOYZkZHRZchAmKF1ApcIqTchHoNiB/vouymGjmHnat+SUpHDvY2KiMZ1Uy5t1Qgbot/8xNSPrGycQQ/0Lhy03/vRNzFJMAe6vVknHg5TCK86TCmELVgJF
X-Forefront-Antispam-Report:
	CIP:165.204.84.17;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:satlexmb07.amd.com;PTR:InfoDomainNonexistent;CAT:NONE;SFS:(13230040)(23010399003)(36860700016)(82310400026)(1800799024)(7416014)(376014)(921020)(10067099003)(56012099006)(11063799006)(18002099003)(22082099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	nITZiMGgOfmQDAiXF8/7ukiFQeu2QbjNsPWlxy/UITva8HASk8Hz8ZCMzf1UrVS50wB6pFvCTyRvP0yCPRq10L236Oetpt4kSSX6Iz1jRZL4Fait8HLkIR4g3a09jY224tnsPWbPxkeVfRkqXFtJ2tjpxgTyDM/NQ5jG94lX/2eanrVuCE55atKKaXgTAtOoIzgol2iiBMk7xBJPHw2PMEZp3Q4vCzRmBUta0fxEWJ43vnJbzqbwJXCl4LynKSsrnK6x6IGazuEhoR7sjIEzswICtqyzaA8QkYB9ObgBcMAkUaSmo4Xw+GKCh7S+HiIGIEOB1UpEVVO6ngpTS4BdhEv9zNFhHMAGgeObulm23uwEZz3uUBSJMRQBONbJeWGMkeLcVqMp/9ufIZjFD/pcow4qP81QyDAXQXOzGM9AWNkXan8PK1TYh+5OsmGccG8Q
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 02 Sep 2026 10:53:24.4815
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 5e2f9f49-7daf-4857-a660-08df08e0697d
X-MS-Exchange-CrossTenant-Id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=3dd8961f-e488-4e60-8e11-a82d994e183d;Ip=[165.204.84.17];Helo=[satlexmb07.amd.com]
X-MS-Exchange-CrossTenant-AuthSource:
	BN1PEPF0000467F.namprd03.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SA1PR12MB6773

If destination folio allocation fails, migrate_folios_unmap() may split
a large folio and retry migration with smaller folios. Factor this logic
out into migrate_folio_split_on_alloc_fail() to simplify the allocation
failure path.

No functional change intended.

Signed-off-by: Shivank Garg <shivankg@amd.com>
---
 mm/migrate.c | 69 +++++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 43 insertions(+), 26 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 89207bf515b9..510dfffa7235 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1809,6 +1809,34 @@ static void migrate_folios_undo(struct list_head *src_folios,
 	}
 }
 
+static int migrate_folio_split_on_alloc_fail(struct folio *folio,
+		struct list_head *split_folios, enum migrate_mode mode,
+		enum migrate_reason reason, struct migrate_pages_stats *stats)
+{
+	bool is_thp = folio_test_pmd_mappable(folio);
+	int rc;
+
+	/* Large folio NUMA faulting doesn't split to retry. */
+	if (!folio_test_large(folio) || reason == MR_NUMA_MISPLACED)
+		return -ENOMEM;
+
+	rc = try_split_folio(folio, split_folios, mode);
+	if (!rc) {
+		stats->nr_thp_split += is_thp;
+		stats->nr_split++;
+		return 0;
+	}
+
+	/*
+	 * Try again to split large folio to mitigate the failure of longterm
+	 * pinning.
+	 */
+	if (reason == MR_LONGTERM_PIN && rc == -EAGAIN)
+		return -EAGAIN;
+
+	return -ENOMEM;
+}
+
 /*
  * Unmap the folios in @from, queuing successfully unmapped sources on
  * @unmap_folios and their destination on @dst_folios.  Increment @nr_failed for
@@ -1829,10 +1857,8 @@ static int migrate_folios_unmap(struct list_head *from,
 	int nr_retry_pages = 0;
 	int pass = 0;
 	bool is_thp = false;
-	bool is_large = false;
 	struct folio *folio, *folio2, *dst = NULL;
-	int rc, nr_pages;
-	bool nosplit = (reason == MR_NUMA_MISPLACED);
+	int rc, split_rc, nr_pages;
 
 	for (pass = 0; pass < nr_pass && retry; pass++) {
 		retry = 0;
@@ -1840,7 +1866,6 @@ static int migrate_folios_unmap(struct list_head *from,
 		nr_retry_pages = 0;
 
 		list_for_each_entry_safe(folio, folio2, from, lru) {
-			is_large = folio_test_large(folio);
 			is_thp = folio_test_pmd_mappable(folio);
 			nr_pages = folio_nr_pages(folio);
 
@@ -1937,28 +1962,20 @@ static int migrate_folios_unmap(struct list_head *from,
 				 */
 				*nr_failed += 1;
 				stats->nr_thp_failed += is_thp;
-				/* Large folio NUMA faulting doesn't split to retry. */
-				if (is_large && !nosplit) {
-					int ret = try_split_folio(folio, split_folios, mode);
-
-					if (!ret) {
-						stats->nr_thp_split += is_thp;
-						stats->nr_split++;
-						break;
-					} else if (reason == MR_LONGTERM_PIN &&
-						   ret == -EAGAIN) {
-						/*
-						 * Try again to split large folio to
-						 * mitigate the failure of longterm pinning.
-						 */
-						retry++;
-						thp_retry += is_thp;
-						nr_retry_pages += nr_pages;
-						/* Undo duplicated failure counting. */
-						*nr_failed -= 1;
-						stats->nr_thp_failed -= is_thp;
-						break;
-					}
+
+				split_rc = migrate_folio_split_on_alloc_fail(folio,
+						split_folios, mode, reason, stats);
+				if (!split_rc)
+					break;
+				/* Retry this folio in a later pass. */
+				if (split_rc == -EAGAIN) {
+					retry++;
+					thp_retry += is_thp;
+					nr_retry_pages += nr_pages;
+					/* Undo duplicated failure counting. */
+					*nr_failed -= 1;
+					stats->nr_thp_failed -= is_thp;
+					break;
 				}
 
 				stats->nr_failed_pages += nr_pages + nr_retry_pages;

-- 
2.43.0

