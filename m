From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 1/5] NFS: Adding trace points to fs/nfs/getroot.c
Date: Fri, 16 Jan 2009 11:25:33 -0500
Message-ID: <4970B4FD.4000400@RedHat.com>
References: <4970B451.4080201@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: SystemTAP <systemtap@redhat.com>
To: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:53012 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758008AbZAPQ16 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Jan 2009 11:27:58 -0500
In-Reply-To: <4970B451.4080201-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Added trace points to nfs_get_root() which define 
when nfs_get_root() is called and if it fails.

Signed-off-by: Steve Dickson <steved@redhat.com>

--- linux/fs/nfs/getroot.c.orig	2008-12-24 18:26:37.000000000 -0500
+++ linux/fs/nfs/getroot.c	2009-01-15 12:42:16.000000000 -0500
@@ -32,6 +32,7 @@
 #include <linux/namei.h>
 #include <linux/mnt_namespace.h>
 #include <linux/security.h>
+#include <trace/nfs.h>
 
 #include <asm/system.h>
 #include <asm/uaccess.h>
@@ -40,6 +41,12 @@
 #include "delegation.h"
 #include "internal.h"
 
+DEFINE_TRACE(nfs_mount_get_root);
+DEFINE_TRACE(nfs_mount_getroot);
+DEFINE_TRACE(nfs_mount_get_root_fhget);
+DEFINE_TRACE(nfs_mount_get_root_dummy_root);
+DEFINE_TRACE(nfs_mount_get_root_alias);
+
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
 
 /*
@@ -84,25 +91,30 @@ struct dentry *nfs_get_root(struct super
 	struct inode *inode;
 	int error;
 
+	trace_nfs_mount_get_root(sb, server, mntfh);
+
 	/* get the actual root for this mount */
 	fsinfo.fattr = &fattr;
 
 	error = server->nfs_client->rpc_ops->getroot(server, mntfh, &fsinfo);
 	if (error < 0) {
 		dprintk("nfs_get_root: getattr error = %d\n", -error);
+		trace_nfs_mount_getroot(sb, server, error);
 		return ERR_PTR(error);
 	}
 
 	inode = nfs_fhget(sb, mntfh, fsinfo.fattr);
 	if (IS_ERR(inode)) {
 		dprintk("nfs_get_root: get root inode failed\n");
+		trace_nfs_mount_get_root_fhget(sb, server, error);
 		return ERR_CAST(inode);
 	}
 
 	error = nfs_superblock_set_dummy_root(sb, inode);
-	if (error != 0)
+	if (error != 0) {
+		trace_nfs_mount_get_root_dummy_root(sb, server, error);
 		return ERR_PTR(error);
-
+	}
 	/* root dentries normally start off anonymous and get spliced in later
 	 * if the dentry tree reaches them; however if the dentry already
 	 * exists, we'll pick it up at this point and use it as the root
@@ -110,6 +122,7 @@ struct dentry *nfs_get_root(struct super
 	mntroot = d_obtain_alias(inode);
 	if (IS_ERR(mntroot)) {
 		dprintk("nfs_get_root: get root dentry failed\n");
+		trace_nfs_mount_get_root_alias(sb, server, PTR_ERR(mntroot));
 		return mntroot;
 	}
 
