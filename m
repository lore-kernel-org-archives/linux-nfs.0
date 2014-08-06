Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f49.google.com ([209.85.220.49]:47940 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbaHFNfw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 09:35:52 -0400
Message-ID: <53E22F2C.8070900@gmail.com>
Date: Wed, 06 Aug 2014 21:35:40 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>, jlayton@redhat.com,
        linux-fsdevel@vger.kernel.org, kinglongmee@gmail.com
Subject: [PATCH 2/3] NFSD: Increase the reference of lockowner when coping
 file_lock
References: <53BAAAC5.9000106@gmail.com> <53E22EA5.70708@gmail.com>
In-Reply-To: <53E22EA5.70708@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4state.c | 33 +++++++++++++++++++++++++++++++--
 1 file changed, 31 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 24168ae..07e4b5c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4867,6 +4867,29 @@ nfs4_transform_lock_offset(struct file_lock *lock)
 		lock->fl_end = OFFSET_MAX;
 }
 
+static inline struct nfs4_lockowner *get_lockowner(struct nfs4_lockowner *lo)
+{
+	atomic_inc(&lo->lo_owner.so_count);
+	return lo;
+}
+
+static void nfsd4_fl_copy_lock(struct file_lock *dst, struct file_lock *src)
+{
+	struct nfs4_lockowner *lo = (struct nfs4_lockowner *) src->fl_owner;
+	get_lockowner(lo);
+}
+
+static void nfsd4_fl_release_lock(struct file_lock *fl)
+{
+	struct nfs4_lockowner *lo = (struct nfs4_lockowner *) fl->fl_owner;
+	nfs4_put_stateowner(&lo->lo_owner);
+}
+
+static const struct file_lock_operations nfsd4_fl_lock_ops = {
+	.fl_copy_lock = nfsd4_fl_copy_lock,
+	.fl_release_private = nfsd4_fl_release_lock,
+};
+
 static inline void
 nfs4_set_lock_denied(struct file_lock *fl, struct nfsd4_lock_denied *deny)
 {
@@ -5233,10 +5256,12 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfserr_openmode;
 		goto out;
 	}
-	file_lock->fl_owner = (fl_owner_t)lock_sop;
+
+	file_lock->fl_owner = (fl_owner_t)get_lockowner(lock_sop);
 	file_lock->fl_pid = current->tgid;
 	file_lock->fl_file = filp;
 	file_lock->fl_flags = FL_POSIX | FL_NFSD;
+	file_lock->fl_ops = &nfsd4_fl_lock_ops;
 	file_lock->fl_start = lock->lk_offset;
 	file_lock->fl_end = last_byte_offset(lock->lk_offset, lock->lk_length);
 	nfs4_transform_lock_offset(file_lock);
@@ -5399,6 +5424,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfs4_ol_stateid *stp;
 	struct file *filp = NULL;
 	struct file_lock *file_lock = NULL;
+	struct nfs4_lockowner *lock_sop = NULL;
 	__be32 status;
 	int err;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
@@ -5420,6 +5446,8 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfserr_lock_range;
 		goto put_stateid;
 	}
+
+	lock_sop = lockowner(stp->st_stateowner);
 	file_lock = locks_alloc_lock();
 	if (!file_lock) {
 		dprintk("NFSD: %s: unable to allocate lock!\n", __func__);
@@ -5428,10 +5456,11 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	}
 	locks_init_lock(file_lock);
 	file_lock->fl_type = F_UNLCK;
-	file_lock->fl_owner = (fl_owner_t)lockowner(stp->st_stateowner);
+	file_lock->fl_owner = (fl_owner_t)get_lockowner(lock_sop);
 	file_lock->fl_pid = current->tgid;
 	file_lock->fl_file = filp;
 	file_lock->fl_flags = FL_POSIX | FL_NFSD;
+	file_lock->fl_ops = &nfsd4_fl_lock_ops;
 	file_lock->fl_start = locku->lu_offset;
 
 	file_lock->fl_end = last_byte_offset(locku->lu_offset,
-- 
1.9.3

