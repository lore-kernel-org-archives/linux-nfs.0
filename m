From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 20/33] svc: Make svc_send transport neutral
Date: Thu, 27 Sep 2007 00:02:16 -0500
Message-ID: <20070927050216.12677.10529.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalVx-0005iW-Bu
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:17 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalW1-0005Qz-SG
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:22 -0700
In-Reply-To: <20070927045751.12677.98896.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Move the sk_mutex field to the transport independent svc_xprt structure.
Now all the fields that svc_send touches are transport neutral. Change the 
svc_send function to use the transport independent svc_xprt directly instead 
of the transport dependent svc_sock structure.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    1 +
 include/linux/sunrpc/svcsock.h  |    1 -
 net/sunrpc/svc_xprt.c           |    1 +
 net/sunrpc/svcsock.c            |   17 ++++++++---------
 4 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 8b46561..bb3c02f 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -55,6 +55,7 @@ #define XPT_LISTENER	11			/* listening e
 	struct svc_pool *	xpt_pool;	/* current pool iff queued */
 	struct svc_serv *	xpt_server;	/* service for this transport */
 	atomic_t    	    	xpt_reserved;	/* space on outq that is reserved */
+	struct mutex		xpt_mutex;	/* to serialize sending data */
 };
 
 int	svc_reg_xprt_class(struct svc_xprt_class *);
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index ba41f11..41c2dfa 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -24,7 +24,6 @@ struct svc_sock {
 						 * sk_info_authunix */
 	struct list_head	sk_deferred;	/* deferred requests that need to
 						 * be revisted */
-	struct mutex		sk_mutex;	/* to serialize sending data */
 
 	/* We keep the old state_change and data_ready CB's here */
 	void			(*sk_ostate)(struct sock *);
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index c5eaf8b..d80fc5f 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -111,6 +111,7 @@ void svc_xprt_init(struct svc_xprt_class
 	xpt->xpt_server = serv;
 	INIT_LIST_HEAD(&xpt->xpt_list);
 	INIT_LIST_HEAD(&xpt->xpt_ready);
+	mutex_init(&xpt->xpt_mutex);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index db9963e..dd70a6d 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1650,12 +1650,12 @@ svc_drop(struct svc_rqst *rqstp)
 int
 svc_send(struct svc_rqst *rqstp)
 {
-	struct svc_sock	*svsk;
+	struct svc_xprt	*xprt;
 	int		len;
 	struct xdr_buf	*xb;
 
-	if ((svsk = rqstp->rq_sock) == NULL) {
-		printk(KERN_WARNING "NULL socket pointer in %s:%d\n",
+	if ((xprt = rqstp->rq_xprt) == NULL) {
+		printk(KERN_WARNING "NULL transport pointer in %s:%d\n",
 				__FILE__, __LINE__);
 		return -EFAULT;
 	}
@@ -1669,13 +1669,13 @@ svc_send(struct svc_rqst *rqstp)
 		xb->page_len +
 		xb->tail[0].iov_len;
 
-	/* Grab svsk->sk_mutex to serialize outgoing data. */
-	mutex_lock(&svsk->sk_mutex);
-	if (test_bit(XPT_DEAD, &svsk->sk_xprt.xpt_flags))
+	/* Grab mutex to serialize outgoing data. */
+	mutex_lock(&xprt->xpt_mutex);
+	if (test_bit(XPT_DEAD, &xprt->xpt_flags))
 		len = -ENOTCONN;
 	else
-		len = svsk->sk_xprt.xpt_ops.xpo_sendto(rqstp);
-	mutex_unlock(&svsk->sk_mutex);
+		len = xprt->xpt_ops.xpo_sendto(rqstp);
+	mutex_unlock(&xprt->xpt_mutex);
 	svc_sock_release(rqstp);
 
 	if (len == -ECONNREFUSED || len == -ENOTCONN || len == -EAGAIN)
@@ -1777,7 +1777,6 @@ static struct svc_sock *svc_setup_socket
 	svsk->sk_lastrecv = get_seconds();
 	spin_lock_init(&svsk->sk_lock);
 	INIT_LIST_HEAD(&svsk->sk_deferred);
-	mutex_init(&svsk->sk_mutex);
 
 	/* Initialize the socket */
 	if (sock->type == SOCK_DGRAM) {

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
