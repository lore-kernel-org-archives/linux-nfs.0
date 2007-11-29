From: Chuck Lever <chuck.lever@oracle.com>
Subject: [NFS] [PATCH 20/29] NFS: Change nfs_find_client() to take "struct
	sockaddr	*"
Date: Thu, 29 Nov 2007 14:41:40 -0500
Message-ID: <20071129194139.4170.85279.stgit@picasso.1015granger.net>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxpHJ-0001eg-EG
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:42:29 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxpHO-0002iY-EL
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:42:35 -0800
In-Reply-To: <20071129193153.4170.29598.stgit-uiCyzNpeAnB9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Adjust arguments and callers of nfs_find_client() to pass a
"struct sockaddr *" instead of "struct sockaddr_in *" to support non-IPv4
addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 fs/nfs/callback.c      |    3 +--
 fs/nfs/callback_proc.c |    4 ++--
 fs/nfs/client.c        |    4 ++--
 fs/nfs/internal.h      |    2 +-
 4 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index bbf67f1..9b6bbf1 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -164,12 +164,11 @@ void nfs_callback_down(void)
 
 static int nfs_callback_authenticate(struct svc_rqst *rqstp)
 {
-	struct sockaddr_in *addr = svc_addr_in(rqstp);
 	struct nfs_client *clp;
 	char buf[RPC_MAX_ADDRBUFLEN];
 
 	/* Don't talk to strangers */
-	clp = nfs_find_client(addr, 4);
+	clp = nfs_find_client(svc_addr(rqstp), 4);
 	if (clp == NULL)
 		return SVC_DROP;
 
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index a555e8a..e89a900 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -25,7 +25,7 @@ __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *
 
 	res->bitmap[0] = res->bitmap[1] = 0;
 	res->status = htonl(NFS4ERR_BADHANDLE);
-	clp = nfs_find_client((void *)args->addr, 4);
+	clp = nfs_find_client(args->addr, 4);
 	if (clp == NULL)
 		goto out;
 
@@ -68,7 +68,7 @@ __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy)
 	__be32 res;
 	
 	res = htonl(NFS4ERR_BADHANDLE);
-	clp = nfs_find_client((void *)args->addr, 4);
+	clp = nfs_find_client(args->addr, 4);
 	if (clp == NULL)
 		goto out;
 
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 011f912..d1f4ce2 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -274,13 +274,13 @@ found:
  * Find a client by IP address and protocol version
  * - returns NULL if no such client
  */
-struct nfs_client *nfs_find_client(const struct sockaddr_in *addr,
+struct nfs_client *nfs_find_client(const struct sockaddr *addr,
 				   unsigned int nfsversion)
 {
 	struct nfs_client *clp;
 
 	spin_lock(&nfs_client_lock);
-	clp = __nfs_find_client((void *)addr, nfsversion, 0);
+	clp = __nfs_find_client(addr, nfsversion, 0);
 	spin_unlock(&nfs_client_lock);
 	if (clp != NULL && clp->cl_cons_state != NFS_CS_READY) {
 		nfs_put_client(clp);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index c065dc3..8b96364 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -61,7 +61,7 @@ extern struct rpc_program nfs_program;
 
 extern void nfs_put_client(struct nfs_client *);
 extern struct nfs_client *nfs_find_client(
-					const struct sockaddr_in *,
+					const struct sockaddr *,
 					unsigned int);
 extern struct nfs_server *nfs_create_server(
 					const struct nfs_parsed_mount_data *,


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

