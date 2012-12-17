Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34084 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752142Ab2LQQKA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2012 11:10:00 -0500
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1TkdGR-0007ch-Pi
	for linux-nfs@vger.kernel.org; Mon, 17 Dec 2012 11:09:59 -0500
Date: Mon, 17 Dec 2012 11:09:59 -0500
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] nfsd4: disable zero-copy on non-final read ops
Message-ID: <20121217160959.GF23546@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

To ensure ordering of read data with any following operations, turn off
zero copy if the read is not the final operation in the compound.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c  |   11 +++++++++++
 fs/nfsd/nfs4state.c |    8 --------
 fs/nfsd/xdr4.h      |    8 ++++++++
 3 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index bd67f4d..2a2d9b0 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -692,6 +692,17 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (read->rd_offset >= OFFSET_MAX)
 		return nfserr_inval;
 
+	/*
+	 * If we do a zero copy read, then a client will see read data
+	 * that reflects the state of the file *after* performing the
+	 * following compound.
+	 *
+	 * To ensure proper ordering, we therefore turn off zero copy if
+	 * the client wants us to do more in this compound:
+	 */
+	if (!nfsd4_last_compound_op(rqstp))
+		rqstp->rq_splice_ok = false;
+
 	nfs4_lock_state();
 	/* check stateid */
 	if ((status = nfs4_preprocess_stateid_op(SVC_NET(rqstp),
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8e25551..8e127b3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1855,14 +1855,6 @@ out_free_session:
 	goto out;
 }
 
-static bool nfsd4_last_compound_op(struct svc_rqst *rqstp)
-{
-	struct nfsd4_compoundres *resp = rqstp->rq_resp;
-	struct nfsd4_compoundargs *argp = rqstp->rq_argp;
-
-	return argp->opcnt == resp->opcnt;
-}
-
 static __be32 nfsd4_map_bcts_dir(u32 *dir)
 {
 	switch (*dir) {
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 331f8a3..0889bfb 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -528,6 +528,14 @@ static inline bool nfsd4_not_cached(struct nfsd4_compoundres *resp)
 		|| nfsd4_is_solo_sequence(resp);
 }
 
+static inline bool nfsd4_last_compound_op(struct svc_rqst *rqstp)
+{
+	struct nfsd4_compoundres *resp = rqstp->rq_resp;
+	struct nfsd4_compoundargs *argp = rqstp->rq_argp;
+
+	return argp->opcnt == resp->opcnt;
+}
+
 #define NFS4_SVC_XDRSIZE		sizeof(struct nfsd4_compoundargs)
 
 static inline void
-- 
1.7.9.5

