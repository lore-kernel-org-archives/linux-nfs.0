Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:49542 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755416Ab1CVWJk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2011 18:09:40 -0400
Received: by mail-iy0-f174.google.com with SMTP id 26so7900353iyb.19
        for <linux-nfs@vger.kernel.org>; Tue, 22 Mar 2011 15:09:40 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] SUNRPC: Use AF_LOCAL for rpcbind upcalls
To: linux-nfs@vger.kernel.org
Date: Tue, 22 Mar 2011 18:09:37 -0400
Message-ID: <20110322220937.4360.83159.stgit@matisse.1015granger.net>
In-Reply-To: <20110322220518.4360.51304.stgit@matisse.1015granger.net>
References: <20110322220518.4360.51304.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

As libtirpc does in user space, have our registration API try using an
AF_LOCAL transport first when registering and unregistering.

This means we don't chew up privileged ports, and our registration is
bound to an "owner" (the effective uid of the process on the sending
end of the transport).  Only that "owner" may unregister the service.

The kernel could probe rpcbind via an rpcbind query to determine
whether rpcbind has an AF_LOCAL service. For simplicity, we use the
same technique that libtirpc uses: simply fail over to network
loopback if creating an AF_LOCAL transport to the well-known rpcbind
service socket fails.

This means we open-code the pathname of the rpcbind socket in the
kernel.  For now we have to do that anyway because the kernel's
RPC over AF_LOCAL implementation does not support autobind.  That may
be undesirable in the long term.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   97 +++++++++++++++++++++++++++++++++++++++++-------
 net/sunrpc/svc.c       |    2 +
 2 files changed, 85 insertions(+), 14 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 770e5b6..7654651 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -16,6 +16,7 @@
 
 #include <linux/types.h>
 #include <linux/socket.h>
+#include <linux/un.h>
 #include <linux/in.h>
 #include <linux/in6.h>
 #include <linux/kernel.h>
@@ -32,6 +33,8 @@
 # define RPCDBG_FACILITY	RPCDBG_BIND
 #endif
 
+#define RPCBIND_SOCK_PATHNAME	"/var/run/rpcbind.sock"
+
 #define RPCBIND_PROGRAM		(100000u)
 #define RPCBIND_PORT		(111u)
 
@@ -158,20 +161,69 @@ static void rpcb_map_release(void *data)
 	kfree(map);
 }
 
-static const struct sockaddr_in rpcb_inaddr_loopback = {
-	.sin_family		= AF_INET,
-	.sin_addr.s_addr	= htonl(INADDR_LOOPBACK),
-	.sin_port		= htons(RPCBIND_PORT),
-};
+/*
+ * Returns zero on success, otherwise a negative errno value
+ * is returned.
+ */
+static int rpcb_create_local_unix(void)
+{
+	static const struct sockaddr_un rpcb_localaddr_rpcbind = {
+		.sun_family		= AF_LOCAL,
+		.sun_path		= RPCBIND_SOCK_PATHNAME,
+	};
+	struct rpc_create_args args = {
+		.net		= &init_net,
+		.protocol	= XPRT_TRANSPORT_LOCAL,
+		.address	= (struct sockaddr *)&rpcb_localaddr_rpcbind,
+		.addrsize	= sizeof(rpcb_localaddr_rpcbind),
+		.servername	= "localhost",
+		.program	= &rpcb_program,
+		.version	= RPCBVERS_2,
+		.authflavor	= RPC_AUTH_NULL,
+	};
+	struct rpc_clnt *clnt, *clnt4;
+	int result = 0;
+
+	/*
+	 * Because we requested an RPC PING at transport creation time,
+	 * this works only if the user space portmapper is rpcbind, and
+	 * it's listening on AF_LOCAL on the named socket.
+	 */
+	clnt = rpc_create(&args);
+	if (IS_ERR(clnt)) {
+		dprintk("RPC:       failed to create AF_LOCAL rpcbind "
+				"client (errno %ld).\n", PTR_ERR(clnt));
+		result = -PTR_ERR(clnt);
+		goto out;
+	}
+
+	clnt4 = rpc_bind_new_program(clnt, &rpcb_program, RPCBVERS_4);
+	if (IS_ERR(clnt4)) {
+		dprintk("RPC:       failed to bind second program to "
+				"rpcbind v4 client (errno %ld).\n",
+				PTR_ERR(clnt4));
+		clnt4 = NULL;
+	}
+
+	/* Protected by rpcb_create_local_mutex */
+	rpcb_local_clnt = clnt;
+	rpcb_local_clnt4 = clnt4;
 
-static DEFINE_MUTEX(rpcb_create_local_mutex);
+out:
+	return result;
+}
 
 /*
  * Returns zero on success, otherwise a negative errno value
  * is returned.
  */
-static int rpcb_create_local(void)
+static int rpcb_create_local_net(void)
 {
+	static const struct sockaddr_in rpcb_inaddr_loopback = {
+		.sin_family		= AF_INET,
+		.sin_addr.s_addr	= htonl(INADDR_LOOPBACK),
+		.sin_port		= htons(RPCBIND_PORT),
+	};
 	struct rpc_create_args args = {
 		.net		= &init_net,
 		.protocol	= XPRT_TRANSPORT_TCP,
@@ -186,13 +238,6 @@ static int rpcb_create_local(void)
 	struct rpc_clnt *clnt, *clnt4;
 	int result = 0;
 
-	if (rpcb_local_clnt)
-		return result;
-
-	mutex_lock(&rpcb_create_local_mutex);
-	if (rpcb_local_clnt)
-		goto out;
-
 	clnt = rpc_create(&args);
 	if (IS_ERR(clnt)) {
 		dprintk("RPC:       failed to create local rpcbind "
@@ -214,10 +259,34 @@ static int rpcb_create_local(void)
 		clnt4 = NULL;
 	}
 
+	/* Protected by rpcb_create_local_mutex */
 	rpcb_local_clnt = clnt;
 	rpcb_local_clnt4 = clnt4;
 
 out:
+	return result;
+}
+
+/*
+ * Returns zero on success, otherwise a negative errno value
+ * is returned.
+ */
+static int rpcb_create_local(void)
+{
+	static DEFINE_MUTEX(rpcb_create_local_mutex);
+	int result = 0;
+
+	if (rpcb_local_clnt)
+		return result;
+
+	mutex_lock(&rpcb_create_local_mutex);
+	if (rpcb_local_clnt)
+		goto out;
+
+	if (rpcb_create_local_unix() != 0)
+		result = rpcb_create_local_net();
+
+out:
 	mutex_unlock(&rpcb_create_local_mutex);
 	return result;
 }
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 08e05a8..2b90292 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -942,6 +942,8 @@ static void svc_unregister(const struct svc_serv *serv)
 			if (progp->pg_vers[i]->vs_hidden)
 				continue;
 
+			dprintk("svc: attempting to unregister %sv%u\n",
+				progp->pg_name, i);
 			__svc_unregister(progp->pg_prog, i, progp->pg_name);
 		}
 	}

