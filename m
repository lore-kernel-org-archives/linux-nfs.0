From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 08/44] nfsd41: replay solo and embedded create session
Date: Tue, 16 Jun 2009 04:19:35 +0300
Message-ID: <1245115175-7063-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2347
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753815AbZFPBTf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:19:35 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

CREATE_SESSION can be preceeded by a SEQUENCE operation (an embedded
CREATE_SESSION) and the create session single slot cache must be maintained.
Always replay a create session from nfsd4_replay_create_session(). Leave
nfsd4_store_cache_entry() for session (sequence operation) replays.

Set cstate->status to a new internal error, nfserr_replay_clientid_cache, and
change the logic in nfsd4_proc_compound so that CREATE_SESSION replays replace
encode_operation.
The new internal error is needed to differentiate between an embedded
CREATE_SESSION replay and a SEQUENCE replay.

On CREATE_SESSION replay, copy the cached struct nfsd4_create_session and
return for encoding.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41: replay struct nfsd4_create_session]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c  |    5 ++---
 fs/nfsd/nfs4state.c |   10 ++++++++++
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index b2883e9..d7f5aef 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -996,7 +996,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 			BUG_ON(op->status == nfs_ok);
 
 encode_op:
-		/* Only from SEQUENCE or CREATE_SESSION */
+		/* Only from SEQUENCE */
 		if (resp->cstate.status == nfserr_replay_cache) {
 			dprintk("%s NFS4.1 replay from cache\n", __func__);
 			if (nfsd4_not_cached(resp))
@@ -1004,8 +1004,7 @@ encode_op:
 			else
 				status = op->status;
 			goto out;
-		}
-		if (op->status == nfserr_replay_me) {
+		} else if (op->status == nfserr_replay_me) {
 			op->replay = &cstate->replay_owner->so_replay;
 			nfsd4_encode_replay(resp, op);
 			status = op->status = op->replay->rp_status;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5aef525..582cd2c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1348,6 +1348,13 @@ nfsd4_cache_create_session(struct nfsd4_create_session *cr_ses,
 	memcpy(&slot->sl_cr_ses, cr_ses, sizeof(*cr_ses));
 }
 
+static __be32
+nfsd4_replay_create_session(struct nfsd4_create_session *cr_ses,
+			    struct nfsd4_clid_slot *slot)
+{
+	memcpy(cr_ses, &slot->sl_cr_ses, sizeof(*cr_ses));
+	return slot->sl_status;
+}
 
 __be32
 nfsd4_create_session(struct svc_rqst *rqstp,
@@ -1369,6 +1376,9 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		if (status == nfserr_replay_cache) {
 			dprintk("Got a create_session replay! seqid= %d\n",
 				slot->sl_seqid);
+			/* Return the cached reply status */
+			status = nfsd4_replay_create_session(cr_ses, slot);
+			goto out;
 		} else if (cr_ses->seqid != conf->cl_slot.sl_seqid + 1) {
 			status = nfserr_seq_misordered;
 			dprintk("Sequence misordered!\n");
-- 
1.6.3

