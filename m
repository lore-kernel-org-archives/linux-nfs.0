From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 16/21] SQUASHME: nfsd41: pass nfsd4_compoundres * to nfsd4_process_open1
Date: Fri,  3 Apr 2009 01:38:42 +0300
Message-ID: <1238711922-22521-1-git-send-email-bhalevy@panasas.com>
References: <49D53D44.4030102@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:27025 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1764792AbZDBWit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 18:38:49 -0400
In-Reply-To: <49D53D44.4030102@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

as per review comment.

squash into "nfsd41: stateid handling"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c        |    5 ++++-
 fs/nfsd/nfs4state.c       |    6 +++---
 include/linux/nfsd/xdr4.h |    2 +-
 3 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index b0d5b10..f2716e0 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -192,6 +192,8 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	   struct nfsd4_open *open)
 {
 	__be32 status;
+	struct nfsd4_compoundres *resp;
+
 	dprintk("NFSD: nfsd4_open filename %.*s op_stateowner %p\n",
 		(int)open->op_fname.len, open->op_fname.data,
 		open->op_stateowner);
@@ -206,7 +208,8 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfs4_lock_state();
 
 	/* check seqid for replay. set nfs4_owner */
-	status = nfsd4_process_open1(rqstp, open);
+	resp = rqstp->rq_resp;
+	status = nfsd4_process_open1(&resp->cstate, open);
 	if (status == nfserr_replay_me) {
 		struct nfs4_replay *rp = &open->op_stateowner->so_replay;
 		fh_put(&cstate->current_fh);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b04f1fa..4d9631c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2228,13 +2228,13 @@ static struct lock_manager_operations nfsd_lease_mng_ops = {
 
 
 __be32
-nfsd4_process_open1(struct svc_rqst *rqstp, struct nfsd4_open *open)
+nfsd4_process_open1(struct nfsd4_compound_state *cstate,
+		    struct nfsd4_open *open)
 {
 	clientid_t *clientid = &open->op_clientid;
 	struct nfs4_client *clp = NULL;
 	unsigned int strhashval;
 	struct nfs4_stateowner *sop = NULL;
-	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 
 	if (!check_name(open->op_owner))
 		return nfserr_inval;
@@ -2253,7 +2253,7 @@ nfsd4_process_open1(struct svc_rqst *rqstp, struct nfsd4_open *open)
 		goto renew;
 	}
 	/* When sessions are used, skip open sequenceid processing */
-	if (nfsd4_has_session(&resp->cstate))
+	if (nfsd4_has_session(cstate))
 		goto renew;
 	if (!sop->so_confirmed) {
 		/* Replace unconfirmed owners without checking for replay. */
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 6a340b6..24d62c1 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -543,7 +543,7 @@ extern __be32 nfsd4_destroy_session(struct svc_rqst *,
 		struct nfsd4_compound_state *,
 		struct nfsd4_destroy_session *);
 #endif /* CONFIG_NFSD_V4_1 */
-extern __be32 nfsd4_process_open1(struct svc_rqst *rqstp,
+extern __be32 nfsd4_process_open1(struct nfsd4_compound_state *,
 		struct nfsd4_open *open);
 extern __be32 nfsd4_process_open2(struct svc_rqst *rqstp,
 		struct svc_fh *current_fh, struct nfsd4_open *open);
-- 
1.6.2.1

