Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:3086 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750745Ab0I0KBA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Sep 2010 06:01:00 -0400
Message-ID: <4CA06B51.5000608@parallels.com>
Date: Mon, 27 Sep 2010 14:00:49 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 6/9] sunrpc: Tag svc_xprt with net
References: <4CA06A63.6090507@parallels.com>
In-Reply-To: <4CA06A63.6090507@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The transport representation should be per-net of course.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/linux/sunrpc/svc_xprt.h |    2 ++
 net/sunrpc/svc_xprt.c           |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 5f4e18b..e50e3ec 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -66,6 +66,8 @@ struct svc_xprt {
 	struct sockaddr_storage	xpt_remote;	/* remote peer's address */
 	size_t			xpt_remotelen;	/* length of address */
 	struct rpc_wait_queue	xpt_bc_pending;	/* backchannel wait queue */
+
+	struct net		*xpt_net;
 };
 
 int	svc_reg_xprt_class(struct svc_xprt_class *);
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 385d822..f7e8915 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -130,6 +130,7 @@ static void svc_xprt_free(struct kref *kref)
 	struct module *owner = xprt->xpt_class->xcl_owner;
 	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags))
 		svcauth_unix_info_release(xprt);
+	put_net(xprt->xpt_net);
 	xprt->xpt_ops->xpo_free(xprt);
 	module_put(owner);
 }
@@ -159,6 +160,7 @@ void svc_xprt_init(struct svc_xprt_class *xcl, struct svc_xprt *xprt,
 	spin_lock_init(&xprt->xpt_lock);
 	set_bit(XPT_BUSY, &xprt->xpt_flags);
 	rpc_init_wait_queue(&xprt->xpt_bc_pending, "xpt_bc_pending");
+	xprt->xpt_net = get_net(&init_net);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_init);
 
-- 
1.5.5.6

