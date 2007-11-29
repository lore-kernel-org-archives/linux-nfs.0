From: Chuck Lever <chuck.lever@oracle.com>
Subject: [NFS] [PATCH 26/29] NFS: Support non-IPv4 addresses in
	nfs_parsed_mount_data
Date: Thu, 29 Nov 2007 14:42:12 -0500
Message-ID: <20071129194212.4170.64222.stgit@picasso.1015granger.net>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxpI0-0001n4-Qw
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:43:12 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxpI6-00006m-N8
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:43:19 -0800
In-Reply-To: <20071129193153.4170.29598.stgit-uiCyzNpeAnB9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Replace the nfs_server and mount_server address fields in the
nfs_parsed_mount_data structure with a "struct sockaddr_storage"
instead of a "struct sockaddr_in".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 fs/nfs/internal.h |    4 ++--
 fs/nfs/super.c    |   27 ++++++++++++++++-----------
 2 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 58c3a2a..b7b861a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -41,7 +41,7 @@ struct nfs_parsed_mount_data {
 	char			*client_address;
 
 	struct {
-		struct sockaddr_in	address;
+		struct sockaddr_storage	address;
 		char			*hostname;
 		unsigned int		version;
 		unsigned short		port;
@@ -49,7 +49,7 @@ struct nfs_parsed_mount_data {
 	} mount_server;
 
 	struct {
-		struct sockaddr_in	address;
+		struct sockaddr_storage	address;
 		char			*hostname;
 		char			*export_path;
 		int			protocol;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b6da80e..5ecbb67 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1044,10 +1044,11 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	/*
 	 * Construct the mount server's address.
 	 */
-	if (args->mount_server.address.sin_addr.s_addr != INADDR_ANY)
-		sin = args->mount_server.address;
+	if (args->mount_server.address.ss_family != AF_UNSPEC)
+		memcpy(&sin, &args->mount_server.address, sizeof(sin));
 	else
-		sin = args->nfs_server.address;
+		memcpy(&sin, &args->nfs_server.address, sizeof(sin));
+
 	/*
 	 * autobind will be used if mount_server.port == 0
 	 */
@@ -1141,9 +1142,6 @@ static int nfs_validate_mount_data(void *options,
 			memset(mntfh->data + mntfh->size, 0,
 			       sizeof(mntfh->data) - mntfh->size);
 
-		if (!nfs_verify_server_address((void *)&data->addr))
-			goto out_no_address;
-
 		/*
 		 * Translate to nfs_parsed_mount_data, which nfs_fill_super
 		 * can deal with.
@@ -1158,7 +1156,12 @@ static int nfs_validate_mount_data(void *options,
 		args->acregmax		= data->acregmax;
 		args->acdirmin		= data->acdirmin;
 		args->acdirmax		= data->acdirmax;
-		args->nfs_server.address = data->addr;
+
+		memcpy(&args->nfs_server.address, &data->addr,
+		       sizeof(data->addr));
+		if (!nfs_verify_server_address(&args->nfs_server.address))
+			goto out_no_address;
+
 		if (!(data->flags & NFS_MOUNT_TCP))
 			args->nfs_server.protocol = XPRT_TRANSPORT_UDP;
 		/* N.B. caller will free nfs_server.hostname in all cases */
@@ -1629,6 +1632,7 @@ static int nfs4_validate_mount_data(void *options,
 				    struct nfs_parsed_mount_data *args,
 				    const char *dev_name)
 {
+	struct sockaddr_in *ap;
 	struct nfs4_mount_data *data = (struct nfs4_mount_data *)options;
 	char *c;
 
@@ -1649,11 +1653,12 @@ static int nfs4_validate_mount_data(void *options,
 
 	switch (data->version) {
 	case 1:
-		if (data->host_addrlen != sizeof(args->nfs_server.address))
+		ap = (struct sockaddr_in *)&args->nfs_server.address;
+		if (data->host_addrlen > sizeof(args->nfs_server.address))
+			goto out_no_address;
+		if (data->host_addrlen == 0)
 			goto out_no_address;
-		if (copy_from_user(&args->nfs_server.address,
-				   data->host_addr,
-				   sizeof(args->nfs_server.address)))
+		if (copy_from_user(ap, data->host_addr, data->host_addrlen))
 			return -EFAULT;
 		if (!nfs_verify_server_address((void *)
 						&args->nfs_server.address))


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

