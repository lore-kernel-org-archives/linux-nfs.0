Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f179.google.com ([209.85.217.179]:32997 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755973Ab3DZMAF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Apr 2013 08:00:05 -0400
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v6 6/7] NFSD: Pass share reservations flags to VFS
Date: Fri, 26 Apr 2013 16:04:20 +0400
Message-Id: <1366977861-27678-7-git-send-email-piastry@etersoft.ru>
In-Reply-To: <1366977861-27678-1-git-send-email-piastry@etersoft.ru>
References: <1366977861-27678-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

that maps them into O_DENY* flags and make them visible for
applications on mounts with sharelock option.

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 fs/locks.c          |  1 +
 fs/nfsd/nfs4state.c | 46 +++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfsd/nfsproc.c   |  1 +
 3 files changed, 47 insertions(+), 1 deletion(-)

diff --git a/fs/locks.c b/fs/locks.c
index abe8986..25c3a49 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -897,6 +897,7 @@ sharelock_lock_file(struct file *filp)
 	locks_free_lock(lock);
 	return error;
 }
+EXPORT_SYMBOL(sharelock_lock_file);
 
 static int __posix_lock_file(struct inode *inode, struct file_lock *request, struct file_lock *conflock)
 {
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2e27430..5043504 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -463,6 +463,19 @@ test_deny(u32 access, struct nfs4_ol_stateid *stp)
 	return test_bit(access, &stp->st_deny_bmap);
 }
 
+static int nfs4_deny_to_odeny(u32 access)
+{
+	switch (access & NFS4_SHARE_DENY_BOTH) {
+	case NFS4_SHARE_DENY_READ:
+		return O_DENYREAD;
+	case NFS4_SHARE_DENY_WRITE:
+		return O_DENYWRITE;
+	case NFS4_SHARE_DENY_BOTH:
+		return O_DENYREAD | O_DENYWRITE;
+	}
+	return 0;
+}
+
 static int nfs4_access_to_omode(u32 access)
 {
 	switch (access & NFS4_SHARE_ACCESS_BOTH) {
@@ -2786,6 +2799,21 @@ nfsd4_truncate(struct svc_rqst *rqstp, struct svc_fh *fh,
 }
 
 static __be32
+nfs4_vfs_set_deny(struct nfs4_file *fp, unsigned long share_access,
+		  unsigned long deny_access)
+{
+	int oflag, rc;
+	__be32 status = nfs_ok;
+
+	oflag = nfs4_access_to_omode(share_access);
+	fp->fi_fds[oflag]->f_flags |= nfs4_deny_to_odeny(deny_access);
+	rc = sharelock_lock_file(fp->fi_fds[oflag]);
+	if (rc)
+		status = nfserrno(rc);
+	return status;
+}
+
+static __be32
 nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *cur_fh, struct nfs4_ol_stateid *stp, struct nfsd4_open *open)
 {
 	u32 op_share_access = open->op_share_access;
@@ -2806,6 +2834,14 @@ nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *c
 		}
 		return status;
 	}
+	status = nfs4_vfs_set_deny(fp, op_share_access, open->op_share_deny);
+	if (status) {
+		if (new_access) {
+			int oflag = nfs4_access_to_omode(op_share_access);
+			nfs4_file_put_access(fp, oflag);
+		}
+		return status;
+	}
 	/* remember the open */
 	set_access(op_share_access, stp);
 	set_deny(open->op_share_deny, stp);
@@ -3039,7 +3075,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 
 	/*
 	 * OPEN the file, or upgrade an existing OPEN.
-	 * If truncate fails, the OPEN fails.
+	 * If truncate or set_deny fails, the OPEN fails.
 	 */
 	if (stp) {
 		/* Stateid was found, this is an OPEN upgrade */
@@ -3053,6 +3089,10 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		status = nfsd4_truncate(rqstp, current_fh, open);
 		if (status)
 			goto out;
+		status = nfs4_vfs_set_deny(fp, open->op_share_access,
+					   open->op_share_deny);
+		if (status)
+			goto out;
 		stp = open->op_stp;
 		open->op_stp = NULL;
 		init_open_stateid(stp, fp, open);
@@ -3751,6 +3791,10 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 	}
 	nfs4_stateid_downgrade(stp, od->od_share_access);
 
+	status = nfs4_vfs_set_deny(stp->st_file, od->od_share_access,
+				   od->od_share_deny);
+	if (status)
+		goto out;
 	reset_union_bmap_deny(od->od_share_deny, stp);
 
 	update_stateid(&stp->st_stid.sc_stateid);
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 54c6b3d..ff95544 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -743,6 +743,7 @@ nfserrno (int errno)
 		{ nfserr_notsupp, -EOPNOTSUPP },
 		{ nfserr_toosmall, -ETOOSMALL },
 		{ nfserr_serverfault, -ESERVERFAULT },
+		{ nfserr_share_denied, -ESHAREDENIED },
 	};
 	int	i;
 
-- 
1.8.1.5

