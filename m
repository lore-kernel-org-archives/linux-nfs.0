From: "HIRANO Takahito" <hiranotaka-FWFpUBK1X0Y@public.gmane.org>
Subject: [PATCH] [stable 2.6.24] Fix oops at rpcb_getport_async in sunrpc
Date: Sat, 3 May 2008 05:07:21 +0900
Message-ID: <8408c1a50805021307x2f1843ffrfb53efbbfaf8aaba@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: stable@kernel.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:36478 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756815AbYEBUHV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 May 2008 16:07:21 -0400
Received: by wf-out-1314.google.com with SMTP id 27so111885wfd.4
        for <linux-nfs@vger.kernel.org>; Fri, 02 May 2008 13:07:21 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rpcb_getport_async in the sunrpc module copies larger memory area than
the allocated. Because of this problem, NFS users might encounter oops.

This problem only exists in 2.6.24.y.
It is fixed in 2.6.25 by the commit 86d61d8638ddf9cdf87df26c7fa69b2804425fbe.

Regards,

HIRANO Takahito

Cc: stable@kernel.org,
    linux-nfs@vger.kernel.org

Signed-off-by: HIRANO Takahito <hiranotaka-FWFpUBK1X0Y@public.gmane.org>
---
 net/sunrpc/rpcb_clnt.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index a05493a..4d939a6 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -113,7 +113,7 @@ struct rpcbind_args {
 	u32			r_prot;
 	unsigned short		r_port;
 	char *			r_netid;
-	char			r_addr[RPCB_MAXADDRLEN];
+	const char *		r_addr;
 	char *			r_owner;
 };

@@ -390,9 +390,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	map->r_port = 0;
 	map->r_xprt = xprt_get(xprt);
 	map->r_netid = rpc_peeraddr2str(clnt, RPC_DISPLAY_NETID);
-	memcpy(map->r_addr,
-	       rpc_peeraddr2str(rpcb_clnt, RPC_DISPLAY_UNIVERSAL_ADDR),
-	       sizeof(map->r_addr));
+	map->r_addr = rpc_peeraddr2str(rpcb_clnt, RPC_DISPLAY_UNIVERSAL_ADDR);
 	map->r_owner = RPCB_OWNER_STRING;	/* ignored for GETADDR */

 	child = rpc_run_task(rpcb_clnt, RPC_TASK_ASYNC, &rpcb_getport_ops, map);
