From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 27/33] SUNRPC: Remove the unused export of
	xprt_force_disconnect
Date: Sat, 19 Apr 2008 16:40:54 -0400
Message-ID: <20080419204053.14124.59168.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35010 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756019AbYDSUuW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:22 -0400
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m3JKoMQw026048
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2008 13:50:22 -0700 (PDT)
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprt.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 5110a4e..a0646a3 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -605,7 +605,6 @@ void xprt_force_disconnect(struct rpc_xprt *xprt)
 	xprt_wake_pending_tasks(xprt, -ENOTCONN);
 	spin_unlock_bh(&xprt->transport_lock);
 }
-EXPORT_SYMBOL_GPL(xprt_force_disconnect);
 
 static void
 xprt_init_autodisconnect(unsigned long data)

