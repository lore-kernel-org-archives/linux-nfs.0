From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v3 26/35] nfsd41: access_valid
Date: Fri,  3 Apr 2009 08:28:53 +0300
Message-ID: <1238736533-17893-1-git-send-email-bhalevy@panasas.com>
References: <49D599EA.6060705@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:30872 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757454AbZDCF26 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 01:28:58 -0400
In-Reply-To: <49D599EA.6060705@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

For nfs41, the open share flags are used also for
delegation "wants" and "signals".  Check that they are valid.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c        |    1 +
 fs/nfsd/nfs4state.c       |   20 +++++++++++++++-----
 include/linux/nfsd/xdr4.h |    1 +
 3 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3fdcca5..db208dd 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -910,6 +910,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	resp->tag = args->tag;
 	resp->opcnt = 0;
 	resp->rqstp = rqstp;
+	resp->cstate.minorversion = args->minorversion;
 	resp->cstate.replay_owner = NULL;
 	fh_init(&resp->cstate.current_fh, NFS4_FHSIZE);
 	fh_init(&resp->cstate.save_fh, NFS4_FHSIZE);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d227f85..374aaf3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1943,11 +1943,21 @@ find_file(struct inode *ino)
 	return NULL;
 }
 
-static inline int access_valid(u32 x)
+static inline int access_valid(u32 x, u32 minorversion)
 {
-	if (x < NFS4_SHARE_ACCESS_READ)
+	if ((x & NFS4_SHARE_ACCESS_MASK) < NFS4_SHARE_ACCESS_READ)
 		return 0;
-	if (x > NFS4_SHARE_ACCESS_BOTH)
+	if ((x & NFS4_SHARE_ACCESS_MASK) > NFS4_SHARE_ACCESS_BOTH)
+		return 0;
+	x &= ~NFS4_SHARE_ACCESS_MASK;
+	if (minorversion && x) {
+		if ((x & NFS4_SHARE_WANT_MASK) > NFS4_SHARE_WANT_CANCEL)
+			return 0;
+		if ((x & NFS4_SHARE_WHEN_MASK) > NFS4_SHARE_PUSH_DELEG_WHEN_UNCONTENDED)
+			return 0;
+		x &= ~(NFS4_SHARE_WANT_MASK | NFS4_SHARE_WHEN_MASK);
+	}
+	if (x)
 		return 0;
 	return 1;
 }
@@ -2495,7 +2505,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	__be32 status;
 
 	status = nfserr_inval;
-	if (!access_valid(open->op_share_access)
+	if (!access_valid(open->op_share_access, resp->cstate.minorversion)
 			|| !deny_valid(open->op_share_deny))
 		goto out;
 	/*
@@ -3104,7 +3114,7 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 			(int)cstate->current_fh.fh_dentry->d_name.len,
 			cstate->current_fh.fh_dentry->d_name.name);
 
-	if (!access_valid(od->od_share_access)
+	if (!access_valid(od->od_share_access, cstate->minorversion)
 			|| !deny_valid(od->od_share_deny))
 		return nfserr_inval;
 
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index b8b3dcb..5e16935 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -53,6 +53,7 @@ struct nfsd4_compound_state {
 	struct nfsd4_slot	*slot;
 	__be32			*statp;
 	size_t			iovlen;
+	u32			minorversion;
 	u32			status;
 };
 
-- 
1.6.2.1

