Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57639 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751347Ab2LDNBz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Dec 2012 08:01:55 -0500
Date: Tue, 4 Dec 2012 08:01:53 -0500
To: linux-nfs@vger.kernel.org
Cc: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [PATCH] nfsd4: lockt, release_lockowner should renew clients
Message-ID: <20121204130153.GA18674@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Fix nfsd4_lockt and release_lockowner to lookup the referenced client,
so that we can renew the client, or correctly return "expired", as
appropriate.

Also share some code while we're here.

Reported-by: Frank Filz <ffilzlnx@us.ibm.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   41 +++++++++++++++++++++++------------------
 1 file changed, 23 insertions(+), 18 deletions(-)

I intend to commit this for 3.8.

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index eff7340..16e954c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3132,6 +3132,18 @@ void nfsd4_cleanup_open_state(struct nfsd4_open *open, __be32 status)
 		free_generic_stateid(open->op_stp);
 }
 
+static __be32 lookup_clientid(clientid_t *clid, bool session, struct nfsd_net *nn, struct nfs4_client **clp)
+{
+	struct nfs4_client *found;
+
+	if (STALE_CLIENTID(clid, nn))
+		return nfserr_stale_clientid;
+	found = find_confirmed_client(clid, session, nn);
+	if (clp)
+		*clp = found;
+	return found ? nfs_ok : nfserr_expired;
+}
+
 __be32
 nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    clientid_t *clid)
@@ -3143,16 +3155,9 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfs4_lock_state();
 	dprintk("process_renew(%08x/%08x): starting\n", 
 			clid->cl_boot, clid->cl_id);
-	status = nfserr_stale_clientid;
-	if (STALE_CLIENTID(clid, nn))
-		goto out;
-	clp = find_confirmed_client(clid, cstate->minorversion, nn);
-	status = nfserr_expired;
-	if (clp == NULL) {
-		/* We assume the client took too long to RENEW. */
-		dprintk("nfsd4_renew: clientid not found!\n");
+	status = lookup_clientid(clid, cstate->minorversion, nn, &clp);
+	if (status)
 		goto out;
-	}
 	status = nfserr_cb_path_down;
 	if (!list_empty(&clp->cl_delegations)
 			&& clp->cl_cb_state != NFSD4_CB_UP)
@@ -4293,9 +4298,11 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	nfs4_lock_state();
 
-	status = nfserr_stale_clientid;
-	if (!nfsd4_has_session(cstate) && STALE_CLIENTID(&lockt->lt_clientid, nn))
-		goto out;
+	if (!nfsd4_has_session(cstate)) {
+		status = lookup_clientid(&lockt->lt_clientid, false, nn, NULL);
+		if (status)
+			goto out;
+	}
 
 	if ((status = fh_verify(rqstp, &cstate->current_fh, S_IFREG, 0)))
 		goto out;
@@ -4466,14 +4473,12 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	dprintk("nfsd4_release_lockowner clientid: (%08x/%08x):\n",
 		clid->cl_boot, clid->cl_id);
 
-	/* XXX check for lease expiration */
-
-	status = nfserr_stale_clientid;
-	if (STALE_CLIENTID(clid, nn))
-		return status;
-
 	nfs4_lock_state();
 
+	status = lookup_clientid(clid, cstate->minorversion, nn, NULL);
+	if (status)
+		goto out;
+
 	status = nfserr_locks_held;
 	INIT_LIST_HEAD(&matches);
 
-- 
1.7.9.5

