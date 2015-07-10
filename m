Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:62516 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932582AbbGJU77 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2015 16:59:59 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH 9/9] NFS: Remove nfs_release()
Date: Fri, 10 Jul 2015 16:58:17 -0400
Message-ID: <1436561897-8051-10-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1436561897-8051-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1436561897-8051-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

And call nfs_file_clear_open_context() directly.  This makes it obvious
that nfs_file_release() will always return 0.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/file.c  | 3 ++-
 fs/nfs/inode.c | 8 +-------
 2 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index cc4fa1e..7538a85 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -82,7 +82,8 @@ nfs_file_release(struct inode *inode, struct file *filp)
 	dprintk("NFS: release(%pD2)\n", filp);
 
 	nfs_inc_stats(inode, NFSIOS_VFSRELEASE);
-	return nfs_release(inode, filp);
+	nfs_file_clear_open_context(filp);
+	return 0;
 }
 EXPORT_SYMBOL_GPL(nfs_file_release);
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index b77b328..a0d195f 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -887,7 +887,7 @@ struct nfs_open_context *nfs_find_open_context(struct inode *inode, struct rpc_c
 	return ctx;
 }
 
-static void nfs_file_clear_open_context(struct file *filp)
+void nfs_file_clear_open_context(struct file *filp)
 {
 	struct nfs_open_context *ctx = nfs_file_open_context(filp);
 
@@ -918,12 +918,6 @@ int nfs_open(struct inode *inode, struct file *filp)
 	return 0;
 }
 
-int nfs_release(struct inode *inode, struct file *filp)
-{
-	nfs_file_clear_open_context(filp);
-	return 0;
-}
-
 /*
  * This function is called whenever some part of NFS notices that
  * the cached attributes have to be refreshed.
-- 
2.4.5

