Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:33433 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751801AbbHTLRh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 07:17:37 -0400
Received: by ykll84 with SMTP id l84so33733251ykl.0
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 04:17:36 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@lst.de, kinglongmee@gmail.com
Subject: [PATCH v3 10/20] nfsd: handle NFSD_MAY_NOT_BREAK_LEASE in open file cache
Date: Thu, 20 Aug 2015 07:17:10 -0400
Message-Id: <1440069440-27454-11-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
References: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFSD_MAY_NOT_BREAK_LEASE flag needs special handling. If we open a
file in order to do (e.g.) a COMMIT then we don't want to break any
leases, but subsequent READ/WRITE operations must break the leases.

If we construct a new cache entry with a set of may flags that have
NFSD_MAY_NOT_BREAK_LEASE set, then set flags in the cache entry that
indicate that subsequent users of this file must break leases before
using it if they do not have NFSD_MAY_NOT_BREAK_LEASE set.

Note that because NFSD_MAY_READ opens do not break read leases, we
must track what sort of lease breaks have been done. If we're breaking
leases for read, then we still need to do a lease break for write if
it's a R/W open and a writer comes along. Lease breaks for write
however imply a read lease break so we can clear both flags in that
event.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/filecache.c | 39 +++++++++++++++++++++++++++++++++++----
 fs/nfsd/filecache.h |  2 ++
 fs/nfsd/vfs.c       |  3 ++-
 fs/nfsd/vfs.h       |  1 +
 4 files changed, 40 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 77041967d8ff..10aa698b6057 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -47,6 +47,12 @@ nfsd_file_alloc(struct inode *inode, unsigned int may, unsigned int hashval)
 		nf->nf_hashval = hashval;
 		atomic_set(&nf->nf_ref, 1);
 		nf->nf_may = NFSD_FILE_MAY_MASK & may;
+		if (may & NFSD_MAY_NOT_BREAK_LEASE) {
+			if (may & NFSD_MAY_WRITE)
+				__set_bit(NFSD_FILE_BREAK_WRITE, &nf->nf_flags);
+			if (may & NFSD_MAY_READ)
+				__set_bit(NFSD_FILE_BREAK_READ, &nf->nf_flags);
+		}
 	}
 	return nf;
 }
@@ -286,9 +292,6 @@ nfsd_file_acquire(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (status != nfs_ok)
 		return status;
 
-	/* Mask off any extraneous bits */
-	may_flags &= NFSD_FILE_MAY_MASK;
-
 	inode = d_inode(fhp->fh_dentry);
 	hashval = (unsigned int)hash_ptr(inode, NFSD_FILE_HASH_BITS);
 retry:
@@ -331,7 +334,7 @@ wait_for_construction:
 		 * MAY flags are equal. Otherwise, we put the reference and try
 		 * again.
 		 */
-		if (may_flags != nf->nf_may) {
+		if ((may_flags & NFSD_FILE_MAY_MASK) != nf->nf_may) {
 			nfsd_file_put(nf);
 			goto retry;
 		}
@@ -339,6 +342,18 @@ wait_for_construction:
 		/* try to take over construction for this file */
 		if (test_and_set_bit(NFSD_FILE_PENDING, &nf->nf_flags))
 			goto wait_for_construction;
+
+		/* sync up the BREAK_* flags with our may_flags */
+		if (may_flags & NFSD_MAY_NOT_BREAK_LEASE) {
+			if (may_flags & NFSD_MAY_WRITE)
+				set_bit(NFSD_FILE_BREAK_WRITE, &nf->nf_flags);
+			if (may_flags & NFSD_MAY_READ)
+				set_bit(NFSD_FILE_BREAK_READ, &nf->nf_flags);
+		} else {
+			clear_bit(NFSD_FILE_BREAK_WRITE, &nf->nf_flags);
+			clear_bit(NFSD_FILE_BREAK_READ, &nf->nf_flags);
+		}
+
 		goto open_file;
 	}
 
@@ -349,6 +364,22 @@ wait_for_construction:
 	 */
 	status = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
 					may_flags|NFSD_MAY_OWNER_OVERRIDE);
+
+	if (status == nfs_ok && !(may_flags & NFSD_MAY_NOT_BREAK_LEASE)) {
+		bool write = (may_flags & NFSD_MAY_WRITE);
+
+		if (test_bit(NFSD_FILE_BREAK_READ, &nf->nf_flags) ||
+		    (test_bit(NFSD_FILE_BREAK_WRITE, &nf->nf_flags) && write)) {
+			status = nfserrno(nfsd_open_break_lease(
+					file_inode(nf->nf_file), may_flags));
+			if (status == nfs_ok) {
+				clear_bit(NFSD_FILE_BREAK_READ, &nf->nf_flags);
+				if (write)
+					clear_bit(NFSD_FILE_BREAK_WRITE,
+						  &nf->nf_flags);
+			}
+		}
+	}
 out:
 	if (status == nfs_ok)
 		*pnf = nf;
diff --git a/fs/nfsd/filecache.h b/fs/nfsd/filecache.h
index e7da463446dd..debd558ef786 100644
--- a/fs/nfsd/filecache.h
+++ b/fs/nfsd/filecache.h
@@ -13,6 +13,8 @@ struct nfsd_file {
 	struct file		*nf_file;
 #define NFSD_FILE_HASHED	(0)
 #define NFSD_FILE_PENDING	(1)
+#define NFSD_FILE_BREAK_READ	(2)
+#define NFSD_FILE_BREAK_WRITE	(3)
 	unsigned long		nf_flags;
 	struct inode		*nf_inode;
 	unsigned int		nf_hashval;
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index eb64597f3bde..81600bd06fef 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -618,7 +618,8 @@ nfsd_access(struct svc_rqst *rqstp, struct svc_fh *fhp, u32 *access, u32 *suppor
 }
 #endif /* CONFIG_NFSD_V3 */
 
-static int nfsd_open_break_lease(struct inode *inode, int access)
+int
+nfsd_open_break_lease(struct inode *inode, int access)
 {
 	unsigned int mode;
 
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 78b5527cba93..a3ec59830297 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -69,6 +69,7 @@ __be32		do_nfsd_create(struct svc_rqst *, struct svc_fh *,
 __be32		nfsd_commit(struct svc_rqst *, struct svc_fh *,
 				loff_t, unsigned long);
 #endif /* CONFIG_NFSD_V3 */
+int		nfsd_open_break_lease(struct inode *, int);
 __be32		nfsd_open(struct svc_rqst *, struct svc_fh *, umode_t,
 				int, struct file **);
 struct raparms;
-- 
2.4.3

