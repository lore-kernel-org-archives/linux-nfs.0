Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:32690 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751217Ab2KPCbg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Nov 2012 21:31:36 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 4/4] NFS: Allow a process to set an aggressive caching policy on a file
Date: Thu, 15 Nov 2012 21:31:28 -0500
Message-Id: <1353033088-47163-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353033088-47163-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1353033088-47163-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353033088-47163-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353033088-47163-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch allows one process to take on the role as a file 'cache policy
controller'. It turns off the some of the more conservative caching
policies that the kernel uses, making it behave as if a delegation is
enabled.
The intention is that the cache policy controller will take over the
role of revalidating the cache using the NFS_CACHECTL ioctl.

The role is tied to an open file descriptor, which means that the
process can return control to the kernel by closing that
file descriptor (or by using the NFS_CACHECTL_CLEAR_AGGRESSIVE
ioctl).

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c         |  8 ++++++++
 fs/nfs/ioctl.c         | 36 ++++++++++++++++++++++++++++++++++++
 fs/nfs/ioctl.h         |  2 ++
 include/linux/nfs_fs.h |  2 ++
 4 files changed, 48 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 117183b..e1de62e 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -672,11 +672,14 @@ static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
 {
 	struct inode *inode = ctx->dentry->d_inode;
 	struct super_block *sb = ctx->dentry->d_sb;
+	struct nfs_inode *nfsi = NFS_I(inode);
 
 	if (!list_empty(&ctx->list)) {
 		if (!atomic_dec_and_lock(&ctx->lock_context.count, &inode->i_lock))
 			return;
 		list_del(&ctx->list);
+		if (test_bit(NFS_CONTEXT_CACHE_AGGRESSIVE, &ctx->flags))
+			nfsi->cache_validity &= ~NFS_INO_CACHE_AGGRESSIVE;
 		spin_unlock(&inode->i_lock);
 	} else if (!atomic_dec_and_test(&ctx->lock_context.count))
 		return;
@@ -885,6 +888,8 @@ static bool nfs_mapping_need_revalidate_inode(struct inode *inode)
 {
 	if (nfs_have_delegated_attributes(inode))
 		return false;
+	if (NFS_I(inode)->cache_validity & NFS_INO_CACHE_AGGRESSIVE)
+		return false;
 	return (NFS_I(inode)->cache_validity & NFS_INO_REVAL_PAGECACHE)
 		|| nfs_attribute_timeout(inode)
 		|| NFS_STALE(inode);
@@ -1484,6 +1489,9 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	if (!(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode)
 				|| S_ISLNK(inode->i_mode)))
 		invalid &= ~NFS_INO_INVALID_DATA;
+	/* Honour the aggressive caching flag */
+	if (nfsi->cache_validity & NFS_INO_CACHE_AGGRESSIVE)
+		invalid &= ~(NFS_INO_INVALID_DATA|NFS_INO_REVAL_PAGECACHE);
 	if (!NFS_PROTO(inode)->have_delegation(inode, FMODE_READ) ||
 			(save_cache_validity & NFS_INO_REVAL_FORCED))
 		nfsi->cache_validity |= invalid;
diff --git a/fs/nfs/ioctl.c b/fs/nfs/ioctl.c
index 72b8592..8c09d86 100644
--- a/fs/nfs/ioctl.c
+++ b/fs/nfs/ioctl.c
@@ -103,6 +103,38 @@ static long nfs_ioctl_return_delegation(struct file *filp)
 	return NFS_PROTO(inode)->return_delegation(inode);
 }
 
+static long nfs_ioctl_cache_aggressive(struct file *filp, bool set)
+{
+	struct inode *inode = filp->f_path.dentry->d_inode;
+	struct nfs_inode *nfsi = NFS_I(inode);
+	struct nfs_open_context *ctx;
+	int ret = 0;
+
+	/* Require write privileges to change the 'aggressive caching' mode */
+	if (!(filp->f_mode & FMODE_WRITE))
+		return -EBADF;
+	if (!S_ISREG(inode->i_mode))
+		return -EINVAL;
+	ctx = nfs_file_open_context(filp);
+	nfs_revalidate_inode(NFS_SERVER(inode), inode);
+	spin_lock(&inode->i_lock);
+	if (set) {
+		if (!(nfsi->cache_validity & NFS_INO_CACHE_AGGRESSIVE)) {
+			set_bit(NFS_CONTEXT_CACHE_AGGRESSIVE, &ctx->flags);
+			nfsi->cache_validity |= NFS_INO_CACHE_AGGRESSIVE;
+		} else
+			ret = -EBUSY;
+	} else {
+		if (test_bit(NFS_CONTEXT_CACHE_AGGRESSIVE, &ctx->flags)) {
+			nfsi->cache_validity &= ~NFS_INO_CACHE_AGGRESSIVE;
+			clear_bit(NFS_CONTEXT_CACHE_AGGRESSIVE, &ctx->flags);
+		} else
+			ret = -EINVAL;
+	}
+	spin_unlock(&inode->i_lock);
+	return ret;
+}
+
 static long nfs_ioctl_cachectl(struct file *filp, struct nfs_cachectl __user *argp)
 {
 	u64 cmd;
@@ -122,6 +154,10 @@ static long nfs_ioctl_cachectl(struct file *filp, struct nfs_cachectl __user *ar
 		return nfs_ioctl_revalidate_range(filp, argp);
 	case NFS_CACHECTL_RETURN_DELEGATION:
 		return nfs_ioctl_return_delegation(filp);
+	case NFS_CACHECTL_SET_AGGRESSIVE:
+		return nfs_ioctl_cache_aggressive(filp, true);
+	case NFS_CACHECTL_CLEAR_AGGRESSIVE:
+		return nfs_ioctl_cache_aggressive(filp, false);
 	}
 	return -EINVAL;
 }
diff --git a/fs/nfs/ioctl.h b/fs/nfs/ioctl.h
index 6cc5baf..f05b80b 100644
--- a/fs/nfs/ioctl.h
+++ b/fs/nfs/ioctl.h
@@ -29,6 +29,8 @@
 #define NFS_CACHECTL_REVALIDATE_DATA		3
 #define NFS_CACHECTL_REVALIDATE_RANGE		4
 #define NFS_CACHECTL_RETURN_DELEGATION		5
+#define NFS_CACHECTL_SET_AGGRESSIVE		6
+#define NFS_CACHECTL_CLEAR_AGGRESSIVE		7
 
 struct nfs_cachectl {
 	u64 cmd;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 1cc2568..b481ea6 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -77,6 +77,7 @@ struct nfs_open_context {
 	unsigned long flags;
 #define NFS_CONTEXT_ERROR_WRITE		(0)
 #define NFS_CONTEXT_RESEND_WRITES	(1)
+#define NFS_CONTEXT_CACHE_AGGRESSIVE	(2)
 	int error;
 
 	struct list_head list;
@@ -199,6 +200,7 @@ struct nfs_inode {
 #define NFS_INO_INVALID_ACL	0x0010		/* cached acls are invalid */
 #define NFS_INO_REVAL_PAGECACHE	0x0020		/* must revalidate pagecache */
 #define NFS_INO_REVAL_FORCED	0x0040		/* force revalidation ignoring a delegation */
+#define NFS_INO_CACHE_AGGRESSIVE 0x8000		/* force aggressive caching */
 
 /*
  * Bit offsets in flags field
-- 
1.7.11.7

