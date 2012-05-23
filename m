Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60638 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760864Ab2EWVkm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 May 2012 17:40:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 07/10] nfsd4: fix error return in non-matching-creds case
Date: Wed, 23 May 2012 17:40:37 -0400
Message-Id: <1337809240-15770-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1337809240-15770-1-git-send-email-bfields@redhat.com>
References: <1337809240-15770-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Note CLID_INUSE is for the case where two clients are trying to use the
same client-provided long-form client identifiers.  But what we're
looking at here is the server-returned shorthand client id--if those
clash there's a bug somewhere.

Fix the error return, pull the check out into common code, and do the
check unconditionally in all cases.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   62 +++++++++++++++++++++------------------------------
 1 file changed, 26 insertions(+), 36 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 286710d..8e77782 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2229,59 +2229,49 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 
 	if (STALE_CLIENTID(clid))
 		return nfserr_stale_clientid;
-	/* 
-	 * XXX The Duplicate Request Cache (DRC) has been checked (??)
-	 * We get here on a DRC miss.
-	 */
-
 	nfs4_lock_state();
 
 	conf = find_confirmed_client(clid);
 	unconf = find_unconfirmed_client(clid);
-
+	/*
+	 * We try hard to give out unique clientid's, so if we get an
+	 * attempt to confirm the same clientid with a different cred,
+	 * there's a bug somewhere.  Let's charitably assume it's our
+	 * bug.
+	 */
+	status = nfserr_serverfault;
+	if (unconf && !same_creds(&unconf->cl_cred, &rqstp->rq_cred))
+		goto out;
+	if (conf && !same_creds(&conf->cl_cred, &rqstp->rq_cred))
+		goto out;
 	/* cases below refer to rfc 3530 section 14.2.34: */
-	status = nfserr_clid_inuse;
 	if (conf && unconf && same_verf(&confirm, &unconf->cl_confirm)) {
 		/* case 1: callback update */
-		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred))
-			status = nfserr_clid_inuse;
-		else {
-			nfsd4_change_callback(conf, &unconf->cl_cb_conn);
-			nfsd4_probe_callback(conf);
-			expire_client(unconf);
-			status = nfs_ok;
-		}
+		nfsd4_change_callback(conf, &unconf->cl_cb_conn);
+		nfsd4_probe_callback(conf);
+		expire_client(unconf);
+		status = nfs_ok;
 	} else if (conf && !unconf) {
-		/* case 2: probable retransmit: */
-		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred))
-			status = nfserr_clid_inuse;
-		else
-			status = nfs_ok;
+		status = nfs_ok;
 	} else if (!conf && unconf
 			&& same_verf(&unconf->cl_confirm, &confirm)) {
 		/* case 3: normal case; new or rebooted client */
-		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred)) {
-			status = nfserr_clid_inuse;
-		} else {
-			unsigned int hash =
-				clientstr_hashval(unconf->cl_recdir);
-			conf = find_confirmed_client_by_str(unconf->cl_recdir,
-							    hash);
-			if (conf) {
-				nfsd4_client_record_remove(conf);
-				expire_client(conf);
-			}
-			move_to_confirmed(unconf);
-			conf = unconf;
-			nfsd4_probe_callback(conf);
-			status = nfs_ok;
+		unsigned int hash = clientstr_hashval(unconf->cl_recdir);
+		conf = find_confirmed_client_by_str(unconf->cl_recdir, hash);
+		if (conf) {
+			nfsd4_client_record_remove(conf);
+			expire_client(conf);
 		}
+		move_to_confirmed(unconf);
+		conf = unconf;
+		nfsd4_probe_callback(conf);
+		status = nfs_ok;
 	} else if ((!conf || !same_verf(&conf->cl_confirm, &confirm))
 	    && (!unconf || !same_verf(&unconf->cl_confirm, &confirm))) {
 		/* case 4: client hasn't noticed we rebooted yet? */
 		status = nfserr_stale_clientid;
 	}
-
+out:
 	nfs4_unlock_state();
 	return status;
 }
-- 
1.7.9.5

