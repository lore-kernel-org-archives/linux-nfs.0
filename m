Received: from CH4PR04CU002.outbound.protection.outlook.com (mail-northcentralusazon11013070.outbound.protection.outlook.com [40.107.201.70])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C24ED47DD50;
	Wed,  2 Sep 2026 10:54:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=40.107.201.70
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788346461; cv=fail; b=pvhat79osU3VavRYijHpDFY3UZQuvxQLpwCU7oqy32ljgqS3NIW9Tm2qm9/flUX8Q/IfEnuTUqDUcDR2Kvn0YNgo7DblEjJ6h0SwI7/+XgYed8rE4pyhU10uPChivauM/XSjNIiu+wDoCUZE33jWgNDXkCsyocEMhyMMwNaD5oA=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788346461; c=relaxed/simple;
	bh=Fqi07cuj0t9DVgFdFNJBSPyRAcnfPff5xqiyG0YOAAw=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-ID:References:
	 In-Reply-To:To:CC; b=nLtwTCgWCq/wIwV6lcROYDedGOri8UGXfnYTTNtXrcUdlbfIHiPhl+c9a+eWBMCmjF3pnufcqQM3Ix0xuR2fP6DYfWIKwNhkzcgTdkTDNLnIOdRMcp5vgKMKEW6dzqh0VqNfTanD4OauYkC+EBXtAa80N21cLfClorLqlorqLMk=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amd.com; spf=fail smtp.mailfrom=amd.com; dkim=pass (1024-bit key) header.d=amd.com header.i=@amd.com header.b=XkSr4OIV; arc=fail smtp.client-ip=40.107.201.70
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amd.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=amd.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=amd.com header.i=@amd.com header.b="XkSr4OIV"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=iIaoH0+VMqzW4UnCD/UPupJ3APS7/eh14+pokliPzOyQoNk68yQNASNKuzwAFyKDRzBJRA9WRDtfAqXHvvDJRH68DR+7wZCSs+8NlFr/2hapwcD7y7WiedacDyt3DZf6Unj/aatADOHIoCVs75eXGVHvendXS58XnrhFghQVmOSO3pmEI9cf9ipk5HWvWPJsX8yg7nlLoDXoc9gBDwxOZoglIvOuznCW1kOcMDFfU7eYbzvz881rt0f1GCMrkscf7b3acKLoBSHKIbetu4P4lnR1pP31i4doqLGlEx4DH1dsm1Ur9MM0W+uzuZ6phpT49wJ0Len86uzGVrXBFWf/XA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=EUHxLZc87SIo516dLR77xd1rSetSYWKvVm1R29rwnEo=;
 b=DaM5DE60asU/X4fCw0hPREJNYlnf7Yzekpw1pBVAWcAhUwbroSjnETeEf/VMKOBIpqu4EOuOdj1vIlzs2q/o84bGxj0gjShiS5TtWtHcchdVhw0Zo1cs6Lxss6Y0gqYkwNTK9eykZ2WBvjSTxT/+CLDGgtjPMsns1Cn/5xPLcVNAAWFj/MwSB/ByCfNbmUb/+6w5+r4IcluChYYGmXdiup+EnOuGS0mVgq7uXjzIo5nTcjunn37vPkMEDbOYjcLncqP/yW47WbTNJMkR+PymwUN3oxsgO4YBlpFEHOguIKTCxIKGXzWSOw0E/xAeVOWwQx/qxMo72iviGfpmAFxRgw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass (sender ip is
 165.204.84.17) smtp.rcpttodomain=sk.com smtp.mailfrom=amd.com; dmarc=pass
 (p=quarantine sp=quarantine pct=100) action=none header.from=amd.com;
 dkim=none (message not signed); arc=none (0)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=amd.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=EUHxLZc87SIo516dLR77xd1rSetSYWKvVm1R29rwnEo=;
 b=XkSr4OIVNDkzw4Fd4JubaEBjjaNHFc6KjZoEKeDbEFwTO7+X1RJ1v1dV9PFStwADGlz4J49KS+Cue7/JaLMu3iN7V7uPDAWU8BkG2Th6TkFBVOAlnoehF2BAJMVb7I7ngit0Bhw88FHKWISWpgeN+PeubhoPeuULK0R91JjOPZI=
Received: from BN0PR08CA0022.namprd08.prod.outlook.com (2603:10b6:408:142::7)
 by PH7PR12MB5805.namprd12.prod.outlook.com (2603:10b6:510:1d1::13) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.360.13; Wed, 2 Sep
 2026 10:54:08 +0000
Received: from BN5PEPF00046987.namprd02.prod.outlook.com
 (2603:10b6:408:142:cafe::78) by BN0PR08CA0022.outlook.office365.com
 (2603:10b6:408:142::7) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.382.10 via Frontend Transport; Wed, 2
 Sep 2026 10:54:07 +0000
X-MS-Exchange-Authentication-Results: spf=pass (sender IP is 165.204.84.17)
 smtp.mailfrom=amd.com; dkim=none (message not signed)
 header.d=none;dmarc=pass action=none header.from=amd.com;
Received-SPF: Pass (protection.outlook.com: domain of amd.com designates
 165.204.84.17 as permitted sender) receiver=protection.outlook.com;
 client-ip=165.204.84.17; helo=satlexmb07.amd.com; pr=C
Received: from satlexmb07.amd.com (165.204.84.17) by
 BN5PEPF00046987.mail.protection.outlook.com (10.167.245.36) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.21.382.8 via Frontend Transport; Wed, 2 Sep 2026 10:54:06 +0000
Received: from [127.0.1.1] (10.180.168.240) by satlexmb07.amd.com
 (10.181.42.216) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.46; Wed, 2 Sep
 2026 05:53:52 -0500
From: Shivank Garg <shivankg@amd.com>
Date: Wed, 2 Sep 2026 10:52:20 +0000
Subject: [PATCH RFC 06/11] mm/migrate: rename migrate_pages_batch() to
 migrate_folios_batch()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-ID: <20260902-migrate-refactor-shivank-v1-6-9dcca87669c4@amd.com>
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
X-Developer-Signature: v=1; a=ed25519-sha256; t=1788346348; l=4160;
 i=shivankg@amd.com; s=20260518; h=from:subject:message-id;
 bh=Fqi07cuj0t9DVgFdFNJBSPyRAcnfPff5xqiyG0YOAAw=;
 b=VHLvgbIhFwCVKeh3oI8OLZ9ydq0iu/G94dLsgBxliBbC+D46x3iUwPS7POszEmY//eC7P6oMg
 gV+QETr+4YXAqnn+IE+sRMapWHGUQIqQCmMzyFGF194eBrHcUM44WS9
X-Developer-Key: i=shivankg@amd.com; a=ed25519;
 pk=2l2QGTeXuGkZTtfmx0nPQU8iFZfjYmX/ymMojitevx4=
X-ClientProxiedBy: satlexmb08.amd.com (10.181.42.217) To satlexmb07.amd.com
 (10.181.42.216)
X-EOPAttributedMessage: 0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: BN5PEPF00046987:EE_|PH7PR12MB5805:EE_
X-MS-Office365-Filtering-Correlation-Id: 1e69fecc-25f3-4590-34a3-08df08e08298
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|82310400026|23010399003|36860700016|1800799024|7416014|376014|921020|11063799006|56012099006|10067099003|22082099003|18002099003;
X-Microsoft-Antispam-Message-Info:
	wCiWB8umVAN6134xVLMiVPh1HwKUaAPCTI8G4upmfK1rHsH3dPW+47NrjMXaBHkbxJP0py2uYnXLmWTub5t3bIPD5GQn5PswYtQKA007xX6m3iIdRh+PvedmBXNkFfWw3uk1Zs1n892OyOQCMUyErlgHqzXEHxSv7WQEUUth9G78c2UY171U8hhNaRAuEmXXHmkaNAr6kCQttBt05WD5NbxwWr02nSEC5hyZBDh6UZcC6U34cyg4nHhZZ/NefebEZrbyC56nKd1ikttLU4k7PxZPLxPqZ9L/bGc4MzOqeSumrL5Pf6kOeABSNFg5p26wfM6+fhZBoJeY7CyTyH8ytNkM2tlyZ2sEWuT1z92MBM0a5O8BBT1QcwdxYc6cvcUlOX2A9GwBZajnWuYfH10S1xV1HWTEr2/22JGNPQ5bX7RGWKEYm5Bbmc5kn6eK8SuYWLCqEAlBf8q0rlxoaITygu9B8fgzJJgSk3K76CsmPI4P1zDNaXg/FA6vQqQf3IlvH4i5dkQUkDu9St1Dtq16LSuMVAUbQL8LLdM+xNkdDhY7tGL4yl+ayev7tV2cY019zCRv0sFGy1yjkYHeQmzSSVm8u/VxIJHWG1p6Bei1spQFwfhrpDDFvHx6iLPYFUcs55QC+wYEmzom0x6REQZByfUIAJ3KrJtHFft3qM1hQBBaGxB38HLrutWSYIXyLAkDRcpptrV122T+tAOTCdhLeKVwL8BLrejgSyLKANPrUrfZsN/S0rWMabr84xd+3xAn
X-Forefront-Antispam-Report:
	CIP:165.204.84.17;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:satlexmb07.amd.com;PTR:InfoDomainNonexistent;CAT:NONE;SFS:(13230040)(82310400026)(23010399003)(36860700016)(1800799024)(7416014)(376014)(921020)(11063799006)(56012099006)(10067099003)(22082099003)(18002099003);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	Vcf/vHEnOgh/JYtjSJnVGWMwa4G08e5YASq1Da20l61TbFQrUh0TfM/Ey4IZLrnoEOh85gSJoY7XmnsLH6NBvpQGpmKulUgKmI3Cey5TUpjZU0eFCPlikBZ7+oqj8PW4EuGHkYMBLZIiineTHxGRDJTOLwkrnHtKHQIWie+PNrhK3xcv9gLtKOvWf/hbK+uWaAHTsaKNszgZkpLbnbQbX2XNrzPDtEJRDWzwn68YTRheZ0vPJg1EEtAVDQjFkBC2zV43XitVIQoh8AyvQ2Qk5L3LW7VozovrkM3uTu9n+aG+EFiuKVQ/ocAW2vFytHVL8nMWZX9jLvXnjCvoNgUCUmWUC8pNmGc8diOSsK52WyxWEGnOy0LuFMCGM76zyY/Z20ehf1BrE5NEIgLv0UlkQOXkmZjQsMIyggkWD7dC9JFsALXTshnFjcHfhLHK3i6q
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 02 Sep 2026 10:54:06.6144
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 1e69fecc-25f3-4590-34a3-08df08e08298
X-MS-Exchange-CrossTenant-Id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=3dd8961f-e488-4e60-8e11-a82d994e183d;Ip=[165.204.84.17];Helo=[satlexmb07.amd.com]
X-MS-Exchange-CrossTenant-AuthSource:
	BN5PEPF00046987.namprd02.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: PH7PR12MB5805

migrate_pages_batch() operates on folios and calls the folio-based unmap,
move and undo helpers. Now that movable_ops-based page migration has been
separated out, rename it to migrate_folios_batch().

No functional changes intended.

Suggested-by: Zi Yan <ziy@nvidia.com>
Signed-off-by: Shivank Garg <shivankg@amd.com>
---
 mm/migrate.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 55f352efdf2b..163f13344fd2 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2003,7 +2003,7 @@ static int migrate_folios_unmap(struct list_head *from,
 			 * always reports success when its fromlist is empty.
 			 * stats->nr_thp_failed should be increased too,
 			 * otherwise stats inconsistency will happen when
-			 * migrate_pages_batch is called via migrate_pages()
+			 * migrate_folios_batch is called via migrate_pages()
 			 * with MIGRATE_SYNC and MIGRATE_ASYNC.
 			 *
 			 * Only check it without removing it from the list.
@@ -2135,7 +2135,7 @@ static int migrate_folios_unmap(struct list_head *from,
 }
 
 /*
- * migrate_pages_batch() first unmaps as many folios in the source list as
+ * migrate_folios_batch() first unmaps as many folios in the source list as
  * possible, flushes the TLBs, then moves the unmapped folios.
  *
  * Only MIGRATE_ASYNC may batch multiple folios.  Waiting for a lock or bit
@@ -2143,7 +2143,7 @@ static int migrate_folios_unmap(struct list_head *from,
  * Therefore, if mode != MIGRATE_ASYNC, the source list must contain at most
  * one folio.
  */
-static int migrate_pages_batch(struct list_head *from,
+static int migrate_folios_batch(struct list_head *from,
 		new_folio_t get_new_folio, free_folio_t put_new_folio,
 		unsigned long private, enum migrate_mode mode, enum migrate_reason reason,
 		struct list_head *ret_folios, struct list_head *split_folios,
@@ -2194,9 +2194,9 @@ static int migrate_pages_sync(struct list_head *from, new_folio_t get_new_folio,
 
 	memset(&astats, 0, sizeof(astats));
 	/* Try to migrate in batch with MIGRATE_ASYNC mode firstly */
-	rc = migrate_pages_batch(from, get_new_folio, put_new_folio, private, MIGRATE_ASYNC,
-				 reason, &folios, split_folios, &astats,
-				 NR_MAX_MIGRATE_ASYNC_RETRY);
+	rc = migrate_folios_batch(from, get_new_folio, put_new_folio, private,
+			MIGRATE_ASYNC, reason, &folios, split_folios, &astats,
+			NR_MAX_MIGRATE_ASYNC_RETRY);
 	stats->nr_succeeded += astats.nr_succeeded;
 	stats->nr_thp_succeeded += astats.nr_thp_succeeded;
 	stats->nr_thp_split += astats.nr_thp_split;
@@ -2221,9 +2221,9 @@ static int migrate_pages_sync(struct list_head *from, new_folio_t get_new_folio,
 	list_splice_tail_init(&folios, from);
 	while (!list_empty(from)) {
 		list_move(from->next, &folios);
-		rc = migrate_pages_batch(&folios, get_new_folio, put_new_folio,
-					 private, mode, reason, ret_folios,
-					 split_folios, stats, NR_MAX_MIGRATE_SYNC_RETRY);
+		rc = migrate_folios_batch(&folios, get_new_folio, put_new_folio,
+				private, mode, reason, ret_folios, split_folios,
+				stats, NR_MAX_MIGRATE_SYNC_RETRY);
 		list_splice_tail_init(&folios, ret_folios);
 		if (rc < 0)
 			return rc;
@@ -2301,7 +2301,7 @@ int migrate_pages(struct list_head *from, new_folio_t get_new_folio,
 	else
 		list_splice_init(from, &folios);
 	if (mode == MIGRATE_ASYNC)
-		rc = migrate_pages_batch(&folios, get_new_folio, put_new_folio,
+		rc = migrate_folios_batch(&folios, get_new_folio, put_new_folio,
 				private, mode, reason, &ret_folios,
 				&split_folios, &stats,
 				NR_MAX_MIGRATE_PAGES_RETRY);
@@ -2321,7 +2321,7 @@ int migrate_pages(struct list_head *from, new_folio_t get_new_folio,
 		 * is counted as 1 failure already.  And, we only try to migrate
 		 * with minimal effort, force MIGRATE_ASYNC mode and retry once.
 		 */
-		migrate_pages_batch(&split_folios, get_new_folio,
+		migrate_folios_batch(&split_folios, get_new_folio,
 				put_new_folio, private, MIGRATE_ASYNC, reason,
 				&ret_folios, NULL, &stats, 1);
 		list_splice_tail_init(&split_folios, &ret_folios);

-- 
2.43.0

