Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:64855 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934528Ab3DICKk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Apr 2013 22:10:40 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFS: Ensure that NFS file unlock waits for readahead to complete
Date: Mon,  8 Apr 2013 22:10:34 -0400
Message-Id: <1365473434-63039-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1365473434-63039-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1365473434-63039-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/file.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 29f4a48..a87a44f 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -744,6 +744,7 @@ static int
 do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 {
 	struct inode *inode = filp->f_mapping->host;
+	struct nfs_lock_context *l_ctx;
 	int status;
 
 	/*
@@ -752,6 +753,14 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 	 */
 	nfs_sync_mapping(filp->f_mapping);
 
+	l_ctx = nfs_get_lock_context(nfs_file_open_context(filp));
+	if (!IS_ERR(l_ctx)) {
+		status = nfs_iocounter_wait(&l_ctx->io_count);
+		nfs_put_lock_context(l_ctx);
+		if (status < 0)
+			return status;
+	}
+
 	/* NOTE: special case
 	 * 	If we're signalled while cleaning up locks on process exit, we
 	 * 	still need to complete the unlock.
-- 
1.8.1.4

