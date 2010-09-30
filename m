Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49142 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932223Ab0I3QTo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 12:19:44 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 13/16] nfsd4: use callbacks on svc_xprt_deletion
Date: Thu, 30 Sep 2010 12:19:10 -0400
Message-Id: <1285863553-8945-14-git-send-email-bfields@redhat.com>
In-Reply-To: <1285863553-8945-1-git-send-email-bfields@redhat.com>
References: <1285863553-8945-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

Remove connections from the list when they go down.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |   51 ++++++++++++++++++++++++++++++++++++++++++---------
 fs/nfsd/state.h     |    3 +++
 2 files changed, 45 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c7c1a7a..b7e9793 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -625,6 +625,25 @@ static void init_forechannel_attrs(struct nfsd4_channel_attrs *new, struct nfsd4
 	new->maxops = min_t(u32, req->maxops, NFSD_MAX_OPS_PER_COMPOUND);
 }
 
+static void free_conn(struct nfsd4_conn *c)
+{
+	svc_xprt_put(c->cn_xprt);
+	kfree(c);
+}
+
+static void nfsd4_conn_lost(struct svc_xpt_user *u)
+{
+	struct nfsd4_conn *c = container_of(u, struct nfsd4_conn, cn_xpt_user);
+	struct nfs4_client *clp = c->cn_session->se_client;
+
+	spin_lock(&clp->cl_lock);
+	if (!list_empty(&c->cn_persession)) {
+		list_del(&c->cn_persession);
+		free_conn(c);
+	}
+	spin_unlock(&clp->cl_lock);
+}
+
 static __be32 nfsd4_new_conn(struct svc_rqst *rqstp, struct nfsd4_session *ses)
 {
 	struct nfs4_client *clp = ses->se_client;
@@ -636,18 +655,34 @@ static __be32 nfsd4_new_conn(struct svc_rqst *rqstp, struct nfsd4_session *ses)
 	conn->cn_flags = NFS4_CDFC4_FORE;
 	svc_xprt_get(rqstp->rq_xprt);
 	conn->cn_xprt = rqstp->rq_xprt;
+	conn->cn_session = ses;
 
 	spin_lock(&clp->cl_lock);
 	list_add(&conn->cn_persession, &ses->se_conns);
 	spin_unlock(&clp->cl_lock);
 
+	conn->cn_xpt_user.callback = nfsd4_conn_lost;
+	register_xpt_user(rqstp->rq_xprt, &conn->cn_xpt_user);
 	return nfs_ok;
 }
 
-static void free_conn(struct nfsd4_conn *c)
+static void nfsd4_del_conns(struct nfsd4_session *s)
 {
-	svc_xprt_put(c->cn_xprt);
-	kfree(c);
+	struct nfs4_client *clp = s->se_client;
+	struct nfsd4_conn *c;
+
+	spin_lock(&clp->cl_lock);
+	while (!list_empty(&s->se_conns)) {
+		c = list_first_entry(&s->se_conns, struct nfsd4_conn, cn_persession);
+		list_del_init(&c->cn_persession);
+		spin_unlock(&clp->cl_lock);
+
+		unregister_xpt_user(c->cn_xprt, &c->cn_xpt_user);
+		free_conn(c);
+
+		spin_lock(&clp->cl_lock);
+	}
+	spin_unlock(&clp->cl_lock);
 }
 
 void free_session(struct kref *kref)
@@ -656,12 +691,7 @@ void free_session(struct kref *kref)
 	int mem;
 
 	ses = container_of(kref, struct nfsd4_session, se_ref);
-	while (!list_empty(&ses->se_conns)) {
-		struct nfsd4_conn *c;
-		c = list_first_entry(&ses->se_conns, struct nfsd4_conn, cn_persession);
-		list_del(&c->cn_persession);
-		free_conn(c);
-	}
+	nfsd4_del_conns(ses);
 	spin_lock(&nfsd_drc_lock);
 	mem = ses->se_fchannel.maxreqs * slot_bytes(&ses->se_fchannel);
 	nfsd_drc_mem_used -= mem;
@@ -1552,6 +1582,9 @@ nfsd4_destroy_session(struct svc_rqst *r,
 	/* wait for callbacks */
 	nfsd4_shutdown_callback(ses->se_client);
 	nfs4_unlock_state();
+
+	nfsd4_del_conns(ses);
+
 	nfsd4_put_session(ses);
 	status = nfs_ok;
 out:
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 29413c2..8d5e237 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -35,6 +35,7 @@
 #ifndef _NFSD4_STATE_H
 #define _NFSD4_STATE_H
 
+#include <linux/sunrpc/svc_xprt.h>
 #include <linux/nfsd/nfsfh.h>
 #include "nfsfh.h"
 
@@ -155,6 +156,8 @@ struct nfsd4_clid_slot {
 struct nfsd4_conn {
 	struct list_head cn_persession;
 	struct svc_xprt *cn_xprt;
+	struct svc_xpt_user cn_xpt_user;
+	struct nfsd4_session *cn_session;
 /* CDFC4_FORE, CDFC4_BACK: */
 	unsigned char cn_flags;
 };
-- 
1.7.0.4

