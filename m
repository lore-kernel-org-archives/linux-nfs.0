Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f172.google.com ([209.85.192.172]:34998 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbaHOANU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Aug 2014 20:13:20 -0400
Message-ID: <53ED5093.6000308@gmail.com>
Date: Fri, 15 Aug 2014 08:13:07 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Jeff Layton <jeff.layton@primarydata.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-fsdevel@vger.kernel.org, kinglongmee@gmail.com
Subject: [PATCH 5/5 v3] NFSD: Increase the reference of lockowner when coping
 file_lock
References: <53BAAAC5.9000106@gmail.com>	<53E22EA5.70708@gmail.com> <20140809065112.700e0ecc@tlielax.poochiereds.net> <53E791F1.40802@gmail.com>
In-Reply-To: <53E791F1.40802@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v3: Update based on Jeff's comments
v2: Fix bad using of struct file_lock_operations for handle the owner.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4state.c | 34 ++++++++++++++++++++++++++++++----
 1 file changed, 30 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e087a71..5076497 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4869,9 +4869,31 @@ nfs4_transform_lock_offset(struct file_lock *lock)
 		lock->fl_end = OFFSET_MAX;
 }
 
-/* Hack!: For now, we're defining this just so we can use a pointer to it
- * as a unique cookie to identify our (NFSv4's) posix locks. */
+static inline struct nfs4_lockowner *
+nfs4_get_lockowner(struct nfs4_lockowner *lo)
+{
+	return lockowner(nfs4_get_stateowner(&lo->lo_owner));
+}
+
+static void nfsd4_fl_copy_owner(struct file_lock *dst, struct file_lock *src)
+{
+	struct nfs4_lockowner *lo = (struct nfs4_lockowner *) src->fl_owner;
+	dst->fl_owner = (fl_owner_t) nfs4_get_lockowner(lo);
+}
+
+static void nfsd4_fl_release_owner(struct file_lock *fl)
+{
+	struct nfs4_lockowner *lo = (struct nfs4_lockowner *) fl->fl_owner;
+
+	if (lo) {
+		nfs4_put_stateowner(&lo->lo_owner);
+		fl->fl_owner = NULL;
+	}
+}
+
 static const struct lock_manager_operations nfsd_posix_mng_ops  = {
+	.lm_copy_owner = nfsd4_fl_copy_owner,
+	.lm_release_owner = nfsd4_fl_release_owner,
 };
 
 static inline void
@@ -5236,7 +5258,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfserr_openmode;
 		goto out;
 	}
-	file_lock->fl_owner = (fl_owner_t)lock_sop;
+
+	file_lock->fl_owner = (fl_owner_t) nfs4_get_lockowner(lock_sop);
 	file_lock->fl_pid = current->tgid;
 	file_lock->fl_file = filp;
 	file_lock->fl_flags = FL_POSIX;
@@ -5403,6 +5426,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfs4_ol_stateid *stp;
 	struct file *filp = NULL;
 	struct file_lock *file_lock = NULL;
+	struct nfs4_lockowner *lock_sop = NULL;
 	__be32 status;
 	int err;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
@@ -5424,6 +5448,8 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfserr_lock_range;
 		goto put_stateid;
 	}
+
+	lock_sop = lockowner(stp->st_stateowner);
 	file_lock = locks_alloc_lock();
 	if (!file_lock) {
 		dprintk("NFSD: %s: unable to allocate lock!\n", __func__);
@@ -5432,7 +5458,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	}
 
 	file_lock->fl_type = F_UNLCK;
-	file_lock->fl_owner = (fl_owner_t)lockowner(stp->st_stateowner);
+	file_lock->fl_owner = (fl_owner_t) nfs4_get_lockowner(lock_sop);
 	file_lock->fl_pid = current->tgid;
 	file_lock->fl_file = filp;
 	file_lock->fl_flags = FL_POSIX;
-- 
1.9.3


