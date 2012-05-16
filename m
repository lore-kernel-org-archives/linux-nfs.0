Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44923 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933386Ab2EPMsn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 May 2012 08:48:43 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 06/11] nfsd4: exchange_id cleanup: comments
Date: Wed, 16 May 2012 08:48:34 -0400
Message-Id: <1337172519-17335-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1337172519-17335-1-git-send-email-bfields@redhat.com>
References: <1337172519-17335-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Make these comments a bit more concise and uniform.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   36 ++++++++++--------------------------
 1 file changed, 10 insertions(+), 26 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e7c4b04..1239ff4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1513,6 +1513,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 
 	strhashval = clientstr_hashval(dname);
 
+	/* Cases below refer to rfc 5661 section 18.35.4: */
 	nfs4_lock_state();
 	conf = find_confirmed_client_by_str(dname, strhashval);
 	if (conf) {
@@ -1520,26 +1521,24 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		bool verfs_match = same_verf(&verf, &conf->cl_verifier);
 
 		if (!clp_used_exchangeid(conf)) {
-			if (update) {
-				status = nfserr_inval; /* buggy client */
+			if (update) { /* buggy client */
+				status = nfserr_inval;
 				goto out;
 			}
 		}
-		if (!creds_match) {
-			/* 18.35.4 case 9 */
+		if (!creds_match) { /* case 9 */
 			if (update)
 				status = nfserr_perm;
 			else /* case 3 */
 				status = nfserr_clid_inuse;
 			goto out;
 		}
-		if (!verfs_match) {
-			/* 18.35.4 case 8 */
+		if (!verfs_match) { /* case 8 */
 			if (update) {
 				status = nfserr_not_same;
 				goto out;
 			}
-			/* Client reboot: destroy old state */
+			/* case 5, client reboot */
 			expire_client(conf);
 			goto out_new;
 		}
@@ -1547,38 +1546,23 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 			status = nfserr_inval;
 			goto out;
 		}
-		/*
-		 * Set bit when the owner id and verifier map to an already
-		 * confirmed client id (18.35.3).
-		 */
+		/* case 2 */
 		exid->flags |= EXCHGID4_FLAG_CONFIRMED_R;
-
-		/*
-		 * Falling into 18.35.4 case 2, possible router replay.
-		 * Leave confirmed record intact and return same result.
-		 */
 		new = conf;
 		goto out_copy;
 	}
 
-	/* 18.35.4 case 7 */
-	if (update) {
+	if (update) { /* case 7 */
 		status = nfserr_noent;
 		goto out;
 	}
 
 	unconf  = find_unconfirmed_client_by_str(dname, strhashval);
-	if (unconf) {
-		/*
-		 * Possible retry or client restart.  Per 18.35.4 case 4,
-		 * a new unconfirmed record should be generated regardless
-		 * of whether any properties have changed.
-		 */
+	if (unconf) /* case 4, possible retry or client restart */
 		expire_client(unconf);
-	}
 
+	/* case 1 (normal case) */
 out_new:
-	/* Normal case */
 	new = create_client(exid->clname, dname, rqstp, &verf);
 	if (new == NULL) {
 		status = nfserr_jukebox;
-- 
1.7.9.5

