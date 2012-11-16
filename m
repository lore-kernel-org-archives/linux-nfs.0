Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:32690 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750804Ab2KPCbf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Nov 2012 21:31:35 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 2/4] NFS: Add an ioctl to flush and invalidate a limited range of data
Date: Thu, 15 Nov 2012 21:31:26 -0500
Message-Id: <1353033088-47163-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353033088-47163-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1353033088-47163-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow finer grained control over the file data cache, by allowing the
user to select a particular range of data to invalidate.
This is not the same as punching a hole. Instead, dirty data will get
flushed to disk, and any clean cached data gets thrown out of the
page cache for that range.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/ioctl.c | 43 +++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/ioctl.h |  4 ++++
 2 files changed, 47 insertions(+)

diff --git a/fs/nfs/ioctl.c b/fs/nfs/ioctl.c
index 9da5f7d..e19fa9e 100644
--- a/fs/nfs/ioctl.c
+++ b/fs/nfs/ioctl.c
@@ -55,6 +55,47 @@ out:
 	return ret;
 }
 
+static bool nfs_cachectl_get_range(struct nfs_cachectl __user *argp,
+		loff_t *start, loff_t *len)
+{
+	u64 tmp;
+
+	if (get_user(tmp, &argp->start))
+		return false;
+	*start = tmp;
+	if (get_user(tmp, &argp->len))
+		return false;
+	*len = tmp;
+	return true;
+}
+
+static long nfs_ioctl_revalidate_range(struct file *filp,
+		struct nfs_cachectl __user *argp)
+{
+	loff_t start, len, end;
+	pgoff_t pgstart, pgend;
+
+	if (!nfs_cachectl_get_range(argp, &start, &len))
+		return -EFAULT;
+	end = -1;
+	if (len < 0) {
+		end = start - 1;
+		start += len;
+	} else if (len > 0)
+		end = start + len - 1;
+	if (start < 0)
+		return -EINVAL;
+
+	if (!S_ISREG(filp->f_path.dentry->d_inode->i_mode))
+		return -EINVAL;
+
+	vfs_fsync_range(filp, start, end, 1);
+
+	pgstart = start >> PAGE_CACHE_SHIFT;
+	pgend = end >> PAGE_CACHE_SHIFT;
+	return invalidate_inode_pages2_range(filp->f_mapping, pgstart, pgend);
+}
+
 static long nfs_ioctl_cachectl(struct file *filp, struct nfs_cachectl __user *argp)
 {
 	u64 cmd;
@@ -70,6 +111,8 @@ static long nfs_ioctl_cachectl(struct file *filp, struct nfs_cachectl __user *ar
 		return nfs_ioctl_cache_revalidate(filp, true, false);
 	case NFS_CACHECTL_REVALIDATE_DATA:
 		return nfs_ioctl_cache_revalidate(filp, false, true);
+	case NFS_CACHECTL_REVALIDATE_RANGE:
+		return nfs_ioctl_revalidate_range(filp, argp);
 	}
 	return -EINVAL;
 }
diff --git a/fs/nfs/ioctl.h b/fs/nfs/ioctl.h
index cf79f0d..6cf8337 100644
--- a/fs/nfs/ioctl.h
+++ b/fs/nfs/ioctl.h
@@ -27,9 +27,13 @@
 #define NFS_CACHECTL_REVALIDATE_ALL		1
 #define NFS_CACHECTL_REVALIDATE_METADATA	2
 #define NFS_CACHECTL_REVALIDATE_DATA		3
+#define NFS_CACHECTL_REVALIDATE_RANGE		4
 
 struct nfs_cachectl {
 	u64 cmd;
+
+	u64 start;
+	u64 len;
 };
 
 #define NFS_IOC_CACHECTL	_IOW('N', 1, struct nfs_cachectl)
-- 
1.7.11.7

