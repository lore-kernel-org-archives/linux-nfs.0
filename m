Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41676 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755752AbeCSOgp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Mar 2018 10:36:45 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 03/10] nfsd: simplify nfs4_put_deleg_lease calls
Date: Mon, 19 Mar 2018 10:36:27 -0400
Message-Id: <1521470194-24840-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1521470194-24840-1-git-send-email-bfields@redhat.com>
References: <1521470194-24840-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Every single caller gets the file out of the delegation, so let's do
that once in nfs4_put_deleg_lease.

Plus we'll need it there for other reasons.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1a0b38fddde4..51f633c85776 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -845,9 +845,10 @@ nfs4_inc_and_copy_stateid(stateid_t *dst, struct nfs4_stid *stid)
 	spin_unlock(&stid->sc_lock);
 }
 
-static void nfs4_put_deleg_lease(struct nfs4_file *fp)
+static void nfs4_put_deleg_lease(struct nfs4_delegation *dp)
 {
 	struct file *filp = NULL;
+	struct nfs4_file *fp = dp->dl_stid.sc_file;
 
 	WARN_ON_ONCE(!fp->fi_delegees);
 
@@ -962,7 +963,7 @@ static void destroy_delegation(struct nfs4_delegation *dp)
 	spin_unlock(&state_lock);
 	if (unhashed) {
 		put_clnt_odstate(dp->dl_clnt_odstate);
-		nfs4_put_deleg_lease(dp->dl_stid.sc_file);
+		nfs4_put_deleg_lease(dp);
 		nfs4_put_stid(&dp->dl_stid);
 	}
 }
@@ -974,7 +975,7 @@ static void revoke_delegation(struct nfs4_delegation *dp)
 	WARN_ON(!list_empty(&dp->dl_recall_lru));
 
 	put_clnt_odstate(dp->dl_clnt_odstate);
-	nfs4_put_deleg_lease(dp->dl_stid.sc_file);
+	nfs4_put_deleg_lease(dp);
 
 	if (clp->cl_minorversion == 0)
 		nfs4_put_stid(&dp->dl_stid);
@@ -1885,7 +1886,7 @@ __destroy_client(struct nfs4_client *clp)
 		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
 		list_del_init(&dp->dl_recall_lru);
 		put_clnt_odstate(dp->dl_clnt_odstate);
-		nfs4_put_deleg_lease(dp->dl_stid.sc_file);
+		nfs4_put_deleg_lease(dp);
 		nfs4_put_stid(&dp->dl_stid);
 	}
 	while (!list_empty(&clp->cl_revoked)) {
@@ -7226,7 +7227,7 @@ nfs4_state_shutdown_net(struct net *net)
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
 		list_del_init(&dp->dl_recall_lru);
 		put_clnt_odstate(dp->dl_clnt_odstate);
-		nfs4_put_deleg_lease(dp->dl_stid.sc_file);
+		nfs4_put_deleg_lease(dp);
 		nfs4_put_stid(&dp->dl_stid);
 	}
 
-- 
2.14.3

