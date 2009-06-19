From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] nfsd41: renew_client must be called under the state lock
Date: Thu, 18 Jun 2009 22:01:45 -0400
Message-ID: <1245376905-3840-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Benny Halevy <bhalevy@panasas.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from linux-nfs.citi.umich.edu ([141.211.133.37]:58952 "EHLO
	linux-nfs.citi.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753147AbZFSCL4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2009 22:11:56 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

FIXME: until we work out the state locking so we can use a
spin lock to protect the cl_lru we need to take the state_lock
to renew the client.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---

Bruce, please add this patch to the nfsd41-for-2.6.31 series.
Also availble on git://linux-nfs.org/~bhalevy/linux-pnfs.git nfsd41-for-2.6.31

 fs/nfsd/nfs4state.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e21da54..c845365 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1443,10 +1443,12 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 		 * for nfsd4_svc_encode_compoundres processing */
 		status = nfsd4_replay_cache_entry(resp, seq);
 		cstate->status = nfserr_replay_cache;
-		goto replay_cache;
-	}
-	if (status)
 		goto out;
+	}
+	if (status) {
+		spin_unlock(&sessionid_lock);
+		goto err;
+	}
 
 	/* Success! bump slot seqid */
 	slot->sl_inuse = true;
@@ -1462,11 +1464,13 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	/* Hold a session reference until done caching the response */
 	nfsd4_get_session(session);
 
-replay_cache:
-	/* Renew the clientid on success and on replay */
-	renew_client(session->se_client);
 out:
 	spin_unlock(&sessionid_lock);
+	/* Renew the clientid on success and on replay */
+	nfs4_lock_state();
+	renew_client(session->se_client);
+	nfs4_unlock_state();
+err:
 	dprintk("%s: return %d\n", __func__, ntohl(status));
 	return status;
 }
-- 
1.6.3.1

