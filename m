From: andros@netapp.com
Subject: [PATCH 04/29] nfsd41: replay solo and embedded create session
Date: Thu, 23 Apr 2009 12:42:43 -0400
Message-ID: <1240504988-9572-5-git-send-email-andros@netapp.com>
References: <>
 <1240504988-9572-1-git-send-email-andros@netapp.com>
 <1240504988-9572-2-git-send-email-andros@netapp.com>
 <1240504988-9572-3-git-send-email-andros@netapp.com>
 <1240504988-9572-4-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51648 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753607AbZDWQnO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2009 12:43:14 -0400
In-Reply-To: <1240504988-9572-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

CREATE_SESSION can be preceeded by a SEQUENCE operation (an embedded
CREATE_SESSION) and the create session single slot cache must be maintained.
Always replay a create session from nfsd4_replay_create_session(). Leave
nfsd4_store_cache_entry() for session (sequence operation) replays.

Do not set cstate->slot, so that nfs4svc_encode_compoundres session replay
processing is not called.

Since create sesssion caching and replay all occur in nfsd4_create_session,
no need to set the slot inuse boolean.

Set cstate->status to a new internal error, nfserr_replay_clientid_cache, and
change the logic in nfsd4_proc_compound so that CREATE_SESSION replays replace
encode_operation.
The new internal error is needed to differentiate between an embedded
CREATE_SESSION replay and a SEQUENCE replay.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4proc.c        |    9 +++++++--
 fs/nfsd/nfs4state.c       |    9 ++-------
 fs/nfsd/nfs4xdr.c         |   18 ++++++++++++++++++
 include/linux/nfsd/nfsd.h |    2 ++
 include/linux/nfsd/xdr4.h |    2 ++
 5 files changed, 31 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index b2883e9..32d5866 100644
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
@@ -1005,7 +1005,12 @@ encode_op:
 				status = op->status;
 			goto out;
 		}
-		if (op->status == nfserr_replay_me) {
+		/* Only from CREATE_SESSION */
+		if (resp->cstate.status == nfserr_replay_clientid_cache) {
+			dprintk("%s NFS4.1 replay from clientid cache\n",
+				__func__);
+			status = op->status;
+		} else if (op->status == nfserr_replay_me) {
 			op->replay = &cstate->replay_owner->so_replay;
 			nfsd4_encode_replay(resp, op);
 			status = op->status = op->replay->rp_status;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 20485c5..a585a58 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1360,10 +1360,9 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		if (status == nfserr_replay_cache) {
 			dprintk("Got a create_session replay! seqid= %d\n",
 				slot->sl_seqid);
-			cstate->slot = slot;
-			cstate->status = status;
+			cstate->status = nfserr_replay_clientid_cache;
 			/* Return the cached reply status */
-			status = nfsd4_replay_cache_entry(resp, NULL);
+			status = nfsd4_replay_create_session(resp, slot);
 			goto out;
 		} else if (cr_ses->seqid != conf->cl_slot.sl_seqid + 1) {
 			status = nfserr_seq_misordered;
@@ -1420,10 +1419,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	       NFS4_MAX_SESSIONID_LEN);
 	cr_ses->seqid = slot->sl_seqid;
 
-	slot->sl_inuse = true;
-	cstate->slot = slot;
-	/* Ensure a page is used for the cache */
-	slot->sl_cache_entry.ce_cachethis = 1;
 out_cache:
 	/* cache solo and embedded create sessions under the state lock */
 	nfsd4_cache_create_session(cr_ses, slot, status);
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 6b34fac..7459900 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3065,6 +3065,24 @@ nfsd4_cache_create_session(struct nfsd4_create_session *cr_ses,
 	entry->ce_datav.iov_len = (char *)resp->p - (char *)p;
 }
 
+__be32
+nfsd4_replay_create_session(struct nfsd4_compoundres *resp,
+			    struct nfsd4_slot *slot)
+{
+	struct nfsd4_cache_entry *entry = &slot->sl_cache_entry;
+	ENCODE_HEAD;
+
+	RESERVE_SPACE(8);
+	WRITE32(OP_CREATE_SESSION);
+	*p++ = entry->ce_status; /* already in network byte order */
+	ADJUST_ARGS();
+
+	memcpy(resp->p, entry->ce_datav.iov_base, entry->ce_datav.iov_len);
+	p += XDR_QUADLEN(entry->ce_datav.iov_len);
+	ADJUST_ARGS();
+	return entry->ce_status;
+}
+
 static __be32
 nfsd4_encode_destroy_session(struct nfsd4_compoundres *resp, int nfserr,
 			     struct nfsd4_destroy_session *destroy_session)
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index 2b49d67..9cd6399 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -301,6 +301,8 @@ void		nfsd_lockd_shutdown(void);
 #define	nfserr_replay_me	cpu_to_be32(11001)
 /* nfs41 replay detected */
 #define	nfserr_replay_cache	cpu_to_be32(11002)
+/* nfs41 clientid cache replay detected */
+#define	nfserr_replay_clientid_cache	cpu_to_be32(11003)
 
 /* Check for dir entries '.' and '..' */
 #define isdotent(n, l)	(l < 3 && n[0] == '.' && (l == 1 || n[1] == '.'))
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index cc50ca0..8fd5eb1 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -519,6 +519,8 @@ extern __be32 nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 		struct nfsd4_sequence *seq);
 extern void nfsd4_cache_create_session(struct nfsd4_create_session *cr_ses,
 		struct nfsd4_slot *slot, int nfserr);
+extern __be32 nfsd4_replay_create_session(struct nfsd4_compoundres *resp,
+		struct nfsd4_slot *slot);
 extern __be32 nfsd4_exchange_id(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 struct nfsd4_exchange_id *);
-- 
1.5.4.3

