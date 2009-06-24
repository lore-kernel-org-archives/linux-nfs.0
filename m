From: andros@netapp.com
Subject: [PATCH 10/14] nfsd41: encode replay sequence from the slot values
Date: Wed, 24 Jun 2009 15:37:54 -0400
Message-ID: <1245872278-18743-11-git-send-email-andros@netapp.com>
References: <>
 <1245872278-18743-1-git-send-email-andros@netapp.com>
 <1245872278-18743-2-git-send-email-andros@netapp.com>
 <1245872278-18743-3-git-send-email-andros@netapp.com>
 <1245872278-18743-4-git-send-email-andros@netapp.com>
 <1245872278-18743-5-git-send-email-andros@netapp.com>
 <1245872278-18743-6-git-send-email-andros@netapp.com>
 <1245872278-18743-7-git-send-email-andros@netapp.com>
 <1245872278-18743-8-git-send-email-andros@netapp.com>
 <1245872278-18743-9-git-send-email-andros@netapp.com>
 <1245872278-18743-10-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40120 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760811AbZFXTiF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Jun 2009 15:38:05 -0400
In-Reply-To: <1245872278-18743-10-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The sequence operation is not cached; always encode the sequence operation on
a replay from the slot table and session values. This simplifies the sessions
replay logic in nfsd4_proc_compound.

If this is a replay of a compound that was specified not to be cached, return
NFS4ERR_RETRY_UNCACHED_REP.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4proc.c  |   33 +--------------------------------
 fs/nfsd/nfs4state.c |   40 ++++++++++++++++++++++++++++++++++++----
 2 files changed, 37 insertions(+), 36 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 386deb5..87be518 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -947,34 +947,6 @@ static struct nfsd4_operation nfsd4_ops[];
 static const char *nfsd4_op_name(unsigned opnum);
 
 /*
- * This is a replay of a compound for which no cache entry pages
- * were used. Encode the sequence operation, and if cachethis is FALSE
- * encode the uncache rep error on the next operation.
- */
-static __be32
-nfsd4_enc_sequence_replay(struct nfsd4_compoundargs *args,
-			 struct nfsd4_compoundres *resp)
-{
-	struct nfsd4_op *op;
-
-	dprintk("--> %s resp->opcnt %d sl_cachethis %u \n", __func__,
-		resp->opcnt, resp->cstate.slot->sl_cachethis);
-
-	/* Encode the replayed sequence operation */
-	BUG_ON(resp->opcnt != 1);
-	op = &args->ops[resp->opcnt - 1];
-	nfsd4_encode_operation(resp, op);
-
-	/*return nfserr_retry_uncached_rep in next operation. */
-	if (resp->cstate.slot->sl_cachethis == 0) {
-		op = &args->ops[resp->opcnt++];
-		op->status = nfserr_retry_uncached_rep;
-		nfsd4_encode_operation(resp, op);
-	}
-	return op->status;
-}
-
-/*
  * Enforce NFSv4.1 COMPOUND ordering rules.
  *
  * TODO:
@@ -1086,10 +1058,7 @@ encode_op:
 		/* Only from SEQUENCE */
 		if (resp->cstate.status == nfserr_replay_cache) {
 			dprintk("%s NFS4.1 replay from cache\n", __func__);
-			if (nfsd4_not_cached(resp))
-				status = nfsd4_enc_sequence_replay(args, resp);
-			else
-				status = op->status;
+			status = op->status;
 			goto out;
 		}
 		if (op->status == nfserr_replay_me) {
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2232b7b..51a51d2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1036,6 +1036,36 @@ out_warn:
 }
 
 /*
+ * Encode the replay sequence operation from the slot values.
+ * If cachethis is FALSE encode the uncached rep error on the next
+ * operation which sets resp->p and increments resp->opcnt for
+ * nfs4svc_encode_compoundres.
+ *
+ */
+static __be32
+nfsd4_enc_sequence_replay(struct nfsd4_compoundargs *args,
+			  struct nfsd4_compoundres *resp)
+{
+	struct nfsd4_op *op;
+	struct nfsd4_slot *slot = resp->cstate.slot;
+
+	dprintk("--> %s resp->opcnt %d cachethis %u \n", __func__,
+		resp->opcnt, resp->cstate.slot->sl_cachethis);
+
+	/* Encode the replayed sequence operation */
+	op = &args->ops[resp->opcnt - 1];
+	nfsd4_encode_operation(resp, op);
+
+	/* Return nfserr_retry_uncached_rep in next operation. */
+	if (args->opcnt > 1 && slot->sl_cachethis == 0) {
+		op = &args->ops[resp->opcnt++];
+		op->status = nfserr_retry_uncached_rep;
+		nfsd4_encode_operation(resp, op);
+	}
+	return op->status;
+}
+
+/*
  * Keep the first page of the replay. Copy the NFSv4.1 data from the first
  * cached page.  Replace any futher replay pages from the cache.
  */
@@ -1058,10 +1088,12 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 	 * session inactivity timer fires and a solo sequence operation
 	 * is sent (lease renewal).
 	 */
-	if (seq && nfsd4_not_cached(resp)) {
-		seq->maxslots = resp->cstate.session->se_fchannel.maxreqs;
-		return nfs_ok;
-	}
+	seq->maxslots = resp->cstate.session->se_fchannel.maxreqs;
+
+	/* Either returns 0 or nfserr_retry_uncached */
+	status = nfsd4_enc_sequence_replay(resp->rqstp->rq_argp, resp);
+	if (status == nfserr_retry_uncached_rep)
+		return status;
 
 	/* The sequence operation has been encoded, cstate->datap set. */
 	memcpy(resp->cstate.datap, slot->sl_data, slot->sl_datalen);
-- 
1.5.4.3

