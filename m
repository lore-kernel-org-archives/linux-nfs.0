Received: from PH7PR06CU001.outbound.protection.outlook.com (mail-westus3azon11010000.outbound.protection.outlook.com [52.101.201.0])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 14B6B46C852;
	Wed,  2 Sep 2026 10:53:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.201.0
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788346447; cv=fail; b=Z2zBlzvWZgm/K52PgO844cs7GgHWQT5YGta5mO0eKCNkv5tIDgg2aDe3sTQJLWiym2zVfkVW4uzkttPtgrmrMIvIuBPLFj2el5eOi78wlkXSveR4Z6OJRyr7LCBS/rwTDS29oPeyQTC2FM1QulBcGBdoWwqLFxwePboGRiiA8Dk=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788346447; c=relaxed/simple;
	bh=VlSFNAND6SnpBBF3+pJnsJtkrGSAlaiY/oieiuTQDjI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-ID:References:
	 In-Reply-To:To:CC; b=r3IiQib97OgFR1ywEyn9YiDL5oaATw39NMT2gQol5UU2zLbrfAPrx81DWc7bw43qifeJn5iQ5bahAbdnZo9K9/kDxdZv2uK2AVYK3idS5AiHouoYeSQU833LUd+b4QQ2OyZiMPcRNCf6UkRIpq9Ty8SMaB9tUhkf5ICDQAn/lGs=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amd.com; spf=fail smtp.mailfrom=amd.com; dkim=pass (1024-bit key) header.d=amd.com header.i=@amd.com header.b=ATwjC9Ve; arc=fail smtp.client-ip=52.101.201.0
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amd.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=amd.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=amd.com header.i=@amd.com header.b="ATwjC9Ve"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=vfBc8V3lffiFXIMLjB8dH3ZhojZvpCnSSOkpK3QdTWy8wT438zireTSQezbCO+iTSXIxMFaynxLZydTeUodhvI90QwXG4RHQ5fO1bPLSpvLh6c+fCWYNBt0KJC2UlJPoEsHMEyrjNlDzE6hdRW2tIa+JOK3UNWgoe8O+6m0z6xE5hRUfLKHxcoJPk/EUh/nDkjQZqfyIadYkOjZ7VnMieic30xKQ92YZzIwUim0iTXQLUXK8ROGGtYWdEV31PEDh2zd077xif6fs9pbu/rUzVWSxGl2APL887dfI+WT3vHuV3c/WYooynLszIfF75fuxNn0ZhkvpnnIwA5PtePjnYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=aWr4bvvbw5bvm5oL4VFn72K+pg4VO4PWtKMFN92Gnm8=;
 b=O4rOBNGy93vdyhKJsYYPw5eZ+t/iJcPSbHV7gdPe0dmLePNHuy9odl508OTh+9vSc32b84uy6OujwlMn9tz1MAMfOmzTURp9OJLARDif7artjo9w0ONyi0dwpxNZd+oJQl2eequGCyUlLJqdqi1OM6ybYid0R8TMtzAkWhO0pMldsBk7oNKzJBL4M+JacuzyAFkKh0GxWPRDeEwEPMzjv7u3pQVwqd5CBMjHP7mBRFji0MckhrDN+GzngxtPOM686cNQtmGpaoAZECnr7FzpsPEusxg2VVbRxReP/1IK4DU7IXtgW3Aovg9R7z+gbH2MTqTbZdWfKdJ/A9IoBEGBhQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass (sender ip is
 165.204.84.17) smtp.rcpttodomain=sk.com smtp.mailfrom=amd.com; dmarc=pass
 (p=quarantine sp=quarantine pct=100) action=none header.from=amd.com;
 dkim=none (message not signed); arc=none (0)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=amd.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=aWr4bvvbw5bvm5oL4VFn72K+pg4VO4PWtKMFN92Gnm8=;
 b=ATwjC9VeszYc9gTgolpFejMaLxu5BJWLvGIHADakcasmIpKYn3ZlhWclJ40334QiRO7Ya528Tn26+Z7N8OhwuuVnNE6BvkBDcHBU3WNAbVoci4m08eQitinppRjzCXo7BuS4gnwJ1jV6YBggbQl7W9VqTr6PX4S4BD3MJHyZWk4=
Received: from BN0PR07CA0022.namprd07.prod.outlook.com (2603:10b6:408:141::14)
 by SN7PR12MB7105.namprd12.prod.outlook.com (2603:10b6:806:2a0::16) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.360.13; Wed, 2 Sep
 2026 10:53:38 +0000
Received: from BN1PEPF00004683.namprd03.prod.outlook.com
 (2603:10b6:408:141:cafe::85) by BN0PR07CA0022.outlook.office365.com
 (2603:10b6:408:141::14) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.382.11 via Frontend Transport; Wed, 2
 Sep 2026 10:53:38 +0000
X-MS-Exchange-Authentication-Results: spf=pass (sender IP is 165.204.84.17)
 smtp.mailfrom=amd.com; dkim=none (message not signed)
 header.d=none;dmarc=pass action=none header.from=amd.com;
Received-SPF: Pass (protection.outlook.com: domain of amd.com designates
 165.204.84.17 as permitted sender) receiver=protection.outlook.com;
 client-ip=165.204.84.17; helo=satlexmb07.amd.com; pr=C
Received: from satlexmb07.amd.com (165.204.84.17) by
 BN1PEPF00004683.mail.protection.outlook.com (10.167.243.89) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.21.382.8 via Frontend Transport; Wed, 2 Sep 2026 10:53:38 +0000
Received: from [127.0.1.1] (10.180.168.240) by satlexmb07.amd.com
 (10.181.42.216) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.46; Wed, 2 Sep
 2026 05:53:24 -0500
From: Shivank Garg <shivankg@amd.com>
Date: Wed, 2 Sep 2026 10:52:18 +0000
Subject: [PATCH RFC 04/11] mm/migrate: use a dedicated list for hugetlb
 folios
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-ID: <20260902-migrate-refactor-shivank-v1-4-9dcca87669c4@amd.com>
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
X-Developer-Signature: v=1; a=ed25519-sha256; t=1788346348; l=3801;
 i=shivankg@amd.com; s=20260518; h=from:subject:message-id;
 bh=VlSFNAND6SnpBBF3+pJnsJtkrGSAlaiY/oieiuTQDjI=;
 b=aw3wzdkKJY9UFNX5TTTWthol5mESU/+Pct7T6sKEZ9lFRDITy/dGihQe0QzZowvjvJuiv7/pL
 vQlQvkOQVpiBP1ZxJVaCn2ZrAgds3kk6XVf50KCgJKSdyk7AaoPz3zv
X-Developer-Key: i=shivankg@amd.com; a=ed25519;
 pk=2l2QGTeXuGkZTtfmx0nPQU8iFZfjYmX/ymMojitevx4=
X-ClientProxiedBy: satlexmb08.amd.com (10.181.42.217) To satlexmb07.amd.com
 (10.181.42.216)
X-EOPAttributedMessage: 0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: BN1PEPF00004683:EE_|SN7PR12MB7105:EE_
X-MS-Office365-Filtering-Correlation-Id: f68a553a-bb09-4804-c7b2-08df08e071dc
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|36860700016|82310400026|376014|7416014|23010399003|1800799024|921020|10067099003|11063799006|56012099006|22082099003|18002099003;
X-Microsoft-Antispam-Message-Info:
	UfdRpVIHS6/Tg9UrLnmJAOaUOQuX0CX09NsEbAn43ij7AY6jfkQDTbgIQ3E+yrXzuisEkgUpDp41ejLTPxjGCCKeU14D3P9814lbwEP28zNzL7v7YTBwZSkCUU1o70m2Q1P8N29v9MJZtxB32CBD+6lcy6s09pgy052JXS+CEWsqmoZaKrn5wwN7BUfRTnq2Zip7WiuGk9ufhXhLSLG8UM1AAkTBiCtFiy/aaGQ/xeNcivaE2sCm9j/Mzm1TehcUJ/G215TCLyheo/2+tyOr4LDPDMJhxP9YPO+38Sck6rSqAGZqyOqTfeAKvdq1IuGYPxjF6UyPmnxNUpzOljmOBZuMxD2KGsLzCoFjmy5Wq/bw52SNmrgzR7RT/Ll6bC6iasjubH/1sHvb5nS9ehnI3De3JunawC8zH385M0ZbEbs5Cw4ehnQuiLvmL3cdRKUszguxxr5+umKriA3SWCrocOZV3FsKWDT8kQmohk3d8Xjxiz8Zl/cJNzRzwCyeqesusPamoRK9qDXy+Yp1ZvfEgKSay5JMlLR5EgJETfyArpk99HIsUwSN5lj3ZploEy9WOh1VvzAx5glyt1nnt4Uh4wcw5IM/1w/rahRuSKvV0aPZABFE6iD7g/zwb0aj5ICjCZdtGuF3cMxJ03BdhZIHYxhHSTWBrpsYfsh+GCJH321H5cuBS/wGi5Kuv/7vSqt15sY1LjWAYHkWx+OSoxOZYCiKnYr6QvwGP4wsEDSVE+We8VuJMYVpgmch2CJpDjq8
X-Forefront-Antispam-Report:
	CIP:165.204.84.17;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:satlexmb07.amd.com;PTR:InfoDomainNonexistent;CAT:NONE;SFS:(13230040)(36860700016)(82310400026)(376014)(7416014)(23010399003)(1800799024)(921020)(10067099003)(11063799006)(56012099006)(22082099003)(18002099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	arY20hyuwLiaSz9KMrD+z6cgcB8BPzyZj56SdmzIQ64I9qsFjUC2F+kZDatEv+blhAM8zWlYFdTSkqxhIIFjAd736snFBNk1H/vm/jCoHxK/gKx7XPEa38gIpyTwZ+CjNkvKpqTr8Y9LbF/o+3uyxlqWiBajgxQXm+gLt6BrzDEKiKkoomHHjmmFVfJjdnwf8yApoeN9SttQxix6Q1qqxKK/ICFqLrErIrVUkH0j9leJBOGbt8ypAzgKYjJ7Wi3Wm1TZvn05FS8DSYVioP/sSJfyZT6q/pdg3pbMcjorRokPBjD3aOYjV0r+7KEB3oQgZi0A+WRPM3dY2R4LQ/d6NeILzXYpHZqy+EVcHRxDnuiDO+lPiz43Q6lfRbJHb0oNYyoWSO4+RaK1fNaLHWm1MBP8T8nxM/fgI7lryo48fTje/RAEyP9gKkCWCqfgQ+7u
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 02 Sep 2026 10:53:38.5472
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: f68a553a-bb09-4804-c7b2-08df08e071dc
X-MS-Exchange-CrossTenant-Id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=3dd8961f-e488-4e60-8e11-a82d994e183d;Ip=[165.204.84.17];Helo=[satlexmb07.amd.com]
X-MS-Exchange-CrossTenant-AuthSource:
	BN1PEPF00004683.namprd03.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN7PR12MB7105

migrate_hugetlbs() scans the full source list on every retry pass, even
though it only handles hugetlb folios.

Move hugetlb folios to a local list before migration and move any remaining
folios to @ret_folios. This avoids scanning unrelated folios and removes
the later hugetlb check from migrate_pages().

No functional change intended.

Signed-off-by: Shivank Garg <shivankg@amd.com>
---
 mm/migrate.c | 43 ++++++++++++++++++++++---------------------
 1 file changed, 22 insertions(+), 21 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 510dfffa7235..7a136cec275f 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1629,11 +1629,12 @@ struct migrate_pages_stats {
 };
 
 /*
- * Returns the number of hugetlb folios that were not migrated, or an error code
- * after NR_MAX_MIGRATE_PAGES_RETRY attempts or if no hugetlb folios are movable
- * any more because the list has become empty or no retryable hugetlb folios
- * exist any more. It is caller's responsibility to call putback_movable_pages()
- * only if ret != 0.
+ * Move hugetlb folios from @from to a local list and try to migrate each folio
+ * up to NR_MAX_MIGRATE_PAGES_RETRY times. Any remaining folios are moved to
+ * @ret_folios list.
+ *
+ * Return the number of failed folios, or a negative errno.
+ *
  */
 static int migrate_hugetlbs(struct list_head *from, new_folio_t get_new_folio,
 			    free_folio_t put_new_folio, unsigned long private,
@@ -1646,16 +1647,18 @@ static int migrate_hugetlbs(struct list_head *from, new_folio_t get_new_folio,
 	int nr_retry_pages = 0;
 	int pass = 0;
 	struct folio *folio, *folio2;
-	int rc, nr_pages;
+	int rc, ret, nr_pages;
+	LIST_HEAD(hugetlbs);
+
+	list_for_each_entry_safe(folio, folio2, from, lru)
+		if (folio_test_hugetlb(folio))
+			list_move_tail(&folio->lru, &hugetlbs);
 
 	for (pass = 0; pass < NR_MAX_MIGRATE_PAGES_RETRY && retry; pass++) {
 		retry = 0;
 		nr_retry_pages = 0;
 
-		list_for_each_entry_safe(folio, folio2, from, lru) {
-			if (!folio_test_hugetlb(folio))
-				continue;
-
+		list_for_each_entry_safe(folio, folio2, &hugetlbs, lru) {
 			nr_pages = folio_nr_pages(folio);
 
 			cond_resched();
@@ -1681,18 +1684,19 @@ static int migrate_hugetlbs(struct list_head *from, new_folio_t get_new_folio,
 			/*
 			 * The rules are:
 			 *	0: hugetlb folio will be put back
-			 *	-EAGAIN: stay on the from list
-			 *	-ENOMEM: stay on the from list
+			 *	-EAGAIN: stay on hugetlbs, retried by a later pass
+			 *	-ENOMEM: give up; rest of the list goes to ret_folios
 			 *	Other errno: put on ret_folios list
 			 */
-			switch(rc) {
+			switch (rc) {
 			case -ENOMEM:
 				/*
 				 * When memory is low, don't bother to try to migrate
 				 * other folios, just exit.
 				 */
 				stats->nr_failed_pages += nr_pages + nr_retry_pages;
-				return -ENOMEM;
+				ret = -ENOMEM;
+				goto out;
 			case -EAGAIN:
 				retry++;
 				nr_retry_pages += nr_pages;
@@ -1720,8 +1724,11 @@ static int migrate_hugetlbs(struct list_head *from, new_folio_t get_new_folio,
 	 */
 	nr_failed += retry;
 	stats->nr_failed_pages += nr_retry_pages;
+	ret = nr_failed;
+out:
+	list_splice_tail(&hugetlbs, ret_folios);
 
-	return nr_failed;
+	return ret;
 }
 
 static void migrate_folios_move(struct list_head *src_folios,
@@ -2161,12 +2168,6 @@ int migrate_pages(struct list_head *from, new_folio_t get_new_folio,
 again:
 	nr_pages = 0;
 	list_for_each_entry_safe(folio, folio2, from, lru) {
-		/* Retried hugetlb folios will be kept in list  */
-		if (folio_test_hugetlb(folio)) {
-			list_move_tail(&folio->lru, &ret_folios);
-			continue;
-		}
-
 		nr_pages += folio_nr_pages(folio);
 		if (nr_pages >= NR_MAX_BATCHED_MIGRATION)
 			break;

-- 
2.43.0

