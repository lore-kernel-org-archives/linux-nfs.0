Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-vbr8.xs4all.nl ([194.109.24.28]:2075 "EHLO
	smtp-vbr8.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935212Ab3DINAf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Apr 2013 09:00:35 -0400
Date: Tue, 9 Apr 2013 14:48:51 +0200
From: Miquel van Smoorenburg <mikevs@xs4all.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] "noaccesscheck" mount option
Message-ID: <20130409124851.GA15231@xs4all.net>
References: <20130409124600.GA15201@xs4all.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130409124600.GA15201@xs4all.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

1/2: "noaccesscheck" mount option

     If this option is enabled, the nfs client will not send any
     NFS ACCESS calls to the server, except for UID 0. For all other
     uids, access is checked locally using generic_permission().

diff -ruN linux-3.9-rc6.orig/include/uapi/linux/nfs_mount.h linux-3.9-rc6/include/uapi/linux/nfs_mount.h
--- linux-3.9-rc6.orig/include/uapi/linux/nfs_mount.h	2013-04-08 05:49:54.000000000 +0200
+++ linux-3.9-rc6/include/uapi/linux/nfs_mount.h	2013-04-08 15:58:38.590470728 +0200
@@ -74,4 +74,6 @@
 #define NFS_MOUNT_LOCAL_FLOCK	0x100000
 #define NFS_MOUNT_LOCAL_FCNTL	0x200000
 
+#define NFS_MOUNT_NOACCESSCHECK	0x400000
+
 #endif
diff -ruN linux-3.9-rc6.orig/fs/nfs/dir.c linux-3.9-rc6/fs/nfs/dir.c
--- linux-3.9-rc6.orig/fs/nfs/dir.c	2013-04-08 05:49:54.000000000 +0200
+++ linux-3.9-rc6/fs/nfs/dir.c	2013-04-08 15:59:04.674471048 +0200
@@ -2165,6 +2165,22 @@
 	struct nfs_access_entry cache;
 	int status;
 
+	if (NFS_SERVER(inode)->flags & NFS_MOUNT_NOACCESSCHECK) {
+		/*
+		 * We could also check
+		 * NFS_SERVER(inode)->client->cl_auth->au_ops->au_flavor
+		 * to see if this is RPC_AUTH_UNIX, which is the only
+		 * auth flavor where this makes sense, but that's way
+		 * too much pointer chasing.
+		 */
+		if (cred->cr_uid != 0) {
+			status = nfs_revalidate_inode(NFS_SERVER(inode), inode);
+			if (status == 0)
+				status = generic_permission(inode, mask);
+			return status;
+		}
+	}
+
 	status = nfs_access_get_cached(inode, cred, &cache);
 	if (status == 0)
 		goto out;
diff -ruN linux-3.9-rc6.orig/fs/nfs/super.c linux-3.9-rc6/fs/nfs/super.c
--- linux-3.9-rc6.orig/fs/nfs/super.c	2013-04-08 05:49:54.000000000 +0200
+++ linux-3.9-rc6/fs/nfs/super.c	2013-04-08 15:59:04.678470794 +0200
@@ -91,6 +91,7 @@
 	Opt_resvport, Opt_noresvport,
 	Opt_fscache, Opt_nofscache,
 	Opt_migration, Opt_nomigration,
+	Opt_accesscheck, Opt_noaccesscheck,
 
 	/* Mount options that take integer arguments */
 	Opt_port,
@@ -152,6 +153,8 @@
 	{ Opt_nofscache, "nofsc" },
 	{ Opt_migration, "migration" },
 	{ Opt_nomigration, "nomigration" },
+	{ Opt_accesscheck, "accesscheck" },
+	{ Opt_noaccesscheck, "noaccesscheck" },
 
 	{ Opt_port, "port=%s" },
 	{ Opt_rsize, "rsize=%s" },
@@ -635,6 +638,7 @@
 		{ NFS_MOUNT_NORDIRPLUS, ",nordirplus", "" },
 		{ NFS_MOUNT_UNSHARED, ",nosharecache", "" },
 		{ NFS_MOUNT_NORESVPORT, ",noresvport", "" },
+		{ NFS_MOUNT_NOACCESSCHECK, ",noaccesscheck", "" },
 		{ 0, NULL, NULL }
 	};
 	const struct proc_nfs_info *nfs_infop;
@@ -1261,6 +1265,12 @@
 		case Opt_nomigration:
 			mnt->options &= NFS_OPTION_MIGRATION;
 			break;
+		case Opt_accesscheck:
+			mnt->flags &= ~NFS_MOUNT_NOACCESSCHECK;
+			break;
+		case Opt_noaccesscheck:
+			mnt->flags |= NFS_MOUNT_NOACCESSCHECK;
+			break;
 
 		/*
 		 * options that take numeric values

