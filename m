Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8493 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756259Ab0IPVCH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Sep 2010 17:02:07 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: viro@zeniv.linux.org.uk, hch@infradead.org
Subject: [PATCH 6/6] NFS: Add an 'open_context' element to struct nfs_rpc_ops
Date: Thu, 16 Sep 2010 17:01:43 -0400
Message-Id: <1284670903-28475-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1284670903-28475-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1284670903-28475-1-git-send-email-Trond.Myklebust@netapp.com>
 <1284670903-28475-2-git-send-email-Trond.Myklebust@netapp.com>
 <1284670903-28475-3-git-send-email-Trond.Myklebust@netapp.com>
 <1284670903-28475-4-git-send-email-Trond.Myklebust@netapp.com>
 <1284670903-28475-5-git-send-email-Trond.Myklebust@netapp.com>
 <1284670903-28475-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c            |    7 ++++---
 fs/nfs/nfs4_fs.h        |    1 -
 fs/nfs/nfs4proc.c       |    3 ++-
 include/linux/nfs_xdr.h |    4 ++++
 4 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e37ffdd..1e9e188 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -34,7 +34,6 @@
 #include <linux/mount.h>
 #include <linux/sched.h>
 
-#include "nfs4_fs.h"
 #include "delegation.h"
 #include "iostat.h"
 #include "internal.h"
@@ -1127,7 +1126,7 @@ static struct dentry *nfs_atomic_lookup(struct inode *dir, struct dentry *dentry
 
 	/* Open the file on the server */
 	nfs_block_sillyrename(dentry->d_parent);
-	inode = nfs4_atomic_open(dir, ctx, open_flags, &attr);
+	inode = NFS_PROTO(dir)->open_context(dir, ctx, open_flags, &attr);
 	if (IS_ERR(inode)) {
 		nfs_unblock_sillyrename(dentry->d_parent);
 		put_nfs_open_context(ctx);
@@ -1175,8 +1174,10 @@ static int nfs_open_revalidate(struct dentry *dentry, struct nameidata *nd)
 
 	if (!is_atomic_open(nd) || d_mountpoint(dentry))
 		goto no_open;
+
 	parent = dget_parent(dentry);
 	dir = parent->d_inode;
+
 	/* We can't create new files in nfs_open_revalidate(), so we
 	 * optimize away revalidation of negative dentries.
 	 */
@@ -1205,7 +1206,7 @@ static int nfs_open_revalidate(struct dentry *dentry, struct nameidata *nd)
 	 * operations that change the directory. We therefore save the
 	 * change attribute *before* we do the RPC call.
 	 */
-	inode = nfs4_atomic_open(dir, ctx, openflags, NULL);
+	inode = NFS_PROTO(dir)->open_context(dir, ctx, openflags, NULL);
 	if (IS_ERR(inode)) {
 		ret = PTR_ERR(inode);
 		switch (ret) {
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 6cf12ba..d24a8e0 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -242,7 +242,6 @@ extern int nfs4_proc_renew(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_do_close(struct path *path, struct nfs4_state *state, gfp_t gfp_mask, int wait);
-extern struct inode *nfs4_atomic_open(struct inode *, struct nfs_open_context *, int, struct iattr *);
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
 extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 617b149..643abd2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1998,7 +1998,7 @@ out:
 	return status;
 }
 
-struct inode *
+static struct inode *
 nfs4_atomic_open(struct inode *dir, struct nfs_open_context *ctx, int open_flags, struct iattr *attr)
 {
 	struct nfs4_state *state;
@@ -5358,6 +5358,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.lock		= nfs4_proc_lock,
 	.clear_acl_cache = nfs4_zap_acl_attr,
 	.close_context  = nfs4_close_context,
+	.open_context	= nfs4_atomic_open,
 };
 
 /*
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index b1484da..6f345f8 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1065,6 +1065,10 @@ struct nfs_rpc_ops {
 	int	(*lock_check_bounds)(const struct file_lock *);
 	void	(*clear_acl_cache)(struct inode *);
 	void	(*close_context)(struct nfs_open_context *ctx, int);
+	struct inode * (*open_context) (struct inode *dir,
+				struct nfs_open_context *ctx,
+				int open_flags,
+				struct iattr *iattr);
 };
 
 /*
-- 
1.7.2.3

