From: Chuck Lever <chuck.lever@oracle.com>
Subject: [NFS] [PATCH 27/29] NFS: Add AF_INET6 support to nfs_try_mount()
Date: Thu, 29 Nov 2007 14:42:17 -0500
Message-ID: <20071129194217.4170.51672.stgit@picasso.1015granger.net>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxpHt-0001mD-NW
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:43:05 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxpHx-0002zp-Ms
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:43:11 -0800
In-Reply-To: <20071129193153.4170.29598.stgit-uiCyzNpeAnB9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Update nfs_try_mount() to support AF_INET6 family addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   15 ++++++---------
 1 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 5ecbb67..7c10189 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1025,7 +1025,7 @@ out_unknown:
 static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 			 struct nfs_fh *root_fh)
 {
-	struct sockaddr_in sin;
+	struct sockaddr *sap = (struct sockaddr *)&args->mount_server.address;
 	int status;
 	char *hostname;
 
@@ -1044,23 +1044,20 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	/*
 	 * Construct the mount server's address.
 	 */
-	if (args->mount_server.address.ss_family != AF_UNSPEC)
-		memcpy(&sin, &args->mount_server.address, sizeof(sin));
-	else
-		memcpy(&sin, &args->nfs_server.address, sizeof(sin));
+	if (args->mount_server.address.ss_family == AF_UNSPEC)
+		memcpy(sap, &args->nfs_server.address,
+		       sizeof(struct sockaddr_in6));
 
 	/*
 	 * autobind will be used if mount_server.port == 0
 	 */
-	nfs_set_port((void *)&sin, args->mount_server.port);
+	nfs_set_port(sap, args->mount_server.port);
 
 	/*
 	 * Now ask the mount server to map our export path
 	 * to a file handle.
 	 */
-	status = nfs_mount((struct sockaddr *) &sin,
-			   sizeof(sin),
-			   hostname,
+	status = nfs_mount(sap, 0, hostname,
 			   args->nfs_server.export_path,
 			   args->mount_server.version,
 			   args->mount_server.protocol,


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

