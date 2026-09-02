Received: from DM1PR04CU001.outbound.protection.outlook.com (mail-centralusazon11010006.outbound.protection.outlook.com [52.101.61.6])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ED4F547124D;
	Wed,  2 Sep 2026 10:55:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.61.6
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788346548; cv=fail; b=r7NpNzq5BWIc+dLfPz7fo6xc+5G+6eGDbv+iJvyGb30nVUqVenGLWPmOsr2qV4envfPBQFdoUEfqedrVWxIqWKcp8BIr0kMIAWwFs6MdTv3YhHxwU5vJEv1nK701GptTCwBP37WT5vWrgc5JH+ONN9HnHQBcvVledLE2+nX7nWg=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788346548; c=relaxed/simple;
	bh=yRTEphkqK1Fis5qo6DvPrfJS5obUvomZv5Ye5/JvcHY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-ID:References:
	 In-Reply-To:To:CC; b=U7n1KZnwl8crur/K3N7qjUh1dWrynsc3jzsmkFBgA3Fh/r98iRQYkbYUjbnQ3SRRl+G+sqVz7uQeCNfxdCaFcZZMo+OezCuPj1nQc8hVdZNrFAFuzl0c5R2ReyJnt0xH7/kZVvjXnn1M8vD1DORuBnBKi9jnHPfNpVLekbFIPjI=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amd.com; spf=fail smtp.mailfrom=amd.com; dkim=pass (1024-bit key) header.d=amd.com header.i=@amd.com header.b=BdUyQkVR; arc=fail smtp.client-ip=52.101.61.6
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amd.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=amd.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=amd.com header.i=@amd.com header.b="BdUyQkVR"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=Kl81BcQll3agYVALOTKHKK8OYxYbuF1YO/4bBsz875PK1zk2JnyOthifBMywkK+DKDhB60l+xqXa4t3b6BvI+wJcSQvt08E380IOlRhDKM4KH7sMDnS3EO4s9CthnyCOGGZFA4JgCoYMHr0G552tmX3c81xSedxtdHX3R5Daha1pUdTMh7aGzXRzCdhqEX7I3gb/43IsruTvRmEM3mVwDf9p52EpiD1LD4vbXq7IRw5PvvkXIyu0Hpc8sLb0Jk0/Uv9g18wwPPaNLJ6AYURGIra1GNuXQH55ISLItyRZQe80gldjqVnmtS7EhSA+nymvXGwLwnLuIHkuGGsGjRi0fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=uqWZjB7KL6Qaq3UbZNEh1+3/BaITN2t6ZfsVDmk6hFY=;
 b=g5yk2/vxJI4YZ80wzc7mMn0cB47kik7cOdjpIlgpcZ5Vw0+g0L6MnBOlqHsaFfFSzEUwNTk+Ssmmyn+6uynzON62zT+oN1oBLK2MVdHOmr3csDXYMQXEsRFayxEjzhUeCYODaPMCl93pJSY6UTFRnyO3a6EM9Pe3N/RFnNsq1N/VC6JJWaZS28u6+8NyovxOMNopGMFlrqSncUYSS/6ZNsQzXRO4uLnUoTvM0coCak8haS4GdMUl+sVhRhw3xFjkO0drIA6QVMJMLLGnamVZ3tyQAcmxRRXmr6pLorCDlNxDb8lpLp14DlM5m5vTs8zKbnJimvEZxQfPkC5s8X4pTA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass (sender ip is
 165.204.84.17) smtp.rcpttodomain=sk.com smtp.mailfrom=amd.com; dmarc=pass
 (p=quarantine sp=quarantine pct=100) action=none header.from=amd.com;
 dkim=none (message not signed); arc=none (0)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=amd.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=uqWZjB7KL6Qaq3UbZNEh1+3/BaITN2t6ZfsVDmk6hFY=;
 b=BdUyQkVRCdh9wRf1fs8lbdFaQWE/504HdTxsOzk1MEdth9g7x1p3lYib3+ab5UpHwL48lFEVmjPBUcCTYTrBFSxaQPaTEDyN1cnBbRiy2GbYxrriNwIzBSYCUji7nsl1cfADMgIAoSVtMS1TYxR4eoADrVw+Q84n0YkmtRnTzSk=
Received: from BN9PR03CA0193.namprd03.prod.outlook.com (2603:10b6:408:f9::18)
 by CY5PR12MB6153.namprd12.prod.outlook.com (2603:10b6:930:27::11) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.360.13; Wed, 2 Sep
 2026 10:55:33 +0000
Received: from BN5PEPF00046989.namprd02.prod.outlook.com
 (2603:10b6:408:f9:cafe::19) by BN9PR03CA0193.outlook.office365.com
 (2603:10b6:408:f9::18) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.21.382.11 via Frontend Transport; Wed, 2
 Sep 2026 10:55:33 +0000
X-MS-Exchange-Authentication-Results: spf=pass (sender IP is 165.204.84.17)
 smtp.mailfrom=amd.com; dkim=none (message not signed)
 header.d=none;dmarc=pass action=none header.from=amd.com;
Received-SPF: Pass (protection.outlook.com: domain of amd.com designates
 165.204.84.17 as permitted sender) receiver=protection.outlook.com;
 client-ip=165.204.84.17; helo=satlexmb07.amd.com; pr=C
Received: from satlexmb07.amd.com (165.204.84.17) by
 BN5PEPF00046989.mail.protection.outlook.com (10.167.245.38) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.21.382.8 via Frontend Transport; Wed, 2 Sep 2026 10:55:32 +0000
Received: from [127.0.1.1] (10.180.168.240) by satlexmb07.amd.com
 (10.181.42.216) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.46; Wed, 2 Sep
 2026 05:55:02 -0500
From: Shivank Garg <shivankg@amd.com>
Date: Wed, 2 Sep 2026 10:52:25 +0000
Subject: [PATCH RFC 11/11] mm/migrate: pass migrate_control to
 migrate_folio()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-ID: <20260902-migrate-refactor-shivank-v1-11-9dcca87669c4@amd.com>
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
X-Developer-Signature: v=1; a=ed25519-sha256; t=1788346348; l=20575;
 i=shivankg@amd.com; s=20260518; h=from:subject:message-id;
 bh=yRTEphkqK1Fis5qo6DvPrfJS5obUvomZv5Ye5/JvcHY=;
 b=b6CZM0096OLZjss2nbNnoQyz5oHyvtGYtuvC44qQglGaFjWZoGZtsEejeYgR+Gyc8MW7IlgdM
 xNerLDWBmFOAWwQS9RxH3urLmY3Gzq5ll7q83g4a5TPJK7krZJ2NDY2
X-Developer-Key: i=shivankg@amd.com; a=ed25519;
 pk=2l2QGTeXuGkZTtfmx0nPQU8iFZfjYmX/ymMojitevx4=
X-ClientProxiedBy: satlexmb08.amd.com (10.181.42.217) To satlexmb07.amd.com
 (10.181.42.216)
X-EOPAttributedMessage: 0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: BN5PEPF00046989:EE_|CY5PR12MB6153:EE_
X-MS-Office365-Filtering-Correlation-Id: 60b5232b-0d87-4e5f-3b2f-08df08e0b5cd
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|1800799024|82310400026|7416014|376014|23010399003|36860700016|22082099003|18002099003|56012099006|10067099003|11063799006|921020;
X-Microsoft-Antispam-Message-Info:
	aYGoq5TXkwWEGOnlOtRhGNlqvK+9iM1nqxyZtJQLPJoPMRlFk6cyC/ve0SAV4ABx9JiIkc27DEY0LgYWMeib14ebeYuzLqf0csCWnqVXck+32IYFbk3Jn7Ez7NvcG8NIOdCudfhpoDEY8EZfOZR6rBrETQ44gVOSwnR5dRRgaENxDkDpST9pqJfs1w0dfF5YlkKXRl3+H8NL50SNjg0hxBeyikQA0ABef0bX5L8rEdmnYjoaLsThPrDCvTPmzr3mUpFM5hHDZqzWlvgSzTbNd49ROl/leavwRbxIqObh/COv24SR1KfqW/V+QcEozKIXHt85mvZtZE9/gwAyTKqDkpodq62eZVIT2LTd74qb1iGHRQpw1jhw9XaGlqq0TTSeLmwlyRoZOOhbDcKNZWT+IHGaH7DbVxvoWF+m0bzAceBxeenvoZZLNX0GyuJOAgge99VQaP9AY6JNfyE1t4DCbM6yg7aEIpY1Sqa9RZIp24zHFWLD1df/SQBn2J/KbgZGKW6TEJCJsK8yJaqJQKqY5ABRnpnBDbrkK2XOz/GZwvyYcAXhqMlYe4Gv5R9Adpyne9b9KIstlrNqCmw7SPk4xIah1DPy07zoG8135reeKPdyLO2QIzKv+pAUesQhZuadUxOQa9Je8UwIF+p1DGT7I/uTP+2wU/XcYlVCe5XfXJ1WlR4JjzyLoLVZJvApC8E2NZVigyhyLxvUxiPh5IZlBivMcqp5FyNVJnDmo7uZCAS/G07VyAOijtmIx2urCAJn
X-Forefront-Antispam-Report:
	CIP:165.204.84.17;CTRY:US;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:satlexmb07.amd.com;PTR:InfoDomainNonexistent;CAT:NONE;SFS:(13230040)(1800799024)(82310400026)(7416014)(376014)(23010399003)(36860700016)(22082099003)(18002099003)(56012099006)(10067099003)(11063799006)(921020);DIR:OUT;SFP:1101;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	3EUw9HfngF2nOhdxnG4RvpENE8M01m3DFA3drZUvYUOItAvcTn8lG36usK0D0UjInSLB/B83OkITfL17HXsb1JkIAJa0n71gmnmoRXo/gNtfIBcgD0g/8lHineB4AWRWhBhZ9qH4hwlhiI+a/qoo1djEzfpHAsjOTRQZ/2crNsJ5c4MExgfOY2UYdaNE2mqtZJk3kWf3tK9itN9YJ7OMxSY0626lQ2GfSEipR3a0CVyzYJDCbH7QHaXY3sBEJnHWzBLeTCPdC3/hwAhAztHf5pWeGs6My+wgP6XpklMXtMS/NNGcvfiDx+ywar/EWOJhR1zqK+sJL/IjGQYhksJuvBmQW9j/ab8YQarnhc5dFzTm0a/BkAAq4x3irZDI2M2RbWizi/pbk5Aiehf/15YAHkBtxGJA7BSRyX+MW2UbKHHZ3ICBDmLn81H7uY/zZKWq
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 02 Sep 2026 10:55:32.5309
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 60b5232b-0d87-4e5f-3b2f-08df08e0b5cd
X-MS-Exchange-CrossTenant-Id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=3dd8961f-e488-4e60-8e11-a82d994e183d;Ip=[165.204.84.17];Helo=[satlexmb07.amd.com]
X-MS-Exchange-CrossTenant-AuthSource:
	BN5PEPF00046989.namprd02.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CY5PR12MB6153

The migration core now carries policy in struct migrate_control, but
migrate_folio() and the address_space migrate_folio callback still receive
only the migration mode. This prevents additional policy, such as
copy-cache hints, from reaching folio-specific migration code.

Pass the control as const through migrate_folio(), the common migration
helpers, and the address_space callback. Update all implementations and
documentation accordingly. Existing callbacks continue to make their
decisions from ctl->mode only, none changes behavior yet.

No functional change intended.

Signed-off-by: Shivank Garg <shivankg@amd.com>
---
 Documentation/filesystems/locking.rst |  2 +-
 Documentation/filesystems/vfs.rst     |  7 +++--
 fs/aio.c                              |  2 +-
 fs/btrfs/disk-io.c                    |  5 ++--
 fs/btrfs/inode.c                      |  6 ++---
 fs/hugetlbfs/inode.c                  |  4 +--
 fs/jfs/jfs_metapage.c                 | 14 +++++-----
 fs/nfs/internal.h                     |  2 +-
 fs/nfs/write.c                        |  8 +++---
 include/linux/buffer_head.h           |  6 +++--
 include/linux/fs.h                    |  6 ++---
 include/linux/migrate.h               |  2 +-
 include/linux/pagemap.h               |  2 +-
 mm/migrate.c                          | 50 +++++++++++++++++++----------------
 mm/secretmem.c                        |  3 ++-
 virt/kvm/guest_memfd.c                |  2 +-
 16 files changed, 66 insertions(+), 55 deletions(-)

diff --git a/Documentation/filesystems/locking.rst b/Documentation/filesystems/locking.rst
index 844d65eb47a5..b406df403b4a 100644
--- a/Documentation/filesystems/locking.rst
+++ b/Documentation/filesystems/locking.rst
@@ -260,7 +260,7 @@ prototypes::
 	void (*free_folio)(struct folio *);
 	int (*direct_IO)(struct kiocb *, struct iov_iter *iter);
 	int (*migrate_folio)(struct address_space *, struct folio *dst,
-			struct folio *src, enum migrate_mode);
+			struct folio *src, const struct migrate_control *ctl);
 	int (*launder_folio)(struct folio *);
 	bool (*is_partially_uptodate)(struct folio *, size_t from, size_t count);
 	int (*error_remove_folio)(struct address_space *, struct folio *);
diff --git a/Documentation/filesystems/vfs.rst b/Documentation/filesystems/vfs.rst
index d3a93eec3945..8e1404723db1 100644
--- a/Documentation/filesystems/vfs.rst
+++ b/Documentation/filesystems/vfs.rst
@@ -767,7 +767,8 @@ cache in your filesystem.  The following members are defined:
 		void (*free_folio)(struct folio *);
 		ssize_t (*direct_IO)(struct kiocb *, struct iov_iter *iter);
 		int (*migrate_folio)(struct mapping *, struct folio *dst,
-				struct folio *src, enum migrate_mode);
+				struct folio *src,
+				const struct migrate_control *ctl);
 		int (*launder_folio) (struct folio *);
 
 		bool (*is_partially_uptodate) (struct folio *, size_t from,
@@ -939,7 +940,9 @@ cache in your filesystem.  The following members are defined:
 	wants to relocate a folio (maybe from a memory device that is
 	signalling imminent failure) it will pass a new folio and an old
 	folio to this function.  migrate_folio should transfer any private
-	data across and update any references that it has to the folio.
+	data across and update any references that it has to the folio.  The
+	control describes the blocking mode and the reason for migration.  If
+	the mode is ``MIGRATE_ASYNC``, the callback must not block.
 
 ``launder_folio``
 	Called before freeing a folio - it writes back the dirty folio.
diff --git a/fs/aio.c b/fs/aio.c
index d78acc69f487..58ee9d0845dd 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -458,7 +458,7 @@ static const struct file_operations aio_ring_fops = {
 
 #if IS_ENABLED(CONFIG_MIGRATION)
 static int aio_migrate_folio(struct address_space *mapping, struct folio *dst,
-			struct folio *src, enum migrate_mode mode)
+			     struct folio *src, const struct migrate_control *ctl)
 {
 	struct kioctx *ctx;
 	struct aio_inode_info *ai = AIO_I(mapping->host);
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 819727460bcf..509651577a1c 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -460,7 +460,8 @@ int btrfs_validate_extent_buffer(struct extent_buffer *eb,
 
 #ifdef CONFIG_MIGRATION
 static int btree_migrate_folio(struct address_space *mapping,
-		struct folio *dst, struct folio *src, enum migrate_mode mode)
+		struct folio *dst, struct folio *src,
+		const struct migrate_control *ctl)
 {
 	/*
 	 * we can't safely write a btree page from here,
@@ -475,7 +476,7 @@ static int btree_migrate_folio(struct address_space *mapping,
 	if (folio_get_private(src) &&
 	    !filemap_release_folio(src, GFP_KERNEL))
 		return -EAGAIN;
-	return migrate_folio(mapping, dst, src, mode);
+	return migrate_folio(mapping, dst, src, ctl);
 }
 #else
 #define btree_migrate_folio NULL
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 3c10a0ef0002..9f1e567fa5ed 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -7653,10 +7653,10 @@ static bool btrfs_release_folio(struct folio *folio, gfp_t gfp_flags)
 
 #ifdef CONFIG_MIGRATION
 static int btrfs_migrate_folio(struct address_space *mapping,
-			     struct folio *dst, struct folio *src,
-			     enum migrate_mode mode)
+			       struct folio *dst, struct folio *src,
+			       const struct migrate_control *ctl)
 {
-	int ret = filemap_migrate_folio(mapping, dst, src, mode);
+	int ret = filemap_migrate_folio(mapping, dst, src, ctl);
 
 	if (ret)
 		return ret;
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 7611a8470ea2..367148251689 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -1022,8 +1022,8 @@ static int hugetlbfs_symlink(struct mnt_idmap *idmap,
 
 #ifdef CONFIG_MIGRATION
 static int hugetlbfs_migrate_folio(struct address_space *mapping,
-				struct folio *dst, struct folio *src,
-				enum migrate_mode mode)
+				   struct folio *dst, struct folio *src,
+				   const struct migrate_control *ctl)
 {
 	int rc;
 
diff --git a/fs/jfs/jfs_metapage.c b/fs/jfs/jfs_metapage.c
index 41fe12e641ce..7958edacb497 100644
--- a/fs/jfs/jfs_metapage.c
+++ b/fs/jfs/jfs_metapage.c
@@ -155,7 +155,7 @@ static inline void dec_io(struct folio *folio, blk_status_t status,
 #ifdef CONFIG_MIGRATION
 static int __metapage_migrate_folio(struct address_space *mapping,
 				    struct folio *dst, struct folio *src,
-				    enum migrate_mode mode)
+				    const struct migrate_control *ctl)
 {
 	struct meta_anchor *src_anchor = src->private;
 	struct metapage *mps[MPS_PER_PAGE] = {0};
@@ -168,7 +168,7 @@ static int __metapage_migrate_folio(struct address_space *mapping,
 			return -EAGAIN;
 	}
 
-	rc = filemap_migrate_folio(mapping, dst, src, mode);
+	rc = filemap_migrate_folio(mapping, dst, src, ctl);
 	if (rc)
 		return rc;
 
@@ -231,7 +231,7 @@ static inline void remove_metapage(struct folio *folio, struct metapage *mp)
 #ifdef CONFIG_MIGRATION
 static int __metapage_migrate_folio(struct address_space *mapping,
 				    struct folio *dst, struct folio *src,
-				    enum migrate_mode mode)
+				    const struct migrate_control *ctl)
 {
 	struct metapage *mp;
 	int page_offset;
@@ -241,7 +241,7 @@ static int __metapage_migrate_folio(struct address_space *mapping,
 	if (metapage_locked(mp))
 		return -EAGAIN;
 
-	rc = filemap_migrate_folio(mapping, dst, src, mode);
+	rc = filemap_migrate_folio(mapping, dst, src, ctl);
 	if (rc)
 		return rc;
 
@@ -645,18 +645,18 @@ static bool metapage_release_folio(struct folio *folio, gfp_t gfp_mask)
  */
 static int metapage_migrate_folio(struct address_space *mapping,
 				  struct folio *dst, struct folio *src,
-				  enum migrate_mode mode)
+				  const struct migrate_control *ctl)
 {
 	int expected_count;
 
 	if (!src->private)
-		return filemap_migrate_folio(mapping, dst, src, mode);
+		return filemap_migrate_folio(mapping, dst, src, ctl);
 
 	/* Check whether page does not have extra refs before we do more work */
 	expected_count = folio_expected_ref_count(src) + 1;
 	if (folio_ref_count(src) != expected_count)
 		return -EAGAIN;
-	return __metapage_migrate_folio(mapping, dst, src, mode);
+	return __metapage_migrate_folio(mapping, dst, src, ctl);
 }
 #else
 #define metapage_migrate_folio NULL
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index abc81f5ae578..e1f366cff2c0 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -673,7 +673,7 @@ void nfs_clear_pnfs_ds_commit_verifiers(struct pnfs_ds_commit_info *cinfo)
 
 #ifdef CONFIG_MIGRATION
 int nfs_migrate_folio(struct address_space *, struct folio *dst,
-		struct folio *src, enum migrate_mode);
+		struct folio *src, const struct migrate_control *);
 #else
 #define nfs_migrate_folio NULL
 #endif
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 623e7ef1f73d..159135900399 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -2112,7 +2112,7 @@ int nfs_wb_folio(struct inode *inode, struct folio *folio)
 
 #ifdef CONFIG_MIGRATION
 int nfs_migrate_folio(struct address_space *mapping, struct folio *dst,
-		struct folio *src, enum migrate_mode mode)
+		struct folio *src, const struct migrate_control *ctl)
 {
 	/*
 	 * If the private flag is set, the folio is currently associated with
@@ -2123,19 +2123,19 @@ int nfs_migrate_folio(struct address_space *mapping, struct folio *dst,
 	 *        the folio lock.
 	 */
 	if (folio_test_private(src)) {
-		if (mode == MIGRATE_SYNC)
+		if (ctl->mode == MIGRATE_SYNC)
 			nfs_wb_folio(src->mapping->host, src);
 		if (folio_test_private(src))
 			return -EBUSY;
 	}
 
 	if (folio_test_private_2(src)) { /* [DEPRECATED] */
-		if (mode == MIGRATE_ASYNC)
+		if (ctl->mode == MIGRATE_ASYNC)
 			return -EBUSY;
 		folio_wait_private_2(src);
 	}
 
-	return migrate_folio(mapping, dst, src, mode);
+	return migrate_folio(mapping, dst, src, ctl);
 }
 #endif
 
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index fd2c7115c054..e4476596c9b6 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -277,9 +277,11 @@ int block_truncate_page(struct address_space *, loff_t, get_block_t *);
 
 #ifdef CONFIG_MIGRATION
 extern int buffer_migrate_folio(struct address_space *,
-		struct folio *dst, struct folio *src, enum migrate_mode);
+		struct folio *dst, struct folio *src,
+		const struct migrate_control *);
 extern int buffer_migrate_folio_norefs(struct address_space *,
-		struct folio *dst, struct folio *src, enum migrate_mode);
+		struct folio *dst, struct folio *src,
+		const struct migrate_control *);
 #else
 #define buffer_migrate_folio NULL
 #define buffer_migrate_folio_norefs NULL
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f9d1e05e8ae6..93ba6054c478 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -423,11 +423,11 @@ struct address_space_operations {
 	void (*free_folio)(struct folio *folio);
 	ssize_t (*direct_IO)(struct kiocb *, struct iov_iter *iter);
 	/*
-	 * migrate the contents of a folio to the specified target. If
-	 * migrate_mode is MIGRATE_ASYNC, it must not block.
+	 * Migrate the contents of a folio to the specified target.  The
+	 * callback must not block when ctl->mode is MIGRATE_ASYNC.
 	 */
 	int (*migrate_folio)(struct address_space *, struct folio *dst,
-			struct folio *src, enum migrate_mode);
+			struct folio *src, const struct migrate_control *ctl);
 	int (*launder_folio)(struct folio *);
 	bool (*is_partially_uptodate) (struct folio *, size_t from,
 			size_t count);
diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index cec5713944e3..123111e7abd3 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -55,7 +55,7 @@ extern const char *migrate_reason_names[MR_TYPES];
 
 void putback_movable_pages(struct list_head *l);
 int migrate_folio(struct address_space *mapping, struct folio *dst,
-		struct folio *src, enum migrate_mode mode);
+		struct folio *src, const struct migrate_control *ctl);
 int migrate_pages(struct list_head *l, new_folio_t new, free_folio_t free,
 		unsigned long private, const struct migrate_control *ctl,
 		unsigned int *ret_succeeded);
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 0adfa6605653..455d57307f88 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -1327,7 +1327,7 @@ bool noop_dirty_folio(struct address_space *mapping, struct folio *folio);
 
 #ifdef CONFIG_MIGRATION
 int filemap_migrate_folio(struct address_space *mapping, struct folio *dst,
-		struct folio *src, enum migrate_mode mode);
+		struct folio *src, const struct migrate_control *ctl);
 #else
 #define filemap_migrate_folio NULL
 #endif
diff --git a/mm/migrate.c b/mm/migrate.c
index 549f8b57092c..731836664a86 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -869,7 +869,7 @@ EXPORT_SYMBOL(folio_migrate_flags);
 
 static int __migrate_folio(struct address_space *mapping, struct folio *dst,
 			   struct folio *src, void *src_private,
-			   enum migrate_mode mode)
+			   const struct migrate_control *ctl)
 {
 	int rc, expected_count = folio_expected_ref_count(src) + 1;
 
@@ -897,7 +897,7 @@ static int __migrate_folio(struct address_space *mapping, struct folio *dst,
  * @mapping: The address_space containing the folio.
  * @dst: The folio to migrate the data to.
  * @src: The folio containing the current data.
- * @mode: How to migrate the folio.
+ * @ctl: Migration policy for this folio.
  *
  * Common logic to directly migrate a single LRU folio suitable for
  * folios that do not have private data.
@@ -905,10 +905,10 @@ static int __migrate_folio(struct address_space *mapping, struct folio *dst,
  * Folios are locked upon entry and exit.
  */
 int migrate_folio(struct address_space *mapping, struct folio *dst,
-		  struct folio *src, enum migrate_mode mode)
+		  struct folio *src, const struct migrate_control *ctl)
 {
 	BUG_ON(folio_test_writeback(src));	/* Writeback must be complete */
-	return __migrate_folio(mapping, dst, src, NULL, mode);
+	return __migrate_folio(mapping, dst, src, NULL, ctl);
 }
 EXPORT_SYMBOL(migrate_folio);
 
@@ -947,8 +947,8 @@ static bool buffer_migrate_lock_buffers(struct buffer_head *head,
 }
 
 static int __buffer_migrate_folio(struct address_space *mapping,
-		struct folio *dst, struct folio *src, enum migrate_mode mode,
-		bool check_refs)
+		struct folio *dst, struct folio *src,
+		const struct migrate_control *ctl, bool check_refs)
 {
 	struct buffer_head *bh, *head;
 	int rc;
@@ -956,14 +956,14 @@ static int __buffer_migrate_folio(struct address_space *mapping,
 
 	head = folio_buffers(src);
 	if (!head)
-		return migrate_folio(mapping, dst, src, mode);
+		return migrate_folio(mapping, dst, src, ctl);
 
 	/* Check whether page does not have extra refs before we do more work */
 	expected_count = folio_expected_ref_count(src) + 1;
 	if (folio_ref_count(src) != expected_count)
 		return -EAGAIN;
 
-	if (!buffer_migrate_lock_buffers(head, mode))
+	if (!buffer_migrate_lock_buffers(head, ctl->mode))
 		return -EAGAIN;
 
 	if (check_refs) {
@@ -995,7 +995,7 @@ static int __buffer_migrate_folio(struct address_space *mapping,
 		}
 	}
 
-	rc = filemap_migrate_folio(mapping, dst, src, mode);
+	rc = filemap_migrate_folio(mapping, dst, src, ctl);
 	if (rc)
 		goto unlock_buffers;
 
@@ -1022,7 +1022,7 @@ static int __buffer_migrate_folio(struct address_space *mapping,
  * @mapping: The address space containing @src.
  * @dst: The folio to migrate to.
  * @src: The folio to migrate from.
- * @mode: How to migrate the folio.
+ * @ctl: Migration policy for this folio.
  *
  * This function can only be used if the underlying filesystem guarantees
  * that no other references to @src exist. For example attached buffer
@@ -1033,9 +1033,10 @@ static int __buffer_migrate_folio(struct address_space *mapping,
  * Return: 0 on success or a negative errno on failure.
  */
 int buffer_migrate_folio(struct address_space *mapping,
-		struct folio *dst, struct folio *src, enum migrate_mode mode)
+		struct folio *dst, struct folio *src,
+		const struct migrate_control *ctl)
 {
-	return __buffer_migrate_folio(mapping, dst, src, mode, false);
+	return __buffer_migrate_folio(mapping, dst, src, ctl, false);
 }
 EXPORT_SYMBOL(buffer_migrate_folio);
 
@@ -1044,7 +1045,7 @@ EXPORT_SYMBOL(buffer_migrate_folio);
  * @mapping: The address space containing @src.
  * @dst: The folio to migrate to.
  * @src: The folio to migrate from.
- * @mode: How to migrate the folio.
+ * @ctl: Migration policy for this folio.
  *
  * Like buffer_migrate_folio() except that this variant is more careful
  * and checks that there are also no buffer head references. This function
@@ -1054,17 +1055,19 @@ EXPORT_SYMBOL(buffer_migrate_folio);
  * Return: 0 on success or a negative errno on failure.
  */
 int buffer_migrate_folio_norefs(struct address_space *mapping,
-		struct folio *dst, struct folio *src, enum migrate_mode mode)
+		struct folio *dst, struct folio *src,
+		const struct migrate_control *ctl)
 {
-	return __buffer_migrate_folio(mapping, dst, src, mode, true);
+	return __buffer_migrate_folio(mapping, dst, src, ctl, true);
 }
 EXPORT_SYMBOL_GPL(buffer_migrate_folio_norefs);
 #endif /* CONFIG_BUFFER_HEAD */
 
 int filemap_migrate_folio(struct address_space *mapping,
-		struct folio *dst, struct folio *src, enum migrate_mode mode)
+		struct folio *dst, struct folio *src,
+		const struct migrate_control *ctl)
 {
-	return __migrate_folio(mapping, dst, src, folio_get_private(src), mode);
+	return __migrate_folio(mapping, dst, src, folio_get_private(src), ctl);
 }
 EXPORT_SYMBOL_GPL(filemap_migrate_folio);
 
@@ -1072,7 +1075,8 @@ EXPORT_SYMBOL_GPL(filemap_migrate_folio);
  * Default handling if a filesystem does not provide a migration function.
  */
 static int fallback_migrate_folio(struct address_space *mapping,
-		struct folio *dst, struct folio *src, enum migrate_mode mode)
+		struct folio *dst, struct folio *src,
+		const struct migrate_control *ctl)
 {
 	WARN_ONCE(mapping->a_ops->writepages,
 			"%ps does not implement migrate_folio\n",
@@ -1085,9 +1089,9 @@ static int fallback_migrate_folio(struct address_space *mapping,
 	 * can't migrate automatically.
 	 */
 	if (!filemap_release_folio(src, GFP_KERNEL))
-		return mode == MIGRATE_SYNC ? -EAGAIN : -EBUSY;
+		return ctl->mode == MIGRATE_SYNC ? -EAGAIN : -EBUSY;
 
-	return migrate_folio(mapping, dst, src, mode);
+	return migrate_folio(mapping, dst, src, ctl);
 }
 
 /*
@@ -1112,7 +1116,7 @@ static int move_to_new_folio(struct folio *dst, struct folio *src,
 	VM_BUG_ON_FOLIO(!folio_test_locked(dst), dst);
 
 	if (!mapping)
-		rc = migrate_folio(mapping, dst, src, ctl->mode);
+		rc = migrate_folio(mapping, dst, src, ctl);
 	else if (mapping_inaccessible(mapping))
 		rc = -EOPNOTSUPP;
 	else if (mapping->a_ops->migrate_folio)
@@ -1123,9 +1127,9 @@ static int move_to_new_folio(struct folio *dst, struct folio *src,
 		 * migrate_folio callback. This is the most common path
 		 * for page migration.
 		 */
-		rc = mapping->a_ops->migrate_folio(mapping, dst, src, ctl->mode);
+		rc = mapping->a_ops->migrate_folio(mapping, dst, src, ctl);
 	else
-		rc = fallback_migrate_folio(mapping, dst, src, ctl->mode);
+		rc = fallback_migrate_folio(mapping, dst, src, ctl);
 
 	if (!rc) {
 		/*
diff --git a/mm/secretmem.c b/mm/secretmem.c
index d29865075b6e..5c81833981d2 100644
--- a/mm/secretmem.c
+++ b/mm/secretmem.c
@@ -144,7 +144,8 @@ static const struct file_operations secretmem_fops = {
 };
 
 static int secretmem_migrate_folio(struct address_space *mapping,
-		struct folio *dst, struct folio *src, enum migrate_mode mode)
+		struct folio *dst, struct folio *src,
+		const struct migrate_control *ctl)
 {
 	return -EBUSY;
 }
diff --git a/virt/kvm/guest_memfd.c b/virt/kvm/guest_memfd.c
index 625e62e1a031..0a9af8c4768d 100644
--- a/virt/kvm/guest_memfd.c
+++ b/virt/kvm/guest_memfd.c
@@ -457,7 +457,7 @@ static struct file_operations kvm_gmem_fops = {
 
 static int kvm_gmem_migrate_folio(struct address_space *mapping,
 				  struct folio *dst, struct folio *src,
-				  enum migrate_mode mode)
+				  const struct migrate_control *ctl)
 {
 	WARN_ON_ONCE(1);
 	return -EINVAL;

-- 
2.43.0

