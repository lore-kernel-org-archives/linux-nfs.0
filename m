Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44188 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754884Ab1JKQlJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Oct 2011 12:41:09 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/4] nfsd4: move access/deny validity checks to xdr code
Date: Tue, 11 Oct 2011 12:41:01 -0400
Message-Id: <1318351263-14918-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1318351263-14918-1-git-send-email-bfields@redhat.com>
References: <1318351263-14918-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'd rather put more of these sorts of checks into standardized xdr
decoders for the various types rather than have them cluttering up the
core logic in nfs4proc.c and nfs4state.c.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   32 --------------------
 fs/nfsd/nfs4xdr.c   |   80 ++++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 73 insertions(+), 39 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a39a542..6bfa293 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2418,31 +2418,6 @@ find_file(struct inode *ino)
 	return NULL;
 }
 
-static inline int access_valid(u32 x, u32 minorversion)
-{
-	if ((x & NFS4_SHARE_ACCESS_MASK) < NFS4_SHARE_ACCESS_READ)
-		return 0;
-	if ((x & NFS4_SHARE_ACCESS_MASK) > NFS4_SHARE_ACCESS_BOTH)
-		return 0;
-	x &= ~NFS4_SHARE_ACCESS_MASK;
-	if (minorversion && x) {
-		if ((x & NFS4_SHARE_WANT_MASK) > NFS4_SHARE_WANT_CANCEL)
-			return 0;
-		if ((x & NFS4_SHARE_WHEN_MASK) > NFS4_SHARE_PUSH_DELEG_WHEN_UNCONTENDED)
-			return 0;
-		x &= ~(NFS4_SHARE_WANT_MASK | NFS4_SHARE_WHEN_MASK);
-	}
-	if (x)
-		return 0;
-	return 1;
-}
-
-static inline int deny_valid(u32 x)
-{
-	/* Note: unlike access bits, deny bits may be zero. */
-	return x <= NFS4_SHARE_DENY_BOTH;
-}
-
 /*
  * Called to check deny when READ with all zero stateid or
  * WRITE with all zero or all one stateid
@@ -2918,10 +2893,6 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	struct nfs4_delegation *dp = NULL;
 	__be32 status;
 
-	status = nfserr_inval;
-	if (!access_valid(open->op_share_access, resp->cstate.minorversion)
-			|| !deny_valid(open->op_share_deny))
-		goto out;
 	/*
 	 * Lookup file; if found, lookup stateid and check open request,
 	 * and check for delegations in the process of being recalled.
@@ -3571,9 +3542,6 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 			(int)cstate->current_fh.fh_dentry->d_name.len,
 			cstate->current_fh.fh_dentry->d_name.name);
 
-	if (!access_valid(od->od_share_access, cstate->minorversion)
-			|| !deny_valid(od->od_share_deny))
-		return nfserr_inval;
 	/* We don't yet support WANT bits: */
 	od->od_share_access &= NFS4_SHARE_ACCESS_MASK;
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 5779acd..94da8bb 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -639,6 +639,64 @@ nfsd4_decode_lookup(struct nfsd4_compoundargs *argp, struct nfsd4_lookup *lookup
 	DECODE_TAIL;
 }
 
+static __be32 nfsd4_decode_share_access(struct nfsd4_compoundargs *argp, u32 *x)
+{
+	__be32 *p;
+	u32 w;
+
+	READ_BUF(4);
+	READ32(w);
+	*x = w;
+	switch (w & NFS4_SHARE_ACCESS_MASK) {
+	case NFS4_SHARE_ACCESS_READ:
+	case NFS4_SHARE_ACCESS_WRITE:
+	case NFS4_SHARE_ACCESS_BOTH:
+		break;
+	default:
+		return nfserr_bad_xdr;
+	}
+	w &= !NFS4_SHARE_ACCESS_MASK;
+	if (!w)
+		return nfs_ok;
+	if (!argp->minorversion)
+		return nfserr_bad_xdr;
+	switch (w & NFS4_SHARE_WANT_MASK) {
+	case NFS4_SHARE_WANT_NO_PREFERENCE:
+	case NFS4_SHARE_WANT_READ_DELEG:
+	case NFS4_SHARE_WANT_WRITE_DELEG:
+	case NFS4_SHARE_WANT_ANY_DELEG:
+	case NFS4_SHARE_WANT_NO_DELEG:
+	case NFS4_SHARE_WANT_CANCEL:
+		break;
+	default:
+		return nfserr_bad_xdr;
+	}
+	w &= !NFS4_SHARE_WANT_MASK;
+	if (!w)
+		return nfs_ok;
+	switch (w) {
+	case NFS4_SHARE_SIGNAL_DELEG_WHEN_RESRC_AVAIL:
+	case NFS4_SHARE_PUSH_DELEG_WHEN_UNCONTENDED:
+		return nfs_ok;
+	}
+xdr_error:
+	return nfserr_bad_xdr;
+}
+
+static __be32 nfsd4_decode_share_deny(struct nfsd4_compoundargs *argp, u32 *x)
+{
+	__be32 *p;
+
+	READ_BUF(4);
+	READ32(*x);
+	/* Note: unlinke access bits, deny bits may be zero. */
+	if (*x & !NFS4_SHARE_DENY_BOTH)
+		return nfserr_bad_xdr;
+	return nfs_ok;
+xdr_error:
+	return nfserr_bad_xdr;
+}
+
 static __be32
 nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
 {
@@ -649,10 +707,15 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
 	open->op_openowner = NULL;
 
 	/* seqid, share_access, share_deny, clientid, ownerlen */
-	READ_BUF(16 + sizeof(clientid_t));
+	READ_BUF(4);
 	READ32(open->op_seqid);
-	READ32(open->op_share_access);
-	READ32(open->op_share_deny);
+	status = nfsd4_decode_share_access(argp, &open->op_share_access);
+	if (status)
+		goto xdr_error;
+	status = nfsd4_decode_share_deny(argp, &open->op_share_deny);
+	if (status)
+		goto xdr_error;
+	READ_BUF(sizeof(clientid_t) + 4);
 	COPYMEM(&open->op_clientid, sizeof(clientid_t));
 	READ32(open->op_owner.len);
 
@@ -753,11 +816,14 @@ nfsd4_decode_open_downgrade(struct nfsd4_compoundargs *argp, struct nfsd4_open_d
 	status = nfsd4_decode_stateid(argp, &open_down->od_stateid);
 	if (status)
 		return status;
-	READ_BUF(12);
+	READ_BUF(4);
 	READ32(open_down->od_seqid);
-	READ32(open_down->od_share_access);
-	READ32(open_down->od_share_deny);
-						        
+	status = nfsd4_decode_share_access(argp, &open_down->od_share_access);
+	if (status)
+		return status;
+	status = nfsd4_decode_share_deny(argp, &open_down->od_share_deny);
+	if (status)
+		return status;
 	DECODE_TAIL;
 }
 
-- 
1.7.4.1

