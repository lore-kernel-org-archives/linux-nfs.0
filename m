From: Chuck Lever <chuck.lever@oracle.com>
Subject: [NFS] [PATCH 21/29] NFS: Change nfs_get_client() to take sockaddr *
Date: Thu, 29 Nov 2007 14:41:45 -0500
Message-ID: <20071129194145.4170.27778.stgit@picasso.1015granger.net>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxpHM-0001ew-81
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:42:32 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxpHQ-0008FX-86
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:42:38 -0800
In-Reply-To: <20071129193153.4170.29598.stgit-uiCyzNpeAnB9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Adjust arguments and callers of nfs_get_client() to pass a
"struct sockaddr *" instead of "struct sockaddr_in *" to support
non-IPv4 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 fs/nfs/client.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index d1f4ce2..dc69d88 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -294,21 +294,20 @@ struct nfs_client *nfs_find_client(const struct sockaddr *addr,
  * - creates a new record if one doesn't yet exist
  */
 static struct nfs_client *nfs_get_client(const char *hostname,
-					 const struct sockaddr_in *addr,
+					 const struct sockaddr *addr,
 					 unsigned int nfsversion)
 {
 	struct nfs_client *clp, *new = NULL;
 	int error;
 
-	dprintk("--> nfs_get_client(%s,"NIPQUAD_FMT":%d,%u)\n",
-		hostname ?: "", NIPQUAD(addr->sin_addr),
-		addr->sin_port, nfsversion);
+	dprintk("--> nfs_get_client(%s,v%u)\n",
+		hostname ?: "", nfsversion);
 
 	/* see if the client already exists */
 	do {
 		spin_lock(&nfs_client_lock);
 
-		clp = __nfs_find_client((void *)addr, nfsversion, 1);
+		clp = __nfs_find_client(addr, nfsversion, 1);
 		if (clp)
 			goto found_client;
 		if (new)
@@ -316,9 +315,7 @@ static struct nfs_client *nfs_get_client(const char *hostname,
 
 		spin_unlock(&nfs_client_lock);
 
-		new = nfs_alloc_client(hostname,
-				       (const void *)addr,
-				       nfsversion);
+		new = nfs_alloc_client(hostname, addr, nfsversion);
 	} while (new);
 
 	return ERR_PTR(-ENOMEM);
@@ -593,7 +590,8 @@ static int nfs_init_server(struct nfs_server *server,
 
 	/* Allocate or find a client reference we can use */
 	clp = nfs_get_client(data->nfs_server.hostname,
-				&data->nfs_server.address, nfsvers);
+			     (struct sockaddr *)&data->nfs_server.address,
+			     nfsvers);
 	if (IS_ERR(clp)) {
 		dprintk("<-- nfs_init_server() = error %ld\n", PTR_ERR(clp));
 		return PTR_ERR(clp);
@@ -930,7 +928,7 @@ static int nfs4_set_client(struct nfs_server *server,
 	dprintk("--> nfs4_set_client()\n");
 
 	/* Allocate or find a client reference we can use */
-	clp = nfs_get_client(hostname, addr, 4);
+	clp = nfs_get_client(hostname, (void *)addr, 4);
 	if (IS_ERR(clp)) {
 		error = PTR_ERR(clp);
 		goto error;


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

