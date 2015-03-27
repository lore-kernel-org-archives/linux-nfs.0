Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:36856 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753555AbbC0Q76 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:59:58 -0400
Received: by igbud6 with SMTP id ud6so25811122igb.1
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 09:59:57 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Allow tracing of NFSv4 fsync calls
Date: Fri, 27 Mar 2015 12:59:55 -0400
Message-Id: <1427475595-14213-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I appear to have missed this when adding the ftrace probes.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4file.c | 5 +++++
 fs/nfs/nfstrace.c | 3 +++
 2 files changed, 8 insertions(+)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 8b46389c4c5b..0de62f7cfebf 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -10,6 +10,8 @@
 #include "fscache.h"
 #include "pnfs.h"
 
+#include "nfstrace.h"
+
 #ifdef CONFIG_NFS_V4_2
 #include "nfs42.h"
 #endif
@@ -100,6 +102,8 @@ nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	int ret;
 	struct inode *inode = file_inode(file);
 
+	trace_nfs_fsync_enter(inode);
+
 	do {
 		ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
 		if (ret != 0)
@@ -118,6 +122,7 @@ nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 		end = LLONG_MAX;
 	} while (ret == -EAGAIN);
 
+	trace_nfs_fsync_exit(inode, ret);
 	return ret;
 }
 
diff --git a/fs/nfs/nfstrace.c b/fs/nfs/nfstrace.c
index 4eb0aead69b6..c74f7af23d77 100644
--- a/fs/nfs/nfstrace.c
+++ b/fs/nfs/nfstrace.c
@@ -7,3 +7,6 @@
 
 #define CREATE_TRACE_POINTS
 #include "nfstrace.h"
+
+EXPORT_TRACEPOINT_SYMBOL_GPL(nfs_fsync_enter);
+EXPORT_TRACEPOINT_SYMBOL_GPL(nfs_fsync_exit);
-- 
2.1.0

