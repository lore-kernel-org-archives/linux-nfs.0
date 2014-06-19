Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:64110 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757877AbaFSOvH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:51:07 -0400
Received: by mail-qg0-f50.google.com with SMTP id j5so2181826qga.37
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:51:06 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 006/104] NFSd: Add a mutex to protect the NFSv4.0 open owner replay cache
Date: Thu, 19 Jun 2014 10:49:12 -0400
Message-Id: <1403189450-18729-7-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

We don't want to rely on the state_lock() for protection in the
case of NFSv4 open owners. Instead, we add a mutex that will
only be taken for NFSv4.0 state mutating operations, and
that will be released once the entire compound is done.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4proc.c  | 13 +++++--------
 fs/nfsd/nfs4state.c | 21 ++++++++-------------
 fs/nfsd/nfs4xdr.c   |  2 --
 fs/nfsd/state.h     |  1 +
 fs/nfsd/xdr4.h      | 19 +++++++++++++++++++
 5 files changed, 33 insertions(+), 23 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 8904c9cbcb89..df5fcae17591 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -469,11 +469,11 @@ out:
 		kfree(resfh);
 	}
 	nfsd4_cleanup_open_state(open, status);
-	if (open->op_openowner && !nfsd4_has_session(cstate))
-		cstate->replay_owner = &open->op_openowner->oo_owner;
+	if (open->op_openowner)
+		nfsd4_cstate_assign_replay(cstate,
+				&open->op_openowner->oo_owner);
 	nfsd4_bump_seqid(cstate, status);
-	if (!cstate->replay_owner)
-		nfs4_unlock_state();
+	nfs4_unlock_state();
 	return status;
 }
 
@@ -1404,10 +1404,7 @@ encode_op:
 			args->ops, args->opcnt, resp->opcnt, op->opnum,
 			be32_to_cpu(status));
 
-		if (cstate->replay_owner) {
-			nfs4_unlock_state();
-			cstate->replay_owner = NULL;
-		}
+		nfsd4_cstate_clear_replay(cstate);
 		/* XXX Ugh, we need to get rid of this kind of special case: */
 		if (op->opnum == OP_READ && op->u.read.rd_filp)
 			fput(op->u.read.rd_filp);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d1b975b29334..1daab96804a4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -781,7 +781,7 @@ void nfsd4_bump_seqid(struct nfsd4_compound_state *cstate, __be32 nfserr)
 		return;
 
 	if (!seqid_mutating_err(ntohl(nfserr))) {
-		cstate->replay_owner = NULL;
+		nfsd4_cstate_clear_replay(cstate);
 		return;
 	}
 	if (!so)
@@ -2622,6 +2622,7 @@ static void init_nfs4_replay(struct nfs4_replay *rp)
 	rp->rp_status = nfserr_serverfault;
 	rp->rp_buflen = 0;
 	rp->rp_buf = rp->rp_ibuf;
+	mutex_init(&rp->rp_mutex);
 }
 
 static inline void *alloc_stateowner(struct kmem_cache *slab, struct xdr_netobj *owner, struct nfs4_client *clp)
@@ -3923,8 +3924,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 	if (status)
 		return status;
 	stp = openlockstateid(s);
-	if (!nfsd4_has_session(cstate))
-		cstate->replay_owner = stp->st_stateowner;
+	nfsd4_cstate_assign_replay(cstate, stp->st_stateowner);
 
 	status = nfs4_seqid_op_checks(cstate, stateid, seqid, stp);
 	if (!status)
@@ -3985,8 +3985,7 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = nfs_ok;
 out:
 	nfsd4_bump_seqid(cstate, status);
-	if (!cstate->replay_owner)
-		nfs4_unlock_state();
+	nfs4_unlock_state();
 	return status;
 }
 
@@ -4068,8 +4067,7 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 	status = nfs_ok;
 out:
 	nfsd4_bump_seqid(cstate, status);
-	if (!cstate->replay_owner)
-		nfs4_unlock_state();
+	nfs4_unlock_state();
 	return status;
 }
 
@@ -4126,8 +4124,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		}
 	}
 out:
-	if (!cstate->replay_owner)
-		nfs4_unlock_state();
+	nfs4_unlock_state();
 	return status;
 }
 
@@ -4539,8 +4536,7 @@ out:
 	if (status && new_state)
 		release_lockowner(lock_sop);
 	nfsd4_bump_seqid(cstate, status);
-	if (!cstate->replay_owner)
-		nfs4_unlock_state();
+	nfs4_unlock_state();
 	if (file_lock)
 		locks_free_lock(file_lock);
 	if (conflock)
@@ -4703,8 +4699,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 out:
 	nfsd4_bump_seqid(cstate, status);
-	if (!cstate->replay_owner)
-		nfs4_unlock_state();
+	nfs4_unlock_state();
 	if (file_lock)
 		locks_free_lock(file_lock);
 	return status;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2d305a121f37..bd0ebd7ff043 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3923,8 +3923,6 @@ status:
  * 
  * XDR note: do not encode rp->rp_buflen: the buffer contains the
  * previously sent already encoded operation.
- *
- * called with nfs4_lock_state() held
  */
 void
 nfsd4_encode_replay(struct xdr_stream *xdr, struct nfsd4_op *op)
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 366887ab5204..26234b106182 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -329,6 +329,7 @@ struct nfs4_replay {
 	unsigned int		rp_buflen;
 	char			*rp_buf;
 	struct knfsd_fh		rp_openfh;
+	struct mutex		rp_mutex;
 	char			rp_ibuf[NFSD4_REPLAY_ISIZE];
 };
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 18cbb6d9c8a9..b577273224e7 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -73,6 +73,25 @@ static inline bool nfsd4_has_session(struct nfsd4_compound_state *cs)
 	return cs->slot != NULL;
 }
 
+static inline void nfsd4_cstate_assign_replay(struct nfsd4_compound_state *cstate,
+		struct nfs4_stateowner *so)
+{
+	if (!nfsd4_has_session(cstate)) {
+		mutex_lock(&so->so_replay.rp_mutex);
+		cstate->replay_owner = so;
+	}
+}
+
+static inline void nfsd4_cstate_clear_replay(struct nfsd4_compound_state *cstate)
+{
+	struct nfs4_stateowner *so = cstate->replay_owner;
+
+	if (so != NULL) {
+		cstate->replay_owner = NULL;
+		mutex_unlock(&so->so_replay.rp_mutex);
+	}
+}
+
 struct nfsd4_change_info {
 	u32		atomic;
 	bool		change_supported;
-- 
1.9.3

