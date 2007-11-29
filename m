From: Chuck Lever <chuck.lever@oracle.com>
Subject: [NFS] [PATCH 13/29] NFS: Make setting a port number agostic
Date: Thu, 29 Nov 2007 14:41:02 -0500
Message-ID: <20071129194102.4170.56993.stgit@picasso.1015granger.net>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxpGj-0001WN-7f
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:41:53 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxpGo-0002QL-8f
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:41:59 -0800
In-Reply-To: <20071129193153.4170.29598.stgit-uiCyzNpeAnB9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

We'll need to set the port number of an AF_INET or AF_INET6 address in
several places in fs/nfs/super.c, so introduce a helper that can manage
this for us.  We put this helper to immediate use.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   26 ++++++++++++++++++++++++--
 1 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ed0b5f1..6377098 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -576,6 +576,25 @@ static void nfs_umount_begin(struct vfsmount *vfsmnt, int flags)
 }
 
 /*
+ * Set the port number in an address.  Be agnostic about the address family.
+ */
+static void nfs_set_port(struct sockaddr *sap, unsigned short port)
+{
+	switch (sap->sa_family) {
+	case AF_INET: {
+		struct sockaddr_in *ap = (struct sockaddr_in *)sap;
+		ap->sin_port = htons(port);
+		break;
+	}
+	case AF_INET6: {
+		struct sockaddr_in6 *ap = (struct sockaddr_in6 *)sap;
+		ap->sin6_port = htons(port);
+		break;
+	}
+	}
+}
+
+/*
  * Sanity-check a server address provided by the mount command.
  *
  * Address family must be initialized, and address must not be
@@ -605,6 +624,7 @@ static int nfs_parse_mount_options(char *raw,
 				   struct nfs_parsed_mount_data *mnt)
 {
 	char *p, *string;
+	unsigned short port = 0;
 
 	if (!raw) {
 		dfprintk(MOUNT, "NFS: mount options string was NULL.\n");
@@ -707,7 +727,7 @@ static int nfs_parse_mount_options(char *raw,
 				return 0;
 			if (option < 0 || option > 65535)
 				return 0;
-			mnt->nfs_server.address.sin_port = htons(option);
+			port = option;
 			break;
 		case Opt_rsize:
 			if (match_int(args, &mnt->rsize))
@@ -949,6 +969,8 @@ static int nfs_parse_mount_options(char *raw,
 		}
 	}
 
+	nfs_set_port((struct sockaddr *)&mnt->nfs_server.address, port);
+
 	return 1;
 
 out_nomem:
@@ -999,7 +1021,7 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	/*
 	 * autobind will be used if mount_server.port == 0
 	 */
-	sin.sin_port = htons(args->mount_server.port);
+	nfs_set_port((void *)&sin, args->mount_server.port);
 
 	/*
 	 * Now ask the mount server to map our export path


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

