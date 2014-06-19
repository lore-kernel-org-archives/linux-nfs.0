Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:35964 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758054AbaFSOwF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:05 -0400
Received: by mail-qc0-f180.google.com with SMTP id r5so2299149qcx.11
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:04 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 046/104] NFSd: Keep a reference to the open stateid for the NFSv4.0 replay cache
Date: Thu, 19 Jun 2014 10:49:52 -0400
Message-Id: <1403189450-18729-47-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Ensure that nfsd4_cstate_assign_replay/nfsd4_cstate_clear_replay take
a reference to the stateowner when they are using it for NFSv4.0
open and lock replay caching.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4proc.c  |  5 +----
 fs/nfsd/nfs4state.c | 26 +++++++++++++++++++++++++-
 fs/nfsd/xdr4.h      | 24 ++++--------------------
 3 files changed, 30 insertions(+), 25 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index df5fcae17591..72e673781e6b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -468,10 +468,7 @@ out:
 		fh_put(resfh);
 		kfree(resfh);
 	}
-	nfsd4_cleanup_open_state(open, status);
-	if (open->op_openowner)
-		nfsd4_cstate_assign_replay(cstate,
-				&open->op_openowner->oo_owner);
+	nfsd4_cleanup_open_state(cstate, open, status);
 	nfsd4_bump_seqid(cstate, status);
 	nfs4_unlock_state();
 	return status;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c96a9b7071e1..8152ad620e20 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2831,6 +2831,27 @@ static void init_nfs4_replay(struct nfs4_replay *rp)
 	mutex_init(&rp->rp_mutex);
 }
 
+static void nfsd4_cstate_assign_replay(struct nfsd4_compound_state *cstate,
+		struct nfs4_stateowner *so)
+{
+	if (!nfsd4_has_session(cstate)) {
+		mutex_lock(&so->so_replay.rp_mutex);
+		cstate->replay_owner = so;
+		atomic_inc(&so->so_count);
+	}
+}
+
+void nfsd4_cstate_clear_replay(struct nfsd4_compound_state *cstate)
+{
+	struct nfs4_stateowner *so = cstate->replay_owner;
+
+	if (so != NULL) {
+		cstate->replay_owner = NULL;
+		mutex_unlock(&so->so_replay.rp_mutex);
+		nfs4_put_stateowner(so);
+	}
+}
+
 static inline void *alloc_stateowner(struct kmem_cache *slab, struct xdr_netobj *owner, struct nfs4_client *clp)
 {
 	struct nfs4_stateowner *sop;
@@ -3672,7 +3693,8 @@ out:
 	return status;
 }
 
-void nfsd4_cleanup_open_state(struct nfsd4_open *open, __be32 status)
+void nfsd4_cleanup_open_state(struct nfsd4_compound_state *cstate,
+			      struct nfsd4_open *open, __be32 status)
 {
 	if (open->op_openowner) {
 		struct nfs4_openowner *oo = open->op_openowner;
@@ -3686,6 +3708,8 @@ void nfsd4_cleanup_open_state(struct nfsd4_open *open, __be32 status)
 			} else
 				oo->oo_flags &= ~NFS4_OO_NEW;
 		}
+		if (open->op_openowner)
+			nfsd4_cstate_assign_replay(cstate, &oo->oo_owner);
 	}
 	if (open->op_file)
 		nfsd4_free_file(open->op_file);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index c9bf09bebdae..634e016f50d3 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -74,25 +74,6 @@ static inline bool nfsd4_has_session(struct nfsd4_compound_state *cs)
 	return cs->slot != NULL;
 }
 
-static inline void nfsd4_cstate_assign_replay(struct nfsd4_compound_state *cstate,
-		struct nfs4_stateowner *so)
-{
-	if (!nfsd4_has_session(cstate)) {
-		mutex_lock(&so->so_replay.rp_mutex);
-		cstate->replay_owner = so;
-	}
-}
-
-static inline void nfsd4_cstate_clear_replay(struct nfsd4_compound_state *cstate)
-{
-	struct nfs4_stateowner *so = cstate->replay_owner;
-
-	if (so != NULL) {
-		cstate->replay_owner = NULL;
-		mutex_unlock(&so->so_replay.rp_mutex);
-	}
-}
-
 struct nfsd4_change_info {
 	u32		atomic;
 	bool		change_supported;
@@ -614,7 +595,9 @@ extern __be32 nfsd4_process_open1(struct nfsd4_compound_state *,
 		struct nfsd4_open *open, struct nfsd_net *nn);
 extern __be32 nfsd4_process_open2(struct svc_rqst *rqstp,
 		struct svc_fh *current_fh, struct nfsd4_open *open);
-extern void nfsd4_cleanup_open_state(struct nfsd4_open *open, __be32 status);
+extern void nfsd4_cstate_clear_replay(struct nfsd4_compound_state *cstate);
+extern void nfsd4_cleanup_open_state(struct nfsd4_compound_state *cstate,
+		struct nfsd4_open *open, __be32 status);
 extern __be32 nfsd4_open_confirm(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *, struct nfsd4_open_confirm *oc);
 extern __be32 nfsd4_close(struct svc_rqst *rqstp,
@@ -645,6 +628,7 @@ extern __be32 nfsd4_test_stateid(struct svc_rqst *rqstp,
 extern __be32 nfsd4_free_stateid(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *, struct nfsd4_free_stateid *free_stateid);
 extern void nfsd4_bump_seqid(struct nfsd4_compound_state *, __be32 nfserr);
+
 #endif
 
 /*
-- 
1.9.3

