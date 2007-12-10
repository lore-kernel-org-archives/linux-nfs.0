From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/27] NFS: Make setting a port number agostic
Date: Mon, 10 Dec 2007 14:57:53 -0500
Message-ID: <20071210195753.2823.51809.stgit@manray.1015granger.net>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:41490 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757501AbXLJUFd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:05:33 -0500
In-Reply-To: <20071210195106.2823.43884.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We'll need to set the port number of an AF_INET or AF_INET6 address in
several places in fs/nfs/super.c, so introduce a helper that can manage
this for us.  We put this helper to immediate use.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   26 ++++++++++++++++++++++++--
 1 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 8bbdb85..71eb5bc 100644
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
+	nfs_set_port((struct sockaddr *)&sin, args->mount_server.port);
 
 	/*
 	 * Now ask the mount server to map our export path

