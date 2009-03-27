From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 30/47] nfsd41: clientid handling
Date: Fri, 27 Mar 2009 06:17:41 +0300
Message-ID: <1238123861-7870-1-git-send-email-bhalevy@panasas.com>
References: <49CC40E5.2080506@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:17661 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756061AbZC0DRq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 23:17:46 -0400
In-Reply-To: <49CC40E5.2080506@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Extract the clientid from sessionid to set the op_clientid on open.
Verify that the clid for other stateful ops is zero for minorversion != 0
Do all other checks for stateful ops without sessions.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
[fixed whitespace indent]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c  |   12 ++++++++++++
 fs/nfsd/nfs4state.c |   14 ++++++++------
 fs/nfsd/nfs4xdr.c   |    9 +++++++++
 3 files changed, 29 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 1d4b2b5..0076bb1 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -162,6 +162,15 @@ do_open_fhandle(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_
 	return status;
 }
 
+static void
+copy_clientid(clientid_t *clid, struct nfsd4_session *session)
+{
+	struct nfsd4_sessionid *sid =
+			(struct nfsd4_sessionid *)session->se_sessionid.data;
+
+	clid->cl_boot = sid->clientid.cl_boot;
+	clid->cl_id = sid->clientid.cl_id;
+}
 
 static __be32
 nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
@@ -176,6 +185,9 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (open->op_create && open->op_claim_type != NFS4_OPEN_CLAIM_NULL)
 		return nfserr_inval;
 
+	if (nfsd4_has_session(cstate))
+		copy_clientid(&open->op_clientid, cstate->slot->sl_session);
+
 	nfs4_lock_state();
 
 	/* check seqid for replay. set nfs4_owner */
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index bf5b214..00ad1c2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -616,8 +616,8 @@ STALE_CLIENTID(clientid_t *clid)
 {
 	if (clid->cl_boot == boot_time)
 		return 0;
-	dprintk("NFSD stale clientid (%08x/%08x)\n", 
-			clid->cl_boot, clid->cl_id);
+	dprintk("NFSD stale clientid (%08x/%08x) boot_time %08lx\n",
+		clid->cl_boot, clid->cl_id, boot_time);
 	return 1;
 }
 
@@ -2968,8 +2968,9 @@ nfs4_preprocess_seqid_op(struct svc_fh *current_fh, u32 seqid, stateid_t *statei
 		if (lock->lk_is_new) {
 			if (!sop->so_is_open_owner)
 				return nfserr_bad_stateid;
-			if (!same_clid(&clp->cl_clientid, lockclid))
-			       return nfserr_bad_stateid;
+			if (!(flags & HAS_SESSION) &&
+			    !same_clid(&clp->cl_clientid, lockclid))
+				return nfserr_bad_stateid;
 			/* stp is the open stateid */
 			status = nfs4_check_openmode(stp, lkflg);
 			if (status)
@@ -3516,7 +3517,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		struct nfs4_file *fp;
 		
 		status = nfserr_stale_clientid;
-		if (STALE_CLIENTID(&lock->lk_new_clientid))
+		if (!nfsd4_has_session(cstate) &&
+		    STALE_CLIENTID(&lock->lk_new_clientid))
 			goto out;
 
 		flags = OPEN_STATE;
@@ -3678,7 +3680,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfs4_lock_state();
 
 	status = nfserr_stale_clientid;
-	if (STALE_CLIENTID(&lockt->lt_clientid))
+	if (!nfsd4_has_session(cstate) && STALE_CLIENTID(&lockt->lt_clientid))
 		goto out;
 
 	if ((status = fh_verify(rqstp, &cstate->current_fh, S_IFREG, 0))) {
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 52ca833..a1af3a3 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -189,6 +189,11 @@ static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
 	return p;
 }
 
+static int zero_clientid(clientid_t *clid)
+{
+	return (clid->cl_boot == 0) && (clid->cl_id == 0);
+}
+
 static int
 defer_free(struct nfsd4_compoundargs *argp,
 		void (*release)(const void *), void *p)
@@ -584,6 +589,8 @@ nfsd4_decode_lockt(struct nfsd4_compoundargs *argp, struct nfsd4_lockt *lockt)
 	READ_BUF(lockt->lt_owner.len);
 	READMEM(lockt->lt_owner.data, lockt->lt_owner.len);
 
+	if (argp->minorversion && !zero_clientid(&lockt->lt_clientid))
+		return nfserr_inval;
 	DECODE_TAIL;
 }
 
@@ -994,6 +1001,8 @@ nfsd4_decode_release_lockowner(struct nfsd4_compoundargs *argp, struct nfsd4_rel
 	READ_BUF(rlockowner->rl_owner.len);
 	READMEM(rlockowner->rl_owner.data, rlockowner->rl_owner.len);
 
+	if (argp->minorversion && !zero_clientid(&rlockowner->rl_clientid))
+		return nfserr_inval;
 	DECODE_TAIL;
 }
 
-- 
1.6.2.1

