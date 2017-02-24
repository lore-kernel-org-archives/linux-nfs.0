Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55990 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751192AbdBXSZa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Feb 2017 13:25:30 -0500
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: schumaker.anna@gmail.com, linux-nfs@vger.kernel.org,
        chuck.lever@oracle.com, tom@talpey.com,
        jgunthorpe@obsidianresearch.com
Subject: [PATCH v2 2/4] sunrpc: flag transports as having both reliable and ordered delivery, and congestion control
Date: Fri, 24 Feb 2017 13:25:23 -0500
Message-Id: <20170224182525.10390-3-jlayton@redhat.com>
In-Reply-To: <20170224182525.10390-1-jlayton@redhat.com>
References: <20170223170337.10686-1-jlayton@redhat.com>
 <20170224182525.10390-1-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4 requires a transport protocol with reliable and ordered delivery,
and congestion control in most cases.

On an IP network, that means that NFSv4 over UDP should be forbidden.

The situation with RDMA is a bit more nuanced, but most RDMA transports
are suitable for this. For now, we assume that all RDMA transports are
suitable, but we may need to revise that at some point.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/sunrpc/svc_xprt.h          | 1 +
 net/sunrpc/svcsock.c                     | 1 +
 net/sunrpc/xprtrdma/svc_rdma_transport.c | 8 ++++++++
 3 files changed, 10 insertions(+)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 7440290f64ac..c832acf509d8 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -67,6 +67,7 @@ struct svc_xprt {
 #define XPT_CACHE_AUTH	11		/* cache auth info */
 #define XPT_LOCAL	12		/* connection from loopback interface */
 #define XPT_KILL_TEMP   13		/* call xpo_kill_temp_xprt before closing */
+#define XPT_CONG_CTRL	14		/* has reliable and ordered delivery, and congestion control */
 
 	struct svc_serv		*xpt_server;	/* service for transport */
 	atomic_t    	    	xpt_reserved;	/* space on outq that is rsvd */
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index de066acdb34e..1956b8b96b2d 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1306,6 +1306,7 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 	svc_xprt_init(sock_net(svsk->sk_sock->sk), &svc_tcp_class,
 		      &svsk->sk_xprt, serv);
 	set_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
+	set_bit(XPT_CONG_CTRL, &svsk->sk_xprt.xpt_flags);
 	if (sk->sk_state == TCP_LISTEN) {
 		dprintk("setting up TCP socket for listening\n");
 		set_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 39652d390a9c..0476b412c7b1 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -571,6 +571,14 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 	spin_lock_init(&cma_xprt->sc_ctxt_lock);
 	spin_lock_init(&cma_xprt->sc_map_lock);
 
+	/*
+	 * Note that this implies that the underlying transport support
+	 * reliable and ordered delivery, and (generally) some form of
+	 * congestion control. For now, we assume that all supported RDMA
+	 * transports are suitable here.
+	 */
+	set_bit(XPT_CONG_CTRL, &cma_xprt->sc_xprt.xpt_flags);
+
 	if (listener)
 		set_bit(XPT_LISTENER, &cma_xprt->sc_xprt.xpt_flags);
 
-- 
2.9.3

