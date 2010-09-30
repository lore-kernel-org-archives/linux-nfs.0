Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49145 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932221Ab0I3QTp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 12:19:45 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 14/16] nfsd4: refactor connection allocation
Date: Thu, 30 Sep 2010 12:19:11 -0400
Message-Id: <1285863553-8945-15-git-send-email-bfields@redhat.com>
In-Reply-To: <1285863553-8945-1-git-send-email-bfields@redhat.com>
References: <1285863553-8945-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   32 ++++++++++++++++++++++++++------
 1 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b7e9793..3b4d74c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -644,25 +644,45 @@ static void nfsd4_conn_lost(struct svc_xpt_user *u)
 	spin_unlock(&clp->cl_lock);
 }
 
-static __be32 nfsd4_new_conn(struct svc_rqst *rqstp, struct nfsd4_session *ses)
+static struct nfsd4_conn *alloc_conn(struct svc_rqst *rqstp)
 {
-	struct nfs4_client *clp = ses->se_client;
 	struct nfsd4_conn *conn;
 
 	conn = kmalloc(sizeof(struct nfsd4_conn), GFP_KERNEL);
 	if (!conn)
-		return nfserr_jukebox;
-	conn->cn_flags = NFS4_CDFC4_FORE;
+		return NULL;
 	svc_xprt_get(rqstp->rq_xprt);
 	conn->cn_xprt = rqstp->rq_xprt;
-	conn->cn_session = ses;
+	conn->cn_flags = NFS4_CDFC4_FORE;
+	INIT_LIST_HEAD(&conn->cn_xpt_user.list);
+	return conn;
+}
+
+static void nfsd4_hash_conn(struct nfsd4_conn *conn, struct nfsd4_session *ses)
+{
+	struct nfs4_client *clp = ses->se_client;
 
 	spin_lock(&clp->cl_lock);
+	conn->cn_session = ses;
 	list_add(&conn->cn_persession, &ses->se_conns);
 	spin_unlock(&clp->cl_lock);
+}
 
+static void nfsd4_register_conn(struct nfsd4_conn *conn)
+{
 	conn->cn_xpt_user.callback = nfsd4_conn_lost;
-	register_xpt_user(rqstp->rq_xprt, &conn->cn_xpt_user);
+	register_xpt_user(conn->cn_xprt, &conn->cn_xpt_user);
+}
+
+static __be32 nfsd4_new_conn(struct svc_rqst *rqstp, struct nfsd4_session *ses)
+{
+	struct nfsd4_conn *conn;
+
+	conn = alloc_conn(rqstp);
+	if (!conn)
+		return nfserr_jukebox;
+	nfsd4_hash_conn(conn, ses);
+	nfsd4_register_conn(conn);
 	return nfs_ok;
 }
 
-- 
1.7.0.4

