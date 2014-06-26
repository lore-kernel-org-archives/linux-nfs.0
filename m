Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:38427 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbaFZTWC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:22:02 -0400
Received: by mail-qc0-f175.google.com with SMTP id i8so3533534qcq.6
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:22:01 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 107/117] nfsd: Remove nfs4_lock_state(): nfsd4_lock/locku/lockt()
Date: Thu, 26 Jun 2014 15:21:15 -0400
Message-Id: <1403810485-16497-24-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2be356341929..3d5ea785652b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5168,8 +5168,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return status;
 	}
 
-	nfs4_lock_state();
-
 	if (lock->lk_is_new) {
 		if (nfsd4_has_session(cstate))
 			/* See rfc 5661 18.10.3: given clientid is ignored: */
@@ -5312,7 +5310,6 @@ out:
 	if (open_stp)
 		put_generic_stateid(open_stp);
 	nfsd4_bump_seqid(cstate, status);
-	nfs4_unlock_state();
 	if (file_lock)
 		locks_free_lock(file_lock);
 	if (conflock)
@@ -5355,8 +5352,6 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (check_lock_length(lockt->lt_offset, lockt->lt_length))
 		 return nfserr_inval;
 
-	nfs4_lock_state();
-
 	if (!nfsd4_has_session(cstate)) {
 		status = lookup_clientid(&lockt->lt_clientid, cstate, nn);
 		if (status)
@@ -5411,7 +5406,6 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 out:
 	if (lo)
 		nfs4_put_stateowner(&lo->lo_owner);
-	nfs4_unlock_state();
 	if (file_lock)
 		locks_free_lock(file_lock);
 	return status;
@@ -5435,8 +5429,6 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (check_lock_length(locku->lu_offset, locku->lu_length))
 		 return nfserr_inval;
 
-	nfs4_lock_state();
-									        
 	status = nfs4_preprocess_seqid_op(cstate, locku->lu_seqid,
 					&locku->lu_stateid, NFS4_LOCK_STID,
 					&stp, nn);
@@ -5479,7 +5471,6 @@ put_stateid:
 	put_generic_stateid(stp);
 out:
 	nfsd4_bump_seqid(cstate, status);
-	nfs4_unlock_state();
 	if (file_lock)
 		locks_free_lock(file_lock);
 	return status;
-- 
1.9.3

