From: Chuck Lever <chuck.lever@oracle.com>
Subject: [NFS] [PATCH 22/29] NFS: Change nfs4_set_client() to accept struct
	sockaddr	*
Date: Thu, 29 Nov 2007 14:41:50 -0500
Message-ID: <20071129194150.4170.84402.stgit@picasso.1015granger.net>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxpHW-0001fy-6M
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:42:42 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxpHa-0008IX-6J
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:42:48 -0800
In-Reply-To: <20071129193153.4170.29598.stgit-uiCyzNpeAnB9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Adjust the arguments and callers of nfs4_set_client() to pass a "struct
sockaddr *" instead of a "struct sockaddr_in *" to support non-IPv4
addresses in the NFS client.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 fs/nfs/client.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index dc69d88..346e4ca 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -917,7 +917,8 @@ error:
  * Set up an NFS4 client
  */
 static int nfs4_set_client(struct nfs_server *server,
-		const char *hostname, const struct sockaddr_in *addr,
+		const char *hostname,
+		const struct sockaddr *addr,
 		const char *ip_addr,
 		rpc_authflavor_t authflavour,
 		int proto, int timeo, int retrans)
@@ -928,7 +929,7 @@ static int nfs4_set_client(struct nfs_server *server,
 	dprintk("--> nfs4_set_client()\n");
 
 	/* Allocate or find a client reference we can use */
-	clp = nfs_get_client(hostname, (void *)addr, 4);
+	clp = nfs_get_client(hostname, addr, 4);
 	if (IS_ERR(clp)) {
 		error = PTR_ERR(clp);
 		goto error;
@@ -999,7 +1000,7 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 	/* Get a client record */
 	error = nfs4_set_client(server,
 			data->nfs_server.hostname,
-			&data->nfs_server.address,
+			(struct sockaddr *)&data->nfs_server.address,
 			data->client_address,
 			data->auth_flavors[0],
 			data->nfs_server.protocol,
@@ -1074,7 +1075,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 
 	/* Get a client representation.
 	 * Note: NFSv4 always uses TCP, */
-	error = nfs4_set_client(server, data->hostname, data->addr,
+	error = nfs4_set_client(server, data->hostname, (void *)data->addr,
 			parent_client->cl_ipaddr,
 			data->authflavor,
 			parent_server->client->cl_xprt->prot,


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

