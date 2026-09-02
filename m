Received: from BYAPR05CU005.outbound.protection.outlook.com (mail-westusazon11010023.outbound.protection.outlook.com [52.101.85.23])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8DF8447253F;
	Wed,  2 Sep 2026 10:52:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.85.23
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788346386; cv=fail; b=FUzir/JIXpSwm9RV5sY1n3Kg28f5T2MSEwDyeTBUICCTMv1aCtMrJEuSbAWZszzTAaxnBz3bONJCi4rlJcuuLoBrHfgo7k/EpwWq5CrKEteAKmvQtwmgDminBPg5EXjLqFLkQ0amelDiNss/APBjU9c5rO8Qo46gIZ/UgFzfwkQ=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788346386; c=relaxed/simple;
	bh=Mu+TgUSXajmjBg2+WPbNk2V8+vggDvRasZKUX+O5vXA=;
	h=From:Subject:Date:Message-ID:MIME-Version:Content-Type:To:CC; b=dhn3l71+ZYMzy8YapEhA6tQgf4U3VhWl6fA7WrEclAkLPSdj49lCmsbNjJhP+k03NG0VBJU04j5VEX+34bLExGrUs73tAfhBQAakiX/kyFtvrxqEJZYROxWRb8ACCmnOqBLL2mvSrCCyP+8QGFJhIntMdqYPUy5rVmlBKPdxjzE=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amd.com; spf=fail smtp.mailfrom=amd.com; dkim=pass (1024-bit key) header.d=amd.com header.i=@amd.com header.b=T9hHbCS8; arc=fail smtp.client-ip=52.101.85.23
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amd.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=amd.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=amd.com header.i=@amd.com header.b="T9hHbCS8"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=SM3u6QDPlMEAx/3xRp83f9Wd0Kky//1niIaSkceLnqy5wuIDdNmsltjtH2vRSsfZohfDr4z+G2x5V7gb+3x/Kt0cwK0JfoqudgCcHdYpGBH7gMHNQHWh69CphGhZaF5Aw7dDrTCUzJaJQqxbPpGYoPWjTXFkZezT4deVVmsChQbTgtcm/ixj6AzmnGOqG7/ZOmAvYFTkuVbOt4DdMVoTp9TnRiju7QeLgh3AAkUhwuB32/gTnhXZV/c5d+4OQV/iQesUiwqeGGLqKIwNido9DKFLP6umstIrH5g4YB0hEzKjmeevCalgbaAQyOsUmo9icGRZVBsmWYXlaJQExFlMLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=rdSNa3qRI/UUcKBfvFodPhN1IFVSUG1PSxLc+cwrLYQ=;
 b=dXkY5y4fnSq02SB495vJ2wCtEjBXO+AcLOKTqHUk2e7dm33JC2QO9S4YM63MZsYbDapFJEwWOZeGBe31Qc+XX5jfXf98YGvZCOV9aoOT2G+QD0Z/wdT/GkWzWszNw49tT/XxsJnMz8BTvGDIzGXBP2fJIuDZqSaM6mCOvGsLzxMdbYRzr1LKUrfakICZcXZiSzN7l9XOJVAyyoAP9fdOC/di/2JPuKO6wRK0tcTbtgqZ5gAc1nBLxv33Mt3rFZj7uHWe+gZLa3tZzacbysufw97fDcnCQhH6mtcJhpHqMAGOHJH4Z9JaFcUo3KIFMbrtSWmsLHyDJnyyoh65vm7EnQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass (sender ip is
 165.204.84.17) smtp.rcpttodomain=sk.com smtp.mailfrom=amd.com; dmarc=pass
 (p=quarantine sp=quarantine pct=100) action=none header.from=amd.com;
 dkim=none (message not signed); arc=none (0)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=amd.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=rdSNa3qRI/UUcKBfvFodPhN1IFVSUG1PSxLc+cwrLYQ=;
 b=T9hHbCS87fNFpo0RkP0VUglohQnSVbCSfoqy7XpuNdlkjE77c4DU+OmKcp8+9CPybZVp2P7U//4ojj9FiaGB0aacuZD1rIPOYh/uEfPZW1YUSd2LVDcBIsPpPrE6oTAeNjQVPmmvHtMvc82mgwce7MKCCbbQFBDNyixVWUR/RKw=
Received: from BN9PR03CA0600.namprd03.prod.outlook.com (2603:10b6:408:10d::35)
 by SN7PR12MB8817.namprd12.prod.outlook.com (2603:10b6:806:347::8) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.360.7; Wed, 2 Sep 2026
 10:52:43 +0000
Received: from BN1PEPF00004683.namprd03.prod.outlook.com
 (2603:10b6:408:10d:cafe::37) by BN9PR03CA0600.outlook.office365.com
 (2603:10b6:408:10d::35) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.382.11 via Frontend Transport; Wed, 2
 Sep 2026 10:52:42 +0000
X-MS-Exchange-Authentication-Results: spf=pass (sender IP is 165.204.84.17)
 smtp.mailfrom=amd.com; dkim=none (message not signed)
 header.d=none;dmarc=pass action=none header.from=amd.com;
Received-SPF: Pass (protection.outlook.com: domain of amd.com designates
 165.204.84.17 as permitted sender) receiver=protection.outlook.com;
 client-ip=165.204.84.17; helo=satlexmb07.amd.com; pr=C
Received: from satlexmb07.amd.com (165.204.84.17) by
 BN1PEPF00004683.mail.protection.outlook.com (10.167.243.89) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.21.382.8 via Frontend Transport; Wed, 2 Sep 2026 10:52:42 +0000
Received: from [127.0.1.1] (10.180.168.240) by satlexmb07.amd.com
 (10.181.42.216) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.46; Wed, 2 Sep
 2026 05:52:28 -0500
From: Shivank Garg <shivankg@amd.com>
Subject: [PATCH RFC 00/11] mm/migrate: separate migration paths and carry
 migration policy
Date: Wed, 2 Sep 2026 10:52:14 +0000
Message-ID: <20260902-migrate-refactor-shivank-v1-0-9dcca87669c4@amd.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAN//l2oC/x2MwQpAQBBAf0VzNsXahKvyAa5yWGswydKspOTfb
 Y6v3nsPeBImD1X0gNDFnncXII0jsItxMyGPgUElKk8KpXHjWcxJKDQZe+6CfuHLuBU1UVbqcrK
 jHSDkRzD4/tcdtE0N/ft+mFMrJ28AAAA=
X-Change-ID: 20260824-migrate-refactor-shivank-4ee3949fcdcb
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
X-Developer-Signature: v=1; a=ed25519-sha256; t=1788346348; l=7312;
 i=shivankg@amd.com; s=20260518; h=from:subject:message-id;
 bh=Mu+TgUSXajmjBg2+WPbNk2V8+vggDvRasZKUX+O5vXA=;
 b=pKzNUrNsQcUH5z2V4LTXZuGoIw3KiYvNiznMLhPp5FE8keBeSIEGyXQ8Jw/+v1GPzgnggP3DX
 4CjbAsJnHq3Dvw+Jl5mAq1EE39USFEZuwnMD4HmbBQHJM7J0BggxsSf
X-Developer-Key: i=shivankg@amd.com; a=ed25519;
 pk=2l2QGTeXuGkZTtfmx0nPQU8iFZfjYmX/ymMojitevx4=
X-ClientProxiedBy: satlexmb08.amd.com (10.181.42.217) To satlexmb07.amd.com
 (10.181.42.216)
X-EOPAttributedMessage: 0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: BN1PEPF00004683:EE_|SN7PR12MB8817:EE_
X-MS-Office365-Filtering-Correlation-Id: 6c233c01-8b81-44f4-a03f-08df08e05062
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|7416014|82310400026|36860700016|1800799024|23010399003|376014|13003099007|921020|10067099003|6133799003|56012099006|18002099003|11063799006|5023799004;
X-Microsoft-Antispam-Message-Info:
	CjtcWHC6mMi7eBnyjzj+KlogDEs98f+Tjj+6Zi25/Ci595orlqlTRVGR6leyXf35TbQSOBX34GQ96RLC+60MSw0+o8eoRbIFUBE0/GqZTKva/3DW03sLEjbfE8YcgeZMheHBDq/HdOR6gQkcV6U4tU4/neU4APSNTyb3UJSS+1IKIoRHm/lLCspUhNYXBrLgzo5lNTlUMRWl2J3Gzz7RCD/SiPLescCuvbSBum/j+YgUQn+ZVv6jy33liK3bxfsbRXsnnPV25o+9cEEAAfG5rAR9enPRj4PIuQR3b6I9f9OtDCrPWHurWmp6IlJQIpcSdD0BXf5eGppFoAUQ8x6G851uEMOhccerURXMBVBKAt2hw/VBUWD1WO6xwLz9oNKmMC7n6DvXY85Z2yesB9YteGPjZPD4PX51qsMiM7w/Vgdbd/1vnhudifOM8zfain27iJSbv/G+p3h/EQ9uvvcifBqf51Zy6tKiE9Li+bOi1o2eT38HL2Z+se6xtIzdOdI/ivv/+I7NOk3VpCmvPU8unIgzsHQYt0/tXFmjgHgxIcRCToxeWDkY/I6XxZBJLsoUMxPBhtFz26giuZu/FRP1u1VUpYvcCBNpQk8DRw1TeoK2ub6tlgZU7XP4wootp89pbEGuBVDnr6mUYs5YCvPx6h96YGioeaeascH0hA+GVqmqa/Ctqg5xopXvD7Sh1/Vrhz7PWPbemsNmCy+vRPszzzea9EtDvmEzQTVvmpDEzPJYWDk7ayI5z0VrP2Ok/w+Q
X-Forefront-Antispam-Report:
	CIP:165.204.84.17;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:satlexmb07.amd.com;PTR:InfoDomainNonexistent;CAT:NONE;SFS:(13230040)(7416014)(82310400026)(36860700016)(1800799024)(23010399003)(376014)(13003099007)(921020)(10067099003)(6133799003)(56012099006)(18002099003)(11063799006)(5023799004);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	ggcarO+tyWKR8O6EsFWh0RBFqmpKPOL9XJGtBZhDrYozYever7JNK9scbsPVd17/mznrfVZvd+4oPhcjEK2WcaYR2S/jup0TE1hvnYJtQlupnLGtrjqR/73/YMdXk5C1otwzuUUwu/xC/YJip6BKXRAwK2g8fYzEVdHcJfFdtqDxsKUo13HE7TSTBG81YzKMcUTdrovTWP79Yvp+z31w45bXh24SaCQAVRxHXzvaa+i4uE3/1Y6TuvOTJhtj8Q7E7sw8dPVtbHFz4yePKfOpbEAUr+K/etTEtxFVWWOTuAkFOMtI34ix9lOZVBAJphRGUnbsCFkfaeplUH+ZKhtKDlODpXKEWrkps/NzhOJyoeKO/l99pwPao09lE9AM5uChyWK9kLWKV323qVOn9s1OFdqK3ZeZ2liCDe3jRBejH9QGkBQuvUN7siBD+7N0skkO
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 02 Sep 2026 10:52:42.3795
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 6c233c01-8b81-44f4-a03f-08df08e05062
X-MS-Exchange-CrossTenant-Id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=3dd8961f-e488-4e60-8e11-a82d994e183d;Ip=[165.204.84.17];Helo=[satlexmb07.amd.com]
X-MS-Exchange-CrossTenant-AuthSource:
	BN1PEPF00004683.namprd03.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN7PR12MB8817

migrate_pages() handles hugetlb folios, movable_ops pages and LRU folios,
although their locking, mapping and retry requirements differ. It already
dispatches hugetlb folios to a dedicated engine but movable_ops 
pages still pass through the regular folio unmap and move machinery.

Migration policy has a separate interface problem. migrate_mode describes
blocking discipline, but it is passed independently from migrate_reason
through the core, and only migrate_mode reaches
address_space_operations->migrate_folio(). Adding another policy dimension
therefore requires more positional arguments, an overloaded mode or side
state. [3] 

This series separates the migration paths (classes) for movable_ops pages
and LRU folios, moves LRU policy into the LRU engine, and carries mode and
reason through struct migrate_control.

Thanks to Zi Yan and David Hildenbrand for the discussions and suggestions
that helped shape this series. I also used AI tools (Opus 5, GPT-5.6 Sol)
to refine my ideas, identify the edge-cases/bugs.

Old flow
========

migrate_pages(mode, reason)
  |
  +-- migrate_hugetlbs()
  |     `-- scan the mixed source list (from) on each retry
  |
  `-- split the remaining list into batches
        |
        +-- MIGRATE_ASYNC
        |     `-- migrate_pages_batch()
        |           inline unmap/retry -> flush -> move/retry
        |
        `-- MIGRATE_SYNC[_LIGHT]
              `-- migrate_pages_sync()
                   +-- try async batch pre-pass
                   `-- retry failures one at a time through
                       migrate_pages_batch()

movable_ops pages are identified by branches inside the batch unmap and
move paths.

New flow
========

migrate_pages(ctl)
  |
  +-- migrate_hugetlbs()
  |     `-- collect and retry hugetlb folios
  |
  +-- migrate_movable_ops_pages()
  |     `-- allocate, lock, invoke the movable_ops callback and retry
  |
  `-- migrate_lru_folios()
        `-- form bounded LRU batches
              `-- __migrate_lru_folios()
                    +-- async: migrate_folios_batch()
                    `-- sync:
                        +-- async batch pre-pass
                        `-- retry failures one at a time

migrate_folios_batch()
  |
  +-- migrate_folios_unmap()
  +-- try_to_unmap_flush()
  +-- migrate_folios_move()
  `-- migrate_folios_undo()

migrate_pages() now only dispatches classes. Each entry owns its lists and
retries; the LRU entry also owns batching and synchronous fallback.

Motivation
==========

This refactor makes the migration control flow easier to follow and gives
new optimizations clear boundaries and insertion points.

Separating movable_ops also prepares for memdescs, where these pages are
expected to lose their folio representation and folio->lru handoff. The
current list interface remains, but its folio dependencies are now isolated.

struct migrate_control is caller-owned, stack allocated and passed as const.
It carries mode and reason through migrate_pages() and ->migrate_folio(),
and provide place for future extension to policy. This is one-time pain of
updating callers, but doing it once avoids repeating that churn whenever
a new use case or optimization need additional policy.

Follow-on 
=========

This series establishes the class, phase and policy boundaries without
adding copy implementation. Possible follow-on use looks like:

Yiannis and Alirad's RFC adds an asynchronous non-temporal mode and updates
existing asynchronous-mode checks. [1] A separate policy field would keep
cache behavior independent of blocking discipline.

  /* migrate_pages() caller: demote_folio_list() */
  ctl.reason = MR_DEMOTION;   /* migration reason - already exists */
  ctl.mode = MIGRATE_ASYNC;   /* blocking discipline - already exists */
  ctl.cache_hint = MIGRATE_COPY_NT; /* caching intent- new policy */

  __migrate_folio(..., ctl);       /* NT/offload based on caller's hint*/
     `-> folio_mc_copy() or folio_mc_copy_nt() or ...

My batch-copy/offload series [2] can extend migrate_control to take caller's
preference of copy engines (like DMA offload, multi-threaded copy, etc.) or
batch size. Some of this may remain wishful thinking but that is what the
RFC is for :)

Behavior Changes
================

No functional change is intended for the LRU and hugetlb migration paths.

The movable_ops pass has three intentional differences:

  - movable_ops pages are attempted before LRU folios;
  - movable_ops pages no longer use the LRU asynchronous pre-pass.
    synchronous callers use their requested mode from the first attempt.
  - movable_ops callback returning -EAGAIN releases the destination, so
    retry allocates a new one.

Unmigrated pages are still returned through the original source list.

[1] https://lore.kernel.org/r/20260730-rfc-nt-demote-v2-0-452dbe3b5073@zptcorp.com
[2] https://lore.kernel.org/r/20260630-shivank-batch-migrate-offload-v6-0-da95d7e8b8a2@amd.com 
[3] https://lore.kernel.org/r/cae6ab98-3441-38bd-1e07-4586a85cdc74@google.com

---
Shivank Garg (11):
      mm/migrate: extract folio unmap phase
      mm/migrate: handle retries in migrate_folios_move()
      mm/migrate: factor out folio splitting on allocation failure
      mm/migrate: use a dedicated list for hugetlb folios
      mm/migrate: add a dedicated movable_ops migration pass
      mm/migrate: rename migrate_pages_batch() to migrate_folios_batch()
      mm/migrate: add migrate_lru_folios() entry point
      mm/migrate: move LRU batching into migrate_lru_folios()
      mm/migrate: thread migration policy through a control struct
      mm/migrate: pass migrate_control to migrate_pages()
      mm/migrate: pass migrate_control to migrate_folio()

 Documentation/filesystems/locking.rst |   2 +-
 Documentation/filesystems/vfs.rst     |   7 +-
 fs/aio.c                              |   2 +-
 fs/btrfs/disk-io.c                    |   5 +-
 fs/btrfs/inode.c                      |   6 +-
 fs/hugetlbfs/inode.c                  |   4 +-
 fs/jfs/jfs_metapage.c                 |  14 +-
 fs/nfs/internal.h                     |   2 +-
 fs/nfs/write.c                        |   8 +-
 include/linux/buffer_head.h           |   6 +-
 include/linux/fs.h                    |   6 +-
 include/linux/migrate.h               |   7 +-
 include/linux/migrate_mode.h          |  14 +
 include/linux/pagemap.h               |   2 +-
 mm/compaction.c                       |   8 +-
 mm/damon/ops-common.c                 |   7 +-
 mm/gup.c                              |   7 +-
 mm/memory-failure.c                   |   6 +-
 mm/memory_hotplug.c                   |   6 +-
 mm/mempolicy.c                        |  13 +-
 mm/migrate.c                          | 717 ++++++++++++++++++++++------------
 mm/page_alloc.c                       |   6 +-
 mm/secretmem.c                        |   3 +-
 mm/vmscan.c                           |   7 +-
 virt/kvm/guest_memfd.c                |   2 +-
 25 files changed, 563 insertions(+), 304 deletions(-)
---
base-commit: cee9395acd8043be0644b25c34bfa86623f2b935
change-id: 20260824-migrate-refactor-shivank-4ee3949fcdcb

Best regards,
-- 
Shivank Garg <shivankg@amd.com>

