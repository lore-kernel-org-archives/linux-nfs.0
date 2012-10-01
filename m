Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43329 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751644Ab2JARqz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 13:46:55 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/8] nfsd4: separate connection allocation and initialization
Date: Mon,  1 Oct 2012 13:46:46 -0400
Message-Id: <1349113612-30374-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1349113612-30374-1-git-send-email-bfields@redhat.com>
References: <1349113612-30374-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

It'll be useful to have connection allocation and initialization as
separate functions.

Also, note we'd been ignoring the alloc_conn error return in
bind_conn_to_session.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   25 +++++++++++++++----------
 1 file changed, 15 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 64938ca..101ccd8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -852,14 +852,10 @@ static int nfsd4_register_conn(struct nfsd4_conn *conn)
 	return register_xpt_user(conn->cn_xprt, &conn->cn_xpt_user);
 }
 
-static __be32 nfsd4_new_conn(struct svc_rqst *rqstp, struct nfsd4_session *ses, u32 dir)
+static void nfsd4_init_conn(struct svc_rqst *rqstp, struct nfsd4_conn *conn, struct nfsd4_session *ses, u32 dir)
 {
-	struct nfsd4_conn *conn;
 	int ret;
 
-	conn = alloc_conn(rqstp, dir);
-	if (!conn)
-		return nfserr_jukebox;
 	nfsd4_hash_conn(conn, ses);
 	ret = nfsd4_register_conn(conn);
 	if (ret)
@@ -870,17 +866,21 @@ static __be32 nfsd4_new_conn(struct svc_rqst *rqstp, struct nfsd4_session *ses,
 		/* callback channel may be back up */
 		nfsd4_probe_callback(ses->se_client);
 	}
-	return nfs_ok;
 }
 
 static __be32 nfsd4_new_conn_from_crses(struct svc_rqst *rqstp, struct nfsd4_session *ses)
 {
+	struct nfsd4_conn *conn;
 	u32 dir = NFS4_CDFC4_FORE;
 
 	if (ses->se_flags & SESSION4_BACK_CHAN)
 		dir |= NFS4_CDFC4_BACK;
 
-	return nfsd4_new_conn(rqstp, ses, dir);
+	conn = alloc_conn(rqstp, dir);
+	if (!conn)
+		return nfserr_jukebox;
+	nfsd4_init_conn(rqstp, conn, ses, dir);
+	return nfs_ok;
 }
 
 /* must be called under client_lock */
@@ -1868,6 +1868,7 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 		     struct nfsd4_bind_conn_to_session *bcts)
 {
 	__be32 status;
+	struct nfsd4_conn *conn;
 
 	if (!nfsd4_last_compound_op(rqstp))
 		return nfserr_not_only_op;
@@ -1884,9 +1885,13 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 		return nfserr_badsession;
 
 	status = nfsd4_map_bcts_dir(&bcts->dir);
-	if (!status)
-		nfsd4_new_conn(rqstp, cstate->session, bcts->dir);
-	return status;
+	if (status)
+		return status;
+	conn = alloc_conn(rqstp, bcts->dir);
+	if (!conn)
+		return nfserr_jukebox;
+	nfsd4_init_conn(rqstp, conn, cstate->session, bcts->dir);
+	return nfs_ok;
 }
 
 static bool nfsd4_compound_in_session(struct nfsd4_session *session, struct nfs4_sessionid *sid)
-- 
1.7.9.5

