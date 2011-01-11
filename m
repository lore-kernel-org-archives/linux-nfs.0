Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56180 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932357Ab1AKQVm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jan 2011 11:21:42 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 03/14] nfsd4: allow backchannel recovery
Date: Tue, 11 Jan 2011 11:21:23 -0500
Message-Id: <1294762894-21371-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1294762894-21371-1-git-send-email-bfields@redhat.com>
References: <1294762894-21371-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

Now that we have a list of connections to choose from, we can teach the
callback code to just pick a suitable connection and use that, instead
of insisting on forever using the connection that the first
create_session was sent with.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   36 +++++++++++++++++++++++++++++++++---
 fs/nfsd/nfs4state.c    |   16 ++++++++++------
 2 files changed, 43 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index dd183af..18b740b 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -473,8 +473,7 @@ static int max_cb_time(void)
 /* Reference counting, callback cleanup, etc., all look racy as heck.
  * And why is cl_cb_set an atomic? */
 
-static int setup_callback_client(struct nfs4_client *clp,
-		struct nfs4_cb_conn *conn)
+static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *conn, struct nfsd4_session *ses)
 {
 	struct rpc_timeout	timeparms = {
 		.to_initval	= max_cb_time(),
@@ -501,6 +500,10 @@ static int setup_callback_client(struct nfs4_client *clp,
 		args.protocol = XPRT_TRANSPORT_TCP;
 		clp->cl_cb_ident = conn->cb_ident;
 	} else {
+		if (!conn->cb_xprt)
+			return -EINVAL;
+		clp->cl_cb_conn.cb_xprt = conn->cb_xprt;
+		clp->cl_cb_session = ses;
 		args.bc_xprt = conn->cb_xprt;
 		args.prognumber = clp->cl_cb_session->se_cb_prog;
 		args.protocol = XPRT_TRANSPORT_BC_TCP;
@@ -756,10 +759,27 @@ static void nfsd4_release_cb(struct nfsd4_callback *cb)
 		cb->cb_ops->rpc_release(cb);
 }
 
+/* requires cl_lock: */
+static struct nfsd4_conn * __nfsd4_find_backchannel(struct nfs4_client *clp)
+{
+	struct nfsd4_session *s;
+	struct nfsd4_conn *c;
+
+	list_for_each_entry(s, &clp->cl_sessions, se_perclnt) {
+		list_for_each_entry(c, &s->se_conns, cn_persession) {
+			if (c->cn_flags & NFS4_CDFC4_BACK)
+				return c;
+		}
+	}
+	return NULL;
+}
+
 static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 {
 	struct nfs4_cb_conn conn;
 	struct nfs4_client *clp = cb->cb_clp;
+	struct nfsd4_session *ses = NULL;
+	struct nfsd4_conn *c;
 	int err;
 
 	/*
@@ -770,6 +790,10 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 		rpc_shutdown_client(clp->cl_cb_client);
 		clp->cl_cb_client = NULL;
 	}
+	if (clp->cl_cb_conn.cb_xprt) {
+		svc_xprt_put(clp->cl_cb_conn.cb_xprt);
+		clp->cl_cb_conn.cb_xprt = NULL;
+	}
 	if (test_bit(NFSD4_CLIENT_KILL, &clp->cl_cb_flags))
 		return;
 	spin_lock(&clp->cl_lock);
@@ -780,9 +804,15 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 	BUG_ON(!clp->cl_cb_flags);
 	clear_bit(NFSD4_CLIENT_CB_UPDATE, &clp->cl_cb_flags);
 	memcpy(&conn, &cb->cb_clp->cl_cb_conn, sizeof(struct nfs4_cb_conn));
+	c = __nfsd4_find_backchannel(clp);
+	if (c) {
+		svc_xprt_get(c->cn_xprt);
+		conn.cb_xprt = c->cn_xprt;
+		ses = c->cn_session;
+	}
 	spin_unlock(&clp->cl_lock);
 
-	err = setup_callback_client(clp, &conn);
+	err = setup_callback_client(clp, &conn, ses);
 	if (err)
 		warn_no_callback_path(clp, err);
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 956174f..290370b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -642,6 +642,7 @@ static void nfsd4_conn_lost(struct svc_xpt_user *u)
 		free_conn(c);
 	}
 	spin_unlock(&clp->cl_lock);
+	/* XXX: mark callback for update, probe callback */
 }
 
 static struct nfsd4_conn *alloc_conn(struct svc_rqst *rqstp, u32 flags)
@@ -790,16 +791,19 @@ static struct nfsd4_session *alloc_init_session(struct svc_rqst *rqstp, struct n
 		free_session(&new->se_ref);
 		return NULL;
 	}
-	if (!clp->cl_cb_session && (cses->flags & SESSION4_BACK_CHAN)) {
+	if (cses->flags & SESSION4_BACK_CHAN) {
 		struct sockaddr *sa = svc_addr(rqstp);
-
-		clp->cl_cb_session = new;
-		clp->cl_cb_conn.cb_xprt = rqstp->rq_xprt;
-		svc_xprt_get(rqstp->rq_xprt);
+		/*
+		 * This is a little silly; with sessions there's no real
+		 * use for the callback address.  Use the peer address
+		 * as a reasonable default for now, but consider fixing
+		 * the rpc client not to require an address in the
+		 * future:
+		 */
 		rpc_copy_addr((struct sockaddr *)&clp->cl_cb_conn.cb_addr, sa);
 		clp->cl_cb_conn.cb_addrlen = svc_addr_len(sa);
-		nfsd4_probe_callback(clp);
 	}
+	nfsd4_probe_callback(clp);
 	return new;
 }
 
-- 
1.7.1

