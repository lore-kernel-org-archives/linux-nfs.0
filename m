From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 026/100] nfsd4: kill some unneeded setclientid comments
Date: Fri, 25 Jan 2008 18:16:06 -0500
Message-ID: <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47358 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758764AbYAYXRa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:30 -0500
In-Reply-To: <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Most of these comments just summarize the code.

The matching of code to the cases described in the RFC may still be
useful, though; add specific section references to make that easier to
follow.  Also update references to the outdated RFC 3010.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |  136 +++++++++++++++------------------------------------
 1 files changed, 40 insertions(+), 96 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9d81c71..242fee7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -683,39 +683,6 @@ out_err:
 	return;
 }
 
-/*
- * RFC 3010 has a complex implmentation description of processing a 
- * SETCLIENTID request consisting of 5 bullets, labeled as 
- * CASE0 - CASE4 below.
- *
- * NOTES:
- * 	callback information will be processed in a future patch
- *
- *	an unconfirmed record is added when:
- *      NORMAL (part of CASE 4): there is no confirmed nor unconfirmed record.
- *	CASE 1: confirmed record found with matching name, principal,
- *		verifier, and clientid.
- *	CASE 2: confirmed record found with matching name, principal,
- *		and there is no unconfirmed record with matching
- *		name and principal
- *
- *      an unconfirmed record is replaced when:
- *	CASE 3: confirmed record found with matching name, principal,
- *		and an unconfirmed record is found with matching 
- *		name, principal, and with clientid and
- *		confirm that does not match the confirmed record.
- *	CASE 4: there is no confirmed record with matching name and 
- *		principal. there is an unconfirmed record with 
- *		matching name, principal.
- *
- *	an unconfirmed record is deleted when:
- *	CASE 1: an unconfirmed record that matches input name, verifier,
- *		and confirmed clientid.
- *	CASE 4: any unconfirmed records with matching name and principal
- *		that exist after an unconfirmed record has been replaced
- *		as described above.
- *
- */
 __be32
 nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		  struct nfsd4_setclientid *setclid)
@@ -748,11 +715,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfs4_lock_state();
 	conf = find_confirmed_client_by_str(dname, strhashval);
 	if (conf) {
-		/* 
-		 * CASE 0:
-		 * clname match, confirmed, different principal
-		 * or different ip_address
-		 */
+		/* RFC 3530 14.2.33 CASE 0: */
 		status = nfserr_clid_inuse;
 		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred)
 				|| conf->cl_addr != sin->sin_addr.s_addr) {
@@ -761,12 +724,17 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			goto out;
 		}
 	}
+	/*
+	 * section 14.2.33 of RFC 3530 (under the heading "IMPLEMENTATION")
+	 * has a description of SETCLIENTID request processing consisting
+	 * of 5 bullet points, labeled as CASE0 - CASE4 below.
+	 */
 	unconf = find_unconfirmed_client_by_str(dname, strhashval);
 	status = nfserr_resource;
 	if (!conf) {
-		/* 
-		 * CASE 4:
-		 * placed first, because it is the normal case.
+		/*
+		 * RFC 3530 14.2.33 CASE 4:
+		 * placed first, because it is the normal case
 		 */
 		if (unconf)
 			expire_client(unconf);
@@ -776,17 +744,8 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		gen_clid(new);
 	} else if (same_verf(&conf->cl_verifier, &clverifier)) {
 		/*
-		 * CASE 1:
-		 * cl_name match, confirmed, principal match
-		 * verifier match: probable callback update
-		 *
-		 * remove any unconfirmed nfs4_client with 
-		 * matching cl_name, cl_verifier, and cl_clientid
-		 *
-		 * create and insert an unconfirmed nfs4_client with same 
-		 * cl_name, cl_verifier, and cl_clientid as existing 
-		 * nfs4_client,  but with the new callback info and a 
-		 * new cl_confirm
+		 * RFC 3530 14.2.33 CASE 1:
+		 * probable callback update
 		 */
 		if (unconf) {
 			/* Note this is removing unconfirmed {*x***},
@@ -802,32 +761,19 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		copy_clid(new, conf);
 	} else if (!unconf) {
 		/*
-		 * CASE 2:
-		 * clname match, confirmed, principal match
-		 * verfier does not match
-		 * no unconfirmed. create a new unconfirmed nfs4_client
-		 * using input clverifier, clname, and callback info
-		 * and generate a new cl_clientid and cl_confirm.
+		 * RFC 3530 14.2.33 CASE 2:
+		 * probable client reboot; state will be removed if
+		 * confirmed.
 		 */
 		new = create_client(clname, dname);
 		if (new == NULL)
 			goto out;
 		gen_clid(new);
 	} else if (!same_verf(&conf->cl_confirm, &unconf->cl_confirm)) {
-		/*	
-		 * CASE3:
-		 * confirmed found (name, principal match)
-		 * confirmed verifier does not match input clverifier
-		 *
-		 * unconfirmed found (name match)
-		 * confirmed->cl_confirm != unconfirmed->cl_confirm
-		 *
-		 * remove unconfirmed.
-		 *
-		 * create an unconfirmed nfs4_client 
-		 * with same cl_name as existing confirmed nfs4_client, 
-		 * but with new callback info, new cl_clientid,
-		 * new cl_verifier and a new cl_confirm
+		/*
+		 * RFC 3530 14.2.33 CASE 3:
+		 * probable client reboot; state will be removed if
+		 * confirmed.
 		 */
 		expire_client(unconf);
 		new = create_client(clname, dname);
@@ -857,11 +803,9 @@ out:
 
 
 /*
- * RFC 3010 has a complex implmentation description of processing a 
- * SETCLIENTID_CONFIRM request consisting of 4 bullets describing
- * processing on a DRC miss, labeled as CASE1 - CASE4 below.
- *
- * NOTE: callback information will be processed here in a future patch
+ * Section 14.2.34 of RFC 3530 (under the heading "IMPLEMENTATION") has
+ * a description of SETCLIENTID_CONFIRM request processing consisting of 4
+ * bullets, labeled as CASE1 - CASE4 below.
  */
 __be32
 nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
@@ -892,16 +836,20 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 	if (unconf && unconf->cl_addr != sin->sin_addr.s_addr)
 		goto out;
 
+	/*
+	 * section 14.2.34 of RFC 3530 has a description of
+	 * SETCLIENTID_CONFIRM request processing consisting
+	 * of 4 bullet points, labeled as CASE1 - CASE4 below.
+	 */
 	if ((conf && unconf) && 
 	    (same_verf(&unconf->cl_confirm, &confirm)) &&
 	    (same_verf(&conf->cl_verifier, &unconf->cl_verifier)) &&
 	    (same_name(conf->cl_recdir,unconf->cl_recdir))  &&
 	    (!same_verf(&conf->cl_confirm, &unconf->cl_confirm))) {
-		/* CASE 1:
-		* unconf record that matches input clientid and input confirm.
-		* conf record that matches input clientid.
-		* conf and unconf records match names, verifiers
-		*/
+		/*
+		 * RFC 3530 14.2.34 CASE 1:
+		 * callback update
+		 */
 		if (!same_creds(&conf->cl_cred, &unconf->cl_cred))
 			status = nfserr_clid_inuse;
 		else {
@@ -918,11 +866,10 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 	    ((conf && unconf) && 
 	     (!same_verf(&conf->cl_verifier, &unconf->cl_verifier) ||
 	      !same_name(conf->cl_recdir, unconf->cl_recdir)))) {
-		/* CASE 2:
-		 * conf record that matches input clientid.
-		 * if unconf record matches input clientid, then
-		 * unconf->cl_name or unconf->cl_verifier don't match the
-		 * conf record.
+		/*
+		 * RFC 3530 14.2.34 CASE 2:
+		 * probable retransmitted request; play it safe and
+		 * do nothing.
 		 */
 		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred))
 			status = nfserr_clid_inuse;
@@ -930,10 +877,9 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 			status = nfs_ok;
 	} else if (!conf && unconf
 			&& same_verf(&unconf->cl_confirm, &confirm)) {
-		/* CASE 3:
-		 * conf record not found.
-		 * unconf record found.
-		 * unconf->cl_confirm matches input confirm
+		/*
+		 * RFC 3530 14.2.34 CASE 3:
+		 * Normal case; new or rebooted client:
 		 */
 		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred)) {
 			status = nfserr_clid_inuse;
@@ -954,11 +900,9 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 	} else if ((!conf || (conf && !same_verf(&conf->cl_confirm, &confirm)))
 	    && (!unconf || (unconf && !same_verf(&unconf->cl_confirm,
 				    				&confirm)))) {
-		/* CASE 4:
-		 * conf record not found, or if conf, conf->cl_confirm does not
-		 * match input confirm.
-		 * unconf record not found, or if unconf, unconf->cl_confirm
-		 * does not match input confirm.
+		/*
+		 * RFC 3530 14.2.34 CASE 4:
+		 * Client probably hasn't noticed that we rebooted yet.
 		 */
 		status = nfserr_stale_clientid;
 	} else {
-- 
1.5.4.rc2.60.gb2e62

