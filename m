From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd4: fix unlikely race in session replay case
Date: Wed, 28 Apr 2010 17:31:51 -0400
Message-ID: <20100428213151.GB23474@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44742 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757106Ab0D1Vbv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Apr 2010 17:31:51 -0400
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1O7ErH-0006ED-OL
	for linux-nfs@vger.kernel.org; Wed, 28 Apr 2010 17:31:51 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

In the replay case, the

	renew_client(session->se_client);

happens after we've droppped the sessionid_lock, and without holding a
reference on the session; so there's nothing preventing the session
being freed before we get here.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4proc.c  |    3 +++
 fs/nfsd/nfs4state.c |    7 +++----
 fs/nfsd/nfs4xdr.c   |    1 -
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index e147dbc..e4a4a3e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1027,6 +1027,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	resp->rqstp = rqstp;
 	resp->cstate.minorversion = args->minorversion;
 	resp->cstate.replay_owner = NULL;
+	resp->cstate.session = NULL;
 	fh_init(&resp->cstate.current_fh, NFS4_FHSIZE);
 	fh_init(&resp->cstate.save_fh, NFS4_FHSIZE);
 	/* Use the deferral mechanism only for NFSv4.0 compounds */
@@ -1131,6 +1132,8 @@ encode_op:
 	fh_put(&resp->cstate.save_fh);
 	BUG_ON(resp->cstate.replay_owner);
 out:
+	if (resp->cstate.session)
+		nfsd4_put_session(resp->cstate.session);
 	nfsd4_release_compoundargs(args);
 	/* Reset deferral mechanism for RPC deferrals */
 	rqstp->rq_usedeferral = 1;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index bba9fff..737315c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1443,11 +1443,10 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	cstate->slot = slot;
 	cstate->session = session;
 
-	/* Hold a session reference until done processing the compound:
-	 * nfsd4_put_session called only if the cstate slot is set.
-	 */
-	nfsd4_get_session(session);
 out:
+	/* Hold a session reference until done processing the compound. */
+	if (cstate->session)
+		nfsd4_get_session(cstate->session);
 	spin_unlock(&sessionid_lock);
 	/* Renew the clientid on success and on replay */
 	if (cstate->session) {
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index fb27b1d..903c5a6 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3310,7 +3310,6 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 		nfsd4_store_cache_entry(resp);
 		dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
 		resp->cstate.slot->sl_inuse = false;
-		nfsd4_put_session(resp->cstate.session);
 	}
 	return 1;
 }
-- 
1.6.3.3

