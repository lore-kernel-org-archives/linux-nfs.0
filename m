From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 06/39] nfs41: Initialize new rpc_xprt callback related fields
Date: Fri,  1 May 2009 02:20:02 +0300
Message-ID: <1241133602-482-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org,
	Ricardo Labiaga <ricardo.labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:1614 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754688AbZD3XUK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:20:10 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 net/sunrpc/xprt.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index a0bfe53..bbaec23 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1051,6 +1051,11 @@ found:
 
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
1.6.2.1

