From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] mount.nfs: Add new files for supporting
	string-ified	mount options
Date: Fri, 10 Aug 2007 18:19:55 -0400
Message-ID: <20070810221955.21712.61109.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IJcq7-0007iV-DJ
	for nfs@lists.sourceforge.net; Fri, 10 Aug 2007 15:20:39 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IJcpv-0003p1-D2
	for nfs@lists.sourceforge.net; Fri, 10 Aug 2007 15:20:19 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Introduce support files which contain code that builds string mount
options and passes them to the kernel.  This is a pre-requisite for
actually enabling /sbin/mount.nfs to do text-based mounts.

This is only partially complete at the moment, but is presented so that
folks can start banging on the kernel mount option string parsing code.
There are clearly still parts that are not implemented quite yet, such
as bg and retry support, but it should be enough to get going.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/Makefile.am |    4 -
 utils/mount/stropts.c   |  331 +++++++++++++++++++++++++++++++++++++++++++++++
 utils/mount/stropts.h   |   25 ++++
 3 files changed, 358 insertions(+), 2 deletions(-)

diff --git a/utils/mount/Makefile.am b/utils/mount/Makefile.am
index a5d7292..23e7ae9 100644
--- a/utils/mount/Makefile.am
+++ b/utils/mount/Makefile.am
@@ -10,10 +10,10 @@ man5_MANS	= nfs.man
 sbin_PROGRAMS	= mount.nfs
 EXTRA_DIST = nfsmount.x $(man8_MANS) $(man5_MANS)
 mount_nfs_SOURCES = mount.c error.c network.c fstab.c \
-		    nfsmount.c nfs4mount.c \
+		    nfsmount.c nfs4mount.c stropts.c\
 		    nfsumount.c \
 		    mount_constants.h error.h network.h fstab.h \
-		    nfs4_mount.h nfs_mount4.h
+		    nfs4_mount.h nfs_mount4.h stropts.h
 
 mount_nfs_LDADD = ../../support/nfs/libnfs.a \
 		  ../../support/export/libexport.a
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
new file mode 100644
index 0000000..4ee7aae
--- /dev/null
+++ b/utils/mount/stropts.c
@@ -0,0 +1,331 @@
+/*
+ * stropts.c -- NFS mount using C string to pass options to kernel
+ *
+ * Copyright (C) 2007 Oracle.  All rights reserved.
+ * Copyright (C) 2007 Chuck Lever <chuck.lever@oracle.com>
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
+#include <ctype.h>
+#include <unistd.h>
+#include <stdio.h>
+#include <string.h>
+#include <stdlib.h>
+#include <errno.h>
+#include <netdb.h>
+#include <time.h>
+#include <sys/socket.h>
+#include <sys/mount.h>
+
+#include "xcommon.h"
+#include "mount.h"
+#include "nls.h"
+#include "nfs_mount.h"
+#include "mount_constants.h"
+#include "error.h"
+#include "network.h"
+
+#ifdef HAVE_RPCSVC_NFS_PROT_H
+#include <rpcsvc/nfs_prot.h>
+#else
+#include <linux/nfs.h>
+#define nfsstat nfs_stat
+#endif
+
+#ifndef NFS_PORT
+#define NFS_PORT 2049
+#endif
+
+extern int nfs_mount_data_version;
+extern char *progname;
+extern int verbose;
+
+static int retry_opt = 10000;		/* 10,000 minutes ~= 1 week */
+static int bg_opt = 0;
+static int addr_opt = 0;
+static int ca_opt = 0;
+
+static int parse_devname(char *hostdir, char **hostname, char **dirname)
+{
+	char *s;
+
+	if (!(s = strchr(hostdir, ':'))) {
+		nfs_error(_("%s: directory to mount not in host:dir format"),
+				progname);
+		return -1;
+	}
+	*hostname = hostdir;
+	*dirname = s + 1;
+	*s = '\0';
+	/* Ignore all but first hostname in replicated mounts
+	   until they can be fully supported. (mack@sgi.com) */
+	if ((s = strchr(hostdir, ','))) {
+		*s = '\0';
+		nfs_error(_("%s: warning: multiple hostnames not supported"),
+				progname);
+	}
+	return 0;
+}
+
+static int fill_ipv4_sockaddr(const char *hostname, struct sockaddr_in *addr)
+{
+	struct hostent *hp;
+	addr->sin_family = AF_INET;
+
+	if (inet_aton(hostname, &addr->sin_addr))
+		return 1;
+	if ((hp = gethostbyname(hostname)) == NULL) {
+		nfs_error(_("%s: can't get address for %s\n"),
+				progname, hostname);
+		return 0;
+	}
+	if (hp->h_length > sizeof(struct in_addr)) {
+		nfs_error(_("%s: got bad hp->h_length"), progname);
+		hp->h_length = sizeof(struct in_addr);
+	}
+	memcpy(&addr->sin_addr, hp->h_addr, hp->h_length);
+	return 1;
+}
+
+/*
+ * XXX: This should really use the technique neil recently added
+ * to get the address off the local end of a socket connected to
+ * the server -- to get the right address to use on multi-homed
+ * clients
+ */
+static int get_my_ipv4addr(char *ip_addr, int len)
+{
+	char myname[1024];
+	struct sockaddr_in myaddr;
+
+	if (gethostname(myname, sizeof(myname))) {
+		nfs_error(_("%s: can't determine client address\n"),
+				progname);
+		return 0;
+	}
+	if (!fill_ipv4_sockaddr(myname, &myaddr))
+		return 0;
+
+	snprintf(ip_addr, len, "%s", inet_ntoa(myaddr.sin_addr));
+	ip_addr[len - 1] = '\0';
+
+	return 1;
+}
+
+/*
+ * Walk through our mount options string, and indicate the presence
+ * of 'bg', 'retry=', and 'clientaddr='.
+ */
+static void extract_interesting_options(char *opts)
+{
+	char *opt, *opteq;
+	int val;
+
+	opts = xstrdup(opts);
+
+	for (opt = strtok(opts, ","); opt; opt = strtok(NULL, ",")) {
+		if ((opteq = strchr(opt, '='))) {
+			val = atoi(opteq + 1);  
+			*opteq = '\0';
+			if (strcmp(opt, "bg") == 0)
+				bg_opt++;
+			else if (strcmp(opt, "retry") == 0)
+				retry_opt = val;
+			else if (strcmp(opt, "addr") == 0)
+				addr_opt++;
+			else if (strcmp(opt, "clientaddr") == 0)
+				ca_opt++;
+		} else {
+			if (strcmp(opt, "bg") == 0)
+				bg_opt++;
+		}
+	}
+
+	free(opts);
+}
+
+/*
+ * Append the "addr=" option to the options string.
+ *
+ * We always add our own addr= to the end of the options string.
+ */
+static int append_addr_opt(const char *spec, char **extra_opts)
+{	
+	static char hostdir[1024], new_opts[1024], ip_addr[255];
+	char *hostname, *dirname, *s, *old_opts;
+	struct sockaddr_in addr;
+
+	if (strlen(spec) >= sizeof(hostdir)) {
+		nfs_error(_("%s: excessively long host:dir argument\n"),
+				progname);
+		return 0;
+	}
+	strcpy(hostdir, spec);
+	if (parse_devname(hostdir, &hostname, &dirname)) {
+		nfs_error(_("%s: parsing host:dir argument failed\n"),
+				progname);
+		return 0;
+	}
+
+	if (!fill_ipv4_sockaddr(hostname, &addr))
+		return 0;
+	if (!get_my_ipv4addr(ip_addr, sizeof(ip_addr)))
+		return 0;
+
+	/* add IP address to mtab options for use when unmounting */
+	s = inet_ntoa(addr.sin_addr);
+	old_opts = *extra_opts;
+	if (!old_opts)
+		old_opts = "";
+	if (strlen(old_opts) + strlen(s) + 10 >= sizeof(new_opts)) {
+		nfs_error(_("%s: excessively long option argument\n"),
+				progname);
+		return 0;
+	}
+	snprintf(new_opts, sizeof(new_opts), "%s%saddr=%s",
+		 old_opts, *old_opts ? "," : "", s);
+	*extra_opts = xstrdup(new_opts);
+
+	return 1;
+}
+
+/*
+ * Append the "clientaddr=" option to the options string.
+ *
+ * Returns 1 if clientaddr option created successfully;
+ * otherwise zero.
+ */
+static int append_clientaddr_opt(const char *spec, char **extra_opts)
+{
+	static char new_opts[1024], cbuf[1024];
+	static char ip_addr[16] = "127.0.0.1";
+
+	if (!get_my_ipv4addr(ip_addr, sizeof(ip_addr)))
+		return 0;
+
+	/* Ensure we have enough padding for the following strcat()s */
+	if (strlen(*extra_opts) + strlen(ip_addr) + 10 >= sizeof(new_opts)) {
+		nfs_error(_("%s: excessively long option argument"),
+				progname);
+		return 0;
+	}
+
+	strcat(new_opts, *extra_opts);
+
+	snprintf(cbuf, sizeof(cbuf) - 1, "%sclientaddr=%s",
+			*extra_opts ? "," : "", ip_addr);
+	strcat(new_opts, cbuf);
+
+	*extra_opts = xstrdup(new_opts);
+
+	return 1;
+}
+
+/*
+ * nfsmount_s - Mount an NFSv2 or v3 file system using C string options
+ *
+ * @spec:	C string hostname:path specifying remoteshare to mount
+ * @node:	C string pathname of local mounted on directory
+ * @flags:	MS_ style flags
+ * @extra_opts:	pointer to C string containing fs-specific mount options
+ *		(possibly also a return argument)
+ * @fake:	flag indicating whether to carry out the whole operation
+ * @bg:		one if this is a backgrounded mount attempt
+ *
+ * XXX: need to handle bg, fg, and retry options.
+ */
+int nfsmount_s(const char *spec, const char *node, int flags,
+		char **extra_opts, int fake, int bg)
+{
+	int retval = EX_FAIL;
+
+	if (verbose)
+		printf(_("%s: using C string mount system call interface\n"),
+			progname);
+
+	extract_interesting_options(*extra_opts);
+
+	if (!addr_opt && !append_addr_opt(spec, extra_opts))
+		goto fail;
+
+	if (verbose)
+		printf(_("%s: option string is '%s'\n"),
+			progname, *extra_opts);
+
+	if (!fake) {
+		if (mount(spec, node, "nfs",
+				flags & ~(MS_USER|MS_USERS), *extra_opts)) {
+			mount_error(spec, node, errno);
+			goto fail;
+		}
+	}
+
+	return 0;
+
+fail:
+	return retval;
+}
+
+/*
+ * nfs4mount_s - Mount an NFSv4 file system using C string options
+ *
+ * @spec:	C string hostname:path specifying remoteshare to mount
+ * @node:	C string pathname of local mounted on directory
+ * @flags:	MS_ style flags
+ * @extra_opts:	pointer to C string containing fs-specific mount options
+ *		(possibly also a return argument)
+ * @fake:	flag indicating whether to carry out the whole operation
+ * @bg:		one if this is a backgrounded mount attempt
+ *
+ * XXX: need to handle bg, fg, and retry options.
+ *
+ */
+int nfs4mount_s(const char *spec, const char *node, int flags,
+		char **extra_opts, int fake)
+{
+	int retval = EX_FAIL;
+
+	if (verbose)
+		printf(_("%s: using C string mount system call interface\n"),
+			progname);
+
+	extract_interesting_options(*extra_opts);
+
+	if (!addr_opt && !append_addr_opt(spec, extra_opts))
+		goto fail;
+
+	if (!ca_opt && !append_clientaddr_opt(spec, extra_opts))
+		goto fail;
+
+	if (verbose)
+		printf(_("%s: option string is '%s'\n"),
+			progname, *extra_opts);
+
+	if (!fake) {
+		if (mount(spec, node, "nfs4",
+				flags & ~(MS_USER|MS_USERS), *extra_opts)) {
+			mount_error(spec, node, errno);
+			goto fail;
+		}
+	}
+
+	return 0;
+
+fail:
+	return retval;
+}
diff --git a/utils/mount/stropts.h b/utils/mount/stropts.h
new file mode 100644
index 0000000..a2a0604
--- /dev/null
+++ b/utils/mount/stropts.h
@@ -0,0 +1,25 @@
+/*
+ * stropts.h -- Provide common network functions for NFS mount/umount
+ *
+ * Copyright (C) 2007 Oracle.  All rights reserved.
+ * Copyright (C) 2007 Chuck Lever <chuck.lever@oracle.com>
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
+int nfsmount_s(const char *, const char *, int , char **, int, int);
+int nfs4mount_s(const char *, const char *, int, char **, int, int);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
