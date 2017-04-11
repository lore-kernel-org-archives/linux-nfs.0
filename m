Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33047 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752923AbdDKRWj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Apr 2017 13:22:39 -0400
Subject: [PATCH v3 02/13] sunrpc: Export xprt_force_disconnect()
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 11 Apr 2017 13:22:38 -0400
Message-ID: <20170411172238.11300.91110.stgit@manet.1015granger.net>
In-Reply-To: <20170411171820.11300.55637.stgit@manet.1015granger.net>
References: <20170411171820.11300.55637.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xprt_force_disconnect() is already invoked from the socket
transport. I want to invoke xprt_force_disconnect() from the
RPC-over-RDMA transport, which is a separate module from sunrpc.ko.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprt.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index b530a28..3e63c5e 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -651,6 +651,7 @@ void xprt_force_disconnect(struct rpc_xprt *xprt)
 	xprt_wake_pending_tasks(xprt, -EAGAIN);
 	spin_unlock_bh(&xprt->transport_lock);
 }
+EXPORT_SYMBOL_GPL(xprt_force_disconnect);
 
 /**
  * xprt_conditional_disconnect - force a transport to disconnect

