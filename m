From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 31/33] NFS - fix potential NULL pointer dereference v2
Date: Sat, 19 Apr 2008 16:40:55 -0400
Message-ID: <20080419204054.14124.59641.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Cyrill Gorcunov <gorcunov@gmail.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53673 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756683AbYDSUuh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:37 -0400
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Cyrill Gorcunov <gorcunov@gmail.com>

There is possible NULL pointer dereference if kstr[n]dup failed.
So fix them for safety.

Signed-off-by: Cyrill Gorcunov <gorcunov@gmail.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 140174d..7c13ce7 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1295,6 +1295,8 @@ static int nfs_validate_mount_data(void *options,
 		args->namlen		= data->namlen;
 		args->bsize		= data->bsize;
 		args->auth_flavors[0]	= data->pseudoflavor;
+		if (!args->nfs_server.hostname)
+			goto out_nomem;
 
 		/*
 		 * The legacy version 6 binary mount data from userspace has a
@@ -1341,6 +1343,8 @@ static int nfs_validate_mount_data(void *options,
 		len = c - dev_name;
 		/* N.B. caller will free nfs_server.hostname in all cases */
 		args->nfs_server.hostname = kstrndup(dev_name, len, GFP_KERNEL);
+		if (!args->nfs_server.hostname)
+			goto out_nomem;
 
 		c++;
 		if (strlen(c) > NFS_MAXPATHLEN)
@@ -1384,6 +1388,10 @@ out_v3_not_compiled:
 	return -EPROTONOSUPPORT;
 #endif /* !CONFIG_NFS_V3 */
 
+out_nomem:
+	dfprintk(MOUNT, "NFS: not enough memory to handle mount options\n");
+	return -ENOMEM;
+
 out_no_address:
 	dfprintk(MOUNT, "NFS: mount program didn't pass remote address\n");
 	return -EINVAL;
@@ -1890,12 +1898,16 @@ static int nfs4_validate_mount_data(void *options,
 			return -ENAMETOOLONG;
 		/* N.B. caller will free nfs_server.hostname in all cases */
 		args->nfs_server.hostname = kstrndup(dev_name, len, GFP_KERNEL);
+		if (!args->nfs_server.hostname)
+			goto out_nomem;
 
 		c++;			/* step over the ':' */
 		len = strlen(c);
 		if (len > NFS4_MAXPATHLEN)
 			return -ENAMETOOLONG;
 		args->nfs_server.export_path = kstrndup(c, len, GFP_KERNEL);
+		if (!args->nfs_server.export_path)
+			goto out_nomem;
 
 		dprintk("NFS: MNTPATH: '%s'\n", args->nfs_server.export_path);
 
@@ -1917,6 +1929,10 @@ out_inval_auth:
 		 data->auth_flavourlen);
 	return -EINVAL;
 
+out_nomem:
+	dfprintk(MOUNT, "NFS4: not enough memory to handle mount options\n");
+	return -ENOMEM;
+
 out_no_address:
 	dfprintk(MOUNT, "NFS4: mount program didn't pass remote address\n");
 	return -EINVAL;

