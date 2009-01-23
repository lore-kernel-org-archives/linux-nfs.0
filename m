From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/6] SUNRPC: Use IPv4 loopback for registering AF_INET6 kernel
	RPC services
Date: Fri, 23 Jan 2009 11:46:01 -0500
Message-ID: <20090123164600.27126.54874.stgit@ingres.1015granger.net>
References: <20090123164302.27126.56411.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:29266 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756659AbZAWQtF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jan 2009 11:49:05 -0500
In-Reply-To: <20090123164302.27126.56411.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kernel uses an IPv6 loopback address when registering its AF_INET6
RPC services so that it can tell whether the local portmapper is
actually IPv6-enabled.

Since the legacy portmapper doesn't listen on IPv6, however, this
causes a long timeout on older systems if the kernel happens to try
creating and registering an AF_INET6 RPC service.  Originally I wanted
to use a connected transport (either TCP or connected UDP) so that the
upcall would fail immediately if the portmapper wasn't listening on
IPv6, but we never agreed on what transport to use.

In the end, it's of little consequence to the kernel whether the local
portmapper is listening on IPv6.  It's only important whether the
portmapper supports rpcbind v4.  And the kernel can't tell that at all
if it is sending requests via IPv6 -- the portmapper will just ignore
them.

So, send all SET/UNSET requests via IPv4 loopback to maintain better
backwards compatibility between new kernels and legacy user space, and
prevent multi-second hangs in some cases when the kernel attempts to
register RPC services.

This patch is part of a series that addresses

   http://bugzilla.kernel.org/show_bug.cgi?id=12256

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   23 ++++++-----------------
 1 files changed, 6 insertions(+), 17 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 03ae007..0e9150d 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -124,12 +124,6 @@ static const struct sockaddr_in rpcb_inaddr_loopback = {
 	.sin_port		= htons(RPCBIND_PORT),
 };
 
-static const struct sockaddr_in6 rpcb_in6addr_loopback = {
-	.sin6_family		= AF_INET6,
-	.sin6_addr		= IN6ADDR_LOOPBACK_INIT,
-	.sin6_port		= htons(RPCBIND_PORT),
-};
-
 static struct rpc_clnt *rpcb_create_local(struct sockaddr *addr,
 					  size_t addrlen, u32 version)
 {
@@ -176,9 +170,10 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 	return rpc_create(&args);
 }
 
-static int rpcb_register_call(struct sockaddr *addr, size_t addrlen,
-			      u32 version, struct rpc_message *msg)
+static int rpcb_register_call(u32 version, struct rpc_message *msg)
 {
+	struct sockaddr *addr = (struct sockaddr *)&rpcb_inaddr_loopback;
+	size_t addrlen = sizeof(rpcb_inaddr_loopback);
 	struct rpc_clnt *rpcb_clnt;
 	int result, error = 0;
 
@@ -254,9 +249,7 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port)
 	if (port)
 		msg.rpc_proc = &rpcb_procedures2[RPCBPROC_SET];
 
-	return rpcb_register_call((struct sockaddr *)&rpcb_inaddr_loopback,
-					sizeof(rpcb_inaddr_loopback),
-					RPCBVERS_2, &msg);
+	return rpcb_register_call(RPCBVERS_2, &msg);
 }
 
 /*
@@ -284,9 +277,7 @@ static int rpcb_register_netid4(struct sockaddr_in *address_to_register,
 	if (port)
 		msg->rpc_proc = &rpcb_procedures4[RPCBPROC_SET];
 
-	return rpcb_register_call((struct sockaddr *)&rpcb_inaddr_loopback,
-					sizeof(rpcb_inaddr_loopback),
-					RPCBVERS_4, msg);
+	return rpcb_register_call(RPCBVERS_4, msg);
 }
 
 /*
@@ -318,9 +309,7 @@ static int rpcb_register_netid6(struct sockaddr_in6 *address_to_register,
 	if (port)
 		msg->rpc_proc = &rpcb_procedures4[RPCBPROC_SET];
 
-	return rpcb_register_call((struct sockaddr *)&rpcb_in6addr_loopback,
-					sizeof(rpcb_in6addr_loopback),
-					RPCBVERS_4, msg);
+	return rpcb_register_call(RPCBVERS_4, msg);
 }
 
 /**

