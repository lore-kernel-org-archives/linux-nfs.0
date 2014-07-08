Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:41578 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755433AbaGHSGh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:06:37 -0400
Received: by mail-qc0-f181.google.com with SMTP id x13so5689239qcv.12
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:06:36 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 090/100] nfsd: Remove nfs4_lock_state(): nfsd4_lock/locku/lockt()
Date: Tue,  8 Jul 2014 14:04:18 -0400
Message-Id: <1404842668-22521-91-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4445925c4c13..7f184503b42e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5193,8 +5193,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return status;
 	}
 
-	nfs4_lock_state();
-
 	if (lock->lk_is_new) {
 		if (nfsd4_has_session(cstate))
 			/* See rfc 5661 18.10.3: given clientid is ignored: */
@@ -5337,7 +5335,6 @@ out:
 	if (open_stp)
 		put_generic_stateid(open_stp);
 	nfsd4_bump_seqid(cstate, status);
-	nfs4_unlock_state();
 	if (file_lock)
 		locks_free_lock(file_lock);
 	if (conflock)
@@ -5380,8 +5377,6 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (check_lock_length(lockt->lt_offset, lockt->lt_length))
 		 return nfserr_inval;
 
-	nfs4_lock_state();
-
 	if (!nfsd4_has_session(cstate)) {
 		status = lookup_clientid(&lockt->lt_clientid, cstate, nn);
 		if (status)
@@ -5436,7 +5431,6 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 out:
 	if (lo)
 		nfs4_put_stateowner(&lo->lo_owner);
-	nfs4_unlock_state();
 	if (file_lock)
 		locks_free_lock(file_lock);
 	return status;
@@ -5460,8 +5454,6 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (check_lock_length(locku->lu_offset, locku->lu_length))
 		 return nfserr_inval;
 
-	nfs4_lock_state();
-									        
 	status = nfs4_preprocess_seqid_op(cstate, locku->lu_seqid,
 					&locku->lu_stateid, NFS4_LOCK_STID,
 					&stp, nn);
@@ -5504,7 +5496,6 @@ put_stateid:
 	put_generic_stateid(stp);
 out:
 	nfsd4_bump_seqid(cstate, status);
-	nfs4_unlock_state();
 	if (file_lock)
 		locks_free_lock(file_lock);
 	return status;
-- 
1.9.3

