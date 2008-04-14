From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 19/24] SUNRPC: Quickly detect missing portmapper during RPC
	service registration
Date: Mon, 14 Apr 2008 12:28:58 -0400
Message-ID: <20080414162858.12741.35946.stgit@manray.1015granger.net>
References: <20080414162108.12741.73233.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:53289 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762111AbYDNQ3Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Apr 2008 12:29:16 -0400
In-Reply-To: <20080414162108.12741.73233.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently the in-kernel RPC server uses an unconnected UDP socket to
contact the local user-space portmapper daemon because UDP is less
overhead than TCP.  However, attempting to register or unregister a
local RPC service with a portmapper that isn't listening for requests
results in a long timeout wait (35 seconds per request, by my
calculations).

Using TCP, the absence of a listener results in an immediate ECONNREFUSED.
Setting the ONESHOT flag causes the RPC client to fail RPC requests as soon
as this occurs.

Therefore, this patch changes rpcb_register() to use TCP to contact the
local portmapper.  Starting up in-kernel RPC services should no longer
hang if there is no local portmapper listening for requests.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   22 ++++++++++++++++++++--
 1 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index eb2bffe..4a85bf5 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -67,6 +67,12 @@ enum {
 #define RPCB_OWNER_STRING	"rpcb"
 #define RPCB_MAXOWNERLEN	sizeof(RPCB_OWNER_STRING)
 
+/*
+ * Number of seconds before timing out a registration request
+ * to our local user space rpcbind daemon.
+ */
+#define RPCB_REGISTER_TO_SECS	(10UL)
+
 static void			rpcb_getport_done(struct rpc_task *, void *);
 static struct rpc_program	rpcb_program;
 
@@ -118,14 +124,26 @@ static const struct sockaddr_in rpcb_inaddr_loopback = {
 	.sin_port		= htons(RPCBIND_PORT),
 };
 
+/*
+ * TCP is always used to contact the local rpcbind daemon because we
+ * get an immediate indication of whether there is a remote listener
+ * when a connection is attempted.
+ */
+static const struct rpc_timeout rpcb_local_tcp_timeout = {
+	.to_initval		= RPCB_REGISTER_TO_SECS * HZ,
+	.to_maxval		= RPCB_REGISTER_TO_SECS * HZ,
+	.to_retries		= 0,
+};
+
 static struct rpc_clnt *rpcb_create_local(struct sockaddr *addr,
 					  size_t addrlen, u32 version)
 {
 	struct rpc_create_args args = {
-		.protocol	= XPRT_TRANSPORT_UDP,
+		.protocol	= XPRT_TRANSPORT_TCP,
 		.address	= addr,
 		.addrsize	= addrlen,
 		.servername	= "localhost",
+		.timeout	= &rpcb_local_tcp_timeout,
 		.program	= &rpcb_program,
 		.version	= version,
 		.authflavor	= RPC_AUTH_UNIX,
@@ -175,7 +193,7 @@ static int rpcb_register_call(struct sockaddr *addr, size_t addrlen,
 
 	rpcb_clnt = rpcb_create_local(addr, addrlen, version);
 	if (!IS_ERR(rpcb_clnt)) {
-		error = rpc_call_sync(rpcb_clnt, msg, 0);
+		error = rpc_call_sync(rpcb_clnt, msg, RPC_TASK_ONESHOT);
 		rpc_shutdown_client(rpcb_clnt);
 	} else
 		error = PTR_ERR(rpcb_clnt);

