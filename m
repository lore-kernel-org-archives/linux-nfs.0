Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f48.google.com ([209.85.220.48]:50128 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbaHTKAS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Aug 2014 06:00:18 -0400
Message-ID: <53F47185.2070301@gmail.com>
Date: Wed, 20 Aug 2014 17:59:33 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Jeff Layton <jeff.layton@primarydata.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-fsdevel@vger.kernel.org, kinglongmee@gmail.com
Subject: [PATCH 6/6 v5] NFSD: Get reference of lockowner when coping file_lock
References: <53BAAAC5.9000106@gmail.com>	<53E22EA5.70708@gmail.com> <20140809065112.700e0ecc@tlielax.poochiereds.net> <53E791F1.40802@gmail.com> <53ED5093.6000308@gmail.com> <53F36CB5.2030707@gmail.com>
In-Reply-To: <53F36CB5.2030707@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v5: using nfs4_get_stateowner() instead of an inline function
v3: Update based on Jeff's comments
v2: Fix bad using of struct file_lock_operations for handle the owner

Acked-by: Jeff Layton <jlayton@primarydata.com>
Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4state.c | 25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e087a71..fd5ff4b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4869,9 +4869,25 @@ nfs4_transform_lock_offset(struct file_lock *lock)
 		lock->fl_end = OFFSET_MAX;
 }
 
-/* Hack!: For now, we're defining this just so we can use a pointer to it
- * as a unique cookie to identify our (NFSv4's) posix locks. */
+static void nfsd4_fl_get_owner(struct file_lock *dst, struct file_lock *src)
+{
+	struct nfs4_lockowner *lo = (struct nfs4_lockowner *)src->fl_owner;
+	dst->fl_owner = (fl_owner_t)lockowner(nfs4_get_stateowner(&lo->lo_owner));
+}
+
+static void nfsd4_fl_put_owner(struct file_lock *fl)
+{
+	struct nfs4_lockowner *lo = (struct nfs4_lockowner *)fl->fl_owner;
+
+	if (lo) {
+		nfs4_put_stateowner(&lo->lo_owner);
+		fl->fl_owner = NULL;
+	}
+}
+
 static const struct lock_manager_operations nfsd_posix_mng_ops  = {
+	.lm_get_owner = nfsd4_fl_get_owner,
+	.lm_put_owner = nfsd4_fl_put_owner,
 };
 
 static inline void
@@ -5236,7 +5252,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfserr_openmode;
 		goto out;
 	}
-	file_lock->fl_owner = (fl_owner_t)lock_sop;
+
+	file_lock->fl_owner = (fl_owner_t)lockowner(nfs4_get_stateowner(&lock_sop->lo_owner));
 	file_lock->fl_pid = current->tgid;
 	file_lock->fl_file = filp;
 	file_lock->fl_flags = FL_POSIX;
@@ -5432,7 +5449,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	}
 
 	file_lock->fl_type = F_UNLCK;
-	file_lock->fl_owner = (fl_owner_t)lockowner(stp->st_stateowner);
+	file_lock->fl_owner = (fl_owner_t)lockowner(nfs4_get_stateowner(stp->st_stateowner));
 	file_lock->fl_pid = current->tgid;
 	file_lock->fl_file = filp;
 	file_lock->fl_flags = FL_POSIX;
-- 
1.9.3

