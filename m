Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55526 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754744AbeFNTcO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Jun 2018 15:32:14 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/5] nfsd4: cleanup sessionid in nfsd4_destroy_session
Date: Thu, 14 Jun 2018 15:32:10 -0400
Message-Id: <1529004733-6022-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1529004733-6022-1-git-send-email-bfields@redhat.com>
References: <1529004733-6022-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The name of this variable doesn't fit the type.  And we only ever use
one field of it.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ac891b5b1d6a..b762054377e0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2966,7 +2966,7 @@ __be32
 nfsd4_destroy_session(struct svc_rqst *r, struct nfsd4_compound_state *cstate,
 		union nfsd4_op_u *u)
 {
-	struct nfsd4_destroy_session *sessionid = &u->destroy_session;
+	struct nfs4_sessionid *sessionid = &u->destroy_session.sessionid;
 	struct nfsd4_session *ses;
 	__be32 status;
 	int ref_held_by_me = 0;
@@ -2974,14 +2974,14 @@ nfsd4_destroy_session(struct svc_rqst *r, struct nfsd4_compound_state *cstate,
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	status = nfserr_not_only_op;
-	if (nfsd4_compound_in_session(cstate, &sessionid->sessionid)) {
+	if (nfsd4_compound_in_session(cstate, sessionid)) {
 		if (!nfsd4_last_compound_op(r))
 			goto out;
 		ref_held_by_me++;
 	}
-	dump_sessionid(__func__, &sessionid->sessionid);
+	dump_sessionid(__func__, sessionid);
 	spin_lock(&nn->client_lock);
-	ses = find_in_sessionid_hashtbl(&sessionid->sessionid, net, &status);
+	ses = find_in_sessionid_hashtbl(sessionid, net, &status);
 	if (!ses)
 		goto out_client_lock;
 	status = nfserr_wrong_cred;
-- 
2.17.1

