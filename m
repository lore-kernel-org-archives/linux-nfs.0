Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43331 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751629Ab2JARqz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 13:46:55 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/8] nfsd4: new_conn_from_crses should only allocate
Date: Mon,  1 Oct 2012 13:46:47 -0400
Message-Id: <1349113612-30374-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1349113612-30374-1-git-send-email-bfields@redhat.com>
References: <1349113612-30374-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Do the initialization in the caller, and clarify that the only failure
ever possible here was due to allocation.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   26 ++++++++++----------------
 1 file changed, 10 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 101ccd8..8b7f8f8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -852,7 +852,7 @@ static int nfsd4_register_conn(struct nfsd4_conn *conn)
 	return register_xpt_user(conn->cn_xprt, &conn->cn_xpt_user);
 }
 
-static void nfsd4_init_conn(struct svc_rqst *rqstp, struct nfsd4_conn *conn, struct nfsd4_session *ses, u32 dir)
+static void nfsd4_init_conn(struct svc_rqst *rqstp, struct nfsd4_conn *conn, struct nfsd4_session *ses)
 {
 	int ret;
 
@@ -862,25 +862,19 @@ static void nfsd4_init_conn(struct svc_rqst *rqstp, struct nfsd4_conn *conn, str
 		/* oops; xprt is already down: */
 		nfsd4_conn_lost(&conn->cn_xpt_user);
 	if (ses->se_client->cl_cb_state == NFSD4_CB_DOWN &&
-		dir & NFS4_CDFC4_BACK) {
+			conn->cn_flags & NFS4_CDFC4_BACK) {
 		/* callback channel may be back up */
 		nfsd4_probe_callback(ses->se_client);
 	}
 }
 
-static __be32 nfsd4_new_conn_from_crses(struct svc_rqst *rqstp, struct nfsd4_session *ses)
+static struct nfsd4_conn *alloc_conn_from_crses(struct svc_rqst *rqstp, struct nfsd4_create_session *cses)
 {
-	struct nfsd4_conn *conn;
 	u32 dir = NFS4_CDFC4_FORE;
 
-	if (ses->se_flags & SESSION4_BACK_CHAN)
+	if (cses->flags & SESSION4_BACK_CHAN)
 		dir |= NFS4_CDFC4_BACK;
-
-	conn = alloc_conn(rqstp, dir);
-	if (!conn)
-		return nfserr_jukebox;
-	nfsd4_init_conn(rqstp, conn, ses, dir);
-	return nfs_ok;
+	return alloc_conn(rqstp, dir);
 }
 
 /* must be called under client_lock */
@@ -929,9 +923,9 @@ void nfsd4_put_session(struct nfsd4_session *ses)
 static struct nfsd4_session *alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp, struct nfsd4_create_session *cses)
 {
 	struct nfsd4_session *new;
+	struct nfsd4_conn *conn;
 	struct nfsd4_channel_attrs *fchan = &cses->fore_channel;
 	int numslots, slotsize;
-	__be32 status;
 	int idx;
 
 	/*
@@ -970,14 +964,14 @@ static struct nfsd4_session *alloc_init_session(struct svc_rqst *rqstp, struct n
 	spin_unlock(&clp->cl_lock);
 	spin_unlock(&client_lock);
 
-	status = nfsd4_new_conn_from_crses(rqstp, new);
-	/* whoops: benny points out, status is ignored! (err, or bogus) */
-	if (status) {
+	conn = alloc_conn_from_crses(rqstp, cses);
+	if (!conn) {
 		spin_lock(&client_lock);
 		free_session(&new->se_ref);
 		spin_unlock(&client_lock);
 		return NULL;
 	}
+	nfsd4_init_conn(rqstp, conn, new);
 	if (cses->flags & SESSION4_BACK_CHAN) {
 		struct sockaddr *sa = svc_addr(rqstp);
 		/*
@@ -1890,7 +1884,7 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 	conn = alloc_conn(rqstp, bcts->dir);
 	if (!conn)
 		return nfserr_jukebox;
-	nfsd4_init_conn(rqstp, conn, cstate->session, bcts->dir);
+	nfsd4_init_conn(rqstp, conn, cstate->session);
 	return nfs_ok;
 }
 
-- 
1.7.9.5

