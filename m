Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60642 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760865Ab2EWVkn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 May 2012 17:40:43 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 09/10] nfsd4: simpler ordering of setclientid_confirm checks
Date: Wed, 23 May 2012 17:40:39 -0400
Message-Id: <1337809240-15770-10-git-send-email-bfields@redhat.com>
In-Reply-To: <1337809240-15770-1-git-send-email-bfields@redhat.com>
References: <1337809240-15770-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The cases here divide into two main categories:

	- if there's an uncomfirmed record with a matching verifier,
	  then this is a "normal", succesful case: we're either creating
	  a new client, or updating an existing one.
	- otherwise, this is a weird case: a replay, or a server reboot.

Reordering to reflect that makes the code a bit more concise and the
logic a lot easier to understand.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e8e3ce0..72bc277 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2245,18 +2245,21 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 	if (conf && !same_creds(&conf->cl_cred, &rqstp->rq_cred))
 		goto out;
 	/* cases below refer to rfc 3530 section 14.2.34: */
-	if (conf && unconf && same_verf(&confirm, &unconf->cl_confirm)) {
-		/* case 1: callback update */
+	if (!unconf || !same_verf(&confirm, &unconf->cl_confirm)) {
+		if (conf && !unconf) /* case 2: probable retransmit */
+			status = nfs_ok;
+		else /* case 4: client hasn't noticed we rebooted yet? */
+			status = nfserr_stale_clientid;
+		goto out;
+	}
+	status = nfs_ok;
+	if (conf) { /* case 1: callback update */
 		nfsd4_change_callback(conf, &unconf->cl_cb_conn);
 		nfsd4_probe_callback(conf);
 		expire_client(unconf);
-		status = nfs_ok;
-	} else if (conf && !unconf) {
-		status = nfs_ok;
-	} else if (!conf && unconf
-			&& same_verf(&unconf->cl_confirm, &confirm)) {
-		/* case 3: normal case; new or rebooted client */
+	} else { /* case 3: normal case; new or rebooted client */
 		unsigned int hash = clientstr_hashval(unconf->cl_recdir);
+
 		conf = find_confirmed_client_by_str(unconf->cl_recdir, hash);
 		if (conf) {
 			nfsd4_client_record_remove(conf);
@@ -2264,11 +2267,6 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		}
 		move_to_confirmed(unconf);
 		nfsd4_probe_callback(unconf);
-		status = nfs_ok;
-	} else if ((!conf || !same_verf(&conf->cl_confirm, &confirm))
-	    && (!unconf || !same_verf(&unconf->cl_confirm, &confirm))) {
-		/* case 4: client hasn't noticed we rebooted yet? */
-		status = nfserr_stale_clientid;
 	}
 out:
 	nfs4_unlock_state();
-- 
1.7.9.5

