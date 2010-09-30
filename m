Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49140 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932222Ab0I3QTo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 12:19:44 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 12/16] nfsd: provide callbacks on svc_xprt deletion
Date: Thu, 30 Sep 2010 12:19:09 -0400
Message-Id: <1285863553-8945-13-git-send-email-bfields@redhat.com>
In-Reply-To: <1285863553-8945-1-git-send-email-bfields@redhat.com>
References: <1285863553-8945-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

NFSv4.1 needs warning when a client tcp connection goes down, if that
connection is being used as a backchannel, so that it can warn the
client that it has lost the backchannel connection.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/sunrpc/svc_xprt.h |   25 +++++++++++++++++++++++++
 net/sunrpc/svc_xprt.c           |   15 +++++++++++++++
 2 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index e50e3ec..cc90cce 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -32,6 +32,16 @@ struct svc_xprt_class {
 	u32			xcl_max_payload;
 };
 
+/*
+ * This is embedded in an object that wants a callback before deleting
+ * an xprt; intended for use by NFSv4.1, which needs to know when a
+ * client's tcp connection (and hence possibly a backchannel) goes away.
+ */
+struct svc_xpt_user {
+	struct list_head list;
+	void (*callback)(struct svc_xpt_user *);
+};
+
 struct svc_xprt {
 	struct svc_xprt_class	*xpt_class;
 	struct svc_xprt_ops	*xpt_ops;
@@ -66,10 +76,25 @@ struct svc_xprt {
 	struct sockaddr_storage	xpt_remote;	/* remote peer's address */
 	size_t			xpt_remotelen;	/* length of address */
 	struct rpc_wait_queue	xpt_bc_pending;	/* backchannel wait queue */
+	struct list_head	xpt_users;	/* callbacks on free */
 
 	struct net		*xpt_net;
 };
 
+static inline void register_xpt_user(struct svc_xprt *xpt, struct svc_xpt_user *u)
+{
+	spin_lock(&xpt->xpt_lock);
+	list_add(&u->list, &xpt->xpt_users);
+	spin_unlock(&xpt->xpt_lock);
+}
+
+static inline void unregister_xpt_user(struct svc_xprt *xpt, struct svc_xpt_user *u)
+{
+	spin_lock(&xpt->xpt_lock);
+	list_del_init(&u->list);
+	spin_unlock(&xpt->xpt_lock);
+}
+
 int	svc_reg_xprt_class(struct svc_xprt_class *);
 void	svc_unreg_xprt_class(struct svc_xprt_class *);
 void	svc_xprt_init(struct svc_xprt_class *, struct svc_xprt *,
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index f7e8915..b37fd3a 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -156,6 +156,7 @@ void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xprt,
 	INIT_LIST_HEAD(&xprt->xpt_list);
 	INIT_LIST_HEAD(&xprt->xpt_ready);
 	INIT_LIST_HEAD(&xprt->xpt_deferred);
+	INIT_LIST_HEAD(&xprt->xpt_users);
 	mutex_init(&xprt->xpt_mutex);
 	spin_lock_init(&xprt->xpt_lock);
 	set_bit(XPT_BUSY, &xprt->xpt_flags);
@@ -880,6 +881,19 @@ static void svc_age_temp_xprts(unsigned long closure)
 	mod_timer(&serv->sv_temptimer, jiffies + svc_conn_age_period * HZ);
 }
 
+static void call_xpt_users(struct svc_xprt *xprt)
+{
+	struct svc_xpt_user *u;
+
+	spin_lock(&xprt->xpt_lock);
+	while (!list_empty(&xprt->xpt_users)) {
+		u = list_first_entry(&xprt->xpt_users, struct svc_xpt_user, list);
+		list_del(&u->list);
+		u->callback(u);
+	}
+	spin_unlock(&xprt->xpt_lock);
+}
+
 /*
  * Remove a dead transport
  */
@@ -912,6 +926,7 @@ void svc_delete_xprt(struct svc_xprt *xprt)
 	while ((dr = svc_deferred_dequeue(xprt)) != NULL)
 		kfree(dr);
 
+	call_xpt_users(xprt);
 	svc_xprt_put(xprt);
 }
 
-- 
1.7.0.4

