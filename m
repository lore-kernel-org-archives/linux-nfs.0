From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 57/85] nfs41: Initialize new rpc_xprt callback related fields
Date: Mon, 10 Nov 2008 22:28:25 +0200
Message-ID: <1226348905-9132-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:59996 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752162AbYKJU2a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:28:30 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <ricardo.labiaga@netapp.com>

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 net/sunrpc/xprt.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 29e401b..848a7af 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1034,6 +1034,11 @@ found:
 
 	INIT_LIST_HEAD(&xprt->free);
 	INIT_LIST_HEAD(&xprt->recv);
+#if defined(CONFIG_NFS_V4_1)
+	spin_lock_init(&xprt->bc_pa_lock);
+	INIT_LIST_HEAD(&xprt->bc_pa_list);
+#endif /* CONFIG_NFS_V4_1 */
+
 	INIT_WORK(&xprt->task_cleanup, xprt_autoclose);
 	setup_timer(&xprt->timer, xprt_init_autodisconnect,
 			(unsigned long)xprt);
-- 
1.6.0.2

