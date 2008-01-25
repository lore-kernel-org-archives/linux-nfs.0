From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 101/112] SUNRPC: rpcb_getport_sync() should use built-in
	hostname generator
Date: Fri, 25 Jan 2008 11:38:00 -0500
Message-ID: <20080125163800.31887.26737.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14403 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755836AbYAYRAU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:20 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH04Hr010310
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:19 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

rpc_create() can already fill in the hostname with a string representation
of the server's IP address, so remove redundant logic in in
rpcb_getport_sync() that does that.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/rpcb_clnt.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index a6cd358..8962ac6 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -220,14 +220,12 @@ int rpcb_getport_sync(struct sockaddr_in *sin, __u32 prog,
 		.rpc_resp	= &map.r_port,
 	};
 	struct rpc_clnt	*rpcb_clnt;
-	char hostname[40];
 	int status;
 
 	dprintk("RPC:       %s(" NIPQUAD_FMT ", %u, %u, %d)\n",
 		__FUNCTION__, NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
 
-	sprintf(hostname, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
-	rpcb_clnt = rpcb_create(hostname, (struct sockaddr *)sin,
+	rpcb_clnt = rpcb_create(NULL, (struct sockaddr *)sin,
 				sizeof(sin), prot, 2, 0);
 	if (IS_ERR(rpcb_clnt))
 		return PTR_ERR(rpcb_clnt);
