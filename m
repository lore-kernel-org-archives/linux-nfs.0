Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:36633 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753959AbaDRSp1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:27 -0400
Received: by mail-ie0-f173.google.com with SMTP id rl12so1894741iec.32
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:26 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 14/70] NFSd: Add a mutex to protect the NFSv4.0 open owner replay cache
Date: Fri, 18 Apr 2014 14:44:08 -0400
Message-Id: <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We don't want to rely on the state_lock() for protection in the
case of NFSv4 open owners. Instead, we add a mutex that will
only be taken for NFSv4.0 state mutating operations, and
that will be released once the entire compound is done.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4proc.c  | 13 +++++--------
 fs/nfsd/nfs4state.c | 21 ++++++++-------------
 fs/nfsd/state.h     |  1 +
 fs/nfsd/xdr4.h      | 19 +++++++++++++++++++
 4 files changed, 33 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 480323443efe..a23da87b384e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -470,11 +470,11 @@ out:
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
 
@@ -1400,10 +1400,7 @@ encode_op:
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
index 6827e8698767..ad7d21e06c36 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -779,7 +779,7 @@ void nfsd4_bump_seqid(struct nfsd4_compound_state *cstate, __be32 nfserr)
 		return;
 
 	if (!seqid_mutating_err(ntohl(nfserr))) {
-		cstate->replay_owner = NULL;
+		nfsd4_cstate_clear_replay(cstate);
 		return;
 	}
 	if (!so)
@@ -2601,6 +2601,7 @@ static void init_nfs4_replay(struct nfs4_replay *rp)
 	rp->rp_status = nfserr_serverfault;
 	rp->rp_buflen = 0;
 	rp->rp_buf = rp->rp_ibuf;
+	mutex_init(&rp->rp_mutex);
 }
 
 static inline void *alloc_stateowner(struct kmem_cache *slab, struct xdr_netobj *owner, struct nfs4_client *clp)
@@ -3886,8 +3887,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 	if (status)
 		return status;
 	*stpp = openlockstateid(s);
-	if (!nfsd4_has_session(cstate))
-		cstate->replay_owner = (*stpp)->st_stateowner;
+	nfsd4_cstate_assign_replay(cstate, (*stpp)->st_stateowner);
 
 	return nfs4_seqid_op_checks(cstate, stateid, seqid, *stpp);
 }
@@ -3945,8 +3945,7 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = nfs_ok;
 out:
 	nfsd4_bump_seqid(cstate, status);
-	if (!cstate->replay_owner)
-		nfs4_unlock_state();
+	nfs4_unlock_state();
 	return status;
 }
 
@@ -4028,8 +4027,7 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 	status = nfs_ok;
 out:
 	nfsd4_bump_seqid(cstate, status);
-	if (!cstate->replay_owner)
-		nfs4_unlock_state();
+	nfs4_unlock_state();
 	return status;
 }
 
@@ -4086,8 +4084,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		}
 	}
 out:
-	if (!cstate->replay_owner)
-		nfs4_unlock_state();
+	nfs4_unlock_state();
 	return status;
 }
 
@@ -4495,8 +4492,7 @@ out:
 	if (status && new_state)
 		release_lockowner(lock_sop);
 	nfsd4_bump_seqid(cstate, status);
-	if (!cstate->replay_owner)
-		nfs4_unlock_state();
+	nfs4_unlock_state();
 	if (file_lock)
 		locks_free_lock(file_lock);
 	if (conflock)
@@ -4659,8 +4655,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 out:
 	nfsd4_bump_seqid(cstate, status);
-	if (!cstate->replay_owner)
-		nfs4_unlock_state();
+	nfs4_unlock_state();
 	if (file_lock)
 		locks_free_lock(file_lock);
 	return status;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 83d9721d9644..80789aa5b5b4 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -330,6 +330,7 @@ struct nfs4_replay {
 	unsigned int		rp_buflen;
 	char			*rp_buf;
 	struct knfsd_fh		rp_openfh;
+	struct mutex		rp_mutex;
 	char			rp_ibuf[NFSD4_REPLAY_ISIZE];
 };
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 5ea7df305083..2f887c944048 100644
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
1.9.0

