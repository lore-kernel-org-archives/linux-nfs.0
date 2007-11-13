From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 19/25] NFS: Make setting a port number agostic
Date: Tue, 13 Nov 2007 13:32:41 -0500
Message-ID: <20071113183240.5087.90678.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is0Yz-0000Wj-Ib
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:32:41 -0800
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Is0Z5-00076B-An
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:32:47 -0800
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

We'll need to set the port number of an AF_INET or AF_INET6 address in
several places in fs/nfs/super.c, so introduce a helper that can manage
this for us.  We put this helper to immediate use.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   34 ++++++++++++++++++++++++++++++++--
 1 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 262adb4..7dc56ce 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -45,6 +45,7 @@
 #include <linux/nfs_idmap.h>
 #include <linux/vfs.h>
 #include <linux/inet.h>
+#include <linux/in6.h>
 #include <linux/nfs_xdr.h>
 #include <linux/magic.h>
 #include <linux/parser.h>
@@ -574,6 +575,28 @@ static void nfs_umount_begin(struct vfsmount *vfsmnt, int flags)
 }
 
 /*
+ * Set the port number in an address.  Be agnostic about the address family.
+ */
+static int nfs_set_address_port(struct sockaddr *sap, unsigned short port)
+{
+	switch (sap->sa_family) {
+	case AF_INET: {
+		struct sockaddr_in *ap = (struct sockaddr_in *)sap;
+		ap->sin_port = htons(port);
+		return 0;
+	}
+	case AF_INET6: {
+		struct sockaddr_in6 *ap = (struct sockaddr_in6 *)sap;
+		ap->sin6_port = htons(port);
+		return 0;
+	}
+	default:
+		dfprintk(MOUNT, "NFS: unrecognized address family\n");
+		return -EAFNOSUPPORT;
+	}
+}
+
+/*
  * Sanity-check a server address provided by the mount command
  */
 static int nfs_verify_server_address(struct sockaddr *addr)
@@ -691,6 +714,7 @@ static int nfs_parse_mount_options(char *raw,
 				   struct nfs_parsed_mount_data *mnt)
 {
 	char *p, *string;
+	unsigned short port = 0;
 
 	if (!raw) {
 		dfprintk(MOUNT, "NFS: mount options string was NULL.\n");
@@ -793,7 +817,7 @@ static int nfs_parse_mount_options(char *raw,
 				return 0;
 			if (option < 0 || option > 65535)
 				return 0;
-			mnt->nfs_server.address.sin_port = htons(option);
+			port = option;
 			break;
 		case Opt_rsize:
 			if (match_int(args, &mnt->rsize))
@@ -978,6 +1002,10 @@ static int nfs_parse_mount_options(char *raw,
 		}
 	}
 
+	if (nfs_set_address_port((struct sockaddr *)
+				 &mnt->nfs_server.address, port))
+		return 0;
+
 	return 1;
 
 out_nomem:
@@ -1030,7 +1058,9 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	/*
 	 * autobind will be used if mount_server.port == 0
 	 */
-	sin.sin_port = htons(args->mount_server.port);
+	if (nfs_set_address_port((struct sockaddr *)&sin,
+					args->mount_server.port))
+		return -EAFNOSUPPORT;
 
 	/*
 	 * Now ask the mount server to map our export path


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
