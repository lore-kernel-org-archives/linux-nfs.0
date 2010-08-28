Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41839 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752922Ab0H1RKM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Aug 2010 13:10:12 -0400
Date: Sat, 28 Aug 2010 13:09:53 -0400
To: Trond Myklebust <trond@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: krb5 problems in 2.6.36
Message-ID: <20100828170953.GB5104@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

As of a17c2153d2e271b0cbacae9bed83b0eaa41db7e1 "SUNRPC: Move the bound
cred to struct rpc_rqst" the NFS server crashes when using krb5.

I don't have good errors--I'll get some--but what I've seen suggests
maybe a use-after-free of an rpc client on rpc_pipefs operations by
gssd?

I need the following to compile commits in that range.

--b.

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 5eccea1..4a7c3d9 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1382,7 +1382,7 @@ static const struct rpc_call_ops nfs_commit_ops = {
 	.rpc_release = nfs_commit_release,
 };
 
-static int nfs_commit_inode(struct inode *inode, int how)
+int nfs_commit_inode(struct inode *inode, int how)
 {
 	LIST_HEAD(head);
 	int may_wait = how & FLUSH_SYNC;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index a9d8026..92926bf 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -504,6 +504,7 @@ extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 extern struct nfs_write_data *nfs_commitdata_alloc(void);
 extern void nfs_commit_free(struct nfs_write_data *wdata);
+extern int nfs_commit_inode(struct inode *inode, int how);
 #endif
 
 static inline int
