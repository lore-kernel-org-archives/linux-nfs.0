From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 102/112] SUNRPC: Use appropriate argument types in rpcb
	client
Date: Fri, 25 Jan 2008 11:38:00 -0500
Message-ID: <20080125163800.31887.40937.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14371 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755590AbYAYRAG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:06 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxseu010226
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:02 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: Follow recommendations of Chapter 5 of Documentation/CodingStyle
and use "u32" instead of "__u32" for types in definitions that are not
shared with user space.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/clnt.h |    2 +-
 net/sunrpc/rpcb_clnt.c      |    3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 5a13da2..3e9addc 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -125,7 +125,7 @@ void		rpc_shutdown_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
 
 int		rpcb_register(u32, u32, int, unsigned short, int *);
-int		rpcb_getport_sync(struct sockaddr_in *, __u32, __u32, int);
+int		rpcb_getport_sync(struct sockaddr_in *, u32, u32, int);
 void		rpcb_getport_async(struct rpc_task *);
 
 void		rpc_call_start(struct rpc_task *);
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 8962ac6..77af989 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -205,8 +205,7 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
  *
  * XXX: Needs to support IPv6, and rpcbind versions 3 and 4
  */
-int rpcb_getport_sync(struct sockaddr_in *sin, __u32 prog,
-		      __u32 vers, int prot)
+int rpcb_getport_sync(struct sockaddr_in *sin, u32 prog, u32 vers, int prot)
 {
 	struct rpcbind_args map = {
 		.r_prog		= prog,
