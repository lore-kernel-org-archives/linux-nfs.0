From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 2/5] NFS: Adding trace points to fs/nfs/super.c
Date: Fri, 16 Jan 2009 11:28:04 -0500
Message-ID: <4970B594.3040507@RedHat.com>
References: <4970B451.4080201@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: SystemTAP <systemtap@redhat.com>
To: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:53085 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760118AbZAPQa1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Jan 2009 11:30:27 -0500
In-Reply-To: <4970B451.4080201-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Added trace points to nfs_validate_mount_data() and
nfs_get_sb(). Since nfs_validate_mount_data() is only
called from nfs_get_sb(), trace points were only added
to the error paths.

Signed-off-by: Steve Dickson <steved@redhat.com>

--- linux/fs/nfs/super.c.orig	2009-01-14 15:54:19.000000000 -0500
+++ linux/fs/nfs/super.c	2009-01-15 12:37:57.000000000 -0500
@@ -51,6 +51,7 @@
 #include <linux/nfs_xdr.h>
 #include <linux/magic.h>
 #include <linux/parser.h>
+#include <trace/nfs.h>
 
 #include <asm/system.h>
 #include <asm/uaccess.h>
@@ -61,6 +62,15 @@
 #include "iostat.h"
 #include "internal.h"
 
+DEFINE_TRACE(nfs_mount_data_null);
+DEFINE_TRACE(nfs_mount_data_invalvers);
+DEFINE_TRACE(nfs_mount_data_invalsec);
+DEFINE_TRACE(nfs_mount_data_nomem);
+DEFINE_TRACE(nfs_mount_data_noaddr);
+DEFINE_TRACE(nfs_mount_data_badfh);
+DEFINE_TRACE(nfs_mount);
+DEFINE_TRACE(nfs_mount_sget);
+
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
 enum {
@@ -1692,15 +1702,18 @@ static int nfs_validate_mount_data(void 
 
 out_no_data:
 	dfprintk(MOUNT, "NFS: mount program didn't pass any mount data\n");
+	trace_nfs_mount_data_null(data, EINVAL);
 	return -EINVAL;
 
 out_no_v3:
 	dfprintk(MOUNT, "NFS: nfs_mount_data version %d does not support v3\n",
 		 data->version);
+	trace_nfs_mount_data_invalvers(data, EINVAL);
 	return -EINVAL;
 
 out_no_sec:
 	dfprintk(MOUNT, "NFS: nfs_mount_data version supports only AUTH_SYS\n");
+	trace_nfs_mount_data_invalsec(data, EINVAL);
 	return -EINVAL;
 
 #ifndef CONFIG_NFS_V3
@@ -1711,14 +1724,17 @@ out_v3_not_compiled:
 
 out_nomem:
 	dfprintk(MOUNT, "NFS: not enough memory to handle mount options\n");
+	trace_nfs_mount_data_nomem(data, EINVAL);
 	return -ENOMEM;
 
 out_no_address:
 	dfprintk(MOUNT, "NFS: mount program didn't pass remote address\n");
+	trace_nfs_mount_data_noaddr(data, EINVAL);
 	return -EINVAL;
 
 out_invalid_fh:
 	dfprintk(MOUNT, "NFS: invalid root filehandle\n");
+	trace_nfs_mount_data_badfh(data, EINVAL);
 	return -EINVAL;
 }
 
@@ -1999,6 +2015,8 @@ static int nfs_get_sb(struct file_system
 
 	security_init_mnt_opts(&data->lsm_opts);
 
+	trace_nfs_mount(fs_type, flags, dev_name, data, mnt);
+
 	/* Validate the mount data */
 	error = nfs_validate_mount_data(raw_data, data, mntfh, dev_name);
 	if (error < 0)
@@ -2019,6 +2037,7 @@ static int nfs_get_sb(struct file_system
 	s = sget(fs_type, compare_super, nfs_set_super, &sb_mntdata);
 	if (IS_ERR(s)) {
 		error = PTR_ERR(s);
+		trace_nfs_mount_sget(server, error);
 		goto out_err_nosb;
 	}
 
