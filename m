Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34284 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752919Ab1ISNPw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Sep 2011 09:15:52 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/5] nfsd4: replace oo_confirmed by flag bit
Date: Mon, 19 Sep 2011 09:15:39 -0400
Message-Id: <1316438143-1057-1-git-send-email-bfields@redhat.com>
In-Reply-To: <20110919131415.GB32498@fieldses.org>
References: <20110919131415.GB32498@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

I want at least one more bit here.  So, let's haul out the caps lock key
and add a flags field.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c  |    4 ++--
 fs/nfsd/nfs4state.c |   24 ++++++++++++------------
 fs/nfsd/state.h     |    3 ++-
 3 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 752a367..aa769df 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -375,7 +375,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				goto out;
 			break;
 		case NFS4_OPEN_CLAIM_PREVIOUS:
-			open->op_openowner->oo_confirmed = 1;
+			open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
 			/*
 			 * The CURRENT_FH is already set to the file being
 			 * opened.  (1) set open->op_cinfo, (2) set
@@ -388,7 +388,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				goto out;
 			break;
              	case NFS4_OPEN_CLAIM_DELEGATE_PREV:
-			open->op_openowner->oo_confirmed = 1;
+			open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
 			dprintk("NFSD: unsupported OPEN claim type %d\n",
 				open->op_claim_type);
 			status = nfserr_notsupp;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e7f83bd..59b70af 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2322,7 +2322,7 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 		return NULL;
 	oo->oo_owner.so_is_open_owner = 1;
 	oo->oo_owner.so_seqid = open->op_seqid;
-	oo->oo_confirmed = 0;
+	oo->oo_flags = 0;
 	oo->oo_time = 0;
 	INIT_LIST_HEAD(&oo->oo_close_lru);
 	hash_openowner(oo, clp, strhashval);
@@ -2549,7 +2549,7 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 			return nfserr_expired;
 		goto renew;
 	}
-	if (!oo->oo_confirmed) {
+	if (!(oo->oo_flags & NFS4_OO_CONFIRMED)) {
 		/* Replace unconfirmed owners without checking for replay. */
 		clp = oo->oo_owner.so_client;
 		release_openowner(oo);
@@ -2616,7 +2616,7 @@ out:
 		return nfs_ok;
 	if (status)
 		return status;
-	open->op_openowner->oo_confirmed = 1;
+	open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
 	return nfs_ok;
 }
 
@@ -2749,7 +2749,7 @@ nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *c
 static void
 nfs4_set_claim_prev(struct nfsd4_open *open)
 {
-	open->op_openowner->oo_confirmed = 1;
+	open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
 	open->op_openowner->oo_owner.so_client->cl_firststate = 1;
 }
 
@@ -2853,7 +2853,7 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_ol_
 			 * had the chance to reclaim theirs.... */
 			if (locks_in_grace())
 				goto out;
-			if (!cb_up || !oo->oo_confirmed)
+			if (!cb_up || !(oo->oo_flags & NFS4_OO_CONFIRMED))
 				goto out;
 			if (open->op_share_access & NFS4_SHARE_ACCESS_WRITE)
 				flag = NFS4_OPEN_DELEGATE_WRITE;
@@ -2952,7 +2952,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	memcpy(&open->op_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
 	if (nfsd4_has_session(&resp->cstate))
-		open->op_openowner->oo_confirmed = 1;
+		open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
 
 	/*
 	* Attempt to hand out a delegation. No error return, because the
@@ -2973,7 +2973,7 @@ out:
 	* To finish the open response, we just need to set the rflags.
 	*/
 	open->op_rflags = NFS4_OPEN_RESULT_LOCKTYPE_POSIX;
-	if (!open->op_openowner->oo_confirmed &&
+	if (!(open->op_openowner->oo_flags & NFS4_OO_CONFIRMED) &&
 	    !nfsd4_has_session(&resp->cstate))
 		open->op_rflags |= NFS4_OPEN_RESULT_CONFIRM;
 
@@ -3264,7 +3264,7 @@ __be32 nfs4_validate_stateid(stateid_t *stateid, bool has_session)
 		return nfs_ok;
 	ols = openlockstateid(s);
 	if (ols->st_stateowner->so_is_open_owner
-	    && !openowner(ols->st_stateowner)->oo_confirmed)
+	    && !(openowner(ols->st_stateowner)->oo_flags & NFS4_OO_CONFIRMED))
 		return nfserr_bad_stateid;
 	return nfs_ok;
 }
@@ -3323,7 +3323,7 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 		if (nfs4_check_fh(current_fh, stp))
 			goto out;
 		if (stp->st_stateowner->so_is_open_owner
-		    && !openowner(stp->st_stateowner)->oo_confirmed)
+		    && !(openowner(stp->st_stateowner)->oo_flags & NFS4_OO_CONFIRMED))
 			goto out;
 		status = nfs4_check_openmode(stp, flags);
 		if (status)
@@ -3476,7 +3476,7 @@ static __be32 nfs4_preprocess_confirmed_seqid_op(struct nfsd4_compound_state *cs
 	if (status)
 		return status;
 	oo = openowner((*stpp)->st_stateowner);
-	if (!oo->oo_confirmed)
+	if (!(oo->oo_flags & NFS4_OO_CONFIRMED))
 		return nfserr_bad_stateid;
 	return nfs_ok;
 }
@@ -3506,9 +3506,9 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	oo = openowner(stp->st_stateowner);
 	status = nfserr_bad_stateid;
-	if (oo->oo_confirmed)
+	if (oo->oo_flags & NFS4_OO_CONFIRMED)
 		goto out;
-	oo->oo_confirmed = 1;
+	oo->oo_flags |= NFS4_OO_CONFIRMED;
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&oc->oc_resp_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 	dprintk("NFSD: %s: success, seqid=%d stateid=" STATEID_FMT "\n",
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 12c1424..a8324b8 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -371,7 +371,8 @@ struct nfs4_openowner {
 	struct list_head        oo_perclient;
 	struct list_head	oo_close_lru; /* tail queue */
 	time_t			oo_time; /* time of placement on so_close_lru */
-	int                     oo_confirmed; /* successful OPEN_CONFIRM? */
+#define NFS4_OO_CONFIRMED   1
+	unsigned char		oo_flags;
 };
 
 struct nfs4_lockowner {
-- 
1.7.4.1

