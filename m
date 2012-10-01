Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43339 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751626Ab2JARq4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 13:46:56 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 7/8] nfsd4: expire old client earlier
Date: Mon,  1 Oct 2012 13:46:51 -0400
Message-Id: <1349113612-30374-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1349113612-30374-1-git-send-email-bfields@redhat.com>
References: <1349113612-30374-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Before we had to delay expiring a client till we'd found out whether the
session and connection allocations would succeed.  That's no longer
necessary.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1cd80d5..592cd7f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1756,7 +1756,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	struct nfsd4_session *new;
 	struct nfsd4_conn *conn;
 	struct nfsd4_clid_slot *cs_slot = NULL;
-	bool confirm_me = false;
 	__be32 status = 0;
 
 	if (cr_ses->flags & ~SESSION4_FLAG_MASK_A)
@@ -1786,6 +1785,8 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			goto out_free_conn;
 		}
 	} else if (unconf) {
+		unsigned int hash;
+		struct nfs4_client *old;
 		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
 		    !rpc_cmp_addr(sa, (struct sockaddr *) &unconf->cl_addr)) {
 			status = nfserr_clid_inuse;
@@ -1798,7 +1799,11 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			status = nfserr_seq_misordered;
 			goto out_free_conn;
 		}
-		confirm_me = true;
+		hash = clientstr_hashval(unconf->cl_recdir);
+		old = find_confirmed_client_by_str(unconf->cl_recdir, hash);
+		if (old)
+			expire_client(old);
+		move_to_confirmed(unconf);
 		conf = unconf;
 	} else {
 		status = nfserr_stale_clientid;
@@ -1823,14 +1828,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 
 	/* cache solo and embedded create sessions under the state lock */
 	nfsd4_cache_create_session(cr_ses, cs_slot, status);
-	if (confirm_me) {
-		unsigned int hash = clientstr_hashval(unconf->cl_recdir);
-		struct nfs4_client *old =
-			find_confirmed_client_by_str(conf->cl_recdir, hash);
-		if (old)
-			expire_client(old);
-		move_to_confirmed(conf);
-	}
 out:
 	nfs4_unlock_state();
 	dprintk("%s returns %d\n", __func__, ntohl(status));
-- 
1.7.9.5

