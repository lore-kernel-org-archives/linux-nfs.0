Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60978 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752865Ab3CUO4W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Mar 2013 10:56:22 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/9] nfsd4: destroy_clientid simplification
Date: Thu, 21 Mar 2013 10:56:15 -0400
Message-Id: <1363877780-28825-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1363877780-28825-1-git-send-email-bfields@redhat.com>
References: <1363877780-28825-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

I'm not sure what the check for clientid expiry was meant to do here.

The check for a matching session is redundant given the previous check
for state: a client without state is, in particular, a client without
sessions.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 91ad066..ef0337d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2127,13 +2127,7 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 	if (conf) {
 		clp = conf;
 
-		if (!is_client_expired(conf) && client_has_state(conf)) {
-			status = nfserr_clientid_busy;
-			goto out;
-		}
-
-		/* rfc5661 18.50.3 */
-		if (cstate->session && conf == cstate->session->se_client) {
+		if (client_has_state(conf)) {
 			status = nfserr_clientid_busy;
 			goto out;
 		}
-- 
1.7.9.5

