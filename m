Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24906 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752600Ab1BHN7X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Feb 2011 08:59:23 -0500
From: Karel Zak <kzak@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, Karel Zak <kzak@redhat.com>
Subject: [PATCH 1/2] mount: move generic functions to utils.c and network.c
Date: Tue,  8 Feb 2011 14:45:16 +0100
Message-Id: <1297172717-26431-2-git-send-email-kzak@redhat.com>
In-Reply-To: <1297172717-26431-1-git-send-email-kzak@redhat.com>
References: <1297172717-26431-1-git-send-email-kzak@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Move generic code that could be shared between standard mount.nfs and
libmount version to utils.c and network.c.

Signed-off-by: Karel Zak <kzak@redhat.com>
---
 utils/mount/Makefile.am |    2 +-
 utils/mount/mount.c     |   83 +------------------
 utils/mount/network.c   |   28 ++++++
 utils/mount/network.h   |    2 +
 utils/mount/nfsumount.c |  119 +--------------------------
 utils/mount/utils.c     |  213 +++++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/utils.h     |   36 ++++++++
 7 files changed, 283 insertions(+), 200 deletions(-)
 create mode 100644 utils/mount/utils.c
 create mode 100644 utils/mount/utils.h

diff --git a/utils/mount/Makefile.am b/utils/mount/Makefile.am
index 299384a..a9553dc 100644
--- a/utils/mount/Makefile.am
+++ b/utils/mount/Makefile.am
@@ -16,7 +16,7 @@ mount_nfs_SOURCES = mount.c error.c network.c fstab.c token.c \
 		    mount_constants.h error.h network.h fstab.h token.h \
 		    parse_opt.h parse_dev.h \
 		    nfs4_mount.h nfs_mount4.h stropts.h version.h \
-			mount_config.h
+		    mount_config.h utils.c utils.h
 
 if MOUNT_CONFIG
 mount_nfs_SOURCES += configfile.c
diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index a19af53..f3f0a83 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -47,7 +47,7 @@
 #include "mount.h"
 #include "error.h"
 #include "stropts.h"
-#include "version.h"
+#include "utils.h"
 
 char *progname;
 int nfs_mount_data_version;
@@ -150,49 +150,6 @@ static const struct opt_map opt_map[] = {
 static void parse_opts(const char *options, int *flags, char **extra_opts);
 
 /*
- * Choose the version of the nfs_mount_data structure that is appropriate
- * for the kernel that is doing the mount.
- *
- * NFS_MOUNT_VERSION:		maximum version supported by these sources
- * nfs_mount_data_version:	maximum version supported by the running kernel
- */
-static void discover_nfs_mount_data_version(void)
-{
-	unsigned int kernel_version = linux_version_code();
-
-	if (kernel_version) {
-		if (kernel_version < MAKE_VERSION(2, 1, 32))
-			nfs_mount_data_version = 1;
-		else if (kernel_version < MAKE_VERSION(2, 2, 18))
-			nfs_mount_data_version = 3;
-		else if (kernel_version < MAKE_VERSION(2, 3, 0))
-			nfs_mount_data_version = 4;
-		else if (kernel_version < MAKE_VERSION(2, 3, 99))
-			nfs_mount_data_version = 3;
-		else if (kernel_version < MAKE_VERSION(2, 6, 3))
-			nfs_mount_data_version = 4;
-		else
-			nfs_mount_data_version = 6;
-	}
-	if (nfs_mount_data_version > NFS_MOUNT_VERSION)
-		nfs_mount_data_version = NFS_MOUNT_VERSION;
-	else
-		if (kernel_version > MAKE_VERSION(2, 6, 22))
-			string++;
-}
-
-static void print_one(char *spec, char *node, char *type, char *opts)
-{
-	if (!verbose)
-		return;
-
-	if (opts)
-		printf(_("%s on %s type %s (%s)\n"), spec, node, type, opts);
-	else
-		printf(_("%s on %s type %s\n"), spec, node, type);
-}
-
-/*
  * Build a canonical mount option string for /etc/mtab.
  */
 static char *fix_opts_string(int flags, const char *extra_opts)
@@ -327,22 +284,6 @@ static int add_mtab(char *spec, char *mount_point, char *fstype,
 	return result;
 }
 
-static void mount_usage(void)
-{
-	printf(_("usage: %s remotetarget dir [-rvVwfnsih] [-o nfsoptions]\n"),
-		progname);
-	printf(_("options:\n"));
-	printf(_("\t-r\t\tMount file system readonly\n"));
-	printf(_("\t-v\t\tVerbose\n"));
-	printf(_("\t-V\t\tPrint version\n"));
-	printf(_("\t-w\t\tMount file system read-write\n"));
-	printf(_("\t-f\t\tFake mount, do not actually mount\n"));
-	printf(_("\t-n\t\tDo not update /etc/mtab\n"));
-	printf(_("\t-s\t\tTolerate sloppy mount options rather than fail\n"));
-	printf(_("\t-h\t\tPrint this help\n"));
-	printf(_("\tnfsoptions\tRefer to mount.nfs(8) or nfs(5)\n\n"));
-}
-
 static void parse_opt(const char *opt, int *mask, char *extra_opts, size_t len)
 {
 	const struct opt_map *om;
@@ -403,26 +344,6 @@ static void parse_opts(const char *options, int *flags, char **extra_opts)
 	}
 }
 
-static int chk_mountpoint(char *mount_point)
-{
-	struct stat sb;
-
-	if (stat(mount_point, &sb) < 0){
-		mount_error(NULL, mount_point, errno);
-		return 1;
-	}
-	if (S_ISDIR(sb.st_mode) == 0){
-		mount_error(NULL, mount_point, ENOTDIR);
-		return 1;
-	}
-	if (access(mount_point, X_OK) < 0) {
-		mount_error(NULL, mount_point, errno);
-		return 1;
-	}
-
-	return 0;
-}
-
 static int try_mount(char *spec, char *mount_point, int flags,
 			char *fs_type, char **extra_opts, char *mount_opts,
 			int fake, int bg)
@@ -459,7 +380,7 @@ int main(int argc, char *argv[])
 
 	progname = basename(argv[0]);
 
-	discover_nfs_mount_data_version();
+	nfs_mount_data_version = discover_nfs_mount_data_version(&string);
 
 	if(!strncmp(progname, "umount", strlen("umount")))
 		exit(nfsumount(argc, argv));
diff --git a/utils/mount/network.c b/utils/mount/network.c
index 21a7a2c..c66e7a0 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1491,6 +1491,34 @@ nfs_mount_version(struct mount_options *options, unsigned long *version)
 }
 
 /*
+ * Discover mount server's hostname/address by examining mount options
+ *
+ * Returns a pointer to a string that the caller must free, on
+ * success; otherwise NULL is returned.
+ */
+char *nfs_umount_hostname(struct mount_options *options,
+				 char *hostname)
+{
+	char *option;
+
+	option = po_get(options, "mountaddr");
+	if (option)
+		goto out;
+	option = po_get(options, "mounthost");
+	if (option)
+		goto out;
+	option = po_get(options, "addr");
+	if (option)
+		goto out;
+
+	return hostname;
+
+out:
+	free(hostname);
+	return strdup(option);
+}
+
+/*
  * Returns TRUE if @protocol contains a valid value for this option,
  * or FALSE if the option was specified with an invalid value. On
  * error, errno is set.
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 2a3a110..416f4a5 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -62,6 +62,8 @@ int nfs_mount_proto_family(struct mount_options *options, sa_family_t *family);
 int nfs_nfs_version(struct mount_options *options, unsigned long *version);
 int  nfs_nfs_protocol(struct mount_options *options, unsigned long *protocol);
 
+char *nfs_umount_hostname(struct mount_options *options, char *hostname);
+
 int nfs_options2pmap(struct mount_options *,
 		      struct pmap *, struct pmap *);
 
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 02d40ff..8cd2852 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -37,6 +37,7 @@
 #include "network.h"
 #include "parse_opt.h"
 #include "parse_dev.h"
+#include "utils.h"
 
 #define MOUNTSFILE	"/proc/mounts"
 #define LINELEN		(4096)
@@ -139,113 +140,6 @@ static int del_mtab(const char *spec, const char *node)
 }
 
 /*
- * Discover mount server's hostname/address by examining mount options
- *
- * Returns a pointer to a string that the caller must free, on
- * success; otherwise NULL is returned.
- */
-static char *nfs_umount_hostname(struct mount_options *options,
-				 char *hostname)
-{
-	char *option;
-
-	option = po_get(options, "mountaddr");
-	if (option)
-		goto out;
-	option = po_get(options, "mounthost");
-	if (option)
-		goto out;
-	option = po_get(options, "addr");
-	if (option)
-		goto out;
-
-	return hostname;
-
-out:
-	free(hostname);
-	return strdup(option);
-}
-
-/*
- * Returns EX_SUCCESS if mount options and device name have been
- * parsed successfully; otherwise EX_FAIL.
- */
-static int nfs_umount_do_umnt(struct mount_options *options,
-			      char **hostname, char **dirname)
-{
-	union {
-		struct sockaddr		sa;
-		struct sockaddr_in	s4;
-		struct sockaddr_in6	s6;
-	} address;
-	struct sockaddr *sap = &address.sa;
-	socklen_t salen = sizeof(address);
-	struct pmap nfs_pmap, mnt_pmap;
-	sa_family_t family;
-
-	if (!nfs_options2pmap(options, &nfs_pmap, &mnt_pmap))
-		return EX_FAIL;
-
-	/* Skip UMNT call for vers=4 mounts */
-	if (nfs_pmap.pm_vers == 4)
-		return EX_SUCCESS;
-
-	*hostname = nfs_umount_hostname(options, *hostname);
-	if (!*hostname) {
-		nfs_error(_("%s: out of memory"), progname);
-		return EX_FAIL;
-	}
-
-	if (!nfs_mount_proto_family(options, &family))
-		return 0;
-	if (!nfs_lookup(*hostname, family, sap, &salen))
-		/* nfs_lookup reports any errors */
-		return EX_FAIL;
-
-	if (nfs_advise_umount(sap, salen, &mnt_pmap, dirname) == 0)
-		/* nfs_advise_umount reports any errors */
-		return EX_FAIL;
-
-	return EX_SUCCESS;
-}
-
-/*
- * Pick up certain mount options used during the original mount
- * from /etc/mtab.  The basics include the server's IP address and
- * the server pathname of the share to unregister.
- *
- * These options might also describe the mount port, mount protocol
- * version, and transport protocol used to punch through a firewall.
- * We will need this information to get through the firewall again
- * to do the umount.
- *
- * Note that option parsing failures won't necessarily cause the
- * umount request to fail.  Those values will be left zero in the
- * pmap tuple.  If the GETPORT call later fails to disambiguate them,
- * then we fail.
- */
-static int nfs_umount23(const char *devname, char *string)
-{
-	char *hostname, *dirname;
-	struct mount_options *options;
-	int result = EX_FAIL;
-
-	if (!nfs_parse_devname(devname, &hostname, &dirname))
-		return EX_USAGE;
-
-	options = po_split(string);
-	if (options) {
-		result = nfs_umount_do_umnt(options, &hostname, &dirname);
-		po_destroy(options);
-	} else
-		nfs_error(_("%s: option parsing error"), progname);
-
-	free(hostname);
-	free(dirname);
-	return result;
-}
-
-/*
  * Detect NFSv4 mounts.
  *
  * Consult /proc/mounts to determine if the mount point
@@ -340,17 +234,6 @@ static struct option umount_longopts[] =
   { NULL, 0, 0, 0 }
 };
 
-static void umount_usage(void)
-{
-	printf(_("usage: %s dir [-fvnrlh]\n"), progname);
-	printf(_("options:\n\t-f\t\tforce unmount\n"));
-	printf(_("\t-v\tverbose\n"));
-	printf(_("\t-n\tDo not update /etc/mtab\n"));
-	printf(_("\t-r\tremount\n"));
-	printf(_("\t-l\tlazy unmount\n"));
-	printf(_("\t-h\tprint this help\n\n"));
-}
-
 int nfsumount(int argc, char *argv[])
 {
 	int c, ret;
diff --git a/utils/mount/utils.c b/utils/mount/utils.c
new file mode 100644
index 0000000..e82cc3e
--- /dev/null
+++ b/utils/mount/utils.c
@@ -0,0 +1,213 @@
+/*
+ * Copyright (C) 2010 Karel Zak <kzak@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2, or (at your option)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <stdio.h>
+#include <string.h>
+#include <errno.h>
+#include <unistd.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+
+#include "nfs_mount.h"
+#include "nls.h"
+#include "xcommon.h"
+#include "version.h"
+#include "error.h"
+#include "utils.h"
+#include "mount.h"
+#include "network.h"
+#include "parse_dev.h"
+
+extern int verbose;
+extern char *progname;
+
+/*
+ * Choose the version of the nfs_mount_data structure that is appropriate
+ * for the kernel that is doing the mount.
+ *
+ * NFS_MOUNT_VERSION:		maximum version supported by these sources
+ * nfs_mount_data_version:	maximum version supported by the running kernel
+ */
+int discover_nfs_mount_data_version(int *string_ver)
+{
+	unsigned int kernel_version = linux_version_code();
+	int ver = 0;
+
+	*string_ver = 0;
+
+	if (kernel_version) {
+		if (kernel_version < MAKE_VERSION(2, 1, 32))
+			ver = 1;
+		else if (kernel_version < MAKE_VERSION(2, 2, 18))
+			ver = 3;
+		else if (kernel_version < MAKE_VERSION(2, 3, 0))
+			ver = 4;
+		else if (kernel_version < MAKE_VERSION(2, 3, 99))
+			ver = 3;
+		else if (kernel_version < MAKE_VERSION(2, 6, 3))
+			ver = 4;
+		else
+			ver = 6;
+	}
+	if (ver > NFS_MOUNT_VERSION)
+		ver = NFS_MOUNT_VERSION;
+	else
+		if (kernel_version > MAKE_VERSION(2, 6, 22))
+			(*string_ver)++;
+
+	return ver;
+}
+
+void print_one(char *spec, char *node, char *type, char *opts)
+{
+	if (!verbose)
+		return;
+
+	if (opts)
+		printf(_("%s on %s type %s (%s)\n"), spec, node, type, opts);
+	else
+		printf(_("%s on %s type %s\n"), spec, node, type);
+}
+
+void mount_usage(void)
+{
+	printf(_("usage: %s remotetarget dir [-rvVwfnsih] [-o nfsoptions]\n"),
+		progname);
+	printf(_("options:\n"));
+	printf(_("\t-r\t\tMount file system readonly\n"));
+	printf(_("\t-v\t\tVerbose\n"));
+	printf(_("\t-V\t\tPrint version\n"));
+	printf(_("\t-w\t\tMount file system read-write\n"));
+	printf(_("\t-f\t\tFake mount, do not actually mount\n"));
+	printf(_("\t-n\t\tDo not update /etc/mtab\n"));
+	printf(_("\t-s\t\tTolerate sloppy mount options rather than fail\n"));
+	printf(_("\t-h\t\tPrint this help\n"));
+	printf(_("\tnfsoptions\tRefer to mount.nfs(8) or nfs(5)\n\n"));
+}
+
+void umount_usage(void)
+{
+	printf(_("usage: %s dir [-fvnrlh]\n"), progname);
+	printf(_("options:\n\t-f\t\tforce unmount\n"));
+	printf(_("\t-v\tverbose\n"));
+	printf(_("\t-n\tDo not update /etc/mtab\n"));
+	printf(_("\t-r\tremount\n"));
+	printf(_("\t-l\tlazy unmount\n"));
+	printf(_("\t-h\tprint this help\n\n"));
+}
+
+int chk_mountpoint(const char *mount_point)
+{
+	struct stat sb;
+
+	if (stat(mount_point, &sb) < 0){
+		mount_error(NULL, mount_point, errno);
+		return 1;
+	}
+	if (S_ISDIR(sb.st_mode) == 0){
+		mount_error(NULL, mount_point, ENOTDIR);
+		return 1;
+	}
+	if (access(mount_point, X_OK) < 0) {
+		mount_error(NULL, mount_point, errno);
+		return 1;
+	}
+
+	return 0;
+}
+
+/*
+ * Returns EX_SUCCESS if mount options and device name have been
+ * parsed successfully; otherwise EX_FAIL.
+ */
+static int nfs_umount_do_umnt(struct mount_options *options,
+			      char **hostname, char **dirname)
+{
+	union {
+		struct sockaddr		sa;
+		struct sockaddr_in	s4;
+		struct sockaddr_in6	s6;
+	} address;
+	struct sockaddr *sap = &address.sa;
+	socklen_t salen = sizeof(address);
+	struct pmap nfs_pmap, mnt_pmap;
+	sa_family_t family;
+
+	if (!nfs_options2pmap(options, &nfs_pmap, &mnt_pmap))
+		return EX_FAIL;
+
+	/* Skip UMNT call for vers=4 mounts */
+	if (nfs_pmap.pm_vers == 4)
+		return EX_SUCCESS;
+
+	*hostname = nfs_umount_hostname(options, *hostname);
+	if (!*hostname) {
+		nfs_error(_("%s: out of memory"), progname);
+		return EX_FAIL;
+	}
+
+	if (!nfs_mount_proto_family(options, &family))
+		return 0;
+	if (!nfs_lookup(*hostname, family, sap, &salen))
+		/* nfs_lookup reports any errors */
+		return EX_FAIL;
+
+	if (nfs_advise_umount(sap, salen, &mnt_pmap, dirname) == 0)
+		/* nfs_advise_umount reports any errors */
+		return EX_FAIL;
+
+	return EX_SUCCESS;
+}
+
+/*
+ * Pick up certain mount options used during the original mount
+ * from /etc/mtab.  The basics include the server's IP address and
+ * the server pathname of the share to unregister.
+ *
+ * These options might also describe the mount port, mount protocol
+ * version, and transport protocol used to punch through a firewall.
+ * We will need this information to get through the firewall again
+ * to do the umount.
+ *
+ * Note that option parsing failures won't necessarily cause the
+ * umount request to fail.  Those values will be left zero in the
+ * pmap tuple.  If the GETPORT call later fails to disambiguate them,
+ * then we fail.
+ */
+int nfs_umount23(const char *devname, char *string)
+{
+	char *hostname = NULL, *dirname = NULL;
+	struct mount_options *options;
+	int result = EX_FAIL;
+
+	if (!nfs_parse_devname(devname, &hostname, &dirname))
+		return EX_USAGE;
+
+	options = po_split(string);
+	if (options) {
+		result = nfs_umount_do_umnt(options, &hostname, &dirname);
+		po_destroy(options);
+	} else
+		nfs_error(_("%s: option parsing error"), progname);
+
+	free(hostname);
+	free(dirname);
+	return result;
+}
+
diff --git a/utils/mount/utils.h b/utils/mount/utils.h
new file mode 100644
index 0000000..61832a3
--- /dev/null
+++ b/utils/mount/utils.h
@@ -0,0 +1,36 @@
+/*
+ * utils.h -- misc utils for mount and umount
+ *
+ * Copyright (C) 2010 Karel Zak <kzak@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License as published by the Free Software Foundation; either
+ * version 2 of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public
+ * License along with this program; if not, write to the
+ * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+ * Boston, MA 021110-1307, USA.
+ *
+ */
+
+#ifndef _NFS_UTILS_MOUNT_UTILS_H
+#define _NFS_UTILS_MOUNT_UTILS_H
+
+#include "parse_opt.h"
+
+int discover_nfs_mount_data_version(int *string_ver);
+void print_one(char *spec, char *node, char *type, char *opts);
+void mount_usage(void);
+void umount_usage(void);
+int chk_mountpoint(const char *mount_point);
+
+int nfs_umount23(const char *devname, char *string);
+
+#endif	/* _NFS_UTILS_MOUNT_UTILS_H */
-- 
1.7.3.4

