From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 093/112] SUNRPC: Fix up constant string declarations in
	struct rpcbind_args
Date: Fri, 25 Jan 2008 11:37:57 -0500
Message-ID: <20080125163756.31887.84907.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14334 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754888AbYAYQ7q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:46 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxdt0010119
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:46 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and eliminate an unnecessary cast.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/rpcb_clnt.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index b60fa92..a6cd358 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -73,9 +73,9 @@ struct rpcbind_args {
 	u32			r_vers;
 	u32			r_prot;
 	unsigned short		r_port;
-	char *			r_netid;
-	char			r_addr[RPCBIND_MAXUADDRLEN];
-	char *			r_owner;
+	const char *		r_netid;
+	const char *		r_addr;
+	const char *		r_owner;
 };
 
 static struct rpc_procinfo rpcb_procedures2[];
@@ -358,10 +358,8 @@ void rpcb_getport_async(struct rpc_task *task)
 	map->r_prot = xprt->prot;
 	map->r_port = 0;
 	map->r_xprt = xprt_get(xprt);
-	map->r_netid = (char *)rpc_peeraddr2str(clnt, RPC_DISPLAY_NETID);
-	memcpy(map->r_addr,
-	       rpc_peeraddr2str(rpcb_clnt, RPC_DISPLAY_UNIVERSAL_ADDR),
-	       sizeof(map->r_addr));
+	map->r_netid = rpc_peeraddr2str(clnt, RPC_DISPLAY_NETID);
+	map->r_addr = rpc_peeraddr2str(rpcb_clnt, RPC_DISPLAY_UNIVERSAL_ADDR);
 	map->r_owner = RPCB_OWNER_STRING;	/* ignored for GETADDR */
 
 	child = rpcb_call_async(rpcb_clnt, map, xprt->bind_index);
