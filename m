From: andros@netapp.com
Subject: [PATCH 05/30] nfsd41: replay solo and embedded create session
Date: Mon,  8 Jun 2009 14:20:46 -0400
Message-ID: <1244485271-7461-6-git-send-email-andros@netapp.com>
References: <>
 <1244485271-7461-1-git-send-email-andros@netapp.com>
 <1244485271-7461-2-git-send-email-andros@netapp.com>
 <1244485271-7461-3-git-send-email-andros@netapp.com>
 <1244485271-7461-4-git-send-email-andros@netapp.com>
 <1244485271-7461-5-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:65497 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752873AbZFHSVX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:21:23 -0400
In-Reply-To: <1244485271-7461-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

CREATE_SESSION can be preceeded by a SEQUENCE operation (an embedded
CREATE_SESSION) and the create session single slot cache must be maintained.
nfsd4_replay_cache_entry() and nfsd4_store_cache_entry() did not implement the
replay of an embedded CREATE_SESSION.

Replace the old create session struct nfs4_slot cache with the new
nfsd4_clid_slot cache which on replay replaces the current struct
nfs4_create_session with the cached version, allowing nfsd4_proc_compound
to handle both the solo and embedded CREATE_SESSION case for us via the
normal use of encode_operation.

Always replay a create session from nfsd4_replay_create_session(). Leave
nfsd4_store_cache_entry() for session (sequence operation) replays.

A following patch removes nfs4_client->cl_slot.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4proc.c  |    2 +-
 fs/nfsd/nfs4state.c |   39 +++++++++++++++++----------------------
 2 files changed, 18 insertions(+), 23 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index b2883e9..13a6c58 100644
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
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 265379e..5f2dd23 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1347,6 +1347,13 @@ nfsd4_cache_create_session(struct nfsd4_create_session *cr_ses,
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
@@ -1354,9 +1361,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		     struct nfsd4_create_session *cr_ses)
 {
 	u32 ip_addr = svc_addr_in(rqstp)->sin_addr.s_addr;
-	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfs4_client *conf, *unconf;
-	struct nfsd4_slot *slot = NULL;
 	struct nfsd4_clid_slot *cs_slot = NULL;
 	int status = 0;
 
@@ -1365,30 +1370,25 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	conf = find_confirmed_client(&cr_ses->clientid);
 
 	if (conf) {
-		slot = &conf->cl_slot;
-		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid,
-					  slot->sl_inuse);
+		cs_slot = &conf->cl_cs_slot;
+		status = check_slot_seqid(cr_ses->seqid, cs_slot->sl_seqid, 0);
 		if (status == nfserr_replay_cache) {
 			dprintk("Got a create_session replay! seqid= %d\n",
-				slot->sl_seqid);
-			cstate->slot = slot;
-			cstate->status = status;
+				cs_slot->sl_seqid);
 			/* Return the cached reply status */
-			status = nfsd4_replay_cache_entry(resp, NULL);
+			status = nfsd4_replay_create_session(cr_ses, cs_slot);
 			goto out;
-		} else if (cr_ses->seqid != conf->cl_slot.sl_seqid + 1) {
+		} else if (cr_ses->seqid != cs_slot->sl_seqid + 1) {
 			status = nfserr_seq_misordered;
 			dprintk("Sequence misordered!\n");
 			dprintk("Expected seqid= %d but got seqid= %d\n",
-				slot->sl_seqid, cr_ses->seqid);
+				cs_slot->sl_seqid, cr_ses->seqid);
 			goto out;
 		}
-		conf->cl_slot.sl_seqid++;
+		cs_slot->sl_seqid++;
 	} else if (unconf) {
-		slot = &unconf->cl_slot;
 		cs_slot = &unconf->cl_cs_slot;
-		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid,
-					  slot->sl_inuse);
+		status = check_slot_seqid(cr_ses->seqid, cs_slot->sl_seqid, 0);
 		if (status) {
 			/* an unconfirmed replay returns misordered */
 			status = nfserr_seq_misordered;
@@ -1401,7 +1401,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			goto out_cache;
 		}
 
-		slot->sl_seqid++; /* from 0 to 1 */
+		cs_slot->sl_seqid++; /* from 0 to 1 */
 		move_to_confirmed(unconf);
 
 		/*
@@ -1422,12 +1422,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 
 	memcpy(cr_ses->sessionid.data, conf->cl_sessionid.data,
 	       NFS4_MAX_SESSIONID_LEN);
-	cr_ses->seqid = slot->sl_seqid;
-
-	slot->sl_inuse = true;
-	cstate->slot = slot;
-	/* Ensure a page is used for the cache */
-	slot->sl_cache_entry.ce_cachethis = 1;
+	cr_ses->seqid = cs_slot->sl_seqid;
 
 out_cache:
 	/* cache solo and embedded create sessions under the state lock */
-- 
1.5.4.3

