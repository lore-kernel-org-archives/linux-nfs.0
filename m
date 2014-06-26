Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:59298 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbaFZTNs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:13:48 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so3594160qcz.28
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:13:48 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: [PATCH v2 001/117] nfsd: fix file access refcount leak when nfsd4_truncate fails
Date: Thu, 26 Jun 2014 15:11:41 -0400
Message-Id: <1403810017-16062-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Christoph Hellwig <hch@infradead.org>

nfsd4_process_open2 will currently will get access to the file, and then
call nfsd4_truncate to (possibly) truncate it. If that operation fails
though, then the access references will never be released as the
nfs4_ol_stateid is never initialized.

Fix by moving the nfsd4_truncate call into nfs4_get_vfs_file, ensuring
that the refcounts are properly put if the truncate fails.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Signed-off-by: Christoph Hellwig <hch@infradead.org>
---
 fs/nfsd/nfs4state.c | 62 ++++++++++++++++++++++++++---------------------------
 1 file changed, 30 insertions(+), 32 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2204e1fe5725..f9049516bfae 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3042,6 +3042,21 @@ static inline int nfs4_access_to_access(u32 nfs4_access)
 	return flags;
 }
 
+static inline __be32
+nfsd4_truncate(struct svc_rqst *rqstp, struct svc_fh *fh,
+		struct nfsd4_open *open)
+{
+	struct iattr iattr = {
+		.ia_valid = ATTR_SIZE,
+		.ia_size = 0,
+	};
+	if (!open->op_truncate)
+		return 0;
+	if (!(open->op_share_access & NFS4_SHARE_ACCESS_WRITE))
+		return nfserr_inval;
+	return nfsd_setattr(rqstp, fh, &iattr, 0, (time_t)0);
+}
+
 static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
 		struct svc_fh *cur_fh, struct nfsd4_open *open)
 {
@@ -3053,53 +3068,39 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
 		status = nfsd_open(rqstp, cur_fh, S_IFREG, access,
 			&fp->fi_fds[oflag]);
 		if (status)
-			return status;
+			goto out;
 	}
 	nfs4_file_get_access(fp, oflag);
 
+	status = nfsd4_truncate(rqstp, cur_fh, open);
+	if (status)
+		goto out_put_access;
+
 	return nfs_ok;
-}
 
-static inline __be32
-nfsd4_truncate(struct svc_rqst *rqstp, struct svc_fh *fh,
-		struct nfsd4_open *open)
-{
-	struct iattr iattr = {
-		.ia_valid = ATTR_SIZE,
-		.ia_size = 0,
-	};
-	if (!open->op_truncate)
-		return 0;
-	if (!(open->op_share_access & NFS4_SHARE_ACCESS_WRITE))
-		return nfserr_inval;
-	return nfsd_setattr(rqstp, fh, &iattr, 0, (time_t)0);
+out_put_access:
+	nfs4_file_put_access(fp, oflag);
+out:
+	return status;
 }
 
 static __be32
 nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *cur_fh, struct nfs4_ol_stateid *stp, struct nfsd4_open *open)
 {
 	u32 op_share_access = open->op_share_access;
-	bool new_access;
 	__be32 status;
 
-	new_access = !test_access(op_share_access, stp);
-	if (new_access) {
+	if (!test_access(op_share_access, stp))
 		status = nfs4_get_vfs_file(rqstp, fp, cur_fh, open);
-		if (status)
-			return status;
-	}
-	status = nfsd4_truncate(rqstp, cur_fh, open);
-	if (status) {
-		if (new_access) {
-			int oflag = nfs4_access_to_omode(op_share_access);
-			nfs4_file_put_access(fp, oflag);
-		}
+	else
+		status = nfsd4_truncate(rqstp, cur_fh, open);
+
+	if (status)
 		return status;
-	}
+
 	/* remember the open */
 	set_access(op_share_access, stp);
 	set_deny(open->op_share_deny, stp);
-
 	return nfs_ok;
 }
 
@@ -3350,9 +3351,6 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		status = nfs4_get_vfs_file(rqstp, fp, current_fh, open);
 		if (status)
 			goto out;
-		status = nfsd4_truncate(rqstp, current_fh, open);
-		if (status)
-			goto out;
 		stp = open->op_stp;
 		open->op_stp = NULL;
 		init_open_stateid(stp, fp, open);
-- 
1.9.3

