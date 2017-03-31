Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44514 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755405AbdCaV44 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 31 Mar 2017 17:56:56 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: neilb@suse.com, linux-nfs@vger.kernel.org
Subject: [RFC nfs-utils PATCH 2/2] systemd: add a generator for the rpc_pipefs mountpoint
Date: Fri, 31 Mar 2017 17:56:54 -0400
Message-Id: <20170331215654.31570-3-smayhew@redhat.com>
In-Reply-To: <20170331215654.31570-1-smayhew@redhat.com>
References: <20170331215654.31570-1-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfs.conf has config options for the pipefs mountpoint.  Currently,
changing these from the default also requires manually overriding the
systemd unit files that are hard-coded to mount the filesystem on
/var/lib/nfs/rpc_pipefs.

This patch adds a generator that creates a mount unit file for the
pipefs when a non-default value is specified in /etc/nfs.conf, as well
as drop-in config files to override the dependencies for the systemd
units using the pipefs.

This patch also removes the dependency on the pipefs from the
rpc-svcgssd.service unit file.  rpc.svcgssd uses the sunrpc cache
mechanism to exchange data with the kernel, not the pipefs.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 .gitignore                     |   1 +
 systemd/Makefile.am            |   4 +-
 systemd/rpc-pipefs-generator.c | 256 +++++++++++++++++++++++++++++++++++++++++
 systemd/rpc-svcgssd.service    |   3 +-
 4 files changed, 261 insertions(+), 3 deletions(-)
 create mode 100644 systemd/rpc-pipefs-generator.c

diff --git a/.gitignore b/.gitignore
index 126d12c..941aca0 100644
--- a/.gitignore
+++ b/.gitignore
@@ -70,6 +70,7 @@ tests/nsm_client/nlm_sm_inter_svc.c
 tests/nsm_client/nlm_sm_inter_xdr.c
 utils/nfsidmap/nfsidmap
 systemd/nfs-server-generator
+systemd/rpc-pipefs-generator
 systemd/nfs-config.service
 systemd/rpc-gssd.service
 # cscope database files
diff --git a/systemd/Makefile.am b/systemd/Makefile.am
index 0d15b9f..4a04f5a 100644
--- a/systemd/Makefile.am
+++ b/systemd/Makefile.am
@@ -42,12 +42,14 @@ EXTRA_DIST = $(unit_files) $(man5_MANS) $(man7_MANS)
 unit_dir = /usr/lib/systemd/system
 generator_dir = /usr/lib/systemd/system-generators
 
-EXTRA_PROGRAMS	= nfs-server-generator
+EXTRA_PROGRAMS	= nfs-server-generator rpc-pipefs-generator
 genexecdir = $(generator_dir)
 nfs_server_generator_LDADD = ../support/export/libexport.a \
 			     ../support/nfs/libnfs.a \
 			     ../support/misc/libmisc.a
 
+rpc_pipefs_generator_LDADD = ../support/nfs/libnfs.a
+
 if INSTALL_SYSTEMD
 genexec_PROGRAMS = nfs-server-generator
 install-data-hook: $(unit_files)
diff --git a/systemd/rpc-pipefs-generator.c b/systemd/rpc-pipefs-generator.c
new file mode 100644
index 0000000..99d5a9b
--- /dev/null
+++ b/systemd/rpc-pipefs-generator.c
@@ -0,0 +1,256 @@
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
+char *conf_path;
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
+ * blkmapd is a placeholder for (generate=0) because it does not have nfs.conf
+ * support and because the pipefs directory cannot be overriden.
+ */
+static struct pipefs_user	pipefs_users[NUM_PIPEFS_USERS] = {
+	{
+		.conf_name = "blkmapd",
+		.unit_name = "nfs-blkmap",
+		.after_local_fs = 0,
+		.generate = 0,
+	},
+	{
+		.conf_name = "gssd",
+		.unit_name = "rpc-gssd",
+		.after_local_fs = 0,
+		.generate = 1,
+	},
+	{
+		.conf_name = "idmapd",
+		.unit_name = "nfs-idmapd",
+		.after_local_fs = 1,
+		.generate = 1,
+	}
+};
+
+int systemd_len(char *path)
+{
+	char *p;
+	int len = 0;
+
+	p = path;
+	while (*p == '/')
+		p++;
+
+	if (!*p)
+		/* "/" becomes "-", otherwise leading "/" is ignored */
+		return 1;
+
+	while (*p) {
+		unsigned char c = *p++;
+
+		if (c == '/') {
+			/* multiple non-trailing slashes become '-' */
+			while (*p == '/')
+				p++;
+			if (*p)
+				len++;
+		} else if (isalnum(c) || c == ':' || c == '.' || c == '_')
+			len++;
+		else {
+			len += 4;
+		}
+	}
+
+	return len;
+}
+
+char *systemd_escape(char *path)
+{
+	char *result = NULL;
+	char *p;
+	int len;
+
+	len = systemd_len(path);
+	if (!len)
+		goto out;
+
+	result = malloc(len + strlen(".mount") + 1);
+	if (!result)
+		goto out;
+
+	p = result;
+	while (*path == '/')
+		path++;
+	if (!*path) {
+		/* "/" becomes "-", otherwise leading "/" is ignored */
+		*p++ = '-';
+		goto out_append;
+	}
+	while (*path) {
+		unsigned char c = *path++;
+
+		if (c == '/') {
+			/* multiple non-trailing slashes become '-' */
+			while (*path == '/')
+				path++;
+			if (*path)
+				*p++ = '-';
+		} else if (isalnum(c) || c == ':' || c == '.' || c == '_')
+			*p++ = c;
+		else {
+			*p++ = '\\';
+			*p++ = 'x';
+			*p++ = '0' + ((c&0xf0)>>4) + (c>=0xa0)*('a'-'9'-1);
+			*p++ = '0' + (c&0x0f) + ((c&0x0f)>=0x0a)*('a'-'9'-1);
+		}
+	}
+
+out_append:
+	sprintf(p, ".mount");
+out:
+	return result;
+}
+
+static int generate_mount_unit(const char *mountpoint, const char *unitname,
+			       const char *dirname)
+{
+	char	*path;
+	struct stat stb;
+	FILE	*f;
+
+	path = malloc(strlen(dirname) + 1 + strlen(unitname));
+	if (!path)
+		return 1;
+	sprintf(path, "%s/%s", dirname, unitname);
+	if (stat(path, &stb) == 0)
+		return 0;
+	f = fopen(path, "w");
+	if (!f)
+		return 1;
+
+	fprintf(f, "# Automatically generated by rpc-pipefs-generator\n\n[Unit]\n");
+	fprintf(f, "Description=RPC Pipe File System\n");
+	fprintf(f, "DefaultDependencies=no\n");
+	fprintf(f, "After=systemd-tmpfiles-setup.service\n");
+	fprintf(f, "Conflicts=umount.target\n");
+	fprintf(f, "\n[Mount]\n");
+	fprintf(f, "What=sunrpc\n");
+	fprintf(f, "Where=%s\n", mountpoint);
+	fprintf(f, "Type=rpc_pipefs\n");
+
+	fclose(f);
+	return 0;
+}
+
+static
+int generate_drop_in(char *conf_name, char *unit_name,
+		     const int after_local_fs, const char *dirname)
+{
+	char	*path;
+	char	dirbase[] = ".service.d";
+	char	filebase[] = "/10-pipefs.conf";
+	char	*s;
+	char	*pipefs_unit;
+	FILE	*f;
+	int 	ret = 0;
+
+	s = conf_get_str(conf_name, "pipefs-directory");
+	if (!s)
+		return 0;
+
+	if (strlen(s) == strlen(RPC_PIPEFS_DEFAULT) &&
+			strcmp(s, RPC_PIPEFS_DEFAULT) == 0)
+		return 0;
+
+	pipefs_unit = systemd_escape(s);
+	if (!pipefs_unit)
+		return 1;
+
+	ret = generate_mount_unit(s, pipefs_unit, dirname);
+	if (ret)
+		return ret;
+
+	path = malloc(strlen(dirname) + 1 + sizeof(unit_name) +
+			sizeof(dirbase) + sizeof(filebase));
+	if (!path)
+		return 2;
+	sprintf(path, "%s/%s%s", dirname, unit_name, dirbase);
+	mkdir(path, 0755);
+	strcat(path, filebase);
+	f = fopen(path, "w");
+	if (!f)
+		return 1;
+
+	fprintf(f, "# Automatically generated by rpc-pipefs-generator\n\n[Unit]\n");
+	fprintf(f, "Requires=\nRequires=");
+	fprintf(f, "%s\n", pipefs_unit);
+	fprintf(f, "After=\nAfter=");
+	fprintf(f, "%s", pipefs_unit);
+	if (after_local_fs)
+		fprintf(f, " local-fs.target");
+	fprintf(f, "\n");
+	fclose(f);
+
+	return 0;
+}
+
+int main(int argc, char *argv[])
+{
+	int	i;
+	struct pipefs_user p;
+	int 	ret;
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
+	conf_path = NFS_CONFFILE;
+	conf_init();
+	for (i = 0; i < NUM_PIPEFS_USERS; i++) {
+		p = pipefs_users[i];
+		if (!p.generate)
+			continue;
+
+		ret = generate_drop_in(p.conf_name, p.unit_name,
+				       p.after_local_fs, argv[1]);
+		if (ret)
+			exit(ret);
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
 
-- 
2.9.3

