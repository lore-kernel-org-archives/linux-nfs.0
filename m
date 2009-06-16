From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 24/44] nfsd41: encode replay sequence from the slot values
Date: Tue, 16 Jun 2009 04:20:21 +0300
Message-ID: <1245115221-7592-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2632
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756571AbZFPBUV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:20:21 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The sequence operation is not cached; always encode the sequence operation on
a replay from the slot table and session values.

If this is a replay of a compound that was specified not to be cached, return
NFS4ERR_RETRY_UNCACHED_REP.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c  |   33 +--------------------------------
 fs/nfsd/nfs4state.c |   40 ++++++++++++++++++++++++++++++++++++----
 2 files changed, 37 insertions(+), 36 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 59a7194..2c72bad 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -860,34 +860,6 @@ static struct nfsd4_operation nfsd4_ops[];
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
-	dprintk("--> %s resp->opcnt %d cachethis %u \n", __func__,
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
@@ -999,10 +971,7 @@ encode_op:
 		/* Only from SEQUENCE */
 		if (resp->cstate.status == nfserr_replay_cache) {
 			dprintk("%s NFS4.1 replay from cache\n", __func__);
-			if (nfsd4_not_cached(resp))
-				status = nfsd4_enc_sequence_replay(args, resp);
-			else
-				status = op->status;
+			status = op->status;
 			goto out;
 		} else if (op->status == nfserr_replay_me) {
 			op->replay = &cstate->replay_owner->so_replay;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c1fa96c..439cf80 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1037,6 +1037,36 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
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
@@ -1059,10 +1089,12 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
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
1.6.3

