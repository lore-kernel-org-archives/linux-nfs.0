From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/14] text-based mount command: Support raw IPv6 address
	hostnames
Date: Wed, 09 Jul 2008 20:37:59 -0400
Message-ID: <20080710003758.6137.71713.stgit@tarkus.1015granger.net>
References: <20080710001725.6137.83845.stgit@tarkus.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:61676 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106AbYGJEIK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2008 00:08:10 -0400
In-Reply-To: <20080710001725.6137.83845.stgit-lQeC5l55kZ7wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Traditionally the mount command has looked for a ":" to separate the
server's hostname from the export path in the mounted on device name,
like this:

	mount server:/export /mounted/on/dir

The server's hostname is "server" and the export path is "/export".

You can also substitute a specific IPv4 network address for the server
hostname, like this:

	mount 192.168.0.55:/export /mounted/on/dir

Raw IPv6 addresses present a problem, however, because they look something
like this:

	fe80::200:5aff:fe00:30b

Note the use of colons.

To get around the presence of colons, copy the Solaris convention used for
raw NFS server IPv6 addresses, which is to wrap the raw IPv6 address with
square brackets.  This is also suggested in RFC 4038.

Introduce a new device name parser that can support traditional device
names and square brackets.  Place the parser in a separate source file
so both the mount and umount paths can derive the server's hostname and
export pathname the same way.

Bonus points: add a check for NFS URLs and display an appropriate error
message in that case.  This is cleaner than failing with "unknown host:
nfs".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/Makefile.am |    6 +
 utils/mount/nfsumount.c |   35 +++----
 utils/mount/parse_dev.c |  230 +++++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/parse_dev.h |   28 ++++++
 utils/mount/stropts.c   |   59 +-----------
 5 files changed, 282 insertions(+), 76 deletions(-)
 create mode 100644 utils/mount/parse_dev.c
 create mode 100644 utils/mount/parse_dev.h

diff --git a/utils/mount/Makefile.am b/utils/mount/Makefile.am
index 5a94631..459fa45 100644
--- a/utils/mount/Makefile.am
+++ b/utils/mount/Makefile.am
@@ -9,10 +9,12 @@ man5_MANS	= nfs.man
 
 sbin_PROGRAMS	= mount.nfs
 EXTRA_DIST = nfsmount.x $(man8_MANS) $(man5_MANS)
-mount_nfs_SOURCES = mount.c error.c network.c fstab.c token.c parse_opt.c \
+mount_nfs_SOURCES = mount.c error.c network.c fstab.c token.c \
+		    parse_opt.c parse_dev.c \
 		    nfsmount.c nfs4mount.c stropts.c\
 		    nfsumount.c \
-		    mount_constants.h error.h network.h fstab.h token.h parse_opt.h \
+		    mount_constants.h error.h network.h fstab.h token.h \
+		    parse_opt.h parse_dev.h \
 		    nfs4_mount.h nfs_mount4.h stropts.h version.h
 
 mount_nfs_LDADD = ../../support/nfs/libnfs.a \
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 285273b..67e9c4b 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -34,6 +34,7 @@
 #include "mount.h"
 #include "error.h"
 #include "network.h"
+#include "parse_dev.h"
 
 #if !defined(MNT_FORCE)
 /* dare not try to include <linux/mount.h> -- lots of errors */
@@ -150,21 +151,11 @@ static int do_nfs_umount23(const char *spec, char *opts)
 	struct mntent mnt = { .mnt_opts = opts };
 	struct pmap *pmap = &mnt_server.pmap;
 	char *p;
+	int result = EX_USAGE;
+
+	if (!nfs_parse_devname(spec, &hostname, &dirname))
+		return result;
 
-	if (spec == NULL) {
-		nfs_error(_("%s: No NFS export name was provided"),
-				progname);
-		return EX_USAGE;
-	}
-	
-	p = strchr(spec, ':');
-	if (p == NULL) {
-		nfs_error(_("%s: '%s' is not a legal NFS export name"),
-				progname, spec);
-		return EX_USAGE;
-	}
-	hostname = xstrndup(spec, p - spec);
-	dirname = xstrdup(p + 1);
 #ifdef NFS_MOUNT_DEBUG
 	printf(_("host: %s, directory: %s\n"), hostname, dirname);
 #endif
@@ -209,18 +200,24 @@ static int do_nfs_umount23(const char *spec, char *opts)
 		pmap->pm_prot = IPPROTO_TCP;
 
 	if (!nfs_gethostbyname(hostname, &mnt_server.saddr)) {
-		nfs_error(_("%s: '%s' does not contain a recognized hostname"),
-				progname, spec);
-		return EX_USAGE;
+		nfs_error(_("%s: DNS resolution of '%s' failed"),
+				progname, hostname);
+		goto out;
 	}
 
 	if (!nfs_call_umount(&mnt_server, &dirname)) {
 		nfs_error(_("%s: Server failed to unmount '%s'"),
 				progname, spec);
-		return EX_USAGE;
+		result = EX_FAIL;
+		goto out;
 	}
 
-	return EX_SUCCESS;
+	result = EX_SUCCESS;
+
+out:
+	free(hostname);
+	free(dirname);
+	return result;
 }
 
 static struct option umount_longopts[] =
diff --git a/utils/mount/parse_dev.c b/utils/mount/parse_dev.c
new file mode 100644
index 0000000..c0a8e18
--- /dev/null
+++ b/utils/mount/parse_dev.c
@@ -0,0 +1,230 @@
+/*
+ * parse_dev.c -- parse device name into hostname and export path
+ *
+ * Copyright (C) 2008 Oracle.  All rights reserved.
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
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include "xcommon.h"
+#include "nls.h"
+#include "parse_dev.h"
+
+#ifndef NFS_MAXHOSTNAME
+#define NFS_MAXHOSTNAME		(255)
+#endif
+
+#ifndef NFS_MAXPATHNAME
+#define NFS_MAXPATHNAME		(1024)
+#endif
+
+extern char *progname;
+extern int verbose;
+
+static int nfs_pdn_no_devname_err(void)
+{
+	nfs_error(_("%s: no device name was provided"), progname);
+	return 0;
+}
+
+static int nfs_pdn_hostname_too_long_err(void)
+{
+	nfs_error(_("%s: server hostname is too long"), progname);
+	return 0;
+}
+
+static int nfs_pdn_pathname_too_long_err(void)
+{
+	nfs_error(_("%s: export pathname is too long"), progname);
+	return 0;
+}
+
+static int nfs_pdn_bad_format_err(void)
+{
+	nfs_error(_("%s: remote share not in 'host:dir' format"), progname);
+	return 0;
+}
+
+static int nfs_pdn_nomem_err(void)
+{
+	nfs_error(_("%s: no memory available to parse devname"), progname);
+	return 0;
+}
+
+static int nfs_pdn_missing_brace_err(void)
+{
+	nfs_error(_("%s: closing bracket missing from server address"),
+				progname);
+	return 0;
+}
+
+/*
+ * Standard hostname:path format
+ */
+static int nfs_parse_simple_hostname(const char *dev,
+				     char **hostname, char **pathname)
+{
+	size_t host_len, path_len;
+	char *colon, *comma;
+
+	/* Must have a colon */
+	colon = strchr(dev, ':');
+	if (colon == NULL)
+		return nfs_pdn_bad_format_err();
+	*colon = '\0';
+	host_len = colon - dev;
+
+	if (host_len > NFS_MAXHOSTNAME)
+		return nfs_pdn_hostname_too_long_err();
+
+	/* If there's a comma before the colon, take only the
+	 * first name in list */
+	comma = strchr(dev, ',');
+	if (comma != NULL) {
+		*comma = '\0';
+		host_len = comma - dev;
+		nfs_error(_("%s: warning: multiple hostnames not supported"),
+				progname);
+	} else
+
+	colon++;
+	path_len = strlen(colon);
+	if (path_len > NFS_MAXPATHNAME)
+		return nfs_pdn_pathname_too_long_err();
+
+	if (hostname) {
+		*hostname = strndup(dev, host_len);
+		if (*hostname == NULL)
+			return nfs_pdn_nomem_err();
+	}
+	if (pathname) {
+		*pathname = strndup(colon, path_len);
+		if (*pathname == NULL) {
+			free(*hostname);
+			return nfs_pdn_nomem_err();
+		}
+	}
+	return 1;
+}
+
+/*
+ * To handle raw IPv6 addresses (which contain colons), the
+ * server's address is enclosed in square brackets.  Return
+ * what's between the brackets.
+ *
+ * There could be anything in between the brackets, but we'll
+ * let DNS resolution sort it out later.
+ */
+static int nfs_parse_square_bracket(const char *dev,
+				    char **hostname, char **pathname)
+{
+	size_t host_len, path_len;
+	char *cbrace;
+
+	dev++;
+
+	/* Must have a closing square bracket */
+	cbrace = strchr(dev, ']');
+	if (cbrace == NULL)
+		return nfs_pdn_missing_brace_err();
+	*cbrace = '\0';
+	host_len = cbrace - dev;
+
+	/* Must have a colon just after the closing bracket */
+	cbrace++;
+	if (*cbrace != ':')
+		return nfs_pdn_bad_format_err();
+
+	if (host_len > NFS_MAXHOSTNAME)
+		return nfs_pdn_hostname_too_long_err();
+
+	cbrace++;
+	path_len = strlen(cbrace);
+	if (path_len > NFS_MAXPATHNAME)
+		return nfs_pdn_pathname_too_long_err();
+
+	if (hostname) {
+		*hostname = strndup(dev, host_len);
+		if (*hostname == NULL)
+			return nfs_pdn_nomem_err();
+	}
+	if (pathname) {
+		*pathname = strndup(cbrace, path_len);
+		if (*pathname == NULL) {
+			free(*hostname);
+			return nfs_pdn_nomem_err();
+		}
+	}
+	return 1;
+}
+
+/*
+ * RFC 2224 says an NFS client must grok "public file handles" to
+ * support NFS URLs.  Linux doesn't do that yet.  Print a somewhat
+ * helpful error message in this case instead of pressing forward
+ * with the mount request and failing with a cryptic error message
+ * later.
+ */
+static int nfs_parse_nfs_url(const char *dev,
+			     char **hostname, char **pathname)
+{
+	nfs_error(_("%s: NFS URLs are not supported"), progname);
+	return 0;
+}
+
+/**
+ * nfs_parse_devname - Determine the server's hostname by looking at "devname".
+ * @devname: pointer to mounted device name (first argument of mount command)
+ * @hostname: OUT: pointer to server's hostname
+ * @pathname: OUT: pointer to export path on server
+ *
+ * Returns 1 if succesful, or zero if some error occurred.  On success,
+ * @hostname and @pathname point to dynamically allocated buffers containing
+ * the hostname of the server and the export pathname (both '\0'-terminated).
+ *
+ * @hostname or @pathname may be NULL if caller doesn't want a copy of those
+ * parts of @devname.
+ *
+ * Note that this will not work if @devname is a wide-character string.
+ */
+int nfs_parse_devname(const char *devname,
+		      char **hostname, char **pathname)
+{
+	char *dev;
+	int result;
+
+	if (devname == NULL)
+		return nfs_pdn_no_devname_err();
+
+	/* Parser is destructive, so operate on a copy of the device name. */
+	dev = strdup(devname);
+	if (dev == NULL)
+		return nfs_pdn_nomem_err();
+	if (*dev == '[')
+		result = nfs_parse_square_bracket(dev, hostname, pathname);
+	else if (strncmp(dev, "nfs://", 6) == 0)
+		result = nfs_parse_nfs_url(dev, hostname, pathname);
+	else
+		result = nfs_parse_simple_hostname(dev, hostname, pathname);
+
+	free(dev);
+	return result;
+}
diff --git a/utils/mount/parse_dev.h b/utils/mount/parse_dev.h
new file mode 100644
index 0000000..a1288c2
--- /dev/null
+++ b/utils/mount/parse_dev.h
@@ -0,0 +1,28 @@
+/*
+ * parse_dev.c -- parse device name into hostname and export path
+ *
+ * Copyright (C) 2008 Oracle.  All rights reserved.
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
+#ifndef __NFS_UTILS_PARSE_DEV_HEADER
+#define __NFS_UTILS_PARSE_DEV_HEADER
+
+extern int	nfs_parse_devname(const char *, char **, char **);
+
+#endif	/* __NFS_UTILS_PARSE_DEV */
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index caa2c25..c4f2326 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -49,6 +49,7 @@
 #include "network.h"
 #include "parse_opt.h"
 #include "version.h"
+#include "parse_dev.h"
 
 #ifdef HAVE_RPCSVC_NFS_PROT_H
 #include <rpcsvc/nfs_prot.h>
@@ -98,58 +99,6 @@ struct nfsmount_info {
 	sa_family_t		family;		/* supported address family */
 };
 
-static int nfs_parse_devname(struct nfsmount_info *mi)
-{
-	int ret = 0;
-	char *dev, *pathname, *s;
-
-	dev = xstrdup(mi->spec);
-
-	if (!(pathname = strchr(dev, ':'))) {
-		nfs_error(_("%s: remote share not in 'host:dir' format"),
-				progname);
-		goto out;
-	}
-	*pathname = '\0';
-	pathname++;
-
-	/*
-	 * We don't need a copy of the pathname, but let's
-	 * sanity check it anyway.
-	 */
-	if (strlen(pathname) > NFS_MAXPATHNAME) {
-		nfs_error(_("%s: export pathname is too long"),
-				progname);
-		goto out;
-	}
-
-	/*
-	 * Ignore all but first hostname in replicated mounts
-	 * until they can be fully supported. (mack@sgi.com)
-	 */
-	if ((s = strchr(dev, ','))) {
-		*s = '\0';
-		nfs_error(_("%s: warning: multiple hostnames not supported"),
-				progname);
-		nfs_error(_("%s: ignoring hostnames that follow the first one"),
-				progname);
-	}
-	mi->hostname = xstrdup(dev);
-	if (strlen(mi->hostname) > NFS_MAXHOSTNAME) {
-		nfs_error(_("%s: server hostname is too long"),
-				progname);
-		free(mi->hostname);
-		mi->hostname = NULL;
-		goto out;
-	}
-
-	ret = 1;
-
-out:
-	free(dev);
-	return ret;
-}
-
 static int fill_ipv4_sockaddr(const char *hostname, struct sockaddr_in *addr)
 {
 	struct hostent *hp;
@@ -338,6 +287,9 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 	struct sockaddr *sap = (struct sockaddr *)&dummy;
 	socklen_t salen = sizeof(dummy);
 
+	if (!nfs_parse_devname(mi->spec, &mi->hostname, NULL))
+		return 0;
+
 	if (!nfs_name_to_address(mi->hostname, mi->family, sap, &salen))
 		return 0;
 
@@ -812,9 +764,6 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
 	};
 	int retval = EX_FAIL;
 
-	if (!nfs_parse_devname(&mi))
-		return retval;
-
 	mi.options = po_split(*extra_opts);
 	if (mi.options) {
 		retval = nfsmount_start(&mi);

