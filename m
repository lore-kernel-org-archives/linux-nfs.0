From: Chuck Lever <chuck.lever@oracle.com>
Subject: [NFS] [PATCH 19/29] NFS: Make nfs_alloc_client() take (sockaddr,
	len) instead of sockaddr_in
Date: Thu, 29 Nov 2007 14:41:34 -0500
Message-ID: <20071129194134.4170.39410.stgit@picasso.1015granger.net>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxpHZ-0001gI-Q9
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:42:46 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxpHf-0008KR-Po
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:42:51 -0800
In-Reply-To: <20071129193153.4170.29598.stgit-uiCyzNpeAnB9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

To support non-IPv4 addresses, adjust the arguments and callers of
nfs_alloc_client() to pass in a "struct sockaddr *" instead of a
"struct sockaddr_in *".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 fs/nfs/client.c |   18 +++++++++++++++---
 1 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 1bfbd4f..011f912 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -102,7 +102,7 @@ struct rpc_program		nfsacl_program = {
  * bother putting them in a slab cache...
  */
 static struct nfs_client *nfs_alloc_client(const char *hostname,
-					   const struct sockaddr_in *addr,
+					   const struct sockaddr *addr,
 					   unsigned int nfsversion)
 {
 	struct nfs_client *clp;
@@ -119,7 +119,17 @@ static struct nfs_client *nfs_alloc_client(const char *hostname,
 	atomic_set(&clp->cl_count, 1);
 	clp->cl_cons_state = NFS_CS_INITING;
 
-	memcpy(&clp->cl_addr, addr, sizeof(*addr));
+	switch (addr->sa_family) {
+	case AF_INET:
+		memcpy(&clp->cl_addr, addr, sizeof(struct sockaddr_in));
+		break;
+	case AF_INET6:
+		memcpy(&clp->cl_addr, addr, sizeof(struct sockaddr_in6));
+		break;
+	default:
+		printk(KERN_ERR "NFS: server address family not supported\n");
+		goto error_2;
+	}
 
 	if (hostname) {
 		clp->cl_hostname = kstrdup(hostname, GFP_KERNEL);
@@ -306,7 +316,9 @@ static struct nfs_client *nfs_get_client(const char *hostname,
 
 		spin_unlock(&nfs_client_lock);
 
-		new = nfs_alloc_client(hostname, addr, nfsversion);
+		new = nfs_alloc_client(hostname,
+				       (const void *)addr,
+				       nfsversion);
 	} while (new);
 
 	return ERR_PTR(-ENOMEM);


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

