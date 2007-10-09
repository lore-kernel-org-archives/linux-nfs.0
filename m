From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 1/7] svc: Don't copy xprt_class data into svc_xprt instance
Date: Tue, 09 Oct 2007 10:37:09 -0500
Message-ID: <20071009153709.18846.73892.stgit@dell3.ogc.int>
References: <20071009153539.18846.33780.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfH8x-0005de-0N
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 08:37:11 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfH90-0000Db-VN
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 08:37:16 -0700
In-Reply-To: <20071009153539.18846.33780.stgit@dell3.ogc.int>
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


Previously, data from the transport class was copied into the transport
structure. Make the xpt_xpo a ptr to the ops structure from the transport
class, and access the max_payload value through the existing xpt_class 
pointer. 

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    3 +--
 net/sunrpc/svc.c                |    4 ++--
 net/sunrpc/svc_xprt.c           |   19 +++++++++----------
 3 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 53c8891..89bd5ff 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -34,8 +34,7 @@ struct svc_xprt_class {
 
 struct svc_xprt {
 	struct svc_xprt_class	*xpt_class;
-	struct svc_xprt_ops	xpt_ops;
-	u32			xpt_max_payload;
+	struct svc_xprt_ops	*xpt_ops;
 	struct kref		xpt_ref;
 	struct list_head	xpt_list;
 	struct list_head	xpt_ready;
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 440ea59..e1d4c03 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -812,7 +812,7 @@ svc_process(struct svc_rqst *rqstp)
 	rqstp->rq_splice_ok = 1;
 
 	/* Setup reply header */
-	rqstp->rq_xprt->xpt_ops.xpo_prep_reply_hdr(rqstp);
+	rqstp->rq_xprt->xpt_ops->xpo_prep_reply_hdr(rqstp);
 
 	rqstp->rq_xid = svc_getu32(argv);
 	svc_putu32(resv, rqstp->rq_xid);
@@ -1029,7 +1029,7 @@ err_bad:
  */
 u32 svc_max_payload(const struct svc_rqst *rqstp)
 {
-	int max = rqstp->rq_xprt->xpt_max_payload;
+	int max = rqstp->rq_xprt->xpt_class->xcl_max_payload;
 
 	if (rqstp->rq_server->sv_max_payload < max)
 		max = rqstp->rq_server->sv_max_payload;
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index e55904f..16ffc73 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -127,7 +127,7 @@ static inline void svc_xprt_free(struct 
 		container_of(kref, struct svc_xprt, xpt_ref);
 	struct module *owner = xprt->xpt_class->xcl_owner;
 	BUG_ON(atomic_read(&kref->refcount));
-	xprt->xpt_ops.xpo_free(xprt);
+	xprt->xpt_ops->xpo_free(xprt);
 	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags)
 	    && xprt->xpt_auth_cache != NULL)
 		svcauth_unix_info_release(xprt->xpt_auth_cache);
@@ -148,8 +148,7 @@ void svc_xprt_init(struct svc_xprt_class
 		   struct svc_serv *serv)
 {
 	xpt->xpt_class = xcl;
-	xpt->xpt_ops = *xcl->xcl_ops;
-	xpt->xpt_max_payload = xcl->xcl_max_payload;
+	xpt->xpt_ops = xcl->xcl_ops;
 	kref_init(&xpt->xpt_ref);
 	xpt->xpt_server = serv;
 	INIT_LIST_HEAD(&xpt->xpt_list);
@@ -281,7 +280,7 @@ svc_xprt_enqueue(struct svc_xprt *xprt)
 		goto process;
 
 	/* Check if we have space to reply to a request */
-	if (!xprt->xpt_ops.xpo_has_wspace(xprt)) {
+	if (!xprt->xpt_ops->xpo_has_wspace(xprt)) {
 		/* Don't enqueue while not enough space for reply */
 		dprintk("svc: no write space, transport %p  not enqueued\n", xprt);
 		xprt->xpt_pool = NULL;
@@ -382,7 +381,7 @@ svc_xprt_release(struct svc_rqst *rqstp)
 {
 	struct svc_xprt	*xprt = rqstp->rq_xprt;
 
-	rqstp->rq_xprt->xpt_ops.xpo_release(rqstp);
+	rqstp->rq_xprt->xpt_ops->xpo_release(rqstp);
 
 	svc_free_res_pages(rqstp);
 	rqstp->rq_res.page_len = 0;
@@ -604,7 +603,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 		svc_delete_xprt(xprt);
 	} else if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
 		struct svc_xprt *newxpt;
-		newxpt = xprt->xpt_ops.xpo_accept(xprt);
+		newxpt = xprt->xpt_ops->xpo_accept(xprt);
 		if (newxpt) {
 			svc_xprt_received(newxpt);
 			/*
@@ -636,7 +635,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 			svc_xprt_received(xprt);
 			len = svc_deferred_recv(rqstp);
 		} else
-			len = xprt->xpt_ops.xpo_recvfrom(rqstp);
+			len = xprt->xpt_ops->xpo_recvfrom(rqstp);
 		svc_copy_addr(rqstp, xprt);
 		dprintk("svc: got len=%d\n", len);
 	}
@@ -684,7 +683,7 @@ svc_send(struct svc_rqst *rqstp)
 	}
 
 	/* release the receive skb before sending the reply */
-	rqstp->rq_xprt->xpt_ops.xpo_release(rqstp);
+	rqstp->rq_xprt->xpt_ops->xpo_release(rqstp);
 
 	/* calculate over-all length */
 	xb = & rqstp->rq_res;
@@ -697,7 +696,7 @@ svc_send(struct svc_rqst *rqstp)
 	if (test_bit(XPT_DEAD, &xprt->xpt_flags))
 		len = -ENOTCONN;
 	else
-		len = xprt->xpt_ops.xpo_sendto(rqstp);
+		len = xprt->xpt_ops->xpo_sendto(rqstp);
 	mutex_unlock(&xprt->xpt_mutex);
 	svc_xprt_release(rqstp);
 
@@ -772,7 +771,7 @@ svc_delete_xprt(struct svc_xprt *xprt)
 
 	serv = xprt->xpt_server;
 
-	xprt->xpt_ops.xpo_detach(xprt);
+	xprt->xpt_ops->xpo_detach(xprt);
 
 	spin_lock_bh(&serv->sv_lock);
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
