From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: Add nfs_alloc_parsed_mount_data
Date: Thu, 10 Sep 2009 17:57:35 -0400
Message-ID: <20090910215556.4139.36866.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:57033
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754466AbZIJV5h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Sep 2009 17:57:37 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allocating nfs_parsed_mount_data and setting up the defaults is nearly
the same for both nfs and nfs4 mounts.

Both paths seem to use nfs_validate_transport_protocol(), so setting a
default value for nfs_server.protocol ought to be unnecessary.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Something like this untested patch?  I assume your tree has a few changes
in it that might prevent this from applying.

 fs/nfs/super.c |   44 +++++++++++++++++++++-----------------------
 1 files changed, 21 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index cf0d754..8057074 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -728,6 +728,25 @@ static void nfs_umount_begin(struct super_block *sb)
 	unlock_kernel();
 }
 
+static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(int flags)
+{
+	struct nfs_parsed_mount_data *data;
+
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	if (data) {
+		data->flags		= flags;
+		data->acregmin		= NFS_DEF_ACREGMIN;
+		data->acregmax		= NFS_DEF_ACREGMAX;
+		data->acdirmin		= NFS_DEF_ACDIRMIN;
+		data->acdirmax		= NFS_DEF_ACDIRMAX;
+		data->nfs_server.port	= NFS_UNSPEC_PORT;
+		data->auth_flavors[0]	= RPC_AUTH_UNIX;
+		data->auth_flavor_len	= 1;
+		data->minorversion	= 0;
+	}
+	return data;
+}
+
 /*
  * Sanity-check a server address provided by the mount command.
  *
@@ -1634,18 +1653,6 @@ static int nfs_validate_mount_data(void *options,
 	if (data == NULL)
 		goto out_no_data;
 
-	args->flags		= (NFS_MOUNT_VER3 | NFS_MOUNT_TCP);
-	args->acregmin		= NFS_DEF_ACREGMIN;
-	args->acregmax		= NFS_DEF_ACREGMAX;
-	args->acdirmin		= NFS_DEF_ACDIRMIN;
-	args->acdirmax		= NFS_DEF_ACDIRMAX;
-	args->mount_server.port	= NFS_UNSPEC_PORT;
-	args->nfs_server.port	= NFS_UNSPEC_PORT;
-	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
-	args->auth_flavors[0]	= RPC_AUTH_UNIX;
-	args->auth_flavor_len	= 1;
-	args->minorversion	= 0;
-
 	switch (data->version) {
 	case 1:
 		data->namlen = 0;
@@ -2087,7 +2094,7 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 	};
 	int error = -ENOMEM;
 
-	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	data = nfs_alloc_parsed_mount_data(NFS_MOUNT_VER3 | NFS_MOUNT_TCP);
 	mntfh = kzalloc(sizeof(*mntfh), GFP_KERNEL);
 	if (data == NULL || mntfh == NULL)
 		goto out_free_fh;
@@ -2349,15 +2356,6 @@ static int nfs4_validate_mount_data(void *options,
 	if (data == NULL)
 		goto out_no_data;
 
-	args->acregmin		= NFS_DEF_ACREGMIN;
-	args->acregmax		= NFS_DEF_ACREGMAX;
-	args->acdirmin		= NFS_DEF_ACDIRMIN;
-	args->acdirmax		= NFS_DEF_ACDIRMAX;
-	args->nfs_server.port	= NFS_UNSPEC_PORT;
-	args->auth_flavors[0]	= RPC_AUTH_UNIX;
-	args->auth_flavor_len	= 1;
-	args->minorversion	= 0;
-
 	switch (data->version) {
 	case 1:
 		if (data->host_addrlen > sizeof(args->nfs_server.address))
@@ -2640,7 +2638,7 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 	struct nfs_parsed_mount_data *data;
 	int error = -ENOMEM;
 
-	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	data = nfs_alloc_parsed_mount_data(0);
 	if (data == NULL)
 		goto out_free_data;
 

