Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60982 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752929Ab3CUO4W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Mar 2013 10:56:22 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 6/9] nfsd4: fix destroy_session race
Date: Thu, 21 Mar 2013 10:56:17 -0400
Message-Id: <1363877780-28825-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1363877780-28825-1-git-send-email-bfields@redhat.com>
References: <1363877780-28825-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

destroy_session uses the session and client without continuously holding
any reference or locks.

Put the whole thing under the state lock for now.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   26 ++++++++++----------------
 1 file changed, 10 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1464d62..05ebcf5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1922,41 +1922,35 @@ nfsd4_destroy_session(struct svc_rqst *r,
 		      struct nfsd4_destroy_session *sessionid)
 {
 	struct nfsd4_session *ses;
-	__be32 status = nfserr_badsession;
+	__be32 status;
 	struct nfsd_net *nn = net_generic(SVC_NET(r), nfsd_net_id);
 
-	/* Notes:
-	 * - The confirmed nfs4_client->cl_sessionid holds destroyed sessinid
-	 * - Should we return nfserr_back_chan_busy if waiting for
-	 *   callbacks on to-be-destroyed session?
-	 * - Do we need to clear any callback info from previous session?
-	 */
-
+	nfs4_lock_state();
+	status = nfserr_not_only_op;
 	if (nfsd4_compound_in_session(cstate->session, &sessionid->sessionid)) {
 		if (!nfsd4_last_compound_op(r))
-			return nfserr_not_only_op;
+			goto out;
 	}
 	dump_sessionid(__func__, &sessionid->sessionid);
 	spin_lock(&nn->client_lock);
 	ses = find_in_sessionid_hashtbl(&sessionid->sessionid, SVC_NET(r));
-	if (!ses) {
-		spin_unlock(&nn->client_lock);
-		goto out;
-	}
+	status = nfserr_badsession;
+	if (!ses)
+		goto out_client_lock;
 
 	unhash_session(ses);
 	spin_unlock(&nn->client_lock);
 
-	nfs4_lock_state();
 	nfsd4_probe_callback_sync(ses->se_client);
-	nfs4_unlock_state();
 
 	spin_lock(&nn->client_lock);
 	nfsd4_del_conns(ses);
 	nfsd4_put_session_locked(ses);
-	spin_unlock(&nn->client_lock);
 	status = nfs_ok;
+out_client_lock:
+	spin_unlock(&nn->client_lock);
 out:
+	nfs4_unlock_state();
 	return status;
 }
 
-- 
1.7.9.5

