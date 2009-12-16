From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 09/11] nfsd: get a reference count on the delgation while outside of the deleg_lock
Date: Wed, 16 Dec 2009 19:42:16 +0200
Message-ID: <1260985336-21666-1-git-send-email-bhalevy@panasas.com>
References: <4B291B4C.3060603@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:60323 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762632AbZLPRmT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2009 12:42:19 -0500
In-Reply-To: <4B291B4C.3060603@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ae49d1e..411226a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2228,8 +2228,10 @@ find_delegation_file(struct nfs4_file *fp, stateid_t *stid)
 
 	spin_lock(&deleg_lock);
 	list_for_each_entry(dp, &fp->fi_delegations, dl_perfile) {
-		if (dp->dl_stateid.si_stateownerid == stid->si_stateownerid)
+		if (dp->dl_stateid.si_stateownerid == stid->si_stateownerid) {
+			atomic_inc(&dp->dl_count);
 			break;
+		}
 	}
 	spin_unlock(&deleg_lock);
 	return dp;
@@ -2533,6 +2535,8 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	dprintk("%s: stateid=" STATEID_FMT "\n", __func__,
 		STATEID_VAL(&stp->st_stateid));
 out:
+	if (dp)
+		nfs4_put_delegation(dp);
 	if (fp)
 		put_nfs4_file(fp);
 	if (status == 0 && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
@@ -2891,6 +2895,8 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 	}
 	status = nfs_ok;
 out:
+	if (dp)
+		nfs4_put_delegation(dp);
 	return status;
 }
 
-- 
1.6.5.1

