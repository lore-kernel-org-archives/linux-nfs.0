Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37113 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932700Ab0DHQFv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Apr 2010 12:05:51 -0400
Date: Thu, 8 Apr 2010 12:08:19 -0400
From: "J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 02/11] sunrpc: take reference to bc_xprt in sunrpc layer
Message-ID: <20100408160819.GA9624@fieldses.org>
References: <1268180896-30921-1-git-send-email-bfields@citi.umich.edu> <1268180896-30921-2-git-send-email-bfields@citi.umich.edu> <1268180896-30921-3-git-send-email-bfields@citi.umich.edu> <1268182980.9419.40.camel@localhost.localdomain> <20100310190545.GC23974@fieldses.org> <20100318150818.GA17347@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100318150818.GA17347@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Mar 18, 2010 at 11:08:18AM -0400, J. Bruce Fields wrote:
> On Wed, Mar 10, 2010 at 02:05:45PM -0500, J. Bruce Fields wrote:
> > On Tue, Mar 09, 2010 at 08:03:00PM -0500, Trond Myklebust wrote:
> > > Why should the back channel socket hold a reference to the svc_sock? The
> > > process that owns both of these things is an RPC server process. It
> > > already holds a reference to the svc_sock and presumably also to the
> > > back channel socket.
> > 
> > Only while it's actually processing an rpc, I assume.  
> > 
> > I'll take a harder look at what should be the lifetime of the server
> > socket that the backchannel requests use.
> > 
> > By the way, we also need to make sure the nfs server code gets some kind
> > of call when the client closes the connection, so we can set
> > callback-down session flags appropriately.
> 
> One way to do that would be for nfsd to register a callback to be called
> from svc_delete_xprt().  Then in that callback nfsd can set those
> session flags appropriately, but it can also shut down the rpc client.
> That ensures the rpc client (and its xprt) go away before the svc_xprt,
> so we no longer need to hold a reference.
> 
> (Actually there's nothing preventing multiple backchannels from sharing
> the same connection, so we'd need a list of callbacks.)

That would look like the below.  The server would use it to register a
callback that cleans up the old rpc client, sets
SEQ4_STATUS_CB_PATH_DOWN if necessary, etc.

(Actually I think it may make the locking simplest just to keep these
callbacks under a spinlock, in which case the callback will need to
defer most of that work to a workqueue, which I don't see any problem
with so far.)

--b.

commit aecf73a3ef70426845deff43e4435a87ff9170ab
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Mon Mar 22 15:37:17 2010 -0400

    nfsd: provide callbacks on svc_xprt deletion.
    
    NFSv4.1 needs warning when a client tcp connection goes down, if that
    connection is being used as a backchannel, so that it can warn the
    client that it has lost the backchannel connection.
    
    This also allows us to destroy the rpc_client, or any other structures
    associated with the backchannel connection, before the svc_xprt is
    destroyed, thus removing the need for some odd reference counting.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 5f4e18b..22229e4 100644
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
@@ -66,8 +76,23 @@ struct svc_xprt {
 	struct sockaddr_storage	xpt_remote;	/* remote peer's address */
 	size_t			xpt_remotelen;	/* length of address */
 	struct rpc_wait_queue	xpt_bc_pending;	/* backchannel wait queue */
+	struct list_head	xpt_users;	/* callbacks on free */
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
index c334f54..82cd43c 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -155,6 +155,7 @@ void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xprt,
 	INIT_LIST_HEAD(&xprt->xpt_list);
 	INIT_LIST_HEAD(&xprt->xpt_ready);
 	INIT_LIST_HEAD(&xprt->xpt_deferred);
+	INIT_LIST_HEAD(&xprt->xpt_users);
 	mutex_init(&xprt->xpt_mutex);
 	spin_lock_init(&xprt->xpt_lock);
 	set_bit(XPT_BUSY, &xprt->xpt_flags);
@@ -865,6 +866,18 @@ static void svc_age_temp_xprts(unsigned long closure)
 	mod_timer(&serv->sv_temptimer, jiffies + svc_conn_age_period * HZ);
 }
 
+static void call_xpt_users(struct svc_xprt *xprt)
+{
+	struct svc_xpt_user *u;
+
+	spin_lock(&xprt->xpt_lock);
+	while (!list_empty(&xprt->xpt_users)) {
+		u = list_first_entry(&xprt->xpt_users, struct svc_xpt_user, list);
+		u->callback(u);
+	}
+	spin_unlock(&xprt->xpt_lock);
+}
+
 /*
  * Remove a dead transport
  */
@@ -897,6 +910,7 @@ void svc_delete_xprt(struct svc_xprt *xprt)
 	while ((dr = svc_deferred_dequeue(xprt)) != NULL)
 		kfree(dr);
 
+	call_xpt_users(xprt);
 	svc_xprt_put(xprt);
 }
 
