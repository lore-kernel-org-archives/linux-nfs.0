Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60628 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760858Ab2EWVkl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 May 2012 17:40:41 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 02/10] nfsd4: setclientid/confirm comment cleanup
Date: Wed, 23 May 2012 17:40:32 -0400
Message-Id: <1337809240-15770-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1337809240-15770-1-git-send-email-bfields@redhat.com>
References: <1337809240-15770-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Be a little more concise.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   67 +++++++++------------------------------------------
 1 file changed, 11 insertions(+), 56 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3dc0289..4ce1045 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2169,17 +2169,13 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (status)
 		return status;
 
-	/* 
-	 * XXX The Duplicate Request Cache (DRC) has been checked (??)
-	 * We get here on a DRC miss.
-	 */
-
 	strhashval = clientstr_hashval(dname);
 
+	/* Cases below refer to rfc 3530 section 14.2.33: */
 	nfs4_lock_state();
 	conf = find_confirmed_client_by_str(dname, strhashval);
 	if (conf) {
-		/* RFC 3530 14.2.33 CASE 0: */
+		/* case 0: */
 		status = nfserr_clid_inuse;
 		if (clp_used_exchangeid(conf))
 			goto out;
@@ -2192,18 +2188,10 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			goto out;
 		}
 	}
-	/*
-	 * section 14.2.33 of RFC 3530 (under the heading "IMPLEMENTATION")
-	 * has a description of SETCLIENTID request processing consisting
-	 * of 5 bullet points, labeled as CASE0 - CASE4 below.
-	 */
 	unconf = find_unconfirmed_client_by_str(dname, strhashval);
 	status = nfserr_jukebox;
 	if (!conf) {
-		/*
-		 * RFC 3530 14.2.33 CASE 4:
-		 * placed first, because it is the normal case
-		 */
+		/* case 4: placed first, because it's the normal case */
 		if (unconf)
 			expire_client(unconf);
 		new = create_client(clname, dname, rqstp, &clverifier);
@@ -2211,10 +2199,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			goto out;
 		gen_clid(new);
 	} else if (same_verf(&conf->cl_verifier, &clverifier)) {
-		/*
-		 * RFC 3530 14.2.33 CASE 1:
-		 * probable callback update
-		 */
+		/* case 1: probable callback update */
 		if (unconf) {
 			/* Note this is removing unconfirmed {*x***},
 			 * which is stronger than RFC recommended {vxc**}.
@@ -2228,21 +2213,13 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			goto out;
 		copy_clid(new, conf);
 	} else if (!unconf) {
-		/*
-		 * RFC 3530 14.2.33 CASE 2:
-		 * probable client reboot; state will be removed if
-		 * confirmed.
-		 */
+		/* case 2: probable client reboot: */
 		new = create_client(clname, dname, rqstp, &clverifier);
 		if (new == NULL)
 			goto out;
 		gen_clid(new);
 	} else {
-		/*
-		 * RFC 3530 14.2.33 CASE 3:
-		 * probable client reboot; state will be removed if
-		 * confirmed.
-		 */
+		/* case 3: probable client reboot: */
 		expire_client(unconf);
 		new = create_client(clname, dname, rqstp, &clverifier);
 		if (new == NULL)
@@ -2266,11 +2243,6 @@ out:
 }
 
 
-/*
- * Section 14.2.34 of RFC 3530 (under the heading "IMPLEMENTATION") has
- * a description of SETCLIENTID_CONFIRM request processing consisting of 4
- * bullets, labeled as CASE1 - CASE4 below.
- */
 __be32
 nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 			 struct nfsd4_compound_state *cstate,
@@ -2293,17 +2265,10 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 	conf = find_confirmed_client(clid);
 	unconf = find_unconfirmed_client(clid);
 
-	/*
-	 * section 14.2.34 of RFC 3530 has a description of
-	 * SETCLIENTID_CONFIRM request processing consisting
-	 * of 4 bullet points, labeled as CASE1 - CASE4 below.
-	 */
+	/* cases below refer to rfc 3530 section 14.2.34: */
 	status = nfserr_clid_inuse;
 	if (conf && unconf && same_verf(&confirm, &unconf->cl_confirm)) {
-		/*
-		 * RFC 3530 14.2.34 CASE 1:
-		 * callback update
-		 */
+		/* case 1: callback update */
 		if (!same_creds(&conf->cl_cred, &unconf->cl_cred))
 			status = nfserr_clid_inuse;
 		else {
@@ -2313,21 +2278,14 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 			status = nfs_ok;
 		}
 	} else if (conf && !unconf) {
-		/*
-		 * RFC 3530 14.2.34 CASE 2:
-		 * probable retransmitted request; play it safe and
-		 * do nothing.
-		 */
+		/* case 2: probable retransmit: */
 		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred))
 			status = nfserr_clid_inuse;
 		else
 			status = nfs_ok;
 	} else if (!conf && unconf
 			&& same_verf(&unconf->cl_confirm, &confirm)) {
-		/*
-		 * RFC 3530 14.2.34 CASE 3:
-		 * Normal case; new or rebooted client:
-		 */
+		/* case 3: normal case; new or rebooted client */
 		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred)) {
 			status = nfserr_clid_inuse;
 		} else {
@@ -2346,10 +2304,7 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		}
 	} else if ((!conf || !same_verf(&conf->cl_confirm, &confirm))
 	    && (!unconf || !same_verf(&unconf->cl_confirm, &confirm))) {
-		/*
-		 * RFC 3530 14.2.34 CASE 4:
-		 * Client probably hasn't noticed that we rebooted yet.
-		 */
+		/* case 4: client hasn't noticed we rebooted yet? */
 		status = nfserr_stale_clientid;
 	}
 
-- 
1.7.9.5

