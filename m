Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49176 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932339AbdC1NhU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 28 Mar 2017 09:37:20 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id B73D2C05AA52
        for <linux-nfs@vger.kernel.org>; Tue, 28 Mar 2017 13:37:03 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] systemd: add generators for the rpc_pipefs mountpoint
Date: Tue, 28 Mar 2017 09:37:03 -0400
Message-Id: <20170328133703.19325-1-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfs.conf and idmapd.conf files both have config options for the
pipefs mountpoint.  Currently, changing these from the defaults also
requires manually overriding the systemd unit files that are hard-coded
to mount the filesystem on /var/lib/nfs/rpc_pipefs.

This patch adds two generators to create drop-in config files to
override the dependencies for the systemd units that require the pipefs.
There are two because rpc.idmapd uses a separate configuration file.  If
idmapd's configurations are ever folded into the nfs.conf, then the
idmapd-rpc-pipefs-generator.c can be deleted and generate=1 can be
specified for idmapd in rpc-pipefs-generator.c.

This patch also adds a unit file to mount the pipefs on /run/rpc_pipefs,
since that is the most logical alternate location for the pipefs
filesystem.  Users wanting to use some other location besides
/var/lib/nfs/rpc_pipefs or /run/rpc_pipefs would have to create their
own systemd mount unit file, but the generators would take care of the
rest.

Finally, this patch removes the dependency on the pipefs from the
rpc-svcgssd.service unit file.  rpc.svcgssd uses the sunrpc cache
mechanism to exchange data with the kernel, not the pipefs.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 systemd/Makefile.am                   |   5 +-
 systemd/idmapd-rpc-pipefs-generator.c |  99 ++++++++++++++++++++++
 systemd/rpc-pipefs-generator.c        | 153 ++++++++++++++++++++++++++++++++++
 systemd/rpc-svcgssd.service           |   3 +-
 systemd/run-rpc_pipefs.mount          |  10 +++
 5 files changed, 267 insertions(+), 3 deletions(-)
 create mode 100644 systemd/idmapd-rpc-pipefs-generator.c
 create mode 100644 systemd/rpc-pipefs-generator.c
 create mode 100644 systemd/run-rpc_pipefs.mount

diff --git a/systemd/Makefile.am b/systemd/Makefile.am
index 0d15b9f..f09be00 100644
--- a/systemd/Makefile.am
+++ b/systemd/Makefile.am
@@ -42,12 +42,15 @@ EXTRA_DIST = $(unit_files) $(man5_MANS) $(man7_MANS)
 unit_dir = /usr/lib/systemd/system
 generator_dir = /usr/lib/systemd/system-generators
 
-EXTRA_PROGRAMS	= nfs-server-generator
+EXTRA_PROGRAMS	= nfs-server-generator rpc-pipefs-generator idmapd-rpc-pipefs-generator
 genexecdir = $(generator_dir)
 nfs_server_generator_LDADD = ../support/export/libexport.a \
 			     ../support/nfs/libnfs.a \
 			     ../support/misc/libmisc.a
 
+rpc_pipefs_generator_LDADD = ../support/nfs/libnfs.a
+idmapd_rpc_pipefs_generator_LDADD = ../support/nfs/libnfs.a
+
 if INSTALL_SYSTEMD
 genexec_PROGRAMS = nfs-server-generator
 install-data-hook: $(unit_files)
diff --git a/systemd/idmapd-rpc-pipefs-generator.c b/systemd/idmapd-rpc-pipefs-generator.c
new file mode 100644
index 0000000..6b0e382
--- /dev/null
+++ b/systemd/idmapd-rpc-pipefs-generator.c
@@ -0,0 +1,99 @@
+/*
+ * idmapd-rpc-pipefs-generator:
+ *   systemd generator to create ordering dependencies between
+ *   the nfs-idmapd service and the rpc_pipefs mount
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <unistd.h>
+#include <stdlib.h>
+#include <string.h>
+#include <ctype.h>
+#include <stdio.h>
+
+#include "nfslib.h"
+#include "conffile.h"
+
+#define RPC_PIPEFS_DEFAULT "/var/lib/nfs/rpc_pipefs"
+char *conf_path = _PATH_IDMAPDCONF;
+
+/* We need to convert a path name to a systemd unit
+ * name.  This requires some translation ('/' -> '-')
+ * and some escaping.
+ */
+static void systemd_escape(FILE *f, char *path)
+{
+	while (*path == '/')
+		path++;
+	if (!*path) {
+		/* "/" becomes "-", otherwise leading "/" is ignored */
+		fputs("-", f);
+		return;
+	}
+	while (*path) {
+		char c = *path++;
+
+		if (c == '/') {
+			/* multiple non-trailing slashes become '-' */
+			while (*path == '/')
+				path++;
+			if (*path)
+				fputs("-", f);
+		} else if (isalnum(c) || c == ':' || c == '.' || c == '_')
+			fputc(c, f);
+		else
+			fprintf(f, "\\x%02x", c & 0xff);
+	}
+}
+
+int main(int argc, char *argv[])
+{
+	char	*path;
+	char	dirbase[] = "/nfs-idmapd.service.d";
+	char	filebase[] = "/10-pipefs.conf";
+	FILE	*f;
+	char	*s;
+
+	/* Avoid using any external services */
+	xlog_syslog(0);
+
+	if (argc != 4 || argv[1][0] != '/') {
+		fprintf(stderr, "idmapd-rpc-pipefs-generator: create systemd dependencies for nfs-idmapd\n");
+		fprintf(stderr, "Usage: normal-dir early-dir late-dir\n");
+		exit(1);
+	}
+
+	conf_init();
+	s = conf_get_str("General", "pipefs-directory");
+	if (!s)
+		exit(0);
+	if (strlen(s) == strlen(RPC_PIPEFS_DEFAULT) &&
+			strcmp(s, RPC_PIPEFS_DEFAULT) == 0)
+		exit(0);
+
+	path = malloc(strlen(argv[1]) + sizeof(dirbase) + sizeof(filebase));
+	if (!path)
+		exit(2);
+	strcat(strcpy(path, argv[1]), dirbase);
+	mkdir(path, 0755);
+	strcat(path, filebase);
+	f = fopen(path, "w");
+	if (!f)
+		exit(1);
+
+	fprintf(f, "# Automatically generated by idmapd-rpc-pipefs-generator\n\n[Unit]\n");
+	fprintf(f, "Requires=\nRequires=");
+	systemd_escape(f, s);
+	fprintf(f, ".mount\n");
+	fprintf(f, "After=\nAfter=");
+	systemd_escape(f, s);
+	fprintf(f, ".mount local-fs.target\n");
+	fclose(f);
+
+	exit(0);
+}
diff --git a/systemd/rpc-pipefs-generator.c b/systemd/rpc-pipefs-generator.c
new file mode 100644
index 0000000..fc65cc9
--- /dev/null
+++ b/systemd/rpc-pipefs-generator.c
@@ -0,0 +1,153 @@
+/*
+ * rpc-pipefs-generator:
+ *   systemd generator to create ordering dependencies between
+ *   nfs services and the rpc_pipefs mount(s)
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <unistd.h>
+#include <stdlib.h>
+#include <string.h>
+#include <ctype.h>
+#include <stdio.h>
+
+#include "nfslib.h"
+#include "conffile.h"
+
+#define NUM_PIPEFS_USERS 3
+#define RPC_PIPEFS_DEFAULT "/var/lib/nfs/rpc_pipefs"
+char *conf_path = NFS_CONFFILE;
+
+/*
+ * conf_name - the name as it appears (or would appear, in the case of idmapd,
+ *             in the /etc/nfs.conf
+ * unit_name - the name of the systemd service unit file (minus '.service')
+ * after_local_fs - should the After= directive have local-fs.target or not
+ * generate - should a drop-in config be generated or not
+ */
+struct pipefs_user {
+	char	*conf_name;
+	char	*unit_name;
+	int	after_local_fs;
+	int	generate;
+};
+
+/*
+ * blkmapd and idmapd are placeholders for now, hence generate=0.  blkmapd
+ * because it does not have nfs.conf support and because the pipefs directory
+ * cannot be overriden.  idmapd because it uses a different config file.
+ */
+static struct pipefs_user	pipefs_users[NUM_PIPEFS_USERS] = {
+	{
+		.conf_name = "gssd",
+		.unit_name = "rpc-gssd",
+		.after_local_fs = 0,
+		.generate = 1,
+	},
+	{
+		.conf_name = "blkmapd",
+		.unit_name = "nfs-blkmap",
+		.after_local_fs = 0,
+		.generate = 0,
+	},
+	{
+		.conf_name = "idmapd",
+		.unit_name = "nfs-idmapd",
+		.after_local_fs = 1,
+		.generate = 0,
+	}
+};
+
+/* We need to convert a path name to a systemd unit
+ * name.  This requires some translation ('/' -> '-')
+ * and some escaping.
+ */
+static void systemd_escape(FILE *f, char *path)
+{
+	while (*path == '/')
+		path++;
+	if (!*path) {
+		/* "/" becomes "-", otherwise leading "/" is ignored */
+		fputs("-", f);
+		return;
+	}
+	while (*path) {
+		char c = *path++;
+
+		if (c == '/') {
+			/* multiple non-trailing slashes become '-' */
+			while (*path == '/')
+				path++;
+			if (*path)
+				fputs("-", f);
+		} else if (isalnum(c) || c == ':' || c == '.' || c == '_')
+			fputc(c, f);
+		else
+			fprintf(f, "\\x%02x", c & 0xff);
+	}
+}
+
+int main(int argc, char *argv[])
+{
+	char	*path;
+	char	dirbase[] = ".service.d";
+	char	filebase[] = "/10-pipefs.conf";
+	FILE	*f;
+	char	*s;
+	int	i;
+	struct	pipefs_user p;
+
+	/* Avoid using any external services */
+	xlog_syslog(0);
+
+	if (argc != 4 || argv[1][0] != '/') {
+		fprintf(stderr, "rpc-pipefs-generator: create systemd dependencies for nfs services\n");
+		fprintf(stderr, "Usage: normal-dir early-dir late-dir\n");
+		exit(1);
+	}
+
+	conf_init();
+	for (i = 0; i < NUM_PIPEFS_USERS; i++) {
+		p = pipefs_users[i];
+		if (!p.generate)
+			continue;
+
+		s = conf_get_str(p.conf_name, "pipefs-directory");
+		if (!s)
+			continue;
+		if (strlen(s) == strlen(RPC_PIPEFS_DEFAULT) &&
+				strcmp(s, RPC_PIPEFS_DEFAULT) == 0)
+			continue;
+
+		path = malloc(strlen(argv[1]) + 1 + sizeof(p.unit_name) +
+				sizeof(dirbase) + sizeof(filebase));
+		if (!path)
+			exit(2);
+		sprintf(path, "%s/%s%s", argv[1], p.unit_name, dirbase);
+		mkdir(path, 0755);
+		strcat(path, filebase);
+		f = fopen(path, "w");
+		if (!f)
+			exit(1);
+
+		fprintf(f, "# Automatically generated by rpc-pipefs-generator\n\n[Unit]\n");
+		fprintf(f, "Requires=\nRequires=");
+		systemd_escape(f, s);
+		fprintf(f, ".mount\n");
+		fprintf(f, "After=\nAfter=");
+		systemd_escape(f, s);
+		fprintf(f, ".mount");
+		if (p.after_local_fs)
+			fprintf(f, " local-fs.target");
+		fprintf(f, "\n");
+
+		fclose(f);
+	}
+
+	exit(0);
+}
diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
index 7187e3c..cb2bcd4 100644
--- a/systemd/rpc-svcgssd.service
+++ b/systemd/rpc-svcgssd.service
@@ -1,8 +1,7 @@
 [Unit]
 Description=RPC security service for NFS server
 DefaultDependencies=no
-Requires=var-lib-nfs-rpc_pipefs.mount
-After=var-lib-nfs-rpc_pipefs.mount local-fs.target
+After=local-fs.target
 PartOf=nfs-server.service
 PartOf=nfs-utils.service
 
diff --git a/systemd/run-rpc_pipefs.mount b/systemd/run-rpc_pipefs.mount
new file mode 100644
index 0000000..aab3145
--- /dev/null
+++ b/systemd/run-rpc_pipefs.mount
@@ -0,0 +1,10 @@
+[Unit]
+Description=RPC Pipe File System
+DefaultDependencies=no
+After=systemd-tmpfiles-setup.service
+Conflicts=umount.target
+
+[Mount]
+What=sunrpc
+Where=/run/rpc_pipefs
+Type=rpc_pipefs
-- 
2.9.3

