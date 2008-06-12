From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 03/37] NFS: Add correct bounds checking to NFSv2 locks
Date: Thu, 12 Jun 2008 15:22:00 -0400
Message-ID: <20080612192200.24528.68074.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32794 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754298AbYFLTg0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:36:26 -0400
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJZvOR002089
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:36:04 -0700 (PDT)
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv2 file locking currently fails the Connectathon tests, because the
calls to the VFS locking code do not return an EINVAL error if the
struct file_lock overflows the 32-bit boundaries.

The problem is due to the fact that we occasionally call helpers from
fs/locks.c in order to avoid RPC calls to the server when we know that a
local process holds the lock. These helpers are, of course, always
64-bit enabled, so EINVAL is not returned in cases when it would if
the call had gone to the NLM code.

For consistency, we therefore add support for a bounds-checking helper.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/file.c           |   20 +++++++++++++++-----
 fs/nfs/proc.c           |   24 ++++++++++++++++++++++++
 include/linux/nfs_xdr.h |    1 +
 3 files changed, 40 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index d84a3d8..7c73f06 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -593,6 +593,7 @@ out:
 static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl)
 {
 	struct inode * inode = filp->f_mapping->host;
+	int ret = -ENOLCK;
 
 	dprintk("NFS: nfs_lock(f=%s/%ld, t=%x, fl=%x, r=%Ld:%Ld)\n",
 			inode->i_sb->s_id, inode->i_ino,
@@ -602,13 +603,22 @@ static int nfs_lock(struct file *filp, int cmd, struct file_lock *fl)
 
 	/* No mandatory locks over NFS */
 	if (__mandatory_lock(inode) && fl->fl_type != F_UNLCK)
-		return -ENOLCK;
+		goto out_err;
+
+	if (NFS_PROTO(inode)->lock_check_bounds != NULL) {
+		ret = NFS_PROTO(inode)->lock_check_bounds(fl);
+		if (ret < 0)
+			goto out_err;
+	}
 
 	if (IS_GETLK(cmd))
-		return do_getlk(filp, cmd, fl);
-	if (fl->fl_type == F_UNLCK)
-		return do_unlk(filp, cmd, fl);
-	return do_setlk(filp, cmd, fl);
+		ret = do_getlk(filp, cmd, fl);
+	else if (fl->fl_type == F_UNLCK)
+		ret = do_unlk(filp, cmd, fl);
+	else
+		ret = do_setlk(filp, cmd, fl);
+out_err:
+	return ret;
 }
 
 /*
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 03599bf..5c35b02 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -598,6 +598,29 @@ nfs_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
 	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl);
 }
 
+/* Helper functions for NFS lock bounds checking */
+#define NFS_LOCK32_OFFSET_MAX ((__s32)0x7fffffffUL)
+static int nfs_lock_check_bounds(const struct file_lock *fl)
+{
+	__s32 start, end;
+
+	start = (__s32)fl->fl_start;
+	if ((loff_t)start != fl->fl_start)
+		goto out_einval;
+
+	if (fl->fl_end != OFFSET_MAX) {
+		end = (__s32)fl->fl_end;
+		if ((loff_t)end != fl->fl_end)
+			goto out_einval;
+	} else
+		end = NFS_LOCK32_OFFSET_MAX;
+
+	if (start < 0 || start > end)
+		goto out_einval;
+	return 0;
+out_einval:
+	return -EINVAL;
+}
 
 const struct nfs_rpc_ops nfs_v2_clientops = {
 	.version	= 2,		       /* protocol version */
@@ -633,4 +656,5 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.file_open	= nfs_open,
 	.file_release	= nfs_release,
 	.lock		= nfs_proc_lock,
+	.lock_check_bounds = nfs_lock_check_bounds,
 };
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 24263bb..8d780de 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -832,6 +832,7 @@ struct nfs_rpc_ops {
 	int	(*file_open)   (struct inode *, struct file *);
 	int	(*file_release) (struct inode *, struct file *);
 	int	(*lock)(struct file *, int, struct file_lock *);
+	int	(*lock_check_bounds)(const struct file_lock *);
 	void	(*clear_acl_cache)(struct inode *);
 };
 

