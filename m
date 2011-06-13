Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.212.179]:59388 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752911Ab1FMTtg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 15:49:36 -0400
Received: by pxi2 with SMTP id 2so3145399pxi.10
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jun 2011 12:49:35 -0700 (PDT)
Message-ID: <4DF669CC.9040205@gmail.com>
Date: Mon, 13 Jun 2011 15:49:32 -0400
From: Benny Halevy <bhalevy.lists@gmail.com>
To: Olga Kornievskaia <aglo@citi.umich.edu>
CC: benny@tonian.com, olga.kornievskaia@gmail.com,
        linux-nfs <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: 3.0.0-rc1 kernel oops
References: <BANLkTin4DBf=oW3HtJcSBQOLzySoX_7SdA@mail.gmail.com> <1399027233-1307977155-cardhu_decombobulator_blackberry.rim.net-1477776010-@b27.c3.bise3.blackberry>
In-Reply-To: <1399027233-1307977155-cardhu_decombobulator_blackberry.rim.net-1477776010-@b27.c3.bise3.blackberry>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-13 10:59, Benny Halevy wrote:
> Thanks! I'm on a call with Israel right now. I'll look into it asap.
> 
> Benny
> Sent from my BlackBerry® smartphone from orange
> 
> -----Original Message-----
> From: Olga Kornievskaia <aglo@citi.umich.edu>
> Sender: olga.kornievskaia@gmail.com
> Date: Mon, 13 Jun 2011 10:54:25 
> To: Benny Halevy<benny@tonian.com>
> Cc: linux-nfs<linux-nfs@vger.kernel.org>
> Subject: 3.0.0-rc1 kernel oops
> 
> pnfs kernel version 3.0.0-rc1. wireshark trace is attached.
> 
> INFO: task nfsd:1385 blocked for more than 120 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> nfsd            D 0000000000000001     0  1385      2 0x00000080
>  ffff88003cbe39b0 0000000000000046 ffffffff8147610e ffff88003cbe39b0
>  ffff88003cbe2010 ffff88003b70c560 0000000000012540 ffff88003cbe3fd8
>  ffff88003cbe3fd8 0000000000012540 ffff88003dee1720 ffff88003b70c560
> Call Trace:
>  [<ffffffff8147610e>] ? apic_timer_interrupt+0xe/0x20
>  [<ffffffff8146dd88>] __mutex_lock_common+0x115/0x176
>  [<ffffffff8146de04>] __mutex_lock_slowpath+0x1b/0x1d
>  [<ffffffff8146df1c>] mutex_lock+0x36/0x4a
>  [<ffffffffa02639ef>] nfs4_lock_state+0x15/0x27 [nfsd]
>  [<ffffffffa026bdac>] nfsd_layout_recall_cb+0xa9/0x320 [nfsd]
>  [<ffffffffa026f6f2>] pnfsd_lexp_recall_layout+0xfb/0x243 [nfsd]
>  [<ffffffffa024cbb4>] ? nfsd_permission+0x44/0xf7 [nfsd]
>  [<ffffffffa024e550>] nfsd_setattr+0x124/0x2b3 [nfsd]
>  [<ffffffffa02644c6>] nfsd4_process_open2+0x2e0/0x956 [nfsd]
>  [<ffffffffa025911b>] nfsd4_open+0x296/0x2cd [nfsd]
>  [<ffffffffa025868d>] nfsd4_proc_compound+0x232/0x422 [nfsd]
>  [<ffffffffa024938f>] nfsd_dispatch+0xf1/0x1d5 [nfsd]
>  [<ffffffffa01cb5a2>] svc_process_common+0x2e1/0x4d8 [sunrpc]
>  [<ffffffffa024985a>] ? nfsd_svc+0x186/0x186 [nfsd]
>  [<ffffffffa01cb9bc>] svc_process+0x11c/0x13c [sunrpc]
>  [<ffffffffa0249950>] nfsd+0xf6/0x13f [nfsd]
>  [<ffffffff81068f9e>] kthread+0x82/0x8a
>  [<ffffffff81476864>] kernel_thread_helper+0x4/0x10
>  [<ffffffff81068f1c>] ? kthread_worker_fn+0x14c/0x14c
>  [<ffffffff81476860>] ? gs_change+0x13/0x13
> 

This happened due to nested locking of the nfs4 state lock by the layout recall
code when called from the open/truncate path.

The following patch fixes this.

Benny

>From d63abc61ac06eaeb9e437a439d4c2115d5a3ea18 Mon Sep 17 00:00:00 2001
From: Benny Halevy <benny@tonian.com>
Date: Mon, 13 Jun 2011 12:51:48 -0400
Subject: [PATCH] SQUASHME: pnfsd: add a locked version of
 nfsd_layout_recall_cb

Needed for pnfsd-lext and spnfs-block which recall the layout
on the nfsd4_truncate path.

Signed-off-by: Benny Halevy <benny@tonian.com>
---
 fs/nfsd/bl_ops.c     |    4 ++--
 fs/nfsd/nfs4pnfsd.c  |   18 ++++++++++++++----
 fs/nfsd/nfs4proc.c   |    2 +-
 fs/nfsd/nfs4state.c  |    2 +-
 fs/nfsd/pnfsd.h      |    5 ++++-
 fs/nfsd/pnfsd_lexp.c |    4 ++--
 fs/nfsd/vfs.c        |    9 +++++----
 fs/nfsd/vfs.h        |   22 ++++++++++++++++++++--
 8 files changed, 49 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/bl_ops.c b/fs/nfsd/bl_ops.c
index d261a97..e84e964 100644
--- a/fs/nfsd/bl_ops.c
+++ b/fs/nfsd/bl_ops.c
@@ -553,7 +553,7 @@ bl_layoutreturn(struct inode *i,
 }

 int
-bl_layoutrecall(struct inode *inode, int type, u64 offset, u64 len)
+bl_layoutrecall(struct inode *inode, int type, u64 offset, u64 len, bool with_nfs4_state_lock)
 {
 	struct super_block		*sb;
 	struct nfsd4_pnfs_cb_layout	lr;
@@ -624,7 +624,7 @@ restart:
 				 * same thread which will cause a deadlock.
 				 */
 				spin_unlock(&r->blr_lock);
-				nfsd_layout_recall_cb(sb, inode, &lr);
+				_nfsd_layout_recall_cb(sb, inode, &lr, with_nfs4_state_lock);
 				adj = MIN(b->bll_len - (offset - b->bll_foff),
 				    len);
 				offset += adj;
diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 3d76730..b1f67eb 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -1581,8 +1581,9 @@ spawn_layout_recall(struct super_block *sb, struct list_head *todolist,
  * Spawn a thread to perform a recall layout
  *
  */
-int nfsd_layout_recall_cb(struct super_block *sb, struct inode *inode,
-			  struct nfsd4_pnfs_cb_layout *cbl)
+int
+_nfsd_layout_recall_cb(struct super_block *sb, struct inode *inode,
+		       struct nfsd4_pnfs_cb_layout *cbl, bool with_nfs4_state_lock)
 {
 	int status;
 	struct nfs4_file *lrfile = NULL;
@@ -1604,7 +1605,8 @@ int nfsd_layout_recall_cb(struct super_block *sb, struct inode *inode,
 		return -ENOENT;
 	}

-	nfs4_lock_state();
+	if (!with_nfs4_state_lock)
+		nfs4_lock_state();
 	status = -ENOENT;
 	if (inode) {
 		lrfile = find_file(inode);
@@ -1635,12 +1637,20 @@ int nfsd_layout_recall_cb(struct super_block *sb, struct inode *inode,
 	}

 err:
-	nfs4_unlock_state();
+	if (!with_nfs4_state_lock)
+		nfs4_unlock_state();
 	if (lrfile)
 		put_nfs4_file(lrfile);
 	return (todo_len && status) ? -EAGAIN : status;
 }

+int
+nfsd_layout_recall_cb(struct super_block *sb, struct inode *inode,
+		      struct nfsd4_pnfs_cb_layout *cbl)
+{
+	return _nfsd_layout_recall_cb(sb, inode, cbl, false);
+}
+
 struct create_device_notify_list_arg {
 	struct list_head *todolist;
 	struct nfsd4_pnfs_cb_dev_list *ndl;
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 71bc980..730b6e7 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -913,7 +913,7 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 #if defined(CONFIG_SPNFS_BLOCK)
 	if (pnfs_block_enabled(cstate->current_fh.fh_dentry->d_inode, 0)) {
                 status = bl_layoutrecall(cstate->current_fh.fh_dentry->d_inode,
-		    RETURN_FILE, write->wr_offset, write->wr_buflen);
+		    RETURN_FILE, write->wr_offset, write->wr_buflen, false);
                 if (!status) {
                         status =  nfsd_write(rqstp, &cstate->current_fh, filp,
 			     write->wr_offset, rqstp->rq_vec, write->wr_vlen,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 332ec8d..60fb09c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2707,7 +2707,7 @@ nfsd4_truncate(struct svc_rqst *rqstp, struct svc_fh *fh,
 		return 0;
 	if (!(open->op_share_access & NFS4_SHARE_ACCESS_WRITE))
 		return nfserr_inval;
-	return nfsd_setattr(rqstp, fh, &iattr, 0, (time_t)0);
+	return nfsd_setattr_locked(rqstp, fh, &iattr, 0, (time_t)0);
 }

 static __be32
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index fa4f5e0..a4c8a9c 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -128,6 +128,9 @@ void nomatching_layout(struct nfs4_layoutrecall *);
 void pnfs_roc(struct nfs4_client *clp, struct nfs4_file *fp);
 void *layoutrecall_done(struct nfs4_layoutrecall *);
 void nfsd4_cb_layout(struct nfs4_layoutrecall *);
+int _nfsd_layout_recall_cb(struct super_block *, struct inode *,
+			  struct nfsd4_pnfs_cb_layout *,
+			  bool with_nfs4_state_lock);
 int nfsd_layout_recall_cb(struct super_block *, struct inode *,
 			  struct nfsd4_pnfs_cb_layout *);
 int nfsd_device_notify_cb(struct super_block *,
@@ -142,7 +145,7 @@ extern size_t pnfs_lexp_addr_len;

 extern void pnfsd_lexp_init(struct inode *);
 extern bool is_inode_pnfsd_lexp(struct inode *);
-extern int pnfsd_lexp_recall_layout(struct inode *);
+extern int pnfsd_lexp_recall_layout(struct inode *, bool with_nfs4_state_lock);
 #endif /* CONFIG_PNFSD_LOCAL_EXPORT */

 #endif /* LINUX_NFSD_PNFSD_H */
diff --git a/fs/nfsd/pnfsd_lexp.c b/fs/nfsd/pnfsd_lexp.c
index 3676ba3..4d8bceb 100644
--- a/fs/nfsd/pnfsd_lexp.c
+++ b/fs/nfsd/pnfsd_lexp.c
@@ -258,7 +258,7 @@ has_layout(struct nfs4_file *fp)
  * recalls the layout if needed and waits synchronously for its return
  */
 int
-pnfsd_lexp_recall_layout(struct inode *inode)
+pnfsd_lexp_recall_layout(struct inode *inode, bool with_nfs4_state_lock)
 {
 	struct nfs4_file *fp;
 	struct nfsd4_pnfs_cb_layout cbl;
@@ -281,7 +281,7 @@ pnfsd_lexp_recall_layout(struct inode *inode)

 	while (has_layout(fp)) {
 		dprintk("%s: recalling layout\n", __func__);
-		status = nfsd_layout_recall_cb(inode->i_sb, inode, &cbl);
+		status = _nfsd_layout_recall_cb(inode->i_sb, inode, &cbl, with_nfs4_state_lock);

 		switch (status) {
 		case 0:
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 837985b..0ca74b1 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -304,8 +304,8 @@ commit_metadata(struct svc_fh *fhp)
  * N.B. After this call fhp needs an fh_put
  */
 __be32
-nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
-	     int check_guard, time_t guardtime)
+_nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
+	      int check_guard, time_t guardtime, bool with_nfs4_state_lock)
 {
 	struct dentry	*dentry;
 	struct inode	*inode;
@@ -384,12 +384,13 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 				goto out;
 #if defined(CONFIG_PNFSD_LOCAL_EXPORT)
 			if (is_inode_pnfsd_lexp(inode))
-				pnfsd_lexp_recall_layout(inode);
+				pnfsd_lexp_recall_layout(inode, with_nfs4_state_lock);
 #endif /* CONFIG_PNFSD_LOCAL_EXPORT */
 #if defined(CONFIG_SPNFS_BLOCK)
 			if (pnfs_block_enabled(inode, 0)) {
 				err = bl_layoutrecall(inode, RETURN_FILE,
-				    iap->ia_size, inode->i_size - iap->ia_size);
+					iap->ia_size, inode->i_size - iap->ia_size,
+					with_nfs4_state_lock);
 			}
 #endif /* CONFIG_SPNFS_BLOCK */
 		}
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index e0bbac0..a4a28a8 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -45,8 +45,26 @@ __be32		nfsd_lookup(struct svc_rqst *, struct svc_fh *,
 __be32		 nfsd_lookup_dentry(struct svc_rqst *, struct svc_fh *,
 				const char *, unsigned int,
 				struct svc_export **, struct dentry **);
-__be32		nfsd_setattr(struct svc_rqst *, struct svc_fh *,
-				struct iattr *, int, time_t);
+__be32		_nfsd_setattr(struct svc_rqst *, struct svc_fh *,
+			      struct iattr *, int, time_t,
+			      bool with_nfs4_state_lock);
+
+/* call when nfs4_lock_state has not been taken */
+static inline __be32
+nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
+	     struct iattr *iap, int check_guard, time_t guardtime)
+{
+	return _nfsd_setattr(rqstp, fhp, iap, check_guard, guardtime, false);
+}
+
+/* call when nfs4_lock_state is taken */
+static inline __be32
+nfsd_setattr_locked(struct svc_rqst *rqstp, struct svc_fh *fhp,
+		    struct iattr *iap, int check_guard, time_t guardtime)
+{
+	return _nfsd_setattr(rqstp, fhp, iap, check_guard, guardtime, true);
+}
+
 int nfsd_mountpoint(struct dentry *, struct svc_export *);
 #ifdef CONFIG_NFSD_V4
 __be32          nfsd4_set_nfs4_acl(struct svc_rqst *, struct svc_fh *,
-- 
1.7.4.4


