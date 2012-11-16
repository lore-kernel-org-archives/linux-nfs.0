Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:32690 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751148Ab2KPCbf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Nov 2012 21:31:35 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 3/4] NFS: Allow users to return the delegation
Date: Thu, 15 Nov 2012 21:31:27 -0500
Message-Id: <1353033088-47163-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353033088-47163-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1353033088-47163-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353033088-47163-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Not all processes are optimised by delegations. If the file is being
accessed by several clients simultaneously (or even sequentially)
then performance can suffer if the server has to keep doing
delegation callbacks.
This ioctl allows the process to pre-emptively return the delegation
and hence turn off aggressive caching of the file. It is expected
that most applications that want to use this feature will do so
just before the last close of the file.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/ioctl.c | 9 +++++++++
 fs/nfs/ioctl.h | 1 +
 2 files changed, 10 insertions(+)

diff --git a/fs/nfs/ioctl.c b/fs/nfs/ioctl.c
index e19fa9e..72b8592 100644
--- a/fs/nfs/ioctl.c
+++ b/fs/nfs/ioctl.c
@@ -96,6 +96,13 @@ static long nfs_ioctl_revalidate_range(struct file *filp,
 	return invalidate_inode_pages2_range(filp->f_mapping, pgstart, pgend);
 }
 
+static long nfs_ioctl_return_delegation(struct file *filp)
+{
+	struct inode *inode = filp->f_path.dentry->d_inode;
+
+	return NFS_PROTO(inode)->return_delegation(inode);
+}
+
 static long nfs_ioctl_cachectl(struct file *filp, struct nfs_cachectl __user *argp)
 {
 	u64 cmd;
@@ -113,6 +120,8 @@ static long nfs_ioctl_cachectl(struct file *filp, struct nfs_cachectl __user *ar
 		return nfs_ioctl_cache_revalidate(filp, false, true);
 	case NFS_CACHECTL_REVALIDATE_RANGE:
 		return nfs_ioctl_revalidate_range(filp, argp);
+	case NFS_CACHECTL_RETURN_DELEGATION:
+		return nfs_ioctl_return_delegation(filp);
 	}
 	return -EINVAL;
 }
diff --git a/fs/nfs/ioctl.h b/fs/nfs/ioctl.h
index 6cf8337..6cc5baf 100644
--- a/fs/nfs/ioctl.h
+++ b/fs/nfs/ioctl.h
@@ -28,6 +28,7 @@
 #define NFS_CACHECTL_REVALIDATE_METADATA	2
 #define NFS_CACHECTL_REVALIDATE_DATA		3
 #define NFS_CACHECTL_REVALIDATE_RANGE		4
+#define NFS_CACHECTL_RETURN_DELEGATION		5
 
 struct nfs_cachectl {
 	u64 cmd;
-- 
1.7.11.7

