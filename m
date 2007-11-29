From: Chuck Lever <chuck.lever@oracle.com>
Subject: [NFS] [PATCH 16/29] NFS: Expand server address storage in
	nfs_client struct
Date: Thu, 29 Nov 2007 14:41:18 -0500
Message-ID: <20071129194118.4170.12851.stgit@picasso.1015granger.net>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxpGy-0001cj-4l
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:42:08 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxpH4-0002Zx-2w
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:42:14 -0800
In-Reply-To: <20071129193153.4170.29598.stgit-uiCyzNpeAnB9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Prepare for managing larger addresses in the NFS client by widening the
nfs_client struct's cl_addr field.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 fs/nfs/client.c           |    3 +--
 fs/nfs/super.c            |    4 ++--
 include/linux/nfs_fs_sb.h |    2 +-
 3 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index e974372..1bfbd4f 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -119,7 +119,7 @@ static struct nfs_client *nfs_alloc_client(const char *hostname,
 	atomic_set(&clp->cl_count, 1);
 	clp->cl_cons_state = NFS_CS_INITING;
 
-	memcpy(&clp->cl_addr, addr, sizeof(clp->cl_addr));
+	memcpy(&clp->cl_addr, addr, sizeof(*addr));
 
 	if (hostname) {
 		clp->cl_hostname = kstrdup(hostname, GFP_KERNEL);
@@ -404,7 +404,6 @@ static int nfs_create_rpc_client(struct nfs_client *clp, int proto,
 	struct rpc_create_args args = {
 		.protocol	= proto,
 		.address	= (struct sockaddr *)&clp->cl_addr,
-		.addrsize	= sizeof(clp->cl_addr),
 		.timeout	= &timeparms,
 		.servername	= clp->cl_hostname,
 		.program	= &nfs_program,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 6a9192f..dde6e3f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1334,8 +1334,8 @@ static int nfs_set_super(struct super_block *s, void *data)
 static int nfs_compare_super_address(struct nfs_server *server1,
 				     struct nfs_server *server2)
 {
-	struct sockaddr_storage *ssp1 = (void *)&server1->nfs_client->cl_addr;
-	struct sockaddr_storage *ssp2 = (void *)&server2->nfs_client->cl_addr;
+	struct sockaddr_storage *ssp1 = &server1->nfs_client->cl_addr;
+	struct sockaddr_storage *ssp2 = &server2->nfs_client->cl_addr;
 
 	if (ssp1->ss_family != ssp2->ss_family)
 		return 0;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index c64773f..b8f6688 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -20,7 +20,7 @@ struct nfs_client {
 #define NFS_CS_IDMAP		2		/* - idmap started */
 #define NFS_CS_RENEWD		3		/* - renewd started */
 
-	struct sockaddr_in	cl_addr;	/* server identifier */
+	struct sockaddr_storage	cl_addr;	/* server identifier */
 	char *			cl_hostname;	/* hostname of server */
 	struct list_head	cl_share_link;	/* link in global client list */
 	struct list_head	cl_superblocks;	/* List of nfs_server structs */


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

