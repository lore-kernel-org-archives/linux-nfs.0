Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:49221 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754126AbcISMKT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Sep 2016 08:10:19 -0400
From: Chao Yu <yuchao0@huawei.com>
To: <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Chao Yu <yuchao0@huawei.com>
Subject: [PATCH] nfs: add missing CONFIG_MIGRATION for nfs_migrate_page
Date: Mon, 19 Sep 2016 20:09:17 +0800
Message-ID: <20160919120917.29844-1-yuchao0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We'd better to use CONFIG_MIGRATION to cover nfs_migrate_page, otherwise
when CONFIG_MIGRATION is not defined, unused nfs_migrate_page will still
be compiled into kernel.

Signed-off-by: Chao Yu <yuchao0@huawei.com>
---
 fs/nfs/file.c | 2 ++
 1 file changed, 2 insertions(+)

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
-- 
2.8.2.311.gee88674

