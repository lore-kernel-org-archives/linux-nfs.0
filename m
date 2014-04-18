Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f172.google.com ([209.85.213.172]:34930 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753952AbaDRSp1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:27 -0400
Received: by mail-ig0-f172.google.com with SMTP id hn18so949098igb.5
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:25 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 13/70] NFSd: Clean up nfs4_preprocess_stateid_op
Date: Fri, 18 Apr 2014 14:44:07 -0400
Message-Id: <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the state locking and file descriptor reference out from the
callers and into nfs4_preprocess_stateid_op() itself.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4proc.c  | 11 -----------
 fs/nfsd/nfs4state.c | 19 +++++++++++++------
 2 files changed, 13 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 8eabbfb25441..480323443efe 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -786,7 +786,6 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (!nfsd4_last_compound_op(rqstp))
 		rqstp->rq_splice_ok = false;
 
-	nfs4_lock_state();
 	/* check stateid */
 	if ((status = nfs4_preprocess_stateid_op(SVC_NET(rqstp),
 						 cstate, &read->rd_stateid,
@@ -794,11 +793,8 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		dprintk("NFSD: nfsd4_read: couldn't process stateid!\n");
 		goto out;
 	}
-	if (read->rd_filp)
-		get_file(read->rd_filp);
 	status = nfs_ok;
 out:
-	nfs4_unlock_state();
 	read->rd_rqstp = rqstp;
 	read->rd_fhp = &cstate->current_fh;
 	return status;
@@ -937,10 +933,8 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	int err;
 
 	if (setattr->sa_iattr.ia_valid & ATTR_SIZE) {
-		nfs4_lock_state();
 		status = nfs4_preprocess_stateid_op(SVC_NET(rqstp), cstate,
 			&setattr->sa_stateid, WR_STATE, NULL);
-		nfs4_unlock_state();
 		if (status) {
 			dprintk("NFSD: nfsd4_setattr: couldn't process stateid!\n");
 			return status;
@@ -1006,17 +1000,12 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (write->wr_offset >= OFFSET_MAX)
 		return nfserr_inval;
 
-	nfs4_lock_state();
 	status = nfs4_preprocess_stateid_op(SVC_NET(rqstp),
 					cstate, stateid, WR_STATE, &filp);
 	if (status) {
-		nfs4_unlock_state();
 		dprintk("NFSD: nfsd4_write: couldn't process stateid!\n");
 		return status;
 	}
-	if (filp)
-		get_file(filp);
-	nfs4_unlock_state();
 
 	cnt = write->wr_buflen;
 	write->wr_how_written = write->wr_stable_how;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f77cc9206373..6827e8698767 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3699,6 +3699,7 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 	struct svc_fh *current_fh = &cstate->current_fh;
 	struct inode *ino = current_fh->fh_dentry->d_inode;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	struct file *file = NULL;
 	__be32 status;
 
 	if (filpp)
@@ -3710,10 +3711,12 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
 		return check_special_stateids(net, current_fh, stateid, flags);
 
+	nfs4_lock_state();
+
 	status = nfsd4_lookup_stateid(stateid, NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID,
 				      &s, cstate->minorversion, nn);
 	if (status)
-		return status;
+		goto out;
 	status = check_stateid_generation(stateid, &s->sc_stateid, nfsd4_has_session(cstate));
 	if (status)
 		goto out;
@@ -3724,8 +3727,8 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 		if (status)
 			goto out;
 		if (filpp) {
-			*filpp = dp->dl_file->fi_deleg_file;
-			if (!*filpp) {
+			file = dp->dl_file->fi_deleg_file;
+			if (!file) {
 				WARN_ON_ONCE(1);
 				status = nfserr_serverfault;
 				goto out;
@@ -3746,16 +3749,20 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 			goto out;
 		if (filpp) {
 			if (flags & RD_STATE)
-				*filpp = find_readable_file(stp->st_file);
+				file = find_readable_file(stp->st_file);
 			else
-				*filpp = find_writeable_file(stp->st_file);
+				file = find_writeable_file(stp->st_file);
 		}
 		break;
 	default:
-		return nfserr_bad_stateid;
+		status = nfserr_bad_stateid;
+		goto out;
 	}
 	status = nfs_ok;
+	if (file)
+		*filpp = get_file(file);
 out:
+	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.9.0

