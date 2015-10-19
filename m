Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50411 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754644AbbJSVzh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Oct 2015 17:55:37 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/2] nfsd: fix clid_inuse on mount with security change
Date: Mon, 19 Oct 2015 17:55:34 -0400
Message-Id: <1445291735-16717-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

In bakeathon testing Solaris client was getting CLID_INUSE error when
doing a krb5 mount soon after an auth_sys mount, or vice versa.

That's not really necessary since in this case the old client doesn't
have any state any more:

	http://tools.ietf.org/html/rfc7530#page-103

	"when the server gets a SETCLIENTID for a client ID that
	currently has no state, or it has state but the lease has
	expired, rather than returning NFS4ERR_CLID_INUSE, the server
	MUST allow the SETCLIENTID and confirm the new client ID if
	followed by the appropriate SETCLIENTID_CONFIRM."

This doesn't fix the problem completely since our client_has_state()
check counts openowners left around to handle close replays, which we
should probably just remove in this case.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8b4731dd6f91..1159a2321e37 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2275,7 +2275,8 @@ static bool client_has_state(struct nfs4_client *clp)
 	 * Note clp->cl_openowners check isn't quite right: there's no
 	 * need to count owners without stateid's.
 	 *
-	 * Also note we should probably be using this in 4.0 case too.
+	 * Also note in 4.0 case should also be checking for openowners
+	 * kept around just for close handling.
 	 */
 	return !list_empty(&clp->cl_openowners)
 #ifdef CONFIG_NFSD_PNFS
@@ -3062,7 +3063,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	/* Cases below refer to rfc 3530 section 14.2.33: */
 	spin_lock(&nn->client_lock);
 	conf = find_confirmed_client_by_name(&clname, nn);
-	if (conf) {
+	if (conf && client_has_state(conf)) {
 		/* case 0: */
 		status = nfserr_clid_inuse;
 		if (clp_used_exchangeid(conf))
@@ -3149,6 +3150,11 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 	} else { /* case 3: normal case; new or rebooted client */
 		old = find_confirmed_client_by_name(&unconf->cl_name, nn);
 		if (old) {
+			status = nfserr_clid_inuse;
+			if (client_has_state(old)
+					&& !same_creds(&unconf->cl_cred,
+							&old->cl_cred))
+				goto out;
 			status = mark_client_expired_locked(old);
 			if (status) {
 				old = NULL;
-- 
2.4.3

