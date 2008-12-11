From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/11] NSM: Move nsm_create()
Date: Thu, 11 Dec 2008 17:56:37 -0500
Message-ID: <20081211225636.21468.36639.stgit@ingres.1015granger.net>
References: <20081211224543.21468.8939.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:40068 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759017AbYLKW4z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Dec 2008 17:56:55 -0500
In-Reply-To: <20081211224543.21468.8939.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: one last thing... relocate nsm_create() to eliminate the forward
declaration and group it near the only function that actually uses it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   51 ++++++++++++++++++++-------------------------------
 1 files changed, 20 insertions(+), 31 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index cd8db11..0027843 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -44,8 +44,6 @@ struct nsm_res {
 	u32			state;
 };
 
-static struct rpc_clnt *	nsm_create(void);
-
 static struct rpc_program	nsm_program;
 static				LIST_HEAD(nsm_handles);
 static				DEFINE_SPINLOCK(nsm_lock);
@@ -99,11 +97,26 @@ static void nsm_display_address(const struct sockaddr *sap,
 	}
 }
 
-/*
- * Common procedure for NSMPROC_MON/NSMPROC_UNMON calls
- */
-static int
-nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
+static struct rpc_clnt *nsm_create(void)
+{
+	struct sockaddr_in sin = {
+		.sin_family		= AF_INET,
+		.sin_addr.s_addr	= htonl(INADDR_LOOPBACK),
+	};
+	struct rpc_create_args args = {
+		.protocol		= XPRT_TRANSPORT_UDP,
+		.address		= (struct sockaddr *)&sin,
+		.addrsize		= sizeof(sin),
+		.servername		= "rpc.statd",
+		.program		= &nsm_program,
+		.version		= NSM_VERSION,
+		.authflavor		= RPC_AUTH_NULL,
+	};
+
+	return rpc_create(&args);
+}
+
+static int nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 {
 	struct rpc_clnt	*clnt;
 	int		status;
@@ -410,30 +423,6 @@ void nsm_release(struct nsm_handle *nsm)
 }
 
 /*
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
-		.version	= NSM_VERSION,
-		.authflavor	= RPC_AUTH_NULL,
-	};
-
-	return rpc_create(&args);
-}
-
-/*
  * XDR functions for NSM.
  *
  * See http://www.opengroup.org/ for details on the Network

