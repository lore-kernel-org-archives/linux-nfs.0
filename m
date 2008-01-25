From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 060/112] NFS: Move dprintks from callback.c to
	callback_proc.c
Date: Fri, 25 Jan 2008 11:37:43 -0500
Message-ID: <20080125163743.31887.95211.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14407 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755755AbYAYRAX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:23 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0Lme010494
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:21 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: The client side peer address is available in callback_proc.c,
so move a dprintk out of fs/nfs/callback.c and into
fs/nfs/callback_proc.c.

This is more consistent with other debugging messages, and the proc
routines have more information about each request to display.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/callback.c      |    4 ----
 fs/nfs/callback_proc.c |   12 +++++++++++-
 2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index a796be5..bbf67f1 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -73,8 +73,6 @@ static void nfs_callback_svc(struct svc_rqst *rqstp)
 	complete(&nfs_callback_info.started);
 
 	for(;;) {
-		char buf[RPC_MAX_ADDRBUFLEN];
-
 		if (signalled()) {
 			if (nfs_callback_info.users == 0)
 				break;
@@ -92,8 +90,6 @@ static void nfs_callback_svc(struct svc_rqst *rqstp)
 					__FUNCTION__, -err);
 			break;
 		}
-		dprintk("%s: request from %s\n", __FUNCTION__,
-				svc_print_addr(rqstp, buf, sizeof(buf)));
 		svc_process(rqstp);
 	}
 
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 72e55d8..e89a900 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -12,7 +12,9 @@
 #include "delegation.h"
 #include "internal.h"
 
+#ifdef NFS_DEBUG
 #define NFSDBG_FACILITY NFSDBG_CALLBACK
+#endif
  
 __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *res)
 {
@@ -20,12 +22,16 @@ __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *
 	struct nfs_delegation *delegation;
 	struct nfs_inode *nfsi;
 	struct inode *inode;
-	
+
 	res->bitmap[0] = res->bitmap[1] = 0;
 	res->status = htonl(NFS4ERR_BADHANDLE);
 	clp = nfs_find_client(args->addr, 4);
 	if (clp == NULL)
 		goto out;
+
+	dprintk("NFS: GETATTR callback request from %s\n",
+		rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR));
+
 	inode = nfs_delegation_find_inode(clp, &args->fh);
 	if (inode == NULL)
 		goto out_putclient;
@@ -65,6 +71,10 @@ __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy)
 	clp = nfs_find_client(args->addr, 4);
 	if (clp == NULL)
 		goto out;
+
+	dprintk("NFS: RECALL callback request from %s\n",
+		rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR));
+
 	inode = nfs_delegation_find_inode(clp, &args->fh);
 	if (inode == NULL)
 		goto out_putclient;
