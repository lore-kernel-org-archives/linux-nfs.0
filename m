Received: from CY7PR03CU001.outbound.protection.outlook.com (mail-westcentralusazon11010016.outbound.protection.outlook.com [40.93.198.16])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7845F4746AB;
	Wed,  2 Sep 2026 10:55:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=40.93.198.16
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788346503; cv=fail; b=S4xUnoVP6hhasoaAZTMrjfsb3S8dmeh6zKWAjU/UxcQ40g8bwj7xJz8yxW47VYF7n8o0LnZ6SfNzfMVjJ1Os/5CIPxRegyY7m9/RQrLa2lWf5TEKnEb7U/pIUqPg3CRaOZ0XhD8flMiKZa/t9HT7vW4H6x0jYPVSXTCKeEK2ijY=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788346503; c=relaxed/simple;
	bh=6EMcmpBQI1vPSYfcMlDJn/BtPcuSul8OlWNINOe6fN8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-ID:References:
	 In-Reply-To:To:CC; b=l0i064aJHCTi0oyN17wa1+1gS/TPNNJTR1mYpXs5A36+2n8eN2y8N5kldxXihSFsQ0nCFo2gQXS4KLEe7MeBHhk0M/zdDYL3kWDtuJ74yVwnrJV7w0opQuGVR07ihXMBYJJNHEtDmSA5TOUKIJ/9OoIkabZ1s6lnrTexjP98J7Q=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amd.com; spf=fail smtp.mailfrom=amd.com; dkim=pass (1024-bit key) header.d=amd.com header.i=@amd.com header.b=oNun03Vy; arc=fail smtp.client-ip=40.93.198.16
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amd.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=amd.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=amd.com header.i=@amd.com header.b="oNun03Vy"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=yXZ1f4OkCC8Y2RLnk2Z19aAUVT5g4G4bW8WsTuAhkq0c/gcDk3AzD945wwFNMXtHukosctIeeDLuHXbbuKbM3lugK6sf9BZQ/j98kU3qBJS+GbfHCGlNbICgrE5mRFO37vez4neMJ1qMf31IlurWAr/JhVIrFHCPKUxOnyQ1OYoi/NxRXhVEEcCGoGxjWHsRhL4D3LhNyNCtfuqBQilZ10iQpfkZ9G+JCaA8nC7ecRlWtf5wkPCJpxEJpVEYJMGtYu0Rttn96GxtUpcT0j2I04dftBiywjA1cMzoDW415Vq3iDEDTFHiLBkuFklq6dmtDJjeDbaJgkq3JehUwEOFtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=KosfdVldCAz+hZA49sh2dczO17gkZdiCZzF6bF0k6fk=;
 b=R3urjMGSUG6VSNmBxnEHLLvRkpV+a8VHlO5fSYCfiFjKZ2Ua/f0QtI+TusTHfriVpL0i5wyetysmFygPl2hes10PT18KE8OXUu9Sn4gyzHkdH+p3YsQVWZPkPHWuxkTbxNeT37os8YVbgaVha3iIJW8/LWEYsnq5DS+Mh6AdA3ZchEwEZxIJdqfxcryOJDsEuZNm1jByv5dfQfRnNv8lmCLDZ0PQf8jNpMCgRUUSFhI93TNDybCxWpN7mLa4gKofj/6GtpVtFPJNdNxbedfl4hSzSMaaLmUWweGOOwMcECdeUxNja6U2ZdXLjHYgZqH53EeaIiuOKJPZBD8BIJZvng==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass (sender ip is
 165.204.84.17) smtp.rcpttodomain=sk.com smtp.mailfrom=amd.com; dmarc=pass
 (p=quarantine sp=quarantine pct=100) action=none header.from=amd.com;
 dkim=none (message not signed); arc=none (0)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=amd.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=KosfdVldCAz+hZA49sh2dczO17gkZdiCZzF6bF0k6fk=;
 b=oNun03VyDhzf4qEzPkaibKIGTmd8w7Dqg7UepyU+oPRAAkpW+uJplKh4mC4h3cNr7RkT18E565LveUXXskN9o/TlraTRe9D1dERazikcTlRSnYbZos6k5NBVNXxznbyV1/Lc2noNnSbOB066Hl1Mmt4m6SocWnis/q+oJmJKjqU=
Received: from BN0PR04CA0149.namprd04.prod.outlook.com (2603:10b6:408:ed::34)
 by DS7PR12MB8290.namprd12.prod.outlook.com (2603:10b6:8:d8::15) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.360.13; Wed, 2 Sep
 2026 10:54:54 +0000
Received: from BN5PEPF0004698B.namprd02.prod.outlook.com
 (2603:10b6:408:ed:cafe::a7) by BN0PR04CA0149.outlook.office365.com
 (2603:10b6:408:ed::34) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.382.10 via Frontend Transport; Wed, 2
 Sep 2026 10:54:52 +0000
X-MS-Exchange-Authentication-Results: spf=pass (sender IP is 165.204.84.17)
 smtp.mailfrom=amd.com; dkim=none (message not signed)
 header.d=none;dmarc=pass action=none header.from=amd.com;
Received-SPF: Pass (protection.outlook.com: domain of amd.com designates
 165.204.84.17 as permitted sender) receiver=protection.outlook.com;
 client-ip=165.204.84.17; helo=satlexmb07.amd.com; pr=C
Received: from satlexmb07.amd.com (165.204.84.17) by
 BN5PEPF0004698B.mail.protection.outlook.com (10.167.245.40) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.21.382.8 via Frontend Transport; Wed, 2 Sep 2026 10:54:51 +0000
Received: from [127.0.1.1] (10.180.168.240) by satlexmb07.amd.com
 (10.181.42.216) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.46; Wed, 2 Sep
 2026 05:54:34 -0500
From: Shivank Garg <shivankg@amd.com>
Date: Wed, 2 Sep 2026 10:52:23 +0000
Subject: [PATCH RFC 09/11] mm/migrate: thread migration policy through a
 control struct
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-ID: <20260902-migrate-refactor-shivank-v1-9-9dcca87669c4@amd.com>
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
X-Developer-Signature: v=1; a=ed25519-sha256; t=1788346348; l=21523;
 i=shivankg@amd.com; s=20260518; h=from:subject:message-id;
 bh=6EMcmpBQI1vPSYfcMlDJn/BtPcuSul8OlWNINOe6fN8=;
 b=OS3tT5J3qLHhG6i6qqPZamCFGRqB92OjoDv19KfNij+wdhrXOVUMFCv2B8FdwsAYzlIoZdmce
 /ziy+FH18AXD2hbrKkJU8vaHPWUDMQnfQMTFxomu30zZ+2VLRT6dDOm
X-Developer-Key: i=shivankg@amd.com; a=ed25519;
 pk=2l2QGTeXuGkZTtfmx0nPQU8iFZfjYmX/ymMojitevx4=
X-ClientProxiedBy: satlexmb08.amd.com (10.181.42.217) To satlexmb07.amd.com
 (10.181.42.216)
X-EOPAttributedMessage: 0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: BN5PEPF0004698B:EE_|DS7PR12MB8290:EE_
X-MS-Office365-Filtering-Correlation-Id: 808b2fb9-c295-4075-d486-08df08e09d87
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|36860700016|376014|82310400026|7416014|1800799024|23010399003|921020|10067099003|11063799006|56012099006|18002099003|22082099003;
X-Microsoft-Antispam-Message-Info:
	4QS7S28TIID30AQxFymuvb4Ak9eSLf6egl7agpX3dVZodsB4UOUQCnYK3DyBhwJUdyZ6FLPVvjERmebGO4FqIu+nnYvMIv7Z4v5rFYfSTRz1biM6p72a2Z2eqAIHvjvws1vw3HVaLJQeC9FdsVo/FAosbaqfjcleAcJiOQkcl8UiRKOuEy01OSJK2fYw9frAX68Ll7B4k70X3DOHv1lcX5GPLuAlcRQaaULRZqhWvyW0uv+5XfUn7zW/l/jkS76cdMBz3Kbut4uz+KwLaJT7xm0qxcO2uLNgP5DkKE5S/l948F1mRroIWdaaR6h3YiCG3GuMzr6CQbrYRuywb0Csc27O3UAX92zHSS/YfVadStgjwF008As6gNv7hci5KtkccggTOT6zRDLL6Aq0cWPNgVGGfa7/PKaYSvn8OG8/XTgBdf3n8fYs0KJ1mSUbrRf4VYXHBZqFkdoost7PRbkVyPpLZtFUgSiZeFZwDmeMb+ugkRBbTlDNCtSnh6P+DeVblRkM6oEg7+RLWMw1F7GaGrcv7UcWMCMkwm+fUkB4kVPyNLmzPp8k8kbWRFsU5h0bIAw3ZIEhotuFmHia3fwBDJ5ZXZy7jvn94yMfKsLZ14I52PLVOE8RxxBMWvDTb/sKbFSnJUo6m6c/1+gWTV7rI3iJDzZkSPZFS/UeiGvL8+bOuW/yEHYT49mb984kda6MagUasNl044/jq7CsAFANBfdy9wpijNSTg7zgJ/OCPq4NDGI7+J6wx3zddEol+Cij
X-Forefront-Antispam-Report:
	CIP:165.204.84.17;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:satlexmb07.amd.com;PTR:InfoDomainNonexistent;CAT:NONE;SFS:(13230040)(36860700016)(376014)(82310400026)(7416014)(1800799024)(23010399003)(921020)(10067099003)(11063799006)(56012099006)(18002099003)(22082099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	rQ8FFx1BowldtA4pmQ505jAvXIIw+3m14etpmTbQKqZN4wfE6YazFCF8RhncfbmlCA2iXoFtdBQ02K7VAbtvyE53rr8RMtBLzEMYFjs9kKCDIR7uheAELARRNxb84/SbVlwi3lANXnLeSYUSoNpBpIkScFts45K8m6fAuKimzrpAvnUbKylwV58R0acXnqY6WHW0lZIkkgzM3M0MJc1sUI8ND3yXYEMqTOHEbl2nsWUm7NCa0YtKRsM6Tj0NI/0Wd5+smXvUln5EKvQUfxPj8kMS30xColFE7Lyh35xXftqEmdhZ5hVd8xqVEGnXjvfLlxuWc/R5jsiwgo8Vq5/W/eklv8JdTwyQCqToeg6lVpj1vdyxXoXvOZLYCjXyQrAdJOfR4D9NMhofUn+1JXJgQUh7Utio+SCb8+tGK0iRFP2wwo1+MOZNfGL09UuiC+Qy
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 02 Sep 2026 10:54:51.7937
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 808b2fb9-c295-4075-d486-08df08e09d87
X-MS-Exchange-CrossTenant-Id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=3dd8961f-e488-4e60-8e11-a82d994e183d;Ip=[165.204.84.17];Helo=[satlexmb07.amd.com]
X-MS-Exchange-CrossTenant-AuthSource:
	BN5PEPF0004698B.namprd02.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DS7PR12MB8290

Migration mode and reason describe one migration invocation, but are passed
separately through every migration engine and phase. Adding more policy
would require another parameter through the same call graph or overloading
migrate_mode with unrelated information.

Add struct migrate_control, initialize it on the migrate_pages() stack, and
pass it as const through the internal migration helpers. This provides one
place for additional policy, such as copy-cache hints.

Use a derived control for asynchronous pre-passes and split-folio retries.
Keep the public migration and filesystem callback interfaces unchanged in
this patch and will be handled separately in upcoming patch.

No functional change intended.

Signed-off-by: Shivank Garg <shivankg@amd.com>
---
 include/linux/migrate_mode.h |  14 +++++
 mm/migrate.c                 | 144 ++++++++++++++++++++++---------------------
 2 files changed, 88 insertions(+), 70 deletions(-)

diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
index 05102d4d2490..388acddfdae8 100644
--- a/include/linux/migrate_mode.h
+++ b/include/linux/migrate_mode.h
@@ -29,4 +29,18 @@ enum migrate_reason {
 	MR_TYPES
 };
 
+/**
+ * struct migrate_control - Policy for one migration invocation
+ * @mode: Blocking discipline for migration operations
+ * @reason: Reason the migration was requested
+ *
+ * Per-folio completion state does not belong here.  Callers keep this
+ * structure on the stack; migration must not allocate it under memory
+ * pressure.
+ */
+struct migrate_control {
+	enum migrate_mode mode;
+	enum migrate_reason reason;
+};
+
 #endif		/* MIGRATE_MODE_H_INCLUDED */
diff --git a/mm/migrate.c b/mm/migrate.c
index 8914358cc434..e4bc7122076e 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1103,7 +1103,7 @@ static int fallback_migrate_folio(struct address_space *mapping,
  *     0 - success
  */
 static int move_to_new_folio(struct folio *dst, struct folio *src,
-				enum migrate_mode mode)
+		const struct migrate_control *ctl)
 {
 	struct address_space *mapping = folio_mapping(src);
 	int rc = -EAGAIN;
@@ -1112,7 +1112,7 @@ static int move_to_new_folio(struct folio *dst, struct folio *src,
 	VM_BUG_ON_FOLIO(!folio_test_locked(dst), dst);
 
 	if (!mapping)
-		rc = migrate_folio(mapping, dst, src, mode);
+		rc = migrate_folio(mapping, dst, src, ctl->mode);
 	else if (mapping_inaccessible(mapping))
 		rc = -EOPNOTSUPP;
 	else if (mapping->a_ops->migrate_folio)
@@ -1123,10 +1123,9 @@ static int move_to_new_folio(struct folio *dst, struct folio *src,
 		 * migrate_folio callback. This is the most common path
 		 * for page migration.
 		 */
-		rc = mapping->a_ops->migrate_folio(mapping, dst, src,
-							mode);
+		rc = mapping->a_ops->migrate_folio(mapping, dst, src, ctl->mode);
 	else
-		rc = fallback_migrate_folio(mapping, dst, src, mode);
+		rc = fallback_migrate_folio(mapping, dst, src, ctl->mode);
 
 	if (!rc) {
 		/*
@@ -1198,13 +1197,13 @@ static void migrate_folio_undo_dst(struct folio *dst, bool locked,
 
 /* Cleanup src folio upon migration success */
 static void migrate_folio_done(struct folio *src,
-			       enum migrate_reason reason)
+		const struct migrate_control *ctl)
 {
-	if (reason != MR_DEMOTION)
+	if (ctl->reason != MR_DEMOTION)
 		mod_node_page_state(folio_pgdat(src), NR_ISOLATED_ANON +
 				    folio_is_file_lru(src), -folio_nr_pages(src));
 
-	if (reason != MR_MEMORY_FAILURE)
+	if (ctl->reason != MR_MEMORY_FAILURE)
 		/* We release the page in page_handle_poison. */
 		folio_put(src);
 }
@@ -1212,8 +1211,8 @@ static void migrate_folio_done(struct folio *src,
 /* Obtain the lock on page, remove all ptes. */
 static int migrate_folio_unmap(new_folio_t get_new_folio,
 		free_folio_t put_new_folio, unsigned long private,
-		struct folio *src, struct folio **dstp, enum migrate_mode mode,
-		struct list_head *ret)
+		struct folio *src, struct folio **dstp,
+		const struct migrate_control *ctl, struct list_head *ret)
 {
 	struct folio *dst;
 	int rc = -EAGAIN;
@@ -1230,7 +1229,7 @@ static int migrate_folio_unmap(new_folio_t get_new_folio,
 	dst->migrate_info = 0;
 
 	if (!folio_trylock(src)) {
-		if (mode == MIGRATE_ASYNC)
+		if (ctl->mode == MIGRATE_ASYNC)
 			goto out;
 
 		/*
@@ -1254,7 +1253,7 @@ static int migrate_folio_unmap(new_folio_t get_new_folio,
 		 * inserting a page into the page table), but it's not
 		 * worth waiting for I/O.
 		 */
-		if (mode == MIGRATE_SYNC_LIGHT && !folio_test_uptodate(src))
+		if (ctl->mode == MIGRATE_SYNC_LIGHT && !folio_test_uptodate(src))
 			goto out;
 
 		folio_lock(src);
@@ -1270,7 +1269,7 @@ static int migrate_folio_unmap(new_folio_t get_new_folio,
 		 * the retry loop is too short and in the sync-light case,
 		 * the overhead of stalling is too much
 		 */
-		switch (mode) {
+		switch (ctl->mode) {
 		case MIGRATE_SYNC:
 			break;
 		default:
@@ -1330,7 +1329,8 @@ static int migrate_folio_unmap(new_folio_t get_new_folio,
 		/* Establish migration ptes */
 		VM_BUG_ON_FOLIO(folio_test_anon(src) &&
 			       !folio_test_ksm(src) && !anon_vma, src);
-		try_to_migrate(src, mode == MIGRATE_ASYNC ? TTU_BATCH_FLUSH : 0);
+		try_to_migrate(src, ctl->mode == MIGRATE_ASYNC ?
+			TTU_BATCH_FLUSH : 0);
 		old_folio_state |= FOLIO_WAS_MAPPED;
 	}
 
@@ -1356,9 +1356,8 @@ static int migrate_folio_unmap(new_folio_t get_new_folio,
 
 /* Migrate the folio to the newly allocated folio in dst. */
 static int migrate_folio_move(free_folio_t put_new_folio, unsigned long private,
-			      struct folio *src, struct folio *dst,
-			      enum migrate_mode mode, enum migrate_reason reason,
-			      struct list_head *ret)
+		struct folio *src, struct folio *dst,
+		const struct migrate_control *ctl, struct list_head *ret)
 {
 	int rc;
 	int old_folio_state = 0;
@@ -1377,7 +1376,7 @@ static int migrate_folio_move(free_folio_t put_new_folio, unsigned long private,
 		src_partially_mapped = folio_test_partially_mapped(src);
 	}
 
-	rc = move_to_new_folio(dst, src, mode);
+	rc = move_to_new_folio(dst, src, ctl);
 	if (rc)
 		goto out;
 
@@ -1407,7 +1406,7 @@ static int migrate_folio_move(free_folio_t put_new_folio, unsigned long private,
 		remove_migration_ptes(src, dst, 0);
 
 	folio_unlock(dst);
-	folio_set_owner_migrate_reason(dst, reason);
+	folio_set_owner_migrate_reason(dst, ctl->reason);
 	/*
 	 * If migration is successful, decrease refcount of dst,
 	 * which will not free the page because new page owner increased
@@ -1424,7 +1423,7 @@ static int migrate_folio_move(free_folio_t put_new_folio, unsigned long private,
 	if (anon_vma)
 		put_anon_vma(anon_vma);
 	folio_unlock(src);
-	migrate_folio_done(src, reason);
+	migrate_folio_done(src, ctl);
 
 	return rc;
 out:
@@ -1466,8 +1465,8 @@ static int migrate_folio_move(free_folio_t put_new_folio, unsigned long private,
  */
 static int unmap_and_move_hugetlb_folio(new_folio_t get_new_folio,
 		free_folio_t put_new_folio, unsigned long private,
-		struct folio *src, int force, enum migrate_mode mode,
-		enum migrate_reason reason, struct list_head *ret)
+		struct folio *src, int force, const struct migrate_control *ctl,
+		struct list_head *ret)
 {
 	struct folio *dst;
 	int rc = -EAGAIN;
@@ -1489,7 +1488,7 @@ static int unmap_and_move_hugetlb_folio(new_folio_t get_new_folio,
 	if (!folio_trylock(src)) {
 		if (!force)
 			goto out;
-		switch (mode) {
+		switch (ctl->mode) {
 		case MIGRATE_SYNC:
 			break;
 		default:
@@ -1534,7 +1533,7 @@ static int unmap_and_move_hugetlb_folio(new_folio_t get_new_folio,
 	}
 
 	if (!folio_mapped(src))
-		rc = move_to_new_folio(dst, src, mode);
+		rc = move_to_new_folio(dst, src, ctl);
 
 	if (was_mapped)
 		remove_migration_ptes(src, !rc ? dst : src, ttu);
@@ -1550,7 +1549,7 @@ static int unmap_and_move_hugetlb_folio(new_folio_t get_new_folio,
 		put_anon_vma(anon_vma);
 
 	if (!rc) {
-		move_hugetlb_state(src, dst, reason);
+		move_hugetlb_state(src, dst, ctl->reason);
 		put_new_folio = NULL;
 	}
 
@@ -1625,7 +1624,7 @@ struct migrate_pages_stats {
  */
 static int migrate_hugetlbs(struct list_head *from, new_folio_t get_new_folio,
 			    free_folio_t put_new_folio, unsigned long private,
-			    enum migrate_mode mode, enum migrate_reason reason,
+			    const struct migrate_control *ctl,
 			    struct migrate_pages_stats *stats,
 			    struct list_head *ret_folios)
 {
@@ -1666,8 +1665,8 @@ static int migrate_hugetlbs(struct list_head *from, new_folio_t get_new_folio,
 
 			rc = unmap_and_move_hugetlb_folio(get_new_folio,
 							  put_new_folio, private,
-							  folio, pass > 2, mode,
-							  reason, ret_folios);
+							  folio, pass > 2, ctl,
+							  ret_folios);
 			/*
 			 * The rules are:
 			 *	0: hugetlb folio will be put back
@@ -1721,7 +1720,7 @@ static int migrate_hugetlbs(struct list_head *from, new_folio_t get_new_folio,
 static void migrate_folios_move(struct list_head *src_folios,
 		struct list_head *dst_folios,
 		free_folio_t put_new_folio, unsigned long private,
-		enum migrate_mode mode, enum migrate_reason reason,
+		const struct migrate_control *ctl,
 		struct list_head *ret_folios,
 		struct migrate_pages_stats *stats, int nr_pass,
 		int *nr_failed)
@@ -1748,7 +1747,7 @@ static void migrate_folios_move(struct list_head *src_folios,
 			cond_resched();
 
 			rc = migrate_folio_move(put_new_folio, private,
-					folio, dst, mode, reason, ret_folios);
+					folio, dst, ctl, ret_folios);
 			/*
 			 * The rules are:
 			 *	0: folio will be freed
@@ -1811,8 +1810,8 @@ static void migrate_folios_undo(struct list_head *src_folios,
  */
 static int move_movable_ops_page(struct folio *src,
 		new_folio_t get_new_folio, free_folio_t put_new_folio,
-		unsigned long private, enum migrate_mode mode,
-		enum migrate_reason reason, struct list_head *ret_folios)
+		unsigned long private, const struct migrate_control *ctl,
+		struct list_head *ret_folios)
 {
 	struct folio *dst;
 	int rc = -EAGAIN;
@@ -1822,7 +1821,7 @@ static int move_movable_ops_page(struct folio *src,
 		return -ENOMEM;
 
 	if (!folio_trylock(src)) {
-		if (mode == MIGRATE_ASYNC)
+		if (ctl->mode == MIGRATE_ASYNC)
 			goto out_put_dst;
 		if (current->flags & PF_MEMALLOC)
 			goto out_put_dst;
@@ -1832,19 +1831,19 @@ static int move_movable_ops_page(struct folio *src,
 	if (unlikely(!folio_trylock(dst)))
 		goto out_unlock_src;
 
-	rc = migrate_movable_ops_page(&dst->page, &src->page, mode);
+	rc = migrate_movable_ops_page(&dst->page, &src->page, ctl->mode);
 	folio_unlock(dst);
 	if (rc)
 		goto out_unlock_src;
 
-	folio_set_owner_migrate_reason(dst, reason);
+	folio_set_owner_migrate_reason(dst, ctl->reason);
 	/* Drop migration's reference after transferring ownership to dst. */
 	folio_put(dst);
 
 	list_del(&src->lru);
 	folio_unlock(src);
 
-	if (reason != MR_MEMORY_FAILURE)
+	if (ctl->reason != MR_MEMORY_FAILURE)
 		folio_put(src);
 
 	return 0;
@@ -1872,8 +1871,8 @@ static int move_movable_ops_page(struct folio *src,
  */
 static int migrate_movable_ops_pages(struct list_head *from,
 		new_folio_t get_new_folio, free_folio_t put_new_folio,
-		unsigned long private, enum migrate_mode mode,
-		enum migrate_reason reason, struct migrate_pages_stats *stats,
+		unsigned long private, const struct migrate_control *ctl,
+		struct migrate_pages_stats *stats,
 		struct list_head *ret_folios)
 {
 	int retry = 1;
@@ -1895,7 +1894,7 @@ static int migrate_movable_ops_pages(struct list_head *from,
 
 			rc = move_movable_ops_page(folio, get_new_folio,
 						   put_new_folio, private,
-						   mode, reason, ret_folios);
+						   ctl, ret_folios);
 			switch (rc) {
 			case -ENOMEM:
 				/* Count this page and those awaiting retry. */
@@ -1933,17 +1932,17 @@ static int migrate_movable_ops_pages(struct list_head *from,
  * unmap phase.
  */
 static int migrate_folio_split_on_alloc_fail(struct folio *folio,
-		struct list_head *split_folios, enum migrate_mode mode,
-		enum migrate_reason reason, struct migrate_pages_stats *stats)
+		struct list_head *split_folios, const struct migrate_control *ctl,
+		struct migrate_pages_stats *stats)
 {
 	bool is_thp = folio_test_pmd_mappable(folio);
 	int rc;
 
 	/* Large folio NUMA faulting doesn't split to retry. */
-	if (!folio_test_large(folio) || reason == MR_NUMA_MISPLACED)
+	if (!folio_test_large(folio) || ctl->reason == MR_NUMA_MISPLACED)
 		return -ENOMEM;
 
-	rc = try_split_folio(folio, split_folios, mode);
+	rc = try_split_folio(folio, split_folios, ctl->mode);
 	if (!rc) {
 		stats->nr_thp_split += is_thp;
 		stats->nr_split++;
@@ -1954,7 +1953,7 @@ static int migrate_folio_split_on_alloc_fail(struct folio *folio,
 	 * Try again to split large folio to mitigate the failure of longterm
 	 * pinning.
 	 */
-	if (reason == MR_LONGTERM_PIN && rc == -EAGAIN)
+	if (ctl->reason == MR_LONGTERM_PIN && rc == -EAGAIN)
 		return -EAGAIN;
 
 	return -ENOMEM;
@@ -1970,7 +1969,7 @@ static int migrate_folio_split_on_alloc_fail(struct folio *folio,
  */
 static int migrate_folios_unmap(struct list_head *from,
 		new_folio_t get_new_folio, free_folio_t put_new_folio,
-		unsigned long private, enum migrate_mode mode, enum migrate_reason reason,
+		unsigned long private, const struct migrate_control *ctl,
 		struct list_head *ret_folios, struct list_head *split_folios,
 		struct list_head *unmap_folios, struct list_head *dst_folios,
 		struct migrate_pages_stats *stats, int nr_pass, int *nr_failed)
@@ -2020,7 +2019,7 @@ static int migrate_folios_unmap(struct list_head *from,
 			if (nr_pages > 2 &&
 			   !list_empty(&folio->_deferred_list) &&
 			   folio_test_partially_mapped(folio)) {
-				if (!try_split_folio(folio, split_folios, mode)) {
+				if (!try_split_folio(folio, split_folios, ctl->mode)) {
 					*nr_failed += 1;
 					stats->nr_thp_failed += is_thp;
 					stats->nr_thp_split += is_thp;
@@ -2042,7 +2041,7 @@ static int migrate_folios_unmap(struct list_head *from,
 			if (!thp_migration_supported() && is_thp) {
 				*nr_failed += 1;
 				stats->nr_thp_failed++;
-				if (!try_split_folio(folio, split_folios, mode)) {
+				if (!try_split_folio(folio, split_folios, ctl->mode)) {
 					stats->nr_thp_split++;
 					stats->nr_split++;
 					continue;
@@ -2060,14 +2059,14 @@ static int migrate_folios_unmap(struct list_head *from,
 				folio_clear_active(folio);
 				folio_clear_unevictable(folio);
 				list_del(&folio->lru);
-				migrate_folio_done(folio, reason);
+				migrate_folio_done(folio, ctl);
 				stats->nr_succeeded += nr_pages;
 				stats->nr_thp_succeeded += is_thp;
 				continue;
 			}
 
 			rc = migrate_folio_unmap(get_new_folio, put_new_folio,
-					private, folio, &dst, mode, ret_folios);
+					private, folio, &dst, ctl, ret_folios);
 			/*
 			 * The rules are:
 			 *	0: folio will be put on unmap_folios list,
@@ -2086,7 +2085,7 @@ static int migrate_folios_unmap(struct list_head *from,
 				stats->nr_thp_failed += is_thp;
 
 				split_rc = migrate_folio_split_on_alloc_fail(folio,
-						split_folios, mode, reason, stats);
+						split_folios, ctl, stats);
 				if (!split_rc)
 					break;
 				/* Retry this folio in a later pass. */
@@ -2145,7 +2144,7 @@ static int migrate_folios_unmap(struct list_head *from,
  */
 static int migrate_folios_batch(struct list_head *from,
 		new_folio_t get_new_folio, free_folio_t put_new_folio,
-		unsigned long private, enum migrate_mode mode, enum migrate_reason reason,
+		unsigned long private, const struct migrate_control *ctl,
 		struct list_head *ret_folios, struct list_head *split_folios,
 		struct migrate_pages_stats *stats, int nr_pass)
 {
@@ -2154,11 +2153,11 @@ static int migrate_folios_batch(struct list_head *from,
 	LIST_HEAD(unmap_folios);
 	LIST_HEAD(dst_folios);
 
-	VM_WARN_ON_ONCE(mode != MIGRATE_ASYNC &&
+	VM_WARN_ON_ONCE(ctl->mode != MIGRATE_ASYNC &&
 			!list_empty(from) && !list_is_singular(from));
 
 	rc_saved = migrate_folios_unmap(from, get_new_folio, put_new_folio,
-			private, mode, reason, ret_folios, split_folios,
+			private, ctl, ret_folios, split_folios,
 			&unmap_folios, &dst_folios, stats, nr_pass,
 			&nr_failed);
 	if (rc_saved && list_empty(&unmap_folios)) {
@@ -2171,7 +2170,7 @@ static int migrate_folios_batch(struct list_head *from,
 
 	/* Move the unmapped folios */
 	migrate_folios_move(&unmap_folios, &dst_folios, put_new_folio, private,
-			mode, reason, ret_folios, stats, nr_pass, &nr_failed);
+			ctl, ret_folios, stats, nr_pass, &nr_failed);
 
 	rc = rc_saved ? : nr_failed;
 out:
@@ -2189,27 +2188,29 @@ static int migrate_folios_batch(struct list_head *from,
  */
 static int __migrate_lru_folios(struct list_head *from, new_folio_t get_new_folio,
 		free_folio_t put_new_folio, unsigned long private,
-		enum migrate_mode mode, enum migrate_reason reason,
-		struct list_head *ret_folios,
+		const struct migrate_control *ctl, struct list_head *ret_folios,
 		struct migrate_pages_stats *stats)
 {
 	int rc, nr_failed = 0;
 	LIST_HEAD(folios);
 	LIST_HEAD(split_folios);
 	struct migrate_pages_stats astats;
+	struct migrate_control async_ctl;
 
-	if (mode == MIGRATE_ASYNC) {
+	if (ctl->mode == MIGRATE_ASYNC) {
 		rc = migrate_folios_batch(from, get_new_folio, put_new_folio,
-				private, mode, reason, ret_folios,
+				private, ctl, ret_folios,
 				&split_folios, stats,
 				NR_MAX_MIGRATE_PAGES_RETRY);
 		goto out;
 	}
 
+	async_ctl = *ctl;
+	async_ctl.mode = MIGRATE_ASYNC;
 	memset(&astats, 0, sizeof(astats));
 	/* Try to migrate in batch with MIGRATE_ASYNC mode firstly */
 	rc = migrate_folios_batch(from, get_new_folio, put_new_folio, private,
-			MIGRATE_ASYNC, reason, &folios, &split_folios, &astats,
+			&async_ctl, &folios, &split_folios, &astats,
 			NR_MAX_MIGRATE_ASYNC_RETRY);
 	stats->nr_succeeded += astats.nr_succeeded;
 	stats->nr_thp_succeeded += astats.nr_thp_succeeded;
@@ -2236,8 +2237,7 @@ static int __migrate_lru_folios(struct list_head *from, new_folio_t get_new_foli
 	while (!list_empty(from)) {
 		list_move(from->next, &folios);
 		rc = migrate_folios_batch(&folios, get_new_folio, put_new_folio,
-				private, mode, reason, ret_folios,
-				&split_folios, stats,
+				private, ctl, ret_folios, &split_folios, stats,
 				NR_MAX_MIGRATE_SYNC_RETRY);
 		list_splice_tail_init(&folios, ret_folios);
 		if (rc < 0)
@@ -2255,7 +2255,7 @@ static int __migrate_lru_folios(struct list_head *from, new_folio_t get_new_foli
 		 * folio they came from was already counted as one failure.
 		 */
 		migrate_folios_batch(&split_folios, get_new_folio, put_new_folio,
-				private, MIGRATE_ASYNC, reason, ret_folios,
+				private, &async_ctl, ret_folios,
 				NULL, stats, 1);
 		list_splice_tail_init(&split_folios, ret_folios);
 	}
@@ -2270,7 +2270,7 @@ static int __migrate_lru_folios(struct list_head *from, new_folio_t get_new_foli
  */
 static int migrate_lru_folios(struct list_head *from, new_folio_t get_new_folio,
 		free_folio_t put_new_folio, unsigned long private,
-		enum migrate_mode mode, enum migrate_reason reason,
+		const struct migrate_control *ctl,
 		struct list_head *ret_folios,
 		struct migrate_pages_stats *stats)
 {
@@ -2292,7 +2292,7 @@ static int migrate_lru_folios(struct list_head *from, new_folio_t get_new_folio,
 			list_splice_init(from, &folios);
 
 		rc = __migrate_lru_folios(&folios, get_new_folio, put_new_folio,
-				private, mode, reason, ret_folios, stats);
+				private, ctl, ret_folios, stats);
 		list_splice_tail_init(&folios, ret_folios);
 		if (rc < 0)
 			return rc;
@@ -2335,18 +2335,22 @@ int migrate_pages(struct list_head *from, new_folio_t get_new_folio,
 	int rc, rc_gather;
 	LIST_HEAD(ret_folios);
 	struct migrate_pages_stats stats;
+	const struct migrate_control ctl = {
+		.mode = mode,
+		.reason = reason,
+	};
 
-	trace_mm_migrate_pages_start(mode, reason);
+	trace_mm_migrate_pages_start(ctl.mode, ctl.reason);
 
 	memset(&stats, 0, sizeof(stats));
 
 	rc_gather = migrate_hugetlbs(from, get_new_folio, put_new_folio, private,
-				     mode, reason, &stats, &ret_folios);
+				     &ctl, &stats, &ret_folios);
 	if (rc_gather < 0)
 		goto out;
 
 	rc = migrate_movable_ops_pages(from, get_new_folio, put_new_folio,
-				       private, mode, reason, &stats,
+				       private, &ctl, &stats,
 				       &ret_folios);
 	if (rc < 0) {
 		rc_gather = rc;
@@ -2355,7 +2359,7 @@ int migrate_pages(struct list_head *from, new_folio_t get_new_folio,
 	rc_gather += rc;
 
 	rc = migrate_lru_folios(from, get_new_folio, put_new_folio,
-			private, mode, reason, &ret_folios, &stats);
+			private, &ctl, &ret_folios, &stats);
 	if (rc < 0) {
 		rc_gather = rc;
 		goto out;
@@ -2382,8 +2386,8 @@ int migrate_pages(struct list_head *from, new_folio_t get_new_folio,
 	count_vm_events(THP_MIGRATION_SPLIT, stats.nr_thp_split);
 	trace_mm_migrate_pages(stats.nr_succeeded, stats.nr_failed_pages,
 			       stats.nr_thp_succeeded, stats.nr_thp_failed,
-			       stats.nr_thp_split, stats.nr_split, mode,
-			       reason);
+			       stats.nr_thp_split, stats.nr_split, ctl.mode,
+			       ctl.reason);
 
 	if (ret_succeeded)
 		*ret_succeeded = stats.nr_succeeded;

-- 
2.43.0

