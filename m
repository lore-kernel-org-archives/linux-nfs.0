Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:54066 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754964Ab3KUCON (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Nov 2013 21:14:13 -0500
From: mark.doffman@codethink.co.uk
To: ceph-devel@vger.kernel.org
Cc: Mark Doffman <mark.doffman@codethink.co.uk>, sage@inktank.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, rob.taylor@codethink.co.uk
Subject: [PATCH 1/4] init: Add a new root device option, the Ceph file system
Date: Wed, 20 Nov 2013 20:13:41 -0600
Message-Id: <1385000024-23463-2-git-send-email-mark.doffman@codethink.co.uk>
In-Reply-To: <1385000024-23463-1-git-send-email-mark.doffman@codethink.co.uk>
References: <1385000024-23463-1-git-send-email-mark.doffman@codethink.co.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Mark Doffman <mark.doffman@codethink.co.uk>

Analogous to NFS add a new root device option, the ability
to boot using the Ceph networked file system as the root fs.

This patch adds a new root device option '/dev/ceph' that
uses a ceph networked file system. File system parameters
are passed using a new kernel parameter: 'cephroot'.

The 'cephroot' parameters are very similar to 'nfsroot'.

Signed-off-by: Mark Doffman <mark.doffman@codethink.co.uk>
Reviewed-by: Ian Molton <ian.molton@codethink.co.uk>
---
 fs/ceph/Kconfig                |  10 +++
 fs/ceph/Makefile               |   1 +
 fs/ceph/root.c                 | 163 +++++++++++++++++++++++++++++++++++++++++
 include/linux/ceph/ceph_root.h |  10 +++
 include/linux/root_dev.h       |   1 +
 init/do_mounts.c               |  32 +++++++-
 6 files changed, 216 insertions(+), 1 deletion(-)
 create mode 100644 fs/ceph/root.c
 create mode 100644 include/linux/ceph/ceph_root.h

diff --git a/fs/ceph/Kconfig b/fs/ceph/Kconfig
index ac9a2ef..325e83d 100644
--- a/fs/ceph/Kconfig
+++ b/fs/ceph/Kconfig
@@ -25,3 +25,13 @@ config CEPH_FSCACHE
 	  caching support for Ceph clients using FS-Cache
 
 endif
+
+config ROOT_CEPH
+	bool "Root file system on Ceph FS"
+	depends on CEPH_FS=y && IP_PNP
+	help
+	  If you want your system to mount its root file system via CEPH,
+	  choose Y here.  For details, read
+	  <file:Documentation/filesystems/ceph/cephroot.txt>.
+
+	  If unsure say N.
diff --git a/fs/ceph/Makefile b/fs/ceph/Makefile
index 32e3010..af2dcbf 100644
--- a/fs/ceph/Makefile
+++ b/fs/ceph/Makefile
@@ -10,3 +10,4 @@ ceph-y := super.o inode.o dir.o file.o locks.o addr.o ioctl.o \
 	debugfs.o
 
 ceph-$(CONFIG_CEPH_FSCACHE) += cache.o
+ceph-$(CONFIG_ROOT_CEPH) += root.o
diff --git a/fs/ceph/root.c b/fs/ceph/root.c
new file mode 100644
index 0000000..bff67fb
--- /dev/null
+++ b/fs/ceph/root.c
@@ -0,0 +1,163 @@
+/*
+ * Copyright (C) 2012 Codethink Ltd. <mark.doffman@codethink.co.uk>
+ *
+ * This file is released under the GPL v2
+ *
+ * Allow a CephFS filesystem to be mounted as root.
+ */
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/string.h>
+#include <linux/init.h>
+#include <linux/slab.h>
+#include <linux/utsname.h>
+#include <linux/root_dev.h>
+#include <linux/in.h>
+#include <net/ipconfig.h>
+#include <linux/ceph/ceph_root.h>
+
+/* linux/net/ipv4/ipconfig.c: trims ip addr off front of name, too. */
+extern __be32 root_nfs_parse_addr(char *name); /*__init*/
+
+#define MAXPATHLEN 1024
+
+/* Parameters passed from the kernel command line */
+static char ceph_root_params[256] __initdata;
+
+/* Address of CEPH server */
+static __be32 servaddr __initdata = htonl(INADDR_NONE);
+
+/* Name of directory to mount */
+static char ceph_export_path[MAXPATHLEN + 1] __initdata;
+
+/* Text-based mount options */
+static char ceph_root_options[256] __initdata;
+
+/* server:path string passed to mount */
+static char ceph_root_device[MAXPATHLEN + 1] __initdata;
+
+/* Address of CEPH server */
+static __be32 root_ceph_server_addr = htonl(INADDR_NONE);
+
+/*
+ * Parse out root export path and mount options from
+ * passed-in string @incoming.
+ *
+ * Copy the export path into @exppath.
+ *
+ * Returns 0 on success -E2BIG if the resulting options string is too long.
+ */
+static int __init root_ceph_parse_options(char *incoming, char *exppath,
+						const size_t exppathlen)
+{
+	char *p;
+	int res = 0;
+
+	/*
+	 * Set the remote path
+	 */
+	p = strsep(&incoming, ",");
+	if (*p != '\0' && strcmp(p, "default") != 0)
+		strlcpy(exppath, p, exppathlen);
+
+	/*
+	 * @incoming now points to the rest of the string; if it
+	 * contains something, append it to our root options buffer
+	 */
+	if (incoming != NULL && *incoming != '\0') {
+		size_t len = strlen(ceph_root_options);
+		size_t destlen = sizeof(ceph_root_options);
+
+		if (len && ceph_root_options[len - 1] != ',') {
+			if (strlcat(ceph_root_options, ",", destlen) > destlen)
+				res = -E2BIG;
+		}
+
+		if (strlcat(ceph_root_options, incoming, destlen) > destlen)
+			res = -E2BIG;
+
+	}
+	return res;
+}
+
+/*
+ *  Parse CephFS server and directory information passed on the kernel
+ *  command line.
+ *
+ *  cephroot=[<server-ip>:]<root-dir>[,<cephfs-options>]
+ */
+static int __init ceph_root_setup(char *line)
+{
+	ROOT_DEV = Root_CEPH;
+
+	strlcpy(ceph_root_params, line, sizeof(ceph_root_params));
+
+	/*
+	 * Note: root_nfs_parse_addr() removes the server-ip from
+	 * ceph_root_params, if it exists.
+	 */
+	root_ceph_server_addr = root_nfs_parse_addr(ceph_root_params);
+
+	return 1;
+}
+
+__setup("cephroot=", ceph_root_setup);
+
+/*
+ * ceph_root_data - Return mount device and data for CEPHROOT mount.
+ *
+ * @root_device: OUT: Address of string containing CEPHROOT device.
+ * @root_data: OUT: Address of string containing CEPHROOT mount options.
+ *
+ * Returns: 0 and sets @root_device and @root_data if successful.
+ *          error code if unsuccessful.
+ */
+int __init ceph_root_data(char **root_device, char **root_data)
+{
+	char *tmp = NULL;
+	const size_t tmplen = sizeof(ceph_export_path);
+	int len;
+	int ret = -E2BIG;
+
+	servaddr = root_ceph_server_addr;
+	if (servaddr == htonl(INADDR_NONE))
+		return -ENOENT;
+
+	tmp = kzalloc(tmplen, GFP_KERNEL);
+	if (tmp == NULL)
+		return -ENOMEM;
+
+	if (ceph_root_params[0] != '\0') {
+		if (root_ceph_parse_options(ceph_root_params, tmp, tmplen))
+			goto out;
+	}
+
+	/*
+	 * Set up ceph_root_device. This looks like: server:/path
+	 *
+	 * At this point, utsname()->nodename contains our local
+	 * IP address or hostname, set by ipconfig.  If "%s" exists
+	 * in tmp, substitute the nodename, then shovel the whole
+	 * mess into ceph_root_device.
+	 */
+	len = snprintf(ceph_export_path, sizeof(ceph_export_path),
+				tmp, utsname()->nodename);
+	if (len > (int)sizeof(ceph_export_path))
+		goto out;
+	len = snprintf(ceph_root_device, sizeof(ceph_root_device),
+				"%pI4:%s", &servaddr, ceph_export_path);
+	if (len > (int)sizeof(ceph_root_device))
+		goto out;
+
+	pr_debug("Root-CEPH: Root device: %s\n", ceph_root_device);
+	pr_debug("Root-CEPH: Root options: %s\n", ceph_root_options);
+	*root_device = ceph_root_device;
+	*root_data = ceph_root_options;
+
+	ret = 0;
+
+out:
+	kfree(tmp);
+	return ret;
+}
diff --git a/include/linux/ceph/ceph_root.h b/include/linux/ceph/ceph_root.h
new file mode 100644
index 0000000..e6bae63
--- /dev/null
+++ b/include/linux/ceph/ceph_root.h
@@ -0,0 +1,10 @@
+/*
+ * Copyright (C) 2012 Codethink Ltd. <mark.doffman@codethink.co.uk>
+ *
+ * This file is released under the GPL v2
+ *
+ * ceph_root.h
+ */
+
+/* linux/fs/ceph/root.c */
+extern int ceph_root_data(char **root_device, char **root_data); /*__init*/
diff --git a/include/linux/root_dev.h b/include/linux/root_dev.h
index ed241aa..af6b182 100644
--- a/include/linux/root_dev.h
+++ b/include/linux/root_dev.h
@@ -16,6 +16,7 @@ enum {
 	Root_SDA2 = MKDEV(SCSI_DISK0_MAJOR, 2),
 	Root_HDC1 = MKDEV(IDE1_MAJOR, 1),
 	Root_SR0 = MKDEV(SCSI_CDROM_MAJOR, 0),
+	Root_CEPH = MKDEV(UNNAMED_MAJOR, 254),
 };
 
 extern dev_t ROOT_DEV;
diff --git a/init/do_mounts.c b/init/do_mounts.c
index 8e5addc..d075020 100644
--- a/init/do_mounts.c
+++ b/init/do_mounts.c
@@ -33,6 +33,8 @@
 #include <linux/nfs_fs_sb.h>
 #include <linux/nfs_mount.h>
 
+#include <linux/ceph/ceph_root.h>
+
 #include "do_mounts.h"
 
 int __initdata rd_doload;	/* 1 = load RAM disk, 0 = don't load */
@@ -199,6 +201,7 @@ done:
  *	   a partition with a known unique id.
  *	8) <major>:<minor> major and minor number of the device separated by
  *	   a colon.
+ *	9) /dev/ceph represents Root_CEPH
  *
  *	If name doesn't have fall into the categories above, we return (0,0).
  *	block_class is used to check if something is a disk name. If the disk
@@ -245,7 +248,9 @@ dev_t name_to_dev_t(char *name)
 	res = Root_RAM0;
 	if (strcmp(name, "ram") == 0)
 		goto done;
-
+	res = Root_CEPH;
+	if (strcmp(name, "ceph") == 0)
+		goto done;
 	if (strlen(name) > 31)
 		goto fail;
 	strcpy(s, name);
@@ -473,6 +478,22 @@ static int __init mount_nfs_root(void)
 }
 #endif
 
+#ifdef CONFIG_ROOT_CEPH
+static int __init mount_ceph_root(void)
+{
+	char *root_dev, *root_data;
+
+	if (ceph_root_data(&root_dev, &root_data))
+		return 0;
+
+	if (do_mount_root(root_dev, "ceph",
+				root_mountflags, root_data))
+		return 0;
+
+	return 1;
+}
+#endif
+
 #if defined(CONFIG_BLK_DEV_RAM) || defined(CONFIG_BLK_DEV_FD)
 void __init change_floppy(char *fmt, ...)
 {
@@ -514,6 +535,15 @@ void __init mount_root(void)
 		ROOT_DEV = Root_FD0;
 	}
 #endif
+#ifdef CONFIG_ROOT_CEPH
+	if (ROOT_DEV == Root_CEPH) {
+		if (mount_ceph_root())
+			return;
+
+		printk(KERN_ERR "VFS: Unable to mount root fs via CephFS, trying floppy.\n");
+		ROOT_DEV = Root_FD0;
+	}
+#endif
 #ifdef CONFIG_BLK_DEV_FD
 	if (MAJOR(ROOT_DEV) == FLOPPY_MAJOR) {
 		/* rd_doload is 2 for a dual initrd/ramload setup */
-- 
1.8.4

