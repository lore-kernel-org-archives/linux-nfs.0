From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/18] NSM: move nsm_create()
Date: Wed, 05 Nov 2008 12:19:57 -0500
Message-ID: <20081105171957.6773.61681.stgit@ingres.1015granger.net>
References: <20081105171300.6773.40121.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:33984 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752674AbYKERU0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:20:26 -0500
In-Reply-To: <20081105171300.6773.40121.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: relocate nsm_create() to eliminate its forward declaration, and
move it next to the only function that uses it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   47 ++++++++++++++++++++++-------------------------
 1 files changed, 22 insertions(+), 25 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 3811485..9c9406d 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -18,8 +18,6 @@
 
 #define NLMDBG_FACILITY		NLMDBG_MONITOR
 
-static struct rpc_clnt *	nsm_create(void);
-
 static struct rpc_program	nsm_program;
 static				LIST_HEAD(nsm_handles);
 static				DEFINE_SPINLOCK(nsm_lock);
@@ -30,6 +28,28 @@ static				DEFINE_SPINLOCK(nsm_lock);
 int				nsm_local_state;
 
 /*
+ * Create NSM client for the local host
+ */
+static struct rpc_clnt *nsm_create(void)
+{
+	struct sockaddr_in	sin = {
+		.sin_family		= AF_INET,
+		.sin_addr.s_addr	= htonl(INADDR_LOOPBACK),
+	};
+	struct rpc_create_args args = {
+		.protocol		= XPRT_TRANSPORT_UDP,
+		.address		= (struct sockaddr *)&sin,
+		.addrsize		= sizeof(sin),
+		.servername		= "localhost",
+		.program		= &nsm_program,
+		.version		= SM_VERSION,
+		.authflavor		= RPC_AUTH_NULL,
+	};
+
+	return rpc_create(&args);
+}
+
+/*
  * Common procedure for SM_MON/SM_UNMON calls
  */
 static int
@@ -226,29 +246,6 @@ void nsm_release(struct nsm_handle *nsm)
 	kfree(nsm);
 }
 
-/*
- * Create NSM client for the local host
- */
-static struct rpc_clnt *
-nsm_create(void)
-{
-	struct sockaddr_in	sin = {
-		.sin_family	= AF_INET,
-		.sin_addr.s_addr = htonl(INADDR_LOOPBACK),
-		.sin_port	= 0,
-	};
-	struct rpc_create_args args = {
-		.protocol	= XPRT_TRANSPORT_UDP,
-		.address	= (struct sockaddr *)&sin,
-		.addrsize	= sizeof(sin),
-		.servername	= "localhost",
-		.program	= &nsm_program,
-		.version	= SM_VERSION,
-		.authflavor	= RPC_AUTH_NULL,
-	};
-
-	return rpc_create(&args);
-}
 
 /*
  * XDR functions for NSM.

