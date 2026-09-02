Received: from CH4PR04CU002.outbound.protection.outlook.com (mail-northcentralusazon11013005.outbound.protection.outlook.com [40.107.201.5])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1F4EF4756BC;
	Wed,  2 Sep 2026 10:53:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=40.107.201.5
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788346414; cv=fail; b=Sw2oSSjFUwGJQFL5goLgUB+eqkv04tHWawZte87K35XsDyrB9w3kraW1OxSmq+hig2PfD1CYDg70bhmxFKiz993nHJs4pR72wW/zabq9XXjrBvVMrXz2D0Jj1K3hmLPVoDpn0buejhOl62ZtFfJ7pA14ZYAW1B4rFLD+NaToVyk=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788346414; c=relaxed/simple;
	bh=RzsQpuq/nFhcE4vUneY1Dkea/cwh24Q+Fcfa4e0Y1IY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-ID:References:
	 In-Reply-To:To:CC; b=fJERqiTLRsG2V0kMs4IHRYC0/Ih6kZsMJaih1ls4fj92xmst2AieTXM4/PL7IfODA+ryIcWnLn3SsuWKaCtlkqoD/CfOhRfkZrR6A9Pa5MK8Rtc6tHbV/T0ohvKtPC2Q6OT5uIrvWvQZnDvEjFeNWY6dg9Il5rcwzZGep/Itj8M=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amd.com; spf=fail smtp.mailfrom=amd.com; dkim=pass (1024-bit key) header.d=amd.com header.i=@amd.com header.b=d/c2UT43; arc=fail smtp.client-ip=40.107.201.5
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amd.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=amd.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=amd.com header.i=@amd.com header.b="d/c2UT43"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=AGGx7cAWXnPvbO+dk0ngaxXsfIOKI5Zehvts5d8NShyWjrnoyyoOqo9wlBZJ0NOoFwJzHKTI8Ejrsh9ue/7g+wAYEevz+MQlU4l0G3rB6J63Zm6Lrgqg33ywPHBNbh43GHaYPdYQfKjKRcoBdFIgc+tK+rbFPphBUTkoyXwqh5I85i9gUQi1NGoK4qcuROeMxvjQudzVyFlDWvdhXSbNYAaICN2ZkUdAX9knYCzHZV7MpgVSPWYd7kQEjG1s6+EHemnmnMvyOyMjBeTrCo7qsH9gw9ewhQcZxqCNXoTScgKqqHtAYEHP30EbZblXqGAMbZHP1rsfQVjVyF+uo6OLXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=pE9co85aDR/F++LDVwEW5UciCB+/hgsn1n/YSWS2h6Y=;
 b=HN0W0mjPKpzVD5qe8D6GcQG4Zpz8F76Xt45rNuZsk5qa9w9O1oM/s6mukxH26yjIBq3h++Rk7szX0EuDfw9r990W2BnW4PBmUQmlQ+T49p/tCUAssvN2EKquZkK5PD8aFgUmNfOYH7b6lpAzOsPZ2VAhLvh/qHcNJtwvBRG/6uQ40xSxNnRSXM0UsGfiPbjs5WQKXrzYRGv+Rqd/4VQA3GFBDo6fwHjIYx9GvOmRB5cqB7m/y+EqZ1j1ukWeX3iHgyXCWrZGceWv+wFh0bbycvbX7Cifv8J6fWxgtJr74sdM6U5pMpq5wNXoAbw6x8U79RBzgKtDeGEv9VoB0+ccUw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass (sender ip is
 165.204.84.17) smtp.rcpttodomain=sk.com smtp.mailfrom=amd.com; dmarc=pass
 (p=quarantine sp=quarantine pct=100) action=none header.from=amd.com;
 dkim=none (message not signed); arc=none (0)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=amd.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=pE9co85aDR/F++LDVwEW5UciCB+/hgsn1n/YSWS2h6Y=;
 b=d/c2UT430aVl7vj1u7rUsnHe1BPlCy3aqn+lOaY6MVKDaE5D9ehNrfE0ysnm55rQR+OdA2sH/mjdXDauT9bZ6GrrDwAnHlNk2XqudnKp5Cq5dAAqkjg9fRkJU+nrbLhP3azKcRfrMBhfJqJcTFfWuJOWjdptOOZfj3wywJTu7RU=
Received: from BN0PR02CA0047.namprd02.prod.outlook.com (2603:10b6:408:e5::22)
 by DS0PR12MB9060.namprd12.prod.outlook.com (2603:10b6:8:c4::12) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.360.13; Wed, 2 Sep
 2026 10:53:10 +0000
Received: from BN1PEPF00004683.namprd03.prod.outlook.com
 (2603:10b6:408:e5:cafe::37) by BN0PR02CA0047.outlook.office365.com
 (2603:10b6:408:e5::22) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.382.11 via Frontend Transport; Wed, 2
 Sep 2026 10:53:10 +0000
X-MS-Exchange-Authentication-Results: spf=pass (sender IP is 165.204.84.17)
 smtp.mailfrom=amd.com; dkim=none (message not signed)
 header.d=none;dmarc=pass action=none header.from=amd.com;
Received-SPF: Pass (protection.outlook.com: domain of amd.com designates
 165.204.84.17 as permitted sender) receiver=protection.outlook.com;
 client-ip=165.204.84.17; helo=satlexmb07.amd.com; pr=C
Received: from satlexmb07.amd.com (165.204.84.17) by
 BN1PEPF00004683.mail.protection.outlook.com (10.167.243.89) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.21.382.8 via Frontend Transport; Wed, 2 Sep 2026 10:53:10 +0000
Received: from [127.0.1.1] (10.180.168.240) by satlexmb07.amd.com
 (10.181.42.216) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.46; Wed, 2 Sep
 2026 05:52:56 -0500
From: Shivank Garg <shivankg@amd.com>
Date: Wed, 2 Sep 2026 10:52:16 +0000
Subject: [PATCH RFC 02/11] mm/migrate: handle retries in
 migrate_folios_move()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-ID: <20260902-migrate-refactor-shivank-v1-2-9dcca87669c4@amd.com>
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
X-Developer-Signature: v=1; a=ed25519-sha256; t=1788346348; l=4845;
 i=shivankg@amd.com; s=20260518; h=from:subject:message-id;
 bh=RzsQpuq/nFhcE4vUneY1Dkea/cwh24Q+Fcfa4e0Y1IY=;
 b=PKss8nrPoTGv7s7z+Uemf5NWtBYz6x1kgLF59bnjeZKk8C0sg+mJBwc15dt3GRUkGkLItFKjl
 vduKOsF0MhQAMYQ0f4oqUqQSFGcGfGccCdETD3xTKqN29CK2A1WBgBG
X-Developer-Key: i=shivankg@amd.com; a=ed25519;
 pk=2l2QGTeXuGkZTtfmx0nPQU8iFZfjYmX/ymMojitevx4=
X-ClientProxiedBy: satlexmb08.amd.com (10.181.42.217) To satlexmb07.amd.com
 (10.181.42.216)
X-EOPAttributedMessage: 0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: BN1PEPF00004683:EE_|DS0PR12MB9060:EE_
X-MS-Office365-Filtering-Correlation-Id: 30478cca-e29d-421e-b75e-08df08e06110
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|23010399003|36860700016|82310400026|1800799024|7416014|376014|921020|6133799003|56012099006|10067099003|11063799006|22082099003|3023799007|18002099003;
X-Microsoft-Antispam-Message-Info:
	CYeto4gR7y2zfNvtnh2wkvDlEY7F9pAELuj1NYAXMJmJATf622IbZ6qpkfhO+3x5nC9vt4+QwJb/uz88qUA89pIlUcUjiAtutrTewHCKVtgeazuokA1ihcUaYL56Fn6/llVnzcuWUKuRr1JWUyl8sW85QpN0zPw13c4+3tkhFnh3+sSsVcIKHdZIiYB5tfzCmDNFqyW+worjvLMBvz7RL0/mfdpXo6SPVBX3f/YCw6sHw+O9CxJed29mXD7czHGKc8zvnvlkDifTfrrfiWwLGIefodt1+ymZ93tOVfCi0iv07eiVKmiS2uS/F7EAm8Wi9HaoMZ0tAZ5NnxYUDfzmeXkkcGthTxaIZvagetI4lYpfbJgeWCtQuqHsU1Xgks1grXvCNwQneXd1OCZrz6058Jbsvoe9kaExnA4Zb4zKv6o5va7+k2AeP89hke4x7P290Tdi8Y4SIsTpwJSiRrgKZ0Ir+g9yVguA828cOF9iO/qpaAuQmsueIyCIMvBdw8TssmTYlN+E+ofsc7YMWfAamdxITBiasAtfNfASQdXJc9nP3Q/22l6Rix1YtRND127AhYia9UnFsrQMAIDHjow/4nne7pDzBLwqguxfq4kRBcFhahIWLn29x6tmdZQOYI3ZhbD6ow2OcaMwluqmdBC3ZDrgp7JaUWBIWU6ftresVs0ngAYY0Lgwn5Zc/GV5Ow0PLfMbiijMKAFioSvNyA76DPsGN30g+wZvUNjbHTW9WaJfFmvJKW0kunZxIo/UnbsE
X-Forefront-Antispam-Report:
	CIP:165.204.84.17;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:satlexmb07.amd.com;PTR:InfoDomainNonexistent;CAT:NONE;SFS:(13230040)(23010399003)(36860700016)(82310400026)(1800799024)(7416014)(376014)(921020)(6133799003)(56012099006)(10067099003)(11063799006)(22082099003)(3023799007)(18002099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	166o3IsiLT4XRf6KeNYrIh27+Su+2jotCPja4qHH8WVaE8e1+AOn2oABcnQavHvHINQbVX8EREvojV+RG9cFja6lDgvJEGpiPHH+5juuuDJiyvGZvW7C6ns0Gi3Sa+fc76hkSRaduHmmAbD9+PW1Mu/7xmGOIzX2rIO5hg5m4Lnk8C9xe6GTqbEN3HhuILK5/XmfU3QTtNPWuZLcFpdlVikBiPpH4kTonLrIaGoKG89PJxFuoK/OYTzXkNen5PC0/xBgMhfsn1bZPkvK2UhNTZ7Xjhlc1LdqtGIXGSsEqLktw7BFONNWGFBuVe56vPBUqbGSVXJf/RCjEH+cV86LlrWtAXrzvkZ1frNffghBMhl+Zgf298y/WToYCDPAVkYB2GjcFPsP8Mh8O4SnNOh3u1LZpoXHCeTr8rSlISrmY4HYuSspebLCKUQj8SAzq+9A
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 02 Sep 2026 10:53:10.3692
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 30478cca-e29d-421e-b75e-08df08e06110
X-MS-Exchange-CrossTenant-Id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=3dd8961f-e488-4e60-8e11-a82d994e183d;Ip=[165.204.84.17];Helo=[satlexmb07.amd.com]
X-MS-Exchange-CrossTenant-AuthSource:
	BN1PEPF00004683.namprd03.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DS0PR12MB9060

After extracting the unmap phase, migrate_pages_batch() still drives the
retry loop for the move phase and passes its retry bookkeeping to
migrate_folios_move(). This splits the move phase across the two
functions and requires several output parameters.

Move the retry loop and its bookkeeping into migrate_folios_move().
The function now takes the number of passes and reports failures through
@nr_failed, matching migrate_folios_unmap().

No functional change is intended.

Signed-off-by: Shivank Garg <shivankg@amd.com>
---
 mm/migrate.c | 104 ++++++++++++++++++++++++++++-------------------------------
 1 file changed, 49 insertions(+), 55 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 14a0f84009c6..89207bf515b9 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1729,51 +1729,61 @@ static void migrate_folios_move(struct list_head *src_folios,
 		free_folio_t put_new_folio, unsigned long private,
 		enum migrate_mode mode, enum migrate_reason reason,
 		struct list_head *ret_folios,
-		struct migrate_pages_stats *stats,
-		int *retry, int *thp_retry, int *nr_failed,
-		int *nr_retry_pages)
+		struct migrate_pages_stats *stats, int nr_pass,
+		int *nr_failed)
 {
 	struct folio *folio, *folio2, *dst, *dst2;
+	int retry = 1;
+	int thp_retry = 0;
+	int nr_retry_pages = 0;
 	bool is_thp;
 	int nr_pages;
-	int rc;
+	int pass, rc;
 
-	dst = list_first_entry(dst_folios, struct folio, lru);
-	dst2 = list_next_entry(dst, lru);
-	list_for_each_entry_safe(folio, folio2, src_folios, lru) {
-		is_thp = folio_test_large(folio) && folio_test_pmd_mappable(folio);
-		nr_pages = folio_nr_pages(folio);
+	for (pass = 0; pass < nr_pass && retry; pass++) {
+		retry = 0;
+		thp_retry = 0;
+		nr_retry_pages = 0;
 
-		cond_resched();
+		dst = list_first_entry(dst_folios, struct folio, lru);
+		dst2 = list_next_entry(dst, lru);
+		list_for_each_entry_safe(folio, folio2, src_folios, lru) {
+			is_thp = folio_test_large(folio) && folio_test_pmd_mappable(folio);
+			nr_pages = folio_nr_pages(folio);
 
-		rc = migrate_folio_move(put_new_folio, private,
-				folio, dst, mode,
-				reason, ret_folios);
-		/*
-		 * The rules are:
-		 *	0: folio will be freed
-		 *	-EAGAIN: stay on the src_folios list
-		 *	Other errno: put on ret_folios list
-		 */
-		switch (rc) {
-		case -EAGAIN:
-			*retry += 1;
-			*thp_retry += is_thp;
-			*nr_retry_pages += nr_pages;
-			break;
-		case 0:
-			stats->nr_succeeded += nr_pages;
-			stats->nr_thp_succeeded += is_thp;
-			break;
-		default:
-			*nr_failed += 1;
-			stats->nr_thp_failed += is_thp;
-			stats->nr_failed_pages += nr_pages;
-			break;
+			cond_resched();
+
+			rc = migrate_folio_move(put_new_folio, private,
+					folio, dst, mode, reason, ret_folios);
+			/*
+			 * The rules are:
+			 *	0: folio will be freed
+			 *	-EAGAIN: stay on the src_folios list
+			 *	Other errno: put on ret_folios list
+			 */
+			switch (rc) {
+			case -EAGAIN:
+				retry++;
+				thp_retry += is_thp;
+				nr_retry_pages += nr_pages;
+				break;
+			case 0:
+				stats->nr_succeeded += nr_pages;
+				stats->nr_thp_succeeded += is_thp;
+				break;
+			default:
+				*nr_failed += 1;
+				stats->nr_thp_failed += is_thp;
+				stats->nr_failed_pages += nr_pages;
+				break;
+			}
+			dst = dst2;
+			dst2 = list_next_entry(dst, lru);
 		}
-		dst = dst2;
-		dst2 = list_next_entry(dst, lru);
 	}
+	*nr_failed += retry;
+	stats->nr_thp_failed += thp_retry;
+	stats->nr_failed_pages += nr_retry_pages;
 }
 
 static void migrate_folios_undo(struct list_head *src_folios,
@@ -2000,11 +2010,7 @@ static int migrate_pages_batch(struct list_head *from,
 		struct list_head *ret_folios, struct list_head *split_folios,
 		struct migrate_pages_stats *stats, int nr_pass)
 {
-	int retry = 1;
-	int thp_retry = 1;
 	int nr_failed = 0;
-	int nr_retry_pages = 0;
-	int pass = 0;
 	int rc, rc_saved;
 	LIST_HEAD(unmap_folios);
 	LIST_HEAD(dst_folios);
@@ -2024,21 +2030,9 @@ static int migrate_pages_batch(struct list_head *from,
 	/* Flush TLBs for all unmapped folios */
 	try_to_unmap_flush();
 
-	retry = 1;
-	for (pass = 0; pass < nr_pass && retry; pass++) {
-		retry = 0;
-		thp_retry = 0;
-		nr_retry_pages = 0;
-
-		/* Move the unmapped folios */
-		migrate_folios_move(&unmap_folios, &dst_folios,
-				put_new_folio, private, mode, reason,
-				ret_folios, stats, &retry, &thp_retry,
-				&nr_failed, &nr_retry_pages);
-	}
-	nr_failed += retry;
-	stats->nr_thp_failed += thp_retry;
-	stats->nr_failed_pages += nr_retry_pages;
+	/* Move the unmapped folios */
+	migrate_folios_move(&unmap_folios, &dst_folios, put_new_folio, private,
+			mode, reason, ret_folios, stats, nr_pass, &nr_failed);
 
 	rc = rc_saved ? : nr_failed;
 out:

-- 
2.43.0

