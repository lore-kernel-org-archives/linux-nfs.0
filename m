Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41415 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752353Ab2E3Sgb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 May 2012 14:36:31 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/5] nfsd4: fix, consolidate client_has_state
Date: Wed, 30 May 2012 14:36:28 -0400
Message-Id: <1338402988-17356-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1338402988-17356-1-git-send-email-bfields@redhat.com>
References: <1338402988-17356-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Whoops: first, I reimplemented the already-existing has_resources
without noticing; second, I got the test backwards.  I did pick a better
name, though.  Combine the two....

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   15 ++++-----------
 1 file changed, 4 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4bd5e4d..c8da5c8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1537,9 +1537,9 @@ static bool client_has_state(struct nfs4_client *clp)
 	 *
 	 * Also note we should probably be using this in 4.0 case too.
 	 */
-	return list_empty(&clp->cl_openowners)
-		&& list_empty(&clp->cl_delegations)
-		&& list_empty(&clp->cl_sessions);
+	return !list_empty(&clp->cl_openowners)
+		|| !list_empty(&clp->cl_delegations)
+		|| !list_empty(&clp->cl_sessions);
 }
 
 __be32
@@ -2069,13 +2069,6 @@ out:
 	return status;
 }
 
-static inline bool has_resources(struct nfs4_client *clp)
-{
-	return !list_empty(&clp->cl_openowners)
-		|| !list_empty(&clp->cl_delegations)
-		|| !list_empty(&clp->cl_sessions);
-}
-
 __be32
 nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_destroy_clientid *dc)
 {
@@ -2089,7 +2082,7 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 	if (conf) {
 		clp = conf;
 
-		if (!is_client_expired(conf) && has_resources(conf)) {
+		if (!is_client_expired(conf) && client_has_state(conf)) {
 			status = nfserr_clientid_busy;
 			goto out;
 		}
-- 
1.7.10.2

