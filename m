From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/3] NFS: Fix an Oops when truncating a file
Date: Wed,  3 Feb 2010 15:14:37 -0500
Message-ID: <1265228079-9713-1-git-send-email-Trond.Myklebust@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63416 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757822Ab0BCUPI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Feb 2010 15:15:08 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The VM/VFS does not allow mapping->a_ops->invalidatepage() to fail.
Unfortunately, nfs_wb_page_cancel() may fail if a fatal signal occurs.
Since the NFS code assumes that the page stays mapped for as long as the
writeback is active, we can end up Oopsing (among other things).

The only safe fix here is to convert nfs_wait_on_request(), so as to make
it uninterruptible (as is already the case with wait_on_page_writeback()).


Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@kernel.org
---
 fs/nfs/pagelist.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index e297593..a12c45b 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -176,6 +176,12 @@ void nfs_release_request(struct nfs_page *req)
 	kref_put(&req->wb_kref, nfs_free_request);
 }
 
+static int nfs_wait_bit_uninterruptible(void *word)
+{
+	io_schedule();
+	return 0;
+}
+
 /**
  * nfs_wait_on_request - Wait for a request to complete.
  * @req: request to wait upon.
@@ -186,14 +192,9 @@ void nfs_release_request(struct nfs_page *req)
 int
 nfs_wait_on_request(struct nfs_page *req)
 {
-	int ret = 0;
-
-	if (!test_bit(PG_BUSY, &req->wb_flags))
-		goto out;
-	ret = out_of_line_wait_on_bit(&req->wb_flags, PG_BUSY,
-			nfs_wait_bit_killable, TASK_KILLABLE);
-out:
-	return ret;
+	return wait_on_bit(&req->wb_flags, PG_BUSY,
+			nfs_wait_bit_uninterruptible,
+			TASK_UNINTERRUPTIBLE);
 }
 
 /**
-- 
1.6.6

