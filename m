Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f42.google.com ([209.85.216.42]:35501 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757910AbaFSOvK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:51:10 -0400
Received: by mail-qa0-f42.google.com with SMTP id dc16so2053110qab.15
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:51:09 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 008/104] NFSd: Ensure that nfs4_file_get_access enforces share access modes
Date: Thu, 19 Jun 2014 10:49:14 -0400
Message-Id: <1403189450-18729-9-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Lock atomicity requires us to check the share access mode when we
actually open the file. Note that ideally this would also be atomic
with file creation.

With the change to make nfs4_file_get_access enforce the share mode, we
now have a bogus WARN_ON that can fire. It's now normal to call
nfs4_file_get_access before populating the fi_fds field for the open
flag, so we should no longer warn on that situation.

The other case is a WARN_ON that can occur if there's a O_RDWR open
already present. I'm unclear on why we'd WARN_ON in that case. This
patch removes it, but please do enlighten me if there's some reason
we ought to keep it instead.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 163 +++++++++++++++++++++++++++++++++++++---------------
 fs/nfsd/state.h     |   1 +
 2 files changed, 118 insertions(+), 46 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f17e3b999be6..17870de5989d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -320,6 +320,20 @@ static unsigned int ownerstr_hashval(u32 clientid, struct xdr_netobj *ownername)
 #define FILE_HASH_BITS                   8
 #define FILE_HASH_SIZE                  (1 << FILE_HASH_BITS)
 
+static int nfs4_access_to_omode(u32 access)
+{
+	switch (access & NFS4_SHARE_ACCESS_BOTH) {
+	case NFS4_SHARE_ACCESS_READ:
+		return O_RDONLY;
+	case NFS4_SHARE_ACCESS_WRITE:
+		return O_WRONLY;
+	case NFS4_SHARE_ACCESS_BOTH:
+		return O_RDWR;
+	}
+	WARN_ON_ONCE(1);
+	return O_RDONLY;
+}
+
 static unsigned int file_hashval(struct inode *ino)
 {
 	/* XXX: why are we hashing on inode pointer, anyway? */
@@ -328,19 +342,33 @@ static unsigned int file_hashval(struct inode *ino)
 
 static struct hlist_head file_hashtbl[FILE_HASH_SIZE];
 
-static void __nfs4_file_get_access(struct nfs4_file *fp, int oflag)
+static __be32 nfs4_file_get_access(struct nfs4_file *fp, u32 access, u32 deny)
 {
-	WARN_ON_ONCE(!(fp->fi_fds[oflag] || fp->fi_fds[O_RDWR]));
-	atomic_inc(&fp->fi_access[oflag]);
-}
+	int oflag = nfs4_access_to_omode(access);
 
-static void nfs4_file_get_access(struct nfs4_file *fp, int oflag)
-{
+	/* Note: relies on NFS4_SHARE_ACCESS_BOTH == READ|WRITE */
+	access &= (NFS4_SHARE_ACCESS_READ|NFS4_SHARE_ACCESS_WRITE);
+	if (access == 0)
+		return nfserr_inval;
+	if ((access & fp->fi_share_deny) != 0)
+		return nfserr_share_denied;
+	/* Note: relies on NFS4_SHARE_DENY_BOTH == READ|WRITE */
+	deny &= (NFS4_SHARE_DENY_READ|NFS4_SHARE_DENY_WRITE);
+	if (deny) {
+		if ((deny & NFS4_SHARE_DENY_READ) &&
+		    atomic_read(&fp->fi_access[O_RDONLY]))
+			return nfserr_share_denied;
+		if ((deny & NFS4_SHARE_DENY_WRITE) &&
+		    atomic_read(&fp->fi_access[O_WRONLY]))
+			return nfserr_share_denied;
+		fp->fi_share_deny |= deny;
+	}
 	if (oflag == O_RDWR) {
-		__nfs4_file_get_access(fp, O_RDONLY);
-		__nfs4_file_get_access(fp, O_WRONLY);
+		atomic_inc(&fp->fi_access[O_RDONLY]);
+		atomic_inc(&fp->fi_access[O_WRONLY]);
 	} else
-		__nfs4_file_get_access(fp, oflag);
+		atomic_inc(&fp->fi_access[oflag]);
+	return nfs_ok;
 }
 
 static struct file *nfs4_file_put_fd(struct nfs4_file *fp, int oflag)
@@ -352,6 +380,17 @@ static struct file *nfs4_file_put_fd(struct nfs4_file *fp, int oflag)
 	return filp;
 }
 
+static void __nfs4_file_put_deny(struct nfs4_file *fp, u32 deny)
+{
+	/* Note: relies on NFS4_SHARE_DENY_BOTH == READ|WRITE */
+	deny &= (NFS4_SHARE_DENY_READ|NFS4_SHARE_DENY_WRITE);
+	if (!deny)
+		return;
+	spin_lock(&fp->fi_lock);
+	fp->fi_share_deny &= ~deny;
+	spin_unlock(&fp->fi_lock);
+}
+
 static void __nfs4_file_put_access(struct nfs4_file *fp, int oflag)
 {
 	if (atomic_dec_and_lock(&fp->fi_access[oflag], &fp->fi_lock)) {
@@ -369,8 +408,16 @@ static void __nfs4_file_put_access(struct nfs4_file *fp, int oflag)
 	}
 }
 
-static void nfs4_file_put_access(struct nfs4_file *fp, int oflag)
+static void nfs4_file_put_access(struct nfs4_file *fp, u32 access, u32 deny)
 {
+	int oflag;
+
+	__nfs4_file_put_deny(fp, deny);
+	/* Note: relies on NFS4_SHARE_ACCESS_BOTH == READ|WRITE */
+	access &= (NFS4_SHARE_ACCESS_READ|NFS4_SHARE_ACCESS_WRITE);
+	if (!access)
+		return;
+	oflag = nfs4_access_to_omode(access);
 	if (oflag == O_RDWR) {
 		__nfs4_file_put_access(fp, O_RDONLY);
 		__nfs4_file_put_access(fp, O_WRONLY);
@@ -650,31 +697,21 @@ test_deny(u32 access, struct nfs4_ol_stateid *stp)
 	return test_bit(access, &stp->st_deny_bmap);
 }
 
-static int nfs4_access_to_omode(u32 access)
-{
-	switch (access & NFS4_SHARE_ACCESS_BOTH) {
-	case NFS4_SHARE_ACCESS_READ:
-		return O_RDONLY;
-	case NFS4_SHARE_ACCESS_WRITE:
-		return O_WRONLY;
-	case NFS4_SHARE_ACCESS_BOTH:
-		return O_RDWR;
-	}
-	WARN_ON_ONCE(1);
-	return O_RDONLY;
-}
-
 /* release all access and file references for a given stateid */
 static void
 release_all_access(struct nfs4_ol_stateid *stp)
 {
-	int i;
+	u32 i;
 
 	for (i = 1; i < 4; i++) {
-		if (test_access(i, stp))
-			nfs4_file_put_access(stp->st_file,
-					     nfs4_access_to_omode(i));
-		clear_access(i, stp);
+		if (test_deny(i, stp)) {
+			nfs4_file_put_access(stp->st_file, 0, i);
+			clear_deny(i, stp);
+		}
+		if (test_access(i, stp)) {
+			nfs4_file_put_access(stp->st_file, i, 0);
+			clear_access(i, stp);
+		}
 	}
 }
 
@@ -2623,6 +2660,7 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino)
 	fp->fi_lease = NULL;
 	memset(fp->fi_fds, 0, sizeof(fp->fi_fds));
 	memset(fp->fi_access, 0, sizeof(fp->fi_access));
+	fp->fi_share_deny = 0;
 	hlist_add_head(&fp->fi_hash, &file_hashtbl[hashval]);
 }
 
@@ -3097,23 +3135,31 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
 	int access = nfs4_access_to_access(open->op_share_access);
 
 	spin_lock(&fp->fi_lock);
+	status = nfs4_file_get_access(fp,
+			open->op_share_access,
+			open->op_share_deny);
+	if (status)
+		goto out;
 	if (!fp->fi_fds[oflag]) {
 		spin_unlock(&fp->fi_lock);
 		status = nfsd_open(rqstp, cur_fh, S_IFREG, access, &filp);
-		if (status)
+		if (status) {
+			nfs4_file_put_access(fp, open->op_share_access,
+					open->op_share_deny);
 			return status;
+		}
 		spin_lock(&fp->fi_lock);
 		if (!fp->fi_fds[oflag]) {
 			fp->fi_fds[oflag] = filp;
 			filp = NULL;
 		}
 	}
-	nfs4_file_get_access(fp, oflag);
+out:
 	spin_unlock(&fp->fi_lock);
 	if (filp)
 		fput(filp);
 
-	return nfs_ok;
+	return status;
 }
 
 static inline __be32
@@ -3146,10 +3192,9 @@ nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *c
 	}
 	status = nfsd4_truncate(rqstp, cur_fh, open);
 	if (status) {
-		if (new_access) {
-			int oflag = nfs4_access_to_omode(op_share_access);
-			nfs4_file_put_access(fp, oflag);
-		}
+		if (new_access)
+			nfs4_file_put_access(fp, op_share_access,
+					open->op_share_deny);
 		return status;
 	}
 	/* remember the open */
@@ -4059,17 +4104,25 @@ out:
 	return status;
 }
 
-static inline void nfs4_stateid_downgrade_bit(struct nfs4_ol_stateid *stp, u32 access)
+static void nfs4_stateid_downgrade_bit(struct nfs4_ol_stateid *stp, u32 access)
 {
 	if (!test_access(access, stp))
 		return;
-	nfs4_file_put_access(stp->st_file, nfs4_access_to_omode(access));
+	nfs4_file_put_access(stp->st_file, access, 0);
 	clear_access(access, stp);
 }
 
-static inline void nfs4_stateid_downgrade(struct nfs4_ol_stateid *stp, u32 to_access)
+static void nfs4_stateid_downgrade_deny_bit(struct nfs4_ol_stateid *stp, u32 deny)
+{
+	if (!test_deny(deny, stp))
+		return;
+	nfs4_file_put_access(stp->st_file, 0, deny);
+	clear_deny(deny, stp);
+}
+
+static void nfs4_stateid_downgrade(struct nfs4_ol_stateid *stp, u32 to_access, u32 to_deny)
 {
-	switch (to_access) {
+	switch (to_access & NFS4_SHARE_ACCESS_BOTH) {
 	case NFS4_SHARE_ACCESS_READ:
 		nfs4_stateid_downgrade_bit(stp, NFS4_SHARE_ACCESS_WRITE);
 		nfs4_stateid_downgrade_bit(stp, NFS4_SHARE_ACCESS_BOTH);
@@ -4083,15 +4136,34 @@ static inline void nfs4_stateid_downgrade(struct nfs4_ol_stateid *stp, u32 to_ac
 	default:
 		WARN_ON_ONCE(1);
 	}
+
+	switch (to_deny & NFS4_SHARE_DENY_BOTH) {
+	case 0:
+		nfs4_stateid_downgrade_deny_bit(stp, NFS4_SHARE_DENY_BOTH);
+		nfs4_stateid_downgrade_deny_bit(stp, NFS4_SHARE_DENY_WRITE);
+		nfs4_stateid_downgrade_deny_bit(stp, NFS4_SHARE_DENY_READ);
+		break;
+	case NFS4_SHARE_DENY_READ:
+		nfs4_stateid_downgrade_deny_bit(stp, NFS4_SHARE_DENY_BOTH);
+		nfs4_stateid_downgrade_deny_bit(stp, NFS4_SHARE_DENY_WRITE);
+		break;
+	case NFS4_SHARE_DENY_WRITE:
+		nfs4_stateid_downgrade_deny_bit(stp, NFS4_SHARE_DENY_BOTH);
+		nfs4_stateid_downgrade_deny_bit(stp, NFS4_SHARE_DENY_READ);
+	}
 }
 
 static void
 reset_union_bmap_deny(unsigned long deny, struct nfs4_ol_stateid *stp)
 {
-	int i;
-	for (i = 0; i < 4; i++) {
-		if ((i & deny) != i)
+	u32 i;
+	for (i = 3; i > 0; i--) {
+		if (i == deny)
+			continue;
+		if (test_deny(i, stp)) {
+			nfs4_file_put_access(stp->st_file, 0, i);
 			clear_deny(i, stp);
+		}
 	}
 }
 
@@ -4128,7 +4200,7 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 			stp->st_deny_bmap, od->od_share_deny);
 		goto out;
 	}
-	nfs4_stateid_downgrade(stp, od->od_share_access);
+	nfs4_stateid_downgrade(stp, od->od_share_access, od->od_share_deny);
 
 	reset_union_bmap_deny(od->od_share_deny, stp);
 
@@ -4410,11 +4482,10 @@ check_lock_length(u64 offset, u64 length)
 static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
 {
 	struct nfs4_file *fp = lock_stp->st_file;
-	int oflag = nfs4_access_to_omode(access);
 
 	if (test_access(access, lock_stp))
 		return;
-	nfs4_file_get_access(fp, oflag);
+	nfs4_file_get_access(fp, access, 0);
 	set_access(access, lock_stp);
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 1c0190c0fd88..be5ab8151b0c 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -397,6 +397,7 @@ struct nfs4_file {
 	 *   + 1 to both of the above if NFS4_SHARE_ACCESS_BOTH is set.
 	 */
 	atomic_t		fi_access[2];
+	u32			fi_share_deny;
 	struct file		*fi_deleg_file;
 	struct file_lock	*fi_lease;
 	atomic_t		fi_delegees;
-- 
1.9.3

