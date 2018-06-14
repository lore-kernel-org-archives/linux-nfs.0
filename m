Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55520 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754691AbeFNTcO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Jun 2018 15:32:14 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/5] nfsd4: less confusing nfsd4_compound_in_session
Date: Thu, 14 Jun 2018 15:32:09 -0400
Message-Id: <1529004733-6022-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1529004733-6022-1-git-send-email-bfields@redhat.com>
References: <1529004733-6022-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Make the function prototype match the name a little better.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 683a5f705d81..ac891b5b1d6a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2955,11 +2955,11 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 	return status;
 }
 
-static bool nfsd4_compound_in_session(struct nfsd4_session *session, struct nfs4_sessionid *sid)
+static bool nfsd4_compound_in_session(struct nfsd4_compound_state *cstate, struct nfs4_sessionid *sid)
 {
-	if (!session)
+	if (!cstate->session)
 		return false;
-	return !memcmp(sid, &session->se_sessionid, sizeof(*sid));
+	return !memcmp(sid, &cstate->session->se_sessionid, sizeof(*sid));
 }
 
 __be32
@@ -2974,7 +2974,7 @@ nfsd4_destroy_session(struct svc_rqst *r, struct nfsd4_compound_state *cstate,
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	status = nfserr_not_only_op;
-	if (nfsd4_compound_in_session(cstate->session, &sessionid->sessionid)) {
+	if (nfsd4_compound_in_session(cstate, &sessionid->sessionid)) {
 		if (!nfsd4_last_compound_op(r))
 			goto out;
 		ref_held_by_me++;
-- 
2.17.1

