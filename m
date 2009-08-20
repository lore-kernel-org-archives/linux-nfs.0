From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] nfsd41: renew_client must be called under the state lock
Date: Thu, 20 Aug 2009 03:21:56 +0300
Message-ID: <1250727716-28107-1-git-send-email-bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-67.z220-152-67.customer.algx.net ([67.152.220.67]:15755
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753609AbZHTAsb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Aug 2009 20:48:31 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd4_sequence() should not renew the client state if the session was not
found or if there was a bad slot.  This will also avoid dereferencing a
null session pointer.

FIXME: until we work out the state locking so we can use a
spin lock to protect the cl_lru we need to take the state_lock
to renew the client.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41: Do not renew state on error]
Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---

Bruce, I'm not whether it is too late but this patch fixes
a bug in 2.6.31-rc that we've hit in the last Bakeathon.

Benny

 fs/nfsd/nfs4state.c |   30 +++++++++++++++++++-----------
 1 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1dedde9..3e7b20a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1436,12 +1436,16 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	spin_lock(&sessionid_lock);
 	status = nfserr_badsession;
 	session = find_in_sessionid_hashtbl(&seq->sessionid);
-	if (!session)
-		goto out;
+	if (!session) {
+		spin_unlock(&sessionid_lock);
+		goto err;
+	}
 
 	status = nfserr_badslot;
-	if (seq->slotid >= session->se_fchannel.maxreqs)
-		goto out;
+	if (seq->slotid >= session->se_fchannel.maxreqs) {
+		spin_unlock(&sessionid_lock);
+		goto err;
+	}
 
 	slot = &session->se_slots[seq->slotid];
 	dprintk("%s: slotid %d\n", __func__, seq->slotid);
@@ -1454,10 +1458,12 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 		 * for nfsd4_proc_compound processing */
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
@@ -1470,15 +1476,17 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	cstate->slot = slot;
 	cstate->session = session;
 
-replay_cache:
-	/* Renew the clientid on success and on replay.
-	 * Hold a session reference until done processing the compound:
+	/* Hold a session reference until done processing the compound:
 	 * nfsd4_put_session called only if the cstate slot is set.
 	 */
-	renew_client(session->se_client);
 	nfsd4_get_session(session);
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
1.6.4

