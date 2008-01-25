From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 064/112] NFS: Make setting a port number agostic
Date: Fri, 25 Jan 2008 11:37:45 -0500
Message-ID: <20080125163744.31887.97533.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14355 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755010AbYAYQ75 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:57 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxseU010226
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:56 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

We'll need to set the port number of an AF_INET or AF_INET6 address in
several places in fs/nfs/super.c, so introduce a helper that can manage
this for us.  We put this helper to immediate use.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |   26 ++++++++++++++++++++++++--
 1 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 038b20b..ef1aad7 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -600,6 +600,25 @@ static void nfs_umount_begin(struct vfsmount *vfsmnt, int flags)
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
@@ -629,6 +648,7 @@ static int nfs_parse_mount_options(char *raw,
 				   struct nfs_parsed_mount_data *mnt)
 {
 	char *p, *string;
+	unsigned short port = 0;
 
 	if (!raw) {
 		dfprintk(MOUNT, "NFS: mount options string was NULL.\n");
@@ -731,7 +751,7 @@ static int nfs_parse_mount_options(char *raw,
 				return 0;
 			if (option < 0 || option > 65535)
 				return 0;
-			mnt->nfs_server.address.sin_port = htons(option);
+			port = option;
 			break;
 		case Opt_rsize:
 			if (match_int(args, &mnt->rsize))
@@ -973,6 +993,8 @@ static int nfs_parse_mount_options(char *raw,
 		}
 	}
 
+	nfs_set_port((struct sockaddr *)&mnt->nfs_server.address, port);
+
 	return 1;
 
 out_nomem:
@@ -1023,7 +1045,7 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	/*
 	 * autobind will be used if mount_server.port == 0
 	 */
-	sin.sin_port = htons(args->mount_server.port);
+	nfs_set_port((struct sockaddr *)&sin, args->mount_server.port);
 
 	/*
 	 * Now ask the mount server to map our export path
