From: Chuck Lever <chuck.lever@oracle.com>
Subject: [NFS] [PATCH 09/29] NFS: Clean-up: move dprintks from callback.c
	to	callback_proc.c
Date: Thu, 29 Nov 2007 14:40:40 -0500
Message-ID: <20071129194040.4170.77111.stgit@picasso.1015granger.net>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxpGV-0001VZ-6w
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:41:39 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxpGa-0002LS-4A
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:41:45 -0800
In-Reply-To: <20071129193153.4170.29598.stgit-uiCyzNpeAnB9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

The client side peer address is available in callback_proc.c, so move
a dprintk out of fs/nfs/callback.c and into fs/nfs/callback_proc.c.

This is more consistent with other debugging messages, and the proc
routines have more information about each request to display.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
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


-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

