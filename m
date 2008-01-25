From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 010/112] SUNRPC: xprt_autoclose() should not call
	xprt_disconnect()
Date: Fri, 25 Jan 2008 11:37:26 -0500
Message-ID: <20080125163725.31887.72688.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14393 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755544AbYAYRAS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:18 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH04Hi010310
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:16 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The transport layer should do that itself whenever appropriate.

Note that the RDMA transport already assumes that it needs to call
xprt_disconnect in xprt_rdma_close().
For TCP sockets, we want to call xprt_disconnect() only after the
connection has been closed by both ends.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprt.c     |    1 -
 net/sunrpc/xprtsock.c |    3 +--
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 8575bf4..8799b64 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -568,7 +568,6 @@ static void xprt_autoclose(struct work_struct *work)
 	struct rpc_xprt *xprt =
 		container_of(work, struct rpc_xprt, task_cleanup);
 
-	xprt_disconnect(xprt);
 	xprt->ops->close(xprt);
 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	xprt_release_write(xprt, NULL);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index d2151a9..5d0444d 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -774,10 +774,10 @@ static void xs_close(struct rpc_xprt *xprt)
 	sock_release(sock);
 clear_close_wait:
 	smp_mb__before_clear_bit();
-	clear_bit(XPRT_CONNECTED, &xprt->state);
 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	clear_bit(XPRT_CLOSING, &xprt->state);
 	smp_mb__after_clear_bit();
+	xprt_disconnect(xprt);
 }
 
 /**
@@ -793,7 +793,6 @@ static void xs_destroy(struct rpc_xprt *xprt)
 
 	cancel_rearming_delayed_work(&transport->connect_worker);
 
-	xprt_disconnect(xprt);
 	xs_close(xprt);
 	xs_free_peer_addresses(xprt);
 	kfree(xprt->slot);
