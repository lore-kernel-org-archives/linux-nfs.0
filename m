Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60179 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932244Ab1INLp2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:28 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 16/25] nfsd4: pass around typemask instead of flags
Date: Wed, 14 Sep 2011 07:45:12 -0400
Message-Id: <1316000721-3289-17-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We're only using those flags to choose lock or open stateid's at this
point.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   18 ++++++++----------
 fs/nfsd/state.h     |    2 --
 2 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ad20bbf..4813463 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1080,16 +1080,14 @@ static struct nfs4_stateid *find_stateid(stateid_t *t)
 	return NULL;
 }
 
-static struct nfs4_stateid *find_stateid_by_type(stateid_t *t, int flags)
+static struct nfs4_stateid *find_stateid_by_type(stateid_t *t, char typemask)
 {
 	struct nfs4_stateid *s;
 
 	s = find_stateid(t);
 	if (!s)
 		return NULL;
-	if (flags & LOCK_STATE && s->st_type == NFS4_LOCK_STID)
-		return s;
-	if (flags & OPEN_STATE && s->st_type == NFS4_OPEN_STID)
+	if (typemask & s->st_type)
 		return s;
 	return NULL;
 }
@@ -3445,7 +3443,7 @@ static __be32 nfs4_seqid_op_checks(struct nfsd4_compound_state *cstate, stateid_
  */
 static __be32
 nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
-			 stateid_t *stateid, int flags,
+			 stateid_t *stateid, char typemask,
 			 struct nfs4_stateid **stpp)
 {
 	__be32 status;
@@ -3457,7 +3455,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 	status = nfs4_nospecial_stateid_checks(stateid);
 	if (status)
 		return status;
-	*stpp = find_stateid_by_type(stateid, flags);
+	*stpp = find_stateid_by_type(stateid, typemask);
 	if (*stpp == NULL)
 		return nfserr_expired;
 	cstate->replay_owner = (*stpp)->st_stateowner;
@@ -3472,7 +3470,7 @@ static __be32 nfs4_preprocess_confirmed_seqid_op(struct nfsd4_compound_state *cs
 	struct nfs4_openowner *oo;
 
 	status = nfs4_preprocess_seqid_op(cstate, seqid, stateid,
-						OPEN_STATE, stpp);
+						NFS4_OPEN_STID, stpp);
 	if (status)
 		return status;
 	oo = openowner((*stpp)->st_stateowner);
@@ -3501,7 +3499,7 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	status = nfs4_preprocess_seqid_op(cstate,
 					oc->oc_seqid, &oc->oc_req_stateid,
-					OPEN_STATE, &stp);
+					NFS4_OPEN_STID, &stp);
 	if (status)
 		goto out;
 	oo = openowner(stp->st_stateowner);
@@ -3999,7 +3997,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfs4_preprocess_seqid_op(cstate,
 				       lock->lk_old_lock_seqid,
 				       &lock->lk_old_lock_stateid,
-				       LOCK_STATE, &lock_stp);
+				       NFS4_LOCK_STID, &lock_stp);
 		if (status)
 			goto out;
 		lock_sop = lockowner(lock_stp->st_stateowner);
@@ -4197,7 +4195,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfs4_lock_state();
 									        
 	status = nfs4_preprocess_seqid_op(cstate, locku->lu_seqid,
-					&locku->lu_stateid, LOCK_STATE, &stp);
+					&locku->lu_stateid, NFS4_LOCK_STID, &stp);
 	if (status)
 		goto out;
 	filp = find_any_file(stp->st_file);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 9745cc7..ef949eb 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -463,8 +463,6 @@ struct nfs4_stateid {
 };
 
 /* flags for preprocess_seqid_op() */
-#define OPEN_STATE              0x00000004
-#define LOCK_STATE              0x00000008
 #define RD_STATE	        0x00000010
 #define WR_STATE	        0x00000020
 
-- 
1.7.4.1

