Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:40932 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750775AbcITECL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2016 00:02:11 -0400
From: Chao Yu <yuchao0@huawei.com>
To: <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Chao Yu <yuchao0@huawei.com>
Subject: [PATCH] nfs: cover ->migratepage with CONFIG_MIGRATION
Date: Tue, 20 Sep 2016 12:01:25 +0800
Message-ID: <20160920040125.18895-1-yuchao0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It will be more clean to use CONFIG_MIGRATION to cover nfs' private
.migratepage in nfs_file_aops like we do in other part of nfs
operations.

Signed-off-by: Chao Yu <yuchao0@huawei.com>
---
 fs/nfs/file.c     | 2 ++
 fs/nfs/internal.h | 8 --------
 2 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 7d62097..6cfb83e 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -543,7 +543,9 @@ const struct address_space_operations nfs_file_aops = {
 	.invalidatepage = nfs_invalidate_page,
 	.releasepage = nfs_release_page,
 	.direct_IO = nfs_direct_IO,
+#ifdef CONFIG_MIGRATION
 	.migratepage = nfs_migrate_page,
+#endif
 	.launder_page = nfs_launder_page,
 	.is_dirty_writeback = nfs_check_dirty_writeback,
 	.error_remove_page = generic_error_remove_page,
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 7ce5e02..0d508f7 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -532,14 +532,6 @@ void nfs_clear_pnfs_ds_commit_verifiers(struct pnfs_ds_commit_info *cinfo)
 }
 #endif
 
-
-#ifdef CONFIG_MIGRATION
-extern int nfs_migrate_page(struct address_space *,
-		struct page *, struct page *, enum migrate_mode);
-#else
-#define nfs_migrate_page NULL
-#endif
-
 static inline int
 nfs_write_verifier_cmp(const struct nfs_write_verifier *v1,
 		const struct nfs_write_verifier *v2)
-- 
2.8.2.311.gee88674

