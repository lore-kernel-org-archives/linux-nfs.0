Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60987 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752845Ab3CUO4X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Mar 2013 10:56:23 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 7/9] nfsd4: simplify bind_conn_to_session locking
Date: Thu, 21 Mar 2013 10:56:18 -0400
Message-Id: <1363877780-28825-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1363877780-28825-1-git-send-email-bfields@redhat.com>
References: <1363877780-28825-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The locking here is very fiddly, and there's no reason for us to be
setting cstate->session, since this is the only op in the compound.
Let's just take the state lock and drop the reference counting.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 05ebcf5..0ff616f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1883,30 +1883,30 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 {
 	__be32 status;
 	struct nfsd4_conn *conn;
+	struct nfsd4_session *session;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	if (!nfsd4_last_compound_op(rqstp))
 		return nfserr_not_only_op;
+	nfs4_lock_state();
 	spin_lock(&nn->client_lock);
-	cstate->session = find_in_sessionid_hashtbl(&bcts->sessionid, SVC_NET(rqstp));
-	/* Sorta weird: we only need the refcnt'ing because new_conn acquires
-	 * client_lock iself: */
-	if (cstate->session) {
-		nfsd4_get_session(cstate->session);
-		atomic_inc(&cstate->session->se_client->cl_refcount);
-	}
+	session = find_in_sessionid_hashtbl(&bcts->sessionid, SVC_NET(rqstp));
 	spin_unlock(&nn->client_lock);
-	if (!cstate->session)
-		return nfserr_badsession;
-
+	status = nfserr_badsession;
+	if (!session)
+		goto out;
 	status = nfsd4_map_bcts_dir(&bcts->dir);
 	if (status)
-		return status;
+		goto out;
 	conn = alloc_conn(rqstp, bcts->dir);
+	status = nfserr_jukebox;
 	if (!conn)
-		return nfserr_jukebox;
-	nfsd4_init_conn(rqstp, conn, cstate->session);
-	return nfs_ok;
+		goto out;
+	nfsd4_init_conn(rqstp, conn, session);
+	status = nfs_ok;
+out:
+	nfs4_unlock_state();
+	return status;
 }
 
 static bool nfsd4_compound_in_session(struct nfsd4_session *session, struct nfs4_sessionid *sid)
-- 
1.7.9.5

