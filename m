Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f42.google.com ([209.85.192.42]:51308 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753118AbaG3M2X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 08:28:23 -0400
Received: by mail-qg0-f42.google.com with SMTP id j5so1296322qga.29
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 05:28:22 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 27/37] nfsd: Remove nfs4_lock_state(): nfsd4_lock/locku/lockt()
Date: Wed, 30 Jul 2014 08:27:28 -0400
Message-Id: <1406723258-8512-28-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4f04a4a776cd..de3bb633d96b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5201,8 +5201,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return status;
 	}
 
-	nfs4_lock_state();
-
 	if (lock->lk_is_new) {
 		if (nfsd4_has_session(cstate))
 			/* See rfc 5661 18.10.3: given clientid is ignored: */
@@ -5345,7 +5343,6 @@ out:
 	if (open_stp)
 		nfs4_put_stid(&open_stp->st_stid);
 	nfsd4_bump_seqid(cstate, status);
-	nfs4_unlock_state();
 	if (file_lock)
 		locks_free_lock(file_lock);
 	if (conflock)
@@ -5388,8 +5385,6 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (check_lock_length(lockt->lt_offset, lockt->lt_length))
 		 return nfserr_inval;
 
-	nfs4_lock_state();
-
 	if (!nfsd4_has_session(cstate)) {
 		status = lookup_clientid(&lockt->lt_clientid, cstate, nn);
 		if (status)
@@ -5444,7 +5439,6 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 out:
 	if (lo)
 		nfs4_put_stateowner(&lo->lo_owner);
-	nfs4_unlock_state();
 	if (file_lock)
 		locks_free_lock(file_lock);
 	return status;
@@ -5468,8 +5462,6 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (check_lock_length(locku->lu_offset, locku->lu_length))
 		 return nfserr_inval;
 
-	nfs4_lock_state();
-									        
 	status = nfs4_preprocess_seqid_op(cstate, locku->lu_seqid,
 					&locku->lu_stateid, NFS4_LOCK_STID,
 					&stp, nn);
@@ -5512,7 +5504,6 @@ put_stateid:
 	nfs4_put_stid(&stp->st_stid);
 out:
 	nfsd4_bump_seqid(cstate, status);
-	nfs4_unlock_state();
 	if (file_lock)
 		locks_free_lock(file_lock);
 	return status;
-- 
1.9.3

